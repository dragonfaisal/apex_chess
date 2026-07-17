/// Pre-computed per-game summary — the data contract consumed by
/// [ReviewSummaryScreen] (Phase 20.1 § 3).
///
/// Computed once from an [AnalysisTimeline] + the user's known
/// colour. All numbers shown on the summary screen derive from this
/// structure so the UI can't silently invent "fake" statistics
/// (addendum to Phase 20 § 1: "Every number shown in UI must come
/// from a real data source.").
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';

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
    required this.onlyMove,
    required this.forced,
    required this.unavailable,
    this.displayCounts = const <ReviewMoveLabel, int>{},
    this.whiteDisplayCounts = const <ReviewMoveLabel, int>{},
    this.blackDisplayCounts = const <ReviewMoveLabel, int>{},
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
  final int onlyMove;
  final int forced;
  final int unavailable;
  final Map<ReviewMoveLabel, int> displayCounts;
  final Map<ReviewMoveLabel, int> whiteDisplayCounts;
  final Map<ReviewMoveLabel, int> blackDisplayCounts;

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
      onlyMove +
      forced +
      unavailable;
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
    required this.onlyMove,
    required this.forced,
    required this.unavailable,
    this.displayCounts = const <ReviewMoveLabel, int>{},
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
      forced = 0,
      onlyMove = 0,
      unavailable = 0,
      displayCounts = const <ReviewMoveLabel, int>{};

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
  final int onlyMove;
  final int forced;
  final int unavailable;
  final Map<ReviewMoveLabel, int> displayCounts;

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
      case MoveQuality.onlyMove:
        return onlyMove;
      case MoveQuality.forced:
        return forced;
      case MoveQuality.unavailable:
        return unavailable;
    }
  }

  int forDisplayLabel(ReviewMoveLabel label) => displayCounts[label] ?? 0;

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
      onlyMove +
      forced +
      unavailable;
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
  final double? accuracyPct;
}

