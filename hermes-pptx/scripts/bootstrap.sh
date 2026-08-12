#!/usr/bin/env bash
# One-shot bootstrap: fetch deps, build image, start stack, smoke-test toolchain.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== hermes-pptx bootstrap =="
echo "root: $ROOT"

if [[ ! -f .env ]]; then
  cp .env.example .env
  # Generate a random API gateway key
  if command -v openssl >/dev/null 2>&1; then
    KEY="$(openssl rand -base64 32 | tr -d '\n' | tr '+/' '-_')"
    sed -i "s|^API_SERVER_KEY=.*|API_SERVER_KEY=${KEY}|" .env
  fi
  echo "Created .env — add DEEPSEEK_API_KEY and/or OPENROUTER_API_KEY before chatting."
fi

# Seed Hermes home env from root .env (provider keys)
mkdir -p data
if [[ ! -f data/.env ]]; then
  grep -E '^(OPENROUTER|DEEPSEEK|ANTHROPIC|OPENAI|GOOGLE|GEMINI|FIRECRAWL|API_SERVER)[A-Z0-9_]*=' .env \
    > data/.env || true
  chmod 600 data/.env 2>/dev/null || true
fi

chmod +x scripts/*.sh 2>/dev/null || true
./scripts/fetch-deps.sh

if [[ ! -f data/skills/document/pptx/SKILL.md ]]; then
  echo "ERROR: pptx skill missing after fetch-deps" >&2
  exit 1
fi
if [[ ! -f data/skills/productivity/deck-master/SKILL.md ]]; then
  echo "ERROR: deck-master skill missing" >&2
  exit 1
fi

mkdir -p workspace/decks workspace/tmp projects data/cache

echo "== docker compose build =="
docker compose build

echo "== docker compose up (Hermes only; UI optional) =="
docker compose up -d hermes

echo "== wait for container =="
sleep 10
docker compose ps

echo "== toolchain smoke (inside image) =="
docker compose exec -T hermes bash -lc '
  set -e
  echo "node $(node -v)"
  node -e "require(\"pptxgenjs\"); console.log(\"pptxgenjs ok\")"
  officecli --version
  soffice --version | head -1
  pdftoppm -v 2>&1 | head -1
  /opt/hermes/.venv/bin/python -c "import markitdown, pptx; print(\"python ok\")"
  test -f /opt/data/skills/document/pptx/SKILL.md
  test -f /opt/data/skills/productivity/deck-master/SKILL.md
  which pptx-render pptx-qa
'

echo "== generate smoke deck =="
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
s.addText("Hermes PPTX ready", {
  x: 0.8, y: 3.0, w: 11.5, h: 0.8,
  fontSize: 36, fontFace: "Arial", color: "F3F6FC", bold: true, margin: 0,
});
pptx.writeFile({ fileName: "/workspace/decks/smoke-test.pptx" }).then(() => console.log("wrote deck"));
EOF
  node /workspace/tmp/smoke/build.js
  pptx-qa /workspace/decks/smoke-test.pptx /workspace/tmp/smoke-qa
  ls -la /workspace/decks/smoke-test.pptx
  ls -la /workspace/tmp/smoke-qa/slides/ || true
'

echo ""
echo "OK — stack is up."
echo "  Hermes CLI:  docker compose exec hermes hermes"
echo "  Hermes API:  http://localhost:${HERMES_API_PORT:-8642}/v1"
echo "  Decks dir:   $ROOT/workspace/decks"
echo "  Optional UI: docker compose --profile ui up -d  → http://localhost:3080"
echo ""
echo "In chat, run:"
echo "  /decks Create a 6-slide investor pitch for a fictional AI startup."
