/// Single source of truth for every per-ply "coach" explanation shown
/// in the UI.
///
/// Phase 20 addendum rules enforced here (and pinned by
/// `test/core/domain/services/coach_explanation_service_test.dart`):
///
///   * Never emit `Better: &lt;same SAN&gt;` — if the played move equals the
///     engine's top line (after castling-UCI normalisation) the
///     headline reads **Top engine choice.** and the better-line
///     subline is suppressed.
///   * A mate-delivering ply reads **Checkmate.**, never "Blunder"
///     — even when the mover is the opponent. The classifier upstream
///     already protects against this at the model level
///     (`MoveQuality.blunder` never fires on a mate-delivering ply per
///     `move_classifier.dart:313`), and this service mirrors the rule
///     at the copy layer so the user never reads a contradictory
///     headline.
///   * When the *previous* user ply is what allowed the mate, the
///     service emits `Allowed forced mate — defensive resources were
///     available earlier.` on that previous ply. The mate-delivering
///     ply itself stays "Checkmate."
///   * Quick-mode classifications that would otherwise read as
///     tentative (i.e. the classifier would have emitted
///     Brilliant / Great / Forced under Deep but `suppressTrophyTiers`
///     downgraded it) surface a **Deep scan recommended** flag. The
///     service never upgrades the tier itself — trustworthy
///     classification beats flashy badges.
///   * Opening-book plies render `&lt;ECO&gt; · &lt;Opening name&gt; — book
///     move.` with no severity judgement attached.
///
/// Keeping this as a pure service (no Flutter imports, no Riverpod)
/// means the exact same copy ships from:
///   * `ReviewScreen._CoachCard`
///   * `ReviewSummaryScreen` ("biggest mistake" / "best user move")
///   * the archive card tooltips
///   * the Live Play post-move feedback banner (Phase 20.3)
///
/// — with zero branch-by-caller drift.
library;

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/utils/move_explanation.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';

/// Input contract for [CoachExplanationService.explain].
///
/// Deliberately narrow: everything the service needs is either
/// already on the [MoveAnalysis] timeline or a small slice of game
/// metadata. No widgets, no theming, no Riverpod.
class CoachExplanationInput {
  const CoachExplanationInput({
    required this.move,
    required this.mode,
    this.previousUserMove,
    this.userIsWhite,
  });

  /// The ply to explain.
  final MoveAnalysis move;

  /// Analysis mode the timeline was produced under. Drives the
  /// "Needs Deep Scan" affordance and — for Quick-mode ambiguous
  /// plies — tones the headline down to a conservative phrasing.
  final AnalysisMode mode;

  /// The user's most recent own-ply immediately preceding [move]. Only
  /// used when [move] is the opponent delivering mate so the service
  /// can redirect blame to the ply that actually let the mate in.
  ///
  /// When the caller doesn't know which colour the user played (PGN
  /// paste without a side selector) this stays `null` and the service
  /// falls back to the generic "Checkmate." wording without a blame
  /// redirect.
  final MoveAnalysis? previousUserMove;

  /// `true` when the user played the White pieces in this game,
  /// `false` when Black, `null` when unknown (PGN paste without a
  /// side selector). Drives the "mover == user" check for the blame
  /// redirect rule.
  final bool? userIsWhite;
}

/// Structured explanation consumed by every coach-copy surface.
///
/// Fields are intentionally flat strings so the widget layer never
/// has to re-interpret classification into copy — the service did it
/// once, authoritatively.
class CoachExplanation {
  const CoachExplanation({
    required this.headline,
    required this.subline,
    this.betterMoveSan,
    this.betterMoveReason,
    this.needsDeepScan = false,
    this.blameRedirectToPreviousPly = false,
  });

  /// Primary line — e.g. `12. Qxh7+ — Brilliant`, `Checkmate.`,
  /// `Top engine choice.`, `Book move.`
  final String headline;

  /// Secondary sentence — e.g. the classifier's own `message`, or a
  /// `BetterMoveExplanation` sentence, or `Deep scan recommended —
  /// Quick mode can't verify this.`
  final String subline;

