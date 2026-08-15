# Hermes Recipes

Reusable, **secrets-free**, **OSS-oriented** Docker recipes for [Nous Hermes Agent](https://hermes-agent.nousresearch.com/).

## Recipes

| Recipe | Description |
|--------|-------------|
| [`hermes-pptx/`](./hermes-pptx/) | Premium self-hosted PowerPoint — **OSS only** (pptxgenjs, OfficeCLI, LibreOffice QA, consulting-pptx skill). No Anthropic proprietary document skills. |

## Quick start (PPTX)

```bash
git clone https://github.com/michagruner/hermes-recipes.git
cd hermes-recipes/hermes-pptx
cp .env.example .env
# add DEEPSEEK_API_KEY and/or OPENROUTER_API_KEY
./scripts/bootstrap.sh
docker compose exec hermes hermes
```

## Examples

- [`hermes-pptx/examples/sovereign-ai/`](./hermes-pptx/examples/sovereign-ai/) — 8-slide management deck on AI sovereignty
- [`hermes-pptx/examples/local-inference-stack/`](./hermes-pptx/examples/local-inference-stack/) — 16-slide dual-audience deck + phase-gate plan

Latest release: [v0.3.0](https://github.com/michagruner/hermes-recipes/releases/tag/v0.3.0)

## Contributing

- Never commit API keys, tokens, session DBs.
- Prefer downloading third-party binaries at bootstrap/build time.
- Do **not** vendor Anthropic proprietary skills.
- Keep host-specific paths out of compose files (use env vars).
