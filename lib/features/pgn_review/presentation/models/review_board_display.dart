/// Display models for the move-by-move Review Board.
///
/// These classes adapt the already-computed review timeline into small UI
/// contracts. They do not run engine analysis or change classification data.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/widgets/apex_board_overlay.dart';

enum ReviewBoardSide { white, black }

class ReviewPlayerHeaderDisplay {
  const ReviewPlayerHeaderDisplay({
    required this.side,
    required this.username,
    required this.rating,
    required this.isUser,
    required this.result,
    required this.avatarUrl,
  });

  final ReviewBoardSide side;
  final String username;
  final String? rating;
  final bool isUser;
  final String? result;
  final String? avatarUrl;

  String get sideLabel => side == ReviewBoardSide.white ? 'White' : 'Black';

  PlayerIdentityDisplay get identity => PlayerIdentityDisplay.fromRaw(
    username: username,
    platform: PlayerIdentityPlatform.pgn,
    rating: rating,
    avatarUrl: avatarUrl,
    isConnectedUser: isUser,
    isOpponent: !isUser,
    side: side == ReviewBoardSide.white
        ? PlayerIdentitySide.white
        : PlayerIdentitySide.black,
    result: switch (result) {
      'Won' => PlayerIdentityResult.won,
      'Lost' => PlayerIdentityResult.lost,
      'Draw' => PlayerIdentityResult.draw,
      _ => PlayerIdentityResult.unknown,
    },
  );

  String get initial {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return side == ReviewBoardSide.white ? 'W' : 'B';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  static ReviewPlayerHeaderDisplay white(
    AnalysisTimeline timeline, {
    required bool? userIsWhite,
  }) {
    final headers = timeline.headers;
    return ReviewPlayerHeaderDisplay(
      side: ReviewBoardSide.white,
      username: _cleanName(headers['White'], fallback: 'White'),
      rating: _cleanOptional(headers['WhiteElo']),
      isUser: userIsWhite == true,
      result: _resultForSide(headers['Result'], ReviewBoardSide.white),
      avatarUrl: _cleanOptional(
        headers['WhiteAvatar'] ?? headers['WhiteAvatarUrl'],
      ),
    );
  }

  static ReviewPlayerHeaderDisplay black(
    AnalysisTimeline timeline, {
    required bool? userIsWhite,
  }) {
    final headers = timeline.headers;
    return ReviewPlayerHeaderDisplay(
      side: ReviewBoardSide.black,
      username: _cleanName(headers['Black'], fallback: 'Black'),
      rating: _cleanOptional(headers['BlackElo']),
      isUser: userIsWhite == false,
      result: _resultForSide(headers['Result'], ReviewBoardSide.black),
      avatarUrl: _cleanOptional(
        headers['BlackAvatar'] ?? headers['BlackAvatarUrl'],
      ),
    );
  }

  static ReviewPlayerHeaderDisplay top(
    AnalysisTimeline timeline, {
    required bool flipped,
    required bool? userIsWhite,
  }) {
    return flipped
        ? white(timeline, userIsWhite: userIsWhite)
        : black(timeline, userIsWhite: userIsWhite);
  }

  static ReviewPlayerHeaderDisplay bottom(
    AnalysisTimeline timeline, {
    required bool flipped,
    required bool? userIsWhite,
  }) {
    return flipped
        ? black(timeline, userIsWhite: userIsWhite)
        : white(timeline, userIsWhite: userIsWhite);
  }

  static String _cleanName(String? raw, {required String fallback}) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  static String? _cleanOptional(String? raw) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String? _resultForSide(String? raw, ReviewBoardSide side) {
    return switch (raw) {
      '1-0' => side == ReviewBoardSide.white ? 'Won' : 'Lost',
      '0-1' => side == ReviewBoardSide.black ? 'Won' : 'Lost',
      '1/2-1/2' => 'Draw',
      _ => null,
    };
  }
}

class ReviewEvalDisplay {
  const ReviewEvalDisplay({
    required this.whiteShare,
    required this.label,
    required this.percentageLabel,
    required this.advantageLabel,
    required this.isKnown,
  });

  /// White share of the vertical bar, 0..1.
  final double whiteShare;
  final String label;
  final String percentageLabel;
  final String advantageLabel;
  final bool isKnown;

