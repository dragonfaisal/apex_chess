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

  group('terminal and mate claims', () {
    test('legal terminal board proves delivered mate', () {
      const fen =
          'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4';
      final input = _input(
        fen: fen,
        uci: 'h5f7',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.mate(1),
      );

      final insight = engine.generate(input);

      expect(insight.state, MoveInsightState.available);
      expect(insight.primaryClaim?.type, MoveInsightClaimType.deliversMate);
      expect(insight.conciseText, 'This move checkmates the king.');
      expect(insight.hasValidStructure, isTrue);
    });

    test('Black mate sign and mover perspective remain explicit', () {
      const fen = 'k3r3/8/8/8/8/P7/5PPP/6K1 b - - 0 1';
      final input = _input(
        fen: fen,
        uci: 'e8e1',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.mate(-1),
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.deliversMate);
      expect(insight.primaryClaim?.pieceRole, 'rook');
      expect(insight.conciseText, 'This move checkmates the king.');
    });

    test('exact terminal board proves stalemate, not mate', () {
      const fen = 'k7/2Q5/2K5/8/8/8/8/8 w - - 0 1';
      final input = _input(
        fen: fen,
        uci: 'c7b6',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.createsStalemate);
      expect(insight.conciseText, 'This move forces stalemate.');
    });

    test('check without a complete mating line is suppressed', () {
      const fen = '7k/8/5KQ1/8/8/8/8/8 w - - 0 1';
      final input = _input(
        fen: fen,
        uci: 'g6h6',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.mate(3),
      );

      final insight = engine.generate(input);

      expect(insight.state, MoveInsightState.suppressed);
      expect(insight.primaryClaim, isNull);
    });

    test('mate score plus legal best response line proves allowed mate', () {
      const fen = 'k3r3/8/8/8/8/8/P4PPP/6K1 w - - 0 1';
      final after = _play(fen, 'a2a3');
      final post = <EngineLine>[
        _line(rank: 1, fen: after.fen, moves: const <String>['e8e1'], mate: -1),
      ];
      final input = _input(
        fen: fen,
        uci: 'a2a3',
        classification: MoveQuality.blunder,
        beforeScore: const ClassificationScore.cp(0),
        playedScore: const ClassificationScore.mate(-1),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'g2g3',
        bestMoveSan: 'g3',
        postLines: post,
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.allowsForcedMate);
      expect(
        insight.conciseText,
        'After Re1#, checkmate can no longer be prevented.',
      );
      expect(insight.betterMoveText, 'g3 avoids the mating sequence.');
    });

    test(
      'mate score without a stored reply line cannot claim allowed mate',
      () {
        const fen = 'k3r3/8/8/8/8/8/P4PPP/6K1 w - - 0 1';
        final input = _input(
          fen: fen,
          uci: 'a2a3',
          classification: MoveQuality.blunder,
          beforeScore: const ClassificationScore.cp(0),
          playedScore: const ClassificationScore.mate(-1),
          bestScore: const ClassificationScore.cp(0),
          bestMoveUci: 'g2g3',
        );

        expect(engine.generate(input).primaryClaim, isNull);
      },
    );

    test('verified PV1 mate proves a missed forced mate', () {
      const fen =
          'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4';
      final best = _line(
        rank: 1,
        fen: fen,
        moves: const <String>['h5f7'],
        mate: 1,
      );
      final input = _input(
        fen: fen,
        uci: 'h5h3',
        classification: MoveQuality.missedWin,
        beforeScore: const ClassificationScore.mate(1),
        playedScore: const ClassificationScore.cp(40),
        bestScore: const ClassificationScore.mate(1),
        bestMoveUci: 'h5f7',
        bestMoveSan: 'Qxf7#',
        preLines: <EngineLine>[best],
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.missesForcedMate);
      expect(
        insight.conciseText,
        'Qxf7# forces checkmate; this move lets it slip away.',
      );
    });

    test('verified continuation proves preserved mate', () {
      const fen = '7k/8/5KQ1/8/8/8/8/8 w - - 0 1';
      final after = _play(fen, 'g6h6');
      final post = <EngineLine>[
        _line(
          rank: 1,
          fen: after.fen,
          moves: const <String>['h8g8', 'h6g7'],
          mate: 2,
        ),
      ];
      final input = _input(
        fen: fen,
        uci: 'g6h6',
        classification: MoveQuality.best,
        beforeScore: const ClassificationScore.mate(3),
        playedScore: const ClassificationScore.mate(2),
        bestScore: const ClassificationScore.mate(3),
        postLines: post,
      );

      final insight = engine.generate(input);

      expect(
        insight.primaryClaim?.type,
        MoveInsightClaimType.preservesForcedMate,
      );
      expect(insight.continuationText, 'Qh6+ Kg8 Qg7#');
    });
  });

  group('material, promotion, recapture, and opening claims', () {
    test('best-response line proves sustained material drop', () {
      const fen = '4k3/8/8/8/8/8/2q5/R3K3 w Q - 0 1';
      final after = _play(fen, 'a1a2');
      final best = _line(
        rank: 1,
        fen: fen,
        moves: const <String>['a1a8', 'e8e7'],
        cp: 0,
      );
      final played = _line(
        rank: 2,
        fen: fen,
        moves: const <String>['a1a2', 'c2a2', 'e1f1'],
        cp: -500,
      );
      final post = _line(
        rank: 1,
        fen: after.fen,
        moves: const <String>['c2a2', 'e1f1'],
        cp: -500,
      );
      final input = _input(
        fen: fen,
        uci: 'a1a2',
        classification: MoveQuality.blunder,
        playedScore: const ClassificationScore.cp(-500),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'a1a8',
        bestMoveSan: 'Ra8+',
        preLines: <EngineLine>[best, played],
        postLines: <EngineLine>[post],
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.dropsMaterial);
      expect(insight.primaryClaim?.pieceRole, 'rook');
      expect(insight.conciseText, 'After Qxa2, the rook is lost.');
      expect(insight.betterMoveText, 'Ra8+ avoids that material loss.');

      final lineJson = Map<String, dynamic>.from(
        insight.primaryClaim!.toJson(),
      );
      lineJson['continuationUci'] = <String>[
        'a1a8',
        ...insight.primaryClaim!.continuationUci.skip(1),
      ];
      final resealedWrongLine = _replacePrimary(
        insight,
        MoveInsightClaim.fromJson(lineJson),
      );
      expect(resealedWrongLine.hasValidIntegrity, isTrue);
      expect(
        const MoveInsightPersistenceValidator().validate(
          insight: resealedWrongLine,
          fenBefore: input.fenBefore,
          fenAfter: input.fenAfter,
          playedMoveUci: input.playedMoveUci,
          isWhiteMove: input.isWhiteMove,
          classification: input.classification,
          classificationEvidence: input.classificationEvidence,
          openingEvidence: input.openingEvidence,
          preMoveLines: input.preMoveLines,
        ),
        isFalse,
      );

      final reasonJson = Map<String, dynamic>.from(
        insight.primaryClaim!.toJson(),
      )..['reasonCode'] = 'invented_material_reason';
      final resealedWrongReason = _replacePrimary(
        insight,
        MoveInsightClaim.fromJson(reasonJson),
      );
      expect(resealedWrongReason.hasValidIntegrity, isTrue);
      expect(
        const MoveInsightPersistenceValidator().validate(
          insight: resealedWrongReason,
          fenBefore: input.fenBefore,
          fenAfter: input.fenAfter,
          playedMoveUci: input.playedMoveUci,
          isWhiteMove: input.isWhiteMove,
          classification: input.classification,
          classificationEvidence: input.classificationEvidence,
          openingEvidence: input.openingEvidence,
          preMoveLines: input.preMoveLines,
        ),
        isFalse,
      );
    });

    test('sound temporary sacrifice is not called a material drop', () {
      const fen = '4k3/8/8/8/8/8/2q5/R3K3 w Q - 0 1';
      final after = _play(fen, 'a1a2');
      final input = _input(
        fen: fen,
        uci: 'a1a2',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.cp(-500),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'a1a8',
        bestMoveSan: 'Ra8+',
        preLines: <EngineLine>[
          _line(
            rank: 1,
            fen: fen,
            moves: const <String>['a1a8', 'e8e7'],
            cp: 0,
          ),
          _line(
            rank: 2,
            fen: fen,
            moves: const <String>['a1a2', 'c2a2', 'e1f1'],
            cp: -500,
          ),
        ],
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['c2a2', 'e1f1'],
            cp: -500,
          ),
        ],
      );

      final insight = engine.generate(input);

      expect(
        insight.primaryClaim?.type,
        isNot(MoveInsightClaimType.dropsMaterial),
      );
      expect(insight.state, MoveInsightState.suppressed);
    });

    test('best-response line proves sustained material win', () {
      const fen = '4k3/8/8/8/8/8/2r5/3QK3 w - - 0 1';
      final after = _play(fen, 'd1c2');
      final post = _line(
        rank: 1,
        fen: after.fen,
        moves: const <String>['e8f7', 'c2c7'],
        cp: 320,
      );
      final input = _input(
        fen: fen,
        uci: 'd1c2',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.cp(320),
        bestScore: const ClassificationScore.cp(320),
        postLines: <EngineLine>[post],
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.winsMaterial);
      expect(insight.primaryClaim?.targetRole, 'rook');
      expect(insight.conciseText, 'After Kf7, the rook stays won.');
    });

    test('Black mover material gain keeps mover perspective', () {
      const fen = '3qk3/2R5/8/8/8/8/8/4K3 b - - 0 1';
      final after = _play(fen, 'd8c7');
      final input = _input(
        fen: fen,
        uci: 'd8c7',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.cp(-320),
        bestScore: const ClassificationScore.cp(-320),
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['e1f2', 'c7c2'],
            cp: -320,
          ),
        ],
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.winsMaterial);
      expect(insight.primaryClaim?.targetRole, 'rook');
      expect(insight.primaryClaim?.materialDelta, 5);
      expect(insight.conciseText, 'After Kf2, the rook stays won.');
    });

    test('recapture remains a recapture rather than a material-win claim', () {
      const fen = '4k3/8/8/8/8/8/2r5/3QK3 w - - 0 1';
      final after = _play(fen, 'd1c2');
      final input = _input(
        fen: fen,
        uci: 'd1c2',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(320),
        isRecapture: true,
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['e8f7', 'c2c7'],
            cp: 320,
          ),
        ],
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.recaptures);
      expect(
        insight.primaryClaim?.type,
        isNot(MoveInsightClaimType.winsMaterial),
      );
    });

    test('temporary capture with recapture produces no material-win claim', () {
      const fen = '8/8/8/8/8/1k6/2r5/3QK3 w - - 0 1';
      final after = _play(fen, 'd1c2');
      final post = _line(
        rank: 1,
        fen: after.fen,
        moves: const <String>['b3c2', 'e1f2'],
        cp: 0,
      );
      final input = _input(
        fen: fen,
        uci: 'd1c2',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
        bestScore: const ClassificationScore.cp(0),
        postLines: <EngineLine>[post],
      );

      final insight = engine.generate(input);

      expect(
        insight.primaryClaim?.type,
        isNot(MoveInsightClaimType.winsMaterial),
      );
    });

    test('legal promotion is exact and notation-aware', () {
      const fen = '4k3/P7/8/8/8/8/8/4K3 w - - 0 1';
      final input = _input(
        fen: fen,
        uci: 'a7a8q',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.cp(900),
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.promotes);
      expect(insight.conciseText, 'This promotes the pawn to a queen on a8.');
    });

    test('trusted recapture flag plus exact capture proves recapture', () {
      const fen = '4k3/8/8/8/4p3/3P4/8/4K3 w - - 0 1';
      final input = _input(
        fen: fen,
        uci: 'd3e4',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
        isRecapture: true,
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.recaptures);
      expect(insight.conciseText, 'This recaptures the pawn on e4.');
    });

    test('verified exact opening edge may identify theory only', () {
      const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      final after = _play(fen, 'e2e4');
      final input = _input(
        fen: fen,
        uci: 'e2e4',
        classification: MoveQuality.book,
        playedScore: const ClassificationScore.cp(20),
        opening: _bookOpening(fen, after.fen, 'e2e4'),
      );

      final first = engine.generate(input);
      final second = engine.generate(input);

      expect(first.primaryClaim?.type, MoveInsightClaimType.bookTransition);
      expect(first.conciseText, "This follows B00 · King's Pawn Game theory.");
      expect(first.integrityDigest, second.integrityDigest);
      expect(first.semanticFingerprint, second.semanticFingerprint);
    });
  });

  group('fail-closed behavior', () {
    test('wrong after-FEN is contradictory', () {
      const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      final input = _input(
        fen: fen,
        uci: 'e2e4',
        fenAfterOverride: fen,
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );

      final insight = engine.generate(input);

      expect(insight.state, MoveInsightState.contradictory);
      expect(insight.conciseText, isNull);
    });

    test('halfmove and fullmove drift makes after-FEN contradictory', () {
      const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      final input = _input(
        fen: fen,
        uci: 'e2e4',
        fenAfterOverride:
            'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 9 42',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );

      expect(engine.generate(input).state, MoveInsightState.contradictory);
    });

    test('played SAN must describe the exact legal UCI move', () {
      const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      final input = _input(
        fen: fen,
        uci: 'e2e4',
        playedSanOverride: 'd4',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );

      expect(engine.generate(input).state, MoveInsightState.contradictory);
    });

    test('castling king-to-rook alias normalizes to the king destination', () {
      const fen = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';
      final input = _input(
        fen: fen,
        uci: 'e1h1',
        boardUci: 'e1g1',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );

      final insight = engine.generate(input);

      expect(insight.state, MoveInsightState.suppressed);
      expect(
        insight.facts.singleWhere((fact) => fact.id == 'f_legal').toSquare,
        'g1',
      );
    });

    test('en passant records the captured pawn on its real square', () {
      const fen = '4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1';
      final input = _input(
        fen: fen,
        uci: 'e5d6',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
        isRecapture: true,
      );

      final insight = engine.generate(input);

      expect(insight.primaryClaim?.type, MoveInsightClaimType.recaptures);
      expect(insight.primaryClaim?.targetRole, 'pawn');
      expect(insight.primaryClaim?.targetSquare, 'd5');
    });

    test('incomplete search naturally produces fewer details', () {
      const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      final input = _input(
        fen: fen,
        uci: 'e2e4',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
        searchQualityMet: false,
      );

      final insight = engine.generate(input);

      expect(insight.state, MoveInsightState.suppressed);
      expect(insight.suppressionReason, 'search_evidence_incomplete');
    });
  });
}

