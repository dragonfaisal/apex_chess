/// Deterministic facts → claims → causal selection → language boundary.
///
/// The engine consumes only evidence already produced by normal analysis. It
/// never calls Stockfish, parses PGN, changes classifications, or guesses a
/// human intention.
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/position_heuristics.dart';

abstract class MoveInsightGenerator {
  MoveInsight generate(MoveInsightInput input);
}

class MoveInsightInput {
  const MoveInsightInput({
    required this.fenBefore,
    required this.fenAfter,
    required this.playedMoveUci,
    required this.playedMoveSan,
    required this.isWhiteMove,
    required this.classification,
    required this.classificationEvidence,
    required this.preMoveLines,
    required this.postMoveLines,
    required this.postMoveSearchQualityMet,
    required this.engineBestMoveSan,
    required this.openingEvidence,
  });

  final String fenBefore;
  final String fenAfter;
  final String playedMoveUci;
  final String playedMoveSan;
  final bool isWhiteMove;
  final MoveQuality classification;
  final MoveClassificationEvidence classificationEvidence;
  final List<EngineLine> preMoveLines;
  final List<EngineLine> postMoveLines;
  final bool postMoveSearchQualityMet;
  final String? engineBestMoveSan;
  final OpeningEvidence openingEvidence;
}

class MoveInsightEngine implements MoveInsightGenerator {
  const MoveInsightEngine({
    this.extractor = const MoveInsightFeatureExtractor(),
    this.detector = const MoveInsightClaimDetector(),
    this.planner = const MoveInsightPlanner(),
    this.renderer = const MoveInsightRenderer(),
  });

  final MoveInsightFeatureExtractor extractor;
  final MoveInsightClaimDetector detector;
  final MoveInsightPlanner planner;
  final MoveInsightRenderer renderer;

  @override
  MoveInsight generate(MoveInsightInput input) {
    try {
      final features = extractor.extract(input);
      if (features.contradiction != null) {
        return MoveInsight.create(
          state: MoveInsightState.contradictory,
          suppressionReason: features.contradiction,
        );
      }
      final claims = detector.detect(input, features);
      final selected = planner.select(claims);
      if (selected == null) {
        final reason = !input.classificationEvidence.searchQualityMet
            ? 'search_evidence_incomplete'
            : 'no_high_signal_verified_claim';
        return MoveInsight.create(
          state: MoveInsightState.suppressed,
          facts: features.facts,
          suppressionReason: reason,
        );
      }
      final rendered = renderer.render(selected.claim);
      return MoveInsight.create(
        state: MoveInsightState.available,
        facts: features.facts,
        primaryClaim: selected.claim,
        supportingClaims: selected.supporting,
        causalChain: selected.causalChain,
        conciseText: rendered.concise,
        causeText: rendered.cause,
        consequenceText: rendered.consequence,
        betterMoveText: rendered.betterMove,
        continuationText: rendered.continuation,
      );
    } on Object {
      return MoveInsight.create(
        state: MoveInsightState.contradictory,
        suppressionReason: 'invalid_or_contradictory_input',
      );
    }
  }
}

class MoveInsightFeatureExtractor {
  const MoveInsightFeatureExtractor();

  MoveInsightFeatures extract(MoveInsightInput input) {
    Position before;
    Position declaredAfter;
    try {
      before = Chess.fromSetup(Setup.parseFen(input.fenBefore));
      declaredAfter = Chess.fromSetup(Setup.parseFen(input.fenAfter));
    } on Object {
      return const MoveInsightFeatures.contradictory('invalid_board_state');
    }
    final played = _moveFromUci(before, input.playedMoveUci);
    if (played == null || !before.isLegal(played)) {
      return const MoveInsightFeatures.contradictory(
        'played_move_is_not_legal',
      );
    }
    final moverSide = input.isWhiteMove ? Side.white : Side.black;
    if (before.turn != moverSide) {
      return const MoveInsightFeatures.contradictory(
        'mover_perspective_mismatch',
      );
    }
    final evidence = input.classificationEvidence;
    if (!evidence.hasValidCoreScores ||
        evidence.mover.name != moverSide.name ||
        evidence.playedMoveUci == null ||
        !_sameUci(evidence.playedMoveUci!, input.playedMoveUci)) {
      return const MoveInsightFeatures.contradictory(
        'classification_evidence_identity_mismatch',
      );
    }
    final calculatedAfter = before.play(played);
    if (calculatedAfter.fen != declaredAfter.fen) {
      return const MoveInsightFeatures.contradictory(
        'fen_after_does_not_match_move',
      );
    }
    if (before.makeSan(played).$2 != input.playedMoveSan.trim()) {
      return const MoveInsightFeatures.contradictory(
        'played_san_does_not_match_move',
      );
    }

    final movingPiece = before.board.pieceAt(played.from);
    if (movingPiece == null) {
      return const MoveInsightFeatures.contradictory('moving_piece_missing');
    }
    final capture = _capturedPiece(before, played);
    final actualLegalMoveCount = _legalMoveCount(before);
    final declaredLegalMoveCount = input.classificationEvidence.legalMoveCount;
    if (declaredLegalMoveCount != null &&
        declaredLegalMoveCount != actualLegalMoveCount) {
      return const MoveInsightFeatures.contradictory(
        'legal_move_count_mismatch',
      );
    }
    final facts = <MoveInsightFact>[
      MoveInsightFact(
        id: 'f_legal',
        type: MoveInsightFactType.legalTransition,
        pieceRole: movingPiece.role.name,
        pieceSide: moverSide.name,
        fromSquare: _squareName(played.from),
        toSquare: _normalizedDestination(input.playedMoveUci),
      ),
      if (capture != null)
        MoveInsightFact(
          id: 'f_capture',
          type: MoveInsightFactType.capture,
          pieceRole: capture.piece.role.name,
          pieceSide: capture.piece.color.name,
          toSquare: _squareName(capture.square),
        ),
      if (played.promotion != null)
        MoveInsightFact(
          id: 'f_promotion',
          type: MoveInsightFactType.promotion,
          pieceRole: played.promotion!.name,
          pieceSide: moverSide.name,
          toSquare: _normalizedDestination(input.playedMoveUci),
        ),
      if (calculatedAfter.isCheckmate)
        MoveInsightFact(
          id: 'f_terminal_mate',
          type: MoveInsightFactType.terminalMate,
          pieceSide: moverSide.name,
        ),
    ];

    final preLines = _traceLines(
      input.fenBefore,
      input.preMoveLines,
      moverSide,
      input.fenBefore,
    );
    final postLines = _tracePostMoveLines(input, moverSide);
    final preCoherence = _preLinesCoherent(
      input.classificationEvidence,
      input.preMoveLines,
      preLines,
    );
    if (input.preMoveLines.isNotEmpty && !preCoherence) {
      return MoveInsightFeatures(
        contradiction: 'pre_move_lines_are_incoherent',
        facts: facts,
      );
    }
    if (input.preMoveLines.isNotEmpty &&
        (!evidence.bestMovePv1Consistent ||
            evidence.bestMoveUci == null ||
            !_sameUci(
              evidence.bestMoveUci!,
              input.preMoveLines.first.moveUci ?? '',
            ))) {
      return MoveInsightFeatures(
        contradiction: 'pre_move_best_move_is_incoherent',
        facts: facts,
      );
    }
    if (input.postMoveLines.isNotEmpty &&
        (postLines.length != input.postMoveLines.length ||
            !_postLinesCoherent(input))) {
      return MoveInsightFeatures(
        contradiction: 'post_move_line_is_not_legally_complete',
        facts: facts,
      );
    }

    final playedTrace = postLines.isEmpty ? null : postLines.first;
    final bestTrace = preLines.isEmpty ? null : preLines.first;
    if (playedTrace != null) {
      facts.add(
        MoveInsightFact(
          id: 'f_played_line',
          type: MoveInsightFactType.coherentEngineLine,
          textValue: playedTrace.sanMoves.take(6).join(' '),
          linePly: 0,
        ),
      );
      facts.add(
        MoveInsightFact(
          id: 'f_played_material',
          type: MoveInsightFactType.materialDelta,
          intValue: playedTrace.materialDelta,
        ),
      );
    }
    if (bestTrace != null) {
      facts.add(
        MoveInsightFact(
          id: 'f_best_line',
          type: MoveInsightFactType.coherentEngineLine,
          textValue: bestTrace.sanMoves.take(6).join(' '),
          linePly: 0,
        ),
      );
    }
    if (input.classificationEvidence.legalMoveCount != null) {
      facts.add(
        MoveInsightFact(
          id: 'f_legal_moves',
          type: MoveInsightFactType.legalMoveCount,
          intValue: input.classificationEvidence.legalMoveCount,
        ),
      );
    }
    final selectedOpening = input.openingEvidence.selectedCandidate;
    if (input.openingEvidence.isVerifiedBookTransition &&
        selectedOpening != null) {
      facts.add(
        MoveInsightFact(
          id: 'f_opening',
          type: MoveInsightFactType.openingTransition,
          textValue:
              '${selectedOpening.ecoCode}|${selectedOpening.openingName}',
        ),
      );
    }
    return MoveInsightFeatures(
      facts: facts,
      before: before,
      after: calculatedAfter,
      playedMove: played,
      movingRole: movingPiece.role.name,
      capturedRole: capture?.piece.role.name,
      capturedSquare: capture == null ? null : _squareName(capture.square),
      promotionRole: played.promotion?.name,
      preLines: preLines,
      postLines: postLines,
      playedTrace: playedTrace,
      bestTrace: bestTrace,
    );
  }

