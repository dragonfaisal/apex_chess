/// Authoritative production runtime for offline analysis and review.
///
/// One immutable timeline and one selected-ply index drive the board, move
/// list, evaluation, labels, summary, audio, save identity, and exact reopen.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';

enum ReviewRuntimeLifecycle {
  idle,
  validating,
  preparing,
  analyzing,
  cancelling,
  completed,
  failed,
  cancelled,
  reopeningSavedReview,
}

enum ReviewRuntimeSource {
  pastedPgn,
  importedGame,
  archiveExact,
  homeSavedPreview,
  importSavedPreview,
  completedLocalGame,
  legacyCompatibility,
}

enum ReviewRuntimeFailure {
  none,
  invalidPgn,
  engineUnavailable,
  timeout,
  cancelled,
  incompleteEvidence,
  savedReviewMissing,
  corruptedSavedReview,
  saveFailed,
  unknown,
}

extension ReviewRuntimeFailureCopy on ReviewRuntimeFailure {
  String? get safeMessage => switch (this) {
    ReviewRuntimeFailure.none => null,
    ReviewRuntimeFailure.invalidPgn => 'The PGN contains an invalid move.',
    ReviewRuntimeFailure.engineUnavailable =>
      'Offline analysis is unavailable right now.',
    ReviewRuntimeFailure.timeout => 'Offline analysis timed out. Try again.',
    ReviewRuntimeFailure.cancelled => 'Review cancelled.',
    ReviewRuntimeFailure.incompleteEvidence =>
      'Analysis stopped before trustworthy evidence was complete.',
    ReviewRuntimeFailure.savedReviewMissing =>
      'The exact saved review is unavailable.',
    ReviewRuntimeFailure.corruptedSavedReview =>
      'The saved review could not be validated.',
    ReviewRuntimeFailure.saveFailed =>
      'Review completed, but could not be saved.',
    ReviewRuntimeFailure.unknown => 'Could not complete the review.',
  };
}

enum ReviewSaveState { idle, saving, saved, failed }

class ReviewRuntimeRequest {
  const ReviewRuntimeRequest({
    required this.pgn,
    required this.profile,
    required this.source,
    required this.sourceProvider,
    this.sourceGameId,
    this.playedAt,
    this.timeControl,
    this.userIsWhite,
    this.userHandle,
  });

  final String pgn;
  final AnalysisProfile profile;
  final ReviewRuntimeSource source;
  final AnalysisGameSource sourceProvider;
  final String? sourceGameId;
  final DateTime? playedAt;
  final String? timeControl;
  final bool? userIsWhite;
  final String? userHandle;
}

typedef ReviewExecution =
    Future<GameReviewResult> Function(GameReviewRequest request);
typedef ReviewPersistence = Future<String> Function(ReviewDocument document);
typedef ReviewCancellation = void Function();

class ReviewState {
  const ReviewState({
    this.timeline,
    this.currentPly = -1,
    this.lifecycle = ReviewRuntimeLifecycle.idle,
    this.executionId = 0,
    this.progressCompleted = 0,
    this.progressTotal = 0,
    this.failure = ReviewRuntimeFailure.none,
    this.flipped = false,
    this.mode = AnalysisMode.deep,
    this.userIsWhite,
    this.source,
    this.requestedProfile,
    this.gameId,
    this.analysisVariantId,
    this.reviewDocumentId,
    this.providerId,
    this.engineIdentity,
    this.payload,
    this.canonicalDocument,
    this.saveState = ReviewSaveState.idle,
    this.savedDocumentId,
  });

  final AnalysisTimeline? timeline;
  final int currentPly;
  final ReviewRuntimeLifecycle lifecycle;
  final int executionId;
  final int progressCompleted;
  final int progressTotal;
  final ReviewRuntimeFailure failure;
  final bool flipped;
  final AnalysisMode mode;
  final bool? userIsWhite;
  final ReviewRuntimeSource? source;
  final AnalysisProfile? requestedProfile;
  final String? gameId;
  final String? analysisVariantId;
  final String? reviewDocumentId;
  final String? providerId;
  final String? engineIdentity;
  final CanonicalAnalysisPayload? payload;
  final ReviewDocument? canonicalDocument;
  final ReviewSaveState saveState;
  final String? savedDocumentId;

  bool get isLoading => switch (lifecycle) {
    ReviewRuntimeLifecycle.validating ||
    ReviewRuntimeLifecycle.preparing ||
    ReviewRuntimeLifecycle.analyzing ||
    ReviewRuntimeLifecycle.cancelling ||
    ReviewRuntimeLifecycle.reopeningSavedReview => true,
    _ => false,
  };

