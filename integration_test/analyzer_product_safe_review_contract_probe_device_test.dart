import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_product_safe_review_contract_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidProductSafeReviewContractProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_PRODUCT_SAFE_REVIEW_CONTRACT_PROOF';

bool isAndroidProductSafeReviewContractProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidProductSafeReviewContractProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android product-safe review contract proof', (_) async {
    if (!isAndroidProductSafeReviewContractProofEnabled()) {
      markTestSkipped(
        'Set --dart-define='
        '$androidProductSafeReviewContractProofFlag=true '
        'to run the Android product-safe review contract proof.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      // ignore: avoid_print
      print(
        jsonEncode({
          'phase': 'Phase 38C',
          'status': 'skipped',
          'reason': 'Product-safe review contract proof is Android-only.',
          'platform': Platform.operatingSystem,
        }),
      );
      markTestSkipped('Run this proof on an Android device or emulator.');
      return;
    }

    const request = AnalyzerLegacyReintegrationRequest.controlled();
    final chainTrace = <String, Map<String, Object?>>{};
    final result = await LocalAnalyzerProductSafeReviewContractProbe().run(
      request,
      timeout: const Duration(milliseconds: 5000),
      onLayer:
          ({
            required String layer,
            required bool succeeded,
            String? failureMessage,
          }) {
            chainTrace[layer] = {
              'succeeded': succeeded,
              'failureMessage': failureMessage,
            };
          },
    );

    // JSON is log-safe and contains no raw UCI output, public labels,
    // product UI fields, persistence output, file export, or backend data.
    // ignore: avoid_print
    print(
      const JsonEncoder.withIndent('  ').convert({
        'phase': 'Phase 38C',
        'request': {
          'playedMoveUci': request.playedMoveUci,
          'candidateMoveUci': request.candidateMoveUci,
          'moverColor': request.moverColor.wire,
          'requestedDepth': request.requestedDepth,
        },
        'chainTrace': chainTrace,
        'finalContract': _contractJson(result),
      }),
    );

    expect(request.playedMoveUci, analyzerLegacyReintegrationPlayedMoveUci);
    expect(
      request.candidateMoveUci,
      analyzerLegacyReintegrationCandidateMoveUci,
    );
    expect(request.moverColor, AnalyzerMoverColor.white);
    expect(request.requestedDepth, analyzerLegacyReintegrationDepth);

    expect(result.mappingSucceeded, isTrue);
    expect(result.contractComputed, isTrue);
    expect(result.reviewReady, isTrue);
    expect(
      result.reviewUnavailableReason,
      AnalyzerProductSafeReviewUnavailableReason.none,
    );
    expect(
      result.reviewScope,
      AnalyzerProductSafeReviewScope.singleMoveControlled,
    );
    expect(
      result.evidenceStrength,
      AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
    );
    expect(result.totalPrivateEntries, 1);
    expect(result.positiveCandidateCount, 1);
    expect(result.neutralCandidateCount, 0);
    expect(result.negativeCandidateCount, 0);
    expect(result.unavailableCount, 0);
    expect(result.privateCountsAreInternalOnly, isTrue);
    expect(result.contractIsProductSafe, isTrue);
    expect(result.contractIsDeveloperEvidenceBacked, isTrue);
    expect(result.contractIsReadOnly, isTrue);
    expect(result.contractIsUiOutput, isFalse);
    expect(result.contractIsProductUi, isFalse);
    expect(result.contractIsSavedAnalysis, isFalse);
    expect(result.contractIsPersistenceWrite, isFalse);
    expect(result.contractIsFileWrite, isFalse);
    expect(result.contractIsBackendPayload, isFalse);
    expect(result.contractIsArchiveStatsOutput, isFalse);
    expect(result.contractContainsPublicLabels, isFalse);
    expect(result.contractContainsOfficialMetrics, isFalse);
    expect(result.contractContainsUiPresentation, isFalse);
    expect(result.publicLabelComputed, isFalse);
    expect(result.publicLabel, isNull);
    expect(result.officialMoveQualityComputed, isFalse);
    expect(result.officialMoveQuality, isNull);
    expect(result.officialCpLossComputed, isFalse);
    expect(result.officialWinPercentComputed, isFalse);
    expect(result.accuracyComputed, isFalse);
    expect(result.acplComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.publicClassifierOutputComputed, isFalse);
    expect(result.savedAnalysisWritten, isFalse);
    expect(result.uiOutputProduced, isFalse);
    expect(result.persistenceWritePerformed, isFalse);
    expect(result.fileWritePerformed, isFalse);
    expect(result.backendPayloadProduced, isFalse);
    expect(result.archiveStatsTouched, isFalse);
    expect(result.safeForPhase38D, isTrue);
    expect(
      result.nextRecommendation,
      analyzerProductSafeReviewContractNextRecommendation,
    );

    for (final entry in chainTrace.entries) {
      expect(entry.value['succeeded'], isTrue, reason: entry.key);
    }
    expect(chainTrace.keys, contains('non-UI developer preview consumer'));
    expect(chainTrace.keys, contains('product-safe review contract'));
  });
}