  /// Engine's top-line SAN when we decided to surface it. `null` when
  /// the played move *is* best (per addendum rule 4) or when the
  /// classification is Book / Forced / Brilliant / Great (suggesting
  /// a "better" move on those reads as a bug).
  final String? betterMoveSan;

  /// One-sentence rationale composed by [BetterMoveExplanation].
  /// `null` when [betterMoveSan] is `null`.
  final String? betterMoveReason;

  /// `true` when the current classification depends on uncertain
  /// Quick-mode eval and Deep analysis should re-verify it. The UI
  /// surfaces a "Needs Deep Scan" chip with a re-analyze CTA. The
  /// service never upgrades the classification tier itself.
  final bool needsDeepScan;

  /// `true` when the caller should render the `Allowed forced mate`
  /// copy on the *previous* user ply rather than on the opponent's
  /// mate-delivering ply. Only set when [CoachExplanationInput.move]
  /// is itself a mate-delivered ply *and* the opponent is the mover.
  final bool blameRedirectToPreviousPly;
}

/// Pure service — no IO, no Flutter.
class CoachExplanationService {
  const CoachExplanationService();

  /// Produce the coach copy for a single ply.
  CoachExplanation explain(CoachExplanationInput in_) {
    final m = in_.move;

    // ── Rule 1: Mate-delivered ply reads "Checkmate." regardless of
    // who delivered it. The classifier upstream never emits
    // MoveQuality.blunder on a mate-delivering ply (see
    // `move_classifier.dart:313`); we mirror that rule at the copy
    // layer so a stale cached timeline produced by an older brain
    // can't leak "Blunder — checkmate" into the UI.
    final isMateDelivery = _isMateDelivery(m);
    if (isMateDelivery) {
      final moverIsUser =
          in_.userIsWhite != null && m.isWhiteMove == in_.userIsWhite;
      final blameRedirect = !moverIsUser && in_.previousUserMove != null;
      return CoachExplanation(
        headline: 'Checkmate.',
        subline: moverIsUser
            ? 'You delivered mate. No legal reply.'
            : blameRedirect
            ? 'Opponent delivered mate. The allowing move was your '
                  'previous ply — look for defensive resources earlier.'
            : 'Mate on the board. No legal reply.',
        blameRedirectToPreviousPly: blameRedirect,
      );
    }

    // ── Rule 2: Book / Theory — surface ECO + opening name, no
    // severity judgement. Classifier sets `classification == book`
    // and `inBook == true` for recognised theory.
    if (m.classification == MoveQuality.book || m.inBook) {
      final eco = m.ecoCode;
      final name = m.openingName;
      final label = (eco != null && name != null)
          ? '$eco · $name'
          : (name ?? eco ?? 'Opening theory');
      return CoachExplanation(
        headline: 'Book move.',
        subline:
            '$label — in theory. No coach verdict while the game '
            'stays in book.',
      );
    }

    // ── Rule 3: "Allowed forced mate" — the current ply's
    // classification is Blunder *and* the classifier flagged it as
    // allowing mate (message starts with `Blunder — allows forced
    // mate.`). Render an explicit `Allowed forced mate` subline so
    // the user sees the *reason*, not just the tier.
    if (m.classification == MoveQuality.blunder &&
        m.message.toLowerCase().contains('allows forced mate')) {
      final moveNum = _moveNumberLabel(m.ply);
      return CoachExplanation(
        headline: '$moveNum ${m.san} — Blunder',
        subline:
            'Allowed forced mate. Defensive resources were '
            'available — look one ply earlier for the critical choice.',
        betterMoveSan: m.engineBestMoveSan,
        betterMoveReason: _composeBetterLineReason(m),
      );
    }

    // ── Rule 4: Played move equals engine's top line. Addendum rule
    // 4: never render `Better: <same SAN>`; the headline reads
    // `Top engine choice.` and we suppress the better-line subline.
    //
    // Phase 20.1 device feedback § 9: replace the generic
    // "matches Stockfish's #1 line" subline with concrete
    // tactic-aware copy a 600–900 player can act on.
    final playedEqualsBest = _playedEqualsBest(m);
    if (playedEqualsBest) {
      final moveNum = _moveNumberLabel(m.ply);
      final tier = _tierHeadline(m.classification);
      return CoachExplanation(
        headline: tier == null
            ? '$moveNum ${m.san} — Top engine choice'
            : '$moveNum ${m.san} — $tier',
        subline: _humanBestSubline(m),
      );
    }

    // ── Rule 5: Quick-mode "Needs Deep Scan" affordance. When the
    // classifier ran with `suppressTrophyTiers` the brain
    // deliberately avoids Brilliant / Great / Forced; anything that
    // landed as "best" despite a suspicious positional profile is a
    // candidate for a Deep re-scan. The UI surfaces an amber chip
    // with a re-analyze CTA — this service never promotes the tier
    // by itself.
    final needsDeepScan =
        in_.mode == AnalysisMode.quick && _looksLikeDeepScanCandidate(m);

    // ── Rule 6: General coach copy — tier headline + classifier
    // message + optional better line.
    final moveNum = _moveNumberLabel(m.ply);
    final tier = _tierHeadline(m.classification) ?? m.classification.label;
    final headline = '$moveNum ${m.san} — $tier';

    String subline = m.message.isNotEmpty
        ? m.message
        : _fallbackMessage(m.classification);

    // Phase 20.1 § 3: append "Opening phase — out of our book." for
    // early non-book plies so the user reads the move was evaluated
    // as a normal sideline, not theory.
    subline = _maybeAppendOpeningPhase(subline, m);

    if (needsDeepScan) {
      // Append, rather than replace — the user still sees the
      // tentative verdict but is told it's Quick-mode bounded.
      subline =
          '$subline Deep scan recommended — Quick mode can\'t '
          'verify trophy-tier reads.';
    }

    final shouldShowBetter = _shouldShowBetterLine(m);
    return CoachExplanation(
      headline: headline,
      subline: subline,
      betterMoveSan: shouldShowBetter ? m.engineBestMoveSan : null,
      betterMoveReason: shouldShowBetter ? _composeBetterLineReason(m) : null,
      needsDeepScan: needsDeepScan,
    );
  }

