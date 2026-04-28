/// Pre-computed per-game summary — the data contract consumed by
/// [ReviewSummaryScreen] (Phase 20.1 § 3).
///
/// Computed once from an [AnalysisTimeline] + the user's known
/// colour. All numbers shown on the summary screen derive from this
/// structure so the UI can't silently invent "fake" statistics
/// (addendum to Phase 20 § 1: "Every number shown in UI must come
/// from a real data source.").
library;

import 'dart:math' as math;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

/// Which third of the game a ply belongs to. Boundaries match the
/// rest-of-app convention (archive card, phase-perf widget):
///   * opening    → plies  0 … 19  (first 10 full moves)
///   * middlegame → plies 20 … 59  (moves 11 … 30)
///   * endgame    → plies 60+
enum GamePhase { opening, middlegame, endgame }

/// Aggregated quality counts per classification, populated from the
/// timeline (never from a stale `qualityCounts` field on the archive
/// record — Phase A audit § 4 flagged drift between the two).
///
/// Phase 20.1 device feedback § 4: also exposes per-side splits so
/// the summary screen can render YOU / OPPONENT columns. The legacy
/// totals are still available for callers that don't care about the
/// split (archive card, etc.).
class ReviewCounts {
  const ReviewCounts({
    required this.best,
    required this.excellent,
    required this.good,
    required this.book,
    required this.inaccuracy,
    required this.mistake,
    required this.blunder,
    required this.missedWin,
    required this.brilliant,
    required this.great,
    required this.forced,
    this.user = const ReviewCountsByTier.empty(),
    this.opponent = const ReviewCountsByTier.empty(),
  });

  final int best;
  final int excellent;
  final int good;
  final int book;
  final int inaccuracy;
  final int mistake;
  final int blunder;
  final int missedWin;
  final int brilliant;
  final int great;
  final int forced;

  /// User-side counts (rendered in the YOU column on the summary).
  /// Empty when [ReviewSummary.userIsWhite] is `null`.
  final ReviewCountsByTier user;

  /// Opponent-side counts (rendered in the OPPONENT column).
  final ReviewCountsByTier opponent;

  int get totalClassified =>
      best +
      excellent +
      good +
      book +
      inaccuracy +
      mistake +
      blunder +
      missedWin +
      brilliant +
      great +
      forced;
}

/// Per-tier classification counts for a single side. Used by the
/// per-player split on the summary screen. The legacy [ReviewCounts]
/// totals (`best`, `mistake`, …) are kept for backwards compatibility
/// with any callers that read them directly.
class ReviewCountsByTier {
  const ReviewCountsByTier({
    required this.best,
    required this.excellent,
    required this.good,
    required this.book,
    required this.inaccuracy,
    required this.mistake,
    required this.blunder,
    required this.missedWin,
    required this.brilliant,
    required this.great,
    required this.forced,
  });

  const ReviewCountsByTier.empty()
      : best = 0,
        excellent = 0,
        good = 0,
        book = 0,
        inaccuracy = 0,
        mistake = 0,
        blunder = 0,
        missedWin = 0,
        brilliant = 0,
        great = 0,
        forced = 0;

  final int best;
  final int excellent;
  final int good;
  final int book;
  final int inaccuracy;
  final int mistake;
  final int blunder;
  final int missedWin;
  final int brilliant;
  final int great;
  final int forced;

  int forTier(MoveQuality q) {
    switch (q) {
      case MoveQuality.best:
        return best;
      case MoveQuality.excellent:
        return excellent;
      case MoveQuality.good:
        return good;
      case MoveQuality.book:
        return book;
      case MoveQuality.inaccuracy:
        return inaccuracy;
      case MoveQuality.mistake:
        return mistake;
      case MoveQuality.blunder:
        return blunder;
      case MoveQuality.missedWin:
        return missedWin;
      case MoveQuality.brilliant:
        return brilliant;
      case MoveQuality.great:
        return great;
      case MoveQuality.forced:
        return forced;
    }
  }

  int get total =>
      best +
      excellent +
      good +
      book +
      inaccuracy +
      mistake +
      blunder +
      missedWin +
      brilliant +
      great +
      forced;
}

/// Per-phase accuracy + cp-loss split. Used by the summary screen's
/// "Game phase weakness" module to call out whichever segment of the
/// user's game was weakest.
class PhaseBreakdown {
  const PhaseBreakdown({
    required this.phase,
    required this.plies,
    required this.averageCpLoss,
    required this.accuracyPct,
  });

