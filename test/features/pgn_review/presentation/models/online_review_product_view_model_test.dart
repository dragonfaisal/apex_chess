import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_product_controller.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/online_review_product_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = OnlineReviewProductViewModelMapper();

  group('OnlineReviewProductViewModelMapper state mapping', () {
    test('maps idle state into submit-ready display data', () {
      final viewModel = mapper.fromControllerState(
        const OnlineReviewProductControllerState.idle(),
      );

      expect(viewModel.status, OnlineReviewProductViewStatus.idle);
      expect(viewModel.titleKey, 'onlineReview.idle.title');
      expect(viewModel.messageKey, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.canSubmit, isTrue);
      expect(viewModel.canRetry, isFalse);
      expect(viewModel.canReset, isFalse);
      expect(viewModel.showSummary, isFalse);
      expect(viewModel.showMoves, isFalse);
      expect(viewModel.primaryAction, OnlineReviewProductPrimaryAction.submit);
    });

    test('maps loading state into non-submit display data', () {
      final viewModel = mapper.fromControllerState(
        OnlineReviewProductControllerState.loading(_request()),
      );

      expect(viewModel.status, OnlineReviewProductViewStatus.loading);
      expect(viewModel.titleKey, 'onlineReview.loading.title');
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.canSubmit, isFalse);
      expect(viewModel.canRetry, isFalse);
      expect(viewModel.canReset, isTrue);
      expect(viewModel.showSummary, isFalse);
      expect(viewModel.showMoves, isFalse);
      expect(viewModel.primaryAction, OnlineReviewProductPrimaryAction.none);
    });

    test('maps success summaries, moves, and debug data without mutation', () {
      final review = _review(
        summary: _summary(
          totalPlies: 2,
          analyzedMoves: 2,
          failedMoves: 0,
          bestMoveCount: 1,
          inaccuracyCount: 0,
          mistakeCount: 1,
          blunderCount: 0,
          criticalMoveCount: 1,
          averageCpLoss: 12.5,
          averageExpectedPointsLoss: 0.08,
        ),
        moves: [
          _move(
            ply: 0,
            quality: ApexMoveQuality.best,
            warnings: const ['futureWarning'],
          ),
          _move(
            ply: 1,
            quality: ApexMoveQuality.mistake,
            criticalityLevel: ApexCriticalityLevel.high,
            isCritical: true,
            betterMoveUci: 'e7e5',
          ),
        ],
        debugInfo: _debugInfo(),
      );

      final viewModel = mapper.fromControllerState(
        OnlineReviewProductControllerState.success(review, _request()),
      );

      expect(viewModel.status, OnlineReviewProductViewStatus.success);
      expect(viewModel.titleKey, 'onlineReview.success.title');
      expect(viewModel.showSummary, isTrue);
      expect(viewModel.showMoves, isTrue);
      expect(viewModel.primaryAction, OnlineReviewProductPrimaryAction.reset);
      expect(viewModel.summary!.totalPlies, 2);
      expect(viewModel.summary!.analyzedMoves, 2);
      expect(viewModel.summary!.mistakeCount, 1);
      expect(viewModel.summary!.averageCpLoss, 12.5);
      expect(viewModel.summary!.averageExpectedPointsLoss, 0.08);
      expect(viewModel.moves, hasLength(2));
      expect(viewModel.moves.last.hasBetterMove, isTrue);
      expect(viewModel.moves.last.betterMoveUci, 'e7e5');
      expect(viewModel.moves.first.warningCodes, contains('futureWarning'));
      expect(viewModel.debug!.enabled, isTrue);
      expect(viewModel.debug!.omittedInternalSectionCount, 2);
      expect(viewModel.debug!.moveCount, 2);
      expect(viewModel.debug!.failedMoves, 0);
      expect(viewModel.debug!.classifierVersion, 'classifier-v1');
      expect(viewModel.debug!.runtimeMigrationReady, isFalse);
      expect(
        () => viewModel.moves.add(viewModel.moves.first),
        throwsUnsupportedError,
      );
      expect(
        () => viewModel.moves.first.warningCodes.add('mutated'),
        throwsUnsupportedError,
      );
    });
  });

  group('OnlineReviewProductViewModelMapper failure mapping', () {
    test('maps known failures to stable keys and severities', () {
      final cases = [
        (
          failure: _failure(
            code: 'emptyPgn',
            source: 'validation',
            validation: true,
          ),
          key: 'onlineReview.failure.validation.emptyPgn',
          severity: OnlineReviewProductNoticeSeverity.warning,
          action: OnlineReviewProductPrimaryAction.submit,
        ),
        (
          failure: _failure(code: 'onlineReviewDisabled', source: 'disabled'),
          key: 'onlineReview.failure.disabled',
          severity: OnlineReviewProductNoticeSeverity.info,
          action: OnlineReviewProductPrimaryAction.reset,
        ),
        (
          failure: _failure(
            code: 'timeout',
            source: 'network',
            isRetryable: true,
          ),
          key: 'onlineReview.failure.timeout',
          severity: OnlineReviewProductNoticeSeverity.warning,
          action: OnlineReviewProductPrimaryAction.retry,
        ),
        (
          failure: _failure(
            code: 'networkError',
            source: 'network',
            isRetryable: true,
          ),
          key: 'onlineReview.failure.network',
          severity: OnlineReviewProductNoticeSeverity.warning,
          action: OnlineReviewProductPrimaryAction.retry,
        ),
        (
          failure: _failure(code: 'invalidPgn', source: 'backend'),
          key: 'onlineReview.failure.invalidPgn',
          severity: OnlineReviewProductNoticeSeverity.warning,
          action: OnlineReviewProductPrimaryAction.submit,
        ),
        (
          failure: _failure(code: 'contractParseError', source: 'parsing'),
          key: 'onlineReview.failure.contract',
          severity: OnlineReviewProductNoticeSeverity.error,
          action: OnlineReviewProductPrimaryAction.submit,
        ),
        (
          failure: _failure(code: 'unknown', source: 'unknown'),
          key: 'onlineReview.failure.unknown',
          severity: OnlineReviewProductNoticeSeverity.error,
          action: OnlineReviewProductPrimaryAction.submit,
        ),
      ];

      for (final item in cases) {
        final state = OnlineReviewProductControllerState.failure(
          item.failure,
          _request(),
        );
        final viewModel = mapper.fromControllerState(state);

        expect(viewModel.status, OnlineReviewProductViewStatus.failure);
        expect(viewModel.titleKey, 'onlineReview.failure.title');
        expect(viewModel.messageKey, item.key);
        expect(viewModel.showFailure, isTrue);
        expect(viewModel.notices, hasLength(1));
        expect(viewModel.notices.single.code, item.failure.code);
        expect(viewModel.notices.single.severity, item.severity);
        expect(viewModel.primaryAction, item.action);
      }
    });

    test(
      'keeps retryable failures retryable and validation failures non-retryable',
      () {
        final retryable = mapper.fromControllerState(
          OnlineReviewProductControllerState.failure(
            _failure(code: 'timeout', source: 'network', isRetryable: true),
            _request(),
          ),
        );
        final validation = mapper.fromControllerState(
          OnlineReviewProductControllerState.failure(
            _failure(code: 'emptyPgn', source: 'validation', validation: true),
            _request(pgn: ''),
          ),
        );

        expect(retryable.canRetry, isTrue);
        expect(retryable.primaryAction, OnlineReviewProductPrimaryAction.retry);
        expect(validation.canRetry, isFalse);
        expect(validation.notices.single.validation, isTrue);
        expect(
          validation.primaryAction,
          OnlineReviewProductPrimaryAction.submit,
        );
      },
    );

    test('preserves compact failed-review data when present', () {
      final failedReview = _review(
        status: ApexReviewStatus.failed,
        failure: const ApexReviewFailure(
          code: 'invalidPgn',
          message: 'Invalid PGN',
        ),
        summary: _summary(totalPlies: 0, analyzedMoves: 0, failedMoves: 0),
      );
      final viewModel = mapper.fromControllerState(
        OnlineReviewProductControllerState.failure(
          _failure(code: 'invalidPgn', source: 'backend'),
          _request(pgn: 'not a pgn'),
          review: failedReview,
        ),
      );

      expect(viewModel.showSummary, isTrue);
      expect(viewModel.showMoves, isFalse);
      expect(viewModel.summary!.totalPlies, 0);
      expect(viewModel.moves, isEmpty);
    });
  });

  group('OnlineReviewProductViewModelMapper move mapping', () {
    test('maps conservative highlight levels deterministically', () {
      final review = _review(
        moves: [
          _move(
            ply: 0,
            quality: ApexMoveQuality.best,
            criticalityLevel: ApexCriticalityLevel.none,
          ),
          _move(
            ply: 1,
            quality: ApexMoveQuality.good,
            criticalityLevel: ApexCriticalityLevel.critical,
            isCritical: true,
          ),
          _move(
            ply: 2,
            quality: ApexMoveQuality.good,
            criticalityLevel: ApexCriticalityLevel.none,
            hasMateWarning: true,
          ),
          _move(
            ply: 3,
            quality: ApexMoveQuality.mistake,
            criticalityLevel: ApexCriticalityLevel.none,
          ),
          _move(
            ply: 4,
            quality: ApexMoveQuality.blunder,
            criticalityLevel: ApexCriticalityLevel.low,
          ),
        ],
      );

      final moves = mapper
          .fromControllerState(
            OnlineReviewProductControllerState.success(review, _request()),
          )
          .moves;

      expect(
        moves[0].highlightLevel,
        OnlineReviewProductMoveHighlightLevel.none,
      );
      expect(
        moves[1].highlightLevel,
        OnlineReviewProductMoveHighlightLevel.critical,
      );
      expect(
        moves[2].highlightLevel,
        OnlineReviewProductMoveHighlightLevel.medium,
      );
      expect(
        moves[3].highlightLevel,
        OnlineReviewProductMoveHighlightLevel.medium,
      );
      expect(
        moves[4].highlightLevel,
        OnlineReviewProductMoveHighlightLevel.high,
      );
    });

    test('preserves unknown warning codes verbatim', () {
      final review = _review(
        moves: [
          _move(
            ply: 0,
            quality: ApexMoveQuality.good,
            warnings: const ['futureWarning'],
          ),
        ],
      );

      final viewModel = mapper.fromControllerState(
        OnlineReviewProductControllerState.success(review, _request()),
      );

      expect(viewModel.moves.single.warningCodes, ['futureWarning']);
    });
  });

  group('OnlineReviewProductViewModelMapper guardrails', () {
    test('does not invent official accuracy or ACPL values', () {
      final review = _review(
        summary: _summary(
          totalPlies: 1,
          analyzedMoves: 1,
          failedMoves: 0,
          accuracy: null,
          acpl: null,
        ),
      );

      final summary = mapper
          .fromControllerState(
            OnlineReviewProductControllerState.success(review, _request()),
          )
          .summary!;

      expect(summary.accuracyAvailable, isFalse);
      expect(summary.acplAvailable, isFalse);
    });

    test('keeps compact debug only and omits internal backend shapes', () {
      final review = _review(debugInfo: _debugInfo());
      final viewModel = mapper.fromControllerState(
        OnlineReviewProductControllerState.success(review, _request()),
      );

      expect(viewModel.debug, isNotNull);
      expect(viewModel.debug!.omittedInternalSectionCount, 2);
      expect(viewModel.debug!.classifierVersion, 'classifier-v1');

      final source = File(
        'lib/features/pgn_review/presentation/models/'
        'online_review_product_view_model.dart',
      ).readAsStringSync();
      expect(source, isNot(contains('internalGameKey')));
      expect(source, isNot(contains('sourceEndpoint')));
      expect(source, isNot(contains('classifierExperimentLedger')));
      expect(source, isNot(contains('classifierLedgerSchemaReviewContract')));
      expect(source, isNot(contains('reanalysisEnvelope')));
      expect(source, isNot(contains('reviewDraftOk')));
      expect(source, isNot(contains('ledgerPersistent')));
    });

    test(
      'mapper stays pure, DTO-free, HTTP-free, UI-free, and backend-path free',
      () {
        final source = File(
          'lib/features/pgn_review/presentation/models/'
          'online_review_product_view_model.dart',
        ).readAsStringSync();

        expect(source, contains('class OnlineReviewProductViewModelMapper'));
        expect(source, isNot(contains('OnlineReviewProductResponseDto')));
        expect(source, isNot(contains('online_review_product_dto.dart')));
        expect(source, isNot(contains('apex_http_client.dart')));
        expect(
          source,
          isNot(contains('http_online_review_product_repository')),
        );
        expect(source, isNot(contains('package:http')));
        expect(source, isNot(contains('package:dio')));
        expect(source, isNot(contains('package:flutter/material.dart')));
        expect(source, isNot(contains('package:flutter/widgets.dart')));
        expect(source, isNot(contains('C:\\apex_chess_backend')));
      },
    );
  });
}