  // ── Predicates ──────────────────────────────────────────────────

  /// Mate has been delivered *by this ply* (not merely "mate-in-N on
  /// the board before the move"). We detect this via the post-move
  /// eval: `mateInAfter == 0` or `winPercentAfter ∈ {0, 100}` with
  /// the mover winning.
  static bool _isMateDelivery(MoveAnalysis m) {
    // Post-move mate signalling: analyzer writes `mateInAfter = 0`
    // when the played move *is* checkmate (terminal position).
    if (m.mateInAfter == 0) return true;
    // Fallback: the mover is at 100% win and the classification was
    // one that the classifier reserves for mate (brilliant / best)
    // with a score trail that screams terminal. Keep loose so an
    // older cached timeline without `mateInAfter=0` still qualifies.
    if (m.winPercentAfter >= 99.9 &&
        m.isWhiteMove &&
        m.classification == MoveQuality.best) {
      return m.message.toLowerCase().contains('mate') || m.san.endsWith('#');
    }
    if (m.winPercentAfter <= 0.1 &&
        !m.isWhiteMove &&
        m.classification == MoveQuality.best) {
      return m.message.toLowerCase().contains('mate') || m.san.endsWith('#');
    }
    // SAN `#` suffix is the canonical PGN marker for mate; honour it
    // even when the analyzer layer didn't surface a `mateInAfter=0`.
    return m.san.endsWith('#');
  }

  /// `true` when [played] equals [best] after castling-UCI
  /// normalisation. Matches the helper in `review_screen.dart:38` so
  /// both surfaces agree on the same rule.
  static bool _playedEqualsBest(MoveAnalysis m) {
    final best = m.engineBestMoveUci;
    final played = m.uci;
    if (best == null || played.isEmpty) return false;
    return normalizeCastlingUci(best) == normalizeCastlingUci(played);
  }

