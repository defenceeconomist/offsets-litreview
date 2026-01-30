"""Utilities for embedding tag/context strings with optional caching.

Designed to be model-agnostic: pass a custom `embed_fn` if you prefer a
remote API or another local model.
"""

from __future__ import annotations

from dataclasses import dataclass
import hashlib
import json
import os
import sqlite3
from typing import Callable, Iterable, List, Sequence, Tuple, Union

import numpy as np

TextLike = Union[str, dict]
EmbedFn = Callable[[Sequence[str]], np.ndarray]


@dataclass(frozen=True)
class NormalizedItem:
    """Normalized input wrapper.

    - id: stable identifier for the item if provided
    - text: the text to embed
    - raw: original item for traceability
    """

    id: str
    text: str
    raw: TextLike


def normalize_inputs(
    items: Union[Sequence[TextLike], dict],
    text_key: str = "text",
    id_key: str = "id",
) -> List[NormalizedItem]:
    """Normalize inputs into a list of NormalizedItem.

    Supports:
    - list of strings
    - list of dicts with text_key
    - dict mapping id -> text
    """

    normalized: List[NormalizedItem] = []

    if isinstance(items, dict):
        for k, v in items.items():
            if not isinstance(v, str):
                raise ValueError("Dict values must be strings when items is a dict")
            normalized.append(NormalizedItem(id=str(k), text=v, raw={id_key: k, text_key: v}))
        return normalized

    for i, item in enumerate(items):
        if isinstance(item, str):
            normalized.append(NormalizedItem(id=str(i), text=item, raw=item))
            continue
        if isinstance(item, dict):
            if text_key not in item:
                raise ValueError(f"Missing '{text_key}' in item {i}")
            text = str(item[text_key])
            item_id = str(item.get(id_key, i))
            normalized.append(NormalizedItem(id=item_id, text=text, raw=item))
            continue
        raise ValueError(f"Unsupported item type at index {i}: {type(item)}")

    return normalized


class EmbeddingCache:
    """SQLite-backed embedding cache keyed by (model_name, text hash)."""

    def __init__(self, path: str):
        self.path = path
        os.makedirs(os.path.dirname(path), exist_ok=True)
        self._conn = sqlite3.connect(path)
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS embeddings (
                key TEXT PRIMARY KEY,
                dim INTEGER NOT NULL,
                dtype TEXT NOT NULL,
                shape TEXT NOT NULL,
                vec BLOB NOT NULL
            )
            """
        )
        self._conn.commit()

    def _make_key(self, model_name: str, text: str) -> str:
        h = hashlib.sha256(text.encode("utf-8")).hexdigest()
        return f"{model_name}:{h}"

    def get(self, model_name: str, text: str) -> np.ndarray | None:
        key = self._make_key(model_name, text)
        cur = self._conn.execute(
            "SELECT dim, dtype, shape, vec FROM embeddings WHERE key = ?", (key,)
        )
        row = cur.fetchone()
        if not row:
            return None
        _, dtype, shape_json, blob = row
        shape = tuple(json.loads(shape_json))
        vec = np.frombuffer(blob, dtype=dtype).reshape(shape)
        return vec

    def set(self, model_name: str, text: str, vec: np.ndarray) -> None:
        key = self._make_key(model_name, text)
        vec = np.asarray(vec, dtype=np.float32)
        shape = vec.shape
        self._conn.execute(
            "INSERT OR REPLACE INTO embeddings (key, dim, dtype, shape, vec) VALUES (?, ?, ?, ?, ?)",
            (key, vec.size, str(vec.dtype), json.dumps(shape), vec.tobytes()),
        )
        self._conn.commit()

    def close(self) -> None:
        self._conn.close()


def default_embedder(model_name: str = "all-MiniLM-L6-v2", device: str | None = None) -> EmbedFn:
    """Return a sentence-transformers embedder function.

    Requires `sentence-transformers` installed.
    """

    try:
        from sentence_transformers import SentenceTransformer
    except Exception as exc:  # pragma: no cover - import guard
        raise RuntimeError(
            "sentence-transformers is required for default_embedder; "
            "install it or pass a custom embed_fn"
        ) from exc

    model = SentenceTransformer(model_name, device=device)

    def _embed(texts: Sequence[str]) -> np.ndarray:
        return np.asarray(model.encode(list(texts), normalize_embeddings=False, show_progress_bar=False))

    return _embed


def embed_texts(
    texts: Sequence[str],
    embed_fn: EmbedFn,
    *,
    normalize: bool = True,
) -> np.ndarray:
    """Embed a batch of texts with optional L2 normalization."""

    vecs = np.asarray(embed_fn(texts))
    if vecs.ndim != 2:
        raise ValueError("embed_fn must return a 2D array [n, dim]")
    if normalize:
        norms = np.linalg.norm(vecs, axis=1, keepdims=True)
        norms[norms == 0] = 1.0
        vecs = vecs / norms
    return vecs


def embed_with_cache(
    texts: Sequence[str],
    embed_fn: EmbedFn,
    *,
    model_name: str,
    cache: EmbeddingCache | None = None,
    normalize: bool = True,
) -> np.ndarray:
    """Embed texts using cache where possible.

    If cache is provided, missing vectors are computed via embed_fn and stored.
    """

    if cache is None:
        return embed_texts(texts, embed_fn, normalize=normalize)

    vecs: List[np.ndarray] = []
    missing: List[Tuple[int, str]] = []
    for i, text in enumerate(texts):
        cached = cache.get(model_name, text)
        if cached is None:
            missing.append((i, text))
            vecs.append(None)  # type: ignore[arg-type]
        else:
            vecs.append(cached)

    if missing:
        miss_texts = [t for _, t in missing]
        miss_vecs = embed_texts(miss_texts, embed_fn, normalize=False)
        for (i, text), vec in zip(missing, miss_vecs, strict=False):
            cache.set(model_name, text, vec)
            vecs[i] = vec

    vecs_arr = np.vstack(vecs)
    if normalize:
        norms = np.linalg.norm(vecs_arr, axis=1, keepdims=True)
        norms[norms == 0] = 1.0
        vecs_arr = vecs_arr / norms
    return vecs_arr