  bool get isExecuting => switch (lifecycle) {
    ReviewRuntimeLifecycle.validating ||
    ReviewRuntimeLifecycle.preparing ||
    ReviewRuntimeLifecycle.analyzing ||
    ReviewRuntimeLifecycle.cancelling => true,
    _ => false,
  };

  bool get isTrustedComplete =>
      lifecycle == ReviewRuntimeLifecycle.completed &&
      timeline?.isComplete == true;

  String? get error => failure.safeMessage;

  double? get progress => progressTotal <= 0
      ? null
      : (progressCompleted / progressTotal).clamp(0, 1).toDouble();

  ReviewState copyWith({
    int? currentPly,
    ReviewRuntimeLifecycle? lifecycle,
    int? progressCompleted,
    int? progressTotal,
    ReviewRuntimeFailure? failure,
    bool? flipped,
    ReviewSaveState? saveState,
    String? savedDocumentId,
    String? reviewDocumentId,
  }) => ReviewState(
    timeline: timeline,
    currentPly: currentPly ?? this.currentPly,
    lifecycle: lifecycle ?? this.lifecycle,
    executionId: executionId,
    progressCompleted: progressCompleted ?? this.progressCompleted,
    progressTotal: progressTotal ?? this.progressTotal,
    failure: failure ?? this.failure,
    flipped: flipped ?? this.flipped,
    mode: mode,
    userIsWhite: userIsWhite,
    source: source,
    requestedProfile: requestedProfile,
    gameId: gameId,
    analysisVariantId: analysisVariantId,
    reviewDocumentId: reviewDocumentId ?? this.reviewDocumentId,
    providerId: providerId,
    engineIdentity: engineIdentity,
    payload: payload,
    canonicalDocument: canonicalDocument,
    saveState: saveState ?? this.saveState,
    savedDocumentId: savedDocumentId ?? this.savedDocumentId,
  );

  MoveAnalysis? get currentMove {
    final activeTimeline = timeline;
    if (activeTimeline == null ||
        currentPly < 0 ||
        currentPly >= activeTimeline.totalPlies) {
      return null;
    }
    return activeTimeline.moves[currentPly];
  }

  String get currentFen {
    final activeTimeline = timeline;
    if (activeTimeline == null) return _initialFen;
    if (currentPly < 0) return activeTimeline.startingFen;
    return activeTimeline.moves[currentPly].fenAfter;
  }

  int get totalPlies => timeline?.totalPlies ?? 0;

  (String, String)? get lastMove {
    final uci = currentMove?.uci;
    if (uci == null || uci.length < 4) return null;
    return (uci.substring(0, 2), uci.substring(2, 4));
  }

  static const _initialFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
}

class NavigationEvent {
  const NavigationEvent({
    required this.oldPly,
    required this.newPly,
    this.moveAnalysis,
  });

  final int oldPly;
  final int newPly;
  final MoveAnalysis? moveAnalysis;

  int get jumpSize => (newPly - oldPly).abs();
  bool get isSequential => jumpSize == 1;
}

typedef OnNavigationCallback = void Function(NavigationEvent event);

class ReviewController extends Notifier<ReviewState> {
  OnNavigationCallback? onNavigation;

  int _generation = 0;
  int _activeGeneration = 0;
  final Set<int> _cancelledGenerations = <int>{};
  ReviewCancellation? _cancelExecution;
  Future<String?>? _saveFuture;

  @override
  ReviewState build() {
    ref.onDispose(() {
      _cancelledGenerations.add(_activeGeneration);
      _cancelExecution?.call();
    });
    return const ReviewState();
  }