ApexOnlineReviewRequest _request({
  String pgn = '1. e4 *',
  ApexOnlineReviewMode mode = ApexOnlineReviewMode.onlineFast,
}) {
  return ApexOnlineReviewRequest(pgn: pgn, mode: mode);
}

OnlineReviewProductUseCaseFailure _failure({
  required String code,
  required String source,
  bool isRetryable = false,
  bool validation = false,
}) {
  return OnlineReviewProductUseCaseFailure(
    code: code,
    message: 'safe message',
    isRetryable: isRetryable,
    source: source,
    validation: validation,
  );
}

ApexOnlineReview _review({
  ApexReviewStatus status = ApexReviewStatus.completed,
  ApexReviewFailure? failure,
  ApexOnlineReviewSummary? summary,
  List<ApexReviewedMove> moves = const [],
  ApexReviewDebugInfo? debugInfo,
}) {
  return ApexOnlineReview(
    contractVersion: 'online-review-product-v1',
    mode: ApexOnlineReviewMode.onlineFast,
    status: status,
    summary: summary ?? _summary(),
    moves: moves,
    providerInfo: const ApexReviewProviderInfo(
      provider: 'fake',
      engine: 'none',
      analysisVersion: 'test',
      classifierVersion: 'test',
      productContractVersion: 'online-review-product-v1',
      mode: ApexOnlineReviewMode.onlineFast,
      targetDepthTier: 'test',
      isExecutionHintOnly: true,
    ),
    debugInfo: debugInfo,
    failure: failure,
  );
}