  bool get whiteBetter => whiteShare > 0.54;
  bool get blackBetter => whiteShare < 0.46;
  bool get isEqual => !whiteBetter && !blackBetter;

  factory ReviewEvalDisplay.fromMove(MoveAnalysis? move) {
    if (move == null || !move.engineEvaluationAvailable) {
      return const ReviewEvalDisplay(
        whiteShare: 0.5,
        label: '-',
        percentageLabel: '—',
        advantageLabel: 'Evaluation unavailable',
        isKnown: false,
      );
    }

    final mate = move.mateInAfter;
    if (mate != null) {
      final whiteShare = mate > 0 ? 1.0 : 0.0;
      return ReviewEvalDisplay(
        whiteShare: whiteShare,
        label: 'M${mate.abs()}',
        percentageLabel: whiteShare == 1.0 ? '100%' : '0%',
        advantageLabel: mate > 0 ? 'White' : 'Black',
        isKnown: true,
      );
    }

    final cp = move.scoreCpAfter;
    final rawShare = cp != null
        ? _shareFromCentipawns(cp)
        : (move.winPercentAfter / 100).clamp(0.0, 1.0);
    final share = _stabilize(rawShare);
    final label = cp == null ? _winLabel(move.winPercentAfter) : _cpLabel(cp);
    return ReviewEvalDisplay(
      whiteShare: share,
      label: label,
      percentageLabel: '${(share * 100).round()}%',
      advantageLabel: share > 0.54
          ? 'White'
          : share < 0.46
          ? 'Black'
          : 'Equal',
      isKnown: cp != null || move.winPercentAfter != 50,
    );
  }

  static double _shareFromCentipawns(int cp) {
    final clamped = cp.clamp(-1000, 1000).toDouble();
    final w = 2.0 / (1.0 + _expApprox(-0.00368208 * clamped)) - 1.0;
    return ((50 + 50 * w) / 100).clamp(0.0, 1.0);
  }

  static double _stabilize(double value) {
    return ((value.clamp(0.0, 1.0) * 50).round() / 50).clamp(0.0, 1.0);
  }

  static double _expApprox(double x) {
    var y = 1.0 + x / 1024.0;
    for (var i = 0; i < 10; i++) {
      y = y * y;
    }
    return y;
  }

  static String _cpLabel(int cp) {
    if (cp.abs() < 15) return 'Equal';
    final pawns = (cp / 100).clamp(-99.9, 99.9);
    final sign = pawns >= 0 ? '+' : '';
    return '$sign${pawns.toStringAsFixed(1)}';
  }

  static String _winLabel(double winPercent) {
    if ((winPercent - 50).abs() < 2) return 'Equal';
    return '${winPercent.round()}%';
  }
}

class ReviewMoveQualityChipDisplay {
  const ReviewMoveQualityChipDisplay({
    required this.label,
    required this.color,
    required this.marker,
    required this.icon,
    required this.semanticDescription,
    this.allowsBrilliantEmphasis = false,
  });

  final String label;
  final Color color;
  final String marker;
  final IconData icon;
  final String semanticDescription;
  final bool allowsBrilliantEmphasis;

  factory ReviewMoveQualityChipDisplay.fromMove(MoveAnalysis move) {
    final label = MoveQualityDisplay.labelForMove(move);
    return ReviewMoveQualityChipDisplay.fromLabel(label);
  }

  factory ReviewMoveQualityChipDisplay.fromLabel(ReviewMoveLabel label) {
    return ReviewMoveQualityChipDisplay(
      label: label.label,
      color: label.color,
      marker: markerForLabel(label),
      icon: iconForLabel(label),
      semanticDescription: semanticDescriptionForLabel(label),
      allowsBrilliantEmphasis: label == ReviewMoveLabel.brilliant,
    );
  }