  Future<bool> analyzeOffline({
    required ReviewRuntimeRequest request,
    required ReviewExecution execute,
    required ReviewCancellation cancelExecution,
    required ReviewPersistence persist,
  }) async {
    if (state.isExecuting) {
      _cancelledGenerations.add(_activeGeneration);
      _cancelExecution?.call();
    }
    final generation = ++_generation;
    _activeGeneration = generation;
    _cancelExecution = cancelExecution;
    _saveFuture = null;
    state = ReviewState(
      lifecycle: ReviewRuntimeLifecycle.validating,
      executionId: generation,
      source: request.source,
      requestedProfile: request.profile,
      userIsWhite: request.userIsWhite,
      flipped: request.userIsWhite == false,
      mode: _modeForProfile(request.profile),
    );

    late final CanonicalGame canonicalGame;
    try {
      canonicalGame = const CanonicalGameIdentityService().fromPgn(
        pgn: request.pgn,
        sourceProvider: request.sourceProvider.wire,
        sourceGameId: request.sourceGameId,
        importedAt: request.playedAt,
      );
    } on Object {
      if (_isCurrent(generation)) {
        state = ReviewState(
          lifecycle: ReviewRuntimeLifecycle.failed,
          executionId: generation,
          failure: ReviewRuntimeFailure.invalidPgn,
          source: request.source,
          requestedProfile: request.profile,
          userIsWhite: request.userIsWhite,
          flipped: request.userIsWhite == false,
          mode: _modeForProfile(request.profile),
        );
      }
      return false;
    }

    if (!_isCurrent(generation)) return false;
    state = ReviewState(
      lifecycle: ReviewRuntimeLifecycle.preparing,
      executionId: generation,
      source: request.source,
      requestedProfile: request.profile,
      userIsWhite: request.userIsWhite,
      flipped: request.userIsWhite == false,
      mode: _modeForProfile(request.profile),
      gameId: canonicalGame.gameId.value,
      progressTotal: canonicalGame.moves.length,
    );

    await Future<void>.value();
    if (!_isCurrent(generation)) return false;
    state = state.copyWith(lifecycle: ReviewRuntimeLifecycle.analyzing);

    try {
      final result = await execute(
        GameReviewRequest(
          pgn: request.pgn,
          profile: request.profile,
          userIsWhite: request.userIsWhite,
          userHandle: request.userHandle,
          isCancelled: () => !_isCurrent(generation),
          onProgress: (completed, total) {
            if (!_isCurrent(generation)) return;
            state = state.copyWith(
              lifecycle: ReviewRuntimeLifecycle.analyzing,
              progressCompleted: completed,
              progressTotal: total,
            );
          },
        ),
      );
      if (!_isCurrent(generation)) return false;
      final timeline = result.timeline;
      if (!timeline.isComplete ||
          timeline.totalPlies != canonicalGame.moves.length) {
        throw const ReviewDocumentValidationException(
          'Runtime result is not a complete canonical mainline.',
        );
      }
      final payload =
          result.analysisResult?.payload ??
          CanonicalAnalysisPayload.fromTimeline(
            timeline: timeline,
            pgn: request.pgn,
            source: request.sourceProvider,
            modeUsed: AnalysisReviewMode.offlineLocal,
            providerKind: AnalysisProviderKind.offlineLocal,
            userIsWhite: request.userIsWhite,
            playedAt: request.playedAt,
            timeControl: request.timeControl,
            providerMetadata: result.metadata.toContractMetadata(),
          );
      final document = ReviewDocument.fromCompletedTimeline(
        pgn: request.pgn,
        timeline: timeline,
        sourceProvider: request.sourceProvider.archiveSource.wire,
        sourceGameId: request.sourceGameId ?? payload.sourceId,
        importedAt: request.playedAt,
        userIsWhite: request.userIsWhite,
        createdAt: payload.createdAt,
        timeControl: request.timeControl,
      );
      if (!_isCurrent(generation)) return false;
      state = ReviewState(
        timeline: timeline,
        currentPly: timeline.totalPlies == 0 ? -1 : 0,
        lifecycle: ReviewRuntimeLifecycle.completed,
        executionId: generation,
        progressCompleted: timeline.totalPlies,
        progressTotal: timeline.totalPlies,
        flipped: request.userIsWhite == false,
        mode: _modeForProfile(request.profile),
        userIsWhite: request.userIsWhite,
        source: request.source,
        requestedProfile: request.profile,
        gameId: document.game.gameId.value,
        analysisVariantId: document.variantId.value,
        reviewDocumentId: document.documentId,
        providerId: document.compatibility.providerId,
        engineIdentity: document.compatibility.engine.declaredIdentity,
        payload: payload,
        canonicalDocument: document,
      );
      await saveCurrent(persist);
      return _isCurrent(generation) && state.isTrustedComplete;
    } on TimeoutException {
      _fail(generation, ReviewRuntimeFailure.timeout);
    } on LocalAnalysisException catch (error) {
      if (error.failure == LocalAnalysisFailure.cancelled ||
          !_isCurrent(generation)) {
        _cancelled(generation);
      } else if (error.failure == LocalAnalysisFailure.invalidPgn) {
        _fail(generation, ReviewRuntimeFailure.invalidPgn);
      } else {
        _fail(generation, ReviewRuntimeFailure.incompleteEvidence);
      }
    } on ReviewProviderUnavailableException {
      _fail(generation, ReviewRuntimeFailure.engineUnavailable);
    } on ReviewDocumentValidationException {
      _fail(generation, ReviewRuntimeFailure.incompleteEvidence);
    } on Object {
      _fail(generation, ReviewRuntimeFailure.unknown);
    }
    return false;
  }

