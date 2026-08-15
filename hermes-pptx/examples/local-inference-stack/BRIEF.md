# BRIEF — Local open-weight inference (canonical)

Frozen source of truth for the dual-audience deck. Do not invent hardware prices, VRAM numbers, or benchmark scores beyond this file. If a figure is missing, write “TBD — measure”.

Date of analysis: 2026-08-15.

## Decision to drive

Approve a **two-tier GPU fleet**. Do **not** standardize on H200. Do **not** buy 8× H200 on day one. Serve DeepSeek V4 Flash locally as the daily driver; burst GLM-5.2 / closed models through a router until a bake-off *and* utilization justify an NVLink node.

## Models in scope

All three are MoEs. **Active params set tokens/sec; total params set VRAM.** Every expert stays resident.

| Model | Size | License | Practical VRAM | Min honest box |
|---|---|---|---|---|
| **DeepSeek V4 Flash** | 284B / 13B active | MIT | ~170–175 GB native FP4+FP8; ~160 GB Q4 | **2× H200** or **2–4× RTX PRO 6000** |
| **Tencent Hy3** | 295B / 21B active | Apache 2.0 | ~295 GB FP8; ~590 GB BF16 | **4× H200** (FP8) or **8× H200** (BF16) |
| **GLM-5.2** | ~753B / ~40B active | MIT | ~744 GB FP8 | **8× H200**. Period. |

- Flash is the only realistically self-hostable **company default**.
- Hy3 is the Goldilocks agent/search model if 4× H200 already exists. Stronger on agentic search/tool use; weaker on coding vs GLM (Tencent’s own tables: SWE-bench Verified 78.0 vs 84.2; Terminal-Bench 2.1 71.7 vs 81; DeepSWE 28.0 vs 46.2 — vendor-reported).
- GLM-5.2 is a **coding-quality buy**, not a cost-efficiency buy.
- DeepSeek V4-Pro (1.6T, ~1 TB+ even at 4-bit) is a **cluster job**. Do not plan on-prem for it.

## H200 vs RTX PRO 6000

| | **RTX PRO 6000 Blackwell SE** | **H200** |
|---|---|---|
| Memory | 96 GB GDDR7 | 141 GB HBM3e |
| Bandwidth | ~1.6–1.8 TB/s | **4.8 TB/s** |
| Interconnect | **PCIe 5 only, no NVLink** | NVLink / SXM |
| Native low prec | **FP4 (NVFP4)** | FP8 |
| Power | ~400–600 W | ~600–700 W |
| Role | Cost/token on 1–2 GPU replicas | Big MoE + long context + 4–8 way TP |

Rule: if the model shards across 4–8 GPUs, buy HBM + NVLink. If it fits 1–2 GPUs at FP4/FP8 and you scale with replicas, buy RTX PRO 6000.

Independent serving benches: on models that fit one card, RTX PRO 6000 is close to H100/H200 on **$/M tokens**. On **8-way tensor parallel**, PCIe loses by **3–4× throughput**. That is the GLM-5.2 / Hy3-BF16 case.

- Do **not** buy 8× RTX PRO 6000 to “save money” on GLM-5.2.
- Do **not** buy a homogeneous H200 fleet unless GLM-5.2 (or V4-Pro) is a hard requirement.
- AMD MI300X/MI325X is not the first box unless ROCm staff already exist — these Chinese MoEs land on vLLM/SGLang CUDA first.

Flash at native FP4+FP8 (~170–175 GB):
- 2× H200 = 282 GB — comfortable
- 2× RTX PRO 6000 = 192 GB — tight
- 4× RTX PRO 6000 = 384 GB — comfortable VRAM, PCIe TP will hurt

Hy3 FP8 ~295 GB: 4× H200 (564 GB) is the honest box.
GLM-5.2 FP8 ~744 GB: 8× H200 (1128 GB) is the honest box. 8× RTX PRO 6000 (768 GB) barely fits and PCIe kills it.

## Phased buy (the plan)

### Phase 0 — prove the workload (0 extra GPUs)

LiteLLM (or thin OpenAI-compatible gateway) in front of DeepSeek / Z.ai / Tencent APIs. Measure tokens, latency SLOs, prompt classes, and what must never leave the building. Most companies discover ~80% of calls are Flash-class.

Duration: 4–8 weeks. Exit: measured token mix + residency classes + golden eval set.

### Phase 1 — first on-prem box

One **4× RTX PRO 6000 Server Edition** node (~384 GB):

- DeepSeek V4 Flash at NVFP4 / FP8 (2–4 way, keep context modest)
- 70B–120B dense replicas at FP8/FP4 (embeddings, classifiers, guard model)
- Dev/eval, LoRA, canary weights

Street TCO is typically **⅓–½ of a 4× H200 node**. Exact card prices: **TBD — quote**.

If Flash quality at native FP4+FP8 and 128K+ context is the SLO, swap this for **2× H200** (282 GB). That is a better Flash box than 4× RTX PRO 6000 if KV cache and decode bandwidth matter.

