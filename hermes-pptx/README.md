# Hermes PPTX Stack (OSS-only)

Self-hosted **premium PowerPoint generation** on [Nous Hermes Agent](https://hermes-agent.nousresearch.com/) using **open-source components only**.

| Layer | Component | License |
|-------|-----------|---------|
| Agent | Hermes | MIT |
| Design skill | `consulting-pptx` (this repo) | MIT |
| Orchestrator | `deck-master` | MIT |
| Create | [pptxgenjs](https://github.com/gitbrent/PptxGenJS) | MIT |
| Edit / screenshot | [OfficeCLI](https://github.com/iOfficeAI/OfficeCLI) | Apache-2.0 |
| Render QA | LibreOffice + poppler | MPL/GPL |
| Inspect | python-pptx, markitdown | MIT |

**Not included:** Anthropic proprietary document skills.

## Quick start

```bash
cd ~/hermes-pptx
# .env with DEEPSEEK_API_KEY and/or OPENROUTER_API_KEY
./scripts/bootstrap.sh
docker compose exec hermes hermes
```

```text
/decks

Create an 8-slide board update on AI sovereignty for management.
McKinsey/BCG visual bar. Native charts. Output /workspace/decks/board.pptx
Run full visual QA.
```

Dual-audience + project-plan: use `examples/local-inference-stack/` (locked `BRIEF.md` + `PROMPT.md`). Prefer `grok-4.6` at **medium** reasoning. Generate incrementally (≤4 slides per write). Do not one-shot a 16-slide `build.js`.

Outputs: `workspace/decks/`

## Access

| Path | URL / command |
|------|----------------|
| CLI | `docker compose exec hermes hermes` |
| API | `http://localhost:8642/v1` + `API_SERVER_KEY` |
| Dashboard | `http://127.0.0.1:9119` |
| Open WebUI | `docker compose --profile ui up -d` → `:3080` |

## Slash commands

| Command | Effect |
|---------|--------|
| `/decks` | deck-master + consulting-pptx (officecli is CLI-only; do not preload the skill) |
| `/consulting-pptx` | Design system + generation rules |
| `/deck-master` | Orchestrator |
| `/officecli` | DOM ops |

## Ops

```bash
docker compose build && docker compose up -d hermes
docker compose logs -f hermes
```