  final GamePhase phase;
  final int plies;
  final double averageCpLoss;
  final double accuracyPct;
}

/// Snapshot of the key ply types called out on the summary screen.
/// `null` fields mean "no ply of this kind in this game" — the UI
/// should render a neutral placeholder rather than a zero value.
class ReviewHighlights {
  const ReviewHighlights({
    this.keyTurningPoint,
    this.biggestMistake,
    this.bestUserMove,
  });

  /// Ply where the user-perspective Win% swing was largest in
  /// absolute value (positive or negative). Useful as "the moment
  /// the game was decided".
  final MoveAnalysis? keyTurningPoint;

  /// The user's worst ply (most negative deltaW from user POV).
  final MoveAnalysis? biggestMistake;

  /// The user's best ply (most positive deltaW from user POV). When
  /// a Brilliant / Great exists, prefer that over raw deltaW.
  final MoveAnalysis? bestUserMove;
}

/// The full summary payload. Cheap to compute (≤ O(N) over the
/// timeline) so we recompute on every push rather than persisting.
class ReviewSummary {
  const ReviewSummary({
    required this.userAccuracyPct,
    required this.opponentAccuracyPct,
    required this.userAverageCpLoss,
    required this.opponentAverageCpLoss,
    required this.counts,
    required this.phases,
    required this.highlights,
    required this.result,
    required this.openingLabel,
    required this.totalPlies,
    required this.userIsWhite,
  });

  /// Lichess-style game accuracy for the user's plies (0–100).
  final double userAccuracyPct;

  /// Lichess-style game accuracy for the opponent's plies (0–100).
  final double opponentAccuracyPct;

  /// Mean centipawn loss across the user's plies.
  final double userAverageCpLoss;

  /// Mean centipawn loss across the opponent's plies.
  final double opponentAverageCpLoss;

  /// Counts for every classification tier (timeline-derived).
  final ReviewCounts counts;

  /// Per-phase breakdown for the user's plies.
  final List<PhaseBreakdown> phases;

  final ReviewHighlights highlights;

  /// PGN result tag (`1-0`, `0-1`, `1/2-1/2`, `*`). `null` when
  /// missing from headers.
  final String? result;

  /// `"B90 · Sicilian Defense: Najdorf"` when an ECO entry matched,
  /// else the raw opening name, else `null`.
  final String? openingLabel;

  final int totalPlies;

  /// User's colour — `null` when unknown (PGN paste without a side
  /// selector). The summary screen renders a "colour unknown"
  /// variant in that case.
  final bool? userIsWhite;

  /// Weakest phase by average cp-loss. `null` when the user played
  /// no plies at all (empty timeline).
  PhaseBreakdown? get weakestPhase {
    if (phases.isEmpty) return null;
    final nonEmpty = phases.where((p) => p.plies > 0).toList();
    if (nonEmpty.isEmpty) return null;
    nonEmpty.sort((a, b) => b.averageCpLoss.compareTo(a.averageCpLoss));
    return nonEmpty.first;
  }
}

/// Pure service — produces a [ReviewSummary] from an
/// [AnalysisTimeline] and the user's colour.
class ReviewSummaryService {
  const ReviewSummaryService();

  ReviewSummary compute({
    required AnalysisTimeline timeline,
    required bool? userIsWhite,
  }) {
    final moves = timeline.moves;
    final counts = _counts(moves, userIsWhite: userIsWhite);

    // Per-colour cp-loss splits were added in Phase A (analysis_timeline.dart).
    final whiteCpLoss = timeline.averageCpLossWhite;
    final blackCpLoss = timeline.averageCpLossBlack;

    final userCpLoss = switch (userIsWhite) {
      true => whiteCpLoss,
      false => blackCpLoss,
      null => (whiteCpLoss + blackCpLoss) / 2,
    };
    final oppCpLoss = switch (userIsWhite) {
      true => blackCpLoss,
      false => whiteCpLoss,
      null => (whiteCpLoss + blackCpLoss) / 2,
    };

    // Accuracy uses per-move Win% loss, Lichess-style. See
    // [_moveAccuracyPct] for the formula.
    final userAccuracy = _gameAccuracy(moves, userIsWhite: userIsWhite);
    final oppAccuracy = _gameAccuracy(moves,
        userIsWhite: userIsWhite == null ? null : !userIsWhite);

    final phases = _phaseBreakdown(moves, userIsWhite: userIsWhite);
    final highlights = _highlights(moves, userIsWhite: userIsWhite);

    return ReviewSummary(
      userAccuracyPct: userAccuracy,
      opponentAccuracyPct: oppAccuracy,
      userAverageCpLoss: userCpLoss,
      opponentAverageCpLoss: oppCpLoss,
      counts: counts,
      phases: phases,
      highlights: highlights,
      result: timeline.headers['Result'],
      openingLabel: _openingLabel(timeline),
      totalPlies: moves.length,
      userIsWhite: userIsWhite,
    );
  }

