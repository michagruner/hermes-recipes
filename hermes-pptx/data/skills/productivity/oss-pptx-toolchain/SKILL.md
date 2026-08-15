---
name: oss-pptx-toolchain
description: "Use when generating .pptx; verified pptxgenjs host quirks."
version: 1.0.0
license: MIT
author: hermes-curator
metadata:
  hermes:
    tags: [pptx, presentation, pptxgenjs, office, oss]
    category: productivity
    requires_toolsets: [terminal]
---

# OSS PPTX Toolchain — host quirks + verified fixes

Companion to the deck skills (`consulting-pptx`, `deck-master`). Holds the host-specific
knowledge verified against pptxgenjs 3.12.0. If a random web snippet contradicts
this file, THIS file is the host-verified one. The consulting-pptx cheatsheet now
uses the same 3.12 legacy chart signature.

## When to Use

- Any session generating or QAing a `.pptx` with the OSS stack (pptxgenjs, pptx-validate,
  pptx-render/pptx-qa, officecli, LibreOffice) on this host.
- Load alongside `consulting-pptx`/`deck-master` when their snippets are about to be used —
  treat this file's chart API and validation guidance as the ground truth for this host.
- Whenever a vision-QA flag (contrast, alignment, overflow) needs verification before redesign.

## Environment facts (verified)

- pptxgenjs on this host is **3.12.0**, resolvable via `NODE_PATH=/opt/pptx-tools/node_modules`
  (or just `require("pptxgenjs")` from /workspace).
- `write_file` sandbox is `HERMES_WRITE_SAFE_ROOT=/opt/data:/workspace` (compose override).
  **Prefer** `write_file` → `/workspace/tmp/<slug>/build.js`. `/opt/data/<slug>-build.js`
  still works. `pptx.writeFile` from node writes `/workspace/decks/<slug>.pptx`.
- MOST ROBUST authoring pattern: `write_file` the scaffold (helpers + cover), then
  patch in ≤4 slides per turn, then `node /workspace/tmp/<slug>/build.js` as a
  **separate** terminal call. Never one-shot a 12–16 slide file (Grok 4.6 think-phase
  then hits xAI idle timeout / Broken pipe).
- The terminal tool REJECTS command lines containing `&&` with a false-positive
  `Foreground command uses '&' backgrounding` error — never chain steps with `&&`;
  issue mkdir / write / build / render as individual calls. (A heredoc
  `cat > file <<'EOF' ... EOF` still works for content, but keep `&&` out of the command
  line entirely — this session that exact heredoc+`&&` combo failed twice before the
  write-to-/opt/data + separate-node pattern succeeded.)
- Outputs: `/workspace/decks/<slug>.pptx`; work dir: `/workspace/tmp/<slug>/`; previews: `slides/slide-NN.jpg`.

## pptxgenjs 3.12.0 chart API (the crash)

3.12.0 uses the LEGACY signature `s.addChart(type, data, options)`:
- `data` = ARRAY of `{ name, labels, values }` objects; all series share one `labels` array.
- The v4 object form (`categories` + `series`) CRASHES here with
  `TypeError: tmpData.forEach is not a function` — never use it.
- Verified working options: `showTitle`, `showLegend`, `legendPos`, `legendFontSize`,
  `legendColor`, `chartColors`, `lineSize`, `lineDataSymbol: "circle"`,
  `catAxisLabelFontSize`, `valAxisLabelFontSize`, `valAxisMinVal`, `valAxisMaxVal`,
  `barGrouping` (BAR). Full snippets in `references/pptxgenjs-3-12-api.md`.

## Validation gates

- Real gate: `pptx-validate` PASS **and** a clean LibreOffice render (`pptx-qa`).
- `officecli validate` reports BENIGN schema warnings on pptxgenjs output —
  `notesMasterIdLst` ordering, chart `varyColors`, `invertIfNegative` — these are
  expected pptxgenjs XML quirks, NOT failures. Do not chase them.

## Visual QA: verify at pixel level before fixing

Full-slide JPEGs (2000×1125) can mislead the vision model — this session it reported
left-aligned phase cards as "centered" and a bright #60A5FA kicker as "dim" (both false).
When a vision flag looks wrong or you are about to redesign:

1. Crop the region: `convert slide-NN.jpg -crop WxH+X+Y /tmp/x.png` (~150 px per inch).
2. Re-inspect the crop with vision_analyze, or read actual colors:
   `convert /tmp/x.png -format %c -depth 8 histogram:info:- | sort -rn | head`
   (count pixels matching the expected hex before claiming a contrast fix).
3. Only then change `build.js`.

## Bottom-band geometry (layout rule)

A full-width takeaway band (`band()` helper: y=6.5, h=0.6) ends at 7.1 and grazes the
footer baseline at 7.08. Rule: keep ALL body content above ~6.4 when a band is present,
or use a centered caption line (10.5–11.5pt, italic or bold accent) instead of a band on
dense slides. Verified failure: a 3-block left column starting at y=3.35 with 1.55"
spacing collided with the band — the third block (Governance) was hidden and its text
leaked under the band. Fix: start blocks at y=2.85, spacing 1.32, smaller text, and check
every column/table bottom edge against the band before rendering.

## Gantt timeline pattern

Verified pattern for quarter-based roadmap slides (full snippet in
`references/gantt-timeline.md`): grid columns Q1..Q4 (~1.525" each from x=3.55),
rows ~0.56" with light separators, rounded-rect bars (h=0.3) spanning quarter ranges,
owner column on the right (x=9.95, w=2.75), green = pilot, blue = platform build,
diamond milestone at a quarter boundary. Pitfall: a milestone LABEL placed in the gap
ABOVE its row overlaps the previous row's bar (orange-on-blue, unreadable) — put the
label INSIDE the bar with contrasting text color (white on green), not above it.

## Pitfalls summary

1. Never use `categories`/`series` chart form on this host — legacy `[{name,labels,values}]` array only.
2. Don't treat officecli schema warnings as failures; pptx-validate + render is the gate.
3. Don't fight the write_file sandbox and don't chain with `&&` — author `build.js` under `/opt/data/`
   via write_file, run `node /opt/data/<slug>-build.js` in a separate call.
4. Verify contrast/alignment flags with crops + histograms before redesigning.