  List<MoveInsightLineTrace> _tracePostMoveLines(
    MoveInsightInput input,
    Side moverSide,
  ) {
    if (!input.postMoveSearchQualityMet || input.postMoveLines.isEmpty) {
      return const <MoveInsightLineTrace>[];
    }
    final out = <MoveInsightLineTrace>[];
    for (final line in input.postMoveLines) {
      if (line.rank != out.length + 1 || line.pvMoves.isEmpty) break;
      final combined = <String>[input.playedMoveUci, ...line.pvMoves];
      final trace = _traceLine(
        input.fenBefore,
        combined,
        moverSide,
        input.fenBefore,
      );
      if (trace == null) break;
      out.add(trace);
    }
    return out;
  }
}

class MoveInsightClaimDetector {
  const MoveInsightClaimDetector();

  List<MoveInsightClaimCandidate> detect(
    MoveInsightInput input,
    MoveInsightFeatures features,
  ) {
    final claims = <MoveInsightClaimCandidate>[];
    final evidence = input.classificationEvidence;
    final moverSide = input.isWhiteMove ? Side.white : Side.black;
    final playedScore = evidence.playedMoveEvaluation;
    final beforeScore = evidence.evaluationBefore;
    final bestScore = evidence.bestMoveEvaluation;
    final playedTrace = features.playedTrace;
    final bestTrace = features.bestTrace;

    void add({
      required MoveInsightClaimType type,
      required String reason,
      required int priority,
      required List<String> factIds,
      String? pieceRole,
      String? pieceSquare,
      String? targetRole,
      String? targetSquare,
      int? materialDelta,
      String? betterMoveSan,
      String? opponentReplySan,
      List<String> continuationSan = const <String>[],
      List<String> continuationUci = const <String>[],
      String? openingEco,
      String? openingName,
      List<MoveInsightCausalStep>? causalChain,
    }) {
      claims.add(
        MoveInsightClaimCandidate(
          priority: priority,
          claim: MoveInsightClaim(
            id: 'c_${type.name.toLowerCase()}',
            type: type,
            confidence: MoveInsightConfidence.verified,
            reasonCode: reason,
            supportingFactIds: factIds,
            pieceRole: pieceRole,
            pieceSquare: pieceSquare,
            targetRole: targetRole,
            targetSquare: targetSquare,
            materialDelta: materialDelta,
            betterMoveSan: betterMoveSan,
            opponentReplySan: opponentReplySan,
            continuationSan: continuationSan,
            continuationUci: continuationUci,
            openingEco: openingEco,
            openingName: openingName,
          ),
          causalChain:
              causalChain ??
              _defaultCausalChain(
                factIds,
                hasResponse: opponentReplySan != null,
              ),
        ),
      );
    }

    if (features.after?.isCheckmate == true) {
      add(
        type: MoveInsightClaimType.deliversMate,
        reason: 'legal_move_reaches_checkmate',
        priority: 100,
        factIds: const <String>['f_legal', 'f_terminal_mate'],
        pieceRole: features.movingRole,
        pieceSquare: _normalizedDestination(input.playedMoveUci),
      );
    } else if (features.after?.isStalemate == true) {
      add(
        type: MoveInsightClaimType.createsStalemate,
        reason: 'legal_move_reaches_stalemate',
        priority: 98,
        factIds: const <String>['f_legal'],
      );
    }

    final postMateWinner = playedTrace?.terminalWinner;
    final bestMateWinner = bestTrace?.terminalWinner;
    if (playedTrace != null &&
        _mateAgainstMover(playedScore, input.isWhiteMove) &&
        !_mateAgainstMover(beforeScore, input.isWhiteMove) &&
        postMateWinner != null &&
        postMateWinner != moverSide) {
      add(
        type: MoveInsightClaimType.allowsForcedMate,
        reason: 'score_and_legal_reply_line_allow_mate',
        priority: 96,
        factIds: const <String>['f_legal', 'f_played_line'],
        opponentReplySan: playedTrace.opponentReplySan,
        continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
        continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
        betterMoveSan: input.engineBestMoveSan,
      );
    }
    if (bestTrace != null &&
        _mateForMover(bestScore, input.isWhiteMove) &&
        !_mateForMover(playedScore, input.isWhiteMove) &&
        bestMateWinner == moverSide) {
      add(
        type: MoveInsightClaimType.missesForcedMate,
        reason: 'verified_best_line_mates_but_played_move_does_not',
        priority: 95,
        factIds: const <String>['f_legal', 'f_best_line'],
        betterMoveSan: input.engineBestMoveSan,
        continuationSan: bestTrace.sanMoves.take(6).toList(growable: false),
        continuationUci: bestTrace.uciMoves.take(6).toList(growable: false),
      );
    }
    if (playedTrace != null &&
        _mateForMover(beforeScore, input.isWhiteMove) &&
        _mateForMover(playedScore, input.isWhiteMove) &&
        postMateWinner == moverSide) {
      add(
        type: MoveInsightClaimType.preservesForcedMate,
        reason: 'verified_played_line_preserves_mate',
        priority: 94,
        factIds: const <String>['f_legal', 'f_played_line'],
        opponentReplySan: playedTrace.opponentReplySan,
        continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
        continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
      );
    }

    if (playedTrace != null && playedTrace.sanMoves.length >= 3) {
      final materialDelta = playedTrace.materialDelta;
      final bestDelta = bestTrace?.materialDelta;
      final bestImprovesMaterial =
          bestDelta != null && bestDelta - materialDelta >= 3;
      if (materialDelta <= -3 &&
          bestImprovesMaterial &&
          _isAdverseClassification(input.classification)) {
        add(
          type: MoveInsightClaimType.dropsMaterial,
          reason: 'best_response_line_sustains_material_loss',
          priority: 90,
          factIds: const <String>[
            'f_legal',
            'f_played_line',
            'f_played_material',
            'f_best_line',
          ],
          pieceRole: playedTrace.mostValuableMoverLoss,
          materialDelta: materialDelta,
          betterMoveSan: input.engineBestMoveSan,
          opponentReplySan: playedTrace.opponentReplySan,
          continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
          continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
        );
      } else if (materialDelta >= 3 &&
          evidence.isRecapture != true &&
          !_mateAgainstMover(playedScore, input.isWhiteMove) &&
          _moverScoreIsSound(playedScore, input.isWhiteMove)) {
        add(
          type: MoveInsightClaimType.winsMaterial,
          reason: 'best_response_line_sustains_material_gain',
          priority: 89,
          factIds: const <String>[
            'f_legal',
            'f_played_line',
            'f_played_material',
          ],
          targetRole: playedTrace.mostValuableOpponentLoss,
          materialDelta: materialDelta,
          opponentReplySan: playedTrace.opponentReplySan,
          continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
          continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
        );
      }
    }

    if (features.promotionRole != null) {
      add(
        type: MoveInsightClaimType.promotes,
        reason: 'legal_move_promotes_pawn',
        priority: 75,
        factIds: const <String>['f_legal', 'f_promotion'],
        targetRole: features.promotionRole,
        targetSquare: _normalizedDestination(input.playedMoveUci),
      );
    }
    if (evidence.isRecapture == true && features.capturedRole != null) {
      add(
        type: MoveInsightClaimType.recaptures,
        reason: 'legal_move_recaptures_on_previous_capture_square',
        priority: 55,
        factIds: const <String>['f_legal', 'f_capture'],
        targetRole: features.capturedRole,
        targetSquare: features.capturedSquare,
      );
    }
    final opening = input.openingEvidence.selectedCandidate;
    if (input.openingEvidence.isVerifiedBookTransition && opening != null) {
      add(
        type: MoveInsightClaimType.bookTransition,
        reason: 'verified_exact_opening_transition',
        priority: 30,
        factIds: const <String>['f_legal', 'f_opening'],
        openingEco: opening.ecoCode,
        openingName: opening.openingName,
      );
    }
    return claims;
  }
}

