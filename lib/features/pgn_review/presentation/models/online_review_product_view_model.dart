/// Presentation-safe models for future Online Review product screens.
///
/// This mapper is deliberately pure: it reshapes controller/domain state into
/// stable display contracts without reading repositories, DTOs, HTTP clients,
/// or Flutter UI classes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/pgn_review/application/online_review_product_controller.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';

enum OnlineReviewProductViewStatus { idle, loading, success, failure }

enum OnlineReviewProductPrimaryAction { none, submit, retry, reset }

enum OnlineReviewProductNoticeSeverity { info, warning, error }

enum OnlineReviewProductMoveHighlightLevel { none, low, medium, high, critical }

class OnlineReviewProductViewModel {
  OnlineReviewProductViewModel({
    required this.status,
    required this.titleKey,
    required this.messageKey,
    required this.isLoading,
    required this.canSubmit,
    required this.canRetry,
    required this.canReset,
    required this.showSummary,
    required this.showMoves,
    required this.showFailure,
    required this.primaryAction,
    this.summary,
    Iterable<OnlineReviewProductMoveViewModel> moves = const [],
    Iterable<OnlineReviewProductNoticeViewModel> notices = const [],
    this.debug,
  }) : moves = List.unmodifiable(moves),
       notices = List.unmodifiable(notices);

  final OnlineReviewProductViewStatus status;
  final String titleKey;
  final String? messageKey;
  final bool isLoading;
  final bool canSubmit;
  final bool canRetry;
  final bool canReset;
  final bool showSummary;
  final bool showMoves;
  final bool showFailure;
  final OnlineReviewProductPrimaryAction primaryAction;
  final OnlineReviewProductSummaryViewModel? summary;
  final List<OnlineReviewProductMoveViewModel> moves;
  final List<OnlineReviewProductNoticeViewModel> notices;
  final OnlineReviewProductDebugViewModel? debug;
}

class OnlineReviewProductSummaryViewModel {
  const OnlineReviewProductSummaryViewModel({
    required this.totalPlies,
    required this.analyzedMoves,
    required this.failedMoves,
    required this.bestMoveCount,
    required this.inaccuracyCount,
    required this.mistakeCount,
    required this.blunderCount,
    required this.criticalMoveCount,
    required this.averageCpLoss,
    required this.averageExpectedPointsLoss,
    required this.accuracyAvailable,
    required this.acplAvailable,
  });

  final int totalPlies;
  final int analyzedMoves;
  final int failedMoves;
  final int bestMoveCount;
  final int inaccuracyCount;
  final int mistakeCount;
  final int blunderCount;
  final int criticalMoveCount;
  final double? averageCpLoss;
  final double? averageExpectedPointsLoss;
  final bool accuracyAvailable;
  final bool acplAvailable;
}

class OnlineReviewProductMoveViewModel {
  OnlineReviewProductMoveViewModel({
    required this.ply,
    required this.moveNumber,
    required this.side,
    required this.san,
    required this.uci,
    required this.quality,
    required this.confidence,
    required this.hasBetterMove,
    required this.betterMoveUci,
    required this.hasEngineLine,
    required this.isCritical,
    required this.isTacticalCandidate,
    required this.hasMateWarning,
    required Iterable<String> warningCodes,
    required this.highlightLevel,
  }) : warningCodes = List.unmodifiable(warningCodes);

  final int ply;
  final int moveNumber;
  final String side;
  final String? san;
  final String? uci;
  final ApexMoveQuality quality;
  final ApexReviewConfidence confidence;
  final bool hasBetterMove;
  final String? betterMoveUci;
  final bool hasEngineLine;
  final bool isCritical;
  final bool isTacticalCandidate;
  final bool hasMateWarning;
  final List<String> warningCodes;
  final OnlineReviewProductMoveHighlightLevel highlightLevel;
}

class OnlineReviewProductNoticeViewModel {
  const OnlineReviewProductNoticeViewModel({
    required this.code,
    required this.severity,
    required this.retryable,
    required this.validation,
  });

  final String code;
  final OnlineReviewProductNoticeSeverity severity;
  final bool retryable;
  final bool validation;
}

class OnlineReviewProductDebugViewModel {
  const OnlineReviewProductDebugViewModel({
    required this.enabled,
    required this.omittedInternalSectionCount,
    required this.moveCount,
    required this.failedMoves,
    required this.classifierVersion,
    required this.runtimeMigrationReady,
  });

  final bool enabled;
  final int omittedInternalSectionCount;
  final int? moveCount;
  final int? failedMoves;
  final String? classifierVersion;
  final bool? runtimeMigrationReady;
}

class OnlineReviewProductViewModelMapper {
  const OnlineReviewProductViewModelMapper();

