---
name: deck-master
description: "Top-quality PowerPoint production pipeline for this Hermes host. Use whenever the user wants slides, a deck, a pitch, a presentation, or a .pptx — especially executive, investor, consulting, product, or board decks. Orchestrates pptxgenjs design rules, validation, LibreOffice visual QA, and optional OfficeCLI edits."
version: 1.0.0
metadata:
  hermes:
    tags: [pptx, presentation, slides, design, office]
    category: productivity
    requires_toolsets: [terminal]
---

# Deck Master — premium PPTX pipeline

You are producing **presentation-quality** PowerPoint, not bullet soup.
This host is pre-configured. Prefer tools already on PATH.

## Tooling (already installed)

| Tool | Purpose |
|------|---------|
| `pptxgenjs` (Node) | **Create** new decks |
| `officecli` | Inspect, edit DOM, screenshots, validate |
| `markitdown file.pptx` | Extract text per slide |
| `python /opt/data/skills/document/pptx/scripts/office/validate.py` | Schema/rel validation |
| `pptx-render deck.pptx` | LibreOffice → PDF → JPEG per slide |
| `pptx-qa deck.pptx` | Render + list preview paths |
| `soffice` / skill `soffice.py` | Headless convert (use wrapper if bare hangs) |

Skill paths on this host:

- Anthropic design skill: `/opt/data/skills/document/pptx/` (also load via `/pptx`)
- OfficeCLI skill: `/opt/data/skills/office/officecli/` (also `/officecli`)
- This orchestrator: `/opt/data/skills/productivity/deck-master/`

**Always load `/pptx` design rules** (or read that SKILL.md) before writing a generator.
Use OfficeCLI when editing an existing deck or for quick screenshot QA.

## Output locations

- Final decks: `/workspace/decks/<slug>.pptx`
- Working files: `/workspace/tmp/<slug>/`
- Slide previews: `/workspace/tmp/<slug>/slides/slide-01.jpg` …

Never write only under `/tmp` without copying the final `.pptx` to `/workspace/decks/`.

## Non-negotiable workflow

### 1. Brief (if missing)

Confirm: audience, goal, slide count range, tone, brand colors (or pick a palette), must-include data.

### 2. Narrative first

Write a slide outline with **action titles** (not "Overview", "Agenda").
One idea per slide. Max ~6 content slides for short decks unless asked otherwise.

### 3. Design system (from pptx skill)

- Pick a **topic-specific** palette — not generic purple-on-white AI defaults
- Avoid: decorative accent bars under titles, teal/cyan gradients, huge rounded cards with equal weight, sparse "big number + subtitle" filler, low-contrast gray on gray
- Prefer: strong type hierarchy, real margins (≥0.5"), alignment grid, selective bold color, native charts
- Widescreen 16:9 (`pptx.defineLayout` / standard 13.333" × 7.5")

### 4. Generate with pptxgenjs

Write a single Node script under `/workspace/tmp/<slug>/build.js` and run:

```bash
cd /workspace/tmp/<slug> && node build.js
```

Script must write `/workspace/decks/<slug>.pptx`.

### 5. Validate

```bash
python /opt/data/skills/document/pptx/scripts/office/validate.py /workspace/decks/<slug>.pptx
# and/or
officecli validate /workspace/decks/<slug>.pptx --json
```

Fix every error before visual QA.

### 6. Visual QA loop (mandatory)

```bash
pptx-qa /workspace/decks/<slug>.pptx /workspace/tmp/<slug>
```

Then **open each** `slide-*.jpg` with the vision tool. Check:

- Text overflow / cut off at edges
- Overlapping shapes or text
- Insufficient contrast
- Uneven gaps, stacked elements too tight
- Low-value slides, walls of bullets
- Columns misaligned across slides

Fix in source (`build.js` re-run preferred for new decks; `officecli set` for small edits), re-render, re-check until clean.

### 7. Deliver

- Path to final `.pptx`
- Optional: attach 2–3 key preview JPEGs as documents (`[[as_document]]` on messaging)
- One-line summary of narrative arc

## OfficeCLI quick patterns

```bash
officecli view /workspace/decks/x.pptx --json
officecli view /workspace/decks/x.pptx screenshot -o /workspace/tmp/x/preview.png
officecli issues /workspace/decks/x.pptx --json
officecli help set
```

Prefer L2 DOM edits over raw XML. Fall back to unpack/edit/zip only when needed (see `/pptx`).

## Quality bar

A finished deck should look like a strong consulting/product designer made it — not a default template dump.
If time is short, fewer excellent slides beat many mediocre ones.