class MoveInsightPlanner {
  const MoveInsightPlanner();

  MoveInsightPlan? select(List<MoveInsightClaimCandidate> candidates) {
    if (candidates.isEmpty) return null;
    final ordered = [...candidates]
      ..sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        return priority != 0
            ? priority
            : a.claim.type.name.compareTo(b.claim.type.name);
      });
    final primary = ordered.first;
    return MoveInsightPlan(
      claim: primary.claim,
      supporting: const <MoveInsightClaim>[],
      causalChain: primary.causalChain,
    );
  }
}

class MoveInsightRenderer {
  const MoveInsightRenderer();

  MoveInsightRenderedCopy render(MoveInsightClaim claim) =>
      renderForVersion(claim, kApexExplanationRendererVersion);

  bool supportsVersion(int version) =>
      version == kApexLegacyExplanationRendererVersion ||
      version == kApexExplanationRendererVersion;

  MoveInsightRenderedCopy renderForVersion(
    MoveInsightClaim claim,
    int version,
  ) {
    return switch (version) {
      kApexLegacyExplanationRendererVersion => _renderV1(claim),
      kApexExplanationRendererVersion => _renderV2(claim),
      _ => throw StateError('Unsupported move insight renderer $version.'),
    };
  }

  MoveInsightRenderedCopy _renderV2(MoveInsightClaim claim) {
    final reply = claim.opponentReplySan;
    final piece = _pieceName(claim.pieceRole);
    final target = _pieceName(claim.targetRole);
    final better = claim.betterMoveSan;
    final continuation = claim.continuationSan.take(4).join(' ');
    late final String concise;
    String? cause;
    String? consequence;
    String? betterMove;
    switch (claim.type) {
      case MoveInsightClaimType.deliversMate:
        concise = 'This move checkmates the king.';
        cause = 'The move gives check and leaves no legal reply.';
        consequence = 'The game ends immediately.';
      case MoveInsightClaimType.createsStalemate:
        concise = 'This move forces stalemate.';
        cause = 'The opponent has no legal move and is not in check.';
        consequence = 'The game is drawn.';
      case MoveInsightClaimType.allowsForcedMate:
        concise = reply == null
            ? 'This allows a forced checkmate.'
            : 'After $reply, checkmate can no longer be prevented.';
        cause = 'The move gives the opponent a forced mating sequence.';
        consequence = 'Even the best defence cannot prevent checkmate.';
        if (better != null) betterMove = '$better avoids the mating sequence.';
      case MoveInsightClaimType.missesForcedMate:
        concise = better == null
            ? 'This lets a forced checkmate slip away.'
            : '$better forces checkmate; this move lets it slip away.';
        cause =
            'The best move forces checkmate, while the played move does not.';
        consequence = 'The forced win is no longer preserved.';
        if (better != null) betterMove = '$better preserves the forced mate.';
      case MoveInsightClaimType.preservesForcedMate:
        concise = reply == null
            ? 'This keeps the forced checkmate intact.'
            : 'After $reply, checkmate remains forced.';
        cause = 'The move stays on the forced mating path.';
        consequence = 'Even the best defence cannot prevent checkmate.';
      case MoveInsightClaimType.winsMaterial:
        concise = target == null
            ? reply == null
                  ? 'The material gain holds.'
                  : 'After $reply, the material gain holds.'
            : reply == null
            ? 'The $target stays won.'
            : 'After $reply, the $target stays won.';
        cause = 'The opponent’s best reply does not recover the material.';
        consequence = _materialConsequence(claim.materialDelta, winning: true);
      case MoveInsightClaimType.dropsMaterial:
        concise = piece == null
            ? reply == null
                  ? 'Material is lost.'
                  : 'After $reply, material is lost.'
            : reply == null
            ? 'The $piece is lost.'
            : 'After $reply, the $piece is lost.';
        cause = 'The opponent’s best reply prevents recovery of the material.';
        consequence = _materialConsequence(claim.materialDelta, winning: false);
        if (better != null) betterMove = '$better avoids that material loss.';
      case MoveInsightClaimType.promotes:
        final promoted = target ?? 'piece';
        final square = claim.targetSquare;
        concise = square == null
            ? 'This promotes the pawn to a $promoted.'
            : 'This promotes the pawn to a $promoted on $square.';
        cause = 'The legal move reaches the promotion rank.';
        consequence = 'The pawn is replaced by a $promoted.';
      case MoveInsightClaimType.recaptures:
        final captured = target ?? 'piece';
        final square = claim.targetSquare;
        concise = square == null
            ? 'This recaptures the $captured.'
            : 'This recaptures the $captured on $square.';
        cause = 'The move captures on the previous capture square.';
        consequence = 'The immediate material exchange is restored.';
      case MoveInsightClaimType.bookTransition:
        final label = <String>[
          if (claim.openingEco?.isNotEmpty == true) claim.openingEco!,
          if (claim.openingName?.isNotEmpty == true) claim.openingName!,
        ].join(' · ');
        concise = label.isEmpty
            ? 'This follows the recorded opening line.'
            : 'This follows $label theory.';
        cause = 'The move and position match the opening reference.';
        consequence = 'The game remains within the recorded opening line.';
    }
    return MoveInsightRenderedCopy(
      concise: concise,
      cause: cause,
      consequence: consequence,
      betterMove: betterMove,
      continuation: continuation.isEmpty ? null : continuation,
    );
  }

