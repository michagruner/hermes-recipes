---
name: deck-master
description: "Top-quality OSS PowerPoint production pipeline. Use whenever the user wants slides, a deck, a pitch, a presentation, or a .pptx. Orchestrates consulting-pptx design rules, pptxgenjs, OfficeCLI, and LibreOffice visual QA. No proprietary skills."
version: 2.0.0
license: MIT
metadata:
  hermes:
    tags: [pptx, presentation, slides, design, office, oss]
    category: productivity
    requires_toolsets: [terminal]
---

# Deck Master — premium PPTX pipeline (OSS-only)

You produce **presentation-quality** PowerPoint with **open-source components only**.

## Never use
- Anthropic document skills (`pptx` from anthropics/skills)
- Proprietary skill packs, closed templates, or non-OSS icon CDNs that require paid licenses

## Always use
| Tool | Purpose |
|------|---------|
| `/consulting-pptx` | Design system + narrative rules |
| `/officecli` | DOM edit, screenshots, validate |
| `pptxgenjs` | Create native `.pptx` |
| `pptx-validate` | Structural validation |
| `pptx-render` / `pptx-qa` | LibreOffice → JPEG visual QA |
| `markitdown` | Text extract |

Skill paths:
- `/opt/data/skills/productivity/consulting-pptx/`
- `/opt/data/skills/productivity/deck-master/`
- `/opt/data/skills/office/officecli/`

## Output
- Final: `/workspace/decks/<slug>.pptx`
- Work: `/workspace/tmp/<slug>/`
- Previews: `/workspace/tmp/<slug>/slides/slide-01.jpg` …

## Workflow
1. Load **consulting-pptx** design rules (read SKILL.md if not already in context).
2. Outline with **action titles**.
3. Generate via pptxgenjs (`build.js`).
4. `pptx-validate` + `officecli validate`.
5. `pptx-qa` → vision-inspect every slide → fix → re-render until clean.
6. Deliver path + brief storyline.

## Quality bar
McKinsey/BCG-like craft: intentional color, hierarchy, native charts, no AI-template look.
Fewer excellent slides beat many mediocre ones.
