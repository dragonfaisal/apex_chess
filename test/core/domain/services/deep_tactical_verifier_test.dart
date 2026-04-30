import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/services/deep_tactical_verifier.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

const _goldenPgn = '''
[Event "DrePlayerNZ vs. ALFAISALpro"]
[Site "Chess.com"]
[Date "2025-10-21"]
[White "DrePlayerNZ"]
[Black "ALFAISALpro"]
[Result "0-1"]
[WhiteElo "559"]
[BlackElo "553"]
[TimeControl "180"]
[Termination "ALFAISALpro won by checkmate"]
1. Nf3 Nf6 2. d4 d5 3. Bg5 h6 4. Bh4 Bg4 5. Ne5 Qd6 6. Bg3 Ne4 7. Nxg4 Qb4+ 8.
Nd2 e5 9. c3 Qxb2 10. Nxe4 exd4 11. Nd2 dxc3 12. Nb3 c2 13. Qd2 Bb4 14. Qxb4
Qxa1+ 15. Nxa1 c1=Q# 0-1
''';

void main() {
  const verifier = DeepTacticalVerifier();

  test('delayed queen sacrifice leading to mate is detected', () {
    final fixture = _fixtureMoves(_goldenPgn);
    final move = fixture.singleWhere((m) => m.san == 'Qxa1+');
    final continuation = _continuationAfter(fixture, move);
    final win = const WinPercentCalculator();

    final verdict = verifier.verify(
      DeepTacticalInput(
        fenBefore: move.fenBefore,
        playedMoveUci: move.uci,
        san: move.san,
        isWhiteMove: move.isWhiteMove,
        actualContinuationUci: continuation,
        lowDepthLines: [
          EngineLine(
            rank: 1,
            moveUci: 'c2c1q',
            scoreCp: -150,
            depth: 10,
            whiteWinPercent: win.forCp(cp: -150),
            pvMoves: const ['c2c1q'],
          ),
        ],
        highDepthLines: [
          EngineLine(
            rank: 1,
            moveUci: move.uci,
            mateIn: -3,
            depth: 24,
            whiteWinPercent: 0,
            pvMoves: [move.uci, ...continuation],
          ),
          EngineLine(
            rank: 2,
            moveUci: 'b2b6',
            scoreCp: 0,
            depth: 24,
            whiteWinPercent: 50,
          ),
          EngineLine(
            rank: 3,
            moveUci: 'b2a2',
            scoreCp: 80,
            depth: 24,
            whiteWinPercent: win.forCp(cp: 80),
          ),
        ],
        isCapture: true,
        deltaW: 8,
        verificationDepth: 24,
        verificationMultiPV: 5,
      ),
    );

    expect(verdict.verified, isTrue);
    expect(verdict.queenSacrifice, isTrue);
    expect(verdict.delayedSacrifice, isTrue);
    expect(verdict.decoy, isTrue);
    expect(verdict.matingNet, isTrue);
    expect(verdict.promotionNet, isTrue);
    expect(verdict.reasonCode, 'queen_sacrifice_mating_net');
    expect(verdict.humanExplanation.toLowerCase(), contains('queen'));
    expect(verdict.humanExplanation.toLowerCase(), contains('checkmate'));
  });

  test('first commitment move in mating net is detected as deflection', () {
    final fixture = _fixtureMoves(_goldenPgn);
    final move = fixture.singleWhere((m) => m.san == 'Bb4');
    final continuation = _continuationAfter(fixture, move);

    final verdict = verifier.verify(
      DeepTacticalInput(
        fenBefore: move.fenBefore,
        playedMoveUci: move.uci,
        san: move.san,
        isWhiteMove: move.isWhiteMove,
        actualContinuationUci: continuation,
        lowDepthLines: [
          EngineLine(
            rank: 1,
            moveUci: 'c2c1q',
            scoreCp: -150,
            depth: 10,
            whiteWinPercent: 25,
            pvMoves: const ['c2c1q'],
          ),
        ],
        highDepthLines: [
          EngineLine(
            rank: 1,
            moveUci: move.uci,
            mateIn: -5,
            depth: 24,
            whiteWinPercent: 0,
            pvMoves: [move.uci, ...continuation],
          ),
          const EngineLine(
            rank: 2,
            moveUci: 'f8e7',
            scoreCp: 0,
            depth: 24,
            whiteWinPercent: 50,
          ),
          const EngineLine(
            rank: 3,
            moveUci: 'f8d6',
            scoreCp: 100,
            depth: 24,
            whiteWinPercent: 60,
          ),
        ],
        deltaW: 7,
        verificationDepth: 24,
        verificationMultiPV: 5,
      ),
    );

    expect(verdict.verified, isTrue);
    expect(verdict.delayedSacrifice, isTrue);
    expect(verdict.deflection, isTrue);
    expect(verdict.matingNet, isTrue);
    expect(verdict.promotionNet, isTrue);
    expect(
      verdict.reasonCode,
      anyOf('delayed_sacrifice_mating_net', 'deflection_promotion_net'),
    );
  });
}

List<_FixtureMove> _fixtureMoves(String pgn) {
  final game = PgnGame.parsePgn(pgn);
  Position position = PgnGame.startingPosition(game.headers);
  final out = <_FixtureMove>[];
  for (final node in game.moves.mainline()) {
    final move = position.parseSan(node.san);
    if (move == null) break;
    final fenBefore = position.fen;
    final isWhite = position.turn == Side.white;
    final next = position.play(move);
    var uci = '';
    if (move is NormalMove) {
      final raw =
          '${_sqAlg(move.from)}${_sqAlg(move.to)}'
          '${move.promotion != null ? _roleChar(move.promotion!) : ""}';
      uci = normalizeCastlingUci(raw);
    }
    out.add(
      _FixtureMove(
        san: node.san,
        uci: uci,
        fenBefore: fenBefore,
        isWhiteMove: isWhite,
      ),
    );
    position = next;
  }
  return out;
}

List<String> _continuationAfter(List<_FixtureMove> moves, _FixtureMove move) {
  final index = moves.indexOf(move);
  return moves.skip(index + 1).map((m) => m.uci).toList(growable: false);
}

class _FixtureMove {
  const _FixtureMove({
    required this.san,
    required this.uci,
    required this.fenBefore,
    required this.isWhiteMove,
  });

  final String san;
  final String uci;
  final String fenBefore;
  final bool isWhiteMove;
}

String _sqAlg(Square sq) {
  final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
  return '$file${sq.rank + 1}';
}

String _roleChar(Role role) => switch (role) {
  Role.queen => 'q',
  Role.rook => 'r',
  Role.bishop => 'b',
  Role.knight => 'n',
  _ => '',
};
