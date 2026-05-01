/// Helper that persists a freshly-completed [AnalysisTimeline] into the
/// Archive store.
///
/// Called by the analysis dialogs right after the timeline is handed to
/// the `reviewController`. Failures here MUST NOT block the review flow
/// — the user already has their result on-screen; a storage blip just
/// means the game doesn't show up in the archive, which is a quality
/// degradation, not a functional break.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/services/analysis_cache_key.dart';

import '../domain/archived_game.dart';
import '../presentation/controllers/archive_controller.dart';

/// Stable id derived from the PGN text. Uses Dart's built-in
/// `String.hashCode` rather than `crypto.sha1` to avoid pulling a new
/// dependency for what is effectively a de-dup key (collisions are
/// benign — latest analysis wins).
String archiveIdForPgn(String pgn) {
  return stablePgnHash(pgn);
}

/// Fire-and-forget save. Returns the resulting id so callers can log it.
///
/// [analysisMode] is persisted on the [ArchivedGame] so Fast and Deep
/// reviews can be filtered separately in the archive. Defaults to Deep
/// for backwards compatibility with callers that pre-date the split.
Future<String?> saveAnalysisToArchive({
  required WidgetRef ref,
  required AnalysisTimeline timeline,
  required String pgn,
  required int depth,
  required ArchiveSource source,
  DateTime? playedAt,
  AnalysisMode analysisMode = AnalysisMode.deep,
}) async {
  try {
    final profileId = AnalysisProfileId.fromWire(timeline.analysisProfileId);
    final pgnHash = timeline.pgnHash ?? stablePgnHash(pgn);
    final id =
        timeline.cacheKey ??
        buildAnalysisCacheKey(
          pgnHash: pgnHash,
          analysisProfileId: profileId,
          providerId: timeline.providerId,
          engineVersion: timeline.engineVersion,
          classifierVersion: timeline.classifierVersion,
          tacticalVerifierVersion: timeline.tacticalVerifierVersion,
          openingBookVersion: timeline.openingBookVersion,
        );
    final game = ArchivedGame.fromTimeline(
      timeline: timeline,
      id: id,
      source: source,
      depth: depth,
      pgn: pgn,
      playedAt: playedAt,
      analysisMode: analysisMode,
    );
    await ref.read(archiveControllerProvider.notifier).save(game);
    return id;
  } catch (_) {
    // Archive save is best-effort — never block the review flow.
    return null;
  }
}
