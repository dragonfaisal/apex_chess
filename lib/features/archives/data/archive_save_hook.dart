/// Helper that persists a freshly-completed [AnalysisTimeline] into the
/// Archived Intel store.
///
/// Called by the analysis dialogs right after the timeline is handed to
/// the `reviewController`. Failures here MUST NOT block the review flow
/// — the user already has their result on-screen; a storage blip just
/// means the game doesn't show up in the archive, which is a quality
/// degradation, not a functional break.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';

import '../domain/archived_game.dart';
import '../presentation/controllers/archive_controller.dart';

/// Stable id derived from the PGN text. Uses Dart's built-in
/// `String.hashCode` rather than `crypto.sha1` to avoid pulling a new
/// dependency for what is effectively a de-dup key (collisions are
/// benign — latest analysis wins).
String archiveIdForPgn(String pgn) {
  // Mask to an unsigned 64-bit hex string so the box keys read cleanly
  // in inspector tools and survive a JSON round-trip without scientific
  // notation. `hashCode` is already 64-bit-ish on the VM, but on web
  // targets it clamps to 32 bits; both are fine here.
  return pgn.hashCode.toUnsigned(64).toRadixString(16);
}

/// Fire-and-forget save. Returns the resulting id so callers can log it.
Future<String?> saveAnalysisToArchive({
  required WidgetRef ref,
  required AnalysisTimeline timeline,
  required String pgn,
  required int depth,
  required ArchiveSource source,
  DateTime? playedAt,
}) async {
  try {
    final id = archiveIdForPgn(pgn);
    final game = ArchivedGame.fromTimeline(
      timeline: timeline,
      id: id,
      source: source,
      depth: depth,
      pgn: pgn,
      playedAt: playedAt,
    );
    await ref.read(archiveControllerProvider.notifier).save(game);
    return id;
  } catch (_) {
    // Archive save is best-effort — never block the review flow.
    return null;
  }
}
