#!/usr/bin/env python
import argparse
import sqlite3
from typing import Iterable, Tuple

import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Embed mechanism statements.")
    parser.add_argument(
        "--input",
        default="data/cmo_statements.csv",
        help="Path to cmo_statements.csv",
    )
    parser.add_argument(
        "--output",
        default="data/mechanism_embeddings.csv",
        help="Output CSV path for embeddings",
    )
    parser.add_argument(
        "--model",
        default="all-MiniLM-L6-v2",
        help="Sentence-Transformers model name",
    )
    parser.add_argument(
        "--cache",
        default="data/embeddings_cache.sqlite",
        help="SQLite cache for embeddings",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=32,
        help="Batch size for embedding",
    )
    parser.add_argument(
        "--device",
        default="cpu",
        help="Device to run embeddings on (e.g. cpu, cuda)",
    )
    parser.add_argument(
        "--normalize",
        action="store_true",
        help="Normalize embeddings to unit length",
    )
    return parser.parse_args()


def _ensure_cache_schema(conn: sqlite3.Connection) -> None:
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS embeddings (
            model TEXT NOT NULL,
            normalize INTEGER NOT NULL,
            text TEXT NOT NULL,
            dim INTEGER NOT NULL,
            dtype TEXT NOT NULL,
            embedding BLOB NOT NULL,
            PRIMARY KEY (model, normalize, text)
        )
        """
    )
    conn.execute(
        "CREATE INDEX IF NOT EXISTS idx_embeddings_model ON embeddings(model, normalize)"
    )
    conn.commit()


def _serialize_embedding(vec: np.ndarray) -> Tuple[bytes, int, str]:
    vec = np.asarray(vec, dtype=np.float32)
    return vec.tobytes(), vec.shape[0], str(vec.dtype)


def _deserialize_embedding(blob: bytes, dim: int, dtype: str) -> np.ndarray:
    return np.frombuffer(blob, dtype=np.dtype(dtype), count=dim)


def _load_cached(
    conn: sqlite3.Connection, model: str, normalize: bool
) -> dict:
    cur = conn.execute(
        "SELECT text, dim, dtype, embedding FROM embeddings WHERE model = ? AND normalize = ?",
        (model, 1 if normalize else 0),
    )
    cache = {}
    for text, dim, dtype, blob in cur.fetchall():
        cache[text] = _deserialize_embedding(blob, dim, dtype)
    return cache


def _save_cached(
    conn: sqlite3.Connection,
    model: str,
    normalize: bool,
    items: Iterable[Tuple[str, np.ndarray]],
) -> None:
    rows = []
    for text, vec in items:
        blob, dim, dtype = _serialize_embedding(vec)
        rows.append((model, 1 if normalize else 0, text, dim, dtype, blob))
    conn.executemany(
        "INSERT OR REPLACE INTO embeddings (model, normalize, text, dim, dtype, embedding) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        rows,
    )
    conn.commit()


def embed_texts(
    texts: list[str],
    model_name: str = "all-MiniLM-L6-v2",
    batch_size: int = 32,
    normalize: bool = False,
    device: str = "cpu",
    cache_path: str = "data/embeddings_cache.sqlite",
) -> np.ndarray:
    if not texts:
        return np.empty((0, 0), dtype=np.float32)

    conn = sqlite3.connect(cache_path)
    _ensure_cache_schema(conn)
    cache = _load_cached(conn, model_name, normalize)

    missing = [t for t in texts if t not in cache]
    if missing:
        model = SentenceTransformer(model_name, device=device)
        new_embeddings = model.encode(
            missing,
            batch_size=batch_size,
            normalize_embeddings=normalize,
            show_progress_bar=True,
        )
        _save_cached(conn, model_name, normalize, zip(missing, new_embeddings))
        for text, vec in zip(missing, new_embeddings):
            cache[text] = np.asarray(vec, dtype=np.float32)

    conn.close()
    return np.vstack([cache[t] for t in texts])


def embed_mechanisms(
    df: pd.DataFrame,
    text_col: str = "mechanism_statement",
    model_name: str = "all-MiniLM-L6-v2",
    batch_size: int = 32,
    normalize: bool = False,
    device: str = "cpu",
    cache_path: str = "data/embeddings_cache.sqlite",
) -> np.ndarray:
    texts = df[text_col].tolist()
    return embed_texts(
        texts=texts,
        model_name=model_name,
        batch_size=batch_size,
        normalize=normalize,
        device=device,
        cache_path=cache_path,
    )


def cosine_similarity_matrix(embeddings: np.ndarray) -> np.ndarray:
    if embeddings.size == 0:
        return np.empty((0, 0), dtype=np.float32)
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    normed = embeddings / norms
    return np.dot(normed, normed.T)


def main() -> None:
    args = parse_args()

    df = pd.read_csv(args.input)
    df = df[df["mechanism_statement"].notna()].copy()
    df["mechanism_statement"] = df["mechanism_statement"].str.strip()
    df = df[df["mechanism_statement"] != ""]

    embeddings = embed_mechanisms(
        df,
        model_name=args.model,
        batch_size=args.batch_size,
        normalize=args.normalize,
        device=args.device,
        cache_path=args.cache,
    )

    emb_cols = [f"emb_{i}" for i in range(embeddings.shape[1])]
    emb_df = pd.DataFrame(embeddings, columns=emb_cols)
    out = pd.concat(
        [df[["chunk_id", "file_id", "mechanism_statement"]].reset_index(drop=True), emb_df],
        axis=1,
    )
    out.to_csv(args.output, index=False)
    print(f"Wrote {args.output} with {len(out)} rows and {len(emb_cols)} dims")


if __name__ == "__main__":
    main()
