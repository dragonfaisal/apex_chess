/// Full-game analyzer backed by the on-device Apex AI Analyst.
///
/// Drop-in replacement for [CloudGameAnalyzer] — same public contract
/// (`analyzeFromPgn` + `onProgress`) and the same `AnalysisTimeline` return
/// type so the Review pipeline does not care whether analysis came from
/// Lichess or from local Stockfish.
///
/// ### Pipeline (per ply)
///
/// 1. Check the embedded ECO opening book for the *before* position. If it
///    is a known theoretical move, classify as [MoveQuality.book] and skip
///    the engine call entirely — saving ~70 % of searches on most opening
///    sequences.
/// 2. Otherwise, request the engine eval for the *before* FEN (mover's
///    POV, normalised to White in the returned snapshot).
/// 3. Request the engine eval for the *after* FEN — which is also the
///    *before* FEN of the next ply, so we cache and reuse it and each ply
///    only costs a single additional search on the happy path.
/// 4. Pass the two snapshots to [EvaluationAnalyzer] to compute deltaW and
///    classify the move (Blunder / Mistake / Inaccuracy / Good / Best /
///    Excellent / Brilliant).
///
/// All evaluations are issued through [LocalEvalService] which now
/// guarantees per-call UCI synchronisation (see that file for details).
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart'
    show CloudEvalError;
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';

/// Exception used to surface user-facing errors to the home / review UI.
class LocalAnalysisException implements Exception {
  const LocalAnalysisException(this.message);

  final String message;

  @override
  String toString() => 'LocalAnalysisException: $message';

  String get userMessage => message;
}

class LocalGameAnalyzer {
  LocalGameAnalyzer({
    required LocalEvalService eval,
    EcoBook? book,
    Future<EcoBook>? bookFuture,
    EvaluationAnalyzer analyzer = const EvaluationAnalyzer(),
    int depth = 14,
    // Per-position wall-clock cap. The analyzer combines this with
    // `depth` so Stockfish stops at whichever terminator hits first —
    // this prevents one tactical middlegame from stalling an entire
    // game scan at high depth. ~900 ms reaches D13-15 on desktop NNUE
    // without bloating wall-clock time on long games.
    Duration movetime = const Duration(milliseconds: 900),
  })  : _eval = eval,
        _book = book,
        _bookFuture = bookFuture,
        _analyzer = analyzer,
        _depth = depth,
        _movetime = movetime;

  final LocalEvalService _eval;
  // Book state is materialised on first `analyzeFromPgn` call. A caller
  // that already has the book ready passes it via `book:`; callers that
  // are racing an async load should pass `bookFuture:` so we await the
  // asset once instead of falling back to engine-only classification.
  EcoBook? _book;
  final Future<EcoBook>? _bookFuture;
  final EvaluationAnalyzer _analyzer;
  final int _depth;
  final Duration _movetime;

