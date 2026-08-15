---
name: consulting-pptx
description: "OSS-only McKinsey/BCG-style PowerPoint generation with pptxgenjs, OfficeCLI, and LibreOffice visual QA. Use for decks, pitches, board updates, conference talks, and executive presentations. No proprietary Anthropic skills."
version: 2.2.0
license: MIT
metadata:
  hermes:
    tags: [pptx, presentation, slides, design, consulting, oss]
    category: productivity
    requires_toolsets: [terminal]
---

# Consulting PPTX (OSS)

Produce **board-ready** native `.pptx` using only open-source tooling.

## Stack (all OSS)

| Tool | License | Role |
|------|---------|------|
| [pptxgenjs](https://github.com/gitbrent/PptxGenJS) | MIT | Create decks |
| [OfficeCLI](https://github.com/iOfficeAI/OfficeCLI) | Apache-2.0 | DOM edit, screenshot, validate |
| LibreOffice + poppler | MPL/GPL | PDF → JPEG visual QA |
| [python-pptx](https://github.com/scanny/python-pptx) | MIT | Inspect / light edit |
| [markitdown](https://github.com/microsoft/markitdown) | MIT | Extract slide text |
| `pptx-validate` / `pptx-render` / `pptx-qa` | MIT (this stack) | Validate + render loop |

**Do not** load or fetch Anthropic document skills.

## Paths on this host

- Skills: `/opt/data/skills/productivity/consulting-pptx/`
- Validate: `pptx-validate deck.pptx` or `python /opt/data/skills/productivity/consulting-pptx/scripts/validate_pptx.py deck.pptx`
- Render: `pptx-render deck.pptx out_dir`
- Full QA: `pptx-qa deck.pptx work_dir`
- Outputs: `/workspace/decks/<slug>.pptx`
- Work: `/workspace/tmp/<slug>/`

---

## Workflow (mandatory)

### 1. Brief
Audience, decision to drive, slide count, tone, brand colors (or pick a palette), must-include data/charts.

### 2. Narrative first
- **Action titles** only (insight or recommendation — never "Overview", "Agenda", "Summary" alone).
- One idea per slide.
- Pyramid: situation → complication → resolution; or SCR / MECE storyline.
- Prefer **fewer excellent slides**. Dual-audience + project-plan decks: **12–16 slides**, two acts.

**Dual-audience (tech + technical senior management):**
- One deck, two acts. Act 1 must stand alone as a decision memo.
- Every Act-1 title must be readable by a VP; the body may be dense.
- Tag footer left: “Decision” or “Deep dive” — do not mix acts on one slide.
- Do not split into two files unless the user asks.
- If a `BRIEF.md` is in the request, do not ask questions; quote numbers from it or write TBD.

### 3. Design system

**Canvas:** 16:9 widescreen — `13.333" × 7.5"`.

**Margins:** ≥ 0.5" from edges. Gutter between columns ≥ 0.25".

**Type scale (Arial or Calibri):**
| Role | Size | Weight |
|------|------|--------|
| Cover title | 32–40 | Bold |
| Section title | 28–32 | Bold |
| Action title | 22–28 | Bold |
| Body | 14–16 | Regular |
| Caption / source | 10–12 | Regular |
| Big number | 36–48 | Bold |

**Color (pick one palette; stay consistent):**

*Midnight Executive (default for tech/sovereignty)*
- Ink `#0B1220` · Slate `#1E293B` · Paper `#F8FAFC` · Muted `#64748B`
- Accent `#2563EB` · Good `#059669` · Warn `#D97706` · Bad `#DC2626`

*Boardroom Classic*
- Navy `#0F172A` · Steel `#334155` · White `#FFFFFF` · Mist `#E2E8F0`
- Accent `#0EA5E9` · Chart series: `#0EA5E9 #6366F1 #14B8A6 #F59E0B #EF4444`

*Warm Consulting*
- Charcoal `#1C1917` · Stone `#78716C` · Cream `#FAFAF9`
- Accent `#B45309` · Secondary `#0F766E`

**Rules that kill "AI slop":**
- **Diagram first.** Relationships, sequences, UIs, and plans are pptxgenjs shapes + 3–6 words. See `references/visuals.md`.
- An image model is optional and rare: at most **one** unlabeled hero if the brief asks for atmosphere or a real object. Never illustrate every slide. Never put required words in pixels.
- Fail vision QA if you cannot say the title from the picture alone — then delete the image and draw a diagram.
- No teal/purple gradient wallpaper
- No decorative vertical accent bar as a default crutch on every slide
- No giant empty cards with one metric and a vague subtitle
- No walls of 8+ prose bullets. Comparison tables (5–7 rows) and phase grids are allowed and preferred for hardware, model-fit, and governance slides.
- High contrast only (dark on light or light on dark — never gray-on-gray)
- Align columns to a shared grid across the deck
- Sources and footnotes bottom-left or bottom-right, 10–11pt muted

**Layout patterns (use often):**
1. **Title / cover** — dark full bleed, 1 line title, 1 line subtitle, speaker + date
2. **Action + 3 columns** — title, three equal cards (icon/number + 2 lines)
3. **Split 40/60** — left insight text, right chart or process
4. **Matrix 2×2** — strategic choices
5. **Process chevron / numbered steps** — 4–6 steps horizontal
6. **Big number row** — 3–4 KPIs with labels + delta
7. **Comparison table** — before/after or build/buy/partner
8. **Closing** — recommendation + next 30/60/90 days
9. **Phase-gate plan** — 3 columns (phases) × 4–6 workstream rows; exit criteria in the cell, not the title
10. **Decision tree** — 3–4 binary nodes (SKU / model / buy-vs-colo), one recommended path highlighted
11. **Stack swimlane** — 4–5 horizontal layers (apps → gateway → router → engines → GPU pools)
12. **RACI strip** — workstream × R/A/C/I, 10–11pt, only on the plan or BOM slide

### 4. Generate with pptxgenjs — incrementally

**You can write files.** `write_file` is allowed under `/workspace` and `/opt/data`.
Never say you lack a filesystem. Never compose a 12–16 slide `build.js` in one turn
(that is how Grok 4.6 times out: long think, no tool call, xAI drops the stream).

**Do not load** the full `officecli` skill or the `powerpoint` (python-pptx) skill.

**Turn plan:**
1. `terminal`: `mkdir -p /workspace/tmp/<slug> /workspace/decks`  (no `&&`)
2. `write_file` `/workspace/tmp/<slug>/build.js` — helpers + cover only
3. `write_file` or `patch` — add at most **4 slides** per turn
4. `terminal`: `node /workspace/tmp/<slug>/build.js`  (own call, `NODE_PATH` already set)
5. Validate, then next batch

```javascript
const PptxGenJS = require("pptxgenjs");
const pptx = new PptxGenJS();
pptx.defineLayout({ name: "WIDE", width: 13.333, height: 7.5 });
pptx.layout = "WIDE";
pptx.author = "Hermes PPTX (OSS)";
pptx.title = "Deck title";

// Charts are the 3.12 LEGACY signature — array of {name, labels, values}.
// The v4 {categories, series} object CRASHES (tmpData.forEach).
// s.addChart(pptx.charts.BAR, [{ name: "A", labels: ["Q1"], values: [1] }], { x: 0.6, y: 1.3, w: 7.5, h: 4 });

pptx.writeFile({ fileName: "/workspace/decks/<slug>.pptx" });
```

See `references/pptxgenjs-cheatsheet.md` and `references/visuals.md`. Host quirks: `oss-pptx-toolchain`.

### 5. Validate

```bash
pptx-validate /workspace/decks/<slug>.pptx
officecli validate /workspace/decks/<slug>.pptx --json
```

Fix errors before visual QA.

### 6. Visual QA loop (non-negotiable)

```bash
pptx-qa /workspace/decks/<slug>.pptx /workspace/tmp/<slug>
```

Open each `slide-*.jpg` with the **vision** tool. Fail if any of:
- Text cut off or overflowing boxes
- Overlapping elements
- Low contrast
- Uneven gaps / misaligned columns
- Sparse "filler" slides
- Too much whitespace with no hierarchy
- A generated picture whose meaning is not the title (decode-the-metaphor slides)
- Any required words living inside a generated image

Fix in `build.js` (preferred) or `officecli set`, re-render, re-check.

### 7. Deliver
- Path to `/workspace/decks/<slug>.pptx`
- Optional 2–3 preview JPEGs
- One-line storyline summary

---

## OfficeCLI quick reference

```bash
officecli view deck.pptx --json
officecli view deck.pptx screenshot -o /tmp/preview.png
officecli validate deck.pptx --json
officecli set deck.pptx /slide[1]/shape[2] --prop text="New title"
officecli help
```

## Quality bar

A finished deck should look like a strong consulting team produced it overnight — crisp titles, intentional color, real charts, no template junk. If time is short, cut slides before cutting craft.