MoveInsightInput _input({
  required String fen,
  required String uci,
  required MoveQuality classification,
  required ClassificationScore playedScore,
  ClassificationScore beforeScore = const ClassificationScore.cp(0),
  ClassificationScore? bestScore,
  String? bestMoveUci,
  String? bestMoveSan,
  List<EngineLine> preLines = const <EngineLine>[],
  List<EngineLine> postLines = const <EngineLine>[],
  bool postMoveSearchQualityMet = true,
  bool searchQualityMet = true,
  bool isRecapture = false,
  OpeningEvidence? opening,
  String? fenAfterOverride,
  String? playedSanOverride,
  String? boardUci,
}) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final move = _move(position, boardUci ?? uci);
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
  final evidence = MoveClassificationEvidence(
    mover: position.turn == Side.white
        ? ClassificationMover.white
        : ClassificationMover.black,
    evaluationBefore: beforeScore,
    playedMoveEvaluation: playedScore,
    bestMoveEvaluation:
        bestScore ??
        (preLines.firstOrNull?.scoreCp != null
            ? ClassificationScore.cp(preLines.first.scoreCp!)
            : preLines.firstOrNull?.mateIn != null
            ? ClassificationScore.mate(preLines.first.mateIn!)
            : playedScore),
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
    bookState: opening?.isVerifiedBookTransition == true
        ? ClassificationBookState.verified
        : ClassificationBookState.notBook,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
    isRecapture: isRecapture,
  );
  return MoveInsightInput(
    fenBefore: fen,
    fenAfter: fenAfterOverride ?? after.fen,
    playedMoveUci: uci,
    playedMoveSan: playedSanOverride ?? position.makeSan(move).$2,
    isWhiteMove: position.turn == Side.white,
    classification: classification,
    classificationEvidence: evidence,
    preMoveLines: preLines,
    postMoveLines: postLines,
    postMoveSearchQualityMet: postMoveSearchQualityMet,
    engineBestMoveSan: bestMoveSan,
    openingEvidence: opening ?? _noOpening(fen, after.fen, uci),
  );
}

