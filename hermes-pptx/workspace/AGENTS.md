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
- Dual-audience or “project plan” requests: 12–16 slides, two acts. Do not ask clarifying questions if a `BRIEF.md` is present. This overrides the default “management-only conference” user profile.
- For those jobs prefer a strong model (`grok-4.6`, `deepseek-v4-pro`, or Opus-class) over Flash — but generate incrementally (≤4 slides per write). Never one-shot the JS.
- You can write files under `/workspace` and `/opt/data`. Never claim otherwise.
- Terminal: one command per call. Do not use `&&`.
- Locked briefs live under `/workspace/briefs/<slug>/`.
- Do not preload the full officecli skill. Call `officecli` on PATH if needed.
- Visuals: labeled pptxgenjs diagrams by default. Image model at most once (unlabeled hero) if the user asked. Never put required words in generated pixels. See consulting-pptx `references/visuals.md`.
