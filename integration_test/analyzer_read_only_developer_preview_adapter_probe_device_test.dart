import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_read_only_developer_preview_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_read_only_developer_preview_adapter_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidReadOnlyDeveloperPreviewAdapterProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_READ_ONLY_DEVELOPER_PREVIEW_ADAPTER_PROOF';

bool isAndroidReadOnlyDeveloperPreviewAdapterProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidReadOnlyDeveloperPreviewAdapterProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android read-only developer preview adapter proof', (
    _,
  ) async {
    if (!isAndroidReadOnlyDeveloperPreviewAdapterProofEnabled()) {
      markTestSkipped(
        'Set --dart-define='
        '$androidReadOnlyDeveloperPreviewAdapterProofFlag=true '
        'to run the Android read-only developer preview adapter proof.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      // ignore: avoid_print
      print(
        jsonEncode({
          'phase': 'Phase 37A',
          'status': 'skipped',
          'reason':
              'Android read-only developer preview adapter proof is Android-only.',
          'platform': Platform.operatingSystem,
        }),
      );
      markTestSkipped('Run this proof on an Android device or emulator.');
      return;
    }

    const request = AnalyzerLegacyReintegrationRequest.controlled();
    final chainTrace = <String, Map<String, Object?>>{};
    final result = await LocalAnalyzerReadOnlyDeveloperPreviewAdapterProbe()
        .run(
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
        'phase': 'Phase 37A',
        'request': {
          'playedMoveUci': request.playedMoveUci,
          'candidateMoveUci': request.candidateMoveUci,
          'moverColor': request.moverColor.wire,
          'requestedDepth': request.requestedDepth,
        },
        'chainTrace': chainTrace,
        'finalAdapter': result.toJson(),
      }),
    );

    expect(request.playedMoveUci, analyzerLegacyReintegrationPlayedMoveUci);
    expect(
      request.candidateMoveUci,
      analyzerLegacyReintegrationCandidateMoveUci,
    );
    expect(request.moverColor, AnalyzerMoverColor.white);
    expect(request.requestedDepth, analyzerLegacyReintegrationDepth);

    expect(result.mappingSucceeded, isTrue, reason: result.renderJson());
    expect(result.adapterComputed, isTrue, reason: result.renderJson());
    expect(result.previewReady, isTrue, reason: result.renderJson());
    expect(
      result.previewUnavailableReason,
      AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none,
    );
    expect(result.totalPrivateEntries, 1);
    expect(result.positiveCandidateCount, 1);
    expect(result.neutralCandidateCount, 0);
    expect(result.negativeCandidateCount, 0);
    expect(result.unavailableCount, 0);
    expect(result.adapterIsDeveloperOnly, isTrue);
    expect(result.adapterIsReadOnly, isTrue);
    expect(result.adapterIsUiOutput, isFalse);
    expect(result.adapterIsProductReview, isFalse);
    expect(result.adapterIsSavedAnalysis, isFalse);
    expect(result.adapterIsPersistenceWrite, isFalse);
    expect(result.adapterIsBackendPayload, isFalse);
    expect(result.adapterIsArchiveStatsOutput, isFalse);
    expect(result.adapterContainsPublicLabels, isFalse);
    expect(result.adapterContainsOfficialMetrics, isFalse);
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
    expect(result.safeForPhase37B, isTrue, reason: result.renderJson());
    expect(
      result.nextRecommendation,
      analyzerReadOnlyDeveloperPreviewAdapterNextRecommendation,
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
  });
}
