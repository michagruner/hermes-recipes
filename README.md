# Hermes Recipes

Reusable, **secrets-free** Docker recipes for [Nous Hermes Agent](https://hermes-agent.nousresearch.com/).

## Recipes

| Recipe | Description |
|--------|-------------|
| [`hermes-pptx/`](./hermes-pptx/) | Premium self-hosted PowerPoint generation (LibreOffice visual QA, pptxgenjs, OfficeCLI, Anthropic pptx skill, deck-master orchestrator) |

## Quick start (PPTX)

```bash
git clone https://github.com/michagruner/hermes-recipes.git
cd hermes-recipes/hermes-pptx
cp .env.example .env
# add DEEPSEEK_API_KEY and/or OPENROUTER_API_KEY
./scripts/bootstrap.sh
docker compose exec hermes hermes
```

## Contributing

- Never commit API keys, tokens, session DBs, or generated `.pptx` files.
- Prefer downloading third-party binaries/skills at bootstrap/build time.
- Keep host-specific paths out of compose files (use env vars).
