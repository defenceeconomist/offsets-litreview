"""Utilities for clustering and de-duplicating tag labels."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence

import numpy as np

try:
    from .tag_embeddings import EmbeddingCache, embed_with_cache
except ImportError:
    from tag_embeddings import EmbeddingCache, embed_with_cache


@dataclass(frozen=True)
class DuplicateGroup:
    texts: list[str]


@dataclass(frozen=True)
class TagHierarchy:
    labels: list[str]
    order: list[int]
    linkage: np.ndarray | None = None


def _cosine_similarity(vectors: np.ndarray) -> np.ndarray:
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    norms[norms == 0.0] = 1.0
    normalized = vectors / norms
    return normalized @ normalized.T


def _open_cache(cache_path: str | None) -> EmbeddingCache | None:
    if cache_path is None:
        return None
    return EmbeddingCache(cache_path)


def group_near_duplicates(
    texts: Sequence[str],
    *,
    embed_fn: Callable[[Sequence[str]], np.ndarray],
    model_name: str,
    threshold: float,
    cache_path: str | None,
) -> list[DuplicateGroup]:
    if len(texts) < 2:
        return []
    cache = _open_cache(cache_path)
    try:
        vectors = embed_with_cache(
            texts,
            embed_fn,
            model_name=model_name,
            cache=cache,
            normalize=True,
        )
    finally:
        if cache is not None:
            cache.close()

    sims = _cosine_similarity(vectors)
    parent = list(range(len(texts)))

    def find(i: int) -> int:
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    def union(i: int, j: int) -> None:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[rj] = ri

    for i in range(len(texts)):
        for j in range(i + 1, len(texts)):
            if sims[i, j] >= threshold:
                union(i, j)

    groups: dict[int, list[int]] = {}
    for idx in range(len(texts)):
        root = find(idx)
        groups.setdefault(root, []).append(idx)

    results: list[DuplicateGroup] = []
    for indices in groups.values():
        if len(indices) < 2:
            continue
        ordered = [texts[i] for i in indices]
        results.append(DuplicateGroup(texts=ordered))

    results.sort(key=lambda group: texts.index(group.texts[0]))
    return results


def build_tag_hierarchy(
    texts: Sequence[str],
    *,
    embed_fn: Callable[[Sequence[str]], np.ndarray],
    model_name: str,
    cache_path: str | None,
) -> TagHierarchy:
    if not texts:
        return TagHierarchy(labels=[], order=[], linkage=None)

    cache = _open_cache(cache_path)
    try:
        vectors = embed_with_cache(
            texts,
            embed_fn,
            model_name=model_name,
            cache=cache,
            normalize=True,
        )
    finally:
        if cache is not None:
            cache.close()

    try:
        from scipy.cluster.hierarchy import linkage, leaves_list
        from scipy.spatial.distance import pdist
    except Exception as exc:
        raise RuntimeError("scipy is required to build tag hierarchies.") from exc

    distances = pdist(vectors, metric="cosine")
    linkage_matrix = linkage(distances, method="average")
    order = leaves_list(linkage_matrix).tolist()
    return TagHierarchy(labels=list(texts), order=order, linkage=linkage_matrix)
