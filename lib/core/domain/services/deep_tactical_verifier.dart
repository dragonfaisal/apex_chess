/// Candidate-only tactical verification for review classifications.
///
/// This service is pure Dart and engine-agnostic: callers provide the normal
/// low-depth/MultiPV lines and, for candidates, an optional deeper candidate
/// search. The verifier replays the engine PV and actual continuation to
/// detect delayed sacrifices, decoys, promotion nets, and mating nets.
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/deep_tactical_verdict.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/services/position_heuristics.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';

class DeepTacticalInput {
  const DeepTacticalInput({
    required this.fenBefore,
    required this.playedMoveUci,
    required this.san,
    required this.isWhiteMove,
    required this.actualContinuationUci,
    required this.lowDepthLines,
    this.highDepthLines = const <EngineLine>[],
    this.isCapture = false,
    this.isFreeCapture = false,
    this.isRecapture = false,
    this.isSacrifice = false,
    this.deltaW = 0,
    this.verificationDepth,
    this.verificationMultiPV,
    this.playerRating,
  });

  final String fenBefore;
  final String playedMoveUci;
  final String san;
  final bool isWhiteMove;
  final List<String> actualContinuationUci;
  final List<EngineLine> lowDepthLines;
  final List<EngineLine> highDepthLines;
  final bool isCapture;
  final bool isFreeCapture;
  final bool isRecapture;
  final bool isSacrifice;
  final double deltaW;
  final int? verificationDepth;
  final int? verificationMultiPV;
  final int? playerRating;
}

class DeepTacticalVerifier {
  const DeepTacticalVerifier({
    WinPercentCalculator winCalc = const WinPercentCalculator(),
  }) : _win = winCalc;

  final WinPercentCalculator _win;

  static const int replayLimitPlies = 12;
  static const int motifWindowPlies = 10;