  MoveInsightRenderedCopy _renderV1(MoveInsightClaim claim) {
    final reply = claim.opponentReplySan;
    final piece = _pieceName(claim.pieceRole);
    final target = _pieceName(claim.targetRole);
    final better = claim.betterMoveSan;
    final continuation = claim.continuationSan.take(4).join(' ');
    late final String concise;
    String? cause;
    String? consequence;
    String? betterMove;
    switch (claim.type) {
      case MoveInsightClaimType.deliversMate:
        concise = 'This move checkmates the king.';
        cause = 'The legal move reaches a position with no reply to check.';
        consequence = 'The game ends immediately.';
      case MoveInsightClaimType.createsStalemate:
        concise = 'This move forces stalemate.';
        cause = 'The opponent has no legal move and is not in check.';
        consequence = 'The game is drawn.';
      case MoveInsightClaimType.allowsForcedMate:
        concise = reply == null
            ? 'This allows a verified forced mate.'
            : 'After $reply, forced mate cannot be avoided.';
        cause = 'The move gives the opponent a legally verified mating line.';
        consequence = 'Best defence no longer prevents checkmate.';
        if (better != null) betterMove = '$better avoids the mating line.';
      case MoveInsightClaimType.missesForcedMate:
        concise = better == null
            ? 'This lets a verified forced mate slip away.'
            : '$better keeps the forced mate; this move lets it slip away.';
        cause = 'The best line reaches mate, while the played line does not.';
        consequence = 'The forced win is no longer preserved.';
        if (better != null) betterMove = '$better preserves the mating line.';
      case MoveInsightClaimType.preservesForcedMate:
        concise = reply == null
            ? 'This keeps the verified forced mate intact.'
            : 'After $reply, the verified mating line remains forced.';
        cause = 'The move stays inside the legally verified mating line.';
        consequence = 'Best defence still cannot prevent mate.';
      case MoveInsightClaimType.winsMaterial:
        final material = target == null ? 'material' : 'the $target';
        concise = reply == null
            ? 'The verified continuation wins $material.'
            : 'After $reply, the verified continuation wins $material.';
        cause = 'The best-response line leaves a lasting material gain.';
        consequence = _legacyMaterialConsequence(
          claim.materialDelta,
          winning: true,
        );
      case MoveInsightClaimType.dropsMaterial:
        final lost = piece == null ? 'material' : 'the $piece';
        concise = reply == null
            ? 'The verified continuation loses $lost.'
            : 'After $reply, the verified continuation loses $lost.';
        cause = 'The opponent’s best response creates a lasting material loss.';
        consequence = _legacyMaterialConsequence(
          claim.materialDelta,
          winning: false,
        );
        if (better != null) betterMove = '$better avoids that material loss.';
      case MoveInsightClaimType.promotes:
        final promoted = target ?? 'piece';
        final square = claim.targetSquare;
        concise = square == null
            ? 'This promotes the pawn to a $promoted.'
            : 'This promotes the pawn on $square to a $promoted.';
        cause = 'The legal move reaches the promotion rank.';
        consequence = 'The pawn is replaced by a $promoted.';
      case MoveInsightClaimType.recaptures:
        final captured = target ?? 'piece';
        final square = claim.targetSquare;
        concise = square == null
            ? 'This recaptures the $captured.'
            : 'This recaptures the $captured on $square.';
        cause = 'The move captures on the previous capture square.';
        consequence = 'The immediate material exchange is restored.';
      case MoveInsightClaimType.bookTransition:
        final label = <String>[
          if (claim.openingEco?.isNotEmpty == true) claim.openingEco!,
          if (claim.openingName?.isNotEmpty == true) claim.openingName!,
        ].join(' · ');
        concise = label.isEmpty
            ? 'This follows a verified opening transition.'
            : 'This follows $label theory.';
        cause = 'The exact move and position match the verified opening index.';
        consequence = 'The move remains inside the bundled theory path.';
    }
    return MoveInsightRenderedCopy(
      concise: concise,
      cause: cause,
      consequence: consequence,
      betterMove: betterMove,
      continuation: continuation.isEmpty ? null : continuation,
    );
  }