/// Snapshot of the key ply types called out on the summary screen.
/// `null` fields mean "no ply of this kind in this game" — the UI
/// should render a neutral placeholder rather than a zero value.
class ReviewHighlights {
  const ReviewHighlights({
    this.keyTurningPoint,
    this.biggestMistake,
    this.bestUserMove,
    this.brilliantMoment,
    this.checkmate,
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

  final MoveAnalysis? brilliantMoment;

  final MoveAnalysis? checkmate;
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
  final double? userAccuracyPct;

  /// Lichess-style game accuracy for the opponent's plies (0–100).
  final double? opponentAccuracyPct;

  /// Mean centipawn loss across the user's plies.
  final double? userAverageCpLoss;

  /// Mean centipawn loss across the opponent's plies.
  final double? opponentAverageCpLoss;

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

    final whiteCount = timeline.cpLossEligibleCountWhite;
    final blackCount = timeline.cpLossEligibleCountBlack;
    final userCpLoss = switch (userIsWhite) {
      true => whiteCount == 0 ? null : whiteCpLoss,
      false => blackCount == 0 ? null : blackCpLoss,
      null => timeline.cpLossEligibleCount == 0 ? null : timeline.averageCpLoss,
    };
    final oppCpLoss = switch (userIsWhite) {
      true => blackCount == 0 ? null : blackCpLoss,
      false => whiteCount == 0 ? null : whiteCpLoss,
      null => timeline.cpLossEligibleCount == 0 ? null : timeline.averageCpLoss,
    };

    final phases = _phaseBreakdown(moves, userIsWhite: userIsWhite);
    final highlights = _highlights(moves, userIsWhite: userIsWhite);

    return ReviewSummary(
      userAccuracyPct: null,
      opponentAccuracyPct: null,
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
    final white = _MutableTier();
    final black = _MutableTier();
    final user = _MutableTier();
    final opp = _MutableTier();

    for (final m in moves) {
      tot.bumpMove(m);
      if (m.isWhiteMove) {
        white.bumpMove(m);
      } else {
        black.bumpMove(m);
      }
      if (userIsWhite == null) continue;
      if (m.isWhiteMove == userIsWhite) {
        user.bumpMove(m);
      } else {
        opp.bumpMove(m);
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
      onlyMove: tot.onlyMove,
      forced: tot.forced,
      unavailable: tot.unavailable,
      displayCounts: tot.displayCounts,
      whiteDisplayCounts: white.displayCounts,
      blackDisplayCounts: black.displayCounts,
      user: user.toCounts(),
      opponent: opp.toCounts(),
    );
  }

  // ── Phases ──────────────────────────────────────────────────────

  static List<PhaseBreakdown> _phaseBreakdown(
    List<MoveAnalysis> moves, {
    required bool? userIsWhite,
  }) {
    int openP = 0, midP = 0, endP = 0;
    double openL = 0, midL = 0, endL = 0;
    for (final m in moves) {
      if (userIsWhite != null && m.isWhiteMove != userIsWhite) continue;
      if (!m.engineEvaluationAvailable ||
          m.classification == MoveQuality.book ||
          m.moverCpLoss == null) {
        continue;
      }
      final phase = _phaseForPly(m.ply);
      final loss = m.moverCpLoss!.clamp(0, 100000).toDouble();
      switch (phase) {
        case GamePhase.opening:
          openP++;
          openL += loss;
        case GamePhase.middlegame:
          midP++;
          midL += loss;
        case GamePhase.endgame:
          endP++;
          endL += loss;
      }
    }

    return [
      PhaseBreakdown(
        phase: GamePhase.opening,
        plies: openP,
        averageCpLoss: openP == 0 ? 0 : openL / openP,
        accuracyPct: null,
      ),
      PhaseBreakdown(
        phase: GamePhase.middlegame,
        plies: midP,
        averageCpLoss: midP == 0 ? 0 : midL / midP,
        accuracyPct: null,
      ),
      PhaseBreakdown(
        phase: GamePhase.endgame,
        plies: endP,
        averageCpLoss: endP == 0 ? 0 : endL / endP,
        accuracyPct: null,
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
    MoveAnalysis? brilliantMoment;
    MoveAnalysis? checkmate;

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
      if (m.classification == MoveQuality.brilliant) {
        brilliantMoment ??= m;
      }
      if (m.san.contains('#')) {
        checkmate ??= m;
      }
    }

    return ReviewHighlights(
      keyTurningPoint: turning,
      biggestMistake: (worst != null && worstLoss > 0) ? worst : null,
      // Prefer a Brilliant/Great when one exists — the spec calls this
      // out as "Best move by user".
      bestUserMove: brilliantOrGreat ?? best,
      brilliantMoment: brilliantMoment,
      checkmate: checkmate,
    );
  }

  // ── Opening label ───────────────────────────────────────────────

  static String? _openingLabel(AnalysisTimeline timeline) {
    final evidence = timeline.moves
        .map((move) => move.openingEvidence)
        .whereType<OpeningEvidence>()
        .toList(growable: false);
    if (evidence.isNotEmpty) {
      final selected = OpeningEvidence.deepestNamed(evidence);
      final selectedIsTransposition =
          selected != null &&
          evidence.any(
            (item) =>
                item.transposition &&
                item.selectedSourceLineId == selected.sourceLineId,
          );
      final opening = selected == null
          ? null
          : '${selected.ecoCode} · ${selected.openingName}'
                '${selectedIsTransposition ? ' · Transposition' : ''}';
      final leavingTheoryPly = evidence
          .where((item) => item.state == OpeningMatchState.leftTheory)
          .map((item) => item.leavingTheoryPly ?? item.matchedPly)
          .fold<int?>(
            null,
            (earliest, ply) =>
                earliest == null || ply < earliest ? ply : earliest,
          );
      final leavingTheory = leavingTheoryPly == null
          ? null
          : 'Left known theory on move '
                '${_moveLabelForOneBasedPly(leavingTheoryPly)}';
      if (opening != null && leavingTheory != null) {
        return '$opening · $leavingTheory';
      }
      if (opening != null || leavingTheory != null) {
        return opening ?? leavingTheory;
      }
      return evidence.any((item) => item.state == OpeningMatchState.unavailable)
          ? 'Opening data unavailable'
          : 'Opening not detected';
    }

    // Historic opening-v1 timelines have no structured evidence. Preserve
    // their stored display values without rewriting or re-running lookup.
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

  static String _moveLabelForOneBasedPly(int ply) {
    final moveNumber = ((ply - 1) ~/ 2) + 1;
    return '$moveNumber${ply.isOdd ? '.' : '...'}';
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
  int onlyMove = 0;
  int forced = 0;
  int unavailable = 0;
  final Map<ReviewMoveLabel, int> _displayCounts = <ReviewMoveLabel, int>{};

  Map<ReviewMoveLabel, int> get displayCounts =>
      Map<ReviewMoveLabel, int>.unmodifiable(_displayCounts);

  void bumpMove(MoveAnalysis move) {
    bump(move.classification);
    final bucket = MoveQualityDisplay.countBucketForMove(move);
    _displayCounts[bucket] = (_displayCounts[bucket] ?? 0) + 1;
  }

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
      case MoveQuality.onlyMove:
        onlyMove++;
      case MoveQuality.forced:
        forced++;
      case MoveQuality.unavailable:
        unavailable++;
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
    onlyMove: onlyMove,
    forced: forced,
    unavailable: unavailable,
    displayCounts: displayCounts,
  );
}
