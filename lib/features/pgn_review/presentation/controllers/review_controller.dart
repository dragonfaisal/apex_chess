/// PGN Review Controller — O(1) ply navigation over pre-computed timeline.
///
/// Manages the current ply index and provides instant access to
/// [MoveAnalysis] data. Emits [NavigationEvent]s to the audio controller.
/// ZERO network calls during navigation — everything is in-memory.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/analysis_timeline.dart';
import '../../../../core/domain/entities/move_analysis.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ReviewState {
  /// The full pre-computed analysis timeline.
  final AnalysisTimeline? timeline;

  /// Current ply index. -1 = starting position (no move played yet).
  final int currentPly;

  /// Whether the timeline is currently being loaded.
  final bool isLoading;

  /// Error message if loading failed.
  final String? error;

  /// Board orientation — `false` (default) = White at bottom; `true` =
  /// Black at bottom. Set automatically from the imported user's
  /// colour at [ReviewController.loadTimeline] time and toggleable
  /// via [ReviewController.toggleFlip] for manual override.
  final bool flipped;

  const ReviewState({
    this.timeline,
    this.currentPly = -1,
    this.isLoading = false,
    this.error,
    this.flipped = false,
  });

  ReviewState copyWith({
    AnalysisTimeline? timeline,
    int? currentPly,
    bool? isLoading,
    String? error,
    bool? flipped,
  }) =>
      ReviewState(
        timeline: timeline ?? this.timeline,
        currentPly: currentPly ?? this.currentPly,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        flipped: flipped ?? this.flipped,
      );

  /// O(1) access to the current ply's analysis.
  MoveAnalysis? get currentMove => timeline?[currentPly];

  /// FEN for the current board position.
  String get currentFen {
    if (timeline == null) return _initialFen;
    if (currentPly < 0) return timeline!.startingFen;
    return timeline!.moves[currentPly].fenAfter;
  }

  /// Total plies in the timeline.
  int get totalPlies => timeline?.totalPlies ?? 0;

  /// Last move (from, to) for board highlight.
  (String, String)? get lastMove {
    final move = currentMove;
    if (move == null) return null;
    final uci = move.uci;
    if (uci.length < 4) return null;
    return (uci.substring(0, 2), uci.substring(2, 4));
  }

  static const _initialFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Event (for AudioController)
// ─────────────────────────────────────────────────────────────────────────────

class NavigationEvent {
  final int oldPly;
  final int newPly;
  final MoveAnalysis? moveAnalysis;

  /// Number of plies jumped (absolute).
  int get jumpSize => (newPly - oldPly).abs();

  /// Whether this is a sequential step (+1 or -1).
  bool get isSequential => jumpSize == 1;

  const NavigationEvent({
    required this.oldPly,
    required this.newPly,
    this.moveAnalysis,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Callback type for navigation events (consumed by audio controller).
typedef OnNavigationCallback = void Function(NavigationEvent event);

class ReviewController extends Notifier<ReviewState> {
  /// Set by the audio controller to receive navigation events.
  OnNavigationCallback? onNavigation;

  @override
  ReviewState build() {
    return const ReviewState();
  }

  /// Loads a pre-computed timeline into the review controller.
  ///
  /// [userIsBlack] auto-flips the board so the imported user is at the
  /// bottom — the integration-audit fix for the "my games show me at
  /// the top when I imported as Black" perspective bug.
  void loadTimeline(AnalysisTimeline timeline, {bool userIsBlack = false}) {
    state = ReviewState(
      timeline: timeline,
      currentPly: -1,
      flipped: userIsBlack,
    );
  }

  /// Toggle the manual board-flip override. The orientation persists
  /// for the lifetime of the loaded timeline.
  void toggleFlip() {
    state = state.copyWith(flipped: !state.flipped);
  }

  /// Navigates to a specific ply.
  void jumpTo(int ply) {
    final t = state.timeline;
    if (t == null) return;

    final clamped = ply.clamp(-1, t.totalPlies - 1);
    if (clamped == state.currentPly) return;

    final oldPly = state.currentPly;
    state = state.copyWith(currentPly: clamped);

    onNavigation?.call(NavigationEvent(
      oldPly: oldPly,
      newPly: clamped,
      moveAnalysis: t[clamped],
    ));
  }

  /// Step forward one ply.
  void next() => jumpTo(state.currentPly + 1);

  /// Step backward one ply.
  void prev() => jumpTo(state.currentPly - 1);

  /// Jump to the starting position.
  void goToStart() => jumpTo(-1);

  /// Jump to the final position.
  void goToEnd() {
    final t = state.timeline;
    if (t == null) return;
    jumpTo(t.totalPlies - 1);
  }

  /// Clears the timeline (e.g. when navigating away).
  void clear() {
    state = const ReviewState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reviewControllerProvider =
    NotifierProvider<ReviewController, ReviewState>(ReviewController.new);
