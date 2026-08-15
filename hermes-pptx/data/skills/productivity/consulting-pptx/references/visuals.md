# Visuals — diagram first, image model last

People scan a slide in a few seconds. A metaphor they must decode is slower than three labeled boxes.

## Default (almost every slide)

Draw the argument in **pptxgenjs shapes + 3–6 words per node**.

Use this when the point is a:

- **relationship** (A → file → gate → B)
- **sequence** (poison → parse → move → present)
- **UI** (Keep / Change / Cut vs Slack)
- **comparison** (approve / refuse / gate)
- **plan** (phase columns)

The picture **is** the sentence. Labels live in pptxgenjs, never in pixels.

## Image model — optional, rare

Use `image_gen` (or an equivalent) **only if all of these are true**:

1. The brief or user explicitly wants a photo / illustration of a real object or atmosphere.
2. The action title still stands if you cover the picture with your hand.
3. You will generate **at most one** hero asset for the whole deck (usually the cover).
4. The prompt forbids letters, numbers, logos, UI chrome, watermarks.

Never:

- illustrate every slide
- put required words in the generated image (models invent “DECK FAGTORY”)
- let the picture carry the claim
- use teal/purple glass, neon, or stock-AI wallpaper

If you generate: lock the active palette (Midnight Executive / Boardroom / Warm). Save under `/workspace/tmp/<slug>/art/`. Place with `s.addImage`, then stamp any caption in pptxgenjs.

## Vision QA extra test

For every slide that has a picture, fail if you cannot answer:

> Can I say the title from the picture alone?

If no, delete the image and draw a labeled diagram.

## `/art` (optional)

A one-shot hero request, not a slide factory. Output: one unlabeled image path. The deck agent places it and writes the words.
