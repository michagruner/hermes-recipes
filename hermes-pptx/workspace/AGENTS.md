# Workspace context — hermes-pptx (OSS)

## Paths
- Finished decks: `/workspace/decks/<slug>.pptx`
- Scratch: `/workspace/tmp/<slug>/`
- Optional host projects: `/projects/`
- Skills: `/opt/data/skills/` — **consulting-pptx**, **deck-master**, **officecli** only for decks

## Rules
- OSS components only for slide generation (no Anthropic document skills).
- Use `/deck-master` or `/decks` for presentation requests.
- Always run `pptx-qa` before declaring done.
