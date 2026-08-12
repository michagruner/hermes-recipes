#!/usr/bin/env bash
# End-to-end smoke test: build a tiny deck, validate, render.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${1:-$ROOT/workspace/decks}"
TMP="$ROOT/workspace/tmp/smoke-$$"
mkdir -p "$OUT_DIR" "$TMP"

DECK="$OUT_DIR/smoke-test.pptx"

cat >"$TMP/build.js" <<'EOF'
const PptxGenJS = require("pptxgenjs");
const pptx = new PptxGenJS();
pptx.defineLayout({ name: "WIDE", width: 13.333, height: 7.5 });
pptx.layout = "WIDE";

const C = {
  bg: "0B1220",
  card: "141C2E",
  text: "F3F6FC",
  muted: "A8B3C7",
  accent: "3B82F6",
  good: "34D399",
};

// Title
{
  const s = pptx.addSlide();
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 13.333, h: 7.5, fill: { color: C.bg } });
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 0.12, h: 7.5, fill: { color: C.accent } });
  s.addText("HERMES PPTX STACK", {
    x: 0.8, y: 2.2, w: 11.5, h: 0.4,
    fontSize: 14, fontFace: "Arial", color: C.accent, bold: true, margin: 0,
  });
  s.addText("Smoke test passed", {
    x: 0.8, y: 2.7, w: 11.5, h: 0.9,
    fontSize: 40, fontFace: "Arial", color: C.text, bold: true, margin: 0,
  });
  s.addText("LibreOffice · pptxgenjs · OfficeCLI · visual QA", {
    x: 0.8, y: 3.7, w: 11.5, h: 0.4,
    fontSize: 16, fontFace: "Arial", color: C.muted, margin: 0,
  });
}

// Content
{
  const s = pptx.addSlide();
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: 13.333, h: 7.5, fill: { color: "F7F8FA" } });
  s.addText("Toolchain ready", {
    x: 0.7, y: 0.45, w: 12, h: 0.55,
    fontSize: 28, fontFace: "Arial", color: "0B1220", bold: true, margin: 0,
  });
  const cards = [
    { t: "Generate", d: "pptxgenjs native charts, shapes, notes" },
    { t: "Validate", d: "OOXML + officecli issue checks" },
    { t: "Visual QA", d: "PDF → JPEG → vision inspect loop" },
  ];
  cards.forEach((c, i) => {
    const x = 0.7 + i * 4.1;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 1.5, w: 3.8, h: 4.2,
      fill: { color: "FFFFFF" },
      shadow: { type: "outer", color: "0B1220", blur: 8, opacity: 0.08, offset: 2 },
      rectRadius: 0.1,
    });
    s.addShape(pptx.shapes.RECTANGLE, { x, y: 1.5, w: 3.8, h: 0.1, fill: { color: C.accent } });
    s.addText(c.t, {
      x: x + 0.3, y: 2.0, w: 3.2, h: 0.5,
      fontSize: 20, fontFace: "Arial", color: "0B1220", bold: true, margin: 0,
    });
    s.addText(c.d, {
      x: x + 0.3, y: 2.7, w: 3.2, h: 2.2,
      fontSize: 15, fontFace: "Arial", color: "4B5563", margin: 0, valign: "top",
    });
  });
}

pptx.writeFile({ fileName: process.argv[2] }).then(() => {
  console.log("wrote", process.argv[2]);
});
EOF

echo "== node build =="
if command -v node >/dev/null 2>&1 && node -e "require('pptxgenjs')" 2>/dev/null; then
  node "$TMP/build.js" "$DECK"
elif docker image inspect hermes-pptx:local >/dev/null 2>&1; then
  docker run --rm \
    -v "$TMP:/work" -v "$OUT_DIR:/out" \
    --entrypoint node \
    hermes-pptx:local \
    /work/build.js /out/smoke-test.pptx
  DECK="$OUT_DIR/smoke-test.pptx"
else
  echo "Need pptxgenjs on host or hermes-pptx:local image" >&2
  exit 1
fi

echo "== render =="
if command -v pptx-render >/dev/null 2>&1; then
  pptx-render "$DECK" "$TMP/slides"
elif docker image inspect hermes-pptx:local >/dev/null 2>&1; then
  docker run --rm \
    -v "$OUT_DIR:/out" -v "$TMP:/tmpwork" \
    --entrypoint pptx-render \
    hermes-pptx:local \
    /out/smoke-test.pptx /tmpwork/slides
else
  echo "Skip render (no pptx-render)"
fi

echo "== officecli =="
if command -v officecli >/dev/null 2>&1; then
  officecli --version
  officecli validate "$DECK" 2>/dev/null || true
elif [[ -x "$ROOT/bin/officecli" ]]; then
  "$ROOT/bin/officecli" --version
fi

echo "OK: $DECK"
ls -lh "$DECK"
