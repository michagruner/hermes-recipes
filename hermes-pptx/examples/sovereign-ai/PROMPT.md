# Sample prompt — Sovereignty with AI usage

Used to generate [`sovereign-ai.pptx`](./sovereign-ai.pptx) via Hermes + `/decks`
(OSS stack: consulting-pptx + OfficeCLI + pptxgenjs — no Anthropic proprietary skills).

## Prompt

```text
/decks Please create me a presentation for a management-conference where I am a speaker. The overall topic is "souvereignity with AI-usage". We plan to
run local inference with open-weight models and ensure that we are a) independent from hyperscalers and b) data not leaving our data center. Please ask if
 you need to know something. I really would like to have it addressed to the management. Use visuals if you can, so it is easily understandable. Please ma
ke sure it looks like its from mckinsey or BCG or the likes.
```

## Notes

- Invoke with the **`/decks`** skill bundle (deck-master + pptx + officecli).
- Target audience: **management / conference**.
- Narrative focus: **AI sovereignty** via local open-weight inference — independence from hyperscalers + data residency in own DC.
- Visual bar: McKinsey / BCG style (action titles, clean hierarchy, diagrams over bullet walls).
- Output path used in the live stack: `/workspace/decks/sovereign-ai.pptx`

## Reproduce

```bash
cd hermes-pptx
docker compose exec hermes hermes
# paste the prompt above
# or one-shot:
docker compose exec hermes hermes chat -q "$(cat examples/sovereign-ai/PROMPT.md)"
```

Finished decks land in `workspace/decks/` on the host.