  DeepTacticalVerdict verify(DeepTacticalInput input) {
    final played = _normalizeUci(input.playedMoveUci);
    if (played.length < 4) return DeepTacticalVerdict.none;

    final actual = _analyzeLine(input.fenBefore, [
      played,
      ...input.actualContinuationUci.take(replayLimitPlies - 1),
    ], input.isWhiteMove);
    final lowPv = _analyzeLine(
      input.fenBefore,
      _playedLineFrom(input.lowDepthLines, played),
      input.isWhiteMove,
    );
    final highPv = input.highDepthLines.isEmpty
        ? _LineTactics.empty
        : _analyzeLine(
            input.fenBefore,
            _playedLineFrom(input.highDepthLines, played),
            input.isWhiteMove,
          );

    final lowRank = _rankOf(played, input.lowDepthLines);
    final highRank = _rankOf(played, input.highDepthLines);
    final effectiveRank = highRank ?? lowRank;
    final lineForOnlyMove = input.highDepthLines.length >= 3
        ? input.highDepthLines
        : input.lowDepthLines;

    final isBestOrNearBest =
        effectiveRank == 1 ||
        (effectiveRank == 2 &&
            _moverGapBetweenRanks(
                  lines: lineForOnlyMove,
                  rankA: 1,
                  rankB: 2,
                  isWhiteMove: input.isWhiteMove,
                ) <=
                3.0);
    final onlyMove = _isOnlyMove(lineForOnlyMove, input.isWhiteMove);

    final trajectory = _merge(actual, highPv, lowPv);
    final movedMajorSac = trajectory.queenSacrifice || trajectory.rookSacrifice;
    final delayedSac =
        trajectory.movedPieceCaptured &&
        (trajectory.capturedOffset ?? 99) <= 3 &&
        trajectory.hasForcingOutcome;
    final sacrificeTrajectory =
        input.isSacrifice || delayedSac || movedMajorSac;
    final deflection =
        trajectory.deflection || (delayedSac && trajectory.capturedByQueen);
    final decoy = trajectory.decoy || movedMajorSac || delayedSac;
    final matingNet = trajectory.forcedMate;
    final promotionNet = trajectory.forcedPromotion;
    final decisiveMaterialWin = trajectory.decisiveMaterialWin;

    final lowRejectedHighApproved =
        input.highDepthLines.isNotEmpty &&
        (lowRank == null || lowRank > 2) &&
        (highRank == 1 || highRank == 2);
    final nonObviousScore = _nonObviousScore(
      lowRank: lowRank,
      highRank: highRank,
      lowRejectedHighApproved: lowRejectedHighApproved,
      sacrificeTrajectory: sacrificeTrajectory,
      queenSacrifice: trajectory.queenSacrifice,
      rookSacrifice: trajectory.rookSacrifice,
      matingNet: matingNet,
      playerRating: input.playerRating,
    );

    final candidateType = _candidateType(
      input: input,
      trajectory: trajectory,
      onlyMove: onlyMove,
      isBestOrNearBest: isBestOrNearBest,
    );
    final isCandidate = candidateType != 'none';
    if (!isCandidate) return DeepTacticalVerdict.none;

    final verified = input.highDepthLines.isNotEmpty;
    final reason = _reasonCode(
      queenSacrifice: trajectory.queenSacrifice,
      rookSacrifice: trajectory.rookSacrifice,
      delayedSacrifice: delayedSac,
      deflection: deflection,
      decoy: decoy,
      matingNet: matingNet,
      promotionNet: promotionNet,
      decisiveMaterialWin: decisiveMaterialWin,
      onlyMove: onlyMove,
      verified: verified,
    );

    return DeepTacticalVerdict(
      isCandidate: true,
      verified: verified,
      candidateType: candidateType,
      isBestOrNearBest: isBestOrNearBest,
      isOnlyMove: onlyMove,
      isNonObvious: nonObviousScore >= 0.5,
      lowDepthRejectedHighDepthApproved: lowRejectedHighApproved,
      forcingLineLength: trajectory.forcingLineLength,
      forcedMate: trajectory.forcedMate,
      forcedPromotion: trajectory.forcedPromotion,
      decisiveMaterialWin: decisiveMaterialWin,
      sacrificeTrajectory: sacrificeTrajectory,
      delayedSacrifice: delayedSac,
      queenSacrifice: trajectory.queenSacrifice,
      rookSacrifice: trajectory.rookSacrifice,
      decoy: decoy,
      deflection: deflection,
      matingNet: matingNet,
      promotionNet: promotionNet,
      reasonCode: reason,
      humanExplanation: _humanExplanation(reason),
      lowDepthRank: lowRank,
      highDepthRank: highRank,
      lowDepthScore: _scoreForRank(input.lowDepthLines, lowRank ?? 1),
      highDepthScore: _scoreForRank(input.highDepthLines, highRank ?? 1),
      lowDepthBestMove: input.lowDepthLines.isEmpty
          ? null
          : input.lowDepthLines.first.moveUci,
      highDepthBestMove: input.highDepthLines.isEmpty
          ? null
          : input.highDepthLines.first.moveUci,
      nonObviousScore: nonObviousScore,
      movedPieceCapturedInPV: trajectory.movedPieceCaptured,
      capturedOnPlyOffset: trajectory.capturedOffset,
      firstCommitmentPly: sacrificeTrajectory || matingNet || promotionNet
          ? 0
          : null,
      candidateVerified: verified,
      verificationDepth: input.verificationDepth,
      verificationMultiPV: input.verificationMultiPV,
    );
  }

  List<String> _playedLineFrom(List<EngineLine> lines, String played) {
    if (lines.isEmpty) return <String>[played];
    final matching = lines.where(
      (l) => l.moveUci != null && _normalizeUci(l.moveUci!) == played,
    );
    final line = matching.isNotEmpty ? matching.first : lines.first;
    final pv = line.pvMoves.map(_normalizeUci).where((m) => m.length >= 4);
    if (pv.isEmpty) return <String>[played];
    return pv.take(replayLimitPlies).toList(growable: false);
  }

