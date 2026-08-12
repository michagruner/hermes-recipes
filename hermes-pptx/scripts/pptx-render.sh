#!/usr/bin/env bash
# Convert a PPTX to per-slide JPEGs via LibreOffice + pdftoppm.
# Usage: pptx-render <deck.pptx> [out_dir]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: pptx-render <deck.pptx> [out_dir]" >&2
  exit 2
fi

DECK="$(readlink -f "$1")"
if [[ ! -f "$DECK" ]]; then
  echo "File not found: $1" >&2
  exit 1
fi

OUT_DIR="${2:-$(dirname "$DECK")/$(basename "$DECK" .pptx)-slides}"
mkdir -p "$OUT_DIR"
# clear previous renders in this dir
rm -f "$OUT_DIR"/slide-*.jpg "$OUT_DIR"/slide*.jpg 2>/dev/null || true

WORK="$(mktemp -d /tmp/pptx-render.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT

cp "$DECK" "$WORK/deck.pptx"
cd "$WORK"

# LibreOffice can be noisy; capture log on failure
if ! soffice --headless --nologo --nofirststartwizard --norestore \
      --convert-to pdf --outdir "$WORK" deck.pptx >"$WORK/lo.log" 2>&1; then
  echo "LibreOffice convert failed:" >&2
  cat "$WORK/lo.log" >&2
  exit 1
fi

if [[ ! -f "$WORK/deck.pdf" ]]; then
  echo "LibreOffice did not produce deck.pdf" >&2
  cat "$WORK/lo.log" 2>/dev/null || true
  ls -la "$WORK" >&2
  exit 1
fi

pdftoppm -jpeg -r 150 "$WORK/deck.pdf" "$WORK/raw"
idx=1
# shellcheck disable=SC2012
for f in $(ls -1 "$WORK"/raw*.jpg 2>/dev/null | sort -V); do
  dest=$(printf "%s/slide-%02d.jpg" "$OUT_DIR" "$idx")
  mv -f "$f" "$dest"
  idx=$((idx + 1))
done

count=$((idx - 1))
if [[ "$count" -lt 1 ]]; then
  echo "No JPEG slides produced" >&2
  exit 1
fi

echo "Rendered ${count} slides → $OUT_DIR"
ls -1 "$OUT_DIR"/slide-*.jpg