  // ── Counts ──────────────────────────────────────────────────────

  static ReviewCounts _counts(
    List<MoveAnalysis> moves, {
    required bool? userIsWhite,
  }) {
    final tot = _MutableTier();
    final user = _MutableTier();
    final opp = _MutableTier();

    for (final m in moves) {
      tot.bump(m.classification);
      if (userIsWhite == null) continue;
      if (m.isWhiteMove == userIsWhite) {
        user.bump(m.classification);
      } else {
        opp.bump(m.classification);
      }
    }

    return ReviewCounts(
      best: tot.best,
      excellent: tot.excellent,
      good: tot.good,
      book: tot.book,
      inaccuracy: tot.inaccuracy,
      mistake: tot.mistake,
      blunder: tot.blunder,
      missedWin: tot.missedWin,
      brilliant: tot.brilliant,
      great: tot.great,
      forced: tot.forced,
      user: user.toCounts(),
      opponent: opp.toCounts(),
    );
  }

  // ── Accuracy ────────────────────────────────────────────────────

  /// Lichess-style per-move accuracy. Published at
  /// https://lichess.org/page/accuracy as:
  ///
  ///   accuracy% = 103.1668 · exp(-0.04354 · winPctDelta) - 3.1669
  ///
  /// where `winPctDelta = max(0, winBefore_moverPOV - winAfter_moverPOV)`.
  /// Clamped to `[0, 100]` so extreme swings don't push the value
  /// negative.
  static double _moveAccuracyPct(MoveAnalysis m) {
    // `deltaW` on MoveAnalysis is **signed mover-POV** — positive
    // means the move helped the mover, negative means it hurt. The
    // Lichess formula only cares about the magnitude of the loss, so
    // we clamp at zero.
    final loss = m.deltaW < 0 ? -m.deltaW : 0.0;
    final raw = 103.1668 * math.exp(-0.04354 * loss) - 3.1669;
    return raw.clamp(0.0, 100.0);
  }

  /// Game-level accuracy: arithmetic mean over the specified side's
  /// per-ply accuracy. Lichess uses a volatility-weighted harmonic
  /// mean; we stick with a simpler arithmetic mean here because the
  /// spec (§ 3 bullet 4) asks for "user accuracy %", not Lichess's
  /// proprietary blend. When [userIsWhite] is `null` we average
  /// every ply — the summary screen will render a "Colour unknown"
  /// caveat rather than two distinct rows.
  static double _gameAccuracy(
    List<MoveAnalysis> moves, {
    required bool? userIsWhite,
  }) {
    final relevant = userIsWhite == null
        ? moves
        : moves.where((m) => m.isWhiteMove == userIsWhite).toList();
    if (relevant.isEmpty) return 0;
    double total = 0;
    for (final m in relevant) {
      total += _moveAccuracyPct(m);
    }
    return total / relevant.length;
  }

  // ── Phases ──────────────────────────────────────────────────────