  bool matchesPersisted(MoveInsight insight) {
    if (!insight.hasValidStructure ||
        insight.supportingClaims.isNotEmpty ||
        !supportsVersion(insight.rendererVersion)) {
      return false;
    }
    if (!insight.isDisplayable) {
      return insight.conciseText == null &&
          insight.causeText == null &&
          insight.consequenceText == null &&
          insight.betterMoveText == null &&
          insight.continuationText == null;
    }
    final expected = renderForVersion(
      insight.primaryClaim!,
      insight.rendererVersion,
    );
    return insight.conciseText == expected.concise &&
        insight.causeText == expected.cause &&
        insight.consequenceText == expected.consequence &&
        insight.betterMoveText == expected.betterMove &&
        insight.continuationText == expected.continuation &&
        !_debugTerm.hasMatch(insight.conciseText!);
  }
}

/// Lightweight stored-reference validator. It never detects or plans claims;
/// it only proves that persisted entities still point at the sealed move,
/// opening evidence, and classifier score domains they were created from.
class MoveInsightPersistenceValidator {
  const MoveInsightPersistenceValidator();

  bool validate({
    required MoveInsight insight,
    required String fenBefore,
    required String fenAfter,
    required String playedMoveUci,
    required bool isWhiteMove,
    required MoveClassificationEvidence classificationEvidence,
    required OpeningEvidence openingEvidence,
    required List<EngineLine> preMoveLines,
  }) {
    if (!insight.hasValidStructure) return false;
    if (!insight.isDisplayable) return true;
    try {
      final before = Chess.fromSetup(Setup.parseFen(fenBefore));
      final declaredAfter = Chess.fromSetup(Setup.parseFen(fenAfter));
      final move = _moveFromUci(before, playedMoveUci);
      if (move == null ||
          !before.isLegal(move) ||
          before.turn != (isWhiteMove ? Side.white : Side.black) ||
          before.play(move).fen != declaredAfter.fen) {
        return false;
      }
      final piece = before.board.pieceAt(move.from);
      final legalFact = insight.facts
          .where((fact) => fact.type == MoveInsightFactType.legalTransition)
          .firstOrNull;
      if (piece == null ||
          legalFact == null ||
          legalFact.pieceRole != piece.role.name ||
          legalFact.pieceSide != before.turn.name ||
          legalFact.fromSquare != _squareName(move.from) ||
          legalFact.toSquare != _normalizedDestination(playedMoveUci)) {
        return false;
      }
      final claim = insight.primaryClaim!;
      if (claim.confidence != MoveInsightConfidence.verified ||
          claim.reasonCode != _reasonCodeFor(claim.type) ||
          !_claimPayloadMatchesType(claim) ||
          !_sameStringSet(
            claim.supportingFactIds,
            _requiredFactIdsFor(claim.type),
          )) {
        return false;
      }
      final moverSide = isWhiteMove ? Side.white : Side.black;
      final persistedTrace = claim.continuationUci.isEmpty
          ? null
          : _traceLine(fenBefore, claim.continuationUci, moverSide, fenBefore);
      final preTraces = _traceLines(
        fenBefore,
        preMoveLines,
        moverSide,
        fenBefore,
      );
      bool traceMatches(MoveInsightLineTrace? trace) =>
          trace != null &&
          _sameMoveList(trace.sanMoves, claim.continuationSan) &&
          _sameUciList(trace.uciMoves, claim.continuationUci) &&
          trace.opponentReplySan == claim.opponentReplySan;
      switch (claim.type) {
        case MoveInsightClaimType.deliversMate:
          return before.play(move).isCheckmate &&
              claim.pieceRole == piece.role.name &&
              claim.pieceSquare == _normalizedDestination(playedMoveUci);
        case MoveInsightClaimType.createsStalemate:
          return before.play(move).isStalemate;
        case MoveInsightClaimType.allowsForcedMate:
          return _mateAgainstMover(
                classificationEvidence.playedMoveEvaluation,
                isWhiteMove,
              ) &&
              !_mateAgainstMover(
                classificationEvidence.evaluationBefore,
                isWhiteMove,
              ) &&
              traceMatches(persistedTrace) &&
              _sameUci(persistedTrace!.uciMoves.first, playedMoveUci) &&
              persistedTrace.terminalWinner != moverSide;
        case MoveInsightClaimType.missesForcedMate:
          final bestTrace = preTraces.firstOrNull;
          return _mateForMover(
                classificationEvidence.bestMoveEvaluation,
                isWhiteMove,
              ) &&
              !_mateForMover(
                classificationEvidence.playedMoveEvaluation,
                isWhiteMove,
              ) &&
              claim.betterMoveSan?.isNotEmpty == true &&
              traceMatches(bestTrace) &&
              bestTrace!.terminalWinner == moverSide &&
              classificationEvidence.bestMoveUci != null &&
              _sameUci(
                bestTrace.uciMoves.first,
                classificationEvidence.bestMoveUci!,
              );
        case MoveInsightClaimType.preservesForcedMate:
          return _mateForMover(
                classificationEvidence.evaluationBefore,
                isWhiteMove,
              ) &&
              _mateForMover(
                classificationEvidence.playedMoveEvaluation,
                isWhiteMove,
              ) &&
              traceMatches(persistedTrace) &&
              _sameUci(persistedTrace!.uciMoves.first, playedMoveUci) &&
              persistedTrace.terminalWinner == moverSide;
        case MoveInsightClaimType.winsMaterial:
          return (claim.materialDelta ?? 0) >= 3 &&
              _hasMatchingMaterialFact(insight, claim.materialDelta!) &&
              traceMatches(persistedTrace) &&
              _sameUci(persistedTrace!.uciMoves.first, playedMoveUci) &&
              persistedTrace.materialDelta == claim.materialDelta &&
              persistedTrace.mostValuableOpponentLoss == claim.targetRole &&
              _moverScoreIsSound(
                classificationEvidence.playedMoveEvaluation,
                isWhiteMove,
              );
        case MoveInsightClaimType.dropsMaterial:
          final bestTrace = preTraces.firstOrNull;
          return (claim.materialDelta ?? 0) <= -3 &&
              _hasMatchingMaterialFact(insight, claim.materialDelta!) &&
              traceMatches(persistedTrace) &&
              _sameUci(persistedTrace!.uciMoves.first, playedMoveUci) &&
              persistedTrace.materialDelta == claim.materialDelta &&
              persistedTrace.mostValuableMoverLoss == claim.pieceRole &&
              bestTrace != null &&
              bestTrace.materialDelta - persistedTrace.materialDelta >= 3;
        case MoveInsightClaimType.promotes:
          return move.promotion?.name == claim.targetRole &&
              claim.targetSquare == _normalizedDestination(playedMoveUci);
        case MoveInsightClaimType.recaptures:
          final captured = _capturedPiece(before, move);
          return classificationEvidence.isRecapture == true &&
              captured?.piece.role.name == claim.targetRole &&
              _squareName(captured!.square) == claim.targetSquare;
        case MoveInsightClaimType.bookTransition:
          final selected = openingEvidence.selectedCandidate;
          return openingEvidence.isVerifiedBookTransition &&
              selected != null &&
              selected.ecoCode == claim.openingEco &&
              selected.openingName == claim.openingName;
      }
    } on Object {
      return false;
    }
  }

