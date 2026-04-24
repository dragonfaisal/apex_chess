/// State management for the Live Play screen — Apex AI Analyst edition.
///
/// Holds the immutable [Chess] position (via dartchess for RULES ONLY),
/// queries the local [LocalEvalService] for evaluation after each move,
/// and orchestrates move → audio → engine eval in a reactive pipeline.
///
/// Zero network calls. If the engine fails to start (unsigned library,
/// unsupported arch), the UI surfaces a graceful error state.
library;

import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/platform/audio/chess_audio_service.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart'
    show CloudEvalSnapshot, CloudEvalError;
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class LivePlayState {
  final String currentFen;

  /// Cloud evaluation snapshot (null if pending or unavailable).
  final CloudEvalSnapshot? evaluation;

  /// Error from the cloud eval service (null if no error).
  final CloudEvalError? evalError;

  final bool isEvaluating;
  final String? selectedSquare;
  final List<String> legalMoves;
  final (String, String)? lastMove;
  final bool isCheck;
  final bool isCheckmate;
  final bool isStalemate;
  final bool isDraw;

  /// Coach's verdict on the last move.
  final MoveAnalysisResult? moveAnalysis;

  /// Previous evaluation (White's POV) for comparison.
  final int? previousScoreCp;
  final int? previousMateIn;

  /// Whether White just moved (for deltaW sign).
  final bool lastMoveWasWhite;

  const LivePlayState({
    required this.currentFen,
    this.evaluation,
    this.evalError,
    this.isEvaluating = false,
    this.selectedSquare,
    this.legalMoves = const [],
    this.lastMove,
    this.isCheck = false,
    this.isCheckmate = false,
    this.isStalemate = false,
    this.isDraw = false,
    this.moveAnalysis,
    this.previousScoreCp,
    this.previousMateIn,
    this.lastMoveWasWhite = true,
  });

  factory LivePlayState.initial() => LivePlayState(
        currentFen: Chess.initial.fen,
      );

  LivePlayState copyWith({
    String? currentFen,
    CloudEvalSnapshot? evaluation,
    bool clearEval = false,
    CloudEvalError? evalError,
    bool clearError = false,
    bool? isEvaluating,
    String? selectedSquare,
    bool clearSelection = false,
    List<String>? legalMoves,
    (String, String)? lastMove,
    bool? isCheck,
    bool? isCheckmate,
    bool? isStalemate,
    bool? isDraw,
    MoveAnalysisResult? moveAnalysis,
    bool clearAnalysis = false,
    int? previousScoreCp,
    int? previousMateIn,
    bool? lastMoveWasWhite,
  }) =>
      LivePlayState(
        currentFen: currentFen ?? this.currentFen,
        evaluation: clearEval ? null : (evaluation ?? this.evaluation),
        evalError: clearError ? null : (evalError ?? this.evalError),
        isEvaluating: isEvaluating ?? this.isEvaluating,
        selectedSquare:
            clearSelection ? null : (selectedSquare ?? this.selectedSquare),
        legalMoves:
            clearSelection ? const [] : (legalMoves ?? this.legalMoves),
        lastMove: lastMove ?? this.lastMove,
        isCheck: isCheck ?? this.isCheck,
        isCheckmate: isCheckmate ?? this.isCheckmate,
        isStalemate: isStalemate ?? this.isStalemate,
        isDraw: isDraw ?? this.isDraw,
        moveAnalysis:
            clearAnalysis ? null : (moveAnalysis ?? this.moveAnalysis),
        previousScoreCp: previousScoreCp ?? this.previousScoreCp,
        previousMateIn: previousMateIn ?? this.previousMateIn,
        lastMoveWasWhite: lastMoveWasWhite ?? this.lastMoveWasWhite,
      );

  /// User-facing error message for the eval bar.
  String? get evalErrorMessage {
    if (evalError == null) return null;
    return switch (evalError!) {
      CloudEvalError.offline =>
        'Apex AI Analyst could not be loaded on this device.',
      CloudEvalError.rateLimited =>
        'Engine busy — retrying…',
      CloudEvalError.positionNotFound =>
        'Engine returned no evaluation for this position.',
      CloudEvalError.serverError =>
        'Apex AI Analyst stopped responding.',
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class LivePlayNotifier extends Notifier<LivePlayState> {
  late final LocalEvalService _eval;
  late final ChessAudioService _audio;
  final EvaluationAnalyzer _analyzer = const EvaluationAnalyzer();

  Chess _position = Chess.initial;

  @override
  LivePlayState build() {
    _eval = ref.watch(liveEvalServiceProvider);
    _audio = ref.watch(audioServiceProvider);
    _position = Chess.initial;
    return LivePlayState.initial();
  }

  // ── Board Interaction ──────────────────────────────────────────────────

  void onSquareTapped(String squareAlg) {
    final currentSelection = state.selectedSquare;
    final square = _parseSquare(squareAlg);
    if (square == null) return;

    if (currentSelection == null) {
      _trySelect(squareAlg, square);
      return;
    }
    if (currentSelection == squareAlg) {
      state = state.copyWith(clearSelection: true);
      return;
    }
    if (state.legalMoves.contains(squareAlg)) {
      attemptMove(currentSelection, squareAlg);
      return;
    }
    final piece = _position.board.pieceAt(square);
    if (piece != null && piece.color == _position.turn) {
      _trySelect(squareAlg, square);
      return;
    }
    state = state.copyWith(clearSelection: true);
  }

  void _trySelect(String squareAlg, Square square) {
    final piece = _position.board.pieceAt(square);
    if (piece == null || piece.color != _position.turn) {
      state = state.copyWith(clearSelection: true);
      return;
    }
    final legalSquareSet = _position.legalMovesOf(square);
    final legalDestinations = <String>[];
    for (int sq = 0; sq < 64; sq++) {
      if (legalSquareSet.has(Square(sq))) {
        legalDestinations.add(_squareToAlgebraic(Square(sq)));
      }
    }
    _audio.play(ChessSoundType.select);
    state = state.copyWith(
        selectedSquare: squareAlg, legalMoves: legalDestinations);
  }

  // ── Move Execution ─────────────────────────────────────────────────────

  void attemptMove(String from, String to) {
    final fromSq = _parseSquare(from);
    final toSq = _parseSquare(to);
    if (fromSq == null || toSq == null) return;

    final targetPiece = _position.board.pieceAt(toSq);
    final isCapture = targetPiece != null;
    final isWhiteMoving = _position.turn == Side.white;

    final movingPiece = _position.board.pieceAt(fromSq);
    final isPromotion = movingPiece != null &&
        movingPiece.role == Role.pawn &&
        (toSq.rank == 0 || toSq.rank == 7);

    // Castling = king moving two files horizontally on the back rank.
    // Detected here so the audio layer can play a dedicated `castle.mp3`
    // instead of falling into the generic `move` bucket (or — if dart-
    // chess ever emits king→rook-square castling — the `capture` bucket).
    final isCastling = movingPiece != null &&
        movingPiece.role == Role.king &&
        (toSq.file - fromSq.file).abs() == 2;

    final move = NormalMove(
        from: fromSq, to: toSq,
        promotion: isPromotion ? Role.queen : null);

    if (!_position.isLegal(move)) {
      _audio.play(ChessSoundType.error);
      state = state.copyWith(clearSelection: true);
      return;
    }

    // Capture previous eval BEFORE making the move.
    final prevCp = state.evaluation?.scoreCp;
    final prevMate = state.evaluation?.mateIn;

    _position = _position.play(move) as Chess;

    // Sound. Castling gets its own SFX — checked before capture so a
    // king→rook-square castling path (unused today but defensive) doesn't
    // fall into the capture bucket just because the destination square
    // holds the friendly rook.
    if (_position.isCheckmate) {
      _audio.playImmediate(ChessSoundType.checkmate);
    } else if (_position.isCheck) {
      _audio.play(ChessSoundType.check);
    } else if (isCastling) {
      _audio.play(ChessSoundType.castle);
    } else if (isCapture) {
      _audio.play(ChessSoundType.capture);
    } else {
      _audio.play(ChessSoundType.move);
    }

    state = state.copyWith(
      currentFen: _position.fen,
      clearSelection: true,
      lastMove: (from, to),
      isCheck: _position.isCheck,
      isCheckmate: _position.isCheckmate,
      isStalemate: _position.isStalemate,
      isDraw: !_position.isCheckmate &&
          !_position.isStalemate && _position.isGameOver,
      clearEval: true,
      clearError: true,
      previousScoreCp: prevCp,
      previousMateIn: prevMate,
      lastMoveWasWhite: isWhiteMoving,
      clearAnalysis: true,
    );

    if (!_position.isGameOver) {
      _requestEval();
    } else {
      _audio.playImmediate(ChessSoundType.gameEnd);
    }
  }

  // ── Engine Evaluation ──────────────────────────────────────────────────

  Future<void> _requestEval() async {
    state = state.copyWith(isEvaluating: true, clearError: true);

    final (snapshot, error) = await _eval.evaluate(state.currentFen);

    if (error != null) {
      state = state.copyWith(
        isEvaluating: false,
        evalError: error,
      );
      return;
    }

    if (snapshot == null) {
      state = state.copyWith(
        isEvaluating: false,
        evalError: CloudEvalError.positionNotFound,
      );
      return;
    }

    state = state.copyWith(
      isEvaluating: false,
      evaluation: snapshot,
      clearError: true,
    );

    // Classify the move using before/after scores.
    _classifyLastMove(snapshot);
  }

  void _classifyLastMove(CloudEvalSnapshot currentEval) {
    final prevCp = state.previousScoreCp;
    if (prevCp == null) return;

    final result = _analyzer.analyze(
      prevCp: prevCp,
      prevMate: state.previousMateIn,
      currCp: currentEval.scoreCp,
      currMate: currentEval.mateIn,
      isWhiteMove: state.lastMoveWasWhite,
    );

    state = state.copyWith(moveAnalysis: result);
  }

  /// Manually re-request evaluation for the current position.
  Future<void> refreshEval() async => _requestEval();

  void resetGame() {
    _position = Chess.initial;
    state = LivePlayState.initial();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Square? _parseSquare(String algebraic) {
    if (algebraic.length != 2) return null;
    final file = algebraic.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(algebraic[1]);
    if (file < 0 || file > 7 || rank == null || rank < 1 || rank > 8) {
      return null;
    }
    return Square(file + (rank - 1) * 8);
  }

  String _squareToAlgebraic(Square sq) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
    final rank = sq.rank + 1;
    return '$file$rank';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final audioServiceProvider = Provider<ChessAudioService>((ref) {
  final service = ChessAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final livePlayProvider =
    NotifierProvider<LivePlayNotifier, LivePlayState>(
  LivePlayNotifier.new,
);