  Future<AnalysisTimeline> analyzeFromPgn(
    String pgn, {
    void Function(int completed, int total)? onProgress,
    int? depth,
  }) async {
    final searchDepth = depth ?? _depth;
    // Resolve the book eagerly so book classifications aren't silently
    // skipped when the first analysis runs faster than the asset load.
    if (_book == null && _bookFuture != null) {
      try {
        _book = await _bookFuture;
      } catch (_) {
        // Asset missing / corrupt — fall back to engine-only classification.
        _book = null;
      }
    }
    // Capture into a local so Dart's flow analysis can promote it past
    // the subsequent `await` boundaries inside this method.
    final book = _book;
    final game = PgnGame.parsePgn(pgn);
    final headers = Map<String, String>.from(game.headers);
    Position position = PgnGame.startingPosition(game.headers);
    final startingFen = position.fen;

    final parsed = <_ParsedMove>[];
    for (final node in game.moves.mainline()) {
      final move = position.parseSan(node.san);
      if (move == null) break;
      final fenBefore = position.fen;
      final isWhite = position.turn == Side.white;
      final newPos = position.play(move);
      // Always derive UCI from the actual move squares — never fall back
      // to SAN, which would produce garbage like "O-O" inside the four-
      // character slot the UI parses as (from, to).
      String uci;
      if (move is NormalMove) {
        uci = '${_sqAlg(move.from)}${_sqAlg(move.to)}'
            '${move.promotion != null ? _roleChar(move.promotion!) : ""}';
      } else {
        // Should be unreachable — dartchess emits NormalMove for every
        // legal move, including castling. Defensive null-guard so the
        // rest of the pipeline can rely on `uci.length >= 4`.
        uci = '';
      }
      parsed.add(_ParsedMove(
        fenBefore: fenBefore,
        fenAfter: newPos.fen,
        san: node.san,
        uci: uci,
        isWhiteMove: isWhite,
      ));
      position = newPos;
    }

    final totalPlies = parsed.length;
    onProgress?.call(0, totalPlies);

    // ── Cache engine evals by FEN. fenAfter[ply N] == fenBefore[ply N+1],
    // so each non-book position is evaluated at most once. ──
    final cache = <String, EvalSnapshot>{};

    // Track consecutive engine failures. One slow position shouldn't
    // nuke an entire game scan — skip it, mark the ply as unknown, and
    // keep going. Only abort when the engine is *sustainedly* broken.
    var consecutiveFailures = 0;

    Future<EvalSnapshot?> evalCached(String fen) async {
      final hit = cache[fen];
      if (hit != null) {
        consecutiveFailures = 0;
        return hit;
      }
      final (snap, err) = await _eval.evaluate(
        fen,
        depth: searchDepth,
        movetime: _movetime,
      );
      if (err != null && err != CloudEvalError.positionNotFound) {
        consecutiveFailures++;
        // A sustained run of failures means the engine itself is
        // unresponsive (NNUE weights missing, native crash, hostile
        // position, etc.) — abort so the user sees a clear error instead
        // of a half-blank timeline.
        if (consecutiveFailures >= 5) {
          throw const LocalAnalysisException(
              'Quantum Scan failed — engine stopped responding.');
        }
        return null;
      }
      if (snap == null) {
        // positionNotFound — engine answered but had no usable score.
        // Skip this ply (it'll classify as Unknown) but don't abort.
        return null;
      }
      consecutiveFailures = 0;
      cache[fen] = snap;
      return snap;
    }

    // Seed the starting-position Win% from the engine's opening eval (if
    // not a book position) or from neutral 50 % (book positions).
    EvalSnapshot? startEval;
    if (book == null || !book.contains(startingFen)) {
      startEval = await evalCached(startingFen);
    }
    double prevWinPct = startEval != null
        ? EvaluationAnalyzer.calculateWinPercentage(
            cp: startEval.scoreCp, mate: startEval.mateIn)
        : 50.0;

    final moves = <MoveAnalysis>[];

    for (var ply = 0; ply < totalPlies; ply++) {
      final entry = parsed[ply];

      // ── Book cutoff: if the move is a known theoretical reply, trust
      // the book and skip the engine entirely. Saves ~70 % of searches in
      // the opening phase and lets batteries live to see move 20. ──
      final bookHit = book?.lookup(entry.fenAfter);
      if (bookHit != null) {
        moves.add(MoveAnalysis(
          ply: ply,
          san: entry.san,
          uci: entry.uci,
          fenBefore: entry.fenBefore,
          fenAfter: entry.fenAfter,
          winPercentBefore: prevWinPct,
          winPercentAfter: prevWinPct,
          deltaW: 0,
          classification: MoveQuality.book,
          isWhiteMove: entry.isWhiteMove,
          engineBestMoveSan: null,
          engineBestMoveUci: null,
          scoreCpAfter: null,
          mateInAfter: null,
          inBook: true,
          openingName: bookHit.name,
          ecoCode: bookHit.eco,
          message: '${bookHit.eco} • ${bookHit.name}',
        ));
        onProgress?.call(ply + 1, totalPlies);
        continue;
      }

      final before = await evalCached(entry.fenBefore);
      final after = await evalCached(entry.fenAfter);

      // Derive the *real* pre-move Win% from the engine — `prevWinPct`
      // may be stale if the previous plies came from the book (book moves
      // preserve the prior Win% unchanged, so the book→engine transition
      // would otherwise show an artificial jump on the first real eval).
      final winPctBefore = before != null
          ? EvaluationAnalyzer.calculateWinPercentage(
              cp: before.scoreCp, mate: before.mateIn)
          : prevWinPct;
      final winPctAfter = after != null
          ? EvaluationAnalyzer.calculateWinPercentage(
              cp: after.scoreCp, mate: after.mateIn)
          : winPctBefore;

      // Backfill any preceding book moves so the chart ramps smoothly
      // from the opening eval (50 % if we started in book) to where the
      // engine actually thinks the position stands when theory ends.
      if (before != null &&
          moves.isNotEmpty &&
          moves.last.classification == MoveQuality.book) {
        _backfillBookWinPct(moves, winPctBefore);
      }

      final result = _analyzer.analyze(
        prevCp: before?.scoreCp,
        prevMate: before?.mateIn,
        currCp: after?.scoreCp,
        currMate: after?.mateIn,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveUci: before?.bestMoveUci,
        playedMoveUci: entry.uci,
      );

      String? engineBestSan;
      if (before?.bestMoveUci != null) {
        engineBestSan = _tryUciToSan(entry.fenBefore, before!.bestMoveUci!);
      }

      moves.add(MoveAnalysis(
        ply: ply,
        san: entry.san,
        uci: entry.uci,
        fenBefore: entry.fenBefore,
        fenAfter: entry.fenAfter,
        winPercentBefore: winPctBefore,
        winPercentAfter: winPctAfter,
        deltaW: result.deltaW,
        classification: result.quality,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveSan: engineBestSan,
        engineBestMoveUci: before?.bestMoveUci,
        scoreCpAfter: after?.scoreCp,
        mateInAfter: after?.mateIn,
        inBook: false,
        message: result.message,
      ));

      prevWinPct = winPctAfter;
      onProgress?.call(ply + 1, totalPlies);
    }

    final winPercentages = moves.map((m) => m.winPercentAfter).toList();
    return AnalysisTimeline(
      moves: moves,
      startingFen: startingFen,
      headers: headers,
      winPercentages: winPercentages,
    );
  }