  static List<PhaseBreakdown> _phaseBreakdown(
    List<MoveAnalysis> moves, {
    required bool? userIsWhite,
  }) {
    int openP = 0, midP = 0, endP = 0;
    double openL = 0, midL = 0, endL = 0;
    double openAcc = 0, midAcc = 0, endAcc = 0;

    for (final m in moves) {
      if (userIsWhite != null && m.isWhiteMove != userIsWhite) continue;
      final phase = _phaseForPly(m.ply);
      final loss = m.deltaW < 0 ? -m.deltaW : 0.0;
      final acc = _moveAccuracyPct(m);
      switch (phase) {
        case GamePhase.opening:
          openP++;
          openL += loss;
          openAcc += acc;
        case GamePhase.middlegame:
          midP++;
          midL += loss;
          midAcc += acc;
        case GamePhase.endgame:
          endP++;
          endL += loss;
          endAcc += acc;
      }
    }

    return [
      PhaseBreakdown(
        phase: GamePhase.opening,
        plies: openP,
        averageCpLoss: openP == 0 ? 0 : openL / openP,
        accuracyPct: openP == 0 ? 0 : openAcc / openP,
      ),
      PhaseBreakdown(
        phase: GamePhase.middlegame,
        plies: midP,
        averageCpLoss: midP == 0 ? 0 : midL / midP,
        accuracyPct: midP == 0 ? 0 : midAcc / midP,
      ),
      PhaseBreakdown(
        phase: GamePhase.endgame,
        plies: endP,
        averageCpLoss: endP == 0 ? 0 : endL / endP,
        accuracyPct: endP == 0 ? 0 : endAcc / endP,
      ),
    ];
  }

  static GamePhase _phaseForPly(int ply) {
    if (ply < 20) return GamePhase.opening;
    if (ply < 60) return GamePhase.middlegame;
    return GamePhase.endgame;
  }

  // ── Highlights ──────────────────────────────────────────────────

  static ReviewHighlights _highlights(
    List<MoveAnalysis> moves, {
    required bool? userIsWhite,
  }) {
    if (moves.isEmpty) return const ReviewHighlights();

    MoveAnalysis? turning;
    double turningAbs = -1;
    MoveAnalysis? worst;
    double worstLoss = -1;
    MoveAnalysis? best;
    double bestGain = -double.infinity;
    MoveAnalysis? brilliantOrGreat;

    for (final m in moves) {
      if (userIsWhite != null && m.isWhiteMove != userIsWhite) continue;

      final abs = m.deltaW.abs();
      if (abs > turningAbs) {
        turningAbs = abs;
        turning = m;
      }

      final loss = -m.deltaW; // positive when ply hurt the user
      if (loss > worstLoss) {
        worstLoss = loss;
        worst = m;
      }

      if (m.deltaW > bestGain) {
        bestGain = m.deltaW;
        best = m;
      }

      if (m.classification == MoveQuality.brilliant ||
          m.classification == MoveQuality.great) {
        brilliantOrGreat ??= m;
      }
    }

    return ReviewHighlights(
      keyTurningPoint: turning,
      biggestMistake: (worst != null && worstLoss > 0) ? worst : null,
      // Prefer a Brilliant/Great when one exists — the spec calls this
      // out as "Best move by user".
      bestUserMove: brilliantOrGreat ?? best,
    );
  }

  // ── Opening label ───────────────────────────────────────────────

  static String? _openingLabel(AnalysisTimeline timeline) {
    String? eco;
    String? name;
    for (final m in timeline.moves) {
      eco ??= m.ecoCode;
      name ??= m.openingName;
      if (eco != null && name != null) break;
    }
    eco ??= timeline.headers['ECO'];
    name ??= timeline.headers['Opening'];
    if (eco != null && name != null) return '$eco · $name';
    return name ?? eco;
  }
}

/// Internal mutable counter — keeps `_counts` readable without
/// allocating an entire [ReviewCountsByTier] per increment.
class _MutableTier {
  int best = 0;
  int excellent = 0;
  int good = 0;
  int book = 0;
  int inaccuracy = 0;
  int mistake = 0;
  int blunder = 0;
  int missedWin = 0;
  int brilliant = 0;
  int great = 0;
  int forced = 0;

  void bump(MoveQuality q) {
    switch (q) {
      case MoveQuality.best:
        best++;
      case MoveQuality.excellent:
        excellent++;
      case MoveQuality.good:
        good++;
      case MoveQuality.book:
        book++;
      case MoveQuality.inaccuracy:
        inaccuracy++;
      case MoveQuality.mistake:
        mistake++;
      case MoveQuality.blunder:
        blunder++;
      case MoveQuality.missedWin:
        missedWin++;
      case MoveQuality.brilliant:
        brilliant++;
      case MoveQuality.great:
        great++;
      case MoveQuality.forced:
        forced++;
    }
  }

  ReviewCountsByTier toCounts() => ReviewCountsByTier(
        best: best,
        excellent: excellent,
        good: good,
        book: book,
        inaccuracy: inaccuracy,
        mistake: mistake,
        blunder: blunder,
        missedWin: missedWin,
        brilliant: brilliant,
        great: great,
        forced: forced,
      );
}
