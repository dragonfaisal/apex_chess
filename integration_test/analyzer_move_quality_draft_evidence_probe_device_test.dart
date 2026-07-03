import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_move_quality_draft_evidence_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerMoveQualityDraftEvidenceProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_MOVE_QUALITY_DRAFT_EVIDENCE_PROOF';

bool isAndroidAnalyzerMoveQualityDraftEvidenceProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerMoveQualityDraftEvidenceProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer move quality draft evidence proof', (
    _,
  ) async {
    if (!isAndroidAnalyzerMoveQualityDraftEvidenceProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerMoveQualityDraftEvidenceProofFlag=true '
        'to run the Android move quality draft evidence proof.',
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

    final result = await LocalAnalyzerMoveQualityDraftEvidenceProbe().run(
      const AnalyzerMoveQualityDraftEvidenceRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35L review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.playedMoveUci, analyzerMoveQualityDraftEvidencePlayedMoveUci);
    expect(
      result.candidateMoveUci,
      analyzerMoveQualityDraftEvidenceCandidateMoveUci,
    );
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerMoveQualityDraftEvidenceDepth);
    expect(result.beforeMoverPerspectiveCp, isNotNull);
    expect(result.playedAfterMoverPerspectiveCp, isNotNull);
    expect(result.candidateAfterMoverPerspectiveCp, isNotNull);
    expect(result.moverPerspectiveDeltaCp, isNotNull);
    expect(result.moverPerspectiveCpLossCandidate, isNotNull);
    expect(
      result.expectedPointsComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.beforeExpectedPoints, isNotNull);
    expect(result.playedAfterExpectedPoints, isNotNull);
    expect(result.candidateAfterExpectedPoints, isNotNull);
    expect(result.playedExpectedPointsDelta, isNotNull);
    expect(result.candidateVsPlayedExpectedPointsDelta, isNotNull);
    expect(
      result.draftEvidenceComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.draftEvidenceIsPublic, isFalse);
    expect(result.draftEvidenceIsOfficialMoveQuality, isFalse);
    expect(result.draftEvidenceIsClassifierOutput, isFalse);
    expect(result.publicLabelComputed, isFalse);
    expect(result.officialMoveQualityComputed, isFalse);
    expect(result.officialCpLossComputed, isFalse);
    expect(result.officialWinPercentComputed, isFalse);
    expect(result.accuracyComputed, isFalse);
    expect(result.acplComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.safeForPhase35M, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      analyzerMoveQualityDraftEvidenceNextRecommendation,
    );

    final json = result.toJson();
    for (final forbiddenField in _forbiddenFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'Draft evidence result must not expose forbidden field '
            '$forbiddenField.',
      );
    }
  });
}

const _forbiddenFields = <String>[
  'label',
  'publicLabel',
  'moveLabel',
  'classificationLabel',
  'badge',
  'icon',
  'brilliant',
  'great',
  'best',
  'mistake',
  'blunder',
  'explanation',
  'savedAnalysis',
];

AnalyzerMoveQualityDraftEvidenceResult _androidOnlySkippedResult() {
  return AnalyzerMoveQualityDraftEvidenceResult(
    playedMoveUci: analyzerMoveQualityDraftEvidencePlayedMoveUci,
    candidateMoveUci: analyzerMoveQualityDraftEvidenceCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerMoveQualityDraftEvidenceDepth,
    evidenceSource: analyzerMoveQualityDraftEvidenceSource,
    evidenceModelName: analyzerMoveQualityDraftEvidenceModelName,
    evidenceModelVersion: analyzerMoveQualityDraftEvidenceModelVersion,
    beforeMoverPerspectiveCp: null,
    playedAfterMoverPerspectiveCp: null,
    candidateAfterMoverPerspectiveCp: null,
    moverPerspectiveDeltaCp: null,
    moverPerspectiveCpLossCandidate: null,
    cpDeltaComputed: false,
    cpLossCandidateComputed: false,
    cpLossCandidateDirection: null,
    expectedPointsModelName: 'none',
    expectedPointsModelVersion: 'none',
    expectedPointsModelIsOfficial: false,
    beforeExpectedPoints: null,
    playedAfterExpectedPoints: null,
    candidateAfterExpectedPoints: null,
    playedExpectedPointsDelta: null,
    candidateVsPlayedExpectedPointsDelta: null,
    expectedPointsComputed: false,
    draftEvidenceComputed: false,
    draftEvidenceIsPublic: false,
    draftEvidenceIsOfficialMoveQuality: false,
    draftEvidenceIsClassifierOutput: false,
    publicLabelComputed: false,
    officialMoveQualityComputed: false,
    officialCpLossComputed: false,
    officialWinPercentComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    classificationComputed: false,
    moveQualityDraftEvidenceProbeSucceeded: false,
    failureMessage:
        'Android move quality draft evidence proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35M: false,
    nextRecommendation: analyzerMoveQualityDraftEvidenceFailureRecommendation,
    blockers: const ['Android draft evidence proof was not run.'],
    warnings: const [
      'This is not a successful draft evidence proof.',
      'Do not proceed to Phase 35M yet.',
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
