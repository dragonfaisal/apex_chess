---
name: apex-engine-safety
description: Use for Apex Chess work touching Stockfish, FFI, UCI, engine isolates, local engine substrate, scheduler execution, MultiPV collection, Android proof, or analyzer runtime engine boundaries.
---

# apex-engine-safety

## Trigger phrases

- Stockfish
- FFI
- UCI
- local engine
- engine substrate
- engine isolate
- scheduler
- MultiPV
- Android proof
- analyzer runtime
- engine lifecycle

## When to use

Use before changing engine services, native bridge code, UCI command parsing, engine lifecycle, scheduler orchestration, Android packaging, benchmark collectors, runtime analyzer input, or any real-engine activation path.

## When NOT to use

Do not use for UI-only changes, docs-only work, skills-only work, copy changes, or pure classifier tests that do not alter engine inputs or engine evidence.

## Instructions

1. Preserve fail-closed behavior for unsafe engine states.
2. Do not expose raw UCI, Stockfish commands, engine stdout/stderr, raw PV dumps, or private proof artifacts to product UI.
3. Validate FEN/PGN/UCI payload shape before any runtime analyzer input or scheduler execution.
4. Keep stub/fake evidence clearly separated from real Stockfish evidence.
5. Require focused parser/settings/lifecycle tests for engine code changes.
6. Require Android proof for native bridge, packaging, scheduler execution, lifecycle, thermal/battery, real-engine activation, or device-only behavior.
7. Engine inspection-only phases are allowed only once per substrate milestone.
8. Repeated inspection/preflight layers must be compressed into the next real engine implementation phase.
9. Keep subprocess fallback or disabled path explicit when lifecycle risk remains.

## Required output format

```markdown
ENGINE SURFACE:

SAFETY BOUNDARY:

RUNTIME INPUT IMPACT:

BLOCKED OUTPUTS:

FOCUSED TESTS:

ANDROID PROOF REQUIRED:
Yes/No - reason

FALLBACK OR FAIL-CLOSED PATH:

KNOWN ENGINE RISKS:
```