  /// Heuristic: a Quick-mode "best" classification on a ply that
  /// looks like it *could* have been Brilliant / Great / Forced under
  /// Deep. We never upgrade the tier here; we only flag the ply as a
  /// Deep-scan candidate so the UI can surface the chip.
  ///
  /// Signals:
  ///   * classification is `best` or `excellent` (Quick's ceiling
  ///     when trophy tiers are suppressed),
  ///   * `deltaW` is non-trivially positive (the move gained Win%)
  ///     OR the SAN has a capture / check marker (`x` / `+`),
  ///   * the move is *not* the opening's first 8 plies (Book path).
  static bool _looksLikeDeepScanCandidate(MoveAnalysis m) {
    if (m.classification != MoveQuality.best &&
        m.classification != MoveQuality.excellent) {
      return false;
    }
    if (m.inBook) return false;
    if (m.openingStatus == OpeningStatus.bookTheory) return false;
    if (m.ply < 8) return false;
    final sanLooksTactical =
        m.san.contains('x') || m.san.contains('+') || m.san.contains('=');
    if (!sanLooksTactical) return false;
    // Non-trivial Win% gain signals "something happened" beyond a
    // quiet positional move. A pure quiet Best doesn't need Deep.
    if (m.deltaW < -2.0) return false;
    return true;
  }

  /// Whether to surface a `Better: <SAN>` subline. Suppressed when:
  ///   * the classifier said the played move *was* the engine's #1,
  ///   * classification is Book / Brilliant / Great / Forced / Best
  ///     (surfacing a "better" line on these reads as a bug),
  ///   * the engine never offered a top line (`engineBestMoveSan`
  ///     is `null`).
  static bool _shouldShowBetterLine(MoveAnalysis m) {
    if (m.engineBestMoveSan == null) return false;
    if (_playedEqualsBest(m)) return false;
    switch (m.classification) {
      case MoveQuality.book:
      case MoveQuality.brilliant:
      case MoveQuality.great:
      case MoveQuality.best:
      case MoveQuality.forced:
        return false;
      case MoveQuality.excellent:
      case MoveQuality.good:
      case MoveQuality.inaccuracy:
      case MoveQuality.mistake:
      case MoveQuality.missedWin:
      case MoveQuality.blunder:
        return true;
    }
  }

  // ── Copy composers ──────────────────────────────────────────────

  static String _moveNumberLabel(int ply) =>
      '${(ply ~/ 2) + 1}${ply.isEven ? '.' : '…'}';

  /// Short tier headline (without SAN prefix). `null` for tiers that
  /// don't need a badge-style headline beyond the classification's
  /// own [MoveQuality.label].
  static String? _tierHeadline(MoveQuality q) {
    switch (q) {
      case MoveQuality.brilliant:
        return 'Brilliant';
      case MoveQuality.great:
        return 'Great find';
      case MoveQuality.best:
        return 'Best';
      case MoveQuality.excellent:
        return 'Excellent';
      case MoveQuality.good:
        return 'Solid';
      case MoveQuality.inaccuracy:
        return 'Inaccuracy';
      case MoveQuality.mistake:
        return 'Mistake';
      case MoveQuality.blunder:
        return 'Blunder';
      case MoveQuality.forced:
        return 'Forced';
      case MoveQuality.missedWin:
        return 'Missed win';
      case MoveQuality.book:
        return null;
    }
  }

  /// When the classifier didn't write a `message` we still want a
  /// humane subline. Keeps parity with the previous inline fallbacks.
  static String _fallbackMessage(MoveQuality q) {
    switch (q) {
      case MoveQuality.brilliant:
        return 'A rare tactical resource — near-best with a sacrifice.';
      case MoveQuality.great:
        return 'Only this move holds the advantage.';
      case MoveQuality.best:
        return 'Stockfish\'s top choice.';
      case MoveQuality.excellent:
        return 'Close to the engine\'s top line.';
      case MoveQuality.good:
        return 'Solid — no significant Win% loss.';
      case MoveQuality.inaccuracy:
        return 'Slight drift from the best continuation.';
      case MoveQuality.mistake:
        return 'Noticeable Win% loss — a stronger plan was available.';
      case MoveQuality.missedWin:
        return 'You were winning; this gave up the advantage.';
      case MoveQuality.blunder:
        return 'Decisive Win% loss.';
      case MoveQuality.forced:
        return 'Only move — any other loses.';
      case MoveQuality.book:
        return 'Opening theory.';
    }
  }

