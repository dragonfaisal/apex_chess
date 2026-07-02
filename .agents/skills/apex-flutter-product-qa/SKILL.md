---
name: apex-flutter-product-qa
description: Use when validating Apex Chess Android and Flutter product flows including Analyze, Import, Archive, Stats, Review board, and Saved Analysis.
---

# apex-flutter-product-qa

## Trigger phrases

- product QA
- Android QA
- Flutter QA
- Analyze flow
- Import flow
- Archive flow
- Stats flow
- Review board
- Saved Analysis
- manual verification

## When to use

Use for visible Flutter behavior, Riverpod/provider changes, controllers, view models, archive reopen, saved review routing, import flows, stats screens, review board interactions, loading states, or product-facing error states.

## When NOT to use

Do not use for pure engine internals, pure classifier math, backend-only contracts, docs-only work, or skill-only workflow setup.

## Instructions

1. Identify the affected product flow and user-visible behavior.
2. Validate through the existing provider/controller/view-model seams.
3. Prefer focused widget, controller, model, and mapper tests over broad matrices.
4. Check loading, empty, error, retry, and saved/reopen states when relevant.
5. Check that review board orientation, timeline state, and selected move state remain coherent when touched.
6. Require Android manual verification only when host tests cannot cover the behavior or when real engine/device behavior is involved.
7. Record skipped validations with a clear reason.

## Required output format

```markdown
FLOW VALIDATED:

USER-VISIBLE BEHAVIOR:

AFFECTED SEAMS:

FOCUSED TESTS:

ANDROID MANUAL VERIFICATION TRIGGER:

REGRESSION RISKS:

VALIDATION EVIDENCE:

SKIPPED VALIDATIONS:
```
