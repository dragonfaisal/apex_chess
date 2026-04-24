/// Apex Academy controller — surfaces the next due [MistakeDrill],
/// generates multiple-choice distractors via dartchess, and wraps the
/// record-result flow (SRS box mutation + streak/XP update).
library;

import 'dart:math' as math;

import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/mistake_vault/domain/mistake_drill.dart';
import 'package:apex_chess/features/mistake_vault/presentation/controllers/mistake_vault_controller.dart';

import '../../data/academy_stats_repository.dart';

class AcademyDrillOptions {
  const AcademyDrillOptions({
    required this.drill,
    required this.options,
    required this.correctIndex,
  });
  final MistakeDrill drill;
  /// 3–4 candidate SAN moves, one of which is the engine's best move.
  final List<DrillOption> options;
  final int correctIndex;
}

class DrillOption {
  const DrillOption({required this.san, required this.uci});
  final String san;
  final String uci;
}

class AcademyState {
  const AcademyState({
    this.current,
    required this.stats,
    this.lastResultCorrect,
    this.lastAnswerUci,
    this.remainingInQueue = 0,
  });

  /// Null when the queue is empty (congrats screen).
  final AcademyDrillOptions? current;
  final AcademyStats stats;
  /// When set, the view shows a result flash before advancing.
  final bool? lastResultCorrect;
  /// The UCI the user selected (used to highlight the wrong move).
  final String? lastAnswerUci;
  final int remainingInQueue;

  AcademyState copyWith({
    AcademyDrillOptions? current,
    AcademyStats? stats,
    Object? lastResultCorrect = _sentinel,
    Object? lastAnswerUci = _sentinel,
    int? remainingInQueue,
    bool clearCurrent = false,
  }) =>
      AcademyState(
        current: clearCurrent ? null : (current ?? this.current),
        stats: stats ?? this.stats,
        lastResultCorrect: lastResultCorrect == _sentinel
            ? this.lastResultCorrect
            : lastResultCorrect as bool?,
        lastAnswerUci: lastAnswerUci == _sentinel
            ? this.lastAnswerUci
            : lastAnswerUci as String?,
        remainingInQueue: remainingInQueue ?? this.remainingInQueue,
      );
}

const _sentinel = Object();

final academyStatsRepositoryProvider = Provider<AcademyStatsRepository>(
    (ref) => AcademyStatsRepository());

final academyControllerProvider =
    NotifierProvider<AcademyController, AcademyState>(AcademyController.new);

class AcademyController extends Notifier<AcademyState> {
  final _rng = math.Random();
  late final List<MistakeDrill> _sessionQueue;

  @override
  AcademyState build() {
    _sessionQueue = <MistakeDrill>[];
    _bootstrap();
    return AcademyState(stats: AcademyStats.empty());
  }

  Future<void> _bootstrap() async {
    final vault = ref.read(mistakeVaultControllerProvider);
    final stats = await ref.read(academyStatsRepositoryProvider).read();
    // Freeze the queue at session start so newly-analysed games
    // don't inject themselves mid-session.
    _sessionQueue.clear();
    _sessionQueue.addAll(vault.due);
    state = state.copyWith(stats: stats);
    _advance();
  }

  /// Refreshes from Hive in case a scan just landed. Idempotent.
  Future<void> refresh() async {
    await ref.read(mistakeVaultControllerProvider.notifier).ingest(const []);
    await _bootstrap();
  }

  void _advance() {
    if (_sessionQueue.isEmpty) {
      state = state.copyWith(
        clearCurrent: true,
        remainingInQueue: 0,
        lastResultCorrect: null,
        lastAnswerUci: null,
      );
      return;
    }
    final drill = _sessionQueue.removeAt(0);
    final options = _buildOptions(drill);
    if (options == null) {
      // Couldn't build options (malformed FEN / best move not legal)
      // — skip silently rather than crash the session.
      _advance();
      return;
    }
    state = state.copyWith(
      current: options,
      remainingInQueue: _sessionQueue.length + 1,
      lastResultCorrect: null,
      lastAnswerUci: null,
    );
  }