  _LineTactics _analyzeLine(
    String fen,
    List<String> rawMoves,
    bool originalIsWhite,
  ) {
    if (rawMoves.isEmpty) return _LineTactics.empty;
    try {
      Position position = Chess.fromSetup(Setup.parseFen(fen));
      final beforeMaterial = PositionHeuristics.materialBalanceFromFen(fen);
      final originalSide = originalIsWhite ? Side.white : Side.black;
      Square? trackedSquare;
      Role? trackedRole;
      bool trackedCaptured = false;
      int? capturedOffset;
      bool capturedByQueen = false;
      bool queenSacrifice = false;
      bool rookSacrifice = false;
      bool deflection = false;
      bool decoy = false;
      bool forcedPromotion = false;
      bool forcedMate = false;
      int forcingLength = 0;

      for (var i = 0; i < rawMoves.length && i < replayLimitPlies; i++) {
        final uci = _normalizeUci(rawMoves[i]);
        final move = _moveFromUci(position, uci);
        if (move == null || !position.isLegal(move)) break;

        final mover = position.turn;
        final movingPiece = position.board.pieceAt(move.from);
        final targetPiece = _isRealCapture(position, move)
            ? position.board.pieceAt(move.to)
            : null;
        final capturerRole = movingPiece?.role;

        if (i == 0) {
          trackedSquare = move.to;
          trackedRole = move.promotion ?? movingPiece?.role;
        } else if (!trackedCaptured &&
            trackedSquare != null &&
            move.to == trackedSquare &&
            targetPiece != null &&
            mover != originalSide) {
          trackedCaptured = true;
          capturedOffset = i;
          capturedByQueen = capturerRole == Role.queen;
          queenSacrifice = trackedRole == Role.queen;
          rookSacrifice = trackedRole == Role.rook;
          decoy = queenSacrifice || rookSacrifice;
          deflection =
              capturerRole == Role.queen ||
              capturerRole == Role.king ||
              capturerRole == Role.rook;
        }

        final isOriginalMover = mover == originalSide;
        if (isOriginalMover && move.promotion != null) {
          forcedPromotion = true;
          if (forcingLength == 0) forcingLength = i + 1;
        }

        position = position.play(move);

        if (!trackedCaptured &&
            trackedSquare != null &&
            mover == originalSide &&
            move.from == trackedSquare) {
          trackedSquare = move.to;
          trackedRole = move.promotion ?? trackedRole;
        }

        if (position.isCheckmate) {
          final winner = mover;
          if (winner == originalSide) {
            forcedMate = true;
            if (forcingLength == 0) forcingLength = i + 1;
          }
          break;
        }
      }

      final afterMaterial = PositionHeuristics.materialBalanceFromFen(
        position.fen,
      );
      final materialDelta = beforeMaterial == null || afterMaterial == null
          ? 0
          : (afterMaterial - beforeMaterial) * (originalIsWhite ? 1 : -1);

      return _LineTactics(
        movedPieceCaptured: trackedCaptured,
        capturedOffset: capturedOffset,
        capturedByQueen: capturedByQueen,
        queenSacrifice: queenSacrifice,
        rookSacrifice: rookSacrifice,
        deflection: deflection,
        decoy: decoy,
        forcedMate: forcedMate,
        forcedPromotion: forcedPromotion,
        decisiveMaterialWin: materialDelta >= 5,
        forcingLineLength: forcingLength,
      );
    } catch (_) {
      return _LineTactics.empty;
    }
  }

  _LineTactics _merge(
    _LineTactics a,
    _LineTactics b,
    _LineTactics c,
  ) => _LineTactics(
    movedPieceCaptured:
        a.movedPieceCaptured || b.movedPieceCaptured || c.movedPieceCaptured,
    capturedOffset: _minPositive([
      a.capturedOffset,
      b.capturedOffset,
      c.capturedOffset,
    ]),
    capturedByQueen:
        a.capturedByQueen || b.capturedByQueen || c.capturedByQueen,
    queenSacrifice: a.queenSacrifice || b.queenSacrifice || c.queenSacrifice,
    rookSacrifice: a.rookSacrifice || b.rookSacrifice || c.rookSacrifice,
    deflection: a.deflection || b.deflection || c.deflection,
    decoy: a.decoy || b.decoy || c.decoy,
    forcedMate: a.forcedMate || b.forcedMate || c.forcedMate,
    forcedPromotion:
        a.forcedPromotion || b.forcedPromotion || c.forcedPromotion,
    decisiveMaterialWin:
        a.decisiveMaterialWin || b.decisiveMaterialWin || c.decisiveMaterialWin,
    forcingLineLength:
        _minPositive([
          a.forcingLineLength == 0 ? null : a.forcingLineLength,
          b.forcingLineLength == 0 ? null : b.forcingLineLength,
          c.forcingLineLength == 0 ? null : c.forcingLineLength,
        ]) ??
        0,
  );