  bool _hasMatchingMaterialFact(MoveInsight insight, int value) =>
      insight.facts.any(
        (fact) =>
            fact.type == MoveInsightFactType.materialDelta &&
            fact.intValue == value,
      );
}

bool _claimPayloadMatchesType(MoveInsightClaim claim) {
  final hasContinuation =
      claim.continuationSan.isNotEmpty &&
      claim.continuationSan.length == claim.continuationUci.length;
  final noContinuation =
      claim.continuationSan.isEmpty && claim.continuationUci.isEmpty;
  final noPiece = claim.pieceRole == null && claim.pieceSquare == null;
  final noTarget = claim.targetRole == null && claim.targetSquare == null;
  final noMaterial = claim.materialDelta == null;
  final noOpening = claim.openingEco == null && claim.openingName == null;
  switch (claim.type) {
    case MoveInsightClaimType.deliversMate:
      return claim.pieceRole != null &&
          claim.pieceSquare != null &&
          noTarget &&
          noMaterial &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan == null &&
          noContinuation &&
          noOpening;
    case MoveInsightClaimType.createsStalemate:
      return noPiece &&
          noTarget &&
          noMaterial &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan == null &&
          noContinuation &&
          noOpening;
    case MoveInsightClaimType.allowsForcedMate:
      return noPiece &&
          noTarget &&
          noMaterial &&
          claim.opponentReplySan != null &&
          hasContinuation &&
          claim.continuationSan.length >= 2 &&
          noOpening;
    case MoveInsightClaimType.missesForcedMate:
      return noPiece &&
          noTarget &&
          noMaterial &&
          claim.betterMoveSan != null &&
          claim.opponentReplySan == null &&
          hasContinuation &&
          noOpening;
    case MoveInsightClaimType.preservesForcedMate:
      return noPiece &&
          noTarget &&
          noMaterial &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan != null &&
          hasContinuation &&
          claim.continuationSan.length >= 2 &&
          noOpening;
    case MoveInsightClaimType.winsMaterial:
      return noPiece &&
          claim.targetSquare == null &&
          claim.materialDelta != null &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan != null &&
          hasContinuation &&
          claim.continuationSan.length >= 3 &&
          noOpening;
    case MoveInsightClaimType.dropsMaterial:
      return claim.pieceSquare == null &&
          noTarget &&
          claim.materialDelta != null &&
          claim.opponentReplySan != null &&
          hasContinuation &&
          claim.continuationSan.length >= 3 &&
          noOpening;
    case MoveInsightClaimType.promotes:
      return noPiece &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          noMaterial &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan == null &&
          noContinuation &&
          noOpening;
    case MoveInsightClaimType.recaptures:
      return noPiece &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          noMaterial &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan == null &&
          noContinuation &&
          noOpening;
    case MoveInsightClaimType.bookTransition:
      return noPiece &&
          noTarget &&
          noMaterial &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan == null &&
          noContinuation &&
          claim.openingEco != null &&
          claim.openingName != null;
  }
}

class MoveInsightRenderedCopy {
  const MoveInsightRenderedCopy({
    required this.concise,
    this.cause,
    this.consequence,
    this.betterMove,
    this.continuation,
  });

  final String concise;
  final String? cause;
  final String? consequence;
  final String? betterMove;
  final String? continuation;
}

class MoveInsightFeatures {
  const MoveInsightFeatures({
    required this.facts,
    this.contradiction,
    this.before,
    this.after,
    this.playedMove,
    this.movingRole,
    this.capturedRole,
    this.capturedSquare,
    this.promotionRole,
    this.preLines = const <MoveInsightLineTrace>[],
    this.postLines = const <MoveInsightLineTrace>[],
    this.playedTrace,
    this.bestTrace,
  });

  const MoveInsightFeatures.contradictory(String reason)
    : this(facts: const <MoveInsightFact>[], contradiction: reason);

  final List<MoveInsightFact> facts;
  final String? contradiction;
  final Position? before;
  final Position? after;
  final NormalMove? playedMove;
  final String? movingRole;
  final String? capturedRole;
  final String? capturedSquare;
  final String? promotionRole;
  final List<MoveInsightLineTrace> preLines;
  final List<MoveInsightLineTrace> postLines;
  final MoveInsightLineTrace? playedTrace;
  final MoveInsightLineTrace? bestTrace;
}

class MoveInsightClaimCandidate {
  const MoveInsightClaimCandidate({
    required this.claim,
    required this.priority,
    required this.causalChain,
  });

  final MoveInsightClaim claim;
  final int priority;
  final List<MoveInsightCausalStep> causalChain;
}

class MoveInsightPlan {
  const MoveInsightPlan({
    required this.claim,
    required this.supporting,
    required this.causalChain,
  });

  final MoveInsightClaim claim;
  final List<MoveInsightClaim> supporting;
  final List<MoveInsightCausalStep> causalChain;
}

class MoveInsightLineTrace {
  const MoveInsightLineTrace({
    required this.sanMoves,
    required this.uciMoves,
    required this.materialDelta,
    required this.terminalWinner,
    required this.mostValuableMoverLoss,
    required this.mostValuableOpponentLoss,
    required this.moverPromoted,
  });

  final List<String> sanMoves;
  final List<String> uciMoves;
  final int materialDelta;
  final Side? terminalWinner;
  final String? mostValuableMoverLoss;
  final String? mostValuableOpponentLoss;
  final bool moverPromoted;

  String? get opponentReplySan => sanMoves.length > 1 ? sanMoves[1] : null;
}

class _CapturedPiece {
  const _CapturedPiece(this.piece, this.square);

