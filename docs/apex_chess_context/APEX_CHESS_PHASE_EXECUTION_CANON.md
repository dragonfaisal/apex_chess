# Apex Chess Phase Execution Canon

## Purpose
This document defines how future Apex Chess phases should be scoped, implemented, validated, and reported without falling back into diagnostic loops.

## Current Canon

### Execution Law
Maximum quality, minimum rotation.

Every implementation phase must combine:
- real implementation value,
- guardrails,
- focused validation,
- concise report.

### Valid Phase Rule
A phase is valid only if it moves at least one forward:
- engine substrate,
- analyzer input,
- analyzer output,
- classifier correctness,
- saved analysis,
- review UI,
- import/archive/stats product flow,
- backend contract,
- real QA coverage for a touched system.

Metadata/report-only work must be compressed into a real implementation phase or rejected unless explicitly requested as documentation/audit work.

### Validation Tiers
- Light validation: docs, skills, pure model files, prompt libraries.
- Focused validation: touched Dart tests, touched tool commands, specific integration proof.
- Android proof: native bridge, FFI, Stockfish, Android-only behavior, UI layout/gesture behavior.
- Full validation: broad shared runtime, DI, scheduler, persistence, classifier, UI, or release-critical changes.

### When to Run Light Validation
- Docs/skills only.
- Pure prompt/template changes.
- No runtime imports, no app code, no tests.

### When Focused Tests Are Enough
- Narrow pure model change.
- Single tool/report command.
- Single adapter boundary with injected fakes.
- One classifier rule with focused classifier tests.

### When Full Validation Is Required
- Shared provider/DI changes.
- Persistence schema or saved analysis changes.
- Scheduler/runtime execution changes.
- UI navigation or common state changes.
- Classifier math retuning across labels.
- Engine lifecycle or parser behavior that affects existing analysis flow.

### When Android Proof Is Required
- Stockfish bridge/native/FFI changes.
- UCI lifecycle or engine isolate behavior.
- Android packaging.
- Device-specific UI layout/gesture proof.

### When Classifier Tests Are Required
- Any public label behavior.
- Brilliant/Great/Miss/Book/Blunder thresholds.
- Perspective math feeding classification.
- Saved label migration.

### Commit / Tag Rules
- Do not commit unless explicitly requested.
- Do not tag unless explicitly requested.
- Stage only scoped files.
- Stop and report unrelated changes before committing.

## Rules
- No standalone diagnostic, preflight, readiness, activation-candidate, or report loops by default.
- Diagnostics belong inside implementation phases.
- No broad rewrites.
- No hidden product/runtime activation.
- No touching forbidden systems "for convenience."
- Reports must be concise and evidence-based.

## Forbidden Regressions
- Patch -> diagnostic -> preflight -> diagnostic -> candidate -> diagnostic loops.
- Full test matrix for every tiny docs/tool change.
- Prompts that say "world-class" without acceptance criteria.
- Prompts that ask for new features while engine/analyzer/persistence is unstable.
- Report language that claims "passed" when proof was actually blocked.

## Phase Usage Notes

### Final Report Template
```markdown
FILES CHANGED:

* ...

BEHAVIOR CHANGED:

* ...

VALIDATION:

* command: result

SKIPPED VALIDATIONS:

* validation: reason

KNOWN LIMITATIONS:

* ...

NEXT ACTION:
Human review. Do not start the next phase unless explicitly requested.
```

### Phase Acceptance Checklist
- Goal is narrow.
- Non-goals and forbidden systems are explicit.
- Implementation value is real.
- Validation matches touched surfaces.
- Next recommendation does not jump past failed proof.
