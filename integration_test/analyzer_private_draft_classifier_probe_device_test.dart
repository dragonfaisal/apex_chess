import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_private_draft_classifier_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerPrivateDraftClassifierProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_PRIVATE_DRAFT_CLASSIFIER_PROOF';

bool isAndroidAnalyzerPrivateDraftClassifierProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerPrivateDraftClassifierProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer private draft classifier proof', (
    _,
  ) async {
    if (!isAndroidAnalyzerPrivateDraftClassifierProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerPrivateDraftClassifierProofFlag=true '
        'to run the Android private draft classifier proof.',
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

    final result = await LocalAnalyzerPrivateDraftClassifierProbe().run(
      const AnalyzerPrivateDraftClassifierRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35N review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.playedMoveUci, analyzerPrivateDraftClassifierPlayedMoveUci);
    expect(
      result.candidateMoveUci,
      analyzerPrivateDraftClassifierCandidateMoveUci,
    );
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerPrivateDraftClassifierDepth);
    expect(
      result.draftClassificationGateComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.evidenceStructurallyEligibleForFutureClassification,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.evidenceIsDeveloperOnly, isTrue);
    expect(result.moverPerspectiveDeltaCp, isNotNull);
    expect(result.moverPerspectiveCpLossCandidate, isNotNull);
    expect(result.candidateVsPlayedExpectedPointsDelta, isNotNull);
    expect(
      result.privateDraftClassifierComputed,
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
    expect(result.privateDraftClassifierIsPublic, isFalse);
    expect(result.privateDraftClassifierIsOfficialMoveQuality, isFalse);
    expect(result.privateDraftClassifierIsPublicLabel, isFalse);
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
    expect(result.safeForPhase35O, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      analyzerPrivateDraftClassifierNextRecommendation,
    );
  });
}

AnalyzerPrivateDraftClassifierResult _androidOnlySkippedResult() {
  return AnalyzerPrivateDraftClassifierResult(
    playedMoveUci: analyzerPrivateDraftClassifierPlayedMoveUci,
    candidateMoveUci: analyzerPrivateDraftClassifierCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerPrivateDraftClassifierDepth,
    privateClassifierSource: analyzerPrivateDraftClassifierSource,
    privateClassifierModelName: analyzerPrivateDraftClassifierModelName,
    privateClassifierModelVersion: analyzerPrivateDraftClassifierModelVersion,
    draftClassificationGateComputed: false,
    evidenceStructurallyEligibleForFutureClassification: false,
    evidenceIsDeveloperOnly: true,
    gateRecommendation: analyzerPrivateDraftGateBlockedRecommendation,
    moverPerspectiveDeltaCp: null,
    moverPerspectiveCpLossCandidate: null,
    cpLossCandidateDirection: null,
    playedExpectedPointsDelta: null,
    candidateVsPlayedExpectedPointsDelta: null,
    privateDraftClassifierComputed: false,
    privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
    privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.unavailable,
    privateDraftClassifierIsPublic: false,
    privateDraftClassifierIsOfficialMoveQuality: false,
    privateDraftClassifierIsPublicLabel: false,
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
    privateDraftClassifierProbeSucceeded: false,
    failureMessage:
        'Android private draft classifier proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35O: false,
    nextRecommendation: analyzerPrivateDraftClassifierFailureRecommendation,
    blockers: const ['Android private draft classifier proof was not run.'],
    warnings: const [
      'This is not a successful private draft classifier proof.',
      'Do not proceed to Phase 35O yet.',
    ],
  );
}

const analyzerPrivateDraftGateBlockedRecommendation =
    AnalyzerDraftClassificationGateRecommendation.notEligibleMissingEvidence;

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
