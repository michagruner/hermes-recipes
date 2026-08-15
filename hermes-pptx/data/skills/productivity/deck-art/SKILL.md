---
name: deck-art
description: "Optional one-shot unlabeled hero image for a deck cover. Use only when the user asks for atmosphere or a photo of a real object. Never illustrate every slide."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [pptx, art, image, cover]
    category: productivity
---

# Deck art (optional)

Not part of `/decks`. Load only if the user asks for a cover illustration or a photo of a real object.

## Rules

1. Generate **one** image for the whole deck.
2. Prompt must include: no letters, no numbers, no logos, no UI chrome, lock the deck palette.
3. Save to `/workspace/tmp/<slug>/art/hero.jpg`.
4. Hand the path back. Do **not** write the slide argument into the pixels.
5. If `image_gen` is unavailable, skip — do not stall the deck. pptxgenjs diagrams are the product.

See `consulting-pptx/references/visuals.md`.
