/// Mock analysis API client — returns pre-computed data for development.
///
/// Uses dartchess to parse the Opera Game PGN and generate correct
/// FENs + SAN notation, then layers hardcoded Win% and classifications
/// on top to test the full gamut of SVG overlays and chart rendering.
library;

import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';

import '../../core/domain/entities/analysis_timeline.dart';
import '../../core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

class MockAnalysisApiClient {
  const MockAnalysisApiClient();

  /// Returns a fully analyzed Opera Game (Morphy vs Duke/Count, 1858).
  ///
  /// Classifications are curated to exercise every UI component:
  /// Book, Best, Excellent, Good, Inaccuracy, Mistake, Blunder, Brilliant.
  AnalysisTimeline getOperaGameAnalysis() {
    const pgn = '[Event "Opera Game"]\n'
        '[Site "Paris, France"]\n'
        '[Date "1858.??.??"]\n'
        '[White "Paul Morphy"]\n'
        '[Black "Duke of Brunswick & Count Isouard"]\n'
        '[Result "1-0"]\n'
        '\n'
        '1. e4 e5 2. Nf3 d6 3. d4 Bg4 4. dxe5 Bxf3 5. Qxf3 dxe5 '
        '6. Bc4 Nf6 7. Qb3 Qe7 8. Nc3 c6 9. Bg5 b5 10. Nxb5 cxb5 '
        '11. Bxb5+ Nbd7 12. O-O-O Rd8 13. Rxd7 Rxd7 14. Rd1 Qe6 '
        '15. Bxd7+ Nxd7 16. Qb8+ Nxb8 17. Rd8# 1-0';

    // Per-ply: (winBefore, winAfter, classification, message, [opening], [bestAlt])
    final data = <_PlyData>[
      _PlyData(50.0, 52.8, MoveQuality.book,
          'Book move — King\'s Pawn Opening.', 'King\'s Pawn Opening'),
      _PlyData(52.8, 52.5, MoveQuality.book,
          'Book move — Open Game.', 'Open Game'),
      _PlyData(52.5, 53.2, MoveQuality.book,
          'Book move — King\'s Knight.', 'King\'s Knight Opening'),
      _PlyData(53.2, 56.1, MoveQuality.good,
          'Philidor Defense — playable but passive.', 'Philidor Defense'),
      _PlyData(56.1, 57.8, MoveQuality.best,
          'Best move — engine\'s #1 choice.'),
      _PlyData(57.8, 56.2, MoveQuality.excellent,
          'Excellent — near-engine accuracy.'),
      _PlyData(56.2, 59.5, MoveQuality.best,
          'Best move — engine\'s #1 choice.'),
      _PlyData(59.5, 58.0, MoveQuality.good,
          'Forced capture — acceptable.'),
      _PlyData(58.0, 60.2, MoveQuality.best,
          'Best move — engine\'s #1 choice.'),
      _PlyData(60.2, 59.8, MoveQuality.excellent,
          'Excellent — recaptures material.'),
      _PlyData(59.8, 62.1, MoveQuality.excellent,
          'Excellent — developing with tempo.'),
      _PlyData(62.1, 68.5, MoveQuality.inaccuracy,
          'Inaccuracy — Qf6 was stronger.', null, 'Qf6'),
      _PlyData(68.5, 70.2, MoveQuality.best,
          'Best move — targeting f7 and b7.'),
      _PlyData(70.2, 78.4, MoveQuality.mistake,
          'Mistake — Qd7 keeps the position together.', null, 'Qd7'),
      _PlyData(78.4, 79.1, MoveQuality.best,
          'Best move — engine\'s #1 choice.'),
      _PlyData(79.1, 77.8, MoveQuality.good,
          'Okay move — slight room for improvement.'),
      _PlyData(77.8, 80.5, MoveQuality.best,
          'Best move — pinning the knight.'),
      _PlyData(80.5, 92.3, MoveQuality.blunder,
          'Blunder! 11.8% lost — fatally weakens queenside.', null, 'Bb4'),
      _PlyData(92.3, 93.0, MoveQuality.best,
          'Best move — engine\'s #1 choice.'),
      _PlyData(93.0, 91.5, MoveQuality.good,
          'Forced recapture.'),
      _PlyData(91.5, 93.8, MoveQuality.best,
          'Best move — check with discovery.'),
      _PlyData(93.8, 93.2, MoveQuality.good,
          'Only legal block.'),
      _PlyData(93.2, 94.5, MoveQuality.best,
          'Best — king safety + rook activation.'),
      _PlyData(94.5, 93.8, MoveQuality.good,
          'Reasonable defense.'),
      _PlyData(93.8, 96.2, MoveQuality.brilliant,
          'Brilliant sacrifice! Rook given for devastating attack.'),
      _PlyData(96.2, 95.8, MoveQuality.good,
          'Forced recapture.'),
      _PlyData(95.8, 97.5, MoveQuality.best,
          'Best move — doubling on the d-file.'),
      _PlyData(97.5, 97.0, MoveQuality.good,
          'Attempting to block the pressure.'),
      _PlyData(97.0, 98.5, MoveQuality.best,
          'Best move — deflection sacrifice.'),
      _PlyData(98.5, 98.2, MoveQuality.good,
          'Forced recapture.'),
      _PlyData(98.2, 100.0, MoveQuality.brilliant,
          'Brilliant! Queen sacrifice forces checkmate.'),
      _PlyData(100.0, 100.0, MoveQuality.good,
          'Forced capture — any move loses.'),
      _PlyData(100.0, 100.0, MoveQuality.best,
          'Checkmate! A masterpiece by Morphy.'),
    ];

    // ── Walk PGN with dartchess for correct FENs + SAN ─────────────
    final game = PgnGame.parsePgn(pgn);
    final headers = Map<String, String>.from(game.headers);
    Position position = PgnGame.startingPosition(game.headers);
    final startingFen = position.fen;

    final moves = <MoveAnalysis>[];
    final winPcts = <double>[];
    int ply = 0;

    for (final node in game.moves.mainline()) {
      if (ply >= data.length) break;

      final move = position.parseSan(node.san);
      if (move == null) break;

      final fenBefore = position.fen;
      final isWhite = position.turn == Side.white;
      final newPos = position.play(move);

      String targetSq = 'e4';
      String uci = node.san;
      if (move is NormalMove) {
        targetSq = _sqToAlg(move.to);
        uci = '${_sqToAlg(move.from)}${_sqToAlg(move.to)}'
            '${move.promotion != null ? _roleChar(move.promotion!) : ""}';
      }

      final d = data[ply];
      final s = isWhite ? 1.0 : -1.0;
      final deltaW = (d.winAfter - d.winBefore) * s;

      moves.add(MoveAnalysis(
        ply: ply,
        san: node.san,
        uci: uci,
        fenBefore: fenBefore,
        fenAfter: newPos.fen,
        targetSquare: targetSq,
        winPercentBefore: d.winBefore,
        winPercentAfter: d.winAfter,
        deltaW: deltaW,
        isWhiteMove: isWhite,
        classification: d.classification,
        engineBestMoveSan: d.engineBestSan,
        scoreCpAfter: _winPctToCp(d.winAfter),
        inBook: d.classification == MoveQuality.book,
        openingName: d.openingName,
        message: d.message,
      ));

      winPcts.add(d.winAfter);
      position = newPos;
      ply++;
    }

    return AnalysisTimeline(
      moves: moves,
      startingFen: startingFen,
      headers: headers,
      winPercentages: winPcts,
    );
  }

  static String _sqToAlg(Square sq) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
    final rank = sq.rank + 1;
    return '$file$rank';
  }

  static String _roleChar(Role role) => switch (role) {
        Role.queen => 'q',
        Role.rook => 'r',
        Role.bishop => 'b',
        Role.knight => 'n',
        _ => '',
      };

  /// Inverse sigmoid: Win% → approximate centipawns for eval bar.
  static int _winPctToCp(double winPct) {
    if (winPct >= 99.9) return 10000;
    if (winPct <= 0.1) return -10000;
    final w = (winPct - 50.0) / 50.0;
    if (w.abs() >= 0.999) return w > 0 ? 1000 : -1000;
    final cp = -math.log((2.0 / (w + 1.0)) - 1.0) / 0.00368208;
    return cp.round().clamp(-1000, 1000);
  }
}

/// Per-ply hardcoded analysis data.
class _PlyData {
  final double winBefore;
  final double winAfter;
  final MoveQuality classification;
  final String message;
  final String? openingName;
  final String? engineBestSan;

  const _PlyData(
    this.winBefore,
    this.winAfter,
    this.classification,
    this.message, [
    this.openingName,
    this.engineBestSan,
  ]);
}