EngineLine _line({
  required int rank,
  required String fen,
  required List<String> moves,
  int? cp,
  int? mate,
}) {
  Position position = Chess.fromSetup(Setup.parseFen(fen));
  final first = _move(position, moves.first);
  final firstSan = position.makeSan(first).$2;
  for (final uci in moves) {
    final move = _move(position, uci);
    position = position.play(move);
  }
  return EngineLine(
    rank: rank,
    moveUci: moves.first,
    moveSan: firstSan,
    scoreCp: cp,
    mateIn: mate,
    depth: 18,
    whiteWinPercent: cp == null ? (mate! > 0 ? 100 : 0) : 50,
    pvMoves: moves,
  );
}

Position _play(String fen, String uci) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  return position.play(_move(position, uci));
}

NormalMove _move(Position position, String uci) {
  final from = _square(uci.substring(0, 2));
  final to = _square(uci.substring(2, 4));
  final promotion = uci.length == 5
      ? switch (uci[4]) {
          'q' => Role.queen,
          'r' => Role.rook,
          'b' => Role.bishop,
          'n' => Role.knight,
          _ => null,
        }
      : null;
  final move = NormalMove(from: from, to: to, promotion: promotion);
  expect(
    position.isLegal(move),
    isTrue,
    reason: '$uci must be legal in ${position.fen}',
  );
  return move;
}