  final Piece piece;
  final Square square;
}

List<MoveInsightLineTrace> _traceLines(
  String fen,
  List<EngineLine> lines,
  Side moverSide,
  String materialBaselineFen,
) {
  final out = <MoveInsightLineTrace>[];
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    if (line.rank != index + 1 ||
        line.depth <= 0 ||
        line.pvMoves.isEmpty ||
        normalizeCastlingUci(line.moveUci ?? '') !=
            normalizeCastlingUci(line.pvMoves.first)) {
      break;
    }
    final trace = _traceLine(fen, line.pvMoves, moverSide, materialBaselineFen);
    if (trace == null) break;
    out.add(trace);
  }
  return out;
}

MoveInsightLineTrace? _traceLine(
  String fen,
  List<String> rawMoves,
  Side moverSide,
  String materialBaselineFen,
) {
  try {
    Position position = Chess.fromSetup(Setup.parseFen(fen));
    final baseline = PositionHeuristics.materialBalanceFromFen(
      materialBaselineFen,
    );
    if (baseline == null || rawMoves.isEmpty) return null;
    final san = <String>[];
    final uciMoves = <String>[];
    final moverLosses = <Role>[];
    final opponentLosses = <Role>[];
    var moverPromoted = false;
    for (var ply = 0; ply < rawMoves.length && ply < 12; ply++) {
      final move = _moveFromUci(position, rawMoves[ply]);
      if (move == null || !position.isLegal(move)) return null;
      final movingSide = position.turn;
      final captured = _capturedPiece(position, move);
      if (captured != null) {
        if (captured.piece.color == moverSide) {
          moverLosses.add(captured.piece.role);
        } else {
          opponentLosses.add(captured.piece.role);
        }
      }
      if (movingSide == moverSide && move.promotion != null) {
        moverPromoted = true;
      }
      san.add(position.makeSan(move).$2);
      uciMoves.add(rawMoves[ply].toLowerCase());
      position = position.play(move);
      if (position.isCheckmate || position.isStalemate) break;
    }
    final after = PositionHeuristics.materialBalanceFromFen(position.fen);
    if (after == null) return null;
    final sign = moverSide == Side.white ? 1 : -1;
    final winner = position.isCheckmate
        ? (position.turn == Side.white ? Side.black : Side.white)
        : null;
    return MoveInsightLineTrace(
      sanMoves: List<String>.unmodifiable(san),
      uciMoves: List<String>.unmodifiable(uciMoves),
      materialDelta: (after - baseline) * sign,
      terminalWinner: winner,
      mostValuableMoverLoss: _mostValuableRole(moverLosses),
      mostValuableOpponentLoss: _mostValuableRole(opponentLosses),
      moverPromoted: moverPromoted,
    );
  } on Object {
    return null;
  }
}

bool _preLinesCoherent(
  MoveClassificationEvidence evidence,
  List<EngineLine> lines,
  List<MoveInsightLineTrace> traces,
) {
  if (lines.isEmpty) return evidence.candidates.isEmpty;
  if (traces.length != lines.length ||
      evidence.candidates.length != lines.length ||
      !evidence.hasStructurallyCoherentCandidates) {
    return false;
  }
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final candidate = evidence.candidates[index];
    if (candidate.rank != line.rank ||
        normalizeCastlingUci(candidate.rootUci) !=
            normalizeCastlingUci(line.moveUci ?? '') ||
        candidate.achievedDepth != line.depth ||
        candidate.score.whiteCp != line.scoreCp ||
        candidate.score.whiteMate != line.mateIn) {
      return false;
    }
  }
  return true;
}

bool _postLinesCoherent(MoveInsightInput input) {
  final played = input.classificationEvidence.playedMoveEvaluation;
  if (!input.postMoveSearchQualityMet ||
      played == null ||
      !played.isValid ||
      input.postMoveLines.isEmpty) {
    return false;
  }
  for (var index = 0; index < input.postMoveLines.length; index++) {
    final line = input.postMoveLines[index];
    final scoreDomainValid =
        (line.scoreCp != null) != (line.mateIn != null) && line.mateIn != 0;
    if (line.rank != index + 1 ||
        line.depth <= 0 ||
        line.pvMoves.isEmpty ||
        !scoreDomainValid ||
        !_sameUci(line.moveUci ?? '', line.pvMoves.first)) {
      return false;
    }
  }
  final first = input.postMoveLines.first;
  return first.scoreCp == played.whiteCp && first.mateIn == played.whiteMate;
}

List<MoveInsightCausalStep> _defaultCausalChain(
  List<String> factIds, {
  required bool hasResponse,
}) {
  if (factIds.isEmpty) return const <MoveInsightCausalStep>[];
  final out = <MoveInsightCausalStep>[
    MoveInsightCausalStep(
      stage: MoveInsightCausalStage.move,
      factId: factIds.first,
    ),
  ];
  if (factIds.length > 1) {
    out.add(
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.changedFact,
        factId: factIds[1],
      ),
    );
  }
  if (hasResponse && factIds.length > 1) {
    out.add(
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.response,
        factId: factIds[1],
      ),
    );
  }
  out.add(
    MoveInsightCausalStep(
      stage: MoveInsightCausalStage.outcome,
      factId: factIds.last,
    ),
  );
  return out;
}

NormalMove? _moveFromUci(Position position, String raw) {
  final uci = normalizeCastlingUci(raw.toLowerCase());
  if (uci.length != 4 && uci.length != 5) return null;
  NormalMove? build(String value) {
    final from = _parseSquare(value.substring(0, 2));
    final to = _parseSquare(value.substring(2, 4));
    if (from == null || to == null) return null;
    final promotion = value.length == 5
        ? switch (value[4]) {
            'q' => Role.queen,
            'r' => Role.rook,
            'b' => Role.bishop,
            'n' => Role.knight,
            _ => null,
          }
        : null;
    if (value.length == 5 && promotion == null) return null;
    return NormalMove(from: from, to: to, promotion: promotion);
  }

  final direct = build(uci);
  if (direct != null && position.isLegal(direct)) return direct;
  final suffix = uci.length == 5 ? uci.substring(4) : '';
  final castlingAlias = switch (uci.substring(0, 4)) {
    'e1g1' => 'e1h1$suffix',
    'e1c1' => 'e1a1$suffix',
    'e8g8' => 'e8h8$suffix',
    'e8c8' => 'e8a8$suffix',
    _ => uci,
  };
  final alias = build(castlingAlias);
  return alias != null && position.isLegal(alias) ? alias : direct;
}