  Future<String?> saveCurrent(ReviewPersistence persist) {
    final existing = _saveFuture;
    if (existing != null && state.saveState != ReviewSaveState.failed) {
      return existing;
    }
    if (state.saveState == ReviewSaveState.failed) _saveFuture = null;
    final document = state.canonicalDocument;
    if (!state.isTrustedComplete || document == null) {
      return Future<String?>.value(null);
    }
    final generation = state.executionId;
    state = state.copyWith(
      saveState: ReviewSaveState.saving,
      failure: ReviewRuntimeFailure.none,
    );
    final future = () async {
      try {
        final id = await persist(document);
        if (_isCurrent(generation)) {
          state = state.copyWith(
            saveState: ReviewSaveState.saved,
            savedDocumentId: id,
            reviewDocumentId: id,
          );
        }
        return id;
      } on Object {
        if (_isCurrent(generation)) {
          state = state.copyWith(
            saveState: ReviewSaveState.failed,
            failure: ReviewRuntimeFailure.saveFailed,
          );
        }
        return null;
      }
    }();
    _saveFuture = future;
    return future;
  }

  bool openSavedReview(
    ArchivedGame game, {
    required ReviewRuntimeSource source,
    bool? legacyUserIsWhite,
    int initialPly = 0,
  }) {
    if (state.isExecuting) cancelActiveAnalysis();
    final generation = ++_generation;
    _activeGeneration = generation;
    _saveFuture = null;
    state = ReviewState(
      lifecycle: ReviewRuntimeLifecycle.reopeningSavedReview,
      executionId: generation,
      source: source,
    );
    if (!ReviewEntryContract.canOpenCachedReview(game)) {
      state = ReviewState(
        lifecycle: ReviewRuntimeLifecycle.failed,
        executionId: generation,
        failure: game.isUnavailable
            ? ReviewRuntimeFailure.corruptedSavedReview
            : ReviewRuntimeFailure.savedReviewMissing,
        source: source,
      );
      return false;
    }
    final timeline = game.cachedTimeline!;
    final immutablePerspective =
        game.recordKind == ArchivedRecordKind.canonicalDocument
        ? game.analyzedUserIsWhite
        : legacyUserIsWhite ?? game.analyzedUserIsWhite;
    final safePly = timeline.totalPlies == 0
        ? -1
        : initialPly.clamp(-1, timeline.totalPlies - 1).toInt();
    state = ReviewState(
      timeline: timeline,
      currentPly: safePly,
      lifecycle: ReviewRuntimeLifecycle.completed,
      executionId: generation,
      progressCompleted: timeline.totalPlies,
      progressTotal: timeline.totalPlies,
      flipped: immutablePerspective == false,
      mode: _modeForProfile(game.analysisProfile),
      userIsWhite: immutablePerspective,
      source: source,
      requestedProfile: game.analysisProfile,
      gameId: game.canonicalGameId,
      analysisVariantId: game.analysisVariantId,
      reviewDocumentId: game.canResolveCanonicalDocument ? game.id : null,
      providerId: game.providerId,
      engineIdentity: game.engineIdentity ?? timeline.engineVersion,
      payload: CanonicalAnalysisPayload.fromArchivedGame(
        game,
        userIsWhite: immutablePerspective,
      ),
      saveState: game.canResolveCanonicalDocument
          ? ReviewSaveState.saved
          : ReviewSaveState.idle,
      savedDocumentId: game.canResolveCanonicalDocument ? game.id : null,
    );
    return true;
  }

  void loadTimeline(
    AnalysisTimeline timeline, {
    bool userIsBlack = false,
    AnalysisMode mode = AnalysisMode.deep,
    bool? userIsWhite,
    int initialPly = 0,
  }) {
    final generation = ++_generation;
    _activeGeneration = generation;
    final safePly = timeline.totalPlies == 0
        ? -1
        : initialPly.clamp(-1, timeline.totalPlies - 1).toInt();
    state = ReviewState(
      timeline: timeline,
      currentPly: safePly,
      lifecycle: ReviewRuntimeLifecycle.completed,
      executionId: generation,
      progressCompleted: timeline.totalPlies,
      progressTotal: timeline.totalPlies,
      flipped: userIsBlack,
      mode: mode,
      userIsWhite: userIsWhite ?? (userIsBlack ? false : null),
      source: ReviewRuntimeSource.legacyCompatibility,
      requestedProfile: AnalysisProfile.fromWire(timeline.analysisProfileId),
      providerId: timeline.providerId,
      engineIdentity: timeline.engineVersion,
    );
  }