  String _candidateType({
    required DeepTacticalInput input,
    required _LineTactics trajectory,
    required bool onlyMove,
    required bool isBestOrNearBest,
  }) {
    if (trajectory.queenSacrifice) return 'queen_sacrifice';
    if (trajectory.rookSacrifice) return 'rook_sacrifice';
    if (trajectory.forcedMate) return 'mating_net';
    if (trajectory.forcedPromotion) return 'promotion_net';
    if (input.isSacrifice || trajectory.movedPieceCaptured) {
      return 'sacrifice_trajectory';
    }
    if (onlyMove) return 'only_move';
    if (input.san.contains('#')) return 'mate';
    if (input.san.contains('+')) return 'check';
    if (input.san.contains('=')) return 'promotion';
    if (input.isCapture && !input.isFreeCapture) return 'capture';
    if (input.deltaW.abs() >= 12) return 'eval_swing';
    if (isBestOrNearBest &&
        (input.san.contains('x') ||
            input.san.contains('+') ||
            input.san.contains('='))) {
      return 'best_tactical';
    }
    return 'none';
  }

  String _reasonCode({
    required bool queenSacrifice,
    required bool rookSacrifice,
    required bool delayedSacrifice,
    required bool deflection,
    required bool decoy,
    required bool matingNet,
    required bool promotionNet,
    required bool decisiveMaterialWin,
    required bool onlyMove,
    required bool verified,
  }) {
    if (queenSacrifice && matingNet) return 'queen_sacrifice_mating_net';
    if (queenSacrifice && promotionNet) return 'queen_sacrifice_promotion_net';
    if (rookSacrifice && matingNet) return 'rook_sacrifice_mating_net';
    if (delayedSacrifice && matingNet) return 'delayed_sacrifice_mating_net';
    if (deflection && promotionNet) return 'deflection_promotion_net';
    if (decoy && matingNet) return 'decoy_mating_net';
    if (matingNet) return 'forcing_mating_net';
    if (promotionNet) return 'promotion_net';
    if (decisiveMaterialWin) return 'decisive_material_tactic';
    if (onlyMove) return 'only_move';
    return verified ? 'verified_tactical_candidate' : 'needs_deep_review';
  }

  String _humanExplanation(String reason) => switch (reason) {
    'queen_sacrifice_mating_net' =>
      'The queen can be captured, but the pawn promotes with checkmate.',
    'queen_sacrifice_promotion_net' =>
      'The queen sacrifice pulls a defender away and makes promotion unstoppable.',
    'rook_sacrifice_mating_net' =>
      'The rook can be taken, but the attack ends in mate.',
    'delayed_sacrifice_mating_net' => 'This starts a forcing mating net.',
    'deflection_promotion_net' =>
      'This pulls the defender away and makes promotion unstoppable.',
    'decoy_mating_net' =>
      'This decoy pulls a piece onto the wrong square and mate follows.',
    'forcing_mating_net' => 'This starts a forcing mating net.',
    'promotion_net' => 'This makes promotion unstoppable.',
    'decisive_material_tactic' =>
      'This tactic wins decisive material without giving the attack away.',
    'only_move' => 'This is the only move that keeps the position together.',
    'verified_tactical_candidate' =>
      'Deep review confirms this tactical idea works.',
    _ => 'Deep review is recommended to verify this tactical idea.',
  };

  int? _rankOf(String played, List<EngineLine> lines) {
    for (final line in lines) {
      final uci = line.moveUci;
      if (uci != null && _normalizeUci(uci) == played) return line.rank;
    }
    return null;
  }

  bool _isOnlyMove(List<EngineLine> lines, bool isWhiteMove) {
    if (lines.length < 3) return false;
    final best = _moverWin(lines[0], isWhiteMove);
    final second = _moverWin(lines[1], isWhiteMove);
    final third = _moverWin(lines[2], isWhiteMove);
    return best - second > 20 && best - third > 20;
  }

  double _moverGapBetweenRanks({
    required List<EngineLine> lines,
    required int rankA,
    required int rankB,
    required bool isWhiteMove,
  }) {
    final a = lines.where((l) => l.rank == rankA).firstOrNull;
    final b = lines.where((l) => l.rank == rankB).firstOrNull;
    if (a == null || b == null) return 100;
    return _moverWin(a, isWhiteMove) - _moverWin(b, isWhiteMove);
  }

  double _moverWin(EngineLine line, bool isWhiteMove) {
    final w = line.whiteWinPercent.isNaN
        ? _win.forCp(cp: line.scoreCp, mate: line.mateIn)
        : line.whiteWinPercent;
    return isWhiteMove ? w : 100.0 - w;
  }

