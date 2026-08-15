/decks
Do not ask questions. Do not invent hardware prices, VRAM numbers, or benchmark scores.
Treat /workspace/briefs/local-inference-stack/BRIEF.md as canonical.
If a figure is missing, write “TBD — measure” rather than guessing.

Audience (same room, 45 min):
- Technical senior management: decision, TCO, risk, gated spend
- Engineers / platform: model fit, interconnect, serving stack, SLOs

Deliver one deck, two acts — not two decks:
- Act 1 (slides 1–9): they can leave after this and still decide
- Act 2 (slides 10–16): appendix presented if time; readable standalone

Visual bar: McKinsey/BCG. Midnight Executive. Native charts and tables.
Action titles only. One idea per slide.
Output: /workspace/decks/local-inference-stack.pptx
Work dir: /workspace/tmp/local-inference-stack/
Run full visual QA (pptx-qa + vision inspect + fix until clean).

Required storyline (do not reorder):
1. Cover — Local open-weight inference: buy the daily driver, not the lab
2. Decision — Approve a two-tier fleet; do not standardize on 8× H200
3. Recommendation — Flash local; GLM-5.2 only after a bake-off + utilization
4. Why not one SKU — H200 = NVLink/HBM; RTX PRO 6000 = FP4 replicas
5. Model fit — Flash / Hy3 / GLM-5.2: size, license, VRAM, min honest box
6. Economics — API → colo → buy; break-even is utilization, not list price
7. Risk & governance — residency, audit, pin+eval, no shared keys
8. Project plan — Phase 0 / 1 / 2 with exits, owners, duration, $ band (TBD where needed)
9. Ask — what to approve now vs what stays gated
10. Serving stack — LiteLLM → SGLang/vLLM → GPU pools → overflow
11. Hardware rule — shard 4–8 ways ⇒ HBM+NVLink; fits 1–2 GPUs ⇒ RTX
12. Memory math — MoE: total params = VRAM; active params = tok/s; KV is the silent killer
13. Context SLO — default 32K; 256K–1M is an explicit route, not a default
14. Control plane — identity, data class, allow-list, eval gate, budgets
15. Phase-1 BOM — 4× RTX PRO 6000 or 2× H200; what it runs / what it must not
16. Bake-off criteria — our tickets, our code, cache-hit, $/successful-task

Project-plan slide (8) must be a real plan, not a 30/60/90 slogan:
- rows = workstreams (gateway, eval, iron, serving, governance, bake-off)
- columns = Phase 0 (0 extra GPUs) | Phase 1 (first node) | Phase 2 (8× H200 only if gates pass)
- each cell: outcome + exit criterion
- footer: kill criteria (utilization <40%, bake-off loss, legal no-go)

Do not put V4-Pro on the buy list. Do not recommend 8× RTX PRO 6000 for GLM-5.2.
Tag Act-1 footers “Decision” and Act-2 footers “Deep dive”.