  void loadPayload(
    CanonicalAnalysisPayload payload, {
    bool userIsBlack = false,
    AnalysisMode? mode,
    bool? userIsWhite,
    int initialPly = 0,
  }) {
    final timeline = payload.timeline;
    if (timeline == null || timeline.moves.isEmpty || !timeline.isComplete) {
      state = ReviewState(
        lifecycle: ReviewRuntimeLifecycle.failed,
        failure: ReviewRuntimeFailure.savedReviewMissing,
      );
      return;
    }
    loadTimeline(
      timeline,
      userIsBlack: userIsBlack,
      mode: mode ?? payload.reviewBoardMode,
      userIsWhite: userIsWhite ?? payload.userIsWhite,
      initialPly: initialPly,
    );
  }

  bool cancelExecutionIfOwned(int executionId) {
    if (state.executionId != executionId || !state.isExecuting) return false;
    cancelActiveAnalysis();
    return true;
  }

  void cancelActiveAnalysis() {
    if (!state.isExecuting) return;
    final generation = _activeGeneration;
    _cancelledGenerations.add(generation);
    state = state.copyWith(lifecycle: ReviewRuntimeLifecycle.cancelling);
    _cancelExecution?.call();
    if (state.executionId == generation) {
      state = ReviewState(
        lifecycle: ReviewRuntimeLifecycle.cancelled,
        executionId: generation,
        failure: ReviewRuntimeFailure.cancelled,
        source: state.source,
        requestedProfile: state.requestedProfile,
        userIsWhite: state.userIsWhite,
        flipped: state.flipped,
        mode: state.mode,
      );
    }
  }

  void toggleFlip() => state = state.copyWith(flipped: !state.flipped);

  void jumpTo(int ply) {
    final timeline = state.timeline;
    if (timeline == null || timeline.totalPlies == 0) return;
    final clamped = ply.clamp(-1, timeline.totalPlies - 1).toInt();
    if (clamped == state.currentPly) return;
    final oldPly = state.currentPly;
    state = state.copyWith(currentPly: clamped);
    onNavigation?.call(
      NavigationEvent(
        oldPly: oldPly,
        newPly: clamped,
        moveAnalysis: clamped < 0 ? null : timeline.moves[clamped],
      ),
    );
  }

  void next() {
    final timeline = state.timeline;
    if (timeline == null || timeline.totalPlies == 0) return;
    if (state.currentPly >= timeline.totalPlies - 1) return;
    jumpTo(state.currentPly + 1);
  }

  void prev() {
    if (state.currentPly <= -1) return;
    jumpTo(state.currentPly - 1);
  }

  void goToStart() => jumpTo(-1);

  void goToEnd() {
    final timeline = state.timeline;
    if (timeline == null || timeline.totalPlies == 0) return;
    jumpTo(timeline.totalPlies - 1);
  }

  void clear() {
    if (state.isExecuting) cancelActiveAnalysis();
    _activeGeneration = ++_generation;
    _saveFuture = null;
    state = ReviewState(executionId: _activeGeneration);
  }

  bool _isCurrent(int generation) =>
      generation == _activeGeneration &&
      !_cancelledGenerations.contains(generation);

  void _fail(int generation, ReviewRuntimeFailure failure) {
    if (!_isCurrent(generation)) return;
    state = ReviewState(
      lifecycle: ReviewRuntimeLifecycle.failed,
      executionId: generation,
      failure: failure,
      source: state.source,
      requestedProfile: state.requestedProfile,
      userIsWhite: state.userIsWhite,
      flipped: state.flipped,
      mode: state.mode,
      gameId: state.gameId,
    );
  }

  void _cancelled(int generation) {
    if (generation != _activeGeneration) return;
    _cancelledGenerations.add(generation);
    state = ReviewState(
      lifecycle: ReviewRuntimeLifecycle.cancelled,
      executionId: generation,
      failure: ReviewRuntimeFailure.cancelled,
      source: state.source,
      requestedProfile: state.requestedProfile,
      userIsWhite: state.userIsWhite,
      flipped: state.flipped,
      mode: state.mode,
    );
  }

  static AnalysisMode _modeForProfile(AnalysisProfile profile) =>
      profile.id == AnalysisProfileId.fastReview
      ? AnalysisMode.quick
      : AnalysisMode.deep;
}

final reviewControllerProvider =
    NotifierProvider<ReviewController, ReviewState>(ReviewController.new);
