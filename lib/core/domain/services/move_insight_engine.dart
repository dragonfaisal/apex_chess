/// Deterministic facts → claims → causal selection → language boundary.
///
/// The engine consumes only evidence already produced by normal analysis. It
/// never calls Stockfish, parses PGN, changes classifications, or guesses a
/// human intention.
library;

import 'dart:convert';

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
  const MoveInsightFeatureExtractor({
    this.causalityAnalyzer = const MoveInsightCausalityAnalyzer(),
  });

  final MoveInsightCausalityAnalyzer causalityAnalyzer;

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
      facts.add(
        MoveInsightFact(
          id: 'f_best_material',
          type: MoveInsightFactType.materialDelta,
          intValue: bestTrace.materialDelta,
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
    final alternativeIndexes = _onlyMoveMateAlternativeIndexes(
      evidence: input.classificationEvidence,
      playedMoveUci: input.playedMoveUci,
      isWhiteMove: input.isWhiteMove,
      traces: preLines,
      moverSide: moverSide,
    );
    if (input.classification == MoveQuality.onlyMove &&
        alternativeIndexes != null) {
      facts.add(
        MoveInsightFact(
          id: 'f_alternative_outcome',
          type: MoveInsightFactType.alternativeOutcome,
          intValue: alternativeIndexes.length,
          relationType: MoveInsightRelationType.alternativeAllowsMate,
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
    final causalProofs = causalityAnalyzer.analyze(
      input: input,
      before: before,
      after: calculatedAfter,
      playedMove: played,
      moverSide: moverSide,
      movingRole: movingPiece.role.name,
      playedTrace: playedTrace,
      bestTrace: bestTrace,
    );
    facts.addAll(causalProofs.map((proof) => proof.toFact(moverSide)));
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
      causalProofs: causalProofs,
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

/// Pure board-relationship analysis over the already accepted legal move and
/// stored engine continuations. Geometry only nominates a mechanism; every
/// returned proof also contains a concrete mate or material consequence.
class MoveInsightCausalityAnalyzer {
  const MoveInsightCausalityAnalyzer();

  static const _proofFactory = _MoveInsightCausalProofFactory();

  List<MoveInsightCausalProof> analyze({
    required MoveInsightInput input,
    required Position before,
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace? playedTrace,
    required MoveInsightLineTrace? bestTrace,
  }) {
    final evidence = input.classificationEvidence;
    final playedScore = evidence.playedMoveEvaluation;
    final materialGain =
        playedTrace != null &&
        playedTrace.steps.length >= 4 &&
        playedTrace.materialDelta >= 3 &&
        _moverScoreIsSound(playedScore, input.isWhiteMove);
    final proofs = <MoveInsightCausalProof>[];

    if (materialGain) {
      final fork = _proofFactory._forkProof(
        before: before,
        after: after,
        playedMove: playedMove,
        moverSide: moverSide,
        movingRole: movingRole,
        trace: playedTrace,
      );
      if (fork != null) proofs.add(fork);

      final pin = _proofFactory._pinProof(
        after: after,
        playedMove: playedMove,
        moverSide: moverSide,
        movingRole: movingRole,
        trace: playedTrace,
      );
      if (pin != null) proofs.add(pin);

      final skewer = _proofFactory._skewerProof(
        after: after,
        playedMove: playedMove,
        moverSide: moverSide,
        movingRole: movingRole,
        trace: playedTrace,
      );
      if (skewer != null) proofs.add(skewer);

      final discovery = _proofFactory._discoveredAttackProof(
        before: before,
        after: after,
        playedMove: playedMove,
        moverSide: moverSide,
        movingRole: movingRole,
        trace: playedTrace,
      );
      if (discovery != null) proofs.add(discovery);

      final removedDefender = _proofFactory._removedDefenderProof(
        before: before,
        after: after,
        playedMove: playedMove,
        moverSide: moverSide,
        movingRole: movingRole,
        trace: playedTrace,
      );
      if (removedDefender != null) proofs.add(removedDefender);
    }

    final sacrifice = _proofFactory._sacrificeProof(
      input: input,
      playedMove: playedMove,
      moverSide: moverSide,
      movingRole: movingRole,
      playedTrace: playedTrace,
      bestTrace: bestTrace,
    );
    if (sacrifice != null) proofs.add(sacrifice);

    proofs.sort((a, b) {
      final priority = b.priority.compareTo(a.priority);
      return priority != 0
          ? priority
          : a.mechanism.name.compareTo(b.mechanism.name);
    });
    return List<MoveInsightCausalProof>.unmodifiable(proofs);
  }
}

class _MoveInsightCausalProofFactory {
  const _MoveInsightCausalProofFactory();

  MoveInsightCausalProof? _sacrificeProof({
    required MoveInsightInput input,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace? playedTrace,
    required MoveInsightLineTrace? bestTrace,
  }) {
    final evidence = input.classificationEvidence;
    final movedPieceLost = playedTrace == null
        ? null
        : _trackedTargetCapture(
            playedTrace.steps,
            initialSquare: _squareName(playedMove.to),
            owner: moverSide,
            role: movingRole,
          );
    final isRealInvestment =
        movedPieceLost != null &&
        movedPieceLost.capturerSide == _opposite(moverSide) &&
        evidence.isSacrifice == true &&
        evidence.isFirstSacrificePly == true &&
        evidence.isRecapture != true &&
        evidence.isTrivialRecapture != true &&
        evidence.isFreeCapture != true &&
        _roleValue(movingRole) >= 3;
    if (!isRealInvestment) return null;

    final playedScore = evidence.playedMoveEvaluation;
    final materialGain =
        playedTrace!.steps.length >= 4 &&
        playedTrace.materialDelta >= 3 &&
        _moverScoreIsSound(playedScore, input.isWhiteMove);
    final materialLoss =
        bestTrace != null &&
        playedTrace.steps.length >= 3 &&
        playedTrace.materialDelta <= -3 &&
        bestTrace.materialDelta - playedTrace.materialDelta >= 3 &&
        _isAdverseClassification(input.classification);
    final mateForMover =
        playedTrace.terminalWinner == moverSide &&
        _mateForMover(playedScore, input.isWhiteMove);
    final isSound =
        evidence.searchQualityMet &&
        evidence.hasCompleteCandidateSet &&
        evidence.bestMovePv1Consistent &&
        evidence.tacticalBestOrNearBest &&
        evidence.tacticalHasForcingOutcome &&
        (mateForMover || materialGain);
    if (isSound) {
      return MoveInsightCausalProof(
        mechanism: MoveInsightMechanismType.soundSacrifice,
        consequence: mateForMover
            ? MoveInsightConsequenceType.checkmate
            : MoveInsightConsequenceType.materialGain,
        relationType: MoveInsightRelationType.investsMaterial,
        reasonCode: mateForMover
            ? 'material_investment_forces_mate'
            : 'material_investment_wins_material',
        priority: mateForMover ? 99 : 94,
        initiatorRole: movingRole,
        initiatorSquare: _squareName(playedMove.to),
        targetRole: movedPieceLost.capturedRole,
        targetSquare: movedPieceLost.capturedSquare,
      );
    }
    if (!materialLoss) return null;
    return MoveInsightCausalProof(
      mechanism: MoveInsightMechanismType.unsoundSacrifice,
      consequence: MoveInsightConsequenceType.materialLoss,
      relationType: MoveInsightRelationType.investsMaterial,
      reasonCode: 'material_investment_has_no_compensation',
      priority: 94,
      initiatorRole: movingRole,
      initiatorSquare: _squareName(playedMove.to),
      targetRole: movedPieceLost.capturedRole,
      targetSquare: movedPieceLost.capturedSquare,
    );
  }

  MoveInsightCausalProof? _forkProof({
    required Position before,
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace trace,
  }) {
    final opponent = _opposite(moverSide);
    final targets = _attackedTargets(after, playedMove.to, opponent)
        .where(
          (target) => _roleValue(target.role) >= 3 || target.role == 'king',
        )
        .where(
          (target) => _attackerCount(before, target.square, moverSide) == 0,
        )
        .toList(growable: false);
    if (targets.length < 2) return null;
    if (targets.any(
      (target) =>
          after.isLegal(NormalMove(from: target.square, to: playedMove.to)),
    )) {
      return null;
    }
    for (final target in targets) {
      final capture = _trackedTargetCapture(
        trace.steps,
        initialSquare: _squareName(target.square),
        owner: opponent,
        role: target.role,
      );
      if (capture?.capturerSide != moverSide ||
          capture?.capturerInitialSquare != _squareName(playedMove.to) ||
          target.role == 'king') {
        continue;
      }
      final other = targets
          .where((candidate) => candidate.square != target.square)
          .reduce((a, b) => _roleValue(a.role) >= _roleValue(b.role) ? a : b);
      final mechanism = other.role == 'king'
          ? MoveInsightMechanismType.fork
          : MoveInsightMechanismType.doubleAttack;
      return MoveInsightCausalProof(
        mechanism: mechanism,
        consequence: MoveInsightConsequenceType.materialGain,
        relationType: MoveInsightRelationType.attacks,
        reasonCode: mechanism == MoveInsightMechanismType.fork
            ? 'new_fork_survives_best_response'
            : 'new_double_attack_survives_best_response',
        priority: other.role == 'king' ? 88 : 84,
        initiatorRole: movingRole,
        initiatorSquare: _squareName(playedMove.to),
        attackerRole: movingRole,
        attackerSquare: _squareName(playedMove.to),
        targetRole: target.role,
        targetSquare: _squareName(target.square),
        secondaryTargetRole: other.role,
        secondaryTargetSquare: _squareName(other.square),
      );
    }
    return null;
  }

  MoveInsightCausalProof? _pinProof({
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace trace,
  }) {
    if (!_isSlider(movingRole)) return null;
    final opponent = _opposite(moverSide);
    for (final ray in _occupiedRays(after, playedMove.to, movingRole)) {
      if (ray.pieces.length < 2) continue;
      final pinned = ray.pieces[0];
      final king = ray.pieces[1];
      if (pinned.side != opponent ||
          king.side != opponent ||
          pinned.role == 'king' ||
          king.role != 'king' ||
          _roleValue(pinned.role) < 3) {
        continue;
      }
      if (after.isLegal(NormalMove(from: pinned.square, to: playedMove.to))) {
        continue;
      }
      final capture = _trackedTargetCapture(
        trace.steps,
        initialSquare: _squareName(pinned.square),
        owner: opponent,
        role: pinned.role,
      );
      if (capture?.capturerSide != moverSide ||
          capture?.capturerInitialSquare != _squareName(playedMove.to)) {
        continue;
      }
      return MoveInsightCausalProof(
        mechanism: MoveInsightMechanismType.absolutePin,
        consequence: MoveInsightConsequenceType.materialGain,
        relationType: MoveInsightRelationType.pinsToKing,
        reasonCode: 'absolute_pin_is_exploited_in_best_response',
        priority: 86,
        attackerRole: movingRole,
        attackerSquare: _squareName(playedMove.to),
        targetRole: pinned.role,
        targetSquare: _squareName(pinned.square),
        secondaryTargetRole: king.role,
        secondaryTargetSquare: _squareName(king.square),
        lineType: ray.lineType,
        lineSquares: ray.squares,
      );
    }
    return null;
  }

  MoveInsightCausalProof? _skewerProof({
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace trace,
  }) {
    if (!_isSlider(movingRole) || trace.steps.length < 3) return null;
    final opponent = _opposite(moverSide);
    for (final ray in _occupiedRays(after, playedMove.to, movingRole)) {
      if (ray.pieces.length < 2) continue;
      final front = ray.pieces[0];
      final rear = ray.pieces[1];
      if (front.side != opponent ||
          rear.side != opponent ||
          _roleValue(front.role) <= _roleValue(rear.role) ||
          _roleValue(rear.role) < 3) {
        continue;
      }
      final capturesAttacker = NormalMove(
        from: front.square,
        to: playedMove.to,
      );
      if (after.isLegal(capturesAttacker)) continue;
      final reply = trace.steps[1];
      final consequence = trace.steps[2];
      if (reply.movingSide != opponent ||
          reply.fromSquare != _squareName(front.square) ||
          consequence.movingSide != moverSide ||
          consequence.fromSquare != _squareName(playedMove.to) ||
          consequence.capturedSquare != _squareName(rear.square) ||
          consequence.capturedRole != rear.role) {
        continue;
      }
      return MoveInsightCausalProof(
        mechanism: MoveInsightMechanismType.skewer,
        consequence: MoveInsightConsequenceType.materialGain,
        relationType: MoveInsightRelationType.skewers,
        reasonCode: 'front_target_moves_and_rear_target_is_lost',
        priority: 87,
        attackerRole: movingRole,
        attackerSquare: _squareName(playedMove.to),
        targetRole: rear.role,
        targetSquare: _squareName(rear.square),
        secondaryTargetRole: front.role,
        secondaryTargetSquare: _squareName(front.square),
        lineType: ray.lineType,
        lineSquares: ray.squares,
      );
    }
    return null;
  }

  MoveInsightCausalProof? _discoveredAttackProof({
    required Position before,
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace trace,
  }) {
    if (trace.steps.length < 3) return null;
    final from = playedMove.from;
    final opponent = _opposite(moverSide);
    for (final direction in _rayDirections) {
      final attacker = _firstOccupied(
        before,
        from,
        -direction.$1,
        -direction.$2,
      );
      final target = _firstOccupied(before, from, direction.$1, direction.$2);
      if (attacker == null ||
          target == null ||
          attacker.side != moverSide ||
          target.side != opponent ||
          !_sliderSupports(attacker.role, direction.$1, direction.$2) ||
          _roleValue(target.role) < 3 ||
          !_attacksSquare(after, attacker.square, target.square)) {
        continue;
      }
      final consequence = trace.steps[2];
      if (consequence.movingSide != moverSide ||
          consequence.fromSquare != _squareName(attacker.square) ||
          consequence.capturedSquare != _squareName(target.square) ||
          consequence.capturedRole != target.role) {
        continue;
      }
      final line = _raySquares(attacker.square, target.square);
      return MoveInsightCausalProof(
        mechanism: MoveInsightMechanismType.discoveredAttack,
        consequence: MoveInsightConsequenceType.materialGain,
        relationType: MoveInsightRelationType.opensLine,
        reasonCode: 'moved_blocker_opens_exploited_line',
        priority: 89,
        initiatorRole: movingRole,
        initiatorSquare: _squareName(playedMove.to),
        attackerRole: attacker.role,
        attackerSquare: _squareName(attacker.square),
        targetRole: target.role,
        targetSquare: _squareName(target.square),
        lineType: _lineTypeFor(direction.$1, direction.$2),
        lineSquares: line,
      );
    }
    return null;
  }

  MoveInsightCausalProof? _removedDefenderProof({
    required Position before,
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace trace,
  }) {
    if (trace.steps.length < 3) return null;
    final captured = _capturedPiece(before, playedMove);
    final opponent = _opposite(moverSide);
    if (captured == null || captured.piece.color != opponent) return null;
    for (var index = 0; index < 64; index++) {
      final square = Square(index);
      final target = after.board.pieceAt(square);
      if (target == null ||
          target.color != opponent ||
          target.role == Role.king ||
          PositionHeuristics.pieceValue(target.role) < 3 ||
          !_attacksSquare(before, captured.square, square) ||
          _defenderCount(after, square, opponent) != 0) {
        continue;
      }
      final consequence = trace.steps[2];
      if (consequence.movingSide != moverSide ||
          consequence.capturedSquare != _squareName(square) ||
          consequence.capturedRole != target.role.name) {
        continue;
      }
      return MoveInsightCausalProof(
        mechanism: MoveInsightMechanismType.removesDefender,
        consequence: MoveInsightConsequenceType.materialGain,
        relationType: MoveInsightRelationType.removesDefense,
        reasonCode: 'captured_defender_exposes_target',
        priority: 91,
        initiatorRole: movingRole,
        initiatorSquare: _squareName(playedMove.to),
        targetRole: target.role.name,
        targetSquare: _squareName(square),
        defenderRole: captured.piece.role.name,
        defenderSquare: _squareName(captured.square),
      );
    }
    return null;
  }
}

class MoveInsightCausalProof {
  const MoveInsightCausalProof({
    required this.mechanism,
    required this.consequence,
    required this.relationType,
    required this.reasonCode,
    required this.priority,
    this.initiatorRole,
    this.initiatorSquare,
    this.attackerRole,
    this.attackerSquare,
    this.targetRole,
    this.targetSquare,
    this.secondaryTargetRole,
    this.secondaryTargetSquare,
    this.defenderRole,
    this.defenderSquare,
    this.lineType,
    this.lineSquares = const <String>[],
  });

  final MoveInsightMechanismType mechanism;
  final MoveInsightConsequenceType consequence;
  final MoveInsightRelationType relationType;
  final String reasonCode;
  final int priority;
  final String? initiatorRole;
  final String? initiatorSquare;
  final String? attackerRole;
  final String? attackerSquare;
  final String? targetRole;
  final String? targetSquare;
  final String? secondaryTargetRole;
  final String? secondaryTargetSquare;
  final String? defenderRole;
  final String? defenderSquare;
  final MoveInsightLineType? lineType;
  final List<String> lineSquares;

  String get factId => 'f_causal_${mechanism.name.toLowerCase()}';

  MoveInsightFact toFact(Side moverSide) => MoveInsightFact(
    id: factId,
    type:
        mechanism == MoveInsightMechanismType.soundSacrifice ||
            mechanism == MoveInsightMechanismType.unsoundSacrifice
        ? MoveInsightFactType.materialInvestment
        : MoveInsightFactType.changedRelationship,
    pieceRole: attackerRole ?? initiatorRole,
    pieceSide: moverSide.name,
    fromSquare: attackerSquare ?? initiatorSquare,
    toSquare: targetSquare,
    relationType: relationType,
    relatedPieceRole: targetRole,
    relatedPieceSide:
        mechanism == MoveInsightMechanismType.soundSacrifice ||
            mechanism == MoveInsightMechanismType.unsoundSacrifice
        ? moverSide.name
        : _opposite(moverSide).name,
    relatedSquare: targetSquare,
    secondaryPieceRole: secondaryTargetRole ?? defenderRole,
    secondaryPieceSide: _opposite(moverSide).name,
    secondarySquare: secondaryTargetSquare ?? defenderSquare,
    lineType: lineType,
    lineSquares: lineSquares,
  );
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
    MoveInsightCausalProof? proofWhere(
      bool Function(MoveInsightCausalProof proof) predicate,
    ) => features.causalProofs.where(predicate).firstOrNull;

    List<String> factsWithProof(
      List<String> base,
      MoveInsightCausalProof? proof,
    ) => proof == null ? base : <String>[...base, proof.factId];

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
      MoveInsightCausalProof? mechanismProof,
      MoveInsightMechanismType mechanism = MoveInsightMechanismType.none,
      MoveInsightConsequenceType consequence = MoveInsightConsequenceType.none,
      String? mechanismReasonCode,
      String? initiatorRole,
      String? initiatorSquare,
      String? secondaryTargetRole,
      String? secondaryTargetSquare,
      String? defenderRole,
      String? defenderSquare,
      MoveInsightRelationType? relationType,
      MoveInsightLineType? lineType,
      List<String> lineSquares = const <String>[],
      List<MoveInsightCausalStep>? causalChain,
    }) {
      final proof = mechanismProof;
      claims.add(
        MoveInsightClaimCandidate(
          priority: priority,
          claim: MoveInsightClaim(
            id: 'c_${type.name.toLowerCase()}',
            type: type,
            confidence: MoveInsightConfidence.verified,
            reasonCode: reason,
            supportingFactIds: factIds,
            pieceRole: proof?.attackerRole ?? pieceRole,
            pieceSquare: proof?.attackerSquare ?? pieceSquare,
            targetRole: proof?.targetRole ?? targetRole,
            targetSquare: proof?.targetSquare ?? targetSquare,
            materialDelta: materialDelta,
            betterMoveSan: betterMoveSan,
            opponentReplySan: opponentReplySan,
            continuationSan: continuationSan,
            continuationUci: continuationUci,
            openingEco: openingEco,
            openingName: openingName,
            mechanism: proof?.mechanism ?? mechanism,
            consequence: proof?.consequence ?? consequence,
            mechanismReasonCode: proof?.reasonCode ?? mechanismReasonCode,
            initiatorRole: proof?.initiatorRole ?? initiatorRole,
            initiatorSquare: proof?.initiatorSquare ?? initiatorSquare,
            secondaryTargetRole:
                proof?.secondaryTargetRole ?? secondaryTargetRole,
            secondaryTargetSquare:
                proof?.secondaryTargetSquare ?? secondaryTargetSquare,
            defenderRole: proof?.defenderRole ?? defenderRole,
            defenderSquare: proof?.defenderSquare ?? defenderSquare,
            relationType: proof?.relationType ?? relationType,
            lineType: proof?.lineType ?? lineType,
            lineSquares: proof?.lineSquares ?? lineSquares,
          ),
          causalChain:
              causalChain ??
              (proof == null
                  ? _defaultCausalChain(
                      factIds,
                      hasResponse: opponentReplySan != null,
                    )
                  : _advancedCausalChain(factIds, proof)),
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
      final sacrifice = proofWhere(
        (proof) =>
            proof.mechanism == MoveInsightMechanismType.soundSacrifice &&
            proof.consequence == MoveInsightConsequenceType.checkmate,
      );
      add(
        type: MoveInsightClaimType.preservesForcedMate,
        reason: 'verified_played_line_preserves_mate',
        priority: 94,
        factIds: factsWithProof(const <String>[
          'f_legal',
          'f_played_line',
        ], sacrifice),
        opponentReplySan: playedTrace.opponentReplySan,
        continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
        continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
        mechanismProof: sacrifice,
      );
    }

    final onlyMoveAlternativeFact = features.facts.any(
      (fact) => fact.id == 'f_alternative_outcome',
    );
    if (input.classification == MoveQuality.onlyMove &&
        onlyMoveAlternativeFact &&
        bestTrace != null &&
        bestTrace.sanMoves.length >= 2 &&
        _sameUci(bestTrace.uciMoves.first, input.playedMoveUci)) {
      add(
        type: MoveInsightClaimType.onlyMoveDefense,
        reason: 'complete_alternatives_allow_forced_mate',
        priority: 92,
        factIds: const <String>[
          'f_legal',
          'f_best_line',
          'f_alternative_outcome',
        ],
        opponentReplySan: bestTrace.opponentReplySan,
        continuationSan: bestTrace.sanMoves.take(6).toList(growable: false),
        continuationUci: bestTrace.uciMoves.take(6).toList(growable: false),
        mechanism: MoveInsightMechanismType.onlyMoveDefense,
        consequence: MoveInsightConsequenceType.avoidsCheckmate,
        mechanismReasonCode: 'alternatives_allow_forced_mate',
        relationType: MoveInsightRelationType.alternativeAllowsMate,
      );
    }

    if (input.classification == MoveQuality.missedWin &&
        bestTrace != null &&
        bestTrace.sanMoves.length >= 3 &&
        bestTrace.materialDelta >= 3 &&
        (playedTrace == null ||
            bestTrace.materialDelta - playedTrace.materialDelta >= 3) &&
        input.engineBestMoveSan?.isNotEmpty == true &&
        !_mateForMover(bestScore, input.isWhiteMove)) {
      add(
        type: MoveInsightClaimType.missesMaterialWin,
        reason: 'best_line_wins_material_but_played_move_does_not',
        priority: 93,
        factIds: const <String>['f_legal', 'f_best_line', 'f_best_material'],
        targetRole: bestTrace.mostValuableOpponentLoss,
        materialDelta: bestTrace.materialDelta,
        betterMoveSan: input.engineBestMoveSan,
        opponentReplySan: bestTrace.opponentReplySan,
        continuationSan: bestTrace.sanMoves.take(6).toList(growable: false),
        continuationUci: bestTrace.uciMoves.take(6).toList(growable: false),
        mechanism: MoveInsightMechanismType.missedMaterialResource,
        consequence: MoveInsightConsequenceType.missedMaterialGain,
        mechanismReasonCode: 'best_line_wins_material',
        relationType: MoveInsightRelationType.alternativeWinsMaterial,
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
        final sacrifice = proofWhere(
          (proof) =>
              proof.mechanism == MoveInsightMechanismType.unsoundSacrifice,
        );
        add(
          type: MoveInsightClaimType.dropsMaterial,
          reason: 'best_response_line_sustains_material_loss',
          priority: 90,
          factIds: factsWithProof(const <String>[
            'f_legal',
            'f_played_line',
            'f_played_material',
            'f_best_line',
          ], sacrifice),
          pieceRole: playedTrace.mostValuableMoverLoss,
          materialDelta: materialDelta,
          betterMoveSan: input.engineBestMoveSan,
          opponentReplySan: playedTrace.opponentReplySan,
          continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
          continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
          mechanismProof: sacrifice,
        );
      } else if (materialDelta >= 3 &&
          evidence.isRecapture != true &&
          !_mateAgainstMover(playedScore, input.isWhiteMove) &&
          _moverScoreIsSound(playedScore, input.isWhiteMove)) {
        final mechanism = proofWhere(
          (proof) =>
              proof.consequence == MoveInsightConsequenceType.materialGain,
        );
        add(
          type: MoveInsightClaimType.winsMaterial,
          reason: 'best_response_line_sustains_material_gain',
          priority: 89,
          factIds: factsWithProof(const <String>[
            'f_legal',
            'f_played_line',
            'f_played_material',
          ], mechanism),
          targetRole: playedTrace.mostValuableOpponentLoss,
          materialDelta: materialDelta,
          opponentReplySan: playedTrace.opponentReplySan,
          continuationSan: playedTrace.sanMoves.take(6).toList(growable: false),
          continuationUci: playedTrace.uciMoves.take(6).toList(growable: false),
          mechanismProof: mechanism,
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

  MoveInsightRenderedCopy renderForVersion(
    MoveInsightClaim claim,
    int version,
  ) {
    return switch (version) {
      kApexLegacyExplanationRendererVersion => _renderV1(claim),
      kApexChapter6ExplanationRendererVersion => _renderV2(claim),
      kApexExplanationRendererVersion => _renderV3(claim),
      _ => throw StateError('Unsupported move insight renderer $version.'),
    };
  }

  MoveInsightRenderedCopy _renderV3(MoveInsightClaim claim) {
    if (claim.mechanism == MoveInsightMechanismType.none) {
      return _renderV2(claim);
    }
    final attacker = _pieceName(claim.pieceRole) ?? 'piece';
    final initiator = _pieceName(claim.initiatorRole) ?? attacker;
    final target = _pieceName(claim.targetRole) ?? 'piece';
    final secondary = _pieceName(claim.secondaryTargetRole) ?? 'piece';
    final defender = _pieceName(claim.defenderRole) ?? 'defender';
    final better = claim.betterMoveSan;
    final continuation = claim.continuationSan.take(4).join(' ');
    late final String concise;
    String? cause;
    String? consequence;
    String? betterMove;
    switch (claim.mechanism) {
      case MoveInsightMechanismType.fork:
        concise =
            'The $attacker forks the $secondary and $target, so the $target cannot be saved.';
        cause = 'One move creates two immediate threats.';
        consequence = 'The best response still loses the $target.';
      case MoveInsightMechanismType.doubleAttack:
        concise = secondary == target
            ? 'The $attacker attacks two ${target}s at once, and one $target is lost.'
            : 'The $attacker attacks the $secondary and $target at once, and the $target is lost.';
        cause = 'The two threats cannot both be answered.';
        consequence = 'The best response still loses the $target.';
      case MoveInsightMechanismType.absolutePin:
        concise =
            'The $attacker pins the $target to the king, and the $target is lost.';
        cause = 'Moving the $target off the line would expose the king.';
        consequence = 'The best response cannot save the $target.';
      case MoveInsightMechanismType.skewer:
        concise =
            'The $attacker skewers the $secondary and $target, and the $target is lost.';
        cause = 'The $secondary must move from the line first.';
        consequence = 'That exposes the $target behind it.';
      case MoveInsightMechanismType.discoveredAttack ||
          MoveInsightMechanismType.opensLine:
        concise =
            'Moving the $initiator opens the $attacker’s attack on the $target, and the $target is lost.';
        cause = 'The move clears the line between the pieces.';
        consequence = 'The best response cannot save the $target.';
      case MoveInsightMechanismType.removesDefender:
        concise =
            'Capturing the $defender removes the $target’s defender, and the $target is lost.';
        cause = 'The capture removes the target’s remaining protection.';
        consequence = 'The continuation wins the $target.';
      case MoveInsightMechanismType.soundSacrifice:
        concise = claim.consequence == MoveInsightConsequenceType.checkmate
            ? 'The $initiator sacrifice forces checkmate.'
            : 'The $initiator sacrifice wins lasting material.';
        cause = 'The material investment creates a forcing continuation.';
        consequence = claim.consequence == MoveInsightConsequenceType.checkmate
            ? 'Even the best defence cannot prevent checkmate.'
            : 'The material is recovered with a lasting gain.';
      case MoveInsightMechanismType.unsoundSacrifice:
        concise =
            'The $initiator sacrifice does not work, and the $initiator is lost.';
        cause =
            'The best response accepts the sacrifice without allowing compensation.';
        consequence = 'The material loss cannot be recovered.';
        if (better != null) betterMove = '$better avoids the failed sacrifice.';
      case MoveInsightMechanismType.onlyMoveDefense:
        concise = 'Only this move prevents a forced checkmate.';
        cause = 'Every other analysed move allows a mating sequence.';
        consequence = 'The played move keeps checkmate from being forced.';
      case MoveInsightMechanismType.missedMaterialResource:
        concise = better == null
            ? 'This misses a forced material win.'
            : '$better wins the $target; this move misses that chance.';
        cause = 'The better move starts a forcing material sequence.';
        consequence = 'The played move gives up that material gain.';
        if (better != null) betterMove = '$better wins the $target.';
      case MoveInsightMechanismType.none:
        throw StateError('Causal renderer requires a mechanism.');
    }
    return MoveInsightRenderedCopy(
      concise: concise,
      cause: cause,
      consequence: consequence,
      betterMove: betterMove,
      continuation: continuation.isEmpty ? null : continuation,
    );
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
      case MoveInsightClaimType.missesMaterialWin:
        concise = better == null
            ? 'This misses a material win.'
            : '$better wins material; this move misses that chance.';
        cause = 'The better move starts a forcing material sequence.';
        consequence = 'The played move gives up that material gain.';
        if (better != null) betterMove = '$better wins material.';
      case MoveInsightClaimType.onlyMoveDefense:
        concise = 'Only this move prevents a forced checkmate.';
        cause = 'Every other analysed move allows a mating sequence.';
        consequence = 'The played move keeps checkmate from being forced.';
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
      case MoveInsightClaimType.missesMaterialWin:
        concise = better == null
            ? 'This misses a material win.'
            : '$better wins material; this move misses that chance.';
        cause = 'The best line wins material while the played line does not.';
        consequence = 'The material opportunity is lost.';
        if (better != null) betterMove = '$better wins material.';
      case MoveInsightClaimType.onlyMoveDefense:
        concise = 'Only this move avoids forced mate.';
        cause = 'The alternatives allow a mating line.';
        consequence = 'The move keeps the position alive.';
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
    required MoveQuality classification,
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
          !_claimPayloadMatchesType(claim, insight.claimSchemaVersion) ||
          !_sameStringSet(
            claim.supportingFactIds,
            _requiredFactIdsForClaim(claim),
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
      final referenceInput = MoveInsightInput(
        fenBefore: fenBefore,
        fenAfter: fenAfter,
        playedMoveUci: playedMoveUci,
        playedMoveSan: '',
        isWhiteMove: isWhiteMove,
        classification: classification,
        classificationEvidence: classificationEvidence,
        preMoveLines: preMoveLines,
        postMoveLines: const <EngineLine>[],
        postMoveSearchQualityMet: true,
        engineBestMoveSan: claim.betterMoveSan,
        openingEvidence: openingEvidence,
      );
      final mechanismMatches = _causalMechanismMatches(
        insight: insight,
        claim: claim,
        input: referenceInput,
        before: before,
        after: declaredAfter,
        playedMove: move,
        moverSide: moverSide,
        movingRole: piece.role.name,
        playedTrace: persistedTrace,
        bestTrace: preTraces.firstOrNull,
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
              persistedTrace.terminalWinner == moverSide &&
              mechanismMatches;
        case MoveInsightClaimType.missesMaterialWin:
          final bestTrace = preTraces.firstOrNull;
          return classification == MoveQuality.missedWin &&
              bestTrace != null &&
              bestTrace.materialDelta >= 3 &&
              claim.materialDelta == bestTrace.materialDelta &&
              claim.targetRole == bestTrace.mostValuableOpponentLoss &&
              claim.betterMoveSan?.isNotEmpty == true &&
              traceMatches(bestTrace) &&
              claim.mechanism ==
                  MoveInsightMechanismType.missedMaterialResource &&
              claim.consequence ==
                  MoveInsightConsequenceType.missedMaterialGain;
        case MoveInsightClaimType.onlyMoveDefense:
          final alternativeIndexes = _onlyMoveMateAlternativeIndexes(
            evidence: classificationEvidence,
            playedMoveUci: playedMoveUci,
            isWhiteMove: isWhiteMove,
            traces: preTraces,
            moverSide: moverSide,
          );
          return classification == MoveQuality.onlyMove &&
              alternativeIndexes != null &&
              claim.mechanism == MoveInsightMechanismType.onlyMoveDefense &&
              claim.consequence == MoveInsightConsequenceType.avoidsCheckmate &&
              traceMatches(preTraces.firstOrNull);
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
              ) &&
              mechanismMatches;
        case MoveInsightClaimType.dropsMaterial:
          final bestTrace = preTraces.firstOrNull;
          return (claim.materialDelta ?? 0) <= -3 &&
              _hasMatchingMaterialFact(insight, claim.materialDelta!) &&
              traceMatches(persistedTrace) &&
              _sameUci(persistedTrace!.uciMoves.first, playedMoveUci) &&
              persistedTrace.materialDelta == claim.materialDelta &&
              persistedTrace.mostValuableMoverLoss == claim.pieceRole &&
              bestTrace != null &&
              bestTrace.materialDelta - persistedTrace.materialDelta >= 3 &&
              mechanismMatches;
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

  bool _causalMechanismMatches({
    required MoveInsight insight,
    required MoveInsightClaim claim,
    required MoveInsightInput input,
    required Position before,
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace? playedTrace,
    required MoveInsightLineTrace? bestTrace,
  }) {
    if (claim.mechanism == MoveInsightMechanismType.none) {
      return claim.consequence == MoveInsightConsequenceType.none &&
          _claimHasNoCausalPayload(claim);
    }
    const factory = _MoveInsightCausalProofFactory();
    final proof = switch (claim.mechanism) {
      MoveInsightMechanismType.fork || MoveInsightMechanismType.doubleAttack =>
        playedTrace == null
            ? null
            : factory._forkProof(
                before: before,
                after: after,
                playedMove: playedMove,
                moverSide: moverSide,
                movingRole: movingRole,
                trace: playedTrace,
              ),
      MoveInsightMechanismType.absolutePin =>
        playedTrace == null
            ? null
            : factory._pinProof(
                after: after,
                playedMove: playedMove,
                moverSide: moverSide,
                movingRole: movingRole,
                trace: playedTrace,
              ),
      MoveInsightMechanismType.skewer =>
        playedTrace == null
            ? null
            : factory._skewerProof(
                after: after,
                playedMove: playedMove,
                moverSide: moverSide,
                movingRole: movingRole,
                trace: playedTrace,
              ),
      MoveInsightMechanismType.discoveredAttack ||
      MoveInsightMechanismType.opensLine =>
        playedTrace == null
            ? null
            : factory._discoveredAttackProof(
                before: before,
                after: after,
                playedMove: playedMove,
                moverSide: moverSide,
                movingRole: movingRole,
                trace: playedTrace,
              ),
      MoveInsightMechanismType.removesDefender =>
        playedTrace == null
            ? null
            : factory._removedDefenderProof(
                before: before,
                after: after,
                playedMove: playedMove,
                moverSide: moverSide,
                movingRole: movingRole,
                trace: playedTrace,
              ),
      MoveInsightMechanismType.soundSacrifice ||
      MoveInsightMechanismType.unsoundSacrifice => factory._sacrificeProof(
        input: input,
        playedMove: playedMove,
        moverSide: moverSide,
        movingRole: movingRole,
        playedTrace: playedTrace,
        bestTrace: bestTrace,
      ),
      MoveInsightMechanismType.onlyMoveDefense ||
      MoveInsightMechanismType.missedMaterialResource ||
      MoveInsightMechanismType.none => null,
    };
    if (proof == null ||
        proof.mechanism != claim.mechanism ||
        proof.consequence != claim.consequence ||
        proof.reasonCode != claim.mechanismReasonCode ||
        proof.initiatorRole != claim.initiatorRole ||
        proof.initiatorSquare != claim.initiatorSquare ||
        proof.attackerRole != claim.pieceRole ||
        proof.attackerSquare != claim.pieceSquare ||
        proof.targetRole != claim.targetRole ||
        proof.targetSquare != claim.targetSquare ||
        proof.secondaryTargetRole != claim.secondaryTargetRole ||
        proof.secondaryTargetSquare != claim.secondaryTargetSquare ||
        proof.defenderRole != claim.defenderRole ||
        proof.defenderSquare != claim.defenderSquare ||
        proof.relationType != claim.relationType ||
        proof.lineType != claim.lineType ||
        !_sameMoveList(proof.lineSquares, claim.lineSquares)) {
      return false;
    }
    final facts = insight.facts.where((fact) => fact.id == proof.factId);
    if (facts.length != 1) return false;
    return jsonEncode(facts.single.toJson()) ==
        jsonEncode(proof.toFact(moverSide).toJson());
  }
}

bool _claimPayloadMatchesType(MoveInsightClaim claim, int schemaVersion) {
  if (schemaVersion == kApexLegacyExplanationClaimSchemaVersion) {
    return claim.mechanism == MoveInsightMechanismType.none &&
        claim.consequence == MoveInsightConsequenceType.none &&
        _legacyClaimPayloadMatchesType(claim);
  }
  if (schemaVersion != kApexExplanationClaimSchemaVersion) return false;
  if (claim.mechanism == MoveInsightMechanismType.none) {
    return claim.consequence == MoveInsightConsequenceType.none &&
        _claimHasNoCausalPayload(claim) &&
        _legacyClaimPayloadMatchesType(claim);
  }
  final hasContinuation =
      claim.continuationSan.isNotEmpty &&
      claim.continuationSan.length == claim.continuationUci.length;
  final hasMechanismIdentity =
      claim.mechanismReasonCode?.isNotEmpty == true &&
      claim.relationType != null;
  if (!hasMechanismIdentity) return false;
  switch (claim.mechanism) {
    case MoveInsightMechanismType.fork || MoveInsightMechanismType.doubleAttack:
      return claim.type == MoveInsightClaimType.winsMaterial &&
          claim.consequence == MoveInsightConsequenceType.materialGain &&
          claim.pieceRole != null &&
          claim.pieceSquare != null &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          claim.secondaryTargetRole != null &&
          claim.secondaryTargetSquare != null &&
          claim.defenderRole == null &&
          claim.lineSquares.isEmpty &&
          hasContinuation;
    case MoveInsightMechanismType.absolutePin ||
        MoveInsightMechanismType.skewer:
      return claim.type == MoveInsightClaimType.winsMaterial &&
          claim.consequence == MoveInsightConsequenceType.materialGain &&
          claim.pieceRole != null &&
          claim.pieceSquare != null &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          claim.secondaryTargetRole != null &&
          claim.secondaryTargetSquare != null &&
          claim.lineType != null &&
          claim.lineSquares.isNotEmpty &&
          hasContinuation;
    case MoveInsightMechanismType.discoveredAttack ||
        MoveInsightMechanismType.opensLine:
      return claim.type == MoveInsightClaimType.winsMaterial &&
          claim.consequence == MoveInsightConsequenceType.materialGain &&
          claim.initiatorRole != null &&
          claim.initiatorSquare != null &&
          claim.pieceRole != null &&
          claim.pieceSquare != null &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          claim.lineType != null &&
          claim.lineSquares.isNotEmpty &&
          hasContinuation;
    case MoveInsightMechanismType.removesDefender:
      return claim.type == MoveInsightClaimType.winsMaterial &&
          claim.consequence == MoveInsightConsequenceType.materialGain &&
          claim.initiatorRole != null &&
          claim.initiatorSquare != null &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          claim.defenderRole != null &&
          claim.defenderSquare != null &&
          hasContinuation;
    case MoveInsightMechanismType.soundSacrifice:
      return (claim.type == MoveInsightClaimType.preservesForcedMate ||
              claim.type == MoveInsightClaimType.winsMaterial) &&
          (claim.consequence == MoveInsightConsequenceType.checkmate ||
              claim.consequence == MoveInsightConsequenceType.materialGain) &&
          claim.initiatorRole != null &&
          claim.initiatorSquare != null &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          hasContinuation;
    case MoveInsightMechanismType.unsoundSacrifice:
      return claim.type == MoveInsightClaimType.dropsMaterial &&
          claim.consequence == MoveInsightConsequenceType.materialLoss &&
          claim.initiatorRole != null &&
          claim.initiatorSquare != null &&
          claim.targetRole != null &&
          claim.targetSquare != null &&
          claim.betterMoveSan != null &&
          hasContinuation;
    case MoveInsightMechanismType.onlyMoveDefense:
      return claim.type == MoveInsightClaimType.onlyMoveDefense &&
          claim.consequence == MoveInsightConsequenceType.avoidsCheckmate &&
          claim.betterMoveSan == null &&
          claim.opponentReplySan != null &&
          hasContinuation;
    case MoveInsightMechanismType.missedMaterialResource:
      return claim.type == MoveInsightClaimType.missesMaterialWin &&
          claim.consequence == MoveInsightConsequenceType.missedMaterialGain &&
          claim.targetRole != null &&
          claim.materialDelta != null &&
          claim.betterMoveSan != null &&
          claim.opponentReplySan != null &&
          hasContinuation;
    case MoveInsightMechanismType.none:
      return false;
  }
}

bool _claimHasNoCausalPayload(MoveInsightClaim claim) =>
    claim.mechanismReasonCode == null &&
    claim.initiatorRole == null &&
    claim.initiatorSquare == null &&
    claim.secondaryTargetRole == null &&
    claim.secondaryTargetSquare == null &&
    claim.defenderRole == null &&
    claim.defenderSquare == null &&
    claim.relationType == null &&
    claim.lineType == null &&
    claim.lineSquares.isEmpty;

bool _legacyClaimPayloadMatchesType(MoveInsightClaim claim) {
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
    case MoveInsightClaimType.missesMaterialWin ||
        MoveInsightClaimType.onlyMoveDefense:
      return false;
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
    this.causalProofs = const <MoveInsightCausalProof>[],
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
  final List<MoveInsightCausalProof> causalProofs;
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
    required this.steps,
    required this.materialDelta,
    required this.terminalWinner,
    required this.mostValuableMoverLoss,
    required this.mostValuableOpponentLoss,
    required this.moverPromoted,
  });

  final List<String> sanMoves;
  final List<String> uciMoves;
  final List<MoveInsightLineStep> steps;
  final int materialDelta;
  final Side? terminalWinner;
  final String? mostValuableMoverLoss;
  final String? mostValuableOpponentLoss;
  final bool moverPromoted;

  String? get opponentReplySan => sanMoves.length > 1 ? sanMoves[1] : null;
}

class MoveInsightLineStep {
  const MoveInsightLineStep({
    required this.before,
    required this.after,
    required this.move,
    required this.movingRole,
    required this.movingSide,
    required this.fromSquare,
    required this.toSquare,
    required this.capturedRole,
    required this.capturedSide,
    required this.capturedSquare,
  });

  final Position before;
  final Position after;
  final NormalMove move;
  final String movingRole;
  final Side movingSide;
  final String fromSquare;
  final String toSquare;
  final String? capturedRole;
  final Side? capturedSide;
  final String? capturedSquare;
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
    final steps = <MoveInsightLineStep>[];
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
      final next = position.play(move);
      steps.add(
        MoveInsightLineStep(
          before: position,
          after: next,
          move: move,
          movingRole: position.board.pieceAt(move.from)?.role.name ?? 'pawn',
          movingSide: movingSide,
          fromSquare: _squareName(move.from),
          toSquare: _normalizedDestination(rawMoves[ply]),
          capturedRole: captured?.piece.role.name,
          capturedSide: captured?.piece.color,
          capturedSquare: captured == null
              ? null
              : _squareName(captured.square),
        ),
      );
      position = next;
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
      steps: List<MoveInsightLineStep>.unmodifiable(steps),
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

List<MoveInsightCausalStep> _advancedCausalChain(
  List<String> factIds,
  MoveInsightCausalProof proof,
) {
  final response = factIds.where(
    (id) => id == 'f_played_line' || id == 'f_best_line',
  );
  final outcome = factIds.where(
    (id) =>
        id == 'f_terminal_mate' ||
        id == 'f_played_material' ||
        id == 'f_best_material' ||
        id == 'f_alternative_outcome',
  );
  return <MoveInsightCausalStep>[
    const MoveInsightCausalStep(
      stage: MoveInsightCausalStage.move,
      factId: 'f_legal',
    ),
    MoveInsightCausalStep(
      stage: MoveInsightCausalStage.changedFact,
      factId: proof.factId,
    ),
    if (response.isNotEmpty)
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.response,
        factId: response.first,
      ),
    MoveInsightCausalStep(
      stage: MoveInsightCausalStage.outcome,
      factId: outcome.isNotEmpty ? outcome.first : proof.factId,
    ),
  ];
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

List<int>? _onlyMoveMateAlternativeIndexes({
  required MoveClassificationEvidence evidence,
  required String playedMoveUci,
  required bool isWhiteMove,
  required List<MoveInsightLineTrace> traces,
  required Side moverSide,
}) {
  if (!evidence.searchQualityMet ||
      !evidence.hasCompleteCandidateSet ||
      !evidence.bestMovePv1Consistent ||
      evidence.requestedMultiPv < 3 ||
      evidence.candidates.length < 3 ||
      evidence.legalMoveCount == null ||
      evidence.legalMoveCount! <= 1 ||
      traces.length != evidence.candidates.length ||
      !_sameUci(evidence.candidates.first.rootUci, playedMoveUci) ||
      !_sameUci(traces.first.uciMoves.first, playedMoveUci)) {
    return null;
  }
  final alternatives = <int>[
    for (var index = 0; index < evidence.candidates.length; index++)
      if (!_sameUci(evidence.candidates[index].rootUci, playedMoveUci)) index,
  ];
  if (alternatives.length < 2 ||
      alternatives.any(
        (index) =>
            !_mateAgainstMover(evidence.candidates[index].score, isWhiteMove) ||
            traces[index].terminalWinner != _opposite(moverSide),
      )) {
    return null;
  }
  return alternatives;
}

Side _opposite(Side side) => side == Side.white ? Side.black : Side.white;

int _roleValue(String role) => switch (role) {
  'pawn' => 1,
  'knight' || 'bishop' => 3,
  'rook' => 5,
  'queen' => 9,
  'king' => 100,
  _ => 0,
};

bool _isSlider(String role) =>
    role == 'bishop' || role == 'rook' || role == 'queen';

bool _sliderSupports(String role, int fileStep, int rankStep) {
  final diagonal = fileStep != 0 && rankStep != 0;
  return role == 'queen' ||
      (role == 'bishop' && diagonal) ||
      (role == 'rook' && !diagonal);
}

bool _attacksSquare(Position position, Square from, Square to) {
  final piece = position.board.pieceAt(from);
  if (piece == null || from == to) return false;
  final fileDelta = to.file - from.file;
  final rankDelta = to.rank - from.rank;
  switch (piece.role) {
    case Role.pawn:
      final forward = piece.color == Side.white ? 1 : -1;
      return rankDelta == forward && fileDelta.abs() == 1;
    case Role.knight:
      return (fileDelta.abs() == 1 && rankDelta.abs() == 2) ||
          (fileDelta.abs() == 2 && rankDelta.abs() == 1);
    case Role.king:
      return fileDelta.abs() <= 1 && rankDelta.abs() <= 1;
    case Role.bishop || Role.rook || Role.queen:
      break;
  }
  if (piece.role == Role.bishop && fileDelta.abs() != rankDelta.abs()) {
    return false;
  }
  if (piece.role == Role.rook && fileDelta != 0 && rankDelta != 0) {
    return false;
  }
  if (piece.role == Role.queen &&
      fileDelta != 0 &&
      rankDelta != 0 &&
      fileDelta.abs() != rankDelta.abs()) {
    return false;
  }
  final fileStep = fileDelta.sign;
  final rankStep = rankDelta.sign;
  var file = from.file + fileStep;
  var rank = from.rank + rankStep;
  while (file != to.file || rank != to.rank) {
    if (position.board.pieceAt(Square(file + rank * 8)) != null) return false;
    file += fileStep;
    rank += rankStep;
  }
  return true;
}

List<_BoardTarget> _attackedTargets(
  Position position,
  Square attacker,
  Side targetSide,
) {
  final out = <_BoardTarget>[];
  for (var index = 0; index < 64; index++) {
    final square = Square(index);
    final piece = position.board.pieceAt(square);
    if (piece != null &&
        piece.color == targetSide &&
        _attacksSquare(position, attacker, square)) {
      out.add(
        _BoardTarget(role: piece.role.name, side: piece.color, square: square),
      );
    }
  }
  out.sort((a, b) {
    final value = _roleValue(b.role).compareTo(_roleValue(a.role));
    return value != 0
        ? value
        : _squareName(a.square).compareTo(_squareName(b.square));
  });
  return out;
}

List<_OccupiedRay> _occupiedRays(
  Position position,
  Square from,
  String sliderRole,
) {
  final out = <_OccupiedRay>[];
  for (final direction in _rayDirections) {
    if (!_sliderSupports(sliderRole, direction.$1, direction.$2)) continue;
    var file = from.file + direction.$1;
    var rank = from.rank + direction.$2;
    final pieces = <_BoardTarget>[];
    final squares = <String>[];
    while (file >= 0 && file < 8 && rank >= 0 && rank < 8) {
      final square = Square(file + rank * 8);
      squares.add(_squareName(square));
      final piece = position.board.pieceAt(square);
      if (piece != null) {
        pieces.add(
          _BoardTarget(
            role: piece.role.name,
            side: piece.color,
            square: square,
          ),
        );
        if (pieces.length == 2) break;
      }
      file += direction.$1;
      rank += direction.$2;
    }
    if (pieces.isNotEmpty) {
      out.add(
        _OccupiedRay(
          pieces: pieces,
          squares: squares,
          lineType: _lineTypeFor(direction.$1, direction.$2),
        ),
      );
    }
  }
  return out;
}

_BoardTarget? _firstOccupied(
  Position position,
  Square from,
  int fileStep,
  int rankStep,
) {
  var file = from.file + fileStep;
  var rank = from.rank + rankStep;
  while (file >= 0 && file < 8 && rank >= 0 && rank < 8) {
    final square = Square(file + rank * 8);
    final piece = position.board.pieceAt(square);
    if (piece != null) {
      return _BoardTarget(
        role: piece.role.name,
        side: piece.color,
        square: square,
      );
    }
    file += fileStep;
    rank += rankStep;
  }
  return null;
}

MoveInsightLineType _lineTypeFor(int fileStep, int rankStep) {
  if (fileStep == 0) return MoveInsightLineType.file;
  if (rankStep == 0) return MoveInsightLineType.rank;
  return MoveInsightLineType.diagonal;
}

List<String> _raySquares(Square from, Square to) {
  final fileDelta = to.file - from.file;
  final rankDelta = to.rank - from.rank;
  if (fileDelta != 0 && rankDelta != 0 && fileDelta.abs() != rankDelta.abs()) {
    return const <String>[];
  }
  final out = <String>[];
  var file = from.file + fileDelta.sign;
  var rank = from.rank + rankDelta.sign;
  while (file != to.file || rank != to.rank) {
    out.add(_squareName(Square(file + rank * 8)));
    file += fileDelta.sign;
    rank += rankDelta.sign;
  }
  out.add(_squareName(to));
  return out;
}

int _defenderCount(Position position, Square target, Side side) {
  var count = 0;
  for (var index = 0; index < 64; index++) {
    final from = Square(index);
    final piece = position.board.pieceAt(from);
    if (from != target &&
        piece?.color == side &&
        _attacksSquare(position, from, target)) {
      count++;
    }
  }
  return count;
}

int _attackerCount(Position position, Square target, Side side) =>
    _defenderCount(position, target, side);

_CausalCapture? _trackedTargetCapture(
  List<MoveInsightLineStep> steps, {
  required String initialSquare,
  required Side owner,
  required String role,
}) {
  var square = initialSquare;
  for (var index = 1; index < steps.length; index++) {
    final step = steps[index];
    if (step.capturedSquare == square &&
        step.capturedSide == owner &&
        step.capturedRole == role) {
      return _CausalCapture(
        capturedRole: role,
        capturedSquare: square,
        capturerSide: step.movingSide,
        capturerRole: step.movingRole,
        capturerInitialSquare: step.fromSquare,
        linePly: index,
      );
    }
    if (step.movingSide == owner &&
        step.movingRole == role &&
        step.fromSquare == square) {
      square = step.toSquare;
    }
  }
  return null;
}

class _BoardTarget {
  const _BoardTarget({
    required this.role,
    required this.side,
    required this.square,
  });

  final String role;
  final Side side;
  final Square square;
}

class _OccupiedRay {
  const _OccupiedRay({
    required this.pieces,
    required this.squares,
    required this.lineType,
  });

  final List<_BoardTarget> pieces;
  final List<String> squares;
  final MoveInsightLineType lineType;
}

class _CausalCapture {
  const _CausalCapture({
    required this.capturedRole,
    required this.capturedSquare,
    required this.capturerSide,
    required this.capturerRole,
    required this.capturerInitialSquare,
    required this.linePly,
  });

  final String capturedRole;
  final String capturedSquare;
  final Side capturerSide;
  final String capturerRole;
  final String capturerInitialSquare;
  final int linePly;
}

const List<(int, int)> _rayDirections = <(int, int)>[
  (1, 0),
  (-1, 0),
  (0, 1),
  (0, -1),
  (1, 1),
  (1, -1),
  (-1, 1),
  (-1, -1),
];

String _reasonCodeFor(MoveInsightClaimType type) => switch (type) {
  MoveInsightClaimType.deliversMate => 'legal_move_reaches_checkmate',
  MoveInsightClaimType.createsStalemate => 'legal_move_reaches_stalemate',
  MoveInsightClaimType.allowsForcedMate =>
    'score_and_legal_reply_line_allow_mate',
  MoveInsightClaimType.missesForcedMate =>
    'verified_best_line_mates_but_played_move_does_not',
  MoveInsightClaimType.preservesForcedMate =>
    'verified_played_line_preserves_mate',
  MoveInsightClaimType.missesMaterialWin =>
    'best_line_wins_material_but_played_move_does_not',
  MoveInsightClaimType.onlyMoveDefense =>
    'complete_alternatives_allow_forced_mate',
  MoveInsightClaimType.winsMaterial =>
    'best_response_line_sustains_material_gain',
  MoveInsightClaimType.dropsMaterial =>
    'best_response_line_sustains_material_loss',
  MoveInsightClaimType.promotes => 'legal_move_promotes_pawn',
  MoveInsightClaimType.recaptures =>
    'legal_move_recaptures_on_previous_capture_square',
  MoveInsightClaimType.bookTransition => 'verified_exact_opening_transition',
};

List<String> _requiredFactIdsForClaim(MoveInsightClaim claim) {
  final base = switch (claim.type) {
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
    MoveInsightClaimType.missesMaterialWin => const <String>[
      'f_legal',
      'f_best_line',
      'f_best_material',
    ],
    MoveInsightClaimType.onlyMoveDefense => const <String>[
      'f_legal',
      'f_best_line',
      'f_alternative_outcome',
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
    MoveInsightClaimType.bookTransition => const <String>[
      'f_legal',
      'f_opening',
    ],
  };
  return claim.mechanism == MoveInsightMechanismType.none ||
          claim.mechanism == MoveInsightMechanismType.onlyMoveDefense ||
          claim.mechanism == MoveInsightMechanismType.missedMaterialResource
      ? base
      : <String>[...base, 'f_causal_${claim.mechanism.name.toLowerCase()}'];
}

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
