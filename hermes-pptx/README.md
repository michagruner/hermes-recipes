# Hermes PPTX Recipe

Self-hosted **premium PowerPoint generation** with [Nous Hermes Agent](https://hermes-agent.nousresearch.com/), matching the Anthropic pptx-skill quality bar:

| Layer | What |
|-------|------|
| **Agent** | Hermes gateway + skills + vision QA |
| **Design skill** | Anthropic `pptx` (fetched at bootstrap) |
| **Orchestrator** | `deck-master` — narrative → build → validate → render → vision fix |
| **Edit/screenshot** | [OfficeCLI](https://github.com/iOfficeAI/OfficeCLI) (downloaded in image) |
| **Render** | LibreOffice → PDF → `pdftoppm` JPEGs (`pptx-render` / `pptx-qa`) |
| **Default model** | DeepSeek `deepseek-v4-flash` (configurable) |
| **UI** | Optional Open WebUI (`--profile ui`) |

> **No secrets in this recipe.** Copy `.env.example` → `.env` and add your keys.

## Quick start

```bash
git clone https://github.com/michagruner/hermes-recipes.git
cd hermes-recipes/hermes-pptx

cp .env.example .env
# Edit .env — set at least one of:
#   DEEPSEEK_API_KEY=...
#   OPENROUTER_API_KEY=...
# and a strong API_SERVER_KEY

./scripts/bootstrap.sh
```

### Chat

```bash
docker compose exec hermes hermes
```

```text
/decks

Create an 8-slide board update for a B2B SaaS product.
Tone: sharp, premium. Include one native chart.
Output /workspace/decks/board-update.pptx
Run full visual QA before finishing.
```

Decks land in `./workspace/decks/` on the host.

### Other clients

| Client | How |
|--------|-----|
| Hermes CLI | `docker compose exec hermes hermes` |
| Open WebUI | `docker compose --profile ui up -d` → http://localhost:3080 |
| OpenAI-compatible API | `http://localhost:8642/v1` + `API_SERVER_KEY` |

## Layout

```text
hermes-pptx/
├── Dockerfile
├── docker-compose.yml
├── .env.example          # secrets template (commit)
├── .env                  # your secrets (gitignored)
├── data/                 # HERMES_HOME (bind-mounted)
│   ├── config.yaml
│   ├── SOUL.md
│   ├── skills/
│   │   ├── document/pptx/          # fetched by fetch-deps.sh
│   │   ├── office/officecli/
│   │   └── productivity/deck-master/
│   └── skill-bundles/decks.yaml
├── workspace/decks/      # output
└── scripts/
    ├── bootstrap.sh
    ├── fetch-deps.sh
    ├── pptx-render.sh
    ├── pptx-qa.sh
    └── smoke-test.sh
```

## Slash commands

| Command | Effect |
|---------|--------|
| `/decks` | Bundle: deck-master + pptx + officecli |
| `/deck-master` | Orchestrator |
| `/pptx` | Anthropic design + generation skill |
| `/officecli` | DOM edit / screenshot skill |

## Models

Default (`data/config.yaml`):

```yaml
model:
  default: "deepseek-v4-flash"
  provider: "deepseek"
  base_url: "https://api.deepseek.com/v1"
```

Switch live:

```text
/model deepseek:deepseek-v4-pro
/model openrouter:anthropic/claude-opus-4.6
/model openrouter:anthropic/claude-sonnet-4.5
```

Or: `docker compose exec hermes hermes model`

**Tip:** Deck quality tracks the model. Use Opus/Sonnet-class for board-level polish; Flash for speed/iteration.

## Ops

```bash
docker compose up -d hermes
docker compose logs -f hermes
docker compose exec hermes bash
docker compose down
docker compose build --no-cache && docker compose up -d hermes
```

Optional projects mount (read-only at `/projects`):

```bash
# .env
PROJECTS_PATH=/path/to/your/code
```

## Ports

| Port | Service |
|------|---------|
| 8642 | Hermes OpenAI-compatible API |
| 127.0.0.1:9119 | Hermes dashboard |
| 3080 | Open WebUI (`--profile ui`) |

## Security notes

- Do **not** commit `.env` or `data/.env`.
- The API binds `0.0.0.0:8642` with a **local** terminal backend — firewall or bind to localhost if the host is exposed.
- `API_SERVER_KEY` is required for the gateway; treat it like a password.

## Examples

| Example | Files |
|---------|--------|
| [AI sovereignty (management conference)](./examples/sovereign-ai/) | [`PROMPT.md`](./examples/sovereign-ai/PROMPT.md) · [`sovereign-ai.pptx`](./examples/sovereign-ai/sovereign-ai.pptx) |

## License notes

- This recipe: provided as-is for self-hosting.
- Hermes Agent: MIT (Nous Research)
- OfficeCLI: Apache-2.0
- Anthropic `pptx` skill: fetched separately; see its `LICENSE.txt` after `fetch-deps.sh`
