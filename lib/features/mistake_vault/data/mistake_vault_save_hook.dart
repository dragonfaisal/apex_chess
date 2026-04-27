/// Extracts [MistakeDrill]s from an [AnalysisTimeline] and persists
/// them into the [MistakeVaultRepository].
///
/// Called fire-and-forget from the same sites that call
/// [saveAnalysisToArchive] — any Blunder, Mistake, or Missed Win ply
/// (from the user's perspective) becomes a drill. Missed Win is
/// included per spec § 3.6.5 ("surface them in training as special
/// drills") — these moves used to land in the Mistake / Blunder tier
/// before the Phase A re-classification, so omitting them would
/// silently regress drill coverage. "User's perspective" means
/// every ply played by the opposite colour is skipped when we know
/// which colour the user played; when colour is unknown we include
/// both sides so nothing leaks through.
library;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

import '../domain/mistake_drill.dart';
import '../presentation/controllers/mistake_vault_controller.dart';

/// Phase A: Blunder, Mistake, and Missed Win plies all generate
/// drills. Exposed (rather than `_private`) so the regression in
/// `test/features/mistake_vault/drill_worthiness_test.dart` can pin
/// the policy directly without spinning up Riverpod / Hive.
@visibleForTesting
bool isDrillWorthy(MoveQuality q) =>
    q == MoveQuality.blunder ||
    q == MoveQuality.mistake ||
    q == MoveQuality.missedWin;

/// Stable id: FEN → compact radix-36 hash. FEN is the right key here
/// because the same mistake across two games should dedupe — we
/// reinforce the weakness instead of spawning duplicate drills.
String _drillIdForFen(String fen) =>
    fen.hashCode.toUnsigned(64).toRadixString(36);

/// [userIsWhite] narrows drill extraction to the plies the user
/// actually played. Pass `null` for PGN uploads where we don't know
/// which colour the user played.
Future<int> saveMistakeDrillsFromTimeline({
  required WidgetRef ref,
  required AnalysisTimeline timeline,
  required String archiveId,
  bool? userIsWhite,
}) async {
  try {
    final now = DateTime.now();
    final drills = <MistakeDrill>[];
    for (final move in timeline.moves) {
      if (!isDrillWorthy(move.classification)) continue;
      if (userIsWhite != null && move.isWhiteMove != userIsWhite) continue;
      if (move.engineBestMoveUci == null ||
          move.engineBestMoveUci!.isEmpty) {
        // No reference move → the drill has no correct answer to
        // score against. Skip rather than persist a broken record.
        continue;
      }
      drills.add(MistakeDrill(
        id: _drillIdForFen(move.fenBefore),
        fenBefore: move.fenBefore,
        isWhiteToMove: move.isWhiteMove,
        userMoveUci: move.uci,
        userMoveSan: move.san,
        bestMoveUci: move.engineBestMoveUci!,
        bestMoveSan: move.engineBestMoveSan ?? move.engineBestMoveUci!,
        classification: move.classification,
        sourceGameId: archiveId,
        sourcePly: move.ply,
        createdAt: now,
        nextDueAt: now.add(LeitnerBox.fresh.cooldown),
        openingName: move.openingName,
        ecoCode: move.ecoCode,
      ));
    }
    if (drills.isEmpty) return 0;
    await ref
        .read(mistakeVaultControllerProvider.notifier)
        .ingest(drills);
    return drills.length;
  } catch (_) {
    // Vault is best-effort, same contract as the archive hook.
    return 0;
  }
}