  static IconData iconForLabel(ReviewMoveLabel label) => switch (label) {
    ReviewMoveLabel.brilliant => Icons.diamond_outlined,
    ReviewMoveLabel.great => Icons.auto_awesome_outlined,
    ReviewMoveLabel.onlyMove || ReviewMoveLabel.forced => Icons.route_outlined,
    ReviewMoveLabel.best ||
    ReviewMoveLabel.excellent ||
    ReviewMoveLabel.good => Icons.check_circle_outline_rounded,
    ReviewMoveLabel.book => Icons.menu_book_outlined,
    ReviewMoveLabel.inaccuracy => Icons.info_outline_rounded,
    ReviewMoveLabel.mistake ||
    ReviewMoveLabel.miss ||
    ReviewMoveLabel.blunder => Icons.warning_amber_rounded,
    ReviewMoveLabel.unavailable => Icons.help_outline_rounded,
    ReviewMoveLabel.checkmate => Icons.flag_outlined,
  };

  static String semanticDescriptionForLabel(ReviewMoveLabel label) =>
      switch (label) {
        ReviewMoveLabel.brilliant => 'Brilliant move',
        ReviewMoveLabel.great => 'Great move',
        ReviewMoveLabel.onlyMove => 'Only move',
        ReviewMoveLabel.forced => 'Forced move',
        ReviewMoveLabel.best => 'Best move',
        ReviewMoveLabel.excellent => 'Excellent move',
        ReviewMoveLabel.good => 'Good move',
        ReviewMoveLabel.book => 'Verified opening move',
        ReviewMoveLabel.inaccuracy => 'Inaccuracy',
        ReviewMoveLabel.mistake => 'Mistake',
        ReviewMoveLabel.miss => 'Missed opportunity',
        ReviewMoveLabel.blunder => 'Blunder',
        ReviewMoveLabel.unavailable => 'Classification unavailable',
        ReviewMoveLabel.checkmate => 'Checkmate',
      };

  static String markerForLabel(ReviewMoveLabel label) {
    return switch (label) {
      ReviewMoveLabel.brilliant => '!!',
      ReviewMoveLabel.great => '!',
      ReviewMoveLabel.onlyMove => 'Only',
      ReviewMoveLabel.forced => 'Forced',
      ReviewMoveLabel.best => '*',
      ReviewMoveLabel.excellent => '+',
      ReviewMoveLabel.good => '',
      ReviewMoveLabel.book => 'Book',
      ReviewMoveLabel.inaccuracy => '?!',
      ReviewMoveLabel.mistake || ReviewMoveLabel.miss => '?',
      ReviewMoveLabel.blunder => '??',
      ReviewMoveLabel.unavailable => '—',
      ReviewMoveLabel.checkmate => '#',
    };
  }
}

class ReviewCoachInsightDisplay {
  const ReviewCoachInsightDisplay({
    required this.moveLabel,
    required this.san,
    this.explanation,
    this.coachDetail,
    this.consequenceDetail,
    required this.quality,
    this.betterMove,
    this.betterMoveReason,
    this.engineLinePreview,
    this.needsDeepScan = false,
    this.artifactDigest,
  });

  final String moveLabel;
  final String san;
  final String? explanation;
  final String? coachDetail;
  final String? consequenceDetail;
  final ReviewMoveQualityChipDisplay quality;
  final String? betterMove;
  final String? betterMoveReason;
  final String? engineLinePreview;
  final bool needsDeepScan;
  final String? artifactDigest;

  bool get hasDetails => explanation != null;

  factory ReviewCoachInsightDisplay.empty() {
    return const ReviewCoachInsightDisplay(
      moveLabel: 'Review',
      san: 'Move',
      quality: ReviewMoveQualityChipDisplay(
        label: 'Move',
        color: Color(0xFF4FC3FF),
        marker: '',
        icon: Icons.circle_outlined,
        semanticDescription: 'Selected position',
      ),
    );
  }

