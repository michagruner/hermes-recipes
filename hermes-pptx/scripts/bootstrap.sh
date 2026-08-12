#!/usr/bin/env bash
# OSS-only bootstrap: build image, start stack, smoke-test.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== hermes-pptx bootstrap (OSS) =="
echo "root: $ROOT"

if [[ ! -f .env ]]; then
  cp .env.example .env
  if command -v openssl >/dev/null 2>&1; then
    KEY="$(openssl rand -base64 32 | tr -d '\n' | tr '+/' '-_')"
    sed -i "s|^API_SERVER_KEY=.*|API_SERVER_KEY=${KEY}|" .env
  fi
  echo "Created .env — add DEEPSEEK_API_KEY and/or OPENROUTER_API_KEY"
fi

# Refuse Anthropic proprietary skill tree if present
if [[ -d data/skills/document/pptx ]]; then
  echo "Removing proprietary Anthropic pptx skill from data/skills/document/pptx"
  rm -rf data/skills/document/pptx
fi

if [[ ! -f data/skills/productivity/consulting-pptx/SKILL.md ]]; then
  echo "ERROR: consulting-pptx OSS skill missing" >&2
  exit 1
fi
if [[ ! -f data/skills/productivity/deck-master/SKILL.md ]]; then
  echo "ERROR: deck-master skill missing" >&2
  exit 1
fi

# Ensure OfficeCLI skill text exists (Apache-2.0 project)
if [[ ! -f data/skills/office/officecli/SKILL.md ]]; then
  mkdir -p data/skills/office/officecli
  curl -fsSL -o data/skills/office/officecli/SKILL.md "https://officecli.ai/SKILL.md" \
    || curl -fsSL -o data/skills/office/officecli/SKILL.md \
         "https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/SKILL.md"
fi

chmod +x scripts/*.sh 2>/dev/null || true
mkdir -p workspace/decks workspace/tmp data/cache projects

echo "== docker compose build =="
docker compose build

echo "== docker compose up =="
docker compose up -d hermes
sleep 10
docker compose ps

echo "== toolchain smoke =="
docker compose exec -T hermes bash -lc '
  set -e
  node -e "require(\"pptxgenjs\"); console.log(\"pptxgenjs ok\")"
  officecli --version
  soffice --version | head -1
  which pptx-render pptx-qa pptx-validate
  test -f /opt/data/skills/productivity/consulting-pptx/SKILL.md
  test ! -e /opt/data/skills/document/pptx/SKILL.md
  echo "OSS skill tree OK"
'

echo "== smoke deck =="
docker compose exec -T hermes bash -lc '
  set -e
  mkdir -p /workspace/tmp/smoke /workspace/decks
  cat >/workspace/tmp/smoke/build.js <<'"'"'EOF'"'"'
const PptxGenJS = require("pptxgenjs");
const pptx = new PptxGenJS();
pptx.defineLayout({ name: "WIDE", width: 13.333, height: 7.5 });
pptx.layout = "WIDE";
const s = pptx.addSlide();
s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 13.333, h: 7.5, fill: { color: "0B1220" } });
s.addText("Hermes PPTX OSS ready", {
  x: 0.8, y: 3.0, w: 11.5, h: 0.8,
  fontSize: 36, fontFace: "Arial", color: "F3F6FC", bold: true, margin: 0,
});
pptx.writeFile({ fileName: "/workspace/decks/smoke-oss.pptx" }).then(() => console.log("wrote"));
EOF
  node /workspace/tmp/smoke/build.js
  pptx-validate /workspace/decks/smoke-oss.pptx
  pptx-qa /workspace/decks/smoke-oss.pptx /workspace/tmp/smoke-oss-qa
  ls -la /workspace/decks/smoke-oss.pptx
'

echo "OK — OSS stack up. CLI: docker compose exec hermes hermes"
echo "Use: /decks  or  /consulting-pptx"
