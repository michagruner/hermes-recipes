#!/usr/bin/env bash
# OSS-only deps. Does NOT download Anthropic proprietary skills.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== OSS hermes-pptx fetch-deps =="

if [[ -d data/skills/document/pptx ]]; then
  echo "Removing proprietary Anthropic pptx skill if present"
  rm -rf data/skills/document/pptx
fi

mkdir -p data/skills/office/officecli
if [[ ! -f data/skills/office/officecli/SKILL.md ]]; then
  curl -fsSL -o data/skills/office/officecli/SKILL.md "https://officecli.ai/SKILL.md" \
    || curl -fsSL -o data/skills/office/officecli/SKILL.md \
         "https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/SKILL.md"
fi

test -f data/skills/productivity/consulting-pptx/SKILL.md
test -f data/skills/productivity/deck-master/SKILL.md

mkdir -p workspace/decks workspace/tmp projects data/cache
echo "OK — OSS deps ready (no Anthropic skills)"