  factory ReviewCoachInsightDisplay.fromMove(
    MoveAnalysis? move, {
    required AnalysisTimeline? timeline,
    required AnalysisMode mode,
    required bool? userIsWhite,
  }) {
    if (move == null) return ReviewCoachInsightDisplay.empty();
    final quality = ReviewMoveQualityChipDisplay.fromMove(move);
    final betterMove = _betterMoveLabel(move);
    final persisted = timeline?.hasSupportedExplanationContract == true
        ? move.insight
        : null;
    final authoritativeInsight = persisted?.isDisplayable == true
        ? persisted!.conciseText
        : null;
    return ReviewCoachInsightDisplay(
      moveLabel: _moveNumberLabel(move.ply),
      san: move.san.isEmpty ? 'Move' : move.san,
      explanation: authoritativeInsight,
      coachDetail: authoritativeInsight == null ? null : persisted!.causeText,
      consequenceDetail: authoritativeInsight == null
          ? null
          : persisted!.consequenceText,
      quality: quality,
      betterMove: betterMove,
      betterMoveReason: authoritativeInsight == null
          ? null
          : persisted!.betterMoveText,
      engineLinePreview: authoritativeInsight == null
          ? null
          : persisted!.continuationText,
      needsDeepScan:
          mode == AnalysisMode.quick &&
          move.classification != MoveQuality.book &&
          move.multiPvReceived < 3,
      artifactDigest: authoritativeInsight == null
          ? null
          : persisted!.integrityDigest,
    );
  }

  static String? _betterMoveLabel(MoveAnalysis move) {
    if (!ReviewBoardDisplayModel.shouldShowBetterMoveArrow(move)) return null;
    final san = move.engineBestMoveSan;
    if (san != null && san.trim().isNotEmpty) return san.trim();
    final lineFirstMove = _lineFirstMove(move);
    if (lineFirstMove != null) return lineFirstMove;
    final uci = move.engineBestMoveUci;
    if (uci == null || uci.trim().isEmpty) return null;
    return uci.trim();
  }

  static String? _lineFirstMove(MoveAnalysis move) {
    final line = move.engineLines.firstOrNull?.moveSan?.trim();
    if (line == null || line.isEmpty) return null;
    final first = line.split(RegExp(r'\s+')).first.trim();
    return first.isEmpty ? null : first;
  }

  static String _moveNumberLabel(int ply) =>
      '${(ply ~/ 2) + 1}${ply.isEven ? '.' : '...'}';
}

class ReviewTimelinePlyDisplay {
  const ReviewTimelinePlyDisplay({
    required this.ply,
    required this.label,
    required this.marker,
    required this.color,
  });

  final int ply;
  final String label;
  final String marker;
  final Color color;

  factory ReviewTimelinePlyDisplay.fromMove(MoveAnalysis move) {
    final label = move.isWhiteMove
        ? '${(move.ply ~/ 2) + 1}. ${move.san}'
        : '${(move.ply ~/ 2) + 1}... ${move.san}';
    final quality = ReviewMoveQualityChipDisplay.fromMove(move);
    return ReviewTimelinePlyDisplay(
      ply: move.ply,
      label: label,
      marker: quality.marker,
      color: quality.color,
    );
  }

  static List<ReviewTimelinePlyDisplay> fromTimeline(
    AnalysisTimeline timeline,
  ) {
    return _projectionCacheFor(timeline).rows;
  }
}

enum ReviewCompatibilityState {
  current,
  historicSchema5,
  historicSchema4,
  unsupported,
}

class ReviewOpeningDisplay {
  const ReviewOpeningDisplay._({
    required this.isVerified,
    this.eco,
    this.name,
    this.variation,
  });

  const ReviewOpeningDisplay.unavailable() : this._(isVerified: false);

  final bool isVerified;
  final String? eco;
  final String? name;
  final String? variation;

  String? get label {
    if (!isVerified || name == null) return null;
    final prefix = eco == null || eco!.isEmpty ? '' : '$eco · ';
    return '$prefix$name';
  }

  factory ReviewOpeningDisplay.fromMove(MoveAnalysis? move) {
    final evidence = move?.openingEvidence;
    final candidate = evidence?.selectedCandidate;
    if (evidence?.isVerifiedBookTransition != true || candidate == null) {
      return const ReviewOpeningDisplay.unavailable();
    }
    return ReviewOpeningDisplay._(
      isVerified: true,
      eco: candidate.ecoCode.trim(),
      name: candidate.openingName.trim(),
      variation: candidate.variation?.trim(),
    );
  }
}

class ReviewCausalMechanismDisplay {
  const ReviewCausalMechanismDisplay({
    required this.label,
    required this.semanticLabel,
  });

  final String label;
  final String semanticLabel;

