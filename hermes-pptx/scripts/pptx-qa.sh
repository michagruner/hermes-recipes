#!/usr/bin/env bash
# Full QA helper: validate + render slide previews.
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

PY="${HERMES_PYTHON:-/opt/hermes/.venv/bin/python}"
if [[ ! -x "$PY" ]]; then
  PY="$(command -v python3 || command -v python)"
fi

echo "== validate (python) =="
VALIDATE_PY="/opt/data/skills/document/pptx/scripts/office/validate.py"
if [[ ! -f "$VALIDATE_PY" ]]; then
  VALIDATE_PY="/opt/hermes-pptx/skills/pptx/scripts/office/validate.py"
fi
if [[ -f "$VALIDATE_PY" ]]; then
  "$PY" "$VALIDATE_PY" "$DECK" || true
else
  echo "(validate.py not found — skip)"
fi

if command -v officecli >/dev/null 2>&1; then
  echo "== validate (officecli) =="
  officecli validate "$DECK" --json 2>/dev/null || officecli help validate 2>/dev/null | head -20 || true
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
