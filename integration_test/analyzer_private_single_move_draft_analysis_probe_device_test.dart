import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_private_single_move_draft_analysis_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerPrivateSingleMoveDraftAnalysisProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_PRIVATE_SINGLE_MOVE_DRAFT_ANALYSIS_PROOF';

bool isAndroidAnalyzerPrivateSingleMoveDraftAnalysisProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerPrivateSingleMoveDraftAnalysisProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'opt-in Android analyzer private single-move draft analysis proof',
    (_) async {
      if (!isAndroidAnalyzerPrivateSingleMoveDraftAnalysisProofEnabled()) {
        markTestSkipped(
          'Set --dart-define='
          '$androidAnalyzerPrivateSingleMoveDraftAnalysisProofFlag=true '
          'to run the Android private single-move draft analysis proof.',
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

      final result = await LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe()
          .run(
            const AnalyzerPrivateSingleMoveDraftAnalysisRequest.controlled(),
            timeout: const Duration(milliseconds: 5000),
          );

      // JSON and markdown are log-safe and omit raw UCI output so device logs
      // can be copied into Phase 35Q review notes.
      // ignore: avoid_print
      print(result.renderJson());
      // ignore: avoid_print
      print(result.renderMarkdown());

      expect(
        result.playedMoveUci,
        analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci,
      );
      expect(
        result.candidateMoveUci,
        analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci,
      );
      expect(result.moverColor, AnalyzerMoverColor.white);
      expect(
        result.requestedDepth,
        analyzerPrivateSingleMoveDraftAnalysisDepth,
      );
      expect(result.beforeMoverPerspectiveCp, isNotNull);
      expect(result.playedAfterMoverPerspectiveCp, isNotNull);
      expect(result.candidateAfterMoverPerspectiveCp, isNotNull);
      expect(result.moverPerspectiveDeltaCp, isNotNull);
      expect(result.moverPerspectiveCpLossCandidate, isNotNull);
      expect(result.cpDeltaComputed, isTrue);
      expect(result.cpLossCandidateComputed, isTrue);
      expect(result.expectedPointsComputed, isTrue);
      expect(result.draftClassificationGateComputed, isTrue);
      expect(
        result.evidenceStructurallyEligibleForFutureClassification,
        isTrue,
        reason: result.renderMarkdown(),
      );
      expect(result.evidenceIsDeveloperOnly, isTrue);
      expect(result.privateDraftClassifierComputed, isTrue);
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
        result.privateSingleMoveDraftAnalysisComputed,
        isTrue,
        reason: result.renderMarkdown(),
      );
      expect(result.privateSingleMoveDraftAnalysisIsPublic, isFalse);
      expect(result.privateSingleMoveDraftAnalysisIsProductReview, isFalse);
      expect(result.privateSingleMoveDraftAnalysisIsSavedAnalysis, isFalse);
      expect(result.privateSingleMoveDraftAnalysisIsOfficial, isFalse);
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
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
      expect(result.safeForPhase36A, isTrue, reason: result.renderMarkdown());
      expect(
        result.nextRecommendation,
        analyzerPrivateSingleMoveDraftAnalysisNextRecommendation,
      );
    },
  );
}

AnalyzerPrivateSingleMoveDraftAnalysisResult _androidOnlySkippedResult() {
  return AnalyzerPrivateSingleMoveDraftAnalysisResult(
    analysisResultId: 'phase35Q:e2e4:e2e3:white:depth1:skipped',
    playedMoveUci: analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci,
    candidateMoveUci: analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerPrivateSingleMoveDraftAnalysisDepth,
    analysisSource: analyzerPrivateSingleMoveDraftAnalysisSource,
    analysisModelName: analyzerPrivateSingleMoveDraftAnalysisModelName,
    analysisModelVersion: analyzerPrivateSingleMoveDraftAnalysisModelVersion,
    beforeMoverPerspectiveCp: null,
    playedAfterMoverPerspectiveCp: null,
    candidateAfterMoverPerspectiveCp: null,
    moverPerspectiveDeltaCp: null,
    moverPerspectiveCpLossCandidate: null,
    cpDeltaComputed: false,
    cpLossCandidateComputed: false,
    cpLossCandidateDirection: null,
    expectedPointsComputed: false,
    expectedPointsModelName: null,
    expectedPointsModelVersion: null,
    expectedPointsModelIsOfficial: false,
    beforeExpectedPoints: null,
    playedAfterExpectedPoints: null,
    candidateAfterExpectedPoints: null,
    playedExpectedPointsDelta: null,
    candidateVsPlayedExpectedPointsDelta: null,
    draftClassificationGateComputed: false,
    evidenceStructurallyEligibleForFutureClassification: false,
    evidenceIsDeveloperOnly: true,
    gateRecommendation: AnalyzerDraftClassificationGateRecommendation
        .notEligibleMissingEvidence,
    privateDraftClassifierComputed: false,
    privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
    privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.unavailable,
    privateDraftClassifierIsPublic: false,
    privateDraftClassifierIsOfficialMoveQuality: false,
    privateDraftClassifierIsPublicLabel: false,
    privateSingleMoveDraftAnalysisComputed: false,
    privateSingleMoveDraftAnalysisIsPublic: false,
    privateSingleMoveDraftAnalysisIsProductReview: false,
    privateSingleMoveDraftAnalysisIsSavedAnalysis: false,
    privateSingleMoveDraftAnalysisIsOfficial: false,
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
    savedAnalysisWritten: false,
    uiOutputProduced: false,
    privateSingleMoveDraftAnalysisProbeSucceeded: false,
    failureMessage:
        'Android private single-move draft analysis proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase36A: false,
    nextRecommendation:
        analyzerPrivateSingleMoveDraftAnalysisFailureRecommendation,
    blockers: const [
      'Android private single-move draft analysis proof was not run.',
    ],
    warnings: const [
      'This is not a successful private single-move draft analysis proof.',
      'Do not proceed to Phase 36A yet.',
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
