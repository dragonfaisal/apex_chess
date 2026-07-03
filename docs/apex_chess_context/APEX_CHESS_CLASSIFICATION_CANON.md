# Apex Chess Classification Canon

## Purpose
This document defines Apex Chess move-label doctrine. It protects public classification identity and prevents false-positive Brilliant, Great, Miss, and Blunder behavior.

## Current Canon

### Public Classification Set
Do not invent new public labels without explicit product approval.

- Brilliant
- Great
- Best
- Excellent
- Good
- Book
- Inaccuracy
- Mistake
- Miss
- Blunder
- Checkmate

### Internal-Only Concepts
These can exist internally but should not become noisy public labels by default:

- forced
- onlyMove
- candidateBrilliant
- candidateGreat
- needsDeepReview
- rawScore
- rawDelta
- verificationPending

### Brilliant
Brilliant is rare and meaningful. It is not "a good move." It requires:

- real sacrifice or meaningful material/positional concession,
- near-best or best engine evidence,
- not a trivial recapture,
- not an obvious forced move,
- not already winning so easily that the sacrifice is irrelevant,
- not leading to a bad or losing position,
- correct ply attachment to the sacrifice, not the later consolidation,
- Deep Review verification, including alternative-line evidence.

Never mark trivial recaptures, obvious moves, simple mates, already-winning conversions, fake sacrifices, or shallow Fast Review candidates as Brilliant.

### Great / Only Move Behavior
- Great is for critical moves, narrow defensive resources, or very strong engine moves that materially change the game.
- Only-move behavior requires MultiPV evidence proving alternatives fail.
- "Only Move" should not become noisy public copy unless explicitly scoped.

### Best / Excellent / Good
- Best means played move matches the strongest engine line or is effectively tied within tolerance.
- Excellent and Good are positive labels for small or no practical loss.
- They still require correct before/after score and perspective handling.

### Book / Theory
- Book moves are opening-theory moves.
- Book classification suppresses normal tactical labels unless engine evidence shows a severe tactical problem.
- Book status must be consistent across review, archive, and stats.

### Miss / Missed Win / Missed Mate
- Miss is a missed opportunity.
- Missed Win requires before-position evidence that a clearly winning move existed.
- Missed Mate requires mate-line evidence.
- Both require alternative move comparison and cannot be inferred from one raw eval.

### Inaccuracy / Mistake / Blunder
- These reflect increasing loss of the mover/player expected outcome.
- They require before/after evaluation and correct player/mover perspective.
- Mate against the mover is always severe regardless of centipawn noise.

### Checkmate
- Checkmate is a terminal game result marker, not a generic "best move" replacement.
- Mate scores and board mate state must not be confused.

### Fast Review Limitations
- Fast Review may show provisional or conservative labels.
- Fast Review must not finalize Brilliant, Great, Missed Win, or Missed Mate without deep verification.

### Deep Review Verification Requirements
- MultiPV for Great/Only Move/Miss/Brilliant candidates.
- Higher depth or backend proof for tactical labels.
- Saved timeline consistency after labels are committed.

## Rules
- Classifier output is allowed only when input perspective, best-line evidence, before/after evaluation, and saved-analysis consistency are proven.
- Public label decisions must be deterministic and testable.
- Classifier math must not be retuned casually.
- Internal labels must not leak into product UI as noisy public labels.

## Forbidden Regressions
- Any sacrifice equals Brilliant.
- Brilliant attached to opponent recapture or later consolidation.
- Brilliant while already trivially winning.
- Fast Review finalizing deep-only labels.
- Book moves classified like middlegame tactics without a severe engine reason.
- Missed Win or Great without alternative-line evidence.
- Black-side perspective inverted into false Blunder/Brilliant.
- Saved archive counts disagreeing with timeline labels.

## Phase Usage Notes
- Use this file for classifier, label display, saved-label migration, and Golden suite phases.
- Required validation: focused classifier tests for touched labels, saved-analysis consistency tests when persistence/display changes, and deep verification tests for Brilliant/Great/Miss logic.
