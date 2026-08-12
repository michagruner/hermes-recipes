#!/usr/bin/env bash
# OSS PPTX structural validation.
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Usage: pptx-validate <deck.pptx>" >&2
  exit 2
fi
DECK="$(readlink -f "$1")"
PY="${HERMES_PYTHON:-/opt/hermes/.venv/bin/python}"
SCRIPT="/opt/data/skills/productivity/consulting-pptx/scripts/validate_pptx.py"
if [[ ! -f "$SCRIPT" ]]; then
  SCRIPT="/opt/hermes-pptx/skills/consulting-pptx/scripts/validate_pptx.py"
fi
if [[ ! -f "$SCRIPT" ]]; then
  echo "validate_pptx.py not found" >&2
  exit 1
fi
exec "$PY" "$SCRIPT" "$DECK"