  static String? _composeBetterLineReason(MoveAnalysis m) {
    final exp = BetterMoveExplanation.compose(
      bestMoveUci: m.engineBestMoveUci,
      bestMoveSan: m.engineBestMoveSan,
      playedQuality: m.classification,
    );
    return exp?.sentence;
  }

  /// Concrete tactic-aware copy for "played == engine's top line".
  /// Rotates through SAN markers (#, +, x, O-O, =) so the user reads
  /// what the move *did* on the board instead of meaningless engine
  /// jargon. Falls back to phase-aware phrasing for quiet moves.
  ///
  /// All copy is calibrated for a 600–900 Elo audience: no "Stockfish",
  /// no "PV1", no centipawn talk.
  static String _humanBestSubline(MoveAnalysis m) {
    final san = m.san;

    // Phase 20.1 § 3: opening phase fallback for early non-book plies.
    // We surface this even when the move is "Best" so the user can
    // tell a sideline from real theory without a confusing badge.
    final isOpeningPhase =
        m.openingStatus == OpeningStatus.openingPhaseUnknown ||
        m.openingStatus == OpeningStatus.bookDeviation ||
        (m.ply < 8 && !m.inBook);

    if (san.endsWith('#')) {
      return 'Checkmate — clean finish.';
    }
    if (san.contains('=') && (san.contains('=Q') || san.contains('=R'))) {
      return san.endsWith('+')
          ? 'Promotes with check — decisive.'
          : 'Promotes the pawn — decisive material gain.';
    }
    if (san.startsWith('O-O-O')) {
      return san.endsWith('+')
          ? 'Castles long with check — king safe, rook active.'
          : 'Castles long — king tucked away, rook activated.';
    }
    if (san.startsWith('O-O')) {
      return san.endsWith('+')
          ? 'Castles short with check — king safe, attack continues.'
          : 'Castles short — king to safety, rook joins the game.';
    }
    if (san.contains('x') && san.endsWith('+')) {
      return 'Captures with check — wins material and keeps the '
          'initiative.';
    }
    if (san.contains('x')) {
      return 'Captures cleanly — picks up material with no good reply.';
    }
    if (san.endsWith('+')) {
      return 'Forcing check — pressures the king and limits replies.';
    }
    if (isOpeningPhase) {
      return 'Sound opening move — develops a piece and keeps the '
          'centre flexible. (Opening phase, out of our book.)';
    }
    // Quiet positional best — derive a hint from the post-move Win%.
    // High mover Win% → improving a winning position; near 50 → keeps
    // the balance.
    final w = m.isWhiteMove ? m.winPercentAfter : 100.0 - m.winPercentAfter;
    if (w >= 75) {
      return 'Keeps your advantage — improves a piece without giving '
          'the opponent counterplay.';
    }
    if (w <= 25) {
      return 'Best defensive try — limits damage and waits for chances.';
    }
    return 'Solid choice — improves piece activity and keeps the '
        'position balanced.';
  }

  /// Append "Opening phase" caveat to the subline when the ply is in
  /// the early game but not in our ECO book. Keeps coaching honest:
  /// the classifier evaluated a normal sideline, not theory.
  static String _maybeAppendOpeningPhase(String subline, MoveAnalysis m) {
    if (m.inBook || m.openingStatus == OpeningStatus.bookTheory) {
      return subline;
    }
    if (subline.toLowerCase().contains('opening phase')) return subline;
    if (m.openingStatus == OpeningStatus.bookDeviation) {
      return '$subline (Opening phase — book deviation.)';
    }
    if (m.openingStatus == OpeningStatus.notOpening && m.ply >= 8) {
      return subline;
    }
    return '$subline (Opening phase — out of our book.)';
  }
}