ApexOnlineReviewSummary _summary({
  int totalPlies = 0,
  int analyzedMoves = 0,
  int failedMoves = 0,
  int bestMoveCount = 0,
  int inaccuracyCount = 0,
  int mistakeCount = 0,
  int blunderCount = 0,
  int criticalMoveCount = 0,
  double? averageCpLoss,
  double? averageExpectedPointsLoss,
  double? accuracy,
  double? acpl,
}) {
  return ApexOnlineReviewSummary(
    totalPlies: totalPlies,
    analyzedMoves: analyzedMoves,
    failedMoves: failedMoves,
    qualityCounts: const {},
    bestMoveCount: bestMoveCount,
    inaccuracyCount: inaccuracyCount,
    mistakeCount: mistakeCount,
    blunderCount: blunderCount,
    criticalMoveCount: criticalMoveCount,
    averageCpLoss: averageCpLoss,
    averageExpectedPointsLoss: averageExpectedPointsLoss,
    accuracy: accuracy,
    acpl: acpl,
  );
}

ApexReviewedMove _move({
  required int ply,
  required ApexMoveQuality quality,
  ApexReviewConfidence confidence = ApexReviewConfidence.high,
  ApexCriticalityLevel criticalityLevel = ApexCriticalityLevel.none,
  bool isCritical = false,
  bool isTacticalCandidate = false,
  bool hasMateWarning = false,
  List<String> warnings = const [],
  String? betterMoveUci,
}) {
  return ApexReviewedMove(
    ply: ply,
    moveNumber: (ply ~/ 2) + 1,
    side: ply.isEven ? 'white' : 'black',
    san: ply.isEven ? 'e4' : 'e5',
    uci: ply.isEven ? 'e2e4' : 'e7e5',
    quality: quality,
    confidence: confidence,
    criticalityLevel: criticalityLevel,
    isCritical: isCritical,
    isTacticalCandidate: isTacticalCandidate,
    hasMateWarning: hasMateWarning,
    warnings: warnings,
    betterMove: betterMoveUci == null
        ? null
        : ApexBetterMove(
            moveUci: betterMoveUci,
            source: 'enginePrimary',
            confidence: confidence,
          ),
    engineLine: ApexEngineLine(pv: const [], multiPvCount: 1),
  );
}

ApexReviewDebugInfo _debugInfo() {
  return ApexReviewDebugInfo(
    enabled: true,
    sourceEndpoint: '/analysis/dev/review-draft',
    omittedInternalSections: const ['reanalysisEnvelope', 'storage'],
    internalSafetySummary: const ApexReviewInternalSafetySummary(
      reviewDraftOk: true,
      moveCount: 2,
      failedMoves: 0,
      classifierVersion: 'classifier-v1',
      ledgerPersistent: false,
      runtimeMigrationReady: false,
    ),
  );
}
