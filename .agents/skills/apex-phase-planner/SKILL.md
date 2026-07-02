---
name: apex-phase-planner
description: Use when planning an Apex Chess feature or phase; turns the request into a narrow implementation plan with guardrails, acceptance criteria, and validation policy.
---

# apex-phase-planner

## Trigger phrases

- phase plan
- plan Phase
- scope this phase
- implementation plan
- acceptance criteria
- validation policy
- maximum quality, minimum rotation

## When to use

Use before implementation phases that touch Apex product behavior, Flutter flows, engine/analyzer boundaries, classifier behavior, saved analysis, archive, stats, backend contracts, or tests.

## When NOT to use

Do not use for simple read-only questions, final reports, code reviews, or tasks that already provide a narrow implementation plan with allowed files, forbidden files, acceptance criteria, and validation.

## Instructions

1. Identify the single product/runtime value the phase must deliver.
2. Name non-goals and forbidden systems explicitly.
3. Keep diagnostics inside the implementation phase.
4. Reject metadata-only, diagnostic-only, preflight-only, readiness-only, activation-candidate-only, or report-only work.
5. Add guardrails for engine, classifier, analyzer, persistence, UI, backend, and tests based on the touched surface.
6. Define acceptance criteria that can be verified.
7. Choose focused validation first.
8. Add full validation and Android manual verification triggers only when the touched surface warrants them.

## Required output format

```markdown
PHASE NAME:

GOAL:

PRODUCT/RUNTIME VALUE:

NON-GOALS:

ALLOWED FILES/SYSTEMS:

FORBIDDEN FILES/SYSTEMS:

IMPLEMENTATION REQUIREMENTS:

GUARDRAILS:

ACCEPTANCE CRITERIA:

FOCUSED VALIDATION:

FULL VALIDATION TRIGGER:

ANDROID MANUAL VERIFICATION TRIGGER:

FINAL REPORT REQUIREMENTS:
```