  String? _scoreForRank(List<EngineLine> lines, int rank) {
    final matching = lines.where((l) => l.rank == rank);
    if (matching.isEmpty) return null;
    final line = matching.first;
    if (line.mateIn != null) return 'mate ${line.mateIn}';
    if (line.scoreCp != null) return 'cp ${line.scoreCp}';
    return null;
  }

  double _nonObviousScore({
    required int? lowRank,
    required int? highRank,
    required bool lowRejectedHighApproved,
    required bool sacrificeTrajectory,
    required bool queenSacrifice,
    required bool rookSacrifice,
    required bool matingNet,
    required int? playerRating,
  }) {
    double score = 0;
    if (lowRejectedHighApproved) score += 0.45;
    if (lowRank == null) score += 0.20;
    if (lowRank != null && highRank != null && lowRank > highRank) {
      score += 0.15;
    }
    if (sacrificeTrajectory) score += 0.25;
    if (queenSacrifice || rookSacrifice) score += 0.25;
    if (matingNet) score += 0.20;
    if (playerRating != null && playerRating <= 1200) score += 0.10;
    return score.clamp(0.0, 1.0);
  }

  NormalMove? _moveFromUci(Position position, String uci) {
    if (uci.length < 4) return null;
    final from = _parseSquare(uci.substring(0, 2));
    final to = _parseSquare(uci.substring(2, 4));
    if (from == null || to == null) return null;
    Role? promotion;
    if (uci.length >= 5) {
      promotion = switch (uci[4].toLowerCase()) {
        'q' => Role.queen,
        'r' => Role.rook,
        'b' => Role.bishop,
        'n' => Role.knight,
        _ => null,
      };
    }
    return NormalMove(from: from, to: to, promotion: promotion);
  }

  bool _isRealCapture(Position position, NormalMove move) {
    final movingPiece = position.board.pieceAt(move.from);
    final targetPiece = position.board.pieceAt(move.to);
    if (targetPiece == null) return false;
    final isCastling =
        movingPiece != null &&
        movingPiece.role == Role.king &&
        move.from.file == 4 &&
        (move.to.file == 0 || move.to.file == 7);
    return !isCastling;
  }

  Square? _parseSquare(String alg) {
    if (alg.length != 2) return null;
    final file = alg.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(alg[1]);
    if (file < 0 || file > 7 || rank == null || rank < 1 || rank > 8) {
      return null;
    }
    return Square(file + (rank - 1) * 8);
  }

  static String _normalizeUci(String uci) {
    if (uci.length < 4) return uci;
    final lower = uci.toLowerCase();
    final head = lower.substring(0, 4);
    return switch (head) {
      'e1h1' => 'e1g1${lower.substring(4)}',
      'e1a1' => 'e1c1${lower.substring(4)}',
      'e8h8' => 'e8g8${lower.substring(4)}',
      'e8a8' => 'e8c8${lower.substring(4)}',
      _ => lower,
    };
  }

  int? _minPositive(List<int?> values) {
    final filtered = values.whereType<int>().where((v) => v > 0).toList();
    if (filtered.isEmpty) return null;
    filtered.sort();
    return filtered.first;
  }
}

class _LineTactics {
  const _LineTactics({
    required this.movedPieceCaptured,
    required this.capturedOffset,
    required this.capturedByQueen,
    required this.queenSacrifice,
    required this.rookSacrifice,
    required this.deflection,
    required this.decoy,
    required this.forcedMate,
    required this.forcedPromotion,
    required this.decisiveMaterialWin,
    required this.forcingLineLength,
  });

  static const empty = _LineTactics(
    movedPieceCaptured: false,
    capturedOffset: null,
    capturedByQueen: false,
    queenSacrifice: false,
    rookSacrifice: false,
    deflection: false,
    decoy: false,
    forcedMate: false,
    forcedPromotion: false,
    decisiveMaterialWin: false,
    forcingLineLength: 0,
  );

  final bool movedPieceCaptured;
  final int? capturedOffset;
  final bool capturedByQueen;
  final bool queenSacrifice;
  final bool rookSacrifice;
  final bool deflection;
  final bool decoy;
  final bool forcedMate;
  final bool forcedPromotion;
  final bool decisiveMaterialWin;
  final int forcingLineLength;

  bool get hasForcingOutcome =>
      forcedMate || forcedPromotion || decisiveMaterialWin;
}
