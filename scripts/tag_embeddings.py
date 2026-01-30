"""Embedding helpers for tag normalization and clustering."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import sqlite3
from typing import Callable, Iterable, Mapping, Sequence

import numpy as np


@dataclass(frozen=True)
class NormalizedText:
    id: str
    text: str


def normalize_inputs(items: Sequence[str] | Sequence[Mapping[str, str]] | Mapping[str, str]) -> list[NormalizedText]:
    if isinstance(items, Mapping):
        return [NormalizedText(str(key), str(value)) for key, value in items.items()]

    normalized: list[NormalizedText] = []
    for idx, item in enumerate(items):
        if isinstance(item, str):
            normalized.append(NormalizedText(str(idx), item))
            continue
        if isinstance(item, Mapping):
            if "text" not in item:
                raise ValueError("Each mapping must include a 'text' field.")
            item_id = str(item.get("id", idx))
            normalized.append(NormalizedText(item_id, str(item["text"])))
            continue
        raise TypeError("Items must be strings or mappings with 'text'.")
    return normalized


def _normalize_vectors(vectors: np.ndarray) -> np.ndarray:
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    norms[norms == 0.0] = 1.0
    return vectors / norms


def embed_texts(texts: Sequence[str], embed_fn: Callable[[Sequence[str]], np.ndarray], *, normalize: bool) -> np.ndarray:
    vectors = np.asarray(embed_fn(texts), dtype=np.float32)
    if vectors.ndim != 2:
        raise ValueError("Embedding function must return a 2D array.")
    if normalize:
        vectors = _normalize_vectors(vectors)
    return vectors


class EmbeddingCache:
    def __init__(self, path: str) -> None:
        db_path = Path(path)
        db_path.parent.mkdir(parents=True, exist_ok=True)
        self._conn = sqlite3.connect(str(db_path))
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS embeddings (
                model TEXT NOT NULL,
                text TEXT NOT NULL,
                dim INTEGER NOT NULL,
                dtype TEXT NOT NULL,
                blob BLOB NOT NULL,
                PRIMARY KEY (model, text)
            )
            """
        )
        self._conn.commit()

    def get(self, model: str, text: str) -> np.ndarray | None:
        row = self._conn.execute(
            "SELECT dim, dtype, blob FROM embeddings WHERE model = ? AND text = ?",
            (model, text),
        ).fetchone()
        if row is None:
            return None
        dim, dtype, blob = row
        vector = np.frombuffer(blob, dtype=np.dtype(dtype))
        return vector.reshape((dim,))

    def set(self, model: str, text: str, vector: np.ndarray) -> None:
        arr = np.asarray(vector, dtype=np.float32)
        self._conn.execute(
            "INSERT OR REPLACE INTO embeddings (model, text, dim, dtype, blob) VALUES (?, ?, ?, ?, ?)",
            (model, text, arr.shape[0], str(arr.dtype), arr.tobytes()),
        )
        self._conn.commit()

    def close(self) -> None:
        self._conn.close()


def embed_with_cache(
    texts: Sequence[str],
    embed_fn: Callable[[Sequence[str]], np.ndarray],
    *,
    model_name: str,
    cache: EmbeddingCache | None,
    normalize: bool,
) -> np.ndarray:
    cached: list[np.ndarray | None] = []
    missing: list[str] = []
    missing_indices: list[int] = []

    for idx, text in enumerate(texts):
        if cache is None:
            cached.append(None)
            missing.append(text)
            missing_indices.append(idx)
            continue
        hit = cache.get(model_name, text)
        cached.append(hit)
        if hit is None:
            missing.append(text)
            missing_indices.append(idx)

    if missing:
        computed = embed_texts(missing, embed_fn, normalize=normalize)
        for offset, text in enumerate(missing):
            if cache is not None:
                cache.set(model_name, text, computed[offset])
            cached[missing_indices[offset]] = computed[offset]

    result = np.vstack([vec for vec in cached if vec is not None]).astype(np.float32)
    if result.shape[0] != len(texts):
        raise RuntimeError("Embedding cache produced an unexpected number of vectors.")
    return result


def default_embedder(model_name: str):
    try:
        from sentence_transformers import SentenceTransformer
    except Exception as exc:
        raise ImportError(
            "sentence-transformers is required to embed tags. Install it and retry."
        ) from exc

    model = SentenceTransformer(model_name)

    def _embed(texts: Sequence[str]) -> np.ndarray:
        vectors = model.encode(list(texts), normalize_embeddings=False)
        return np.asarray(vectors, dtype=np.float32)

    return _embed
