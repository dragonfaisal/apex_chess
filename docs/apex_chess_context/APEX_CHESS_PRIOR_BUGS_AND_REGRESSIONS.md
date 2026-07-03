# Apex Chess Prior Bugs and Regressions

## Purpose
This document records durable lessons from known bugs and regressions so future agents do not repeat them.

## Current Canon

### Stub Engine / Fake 0.0 Eval
- Cause: fake/stub engine path or failed engine load returned neutral scores.
- Danger: every move looked excellent; classifier and user trust collapsed.
- Prevention: real engine proof, fail-closed errors, no constant score fallback.
- Related systems: Stockfish, FFI, UCI, analyzer, classifier.

### First Move Crash
- Cause: empty or malformed FEN reaching engine/parser paths.
- Danger: crash at the start of analysis and broken first review experience.
- Prevention: validate FEN shape before engine commands.
- Related systems: PGN parsing, FEN generation, engine input.

### Stats Crash
- Cause: null/empty/corrupt stats or archive state not handled.
- Danger: dashboard crash after import or wipe.
- Prevention: empty-state safe stats, nullable guards, no assumptions about archive readiness.
- Related systems: Stats, Archive, repository reads, UI.

### FEN Empty Path
- Cause: empty string or missing FEN treated as playable.
- Danger: native crashes, fake evals, invalid timelines.
- Prevention: fail closed on missing FEN; never send empty FEN to engine.
- Related systems: analyzer input, local engine, adapters.

### UCI Parsing Issues
- Cause: raw lines interpreted ad hoc or cp/mate/bestmove conflated.
- Danger: wrong scores, wrong mate behavior, invalid labels.
- Prevention: typed parser/events, structured raw eval contracts, sanitized previews.
- Related systems: UCI parser, local eval, raw eval bridge.

### Wrong Score Perspective
- Cause: raw side-to-move score used as White/Black/player score.
- Danger: Black analysis inverted; false Blunders and Brilliants.
- Prevention: explicit side-to-move extraction and White/Black/player perspective fields.
- Related systems: raw eval, normalizer, analyzer, classifier.

### Brilliant Over-Triggering
- Cause: any sacrifice or material deficit treated as Brilliant.
- Danger: label inflation and wrong coaching.
- Prevention: strict sacrifice, near-best, not trivial, not already winning, deep verification.
- Related systems: classifier, MultiPV, Golden suite.

### Castling Overlay Issues
- Cause: marker attached to rook square instead of king destination.
- Danger: confusing board feedback.
- Prevention: castling marker tests for g1/c1/g8/c8.
- Related systems: board overlay, move rendering.

### Saved Analysis Mismatch
- Cause: stale aggregate counts or database snapshots diverged from timeline.
- Danger: archive shows labels the review does not contain.
- Prevention: derive counts from saved timeline; version saved analysis.
- Related systems: Archive, saved analysis, Review, Stats.

### Book Phase Problems
- Cause: opening moves classified with middlegame/tactical logic.
- Danger: Book lines shown as Brilliant/Blunder without context.
- Prevention: opening/book layer before classifier; severe exceptions require engine proof.
- Related systems: ECO/book, classifier, review.

### Move List Blocking Board
- Cause: layout crowded product controls over board.
- Danger: review screen becomes unusable.
- Prevention: responsive constraints and Android visual checks.
- Related systems: Review UI, board, timeline.

### Login Switching Hang
- Cause: account/import state not reset cleanly.
- Danger: user stuck switching accounts or importing games.
- Prevention: cancellable import flows, clear loading state, timeout and reset paths.
- Related systems: account, import, repository, UI.

### Import PGN Mode Issues
- Cause: PGN/import mode confused with source import or bad parser state.
- Danger: wrong source, failed review, broken archive identity.
- Prevention: explicit input type/source models, validation, canonical keys.
- Related systems: Import, Archive, Review contract.

### Fast / Deep Toggle Expectations
- Cause: user-facing modes not aligned with actual analysis strength.
- Danger: Fast mode appears to provide Deep confidence.
- Prevention: explicit mode labels, Deep-only gates, saved analysis mode metadata.
- Related systems: Review, classifier, archive, UI.

## Rules
- Every resolved bug category must become a test, guardrail, or documented fail-closed behavior.
- If a bug touches saved analysis, verify reopen consistency.
- If a bug touches engine/native behavior, require Android proof.
- If a bug touches labels, require classifier tests.

## Forbidden Regressions
- Silent fake eval.
- UI crash on empty or null state.
- Wrong-side score math.
- Label mismatch between archive and timeline.
- Book moves receiving unsupported tactical labels.
- Import/account flows hanging without escape.

## Phase Usage Notes
- Use this file during bugfix planning and review.
- Each bugfix phase should state which prior regression category it protects.
- Do not create diagnostic-only phases for known bugs; fix and validate in the same phase.
