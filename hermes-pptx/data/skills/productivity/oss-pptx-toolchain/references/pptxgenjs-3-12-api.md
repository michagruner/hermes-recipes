# pptxgenjs 3.12.0 — verified API snippets (this host)

All snippets below were executed successfully against pptxgenjs 3.12.0
(`/opt/pptx-tools/node_modules`) during a production deck build.

## Rule that matters most

`s.addChart(type, data, options)` — `data` is an ARRAY of `{ name, labels, values }`.
The v4 `categories`/`series` object form throws:
`TypeError: tmpData.forEach is not a function`
Do NOT copy v4 examples from the web or from the consulting-pptx cheatsheet into this host.

## LINE chart (verified)

```js
s.addChart(pptx.charts.LINE, [
  { name: "Closed frontier models (API)", labels: ["2022", "2023", "2024", "2025", "2026"], values: [58, 70, 80, 87, 91] },
  { name: "Open-weight models (self-hosted)", labels: ["2022", "2023", "2024", "2025", "2026"], values: [40, 52, 66, 82, 89] },
], {
  x: 0.6, y: 2.15, w: 7.3, h: 4.4,
  showTitle: false,
  showLegend: true, legendPos: "b", legendFontSize: 11, legendColor: "0B1220",
  chartColors: ["64748B", "2563EB"],
  lineSize: 2.5, lineDataSymbol: "circle",
  catAxisLabelFontSize: 11, valAxisLabelFontSize: 10,
  valAxisMinVal: 0, valAxisMaxVal: 100,
});
```

Notes:
- All series must share the same `labels` array length/values.
- `lineDataSymbol: "circle"` renders visible data-point markers (verified).
- Keep series count low (2) for conference legibility; legend at bottom.

## BAR chart (same data shape)

```js
s.addChart(pptx.charts.BAR, [
  { name: "On-prem", labels: ["Q1", "Q2", "Q3", "Q4"], values: [12, 18, 27, 41] },
  { name: "Hyperscaler", labels: ["Q1", "Q2", "Q3", "Q4"], values: [40, 38, 33, 28] },
], {
  x: 0.6, y: 1.3, w: 7.5, h: 5.2,
  barGrouping: "clustered",
  showTitle: false,
  showLegend: true, legendPos: "b", legendFontSize: 11, legendColor: "0B1220",
  chartColors: ["2563EB", "64748B"],
  catAxisLabelFontSize: 11, valAxisLabelFontSize: 10,
});
```

## Table (verified — used for trade-off comparison slide)

```js
s.addTable(
  [
    [
      { text: "Dimension", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF", fontSize: 12.5 } },
      { text: "Cloud API", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF", fontSize: 12.5 } },
      { text: "Local open-weight", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF", fontSize: 12.5 } },
      { text: "How we manage it", options: { bold: true, fill: { color: "0B1220" }, color: "FFFFFF", fontSize: 12.5 } },
    ],
    ["Capability", "Latest frontier model, zero ops", "~6–12 months behind — and closing", "Select models per use case; fine-tune for our domain"],
    ["Cost profile", "Predictable per token; scales with usage", "Upfront hardware; low marginal cost", "Plan GPU capacity; pilot before scaling"],
    ["Operations", "Fully outsourced", "New skills: MLOps, GPU ops, security", "Build a small platform team; partner for ramp-up"],
    ["Updates & governance", "Vendor decides; terms can change", "We control versioning and rollback", "Pinned versions, staged rollout, audit trail"],
  ],
  {
    x: 0.6, y: 2.0, w: 12.1,
    colW: [2.3, 3.0, 3.4, 3.4],
    rowH: [0.55, 1.02, 1.02, 1.02, 1.02],
    border: { pt: 0.75, color: "E2E8F0" },
    fontFace: "Arial", fontSize: 11.5, color: "1E293B",
    fill: { color: "FFFFFF" },
    valign: "middle", margin: 0.12,
    autoPage: false,
  }
);
```

Notes:
- `colW` sum must equal `w`. `rowH` array must match row count.
- `autoPage: false` keeps the table on one slide.

## Arrows and connectors (verified)

```js
// horizontal arrow with triangle head
s.addShape(pptx.shapes.LINE, {
  x: 4.3, y: 3.9, w: 1.3, h: 0,
  line: { color: "2563EB", width: 1.75, endArrowType: "triangle" },
});

// dashed line
s.addShape(pptx.shapes.LINE, {
  x: 10.4, y: 4.0, w: 0.62, h: 0,
  line: { color: "DC2626", width: 1.25, dashType: "dash" },
});
```

Notes:
- LINE shapes need w and/or h; `h: 0` is fine for horizontal arrows.
- Keep diagonal lines positive-delta only (x+w, y+h both increasing) — negative
  deltas are unreliable in this version.

## Dark-slide contrast constants (verified in QA loop)

- On dark backgrounds (`#0B1220` / `#1E293B`) use kickers/CTAs at `#60A5FA`, not the
  regular accent `#2563EB` — the vision model flagged `#2563EB` on ink as low-contrast,
  and pixel histogram confirmed the brighter blue is clearly rendered.
- Card subtext on dark cards: `#E2E8F0` (not `#94A3B8`).
- Ghost numbers: `#E2E8F0` on white cards reads as an intentional watermark.