Square _square(String value) {
  final file = value.codeUnitAt(0) - 97;
  final rank = value.codeUnitAt(1) - 49;
  return Square(file + rank * 8);
}

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

OpeningEvidence _bookOpening(String before, String after, String uci) {
  const candidate = OpeningCandidate(
    ecoCode: 'B00',
    openingName: "King's Pawn Game",
    sourceLineId:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    sourceTerminalPly: 1,
    matchedPly: 1,
    exactPositionName: true,
  );
  return OpeningEvidence(
    artifact: kApexOpeningArtifactIdentity,
    artifactVerification: OpeningArtifactVerification.verified,
    state: OpeningMatchState.knownTransition,
    beforePositionKey: OpeningPositionKey.fromFen(before).value,
    afterPositionKey: OpeningPositionKey.fromFen(after).value,
    playedUci: uci,
    transitionVerified: true,
    selectedCandidate: candidate,
    totalCandidateCount: 1,
    matchedPly: 1,
    reasonCode: 'verified_known_transition',
  );
}

MoveInsight _replacePrimary(
  MoveInsight original,
  MoveInsightClaim primaryClaim,
) => MoveInsight.create(
  state: original.state,
  facts: original.facts,
  primaryClaim: primaryClaim,
  supportingClaims: original.supportingClaims,
  causalChain: original.causalChain,
  conciseText: original.conciseText,
  causeText: original.causeText,
  consequenceText: original.consequenceText,
  betterMoveText: original.betterMoveText,
  continuationText: original.continuationText,
  suppressionReason: original.suppressionReason,
);
