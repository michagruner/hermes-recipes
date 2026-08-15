# Gantt timeline pattern (verified on pptxgenjs 3.12.0, 13.333×7.5 canvas)

Quarter-based roadmap slide: workstreams × Q1..Q4 with owners. Verified in the
"One AI Assistant for Every Employee" management pitch (slide 10).

## Layout constants

```js
const gridX = 3.55, gridW = 6.1;   // quarter grid area
const qw = gridW / 4;              // quarter width ~1.525"
const ownerX = 9.95, ownerW = 2.75; // owner column
const rowH = 0.56, rowY0 = 2.5;    // 7 rows end ~6.42; band at 6.5
const workstreams = [
  { t: "Platform foundation", owner: "Infra team", q: [1, 2], c: ACCENT },
  { t: "Pilot — 20 users", owner: "AI Platform", q: [1, 2], c: GOOD },  // green = pilot
  { t: "Control plane (provisioner)", owner: "Platform Eng.", q: [2, 4], c: ACCENT },
];
```

## Bars

```js
workstreams.forEach((ws, i) => {
  const y = rowY0 + i * rowH;
  s.addText(ws.t, { x: M, y, w: 2.7, h: 0.4, fontSize: 10.5, bold: true, color: INK, margin: 0, valign: "middle" });
  const bx = gridX + (ws.q[0] - 1) * qw + 0.07;
  const bw = (ws.q[1] - ws.q[0] + 1) * qw - 0.14;
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: bx, y: y + 0.09, w: bw, h: 0.3, fill: { color: ws.c }, rectRadius: 0.06 });
  s.addText(ws.owner, { x: ownerX, y, w: ownerW, h: 0.4, fontSize: 10, color: MUTED, margin: 0, valign: "middle" });
});
```

Quarter separators: thin rects at `x: gridX + i*qw` from y=2.5, height `rows*rowH`.
Header row: workstream label + "Q1 2026".."Q4 2026" centered per column + "Owner",
hairline at y=2.42.

## Milestone (pitfall included)

Diamond at a quarter boundary, vertically centered on its row's bar:

```js
s.addShape(pptx.shapes.DIAMOND, { x: gridX + qw - 0.1, y: rowY0 + 2 * rowH + 0.14, w: 0.18, h: 0.18, fill: { color: WARN } });
s.addText("pilot go / no-go", { x: gridX + qw + 0.12, y: rowY0 + 2 * rowH + 0.18, w: 1.35, h: 0.2, fontSize: 8, bold: true, color: WHITE, margin: 0 });
```

DO NOT place the label in the gap above the row (`y: rowY0 + 2*rowH - 0.32`) — it
overlaps the previous row's bar (orange text on blue, unreadable). Label must sit
INSIDE the bar (white on green/good-contrast fill), immediately right of the diamond.

## Legend + band

Small legend bottom-left: 0.13" square swatches (green = Pilot, blue = Platform build)
+ 9pt muted labels at y≈6.1. Takeaway band at y=6.5 (see bottom-band geometry rule in
SKILL.md — keep rows ending ≤6.42).
