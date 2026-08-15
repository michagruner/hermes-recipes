# pptxgenjs cheatsheet (OSS)

```bash
node -e "require('pptxgenjs')"
# NODE_PATH=/opt/pptx-tools/node_modules on this image
```

## Skeleton

```js
const PptxGenJS = require("pptxgenjs");
const pptx = new PptxGenJS();
pptx.defineLayout({ name: "WIDE", width: 13.333, height: 7.5 });
pptx.layout = "WIDE";

const C = {
  ink: "0B1220",
  paper: "F8FAFC",
  white: "FFFFFF",
  muted: "64748B",
  accent: "2563EB",
  good: "059669",
};

const s = pptx.addSlide();
s.addShape(pptx.shapes.RECTANGLE, {
  x: 0, y: 0, w: 13.333, h: 7.5,
  fill: { color: C.paper },
});
s.addText("Action title goes here", {
  x: 0.6, y: 0.4, w: 12.1, h: 0.55,
  fontSize: 26, fontFace: "Arial", color: C.ink, bold: true, margin: 0,
});

await pptx.writeFile({ fileName: "/workspace/decks/out.pptx" });
```

## Chart

```js
// pptxgenjs 3.12 LEGACY signature. The v4 {categories, series} object crashes.
  s.addChart(pptx.charts.BAR, [
    { name: "On-prem", labels: ["Q1", "Q2", "Q3", "Q4"], values: [12, 18, 27, 41] },
    { name: "Hyperscaler", labels: ["Q1", "Q2", "Q3", "Q4"], values: [40, 38, 33, 28] },
  ], {
    x: 0.6, y: 1.3, w: 7.5, h: 5.2,
    barGrouping: "clustered",
    showTitle: false,
    showLegend: true,
    legendPos: "b",
    chartColors: ["2563EB", "64748B"],
  });
```

## Table

```js
s.addTable(
  [
    [
      { text: "Option", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
      { text: "Control", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
      { text: "Speed", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
    ],
    ["Local open-weight", "High", "Medium"],
    ["Hyperscaler API", "Low", "High"],
  ],
  {
    x: 0.6, y: 1.5, w: 12.1, h: 3.5,
    colW: [4.5, 3.8, 3.8],
    border: [{ pt: 0.5, color: "CBD5E1" }],
    fontFace: "Arial",
    fontSize: 14,
    color: "0B1220",
  }
);
```

## Phase-gate grid (project plan)

```js
s.addTable(
  [
    [
      { text: "Workstream", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
      { text: "Phase 0 — prove", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
      { text: "Phase 1 — first node", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
      { text: "Phase 2 — gated", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF" } },
    ],
    [
      { text: "Gateway", options: { bold: true } },
      { text: "LiteLLM live\nExit: SSO + quotas", options: { fontSize: 11, color: "334155" } },
      { text: "On-prem alias\nExit: overflow 429", options: { fontSize: 11, color: "334155" } },
      { text: "P/D split TBD", options: { fontSize: 11, color: "64748B" } },
    ],
  ],
  {
    x: 0.5, y: 1.25, w: 12.3, h: 4.8,
    colW: [2.1, 3.4, 3.4, 3.4],
    border: [{ pt: 0.5, color: "CBD5E1" }],
    fontFace: "Arial",
    fontSize: 12,
    color: "0B1220",
    valign: "top",
  }
);
s.addText("Kill criteria: utilization <40% · bake-off loss · legal no-go", {
  x: 0.5, y: 6.85, w: 12.3, h: 0.28,
  fontSize: 11, color: "64748B", fontFace: "Arial", margin: 0,
});
```

## Card row

```js
const cards = [
  { t: "Independence", d: "No single-vendor kill switch" },
  { t: "Residency", d: "Data stays in our DC" },
  { t: "Cost path", d: "Predictable GPU unit economics" },
];
cards.forEach((c, i) => {
  const x = 0.6 + i * 4.2;
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x, y: 1.6, w: 3.9, h: 4.5,
    fill: { color: "FFFFFF" },
    shadow: { type: "outer", color: "0B1220", blur: 10, opacity: 0.08, offset: 2 },
    rectRadius: 0.08,
  });
  s.addText(c.t, {
    x: x + 0.3, y: 2.0, w: 3.3, h: 0.5,
    fontSize: 18, bold: true, color: "0B1220", fontFace: "Arial", margin: 0,
  });
  s.addText(c.d, {
    x: x + 0.3, y: 2.7, w: 3.3, h: 2.5,
    fontSize: 15, color: "475569", fontFace: "Arial", margin: 0, valign: "top",
  });
});
```