_CapturedPiece? _capturedPiece(Position position, NormalMove move) {
  final target = position.board.pieceAt(move.to);
  if (target != null) return _CapturedPiece(target, move.to);
  final moving = position.board.pieceAt(move.from);
  if (moving?.role != Role.pawn || move.from.file == move.to.file) return null;
  final square = Square(move.to.file + move.from.rank * 8);
  final enPassant = position.board.pieceAt(square);
  return enPassant == null ? null : _CapturedPiece(enPassant, square);
}

Square? _parseSquare(String algebraic) {
  if (algebraic.length != 2) return null;
  final file = algebraic.codeUnitAt(0) - 97;
  final rank = algebraic.codeUnitAt(1) - 49;
  if (file < 0 || file > 7 || rank < 0 || rank > 7) return null;
  return Square(file + rank * 8);
}

String _squareName(Square square) =>
    '${String.fromCharCode(97 + square.file)}${square.rank + 1}';

String _normalizedDestination(String uci) {
  final normalized = normalizeCastlingUci(uci);
  return normalized.length >= 4 ? normalized.substring(2, 4) : '';
}

bool _sameMoveList(List<String> actual, List<String> expected) {
  if (actual.length != expected.length) return false;
  for (var index = 0; index < actual.length; index++) {
    if (actual[index] != expected[index]) return false;
  }
  return true;
}

bool _sameUciList(List<String> actual, List<String> expected) {
  if (actual.length != expected.length) return false;
  for (var index = 0; index < actual.length; index++) {
    if (!_sameUci(actual[index], expected[index])) return false;
  }
  return true;
}

bool _sameUci(String first, String second) =>
    normalizeCastlingUci(first) == normalizeCastlingUci(second);

String _reasonCodeFor(MoveInsightClaimType type) => switch (type) {
  MoveInsightClaimType.deliversMate => 'legal_move_reaches_checkmate',
  MoveInsightClaimType.createsStalemate => 'legal_move_reaches_stalemate',
  MoveInsightClaimType.allowsForcedMate =>
    'score_and_legal_reply_line_allow_mate',
  MoveInsightClaimType.missesForcedMate =>
    'verified_best_line_mates_but_played_move_does_not',
  MoveInsightClaimType.preservesForcedMate =>
    'verified_played_line_preserves_mate',
  MoveInsightClaimType.winsMaterial =>
    'best_response_line_sustains_material_gain',
  MoveInsightClaimType.dropsMaterial =>
    'best_response_line_sustains_material_loss',
  MoveInsightClaimType.promotes => 'legal_move_promotes_pawn',
  MoveInsightClaimType.recaptures =>
    'legal_move_recaptures_on_previous_capture_square',
  MoveInsightClaimType.bookTransition => 'verified_exact_opening_transition',
};

List<String> _requiredFactIdsFor(MoveInsightClaimType type) => switch (type) {
  MoveInsightClaimType.deliversMate => const <String>[
    'f_legal',
    'f_terminal_mate',
  ],
  MoveInsightClaimType.createsStalemate => const <String>['f_legal'],
  MoveInsightClaimType.allowsForcedMate ||
  MoveInsightClaimType.preservesForcedMate => const <String>[
    'f_legal',
    'f_played_line',
  ],
  MoveInsightClaimType.missesForcedMate => const <String>[
    'f_legal',
    'f_best_line',
  ],
  MoveInsightClaimType.winsMaterial => const <String>[
    'f_legal',
    'f_played_line',
    'f_played_material',
  ],
  MoveInsightClaimType.dropsMaterial => const <String>[
    'f_legal',
    'f_played_line',
    'f_played_material',
    'f_best_line',
  ],
  MoveInsightClaimType.promotes => const <String>['f_legal', 'f_promotion'],
  MoveInsightClaimType.recaptures => const <String>['f_legal', 'f_capture'],
  MoveInsightClaimType.bookTransition => const <String>['f_legal', 'f_opening'],
};

bool _sameStringSet(List<String> first, List<String> second) =>
    first.length == second.length && first.toSet().containsAll(second);

bool _mateForMover(ClassificationScore? score, bool white) {
  final mate = score?.whiteMate;
  return mate != null && (white ? mate > 0 : mate < 0);
}

bool _mateAgainstMover(ClassificationScore? score, bool white) {
  final mate = score?.whiteMate;
  return mate != null && (white ? mate < 0 : mate > 0);
}

bool _moverScoreIsSound(ClassificationScore? score, bool white) {
  if (score == null || !score.isValid) return false;
  if (_mateAgainstMover(score, white)) return false;
  if (_mateForMover(score, white)) return true;
  final cp = score.whiteCp;
  if (cp == null) return false;
  return (white ? cp : -cp) >= -100;
}

bool _isAdverseClassification(MoveQuality quality) => switch (quality) {
  MoveQuality.inaccuracy ||
  MoveQuality.mistake ||
  MoveQuality.missedWin ||
  MoveQuality.blunder => true,
  _ => false,
};

int _legalMoveCount(Position position) {
  var count = 0;
  position.legalMoves.forEach((from, destinations) {
    final piece = position.board.pieceAt(from);
    for (final square in destinations.squares) {
      final promotion =
          piece?.role == Role.pawn && (square.rank == 0 || square.rank == 7);
      count += promotion ? 4 : 1;
    }
  });
  return count;
}

String? _mostValuableRole(List<Role> roles) {
  if (roles.isEmpty) return null;
  final sorted = [...roles]
    ..sort(
      (a, b) => PositionHeuristics.pieceValue(
        b,
      ).compareTo(PositionHeuristics.pieceValue(a)),
    );
  return sorted.first.name;
}

String? _pieceName(String? role) => switch (role) {
  'pawn' => 'pawn',
  'knight' => 'knight',
  'bishop' => 'bishop',
  'rook' => 'rook',
  'queen' => 'queen',
  'king' => 'king',
  _ => null,
};

String _materialConsequence(int? delta, {required bool winning}) {
  final amount = delta?.abs();
  if (amount == null) {
    return winning
        ? 'The material gain remains secure.'
        : 'The material loss cannot be recovered.';
  }
  return winning
      ? 'The lasting material gain is worth at least $amount points.'
      : 'The lasting material loss is worth at least $amount points.';
}

String _legacyMaterialConsequence(int? delta, {required bool winning}) {
  final amount = delta?.abs();
  if (amount == null) {
    return winning
        ? 'The gain survives the verified reply sequence.'
        : 'The loss survives the verified reply sequence.';
  }
  return winning
      ? 'The line finishes at least $amount material points ahead of the start.'
      : 'The line finishes at least $amount material points below the start.';
}

final RegExp _debugTerm = RegExp(
  r'\b(stockfish|pv\d*|centipawns?|debug|uci|fen)\b',
  caseSensitive: false,
);
