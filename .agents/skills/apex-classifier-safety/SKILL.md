---
name: apex-classifier-safety
description: Use for Apex Chess classifier safety around Brilliant, Great, Missed Win, Book, Blunder, Win% delta, perspective handling, MultiPV evidence, classifier tests, and saved label consistency.
---

# apex-classifier-safety

## Trigger phrases

- classifier
- Brilliant
- Great
- Missed Win
- Book
- Blunder
- Win%
- delta win
- perspective
- MultiPV evidence
- saved labels
- move classification

## When to use

Use for any change to move labels, Win% math, mover-perspective delta, `MoveClassifier`, `WinPercentCalculator`, `DeepTacticalVerifier`, engine-line inputs, coach explanations derived from labels, saved label consistency, or classifier fixtures.

## When NOT to use

Do not use for styling-only UI changes that display already-computed labels, docs-only work, or backend-only activation gates with no label semantics.

## Instructions

1. Keep White/Black perspective explicit and tested.
2. Do not retune thresholds unless the phase explicitly scopes threshold work.
3. Brilliant must remain strict, rare, sacrifice-based, sound, not assigned to trivial recaptures, and deeply verified.
4. Great/Only Move requires MultiPV or equivalent alternative-line evidence.
5. Missed Win requires a maintained-win alternative and a large mover-perspective drop.
6. Book handling must not hide a real large drop without an honest explanation.
7. Quick mode must not overclaim labels that require Deep/MultiPV evidence.
8. Do not allow classifier output unless input perspective, best-line evidence, and saved-analysis consistency are explicitly proven.
9. If labels are persisted or cached, verify saved-analysis and archive consistency.

## Required output format

```markdown
CLASSIFIER SURFACE:

MATH OR THRESHOLD IMPACT:

PERSPECTIVE PROOF:

MULTIPV OR ALTERNATIVE-LINE EVIDENCE:

SAVED-ANALYSIS IMPACT:

FOCUSED TESTS:

REGRESSION RISKS:

KNOWN LIMITATIONS:
```
