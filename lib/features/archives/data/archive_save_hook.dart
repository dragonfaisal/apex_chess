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
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';

import '../domain/archived_game.dart';
import '../presentation/controllers/archive_controller.dart';

/// Stable id derived from the PGN text. Uses the shared FNV cache hash so
/// archive and analysis identity stay aligned without a crypto dependency.
String archiveIdForPgn(String pgn) {
  return stablePgnHash(pgn);
}

String archiveIdForAnalysis({
  required String pgn,
  required AnalysisProfileId analysisProfileId,
  required String providerId,
  required String engineVersion,
  String? pgnHash,
  int? classifierVersion,
  int? tacticalVerifierVersion,
  int? openingBookVersion,
}) {
  return buildAnalysisCacheKey(
    pgnHash: pgnHash ?? stablePgnHash(pgn),
    analysisProfileId: analysisProfileId,
    providerId: providerId,
    engineVersion: engineVersion,
    classifierVersion: classifierVersion ?? kApexClassifierVersion,
    tacticalVerifierVersion:
        tacticalVerifierVersion ?? kApexTacticalVerifierVersion,
    openingBookVersion: openingBookVersion ?? kApexOpeningBookVersion,
  );
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
  String? timeControl,
}) async {
  try {
    final payload = CanonicalAnalysisPayload.fromTimeline(
      timeline: timeline,
      pgn: pgn,
      source: AnalysisGameSource.fromArchiveSource(source),
      modeUsed: _reviewModeForTimeline(timeline, analysisMode),
      providerKind: _providerKindForTimeline(timeline, analysisMode),
      playedAt: playedAt,
      timeControl: timeControl,
    );
    final game = archivedGameFromAnalysisPayload(
      payload,
      depth: depth,
      source: source,
      analysisMode: analysisMode,
    );
    await ref.read(archiveControllerProvider.notifier).save(game);
    return game.id;
  } catch (_) {
    // Archive save is best-effort — never block the review flow.
    return null;
  }
}

ArchivedGame archivedGameFromAnalysisPayload(
  CanonicalAnalysisPayload payload, {
  required int depth,
  ArchiveSource? source,
  AnalysisMode? analysisMode,
}) {
  final timeline = payload.timeline;
  if (timeline == null) {
    throw StateError('Analysis payload has no timeline');
  }
  return ArchivedGame.fromTimeline(
    timeline: timeline,
    id: payload.canonicalGameKey,
    source: source ?? payload.source.archiveSource,
    depth: depth,
    pgn: payload.pgn ?? '',
    playedAt: payload.playedAt,
    analysisMode: analysisMode ?? payload.reviewBoardMode,
    timeControl: payload.timeControl,
  );
}

AnalysisReviewMode _reviewModeForTimeline(
  AnalysisTimeline timeline,
  AnalysisMode fallback,
) {
  final profileId = AnalysisProfileId.fromWire(timeline.analysisProfileId);
  if (profileId == AnalysisProfileId.offlineReview) {
    return AnalysisReviewMode.offlineLocal;
  }
  if (profileId == AnalysisProfileId.fastReview) {
    return AnalysisReviewMode.onlineFast;
  }
  if (fallback == AnalysisMode.quick) return AnalysisReviewMode.onlineFast;
  return AnalysisReviewMode.onlineDeep;
}

AnalysisProviderKind _providerKindForTimeline(
  AnalysisTimeline timeline,
  AnalysisMode fallback,
) => _reviewModeForTimeline(timeline, fallback).providerKind;
