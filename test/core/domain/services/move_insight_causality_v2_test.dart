import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_insight_engine.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

void main() {
  const engine = MoveInsightEngine();

  group('advanced board causality', () {
    test('White knight fork wins the queen after the best response', () {
      final insight = engine.generate(
        _input(
          fen: 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1',
          uci: 'b5c7',
          playedScore: const ClassificationScore.cp(700),
          postMoves: const <String>['e8f8', 'c7a8', 'f8g8'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.fork);
      expect(insight.primaryClaim?.targetRole, 'queen');
      expect(insight.primaryClaim?.secondaryTargetRole, 'king');
      expect(
        insight.conciseText,
        'The knight forks the king and queen, so the queen cannot be saved.',
      );
    });

    test('Black mover fork preserves mover perspective', () {
      final insight = engine.generate(
        _input(
          fen: '4k3/8/8/8/1n6/8/8/Q3K3 b - - 0 1',
          uci: 'b4c2',
          playedScore: const ClassificationScore.cp(-700),
          postMoves: const <String>['e1f1', 'c2a1', 'f1g1'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.fork);
      expect(
        insight.facts
            .where((fact) => fact.id == 'f_causal_fork')
            .single
            .pieceSide,
        'black',
      );
    });

    test('double attack requires a target to remain lost', () {
      final insight = engine.generate(
        _input(
          fen: '4k3/8/6r1/8/8/8/2r1B3/4K3 w - - 0 1',
          uci: 'e2d3',
          playedScore: const ClassificationScore.cp(500),
          postMoves: const <String>['g6g8', 'd3c2', 'e8f7'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.doubleAttack);
      expect(
        insight.conciseText,
        'The bishop attacks two rooks at once, and one rook is lost.',
      );
    });

    test('absolute pin is public only when the pinned rook is won', () {
      final insight = engine.generate(
        _input(
          fen: '4k3/7p/2r5/8/8/8/4B3/4K3 w - - 0 1',
          uci: 'e2b5',
          playedScore: const ClassificationScore.cp(500),
          postMoves: const <String>['h7h6', 'b5c6', 'e8f8'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.absolutePin);
      expect(insight.primaryClaim?.secondaryTargetRole, 'king');
    });

    test('skewer requires the front king move and rear rook capture', () {
      final insight = engine.generate(
        _input(
          fen: '4r3/3k4/8/8/8/8/4B3/5K2 w - - 0 1',
          uci: 'e2b5',
          playedScore: const ClassificationScore.cp(500),
          postMoves: const <String>['d7c8', 'b5e8', 'c8b7'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.skewer);
      expect(insight.primaryClaim?.targetRole, 'rook');
      expect(insight.primaryClaim?.secondaryTargetRole, 'king');
    });

    test('moving blocker opens a line that wins the queen', () {
      final insight = engine.generate(
        _input(
          fen: 'q7/8/8/3k4/8/8/N7/R3K3 w - - 0 1',
          uci: 'a2b4',
          playedScore: const ClassificationScore.cp(800),
          postMoves: const <String>['d5e5', 'a1a8', 'e5d4'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.discoveredAttack);
      expect(insight.primaryClaim?.initiatorRole, 'knight');
      expect(insight.primaryClaim?.pieceRole, 'rook');
    });

    test('captured defender must expose a target that is then won', () {
      final insight = engine.generate(
        _input(
          fen: '6k1/8/8/3n4/2B2r2/4Q3/8/4K3 w - - 0 1',
          uci: 'c4d5',
          playedScore: const ClassificationScore.cp(800),
          postMoves: const <String>['g8h8', 'e3f4', 'h8g7'],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.removesDefender);
      expect(insight.primaryClaim?.defenderRole, 'knight');
      expect(insight.primaryClaim?.targetRole, 'rook');
    });
  });

  group('sacrifice and special-label causality', () {
    test('Brilliant queen investment is explained only by forced mate', () {
      const fen = '5r1k/6pp/4Q2N/8/8/8/8/4K3 w - - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'e6g8',
          classification: MoveQuality.brilliant,
          beforeScore: const ClassificationScore.mate(3),
          playedScore: const ClassificationScore.mate(1),
          preLines: <EngineLine>[
            _line(fen, const <String>['e6g8', 'f8g8', 'h6f7'], mate: 1),
          ],
          postMoves: const <String>['f8g8', 'h6f7'],
          isSacrifice: true,
          isFirstSacrificePly: true,
          tacticalBestOrNearBest: true,
          tacticalHasForcingOutcome: true,
          tacticalForcedMate: true,
          verificationState: ClassificationVerificationState.complete,
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.soundSacrifice);
      expect(
        insight.primaryClaim?.type,
        MoveInsightClaimType.preservesForcedMate,
      );
      expect(insight.conciseText, 'The queen sacrifice forces checkmate.');
    });

    test('failed rook sacrifice is tied to the concrete loss', () {
      const fen = '4k3/8/8/8/8/8/2q5/R3K3 w Q - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'a1a2',
          classification: MoveQuality.blunder,
          playedScore: const ClassificationScore.cp(-500),
          bestScore: const ClassificationScore.cp(0),
          bestMoveUci: 'a1a8',
          bestMoveSan: 'Ra8+',
          preLines: <EngineLine>[
            _line(fen, const <String>['a1a8', 'e8e7'], cp: 0),
          ],
          postMoves: const <String>['c2a2', 'e1f1'],
          isSacrifice: true,
          isFirstSacrificePly: true,
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.unsoundSacrifice);
      expect(
        insight.conciseText,
        'The rook sacrifice does not work, and the rook is lost.',
      );
    });

    test('Only Move names the proven mate failure of alternatives', () {
      const fen = 'k2r4/8/1b6/8/4b2b/8/P5PP/7K w - - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'h2h3',
          classification: MoveQuality.onlyMove,
          playedScore: const ClassificationScore.cp(0),
          bestMoveUci: 'h2h3',
          legalMoveCount: 3,
          preLines: <EngineLine>[
            _line(fen, const <String>['h2h3', 'd8d1', 'h1h2'], cp: 0, rank: 1),
            _line(fen, const <String>['a2a3', 'd8d1'], mate: -1, rank: 2),
            _line(fen, const <String>['a2a4', 'd8d1'], mate: -1, rank: 3),
          ],
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.onlyMoveDefense);
      expect(
        insight.conciseText,
        'Only this move prevents a forced checkmate.',
      );
    });

    test('Only Move requires the complete three-line alternative contract', () {
      const fen = 'k2r4/8/1b6/8/4b2b/8/P5PP/7K w - - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'h2h3',
          classification: MoveQuality.onlyMove,
          playedScore: const ClassificationScore.cp(0),
          bestMoveUci: 'h2h3',
          legalMoveCount: 3,
          preLines: <EngineLine>[
            _line(fen, const <String>['h2h3', 'd8d1', 'h1h2'], cp: 0, rank: 1),
            _line(fen, const <String>['a2a3', 'd8d1'], mate: -1, rank: 2),
          ],
        ),
      );

      expect(insight.state, MoveInsightState.suppressed);
    });

    test(
      'Missed Win identifies the material resource rather than the label',
      () {
        const fen = '4k3/8/8/8/8/8/2r5/3QK3 w - - 0 1';
        final insight = engine.generate(
          _input(
            fen: fen,
            uci: 'e1f1',
            classification: MoveQuality.missedWin,
            playedScore: const ClassificationScore.cp(0),
            bestScore: const ClassificationScore.cp(500),
            bestMoveUci: 'd1c2',
            bestMoveSan: 'Qxc2',
            preLines: <EngineLine>[
              _line(fen, const <String>['d1c2', 'e8f7', 'c2c7'], cp: 500),
            ],
          ),
        );

        _expectMechanism(
          insight,
          MoveInsightMechanismType.missedMaterialResource,
        );
        expect(
          insight.conciseText,
          'Qxc2 wins the rook; this move misses that chance.',
        );
      },
    );
  });

  group('advanced mechanisms fail closed', () {
    test('two attacks without a surviving gain are not a fork', () {
      final insight = engine.generate(
        _input(
          fen: 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1',
          uci: 'b5c7',
          playedScore: const ClassificationScore.cp(0),
          postMoves: const <String>['e8f8', 'c7b5'],
        ),
      );

      expect(insight.state, MoveInsightState.suppressed);
    });

    test('an already attacked target cannot manufacture a fork', () {
      const fen = 'q3k3/8/8/1N6/8/8/8/R3K3 w - - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'b5c7',
          playedScore: const ClassificationScore.cp(700),
          postMoves: const <String>['e8f8', 'c7a8', 'f8g8'],
        ),
      );

      expect(
        insight.primaryClaim?.mechanism,
        isNot(MoveInsightMechanismType.fork),
      );
    });

    test('aligned pieces without exploitation are not a pin', () {
      final insight = engine.generate(
        _input(
          fen: '4k3/p2r4/8/8/8/8/4B3/4K3 w - - 0 1',
          uci: 'e2b5',
          playedScore: const ClassificationScore.cp(0),
          postMoves: const <String>['a7a6', 'b5c4'],
        ),
      );

      expect(insight.state, MoveInsightState.suppressed);
    });

    test('opened line without capture consequence is suppressed', () {
      final insight = engine.generate(
        _input(
          fen: 'q7/8/8/3k4/8/8/N7/R3K3 w - - 0 1',
          uci: 'a2b4',
          playedScore: const ClassificationScore.cp(0),
          postMoves: const <String>['d5e5', 'a1a2'],
        ),
      );

      expect(insight.state, MoveInsightState.suppressed);
    });

    test('Brilliant label without sacrifice facts produces no story', () {
      final insight = engine.generate(
        _input(
          fen: '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1',
          uci: 'e2e4',
          classification: MoveQuality.brilliant,
          playedScore: const ClassificationScore.cp(20),
        ),
      );

      expect(insight.state, MoveInsightState.suppressed);
    });

    test('sacrifice flags cannot replace an actually captured investment', () {
      const fen = 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'b5c7',
          classification: MoveQuality.brilliant,
          playedScore: const ClassificationScore.cp(700),
          preLines: <EngineLine>[
            _line(fen, const <String>['b5c7', 'e8f8', 'c7a8', 'f8g8'], cp: 700),
          ],
          postMoves: const <String>['e8f8', 'c7a8', 'f8g8'],
          isSacrifice: true,
          isFirstSacrificePly: true,
          tacticalBestOrNearBest: true,
          tacticalHasForcingOutcome: true,
        ),
      );

      _expectMechanism(insight, MoveInsightMechanismType.fork);
      expect(insight.conciseText, isNot(contains('sacrifice')));
    });

    test('Only Move without terminal mate alternatives is suppressed', () {
      const fen = '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1';
      final insight = engine.generate(
        _input(
          fen: fen,
          uci: 'e2e4',
          classification: MoveQuality.onlyMove,
          playedScore: const ClassificationScore.cp(0),
          preLines: <EngineLine>[
            _line(fen, const <String>['e2e4', 'e8f7'], cp: 0, rank: 1),
            _line(fen, const <String>['e2e3', 'e8f7'], mate: -1, rank: 2),
          ],
        ),
      );

      expect(insight.state, MoveInsightState.suppressed);
    });
  });
}

void _expectMechanism(MoveInsight insight, MoveInsightMechanismType mechanism) {
  expect(insight.state, MoveInsightState.available);
  expect(insight.primaryClaim?.mechanism, mechanism);
  expect(insight.hasValidStructure, isTrue);
  expect(insight.conciseText, isNot(contains('verified')));
}

MoveInsightInput _input({
  required String fen,
  required String uci,
  MoveQuality classification = MoveQuality.best,
  ClassificationScore beforeScore = const ClassificationScore.cp(0),
  required ClassificationScore playedScore,
  ClassificationScore? bestScore,
  String? bestMoveUci,
  String? bestMoveSan,
  List<EngineLine> preLines = const <EngineLine>[],
  List<String> postMoves = const <String>[],
  bool searchQualityMet = true,
  bool isSacrifice = false,
  bool isFirstSacrificePly = false,
  bool tacticalBestOrNearBest = false,
  bool tacticalHasForcingOutcome = false,
  bool tacticalForcedMate = false,
  int? legalMoveCount,
  ClassificationVerificationState verificationState =
      ClassificationVerificationState.notRequested,
}) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final move = _move(position, uci);
  final after = position.play(move);
  final candidates = <ClassificationCandidateEvidence>[
    for (final line in preLines)
      ClassificationCandidateEvidence(
        rootUci: line.moveUci!,
        rank: line.rank,
        score: line.scoreCp != null
            ? ClassificationScore.cp(line.scoreCp!)
            : ClassificationScore.mate(line.mateIn!),
        achievedDepth: line.depth,
        isLegal: true,
        pvComplete: true,
      ),
  ];
  final actualBest = bestMoveUci ?? preLines.firstOrNull?.moveUci ?? uci;
  final actualBestScore =
      bestScore ??
      (preLines.firstOrNull?.scoreCp != null
          ? ClassificationScore.cp(preLines.first.scoreCp!)
          : preLines.firstOrNull?.mateIn != null
          ? ClassificationScore.mate(preLines.first.mateIn!)
          : playedScore);
  final evidence = MoveClassificationEvidence(
    mover: position.turn == Side.white
        ? ClassificationMover.white
        : ClassificationMover.black,
    evaluationBefore: beforeScore,
    playedMoveEvaluation: playedScore,
    bestMoveEvaluation: actualBestScore,
    playedMoveUci: uci,
    bestMoveUci: actualBest,
    candidates: candidates,
    requestedMultiPv: preLines.isEmpty ? 1 : preLines.length,
    receivedMultiPv: preLines.length,
    candidateSetComplete: preLines.isNotEmpty,
    candidateSetCoherent: preLines.isNotEmpty,
    bestMovePv1Consistent:
        preLines.isNotEmpty && preLines.first.moveUci == actualBest,
    searchQualityMet: searchQualityMet,
    legalMoveCount: legalMoveCount,
    verificationState: verificationState,
    forcedState: ClassificationForcedState.notForced,
    bookState: ClassificationBookState.notBook,
    isSacrifice: isSacrifice,
    isFirstSacrificePly: isFirstSacrificePly,
    isRecapture: false,
    isTrivialRecapture: false,
    isFreeCapture: false,
    tacticalBestOrNearBest: tacticalBestOrNearBest,
    tacticalHasForcingOutcome: tacticalHasForcingOutcome,
    tacticalForcedMate: tacticalForcedMate,
  );
  return MoveInsightInput(
    fenBefore: fen,
    fenAfter: after.fen,
    playedMoveUci: uci,
    playedMoveSan: position.makeSan(move).$2,
    isWhiteMove: position.turn == Side.white,
    classification: classification,
    classificationEvidence: evidence,
    preMoveLines: preLines,
    postMoveLines: postMoves.isEmpty
        ? const <EngineLine>[]
        : <EngineLine>[
            _line(
              after.fen,
              postMoves,
              cp: playedScore.whiteCp,
              mate: playedScore.whiteMate,
            ),
          ],
    postMoveSearchQualityMet: searchQualityMet,
    engineBestMoveSan: bestMoveSan,
    openingEvidence: _noOpening(fen, after.fen, uci),
  );
}

EngineLine _line(
  String fen,
  List<String> moves, {
  int rank = 1,
  int? cp,
  int? mate,
}) {
  assert((cp == null) != (mate == null));
  Position position = Chess.fromSetup(Setup.parseFen(fen));
  final first = _move(position, moves.first);
  final firstSan = position.makeSan(first).$2;
  for (final uci in moves) {
    position = position.play(_move(position, uci));
  }
  return EngineLine(
    rank: rank,
    moveUci: moves.first,
    moveSan: firstSan,
    scoreCp: cp,
    mateIn: mate,
    depth: 20,
    whiteWinPercent: mate == null ? 50 : (mate > 0 ? 100 : 0),
    pvMoves: moves,
  );
}

NormalMove _move(Position position, String uci) {
  final move = NormalMove(
    from: _square(uci.substring(0, 2)),
    to: _square(uci.substring(2, 4)),
    promotion: uci.length == 5
        ? switch (uci[4]) {
            'q' => Role.queen,
            'r' => Role.rook,
            'b' => Role.bishop,
            'n' => Role.knight,
            _ => null,
          }
        : null,
  );
  if (!position.isLegal(move)) {
    throw StateError('$uci must be legal in ${position.fen}');
  }
  return move;
}

Square _square(String value) =>
    Square(value.codeUnitAt(0) - 97 + (value.codeUnitAt(1) - 49) * 8);

OpeningEvidence _noOpening(String before, String after, String uci) =>
    OpeningEvidence(
      artifact: kApexOpeningArtifactIdentity,
      artifactVerification: OpeningArtifactVerification.verified,
      state: OpeningMatchState.noMatch,
      beforePositionKey: OpeningPositionKey.fromFen(before).value,
      afterPositionKey: OpeningPositionKey.fromFen(after).value,
      playedUci: uci,
      transitionVerified: false,
      totalCandidateCount: 0,
      matchedPly: 1,
      reasonCode: 'position_and_transition_not_found',
    );
