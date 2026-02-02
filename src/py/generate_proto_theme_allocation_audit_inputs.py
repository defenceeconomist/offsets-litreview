#!/usr/bin/env python3
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

import yaml


@dataclass(frozen=True)
class ThemeSummary:
    theme_id: str
    mechanism_count: int
    theme_label: str


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _load_yaml(path: Path):
    return yaml.safe_load(_read_text(path))


def _summarize_themes(proto: dict) -> list[ThemeSummary]:
    summaries: list[ThemeSummary] = []
    for theme in proto.get("proto_mechanism_themes", []) or []:
        theme_id = str(theme.get("theme_id", "")).strip()
        if not theme_id:
            continue
        label = str(theme.get("theme_label", "")).strip()
        mechanisms = theme.get("mechanisms") or []
        summaries.append(
            ThemeSummary(
                theme_id=theme_id,
                mechanism_count=len(mechanisms),
                theme_label=label,
            )
        )
    summaries.sort(key=lambda s: (-s.mechanism_count, s.theme_id))
    return summaries


def _build_run_markdown(
    prompt_text: str,
    target_theme_id: str,
    proto_themes_yml_text: str,
    proto_themes_changelog_yml_text: str,
) -> str:
    parts: list[str] = []
    parts.append(prompt_text.rstrip())
    parts.append("")
    parts.append("INPUTS")
    parts.append("")
    parts.append(f"1) target_theme_id\n{target_theme_id}")
    parts.append("")
    parts.append("2) proto_themes_yml")
    parts.append("```yaml")
    parts.append(proto_themes_yml_text.rstrip())
    parts.append("```")
    parts.append("")
    parts.append("3) proto_themes_changelog_yml")
    parts.append("```yaml")
    parts.append(proto_themes_changelog_yml_text.rstrip())
    parts.append("```")
    parts.append("")
    return "\n".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate per-theme run files for prompts/proto_theme_allocation_audit.md."
    )
    parser.add_argument(
        "--proto-themes",
        default="data/mechanism_themes/proto_themes.yml",
        help="Path to proto_themes.yml",
    )
    parser.add_argument(
        "--changelog",
        default="data/mechanism_themes/proto_themes_changelog.yml",
        help="Path to proto_themes_changelog.yml",
    )
    parser.add_argument(
        "--prompt",
        default="prompts/proto_theme_allocation_audit.md",
        help="Path to the prompt template markdown.",
    )
    parser.add_argument(
        "--outdir",
        default="data/mechanism_themes/audit_inputs",
        help="Directory to write per-theme run files into.",
    )
    parser.add_argument(
        "--min-mechanisms",
        type=int,
        default=11,
        help="Minimum mechanism count to include (default 11 => >10).",
    )
    parser.add_argument(
        "--index",
        default="data/mechanism_themes/audit_inputs/index.tsv",
        help="Write a TSV index of generated files here.",
    )
    args = parser.parse_args()

    proto_path = Path(args.proto_themes)
    changelog_path = Path(args.changelog)
    prompt_path = Path(args.prompt)
    outdir = Path(args.outdir)
    index_path = Path(args.index)

    proto = _load_yaml(proto_path)
    summaries = _summarize_themes(proto)
    selected = [s for s in summaries if s.mechanism_count >= args.min_mechanisms]

    outdir.mkdir(parents=True, exist_ok=True)

    prompt_text = _read_text(prompt_path)
    proto_text = _read_text(proto_path)
    changelog_text = _read_text(changelog_path)

    index_lines = ["theme_id\tmechanism_count\ttheme_label\toutput_path"]
    for s in selected:
        out_path = outdir / f"proto_theme_allocation_audit_{s.theme_id}.md"
        out_path.write_text(
            _build_run_markdown(
                prompt_text=prompt_text,
                target_theme_id=s.theme_id,
                proto_themes_yml_text=proto_text,
                proto_themes_changelog_yml_text=changelog_text,
            ),
            encoding="utf-8",
        )
        index_lines.append(
            f"{s.theme_id}\t{s.mechanism_count}\t{s.theme_label}\t{out_path.as_posix()}"
        )

    index_path.parent.mkdir(parents=True, exist_ok=True)
    index_path.write_text("\n".join(index_lines) + "\n", encoding="utf-8")

    print(f"Generated {len(selected)} run file(s) in: {outdir.as_posix()}")
    print(f"Index: {index_path.as_posix()}")
    for s in selected:
        print(f"- {s.theme_id} ({s.mechanism_count}) {s.theme_label}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

