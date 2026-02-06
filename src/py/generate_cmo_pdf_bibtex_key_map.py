#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

import yaml


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Generate a YAML map from PDFs referenced in data/cmo/*.yml to BibTeX keys "
            "in references/offsets.bib (matching by BibTeX 'file' field basename)."
        )
    )
    parser.add_argument(
        "--cmo-dir",
        type=Path,
        default=Path("data/cmo"),
        help="Directory containing CMO YAML files (default: data/cmo).",
    )
    parser.add_argument(
        "--bib",
        type=Path,
        default=Path("references/offsets.bib"),
        help="BibTeX file to read (default: references/offsets.bib).",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=Path("data/cmo/pdf_to_bibtex_key.yml"),
        help="Output YAML path (default: data/cmo/pdf_to_bibtex_key.yml).",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print info about skipped YAML files.",
    )
    return parser.parse_args()


def _load_cmo_pdf_filenames(cmo_dir: Path, *, verbose: bool) -> tuple[list[str], set[str]]:
    yaml_files = sorted(p for p in cmo_dir.glob("*.yml") if p.is_file())
    if not yaml_files:
        raise FileNotFoundError(f"No .yml files found under {cmo_dir}")

    cmo_files: list[Path] = []
    pdfs: set[str] = set()
    for cmo_path in yaml_files:
        data = yaml.safe_load(cmo_path.read_text())
        if not isinstance(data, dict):
            if verbose:
                print(f"Skipping non-mapping YAML: {cmo_path}", file=sys.stderr)
            continue

        keys = list(data.keys())
        is_cmo_yaml = bool(keys) and all(
            isinstance(key, str) and key.lower().endswith(".pdf") for key in keys
        )
        if not is_cmo_yaml:
            if verbose:
                print(f"Skipping non-CMO YAML: {cmo_path}", file=sys.stderr)
            continue

        cmo_files.append(cmo_path)
        pdfs.update(data.keys())

    if not cmo_files:
        raise FileNotFoundError(
            f"No CMO YAML files found under {cmo_dir} (expected top-level PDF keys)"
        )

    return [str(p.as_posix()) for p in cmo_files], pdfs


def _parse_bib_file_basename_to_key(bib_path: Path) -> dict[str, str]:
    header_re = re.compile(r"^@\w+\{([^,]+),")
    file_re = re.compile(r"\bfile\s*=\s*[{\\\"]([^}\\\"]+)[}\\\"]")

    basename_to_key: dict[str, str] = {}
    current_key: str | None = None

    for raw_line in bib_path.read_text().splitlines():
        line = raw_line.strip()
        header_match = header_re.match(line)
        if header_match:
            current_key = header_match.group(1).strip()
            continue

        file_match = file_re.search(line)
        if file_match and current_key:
            basename = os.path.basename(file_match.group(1).strip())
            previous = basename_to_key.get(basename)
            if previous and previous != current_key:
                raise ValueError(
                    f"BibTeX file basename collision for {basename!r}: "
                    f"{previous!r} vs {current_key!r}"
                )
            basename_to_key[basename] = current_key

    if not basename_to_key:
        raise ValueError(f"No BibTeX 'file' fields found in {bib_path}")

    return basename_to_key


def main() -> int:
    args = _parse_args()

    cmo_files, pdfs = _load_cmo_pdf_filenames(args.cmo_dir, verbose=args.verbose)
    basename_to_key = _parse_bib_file_basename_to_key(args.bib)

    missing = sorted(pdf for pdf in pdfs if pdf not in basename_to_key)
    if missing:
        print("Missing BibTeX entries for PDFs:", file=sys.stderr)
        for pdf in missing:
            print(f"- {pdf}", file=sys.stderr)
        return 2

    mapping = {pdf: basename_to_key[pdf] for pdf in sorted(pdfs)}
    out_obj = {
        "sources": {"cmo_files": cmo_files, "bibtex": str(args.bib.as_posix())},
        "pdf_to_bibtex_key": mapping,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(
        yaml.safe_dump(out_obj, sort_keys=False, allow_unicode=True),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
