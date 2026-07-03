# Apex Chess Prompt Library

## Purpose
This document stores reusable prompt blocks for future Apex Chess phases. Use these as building blocks, not as full prompts copied blindly.

## Current Canon

### Engine Safety Paragraph
Touch engine systems only within explicit scope. Preserve fail-closed behavior. Do not expose raw UCI, PV dumps, Stockfish commands, or private proof artifacts to product UI. Validate FEN/PGN/UCI payload shape before runtime analyzer input or scheduler execution. Require Android proof for Stockfish, FFI, native bridge, engine isolate, local engine substrate, or device-only behavior.

### Classifier Safety Paragraph
Do not retune classifier or engine math unless scoped. Do not allow classifier output unless input perspective, before/after eval evidence, best-line evidence, and saved-analysis consistency are proven. Brilliant/Great/Miss/Book/Blunder changes require focused classifier tests and must preserve strict public-label rules.

### UI Canon Paragraph
Preserve Apex UI identity: deep dark navy, electric blue/cyan accents, Material 3 inspired, fast, clean, premium, beginner-friendly. Do not redesign UI identity unless scoped. Badge/icon changes require inspecting current implementation first. No fake hype words, no raw debug output, no text overlap, no board-blocking panels.

### Anti-Loop Paragraph
Maximum quality, minimum rotation. A phase is invalid if it is only diagnostic, preflight, readiness, activation-candidate, or report work without implementation value or direct protection of a touched runtime/product system. Diagnostics belong inside implementation phases.

### Validation Policy Paragraph
Run focused validation for touched systems. Full validation is for risky shared surfaces, not every docs/tool change. Android proof is required for native engine, FFI, packaging, and device-only UI behavior. Classifier tests are required for label logic. Persistence/saved-analysis changes require reopen and consistency tests.

### Forbidden Systems Template
```markdown
FORBIDDEN SYSTEMS:

* No PGN input unless scoped
* No imported games unless scoped
* No move list input unless scoped
* No classifier labels unless scoped
* No Brilliant/Great/Miss/Best/Blunder unless scoped
* No Win%, CP-loss, accuracy, or ACPL unless scoped
* No analyzer runtime wiring unless scoped
* No scheduler execution unless scoped
* No persistence/cache/database writes unless scoped
* No saved analysis integration unless scoped
* No product UI unless scoped
* No backend/API work unless scoped
* No broad refactor
```

### Phase Scope Template
```markdown
PHASE NAME:

GOAL:

PRODUCT/RUNTIME VALUE:

NON-GOALS:

ALLOWED FILES/SYSTEMS:

FORBIDDEN FILES/SYSTEMS:

IMPLEMENTATION REQUIREMENTS:

GUARDRAILS:

FOCUSED VALIDATION:

FULL VALIDATION TRIGGER:

ANDROID MANUAL VERIFICATION TRIGGER:

FINAL REPORT FORMAT:

NEXT PHASE RULE:
Human review before starting the next phase.
```

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
Human review. Do not start the next phase yet.
```

### Commit Review Checklist
- Run `git status --short`.
- Run `git diff --check`.
- Confirm changed/untracked files match requested scope.
- Stop if unrelated files appear.
- Stage only requested files.
- Commit only if explicitly requested.
- Do not tag unless explicitly requested.

## Historical Prompts - Do Not Reuse Directly
- "Any sacrifice is Brilliant": obsolete; violates classifier canon.
- "Use Lichess cloud eval as the only engine": obsolete; public APIs are enrichment, not core dependency.
- "Preflight/readiness candidate phases": historical loop pattern; compress into real implementation phases.
- "Fake AI coach" copy: obsolete; Academy must be grounded in real recurring mistakes.

## Rules
- Reuse paragraphs selectively.
- Add concrete acceptance criteria before implementation.
- Preserve forbidden systems for narrow phases.
- Keep prompt blocks updated when canon changes.

## Forbidden Regressions
- Copying obsolete prompts as active instructions.
- Broad prompts with no acceptance criteria.
- Validation requirements unrelated to touched systems.
- Prompting for product labels before evidence layers exist.

## Phase Usage Notes
- Use this library when drafting future phase prompts.
- Always pair a reusable paragraph with the phase-specific allowed systems, forbidden systems, and validation policy.