  static ReviewCausalMechanismDisplay? fromMove(
    MoveAnalysis? move, {
    required AnalysisTimeline timeline,
  }) {
    final insight = timeline.hasSupportedExplanationContract
        ? move?.insight
        : null;
    final claim = insight?.isDisplayable == true ? insight!.primaryClaim : null;
    if (claim == null || claim.mechanism == MoveInsightMechanismType.none) {
      return null;
    }
    final label = switch (claim.mechanism) {
      MoveInsightMechanismType.fork => 'Fork',
      MoveInsightMechanismType.doubleAttack => 'Double attack',
      MoveInsightMechanismType.absolutePin => 'Absolute pin',
      MoveInsightMechanismType.skewer => 'Skewer',
      MoveInsightMechanismType.discoveredAttack => 'Discovered attack',
      MoveInsightMechanismType.opensLine => 'Opened line',
      MoveInsightMechanismType.removesDefender => 'Removed defender',
      MoveInsightMechanismType.soundSacrifice => 'Sound sacrifice',
      MoveInsightMechanismType.unsoundSacrifice => 'Unsound sacrifice',
      MoveInsightMechanismType.onlyMoveDefense => 'Only defense',
      MoveInsightMechanismType.missedMaterialResource =>
        'Missed material resource',
      MoveInsightMechanismType.none => '',
    };
    return ReviewCausalMechanismDisplay(
      label: label,
      semanticLabel: 'Tactical mechanism: $label',
    );
  }
}

class _ReviewTimelineProjectionCache {
  const _ReviewTimelineProjectionCache({
    required this.rows,
    required this.criticalPlies,
    required this.criticalPlySet,
    required this.previousCriticalBySelection,
    required this.nextCriticalBySelection,
  });

  final List<ReviewTimelinePlyDisplay> rows;
  final List<int> criticalPlies;
  final Set<int> criticalPlySet;
  final List<int?> previousCriticalBySelection;
  final List<int?> nextCriticalBySelection;
}

/// The single immutable selected-ply presentation authority for Review V2.
///
/// It projects already accepted timeline/document evidence. Widgets render
/// these values and never inspect engine/classifier/opening/claim internals.
class ReviewBoardDisplayModel {
  const ReviewBoardDisplayModel({
    required this.documentIdentity,
    required this.variantIdentity,
    required this.gameIdentity,
    required this.executionId,
    required this.presentationKey,
    required this.currentFen,
    required this.fenBefore,
    required this.fenAfter,
    required this.currentMove,
    required this.currentPly,
    required this.totalPlies,
    required this.moverLabel,
    required this.sideToMoveLabel,
    required this.flipped,
    required this.topPlayer,
    required this.bottomPlayer,
    required this.eval,
    required this.opening,
    required this.insight,
    required this.mechanism,
    required this.boardOverlay,
    required this.timeline,
    required this.criticalPlies,
    required Set<int> criticalPlySet,
    required List<int?> previousCriticalBySelection,
    required List<int?> nextCriticalBySelection,
    required this.compatibility,
    required this.executionKey,
    this.lastMove,
    this.selectedSquare,
    this.bestMoveArrow,
  }) : _criticalPlySet = criticalPlySet,
       _previousCriticalBySelection = previousCriticalBySelection,
       _nextCriticalBySelection = nextCriticalBySelection;

  final String? documentIdentity;
  final String? variantIdentity;
  final String? gameIdentity;
  final int executionId;
  final String presentationKey;
  final String currentFen;
  final String fenBefore;
  final String fenAfter;
  final MoveAnalysis? currentMove;
  final int currentPly;
  final int totalPlies;
  final String moverLabel;
  final String sideToMoveLabel;
  final bool flipped;
  final ReviewPlayerHeaderDisplay topPlayer;
  final ReviewPlayerHeaderDisplay bottomPlayer;
  final ReviewEvalDisplay eval;
  final ReviewOpeningDisplay opening;
  final ReviewCoachInsightDisplay insight;
  final ReviewCausalMechanismDisplay? mechanism;
  final ApexBoardOverlay? boardOverlay;
  final List<ReviewTimelinePlyDisplay> timeline;
  final List<int> criticalPlies;
  final Set<int> _criticalPlySet;
  final List<int?> _previousCriticalBySelection;
  final List<int?> _nextCriticalBySelection;
  final ReviewCompatibilityState compatibility;
  final String executionKey;
  final (String, String)? lastMove;
  final String? selectedSquare;
  final (String, String)? bestMoveArrow;

