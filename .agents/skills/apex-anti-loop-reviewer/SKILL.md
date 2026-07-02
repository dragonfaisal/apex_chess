---
name: apex-anti-loop-reviewer
description: Use to review an Apex Chess prompt or phase and reject metadata-only, diagnostic-only, preflight-only, readiness-gate, activation-candidate, or report-only loops unless they directly support real implementation.
---

# apex-anti-loop-reviewer

## Trigger phrases

- anti-loop
- review this phase
- is this prompt valid
- stop the loop
- diagnostic phase
- preflight phase
- readiness gate
- activation candidate
- metadata only

## When to use

Use before accepting a proposed phase or prompt, especially around engine/analyzer activation, backend gates, classifier readiness, scheduler work, or repeated diagnostic/report chains.

## When NOT to use

Do not use when the task is a direct, narrow implementation with clear product/runtime value, guardrails, and focused validation already defined.

## Instructions

1. Classify the prompt as implementation, enabling infrastructure, real QA, metadata, diagnostic, preflight, readiness gate, activation candidate, report, or mixed.
2. A phase is valid only if it advances engine substrate, analyzer input, analyzer output, classifier correctness, saved analysis, review UI, import/archive/stats flow, backend contract, or real QA coverage for a touched system.
3. If a proposed phase does not produce real implementation value or directly protect a touched runtime/product system, reject it.
4. Do not approve diagnostic-only, preflight-only, readiness-only, activation-candidate-only, or report-only phases as separate phases by default.
5. Reject standalone diagnostic/preflight/readiness/activation-candidate/report phases unless they directly support real implementation in the same phase.
6. Reject "world-class" or broad quality prompts that lack acceptance criteria.
7. Compress diagnostics, preflight checks, and reporting into the implementation phase whenever possible.
8. Require the next prompt to name allowed files/systems, forbidden files/systems, acceptance criteria, and focused validation.

## Required output format

```markdown
DECISION:
Accept | Compress | Reject

REASON:

PRODUCT/RUNTIME VALUE:

LOOP RISK:

MISSING ACCEPTANCE CRITERIA:

REQUIRED COMPRESSION:

ALLOWED NEXT PROMPT:
```
