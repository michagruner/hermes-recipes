# Workspace context — hermes-pptx

## Paths
- Write finished decks to `/workspace/decks/<slug>.pptx`
- Scratch/build scripts under `/workspace/tmp/<slug>/`
- Optional host projects (read-only): `/projects/`
- Skills on disk: `/opt/data/skills/` (pptx, officecli, deck-master)

## Required quality bar
Use `/deck-master` for any presentation request. Always run visual QA (`pptx-qa`) before declaring done.