  bool get canGoPrevious => currentPly > -1;
  bool get canGoNext => currentPly < totalPlies - 1;
  bool get hasBestMove => insight.betterMove != null;
  bool get isCriticalMoment => _criticalPlySet.contains(currentPly);
  int? get previousCriticalPly => _previousCriticalBySelection[currentPly + 1];
  int? get nextCriticalPly => _nextCriticalBySelection[currentPly + 1];

  factory ReviewBoardDisplayModel.fromState(ReviewState state) {
    final timeline = state.timeline;
    if (timeline == null) {
      throw StateError('Review presentation requires a loaded timeline.');
    }
    return ReviewBoardDisplayModel.fromTimeline(
      timeline,
      currentPly: state.currentPly,
      flipped: state.flipped,
      mode: state.mode,
      userIsWhite: state.userIsWhite,
      documentIdentity: state.reviewDocumentId,
      variantIdentity: state.analysisVariantId,
      gameIdentity: state.gameId,
      executionId: state.executionId,
    );
  }

  factory ReviewBoardDisplayModel.fromTimeline(
    AnalysisTimeline timeline, {
    required int currentPly,
    required bool flipped,
    required AnalysisMode mode,
    required bool? userIsWhite,
    String? documentIdentity,
    String? variantIdentity,
    String? gameIdentity,
    int executionId = 0,
  }) {
    final safePly = timeline.moves.isEmpty
        ? -1
        : currentPly.clamp(-1, timeline.totalPlies - 1).toInt();
    final move = safePly < 0 ? null : timeline.moves[safePly];
    final fenBefore = move?.fenBefore ?? timeline.startingFen;
    final fenAfter = move?.fenAfter ?? timeline.startingFen;
    final lastMove = _lastMoveFromUci(move?.uci);
    final insight = ReviewCoachInsightDisplay.fromMove(
      move,
      timeline: timeline,
      mode: mode,
      userIsWhite: userIsWhite,
    );
    final cache = _projectionCacheFor(timeline);
    final overlay = _overlayFromMove(move, timeline: timeline);
    final timelineToken = identityHashCode(timeline);
    final identityKey =
        documentIdentity ??
        variantIdentity ??
        timeline.cacheKey ??
        'timeline-$timelineToken';
    final presentationKey =
        '$identityKey|run=$executionId|timeline=$timelineToken|ply=$safePly|'
        'flipped=$flipped';
    return ReviewBoardDisplayModel(
      documentIdentity: documentIdentity,
      variantIdentity: variantIdentity,
      gameIdentity: gameIdentity,
      executionId: executionId,
      presentationKey: presentationKey,
      currentFen: fenAfter,
      fenBefore: fenBefore,
      fenAfter: fenAfter,
      currentMove: move,
      currentPly: safePly,
      totalPlies: timeline.totalPlies,
      moverLabel: move == null
          ? 'No move selected'
          : move.isWhiteMove
          ? 'White moved'
          : 'Black moved',
      sideToMoveLabel: _sideToMoveFromFen(fenAfter),
      flipped: flipped,
      topPlayer: ReviewPlayerHeaderDisplay.top(
        timeline,
        flipped: flipped,
        userIsWhite: userIsWhite,
      ),
      bottomPlayer: ReviewPlayerHeaderDisplay.bottom(
        timeline,
        flipped: flipped,
        userIsWhite: userIsWhite,
      ),
      eval: ReviewEvalDisplay.fromMove(move),
      opening: ReviewOpeningDisplay.fromMove(move),
      insight: insight,
      mechanism: ReviewCausalMechanismDisplay.fromMove(
        move,
        timeline: timeline,
      ),
      boardOverlay: overlay,
      timeline: cache.rows,
      criticalPlies: cache.criticalPlies,
      criticalPlySet: cache.criticalPlySet,
      previousCriticalBySelection: cache.previousCriticalBySelection,
      nextCriticalBySelection: cache.nextCriticalBySelection,
      compatibility: _compatibilityFor(timeline),
      executionKey: '$identityKey|run=$executionId|timeline=$timelineToken',
      lastMove: lastMove,
      selectedSquare: move?.targetSquare.isNotEmpty == true
          ? move!.targetSquare
          : lastMove?.$2,
      bestMoveArrow: insight.betterMove != null && overlay == null
          ? _arrowFromUci(move?.engineBestMoveUci)
          : null,
    );
  }

