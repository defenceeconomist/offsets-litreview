"""Generate a near-duplicate alias map for CMO tag labels."""

from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Dict, Iterable, Sequence

import yaml

try:
    from .tag_clustering import group_near_duplicates
    from .tag_embeddings import default_embedder
except ImportError:
    from tag_clustering import group_near_duplicates
    from tag_embeddings import default_embedder

TAG_FIELDS = ("context_tags", "mechanism_tags", "outcome_tags")
CMO_TAG_FIELDS = {"context_tags", "mechanism_tags", "outcome_tags"}


def _choose_canonical_tag(tags: Sequence[str], counts: Counter[str]) -> str:
    unique = sorted({tag for tag in tags if tag})
    if not unique:
        raise ValueError("Cannot select canonical tag from empty group")
    return sorted(unique, key=lambda tag: (-counts.get(tag, 0), tag))[0]


def _load_tags_from_cmo(cmo_dir: Path) -> Dict[str, Counter[str]]:
    counts: Dict[str, Counter[str]] = {kind: Counter() for kind in TAG_FIELDS}
    if not cmo_dir.exists():
        raise FileNotFoundError(f"CMO directory not found: {cmo_dir}")
    for path in sorted(cmo_dir.glob("*.yml")):
        if path.name in {"normalised_tags.yml", "normalized_tags.yml"}:
            continue
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        for document in data.values():
            cmos = document.get("cmos") or {}
            for cmo in cmos.values():
                for field in TAG_FIELDS:
                    for raw in cmo.get(field) or []:
                        tag = str(raw).strip()
                        if tag:
                            counts[field][tag] += 1
    return counts


def build_aliases(
    counts_by_field: Dict[str, Counter[str]],
    *,
    embed_fn,
    model_name: str,
    threshold: float,
    cache_path: str | None,
) -> Dict[str, Dict[str, str]]:
    alias_sections: Dict[str, Dict[str, str]] = {}
    for field in TAG_FIELDS:
        tags = sorted(counts_by_field.get(field, Counter()).keys())
        if len(tags) < 2:
            alias_sections[field] = {}
            continue
        dupes = group_near_duplicates(
            tags, embed_fn=embed_fn, model_name=model_name, threshold=threshold, cache_path=cache_path
        )
        aliases: Dict[str, str] = {}
        for group in dupes:
            canonical = _choose_canonical_tag(group.texts, counts_by_field[field])
            for tag in sorted(set(group.texts)):
                if tag != canonical:
                    aliases[tag] = canonical
        alias_sections[field] = aliases
    return alias_sections


def write_aliases(path: Path, alias_sections: Dict[str, Dict[str, str]]) -> None:
    payload = {"aliases": alias_sections}
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(yaml.safe_dump(payload, sort_keys=False), encoding="utf-8")


def run_normalise_tags(
    *,
    cmo_dir: str = "cmo",
    output: str = "normalised_tags.yml",
    model: str = "all-MiniLM-L6-v2",
    threshold: float = 0.9,
    cache_path: str | None = ".cache/tag_embeddings.sqlite",
) -> None:
    embed_fn = default_embedder(model)
    counts_by_field = _load_tags_from_cmo(Path(cmo_dir))
    alias_sections = build_aliases(
        counts_by_field,
        embed_fn=embed_fn,
        model_name=model,
        threshold=threshold,
        cache_path=cache_path,
    )
    write_aliases(Path(output), alias_sections)
    total_aliases = sum(len(section) for section in alias_sections.values())
    print(f"wrote {total_aliases} aliases to {output}")


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser("Generate near-duplicate tag aliases from CMO data.")
    parser.add_argument("--cmo-dir", default="cmo", help="Directory containing CMO YAML files")
    parser.add_argument("--output", default="normalised_tags.yml", help="Path to write the alias map")
    parser.add_argument("--model", default="all-MiniLM-L6-v2", help="Sentence-transformers model name")
    parser.add_argument("--threshold", type=float, default=0.9, help="Cosine similarity threshold")
    parser.add_argument("--cache-path", default=".cache/tag_embeddings.sqlite", help="Embedding cache path")
    args = parser.parse_args()

    run_normalise_tags(
        cmo_dir=args.cmo_dir,
        output=args.output,
        model=args.model,
        threshold=args.threshold,
        cache_path=args.cache_path,
    )


if __name__ == "__main__":
    main()