  OnlineReviewProductViewModel fromControllerState(
    OnlineReviewProductControllerState state,
  ) {
    return switch (state.status) {
      OnlineReviewProductControllerStatus.idle => _idle(state),
      OnlineReviewProductControllerStatus.loading => _loading(state),
      OnlineReviewProductControllerStatus.success => _success(state),
      OnlineReviewProductControllerStatus.failure => _failure(state),
    };
  }

  OnlineReviewProductViewModel _idle(OnlineReviewProductControllerState state) {
    return OnlineReviewProductViewModel(
      status: OnlineReviewProductViewStatus.idle,
      titleKey: 'onlineReview.idle.title',
      messageKey: null,
      isLoading: false,
      canSubmit: state.canSubmit,
      canRetry: false,
      canReset: false,
      showSummary: false,
      showMoves: false,
      showFailure: false,
      primaryAction: OnlineReviewProductPrimaryAction.submit,
    );
  }

  OnlineReviewProductViewModel _loading(
    OnlineReviewProductControllerState state,
  ) {
    return OnlineReviewProductViewModel(
      status: OnlineReviewProductViewStatus.loading,
      titleKey: 'onlineReview.loading.title',
      messageKey: null,
      isLoading: true,
      canSubmit: false,
      canRetry: false,
      canReset: true,
      showSummary: false,
      showMoves: false,
      showFailure: false,
      primaryAction: OnlineReviewProductPrimaryAction.none,
    );
  }

  OnlineReviewProductViewModel _success(
    OnlineReviewProductControllerState state,
  ) {
    final review = state.review;
    return OnlineReviewProductViewModel(
      status: OnlineReviewProductViewStatus.success,
      titleKey: 'onlineReview.success.title',
      messageKey: null,
      isLoading: false,
      canSubmit: state.canSubmit,
      canRetry: false,
      canReset: true,
      showSummary: review != null,
      showMoves: review != null,
      showFailure: false,
      primaryAction: OnlineReviewProductPrimaryAction.reset,
      summary: review == null ? null : _summary(review.summary),
      moves: review == null ? const [] : _moves(review.moves),
      debug: review == null ? null : _debug(review.debugInfo),
    );
  }

  OnlineReviewProductViewModel _failure(
    OnlineReviewProductControllerState state,
  ) {
    final review = state.review;
    final failure = state.failure;
    final presentation = _failurePresentation(failure);
    return OnlineReviewProductViewModel(
      status: OnlineReviewProductViewStatus.failure,
      titleKey: 'onlineReview.failure.title',
      messageKey: presentation.messageKey,
      isLoading: false,
      canSubmit: state.canSubmit,
      canRetry: state.canRetry,
      canReset: true,
      showSummary: review != null,
      showMoves: review?.moves.isNotEmpty == true,
      showFailure: true,
      primaryAction: _failureAction(state, failure),
      summary: review == null ? null : _summary(review.summary),
      moves: review == null ? const [] : _moves(review.moves),
      notices: failure == null
          ? const []
          : [
              OnlineReviewProductNoticeViewModel(
                code: failure.code,
                severity: presentation.severity,
                retryable: failure.isRetryable,
                validation: failure.validation,
              ),
            ],
      debug: review == null ? null : _debug(review.debugInfo),
    );
  }

  OnlineReviewProductSummaryViewModel _summary(
    ApexOnlineReviewSummary summary,
  ) {
    return OnlineReviewProductSummaryViewModel(
      totalPlies: summary.totalPlies,
      analyzedMoves: summary.analyzedMoves,
      failedMoves: summary.failedMoves,
      bestMoveCount: summary.bestMoveCount,
      inaccuracyCount: summary.inaccuracyCount,
      mistakeCount: summary.mistakeCount,
      blunderCount: summary.blunderCount,
      criticalMoveCount: summary.criticalMoveCount,
      averageCpLoss: summary.averageCpLoss,
      averageExpectedPointsLoss: summary.averageExpectedPointsLoss,
      accuracyAvailable: summary.accuracy != null,
      acplAvailable: summary.acpl != null,
    );
  }

  List<OnlineReviewProductMoveViewModel> _moves(
    Iterable<ApexReviewedMove> moves,
  ) {
    return [
      for (final move in moves)
        OnlineReviewProductMoveViewModel(
          ply: move.ply,
          moveNumber: move.moveNumber,
          side: move.side,
          san: move.san,
          uci: move.uci,
          quality: move.quality,
          confidence: move.confidence,
          hasBetterMove: move.hasBetterMove,
          betterMoveUci: move.betterMove?.moveUci,
          hasEngineLine: move.hasEngineLine,
          isCritical: move.isCritical,
          isTacticalCandidate: move.isTacticalCandidate,
          hasMateWarning: move.hasMateWarning,
          warningCodes: move.warnings,
          highlightLevel: _highlightLevel(move),
        ),
    ];
  }