  /// Rewrite contiguous book moves at the tail of [moves] so their
  /// `winPercentBefore` / `winPercentAfter` interpolate linearly from the
  /// first book move's starting Win% up to [endWinPct]. This makes the
  /// advantage chart read as a smooth ramp through theory instead of a
  /// flat 50 % line followed by an abrupt step on the first engine eval.
  static void _backfillBookWinPct(List<MoveAnalysis> moves, double endWinPct) {
    var start = moves.length - 1;
    while (start > 0 && moves[start - 1].classification == MoveQuality.book) {
      start--;
    }
    final startWinPct = moves[start].winPercentBefore;
    final span = moves.length - start;
    for (var i = start; i < moves.length; i++) {
      final src = moves[i];
      final tBefore = span == 0 ? 1.0 : (i - start) / span;
      final tAfter = span == 0 ? 1.0 : (i - start + 1) / span;
      final wBefore = startWinPct + (endWinPct - startWinPct) * tBefore;
      final wAfter = startWinPct + (endWinPct - startWinPct) * tAfter;
      moves[i] = MoveAnalysis(
        ply: src.ply,
        san: src.san,
        uci: src.uci,
        fenBefore: src.fenBefore,
        fenAfter: src.fenAfter,
        targetSquare: src.targetSquare,
        winPercentBefore: wBefore,
        winPercentAfter: wAfter,
        deltaW: wAfter - wBefore,
        isWhiteMove: src.isWhiteMove,
        classification: src.classification,
        engineBestMoveUci: src.engineBestMoveUci,
        engineBestMoveSan: src.engineBestMoveSan,
        scoreCpAfter: src.scoreCpAfter,
        mateInAfter: src.mateInAfter,
        inBook: src.inBook,
        openingName: src.openingName,
        ecoCode: src.ecoCode,
        message: src.message,
      );
    }
  }

  String? _tryUciToSan(String fen, String uci) {
    try {
      if (uci.length < 4) return null;
      final pos = Chess.fromSetup(Setup.parseFen(fen));
      final from = _parseSquare(uci.substring(0, 2));
      final to = _parseSquare(uci.substring(2, 4));
      if (from == null || to == null) return null;
      Role? promotion;
      if (uci.length == 5) {
        promotion = switch (uci[4]) {
          'q' => Role.queen,
          'r' => Role.rook,
          'b' => Role.bishop,
          'n' => Role.knight,
          _ => null,
        };
      }
      final move = NormalMove(from: from, to: to, promotion: promotion);
      if (!pos.isLegal(move)) return null;
      return pos.makeSan(move).$2;
    } catch (_) {
      return null;
    }
  }

  static Square? _parseSquare(String alg) {
    if (alg.length != 2) return null;
    final file = alg.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(alg[1]);
    if (file < 0 || file > 7 || rank == null || rank < 1 || rank > 8) {
      return null;
    }
    return Square(file + (rank - 1) * 8);
  }

  static String _sqAlg(Square sq) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
    return '$file${sq.rank + 1}';
  }

  static String _roleChar(Role role) => switch (role) {
        Role.queen => 'q',
        Role.rook => 'r',
        Role.bishop => 'b',
        Role.knight => 'n',
        _ => '',
      };
}

class _ParsedMove {
  const _ParsedMove({
    required this.fenBefore,
    required this.fenAfter,
    required this.san,
    required this.uci,
    required this.isWhiteMove,
  });

  final String fenBefore;
  final String fenAfter;
  final String san;
  final String uci;
  final bool isWhiteMove;
}