  static bool shouldShowBetterMoveArrow(MoveAnalysis? move) {
    if (move == null) return false;
    if (move.engineBestMoveUci == null) return false;
    if (_playedEqualsBest(move) || move.playedEqualsPv1) return false;
    return switch (move.classification) {
      MoveQuality.brilliant ||
      MoveQuality.great ||
      MoveQuality.best ||
      MoveQuality.book ||
      MoveQuality.onlyMove ||
      MoveQuality.forced ||
      MoveQuality.unavailable => false,
      MoveQuality.excellent ||
      MoveQuality.good ||
      MoveQuality.inaccuracy ||
      MoveQuality.mistake ||
      MoveQuality.missedWin ||
      MoveQuality.blunder => true,
    };
  }

  static (String, String)? _lastMoveFromUci(String? uci) {
    if (uci == null || uci.length < 4) return null;
    final normalized = normalizeCastlingUci(uci);
    if (normalized.length < 4) return null;
    return (normalized.substring(0, 2), normalized.substring(2, 4));
  }

  static (String, String)? _arrowFromUci(String? uci) {
    if (uci == null || uci.length < 4) return null;
    final normalized = normalizeCastlingUci(uci);
    if (normalized.length < 4) return null;
    return (normalized.substring(0, 2), normalized.substring(2, 4));
  }

  static bool _playedEqualsBest(MoveAnalysis move) {
    final best = move.engineBestMoveUci;
    final played = move.uci;
    if (best == null || played.isEmpty) return false;
    return normalizeCastlingUci(best) == normalizeCastlingUci(played);
  }

  static String _sideToMoveFromFen(String fen) {
    final fields = fen.trim().split(RegExp(r'\s+'));
    if (fields.length < 2) return 'Side to move unavailable';
    return fields[1] == 'b' ? 'Black to move' : 'White to move';
  }

  static ReviewCompatibilityState _compatibilityFor(
    AnalysisTimeline timeline,
  ) => switch (timeline.analysisSchemaVersion) {
    kApexAnalysisSchemaVersion => ReviewCompatibilityState.current,
    kApexLegacyInsightAnalysisSchemaVersion =>
      ReviewCompatibilityState.historicSchema5,
    kApexLegacyAnalysisSchemaVersion =>
      ReviewCompatibilityState.historicSchema4,
    _ => ReviewCompatibilityState.unsupported,
  };

