# Changelog

## [0.2.0] — 2026-08-15

Dual-audience decks, a real project-plan layout, and the Hermes/Grok reliability fixes that stopped 16-slide jobs from dying mid-think.

### Added
- Dual-audience + project-plan mode (12–16 slides, two acts, phase-gate / decision-tree / stack / RACI layouts)
- `examples/local-inference-stack/` — locked brief, prompt, and sample deck
- `oss-pptx-toolchain` skill — pptxgenjs 3.12 chart API and host quirks
- `write_file` sandbox now includes `/workspace` (`HERMES_WRITE_SAFE_ROOT=/opt/data:/workspace`)
- grok-4.6 stale timeouts (900s) and `reasoning_overrides: medium`
- Incremental generation contract: scaffold + ≤4 slides per write, no `&&` in terminal

### Changed
- `/decks` no longer preloads the full officecli skill (Word/Excel/Morph novel)
- consulting-pptx / deck-master insist on `write_file` to `/workspace` and forbid one-shot 16-slide `build.js`
- Chart cheatsheet uses the pptxgenjs 3.12 legacy `{name, labels, values}` signature
- Compose uses `${PROJECTS_PATH}` instead of a host-specific path

### Fixed
- Reasoning models claiming they have no filesystem (sandbox was `/opt/data` only)
- Hermes treating `&&` as backgrounding (`\s&\s` matches ` && `)
- grok-4.6 not in Hermes’s built-in reasoning-timeout floor (only grok-4.5) → Broken pipe after 90–120s