Duration: 6–10 weeks after Phase 0 exit. Exit: Flash serving SLO met on-prem; overflow to cloud works; utilization tracked.

### Phase 2 — only if gates pass

One **8× H200 SXM** (or 8× B200 if available without a long wait):

- GLM-5.2 FP8, or Hy3 BF16 + 256K
- Shared prefix / agent traffic on SGLang

Do not put this node on the hot path for every chat completion.

Gates (all required):
1. GLM-5.2 (or equivalent) wins a bake-off on **our** coding agents
2. Sustained utilization that justifies owned/colo iron (rule of thumb: under **~40%** utilization, purchased H200s lose to APIs)
3. Legal / residency review of weights and any remaining API fallback is signed off

### Colocate vs own

For a first company cluster, **dedicated bare metal / colo** usually beats owning H200s. Buy only after 3–6 months of measured, steady load.

On-prem only if 8–12 kW, 3-phase, and InfiniBand skills exist. A Proxmox guest with weak disk IOPS is the wrong host for weight loads and KV offload.

Exact colo $/hr and purchase quotes: **TBD — RFQ**. Do not invent list prices.

## Service stack

```
 Apps / IDE agents / RAG / internal chat
                 │
        API gateway (authN/Z, mTLS, IP allow)
                 │
     Control plane: LiteLLM + Postgres
     - model aliases  (flash | hy3 | glm | cloud)
     - per-team key, quota, budget
     - policy: PII / residency / allow-tools
     - fallback + canary
                 │
     ┌───────────┼────────────┐
     ▼           ▼            ▼
  SGLang      vLLM         Cloud
  (agents,    (general,    (overflow,
   prefix,     ops-mature)  GLM burst)
   MTP)
     │           │
  GPU pool A              GPU pool B
  4× RTX PRO 6000         8× H200
  Flash / small           GLM / Hy3-full
                 │
     Observability + audit lake
```

Serving rules:
- **SGLang** for agent loops, RAG with a shared system prompt, Hy3 MTP, DeepSeek-family serving. RadixAttention is the cost lever.
- **vLLM** as the boring production default and the engine with more Helm/K8s surface.
- Keep both behind the same OpenAI schema. Apps must not bind to an engine.
- **Ollama / LM Studio** for laptops only. Not a company serving plane.
- TensorRT-LLM only after model + GPU SKU are frozen for 6+ months.
- Separate prefill vs decode only after a second node exists — not a Phase-1 project.
- KV cache is a first-class SLO. Default context **32K**. Raise per route. 256K–1M is how you OOM a correctly sized weight box.
- Queue + 429 + cloud overflow. A saturated 4-GPU node without overflow is an outage.

## Governance (minimum)

| Control | Do this |
|---|---|
| Identity | SSO → short-lived service tokens. No shared `sk-` in Slack. |
| Data classes | Routes: `public` / `internal` / `restricted`. Restricted never leaves the building, no cloud fallback. |
| Prompt/response audit | Hash + metadata always; raw text only for restricted with 30–90 day retention. |
| Allow-lists | Tools, MCP servers, egress domains per tenant. |
| Model provenance | Pin commit + quant + chat template. Promote through staging. MIT/Apache is not “no review.” |
| Eval gate | Golden set (our tickets, our contracts, our code) before any weight swap. Vendor benches are directional. |
| Safety | Separate small guard model on the RTX box. Do not ask the frontier model to police itself. |
| Cost | Per-team token budget, cache-hit ratio, **$/successful-task** — not just $/M tokens. Agents burn output. |
| SBOM / CVE | Treat vLLM/SGLang/CUDA like prod software. Air-gap weight pulls. |
| Export / residency | EU: DeepSeek/Zhipu/Tencent weights need legal review, not just `git lfs pull`. APIs are usually a worse posture. |

## What to approve now vs later

**Approve now (Phase 0 + design):**
- Gateway + eval harness + data-class policy
- Bake-off criteria owned by engineering
- RFQ for 4× RTX PRO 6000 *or* 2× H200 (do not PO both)

**Approve after Phase 0 exit (Phase 1 iron):**
- One first node as above
- On-prem Flash as `company-flash`

**Do not approve until Phase 2 gates:**
- 8× H200 / B200
- On-prem GLM-5.2 or Hy3-BF16 as default
- V4-Pro

## Kill criteria

- Utilization of owned/colo GPUs stays **<40%** after 90 days of Phase 1
- Bake-off: local Flash (or Hy3) loses to API-only on the golden set by enough to erase TCO
- Legal no-go on the chosen weight family
- Phase-1 node cannot hold Flash SLO even at 32K with overflow

## Open items (must stay TBD on slides)

- Exact street / colo prices for RTX PRO 6000 and H200
- Power/cooling capacity of the target DC
- Legal opinion on DeepSeek / Zhipu / Tencent weights in the operating jurisdiction
- Independent (non-vendor) SWE-bench / agent scores
- Concrete token volume of this company (Phase 0 measures it)
