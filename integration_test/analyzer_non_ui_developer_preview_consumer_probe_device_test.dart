import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_non_ui_developer_preview_consumer.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_non_ui_developer_preview_consumer_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidNonUiDeveloperPreviewConsumerProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_NON_UI_DEVELOPER_PREVIEW_CONSUMER_PROOF';

bool isAndroidNonUiDeveloperPreviewConsumerProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidNonUiDeveloperPreviewConsumerProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android non-UI developer preview consumer proof', (
    _,
  ) async {
    if (!isAndroidNonUiDeveloperPreviewConsumerProofEnabled()) {
      markTestSkipped(
        'Set --dart-define='
        '$androidNonUiDeveloperPreviewConsumerProofFlag=true '
        'to run the Android non-UI developer preview consumer proof.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      // ignore: avoid_print
      print(
        jsonEncode({
          'phase': 'Phase 37D',
          'status': 'skipped',
          'reason':
              'Android non-UI developer preview consumer proof is Android-only.',
          'platform': Platform.operatingSystem,
        }),
      );
      markTestSkipped('Run this proof on an Android device or emulator.');
      return;
    }

    const request = AnalyzerLegacyReintegrationRequest.controlled();
    final chainTrace = <String, Map<String, Object?>>{};
    final result = await LocalAnalyzerNonUiDeveloperPreviewConsumerProbe().run(
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
    // product UI fields, persistence payload, file export, or backend data.
    // ignore: avoid_print
    print(
      const JsonEncoder.withIndent('  ').convert({
        'phase': 'Phase 37D',
        'request': {
          'playedMoveUci': request.playedMoveUci,
          'candidateMoveUci': request.candidateMoveUci,
          'moverColor': request.moverColor.wire,
          'requestedDepth': request.requestedDepth,
        },
        'chainTrace': chainTrace,
        'finalConsumer': _consumerJson(result),
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
    expect(result.consumerComputed, isTrue);
    expect(result.consumerReady, isTrue);
    expect(
      result.consumerUnavailableReason,
      AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none,
    );
    expect(result.totalPrivateEntries, 1);
    expect(result.positiveCandidateCount, 1);
    expect(result.neutralCandidateCount, 0);
    expect(result.negativeCandidateCount, 0);
    expect(result.unavailableCount, 0);
    expect(result.consumerIsDeveloperOnly, isTrue);
    expect(result.consumerIsReadOnly, isTrue);
    expect(result.consumerIsUiOutput, isFalse);
    expect(result.consumerIsDebugUi, isFalse);
    expect(result.consumerIsProductReview, isFalse);
    expect(result.consumerIsSavedAnalysis, isFalse);
    expect(result.consumerIsPersistenceWrite, isFalse);
    expect(result.consumerIsFileWrite, isFalse);
    expect(result.consumerIsBackendPayload, isFalse);
    expect(result.consumerIsArchiveStatsOutput, isFalse);
    expect(result.consumerContainsPublicLabels, isFalse);
    expect(result.consumerContainsOfficialMetrics, isFalse);
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
    expect(result.safeForPhase37E, isTrue);
    expect(
      result.nextRecommendation,
      analyzerNonUiDeveloperPreviewConsumerNextRecommendation,
    );

    for (final entry in chainTrace.entries) {
      expect(entry.value['succeeded'], isTrue, reason: entry.key);
    }
    expect(chainTrace.keys, contains('legacy reintegration'));
    expect(chainTrace.keys, contains('move result read model'));
    expect(chainTrace.keys, contains('timeline entry'));
    expect(chainTrace.keys, contains('timeline collection'));
    expect(chainTrace.keys, contains('review summary'));
    expect(chainTrace.keys, contains('review envelope'));
    expect(chainTrace.keys, contains('developer snapshot'));
    expect(chainTrace.keys, contains('export contract'));
    expect(chainTrace.keys, contains('debug read facade'));
    expect(chainTrace.keys, contains('debug preview contract'));
    expect(chainTrace.keys, contains('read-only developer preview adapter'));
    expect(chainTrace.keys, contains('non-UI developer preview consumer'));
  });
}

Map<String, Object?> _consumerJson(
  AnalyzerNonUiDeveloperPreviewConsumerResult result,
) {
  return {
    'consumerResultId': result.consumerResultId,
    'sourceAdapterResultId': result.sourceAdapterResultId,
    'consumerSource': result.consumerSource,
    'consumerVersion': result.consumerVersion,
    'consumerComputed': result.consumerComputed,
    'consumerReady': result.consumerReady,
    'consumerUnavailableReason': result.consumerUnavailableReason.wire,
    'totalPrivateEntries': result.totalPrivateEntries,
    'positiveCandidateCount': result.positiveCandidateCount,
    'neutralCandidateCount': result.neutralCandidateCount,
    'negativeCandidateCount': result.negativeCandidateCount,
    'unavailableCount': result.unavailableCount,
    'consumerIsDeveloperOnly': result.consumerIsDeveloperOnly,
    'consumerIsReadOnly': result.consumerIsReadOnly,
    'consumerIsUiOutput': result.consumerIsUiOutput,
    'consumerIsDebugUi': result.consumerIsDebugUi,
    'consumerIsProductReview': result.consumerIsProductReview,
    'consumerIsSavedAnalysis': result.consumerIsSavedAnalysis,
    'consumerIsPersistenceWrite': result.consumerIsPersistenceWrite,
    'consumerIsFileWrite': result.consumerIsFileWrite,
    'consumerIsBackendPayload': result.consumerIsBackendPayload,
    'consumerIsArchiveStatsOutput': result.consumerIsArchiveStatsOutput,
    'consumerContainsPublicLabels': result.consumerContainsPublicLabels,
    'consumerContainsOfficialMetrics': result.consumerContainsOfficialMetrics,
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
    'safeForPhase37D': result.safeForPhase37D,
    'safeForPhase37E': result.safeForPhase37E,
    'nextRecommendation': result.nextRecommendation,
  };
}