  static ApexBoardOverlay? _overlayFromMove(
    MoveAnalysis? move, {
    required AnalysisTimeline timeline,
  }) {
    final insight = timeline.hasSupportedExplanationContract
        ? move?.insight
        : null;
    final claim = insight?.isDisplayable == true ? insight!.primaryClaim : null;
    if (claim == null || claim.mechanism == MoveInsightMechanismType.none) {
      return null;
    }

    (String, String)? arrow(String? from, String? to) {
      if (!ApexBoardGeometry.isSquare(from) ||
          !ApexBoardGeometry.isSquare(to) ||
          from == to) {
        return null;
      }
      return (from!, to!);
    }

    List<String> squares(Iterable<String?> candidates) =>
        List<String>.unmodifiable(
          candidates
              .whereType<String>()
              .where(ApexBoardGeometry.isSquare)
              .toSet(),
        );

    final label = ReviewCausalMechanismDisplay.fromMove(
      move,
      timeline: timeline,
    )?.semanticLabel;
    if (label == null) return null;

    final overlay = switch (claim.mechanism) {
      MoveInsightMechanismType.fork ||
      MoveInsightMechanismType.doubleAttack => ApexBoardOverlay(
        semanticLabel: label,
        principalArrow: arrow(claim.pieceSquare, claim.targetSquare),
        targetSquares: squares([
          claim.targetSquare,
          claim.secondaryTargetSquare,
        ]),
      ),
      MoveInsightMechanismType.absolutePin ||
      MoveInsightMechanismType.skewer => ApexBoardOverlay(
        semanticLabel: label,
        principalArrow: arrow(claim.pieceSquare, claim.targetSquare),
        targetSquares: squares([
          claim.targetSquare,
          claim.secondaryTargetSquare,
        ]),
        raySquares: squares(claim.lineSquares),
      ),
      MoveInsightMechanismType.discoveredAttack ||
      MoveInsightMechanismType.opensLine => ApexBoardOverlay(
        semanticLabel: label,
        principalArrow: arrow(claim.pieceSquare, claim.targetSquare),
        targetSquares: squares([claim.targetSquare]),
        raySquares: squares(claim.lineSquares),
        supportSquares: squares([claim.initiatorSquare]),
      ),
      MoveInsightMechanismType.removesDefender => ApexBoardOverlay(
        semanticLabel: label,
        principalArrow: arrow(claim.defenderSquare, claim.targetSquare),
        targetSquares: squares([claim.targetSquare]),
        supportSquares: squares([claim.defenderSquare, claim.initiatorSquare]),
      ),
      MoveInsightMechanismType.soundSacrifice ||
      MoveInsightMechanismType.unsoundSacrifice => ApexBoardOverlay(
        semanticLabel: label,
        targetSquares: squares([claim.initiatorSquare, claim.targetSquare]),
      ),
      MoveInsightMechanismType.onlyMoveDefense ||
      MoveInsightMechanismType.missedMaterialResource ||
      MoveInsightMechanismType.none => const ApexBoardOverlay(
        semanticLabel: '',
      ),
    };
    return overlay.isEmpty ? null : overlay;
  }
}

typedef ReviewSelectedPlyPresentation = ReviewBoardDisplayModel;

final Expando<_ReviewTimelineProjectionCache> _timelineProjectionCache =
    Expando<_ReviewTimelineProjectionCache>('reviewTimelineProjection');

_ReviewTimelineProjectionCache _projectionCacheFor(AnalysisTimeline timeline) {
  final cached = _timelineProjectionCache[timeline];
  if (cached != null) return cached;
  final rows = List<ReviewTimelinePlyDisplay>.unmodifiable([
    for (final move in timeline.moves) ReviewTimelinePlyDisplay.fromMove(move),
  ]);
  final critical = List<int>.unmodifiable([
    for (final move in timeline.moves)
      if (_isCriticalMove(move, timeline: timeline)) move.ply,
  ]);
  final criticalSet = Set<int>.unmodifiable(critical);
  final previousCritical = List<int?>.filled(timeline.totalPlies + 1, null);
  int? previous;
  for (var current = -1; current < timeline.totalPlies; current++) {
    previousCritical[current + 1] = previous;
    if (criticalSet.contains(current)) previous = current;
  }
  final nextCritical = List<int?>.filled(timeline.totalPlies + 1, null);
  var nextIndex = 0;
  for (var current = -1; current < timeline.totalPlies; current++) {
    while (nextIndex < critical.length && critical[nextIndex] <= current) {
      nextIndex++;
    }
    nextCritical[current + 1] = nextIndex < critical.length
        ? critical[nextIndex]
        : null;
  }
  final projection = _ReviewTimelineProjectionCache(
    rows: rows,
    criticalPlies: critical,
    criticalPlySet: criticalSet,
    previousCriticalBySelection: List<int?>.unmodifiable(previousCritical),
    nextCriticalBySelection: List<int?>.unmodifiable(nextCritical),
  );
  _timelineProjectionCache[timeline] = projection;
  return projection;
}

bool _isCriticalMove(MoveAnalysis move, {required AnalysisTimeline timeline}) {
  final classificationCritical = switch (move.classification) {
    MoveQuality.brilliant ||
    MoveQuality.great ||
    MoveQuality.onlyMove ||
    MoveQuality.missedWin ||
    MoveQuality.inaccuracy ||
    MoveQuality.mistake ||
    MoveQuality.blunder => true,
    _ => false,
  };
  final forcedMatePresent = move.mateInAfter != null;
  final insight = timeline.hasSupportedExplanationContract
      ? move.insight
      : null;
  final highSignalMechanism =
      insight?.isDisplayable == true &&
      insight!.primaryClaim?.mechanism != MoveInsightMechanismType.none;
  return classificationCritical || forcedMatePresent || highSignalMechanism;
}