  AcademyDrillOptions? _buildOptions(MistakeDrill drill) {
    try {
      final pos = Chess.fromSetup(Setup.parseFen(drill.fenBefore));
      final legals = <Move>[];
      pos.legalMoves.forEach((from, dests) {
        final fromPiece = pos.board.pieceAt(from);
        for (final sq in dests.squares) {
          // Pawn reaching the back rank = promotion: enumerate the four
          // promotion variants so UCI comparison (`e7e8q` vs `e7e8n`)
          // can resolve to the right entry instead of silently skipping
          // the drill when the best move is a promotion.
          final isPromotion = fromPiece != null &&
              fromPiece.role == Role.pawn &&
              (sq.rank == 0 || sq.rank == 7);
          if (isPromotion) {
            for (final role in const [
              Role.queen,
              Role.rook,
              Role.bishop,
              Role.knight,
            ]) {
              legals.add(NormalMove(from: from, to: sq, promotion: role));
            }
          } else {
            legals.add(NormalMove(from: from, to: sq));
          }
        }
      });
      if (legals.isEmpty) return null;

      String uciOf(Move m) {
        final n = m as NormalMove;
        final promoSuffix = switch (n.promotion) {
          Role.queen => 'q',
          Role.rook => 'r',
          Role.bishop => 'b',
          Role.knight => 'n',
          _ => '',
        };
        return '${_squareToAlg(n.from)}${_squareToAlg(n.to)}$promoSuffix';
      }

      final best = legals.firstWhere(
        (m) => uciOf(m) == drill.bestMoveUci,
        orElse: () => legals.first,
      );
      if (uciOf(best) != drill.bestMoveUci) return null;

      // Pick up to 3 distractors. Prefer moves with the same piece
      // type when possible so the choices feel plausible; fall back
      // to random legal moves otherwise.
      final bestPieceSquare = (best as NormalMove).from;
      final bestPiece = pos.board.pieceAt(bestPieceSquare);
      final sameTypeLegals = bestPiece == null
          ? <Move>[]
          : legals.where((m) {
              final p = pos.board.pieceAt((m as NormalMove).from);
              return p != null && p.role == bestPiece.role && uciOf(m) != drill.bestMoveUci;
            }).toList();
      final otherLegals = legals
          .where((m) => uciOf(m) != drill.bestMoveUci)
          .toList();
      final distractorPool = sameTypeLegals.isEmpty ? otherLegals : sameTypeLegals;
      distractorPool.shuffle(_rng);
      final distractors = distractorPool.take(3).toList();

      // Always include the user's actual mistake as a distractor if
      // legal — keeps the drill honest to the game's context.
      final userMove = legals.firstWhere(
        (m) => uciOf(m) == drill.userMoveUci,
        orElse: () => best,
      );
      if (uciOf(userMove) != drill.bestMoveUci &&
          !distractors.any((m) => uciOf(m) == drill.userMoveUci)) {
        if (distractors.isNotEmpty) distractors.removeLast();
        distractors.add(userMove);
      }

      final allMoves = <Move>[best, ...distractors];
      allMoves.shuffle(_rng);

      final options = allMoves
          .map((m) => DrillOption(san: pos.makeSan(m).$2, uci: uciOf(m)))
          .toList();
      final correctIndex =
          options.indexWhere((o) => o.uci == drill.bestMoveUci);
      if (correctIndex < 0) return null;

      return AcademyDrillOptions(
        drill: drill,
        options: options,
        correctIndex: correctIndex,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> submit(String uci) async {
    final cur = state.current;
    if (cur == null) return;
    final correct = uci == cur.drill.bestMoveUci;
    // Update the Leitner schedule.
    final vaultCtrl = ref.read(mistakeVaultControllerProvider.notifier);
    if (correct) {
      await vaultCtrl.markCorrect(cur.drill);
    } else {
      await vaultCtrl.markWrong(cur.drill);
    }
    // Update stats (streak + XP).
    final repo = ref.read(academyStatsRepositoryProvider);
    final newStats = await repo.recordResult(correct: correct);
    state = state.copyWith(
      lastResultCorrect: correct,
      lastAnswerUci: uci,
      stats: newStats,
    );
  }

  /// Called after the user dismisses the result flash.
  void next() {
    _advance();
  }
}

String _squareToAlg(Square sq) {
  const files = 'abcdefgh';
  return '${files[sq.file]}${sq.rank + 1}';
}