Map<String, Object?> _contractJson(AnalyzerProductSafeReviewContract result) {
  return {
    'productSafeReviewContractId': result.productSafeReviewContractId,
    'sourceConsumerResultId': result.sourceConsumerResultId,
    'contractSource': result.contractSource,
    'contractVersion': result.contractVersion,
    'contractComputed': result.contractComputed,
    'reviewReady': result.reviewReady,
    'reviewUnavailableReason': result.reviewUnavailableReason.wire,
    'reviewScope': result.reviewScope.wire,
    'requestedDepth': result.requestedDepth,
    'evidenceStrength': result.evidenceStrength.wire,
    'totalPrivateEntries': result.totalPrivateEntries,
    'positiveCandidateCount': result.positiveCandidateCount,
    'neutralCandidateCount': result.neutralCandidateCount,
    'negativeCandidateCount': result.negativeCandidateCount,
    'unavailableCount': result.unavailableCount,
    'privateCountsAreInternalOnly': result.privateCountsAreInternalOnly,
    'contractIsProductSafe': result.contractIsProductSafe,
    'contractIsDeveloperEvidenceBacked':
        result.contractIsDeveloperEvidenceBacked,
    'contractIsReadOnly': result.contractIsReadOnly,
    'contractIsUiOutput': result.contractIsUiOutput,
    'contractIsProductUi': result.contractIsProductUi,
    'contractIsSavedAnalysis': result.contractIsSavedAnalysis,
    'contractIsPersistenceWrite': result.contractIsPersistenceWrite,
    'contractIsFileWrite': result.contractIsFileWrite,
    'contractIsBackendPayload': result.contractIsBackendPayload,
    'contractIsArchiveStatsOutput': result.contractIsArchiveStatsOutput,
    'contractContainsPublicLabels': result.contractContainsPublicLabels,
    'contractContainsOfficialMetrics': result.contractContainsOfficialMetrics,
    'contractContainsUiPresentation': result.contractContainsUiPresentation,
    'publicLabelComputed': result.publicLabelComputed,
    'publicLabel': result.publicLabel,
    'officialMoveQualityComputed': result.officialMoveQualityComputed,
    'officialMoveQuality': result.officialMoveQuality,
    'officialCpLossComputed': result.officialCpLossComputed,
    'officialWinPercentComputed': result.officialWinPercentComputed,
    'accuracyComputed': result.accuracyComputed,
    'acplComputed': result.acplComputed,
    'classificationComputed': result.classificationComputed,
    'publicClassifierOutputComputed': result.publicClassifierOutputComputed,
    'savedAnalysisWritten': result.savedAnalysisWritten,
    'uiOutputProduced': result.uiOutputProduced,
    'persistenceWritePerformed': result.persistenceWritePerformed,
    'fileWritePerformed': result.fileWritePerformed,
    'backendPayloadProduced': result.backendPayloadProduced,
    'archiveStatsTouched': result.archiveStatsTouched,
    'mappingSucceeded': result.mappingSucceeded,
    'failureMessage': result.failureMessage,
    'safeForPhase38C': result.safeForPhase38C,
    'safeForPhase38D': result.safeForPhase38D,
    'nextRecommendation': result.nextRecommendation,
  };
}
