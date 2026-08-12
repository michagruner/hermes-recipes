#!/usr/bin/env python3
"""Lightweight OSS PPTX validation (MIT). No proprietary dependencies."""
from __future__ import annotations

import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

REQUIRED = [
    "[Content_Types].xml",
    "ppt/presentation.xml",
    "_rels/.rels",
]


def main(path: str) -> int:
    p = Path(path)
    errors: list[str] = []
    warnings: list[str] = []

    if not p.is_file():
        print(f"ERROR: file not found: {p}", file=sys.stderr)
        return 2

    if p.suffix.lower() != ".pptx":
        warnings.append(f"unusual extension: {p.suffix}")

    try:
        zf = zipfile.ZipFile(p)
    except zipfile.BadZipFile:
        print("ERROR: not a valid ZIP/PPTX", file=sys.stderr)
        return 1

    names = set(zf.namelist())
    for req in REQUIRED:
        if req not in names:
            errors.append(f"missing required part: {req}")

    # Parse content types
    try:
        ct = ET.fromstring(zf.read("[Content_Types].xml"))
    except Exception as exc:  # noqa: BLE001
        errors.append(f"Content_Types parse failed: {exc}")
        ct = None

    # Count slides
    slides = sorted(
        n for n in names if n.startswith("ppt/slides/slide") and n.endswith(".xml")
    )
    if not slides:
        errors.append("no slides found under ppt/slides/")
    else:
        print(f"slides: {len(slides)}")

    # Basic XML well-formedness for slides + presentation
    for part in ["ppt/presentation.xml", *slides[:50]]:
        if part not in names:
            continue
        try:
            ET.fromstring(zf.read(part))
        except Exception as exc:  # noqa: BLE001
            errors.append(f"XML error in {part}: {exc}")

    # Optional python-pptx open
    try:
        from pptx import Presentation  # type: ignore

        prs = Presentation(str(p))
        print(f"python-pptx slides: {len(prs.slides)}")
        print(f"slide_width={prs.slide_width} slide_height={prs.slide_height}")
    except ImportError:
        warnings.append("python-pptx not installed — skipped deep open")
    except Exception as exc:  # noqa: BLE001
        errors.append(f"python-pptx open failed: {exc}")

    zf.close()

    for w in warnings:
        print(f"WARNING: {w}")
    if errors:
        for e in errors:
            print(f"ERROR: {e}")
        print("FAILED")
        return 1

    print("All validations PASSED!")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file.pptx>", file=sys.stderr)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
