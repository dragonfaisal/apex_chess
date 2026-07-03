import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_draft_classification_gate_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerDraftClassificationGateProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_DRAFT_CLASSIFICATION_GATE_PROOF';

bool isAndroidAnalyzerDraftClassificationGateProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerDraftClassificationGateProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer draft classification gate proof', (
    _,
  ) async {
    if (!isAndroidAnalyzerDraftClassificationGateProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerDraftClassificationGateProofFlag=true '
        'to run the Android draft classification gate proof.',
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

    final result = await LocalAnalyzerDraftClassificationGateProbe().run(
      const AnalyzerDraftClassificationGateRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35M review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.playedMoveUci, analyzerDraftClassificationGatePlayedMoveUci);
    expect(
      result.candidateMoveUci,
      analyzerDraftClassificationGateCandidateMoveUci,
    );
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerDraftClassificationGateDepth);
    expect(
      result.draftEvidenceComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.cpDeltaComputed, isTrue);
    expect(result.cpLossCandidateComputed, isTrue);
    expect(result.expectedPointsComputed, isTrue);
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
    expect(result.evidenceHasBeforeAfterCp, isTrue);
    expect(result.evidenceHasCandidateComparison, isTrue);
    expect(result.evidenceHasExpectedPoints, isTrue);
    expect(result.evidenceIsDeveloperOnly, isTrue);
    expect(
      result.gateRecommendation,
      AnalyzerDraftClassificationGateRecommendation
          .eligibleForFutureDraftClassifier,
    );
    expect(result.publicLabelComputed, isFalse);
    expect(result.publicLabel, isNull);
    expect(result.officialMoveQualityComputed, isFalse);
    expect(result.officialMoveQuality, isNull);
    expect(result.officialCpLossComputed, isFalse);
    expect(result.officialWinPercentComputed, isFalse);
    expect(result.accuracyComputed, isFalse);
    expect(result.acplComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.classifierOutputComputed, isFalse);
    expect(result.safeForPhase35N, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      analyzerDraftClassificationGateNextRecommendation,
    );
  });
}

AnalyzerDraftClassificationGateResult _androidOnlySkippedResult() {
  return AnalyzerDraftClassificationGateResult(
    playedMoveUci: analyzerDraftClassificationGatePlayedMoveUci,
    candidateMoveUci: analyzerDraftClassificationGateCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerDraftClassificationGateDepth,
    gateSource: analyzerDraftClassificationGateSource,
    gateModelName: analyzerDraftClassificationGateModelName,
    gateModelVersion: analyzerDraftClassificationGateModelVersion,
    draftEvidenceComputed: false,
    cpDeltaComputed: false,
    cpLossCandidateComputed: false,
    expectedPointsComputed: false,
    expectedPointsModelIsOfficial: analyzerExpectedPointsModelIsOfficial,
    draftEvidenceIsPublic: false,
    draftEvidenceIsOfficialMoveQuality: false,
    draftEvidenceIsClassifierOutput: false,
    moverPerspectiveDeltaCp: null,
    moverPerspectiveCpLossCandidate: null,
    cpLossCandidateDirection: null,
    playedExpectedPointsDelta: null,
    candidateVsPlayedExpectedPointsDelta: null,
    draftClassificationGateComputed: false,
    evidenceStructurallyEligibleForFutureClassification: false,
    evidenceHasBeforeAfterCp: false,
    evidenceHasCandidateComparison: false,
    evidenceHasExpectedPoints: false,
    evidenceIsDeveloperOnly: true,
    gateRecommendation: AnalyzerDraftClassificationGateRecommendation
        .notEligibleMissingEvidence,
    publicLabelComputed: false,
    publicLabel: null,
    officialMoveQualityComputed: false,
    officialMoveQuality: null,
    officialCpLossComputed: false,
    officialWinPercentComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    classificationComputed: false,
    classifierOutputComputed: false,
    draftClassificationGateProbeSucceeded: false,
    failureMessage:
        'Android draft classification gate proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35N: false,
    nextRecommendation: analyzerDraftClassificationGateFailureRecommendation,
    blockers: const ['Android draft classification gate proof was not run.'],
    warnings: const [
      'This is not a successful draft classification gate proof.',
      'Do not proceed to Phase 35N yet.',
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
