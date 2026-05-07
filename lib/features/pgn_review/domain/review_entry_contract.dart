/// Shared contract for review entry points.
///
/// This keeps route decisions explicit: Import/Paste analyze first, saved
/// reviews open from cached timeline when available, and missing saved data
/// falls back to Archive instead of mutating review state.
library;

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';

enum ReviewEntryKind { importedGame, pastedPgn, savedReview }

enum ReviewEntryDestination { analyze, summary, board, archiveFallback }

class ReviewEntryIntent {
  const ReviewEntryIntent._({
    required this.kind,
    required this.destination,
    this.profile,
    this.archiveSearch = '',
  });

  factory ReviewEntryIntent.importedGame(AnalysisProfile profile) {
    return ReviewEntryIntent._(
      kind: ReviewEntryKind.importedGame,
      destination: ReviewEntryDestination.analyze,
      profile: profile,
    );
  }

  factory ReviewEntryIntent.pastedPgn(AnalysisProfile profile) {
    return ReviewEntryIntent._(
      kind: ReviewEntryKind.pastedPgn,
      destination: ReviewEntryDestination.analyze,
      profile: profile,
    );
  }

  factory ReviewEntryIntent.savedReview(
    ArchivedGame? game, {
    bool preferBoard = false,
  }) {
    if (game == null) {
      return const ReviewEntryIntent._(
        kind: ReviewEntryKind.savedReview,
        destination: ReviewEntryDestination.archiveFallback,
      );
    }
    if (ReviewEntryContract.canOpenCachedReview(game)) {
      return ReviewEntryIntent._(
        kind: ReviewEntryKind.savedReview,
        destination: preferBoard
            ? ReviewEntryDestination.board
            : ReviewEntryDestination.summary,
        archiveSearch: ReviewEntryContract.archiveFallbackSearch(game),
      );
    }
    return ReviewEntryIntent._(
      kind: ReviewEntryKind.savedReview,
      destination: ReviewEntryDestination.archiveFallback,
      archiveSearch: ReviewEntryContract.archiveFallbackSearch(game),
    );
  }

  final ReviewEntryKind kind;
  final ReviewEntryDestination destination;
  final AnalysisProfile? profile;
  final String archiveSearch;

  bool get requiresAnalysis => destination == ReviewEntryDestination.analyze;

  bool get mutatesReviewStateBeforeData => false;
}

class ReviewEntryContract {
  const ReviewEntryContract._();

  static bool canOpenCachedReview(ArchivedGame game) {
    final timeline = game.cachedTimeline;
    return game.isCacheCurrent && timeline != null && timeline.moves.isNotEmpty;
  }

  static String archiveFallbackSearch(ArchivedGame game) {
    final eco = game.ecoCode?.trim();
    if (eco != null && eco.isNotEmpty) return eco;
    final opening = game.openingName?.trim();
    if (opening != null && opening.isNotEmpty) return opening;
    final black = game.black.trim();
    if (black.isNotEmpty) return black;
    return game.white.trim();
  }
}
