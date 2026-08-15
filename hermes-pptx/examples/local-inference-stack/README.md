# Local inference stack (dual-audience + project plan)

Locked brief and prompt for a 16-slide deck aimed at **engineers and technical senior management** in the same 45-minute room. Includes a generated `.pptx`.

| File | Role |
|------|------|
| [`BRIEF.md`](./BRIEF.md) | Canonical numbers and decisions. Do not invent beyond this. |
| [`PROMPT.md`](./PROMPT.md) | `/decks` invocation — two acts, phase-gate plan required |
| [`local-inference-stack.pptx`](./local-inference-stack.pptx) | Sample output (Midnight Executive) |

## How to run

Mount or copy the brief into the container, then:

```text
/model grok-4.6
# provider xai-oauth if using SuperGrok / Premium+ OAuth

/decks
Read /workspace/briefs/local-inference-stack/BRIEF.md first.
Then follow examples/local-inference-stack/PROMPT.md.
```

Or bind-mount this folder to `/workspace/briefs/local-inference-stack`.

Use **medium** reasoning. Do not ask Hermes to emit all 16 slides in one `build.js` turn.
