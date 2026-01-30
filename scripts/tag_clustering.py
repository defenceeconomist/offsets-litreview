"""Clustering utilities for mechanism tags or other short texts."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Sequence, Tuple

import numpy as np

from tag_embeddings import (
    EmbeddingCache,
    NormalizedItem,
    embed_with_cache,
    normalize_inputs,
)


@dataclass
class DuplicateGroup:
    """Group of near-duplicate items."""

    indices: List[int]
    ids: List[str]
    texts: List[str]

    @property
    def representative(self) -> str:
        return self.texts[0]


def _union_find(n: int):
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(a: int, b: int) -> None:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[rb] = ra

    return find, union


def group_near_duplicates(
    items: Sequence[str] | Sequence[dict] | Dict[str, str],
    *,
    embed_fn,
    model_name: str,
    threshold: float = 0.9,
    cache_path: str | None = ".cache/tag_embeddings.sqlite",
) -> List[DuplicateGroup]:
    """Identify and group near-duplicate tags using cosine similarity.

    Returns only groups with size > 1, ordered by size desc.
    """

    normalized = normalize_inputs(items)
    texts = [it.text for it in normalized]
    cache = EmbeddingCache(cache_path) if cache_path else None
    vecs = embed_with_cache(texts, embed_fn, model_name=model_name, cache=cache, normalize=True)
    if cache:
        cache.close()

    n = vecs.shape[0]
    if n == 0:
        return []

    # Cosine similarity via dot-product on normalized vectors.
    sim = vecs @ vecs.T
    find, union = _union_find(n)

    for i in range(n):
        for j in range(i + 1, n):
            if sim[i, j] >= threshold:
                union(i, j)

    groups: Dict[int, List[int]] = {}
    for i in range(n):
        root = find(i)
        groups.setdefault(root, []).append(i)

    dup_groups: List[DuplicateGroup] = []
    for idxs in groups.values():
        if len(idxs) < 2:
            continue
        ids = [normalized[i].id for i in idxs]
        texts = [normalized[i].text for i in idxs]
        dup_groups.append(DuplicateGroup(indices=idxs, ids=ids, texts=texts))

    dup_groups.sort(key=lambda g: len(g.indices), reverse=True)
    return dup_groups


@dataclass
class HierarchyResult:
    linkage_matrix: np.ndarray
    dendrogram: dict
    order: List[int]
    labels: List[str]


def build_tag_hierarchy(
    items: Sequence[str] | Sequence[dict] | Dict[str, str],
    *,
    embed_fn,
    model_name: str,
    method: str = "average",
    metric: str = "cosine",
    cache_path: str | None = ".cache/tag_embeddings.sqlite",
) -> HierarchyResult:
    """Create a hierarchical clustering dendrogram for tags."""

    try:
        from scipy.cluster.hierarchy import dendrogram, linkage
        from scipy.spatial.distance import pdist
    except Exception as exc:  # pragma: no cover - import guard
        raise RuntimeError("scipy is required for hierarchical clustering") from exc

    normalized = normalize_inputs(items)
    texts = [it.text for it in normalized]
    labels = [it.id for it in normalized]

    cache = EmbeddingCache(cache_path) if cache_path else None
    vecs = embed_with_cache(texts, embed_fn, model_name=model_name, cache=cache, normalize=True)
    if cache:
        cache.close()

    dist = pdist(vecs, metric=metric)
    linkage_matrix = linkage(dist, method=method)
    dendro = dendrogram(linkage_matrix, labels=labels, no_plot=True)

    return HierarchyResult(
        linkage_matrix=linkage_matrix,
        dendrogram=dendro,
        order=list(dendro["leaves"]),
        labels=labels,
    )


if __name__ == "__main__":
    import argparse
    import csv
    import json
    from pathlib import Path

    from tag_embeddings import default_embedder

    def load_items(path: str) -> List[str]:
        p = Path(path)
        if p.suffix == ".json":
            with p.open("r", encoding="utf-8") as f:
                data = json.load(f)
            if isinstance(data, list):
                return [str(x) for x in data]
            if isinstance(data, dict):
                return [str(v) for v in data.values()]
            raise ValueError("Unsupported JSON structure")
        if p.suffix in {".csv", ".tsv"}:
            delim = "," if p.suffix == ".csv" else "\t"
            with p.open("r", encoding="utf-8") as f:
                reader = csv.reader(f, delimiter=delim)
                rows = list(reader)
            return [r[0] for r in rows if r]
        return [line.strip() for line in p.read_text(encoding="utf-8").splitlines() if line.strip()]

    parser = argparse.ArgumentParser(description="Embed and cluster mechanism tags.")
    parser.add_argument("--input", required=True, help="Path to txt/csv/json of tags (one per line or list)")
    parser.add_argument("--model", default="all-MiniLM-L6-v2")
    parser.add_argument("--threshold", type=float, default=0.9)
    parser.add_argument("--hierarchy", action="store_true")
    args = parser.parse_args()

    tags = load_items(args.input)
    embed_fn = default_embedder(args.model)

    dupes = group_near_duplicates(
        tags, embed_fn=embed_fn, model_name=args.model, threshold=args.threshold
    )

    print("Near-duplicate groups:")
    for group in dupes:
        print("-", " | ".join(group.texts))

    if args.hierarchy:
        result = build_tag_hierarchy(tags, embed_fn=embed_fn, model_name=args.model)
        print("\nDendrogram order (indices):", result.order)
