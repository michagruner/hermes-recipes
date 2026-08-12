#!/usr/bin/env bash
# Full QA helper: validate + render slide previews (OSS).
# Usage: pptx-qa <deck.pptx> [work_dir]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: pptx-qa <deck.pptx> [work_dir]" >&2
  exit 2
fi

DECK="$(readlink -f "$1")"
WORK_ROOT="${2:-$(dirname "$DECK")/$(basename "$DECK" .pptx)-qa}"
SLIDES="$WORK_ROOT/slides"
mkdir -p "$SLIDES"

echo "== validate =="
if command -v pptx-validate >/dev/null 2>&1; then
  pptx-validate "$DECK" || true
else
  PY="${HERMES_PYTHON:-/opt/hermes/.venv/bin/python}"
  SCRIPT="/opt/data/skills/productivity/consulting-pptx/scripts/validate_pptx.py"
  [[ -f "$SCRIPT" ]] && "$PY" "$SCRIPT" "$DECK" || true
fi

if command -v officecli >/dev/null 2>&1; then
  echo "== validate (officecli) =="
  officecli validate "$DECK" --json 2>/dev/null || true
fi

echo "== content extract =="
if [[ -x /opt/hermes/.venv/bin/markitdown ]]; then
  /opt/hermes/.venv/bin/markitdown "$DECK" | head -n 80 || true
elif command -v markitdown >/dev/null 2>&1; then
  markitdown "$DECK" | head -n 80 || true
fi

echo "== render slides =="
pptx-render "$DECK" "$SLIDES"

echo "== QA artifacts =="
echo "DECK=$DECK"
echo "SLIDES=$SLIDES"
ls -la "$SLIDES"