  OnlineReviewProductDebugViewModel? _debug(ApexReviewDebugInfo? debugInfo) {
    if (debugInfo == null) return null;
    final safety = debugInfo.internalSafetySummary;
    return OnlineReviewProductDebugViewModel(
      enabled: debugInfo.enabled,
      omittedInternalSectionCount: debugInfo.omittedInternalSections.length,
      moveCount: safety?.moveCount,
      failedMoves: safety?.failedMoves,
      classifierVersion: safety?.classifierVersion,
      runtimeMigrationReady: safety?.runtimeMigrationReady,
    );
  }

  OnlineReviewProductMoveHighlightLevel _highlightLevel(ApexReviewedMove move) {
    var level = switch (move.criticalityLevel) {
      ApexCriticalityLevel.critical =>
        OnlineReviewProductMoveHighlightLevel.critical,
      ApexCriticalityLevel.high => OnlineReviewProductMoveHighlightLevel.high,
      ApexCriticalityLevel.medium =>
        OnlineReviewProductMoveHighlightLevel.medium,
      ApexCriticalityLevel.low =>
        move.isCritical || move.isTacticalCandidate || move.hasMateWarning
            ? OnlineReviewProductMoveHighlightLevel.low
            : OnlineReviewProductMoveHighlightLevel.none,
      ApexCriticalityLevel.none => OnlineReviewProductMoveHighlightLevel.none,
    };

    if (move.hasMateWarning) {
      level = _maxHighlight(
        level,
        OnlineReviewProductMoveHighlightLevel.medium,
      );
    }

    if (move.quality == ApexMoveQuality.blunder) {
      level = _maxHighlight(level, OnlineReviewProductMoveHighlightLevel.high);
    } else if (move.quality == ApexMoveQuality.mistake) {
      level = _maxHighlight(
        level,
        OnlineReviewProductMoveHighlightLevel.medium,
      );
    }

    return level;
  }

  OnlineReviewProductMoveHighlightLevel _maxHighlight(
    OnlineReviewProductMoveHighlightLevel first,
    OnlineReviewProductMoveHighlightLevel second,
  ) {
    return first.index >= second.index ? first : second;
  }

  OnlineReviewProductPrimaryAction _failureAction(
    OnlineReviewProductControllerState state,
    OnlineReviewProductUseCaseFailure? failure,
  ) {
    if (state.canRetry) return OnlineReviewProductPrimaryAction.retry;
    if (failure?.source == 'disabled' ||
        failure?.code == 'onlineReviewDisabled') {
      return OnlineReviewProductPrimaryAction.reset;
    }
    return OnlineReviewProductPrimaryAction.submit;
  }

  _FailurePresentation _failurePresentation(
    OnlineReviewProductUseCaseFailure? failure,
  ) {
    if (failure == null) {
      return const _FailurePresentation(
        messageKey: 'onlineReview.failure.unknown',
        severity: OnlineReviewProductNoticeSeverity.error,
      );
    }

    return switch (failure.code) {
      'emptyPgn' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.validation.emptyPgn',
        severity: OnlineReviewProductNoticeSeverity.warning,
      ),
      'onlineReviewDisabled' ||
      'onlineReviewHttpNotConfigured' ||
      'onlineReviewFixtureNotConfigured' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.disabled',
        severity: OnlineReviewProductNoticeSeverity.info,
      ),
      'timeout' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.timeout',
        severity: OnlineReviewProductNoticeSeverity.warning,
      ),
      'networkError' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.network',
        severity: OnlineReviewProductNoticeSeverity.warning,
      ),
      'invalidPgn' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.invalidPgn',
        severity: OnlineReviewProductNoticeSeverity.warning,
      ),
      'contractParseError' || 'invalidJson' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.contract',
        severity: OnlineReviewProductNoticeSeverity.error,
      ),
      'onlineReviewUnexpectedError' ||
      'onlineReviewControllerUnexpectedError' ||
      'unknown' => const _FailurePresentation(
        messageKey: 'onlineReview.failure.unknown',
        severity: OnlineReviewProductNoticeSeverity.error,
      ),
      _ when failure.validation => const _FailurePresentation(
        messageKey: 'onlineReview.failure.validation',
        severity: OnlineReviewProductNoticeSeverity.warning,
      ),
      _ => const _FailurePresentation(
        messageKey: 'onlineReview.failure.unknown',
        severity: OnlineReviewProductNoticeSeverity.error,
      ),
    };
  }
}

class _FailurePresentation {
  const _FailurePresentation({
    required this.messageKey,
    required this.severity,
  });

  final String messageKey;
  final OnlineReviewProductNoticeSeverity severity;
}

final onlineReviewProductViewModelMapperProvider =
    Provider<OnlineReviewProductViewModelMapper>((ref) {
      return const OnlineReviewProductViewModelMapper();
    });

final onlineReviewProductViewModelProvider =
    Provider<OnlineReviewProductViewModel>((ref) {
      final controllerState = ref.watch(onlineReviewProductControllerProvider);
      final mapper = ref.watch(onlineReviewProductViewModelMapperProvider);
      return mapper.fromControllerState(controllerState);
    });
