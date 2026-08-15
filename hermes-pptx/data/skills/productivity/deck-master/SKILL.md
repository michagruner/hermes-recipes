---
name: deck-master
description: "Top-quality OSS PowerPoint production pipeline. Use whenever the user wants slides, a deck, a pitch, a presentation, or a .pptx. Orchestrates consulting-pptx design rules, pptxgenjs, OfficeCLI, and LibreOffice visual QA. No proprietary skills."
version: 2.1.0
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
2. Outline with **action titles** (short). Do not narrate the finished deck.
3. Generate via pptxgenjs **incrementally**: scaffold + ≤4 slides per `write_file`.
   You can write `/workspace/...`. Never one-shot 12–16 slides. No `&&` in terminal.
4. `terminal`: `node /workspace/tmp/<slug>/build.js` as its own call.
5. `pptx-validate`. `officecli validate` is optional CLI — do **not** load the officecli skill.
6. `pptx-qa` → vision-inspect every slide → fix → re-render until clean.
7. Deliver path + brief storyline. Do not claim done unless `ls` shows the `.pptx`.

## Quality bar
McKinsey/BCG-like craft: intentional color, hierarchy, native charts, no AI-template look.
Fewer excellent slides beat many mediocre ones.
Dual-audience + project-plan decks may run 12–16 slides (decision act + technical appendix).
Never invent figures that are not in the brief.
