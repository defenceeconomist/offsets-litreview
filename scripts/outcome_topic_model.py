"""Train a BERTopic model on CMO outcome fields."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Iterable

import yaml


def _iter_outcomes(data: dict[str, Any], source: str) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []
    for doc_id, payload in data.items():
        if not isinstance(payload, dict):
            continue
        cmos = payload.get("cmos", {})
        if not isinstance(cmos, dict):
            continue
        for cmo_id, cmo in cmos.items():
            if not isinstance(cmo, dict):
                continue
            outcome = cmo.get("outcome")
            if outcome is None:
                continue
            outcome_text = str(outcome).strip()
            if not outcome_text:
                continue
            records.append(
                {
                    "source_file": source,
                    "doc_id": str(doc_id),
                    "cmo_id": str(cmo_id),
                    "outcome": outcome_text,
                }
            )
    return records


def load_outcomes(paths: Iterable[Path]) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []
    for path in paths:
        with path.open("r", encoding="utf-8") as handle:
            data = yaml.safe_load(handle) or {}
        if not isinstance(data, dict):
            continue
        records.extend(_iter_outcomes(data, source=str(path)))
    return records


def _build_topic_model(min_topic_size: int, embedding_model: str | None, verbose: bool):
    try:
        from bertopic import BERTopic
    except Exception as exc:
        raise ImportError(
            "bertopic is required. Install dependencies from requirements.txt."
        ) from exc

    embedder = None
    if embedding_model:
        try:
            from sentence_transformers import SentenceTransformer
        except Exception as exc:
            raise ImportError(
                "sentence-transformers is required when using --embedding-model."
            ) from exc
        embedder = SentenceTransformer(embedding_model)

    return BERTopic(
        embedding_model=embedder,
        min_topic_size=min_topic_size,
        verbose=verbose,
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Train a BERTopic model on CMO outcome fields.",
    )
    parser.add_argument(
        "--inputs",
        nargs="+",
        default=[
            "cmo/arms_trade_offsets_chapters.yml",
            "cmo/articles.yml",
        ],
        help="YAML files containing CMOs.",
    )
    parser.add_argument(
        "--output-dir",
        default="analysis/outcome_topics",
        help="Directory for topic outputs.",
    )
    parser.add_argument(
        "--min-topic-size",
        type=int,
        default=3,
        help="Minimum topic size for BERTopic.",
    )
    parser.add_argument(
        "--embedding-model",
        default=None,
        help="Optional sentence-transformers model name.",
    )
    parser.add_argument(
        "--save-model",
        default=None,
        help="Optional path to save the trained BERTopic model.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable BERTopic verbose logging.",
    )
    args = parser.parse_args()

    input_paths = [Path(path) for path in args.inputs]
    records = load_outcomes(input_paths)
    if not records:
        raise SystemExit("No outcome fields found in the provided inputs.")

    outcomes = [record["outcome"] for record in records]
    topic_model = _build_topic_model(
        min_topic_size=args.min_topic_size,
        embedding_model=args.embedding_model,
        verbose=args.verbose,
    )
    topics, probs = topic_model.fit_transform(outcomes)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    topic_info = topic_model.get_topic_info()
    doc_info = topic_model.get_document_info(outcomes)
    doc_info["source_file"] = [record["source_file"] for record in records]
    doc_info["doc_id"] = [record["doc_id"] for record in records]
    doc_info["cmo_id"] = [record["cmo_id"] for record in records]
    doc_info["outcome"] = outcomes

    topic_info_path = output_dir / "topic_info.csv"
    doc_info_path = output_dir / "document_info.csv"
    topic_info.to_csv(topic_info_path, index=False)
    doc_info.to_csv(doc_info_path, index=False)

    topic_terms = {
        str(topic_id): topic_model.get_topic(topic_id) for topic_id in topic_info["Topic"]
    }
    topics_path = output_dir / "topic_terms.json"
    with topics_path.open("w", encoding="utf-8") as handle:
        json.dump(topic_terms, handle, indent=2, ensure_ascii=True)

    if args.save_model:
        topic_model.save(args.save_model)

    print(f"Loaded {len(outcomes)} outcome statements.")
    print(f"Wrote {topic_info_path} and {doc_info_path}.")
    print(f"Wrote {topics_path}.")
    print("Top topics:")
    for _, row in topic_info.iterrows():
        topic_id = row["Topic"]
        count = row["Count"]
        label = row.get("Name", "")
        words = topic_model.get_topic(topic_id) or []
        top_words = ", ".join(term for term, _ in words[:5])
        print(f"- Topic {topic_id} ({count}): {label} :: {top_words}")


if __name__ == "__main__":
    main()
