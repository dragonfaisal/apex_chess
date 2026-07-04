import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_legacy_reintegration_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerLegacyReintegrationProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_LEGACY_REINTEGRATION_PROOF';

bool isAndroidAnalyzerLegacyReintegrationProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerLegacyReintegrationProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer legacy reintegration proof', (_) async {
    if (!isAndroidAnalyzerLegacyReintegrationProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerLegacyReintegrationProofFlag=true '
        'to run the Android legacy reintegration proof.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      final skipped = _androidOnlySkippedResult();
      // ignore: avoid_print
      print(skipped.renderJson());
      // ignore: avoid_print
      print(skipped.renderMarkdown());
      markTestSkipped('Run this proof on an Android device or emulator.');
      return;
    }

    final result = await LocalAnalyzerLegacyReintegrationProbe().run(
      const AnalyzerLegacyReintegrationRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 36A review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.playedMoveUci, analyzerLegacyReintegrationPlayedMoveUci);
    expect(
      result.candidateMoveUci,
      analyzerLegacyReintegrationCandidateMoveUci,
    );
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerLegacyReintegrationDepth);
    expect(result.phase35QAnalysisResultId, 'phase35Q:e2e4:e2e3:white:depth1');
    expect(
      result.privateSingleMoveDraftAnalysisComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.privateDraftBucket,
      AnalyzerPrivateDraftBucket.positiveCandidate,
    );
    expect(
      result.privateDraftReasonCode,
      AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
    );
    expect(
      result.privateDraftConfidenceTier,
      AnalyzerPrivateDraftConfidenceTier.low,
    );
    expect(
      result.legacyReintegrationComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.legacyReintegrationIsPublic, isFalse);
    expect(result.legacyReintegrationIsProductReview, isFalse);
    expect(result.legacyReintegrationIsSavedAnalysis, isFalse);
    expect(result.legacyReintegrationIsOfficial, isFalse);
    expect(result.legacyPublicLabelProduced, isFalse);
    expect(result.legacyOfficialMoveQualityProduced, isFalse);
    expect(result.legacySavedAnalysisWritten, isFalse);
    expect(result.legacyUiOutputProduced, isFalse);
    expect(result.legacyArchiveStatsTouched, isFalse);
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
    expect(result.safeForPhase36B, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      analyzerLegacyReintegrationNextRecommendation,
    );
  });
}

AnalyzerLegacyReintegrationResult _androidOnlySkippedResult() {
  return AnalyzerLegacyReintegrationResult(
    legacyReintegrationResultId: 'phase36A:e2e4:e2e3:white:depth1:skipped',
    playedMoveUci: analyzerLegacyReintegrationPlayedMoveUci,
    candidateMoveUci: analyzerLegacyReintegrationCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerLegacyReintegrationDepth,
    reintegrationSource: analyzerLegacyReintegrationSource,
    reintegrationModelName: analyzerLegacyReintegrationModelName,
    reintegrationModelVersion: analyzerLegacyReintegrationModelVersion,
    phase35QAnalysisResultId: 'unavailable',
    privateSingleMoveDraftAnalysisComputed: false,
    privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
    privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.unavailable,
    legacyReintegrationComputed: false,
    legacyReintegrationIsPublic: false,
    legacyReintegrationIsProductReview: false,
    legacyReintegrationIsSavedAnalysis: false,
    legacyReintegrationIsOfficial: false,
    legacyPublicLabelProduced: false,
    legacyOfficialMoveQualityProduced: false,
    legacySavedAnalysisWritten: false,
    legacyUiOutputProduced: false,
    legacyArchiveStatsTouched: false,
    publicLabelComputed: false,
    publicLabel: null,
    officialMoveQualityComputed: false,
    officialMoveQuality: null,
    officialCpLossComputed: false,
    officialWinPercentComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    classificationComputed: false,
    publicClassifierOutputComputed: false,
    legacyReintegrationProbeSucceeded: false,
    failureMessage:
        'Android legacy reintegration proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase36B: false,
    nextRecommendation: analyzerLegacyReintegrationFailureRecommendation,
    blockers: const ['Android legacy reintegration proof was not run.'],
    warnings: const [
      'This is not a successful legacy reintegration proof.',
      'Do not proceed to Phase 36B yet.',
    ],
  );
}

String _runtimeAbiLabel() {
  try {
    return switch (Abi.current()) {
      Abi.androidArm => 'armeabi-v7a',
      Abi.androidArm64 => 'arm64-v8a',
      Abi.androidIA32 => 'x86',
      Abi.androidX64 => 'x86_64',
      Abi.windowsX64 => 'windows-x64',
      Abi.windowsArm64 => 'windows-arm64',
      Abi.linuxX64 => 'linux-x64',
      Abi.linuxArm64 => 'linux-arm64',
      Abi.macosX64 => 'macos-x64',
      Abi.macosArm64 => 'macos-arm64',
      _ => Abi.current().toString(),
    };
  } on Object {
    return 'unknown';
  }
}
