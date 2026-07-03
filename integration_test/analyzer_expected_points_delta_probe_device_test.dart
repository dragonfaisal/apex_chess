import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_expected_points_delta_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerExpectedPointsDeltaProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_EXPECTED_POINTS_DELTA_PROOF';

bool isAndroidAnalyzerExpectedPointsDeltaProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerExpectedPointsDeltaProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer expected-points delta proof', (_) async {
    if (!isAndroidAnalyzerExpectedPointsDeltaProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerExpectedPointsDeltaProofFlag=true '
        'to run the Android analyzer expected-points delta proof.',
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

    final result = await LocalAnalyzerExpectedPointsDeltaProbe().run(
      const AnalyzerExpectedPointsDeltaRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35K review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerExpectedPointsDepth);
    expect(
      result.cpLossCandidateProbeSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.beforeMoverPerspectiveCp, isNotNull);
    expect(result.playedAfterMoverPerspectiveCp, isNotNull);
    expect(result.candidateAfterMoverPerspectiveCp, isNotNull);
    expect(
      result.expectedPointsComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.beforeExpectedPoints, isNotNull);
    expect(result.playedAfterExpectedPoints, isNotNull);
    expect(result.candidateAfterExpectedPoints, isNotNull);
    expect(
      result.playedExpectedPointsDelta,
      closeTo(
        result.playedAfterExpectedPoints! - result.beforeExpectedPoints!,
        0.000001,
      ),
    );
    expect(
      result.candidateVsPlayedExpectedPointsDelta,
      closeTo(
        result.candidateAfterExpectedPoints! -
            result.playedAfterExpectedPoints!,
        0.000001,
      ),
    );
    expect(result.expectedPointsModelIsOfficial, isFalse);
    expect(result.officialWinPercentComputed, isFalse);
    expect(result.officialCpLossComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.moveQualityComputed, isFalse);
    expect(result.accuracyComputed, isFalse);
    expect(result.acplComputed, isFalse);
    expect(result.safeForPhase35L, isTrue, reason: result.renderMarkdown());
    expect(result.nextRecommendation, analyzerExpectedPointsNextRecommendation);
  });
}

AnalyzerExpectedPointsDeltaResult _androidOnlySkippedResult() {
  return AnalyzerExpectedPointsDeltaResult(
    beforeFen: analyzerExpectedPointsBeforeFen,
    playedAfterFen: analyzerExpectedPointsPlayedAfterFen,
    candidateAfterFen: analyzerExpectedPointsCandidateAfterFen,
    playedMoveUci: analyzerExpectedPointsPlayedMoveUci,
    candidateMoveUci: analyzerExpectedPointsCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerExpectedPointsDepth,
    cpLossCandidateProbeSucceeded: false,
    beforeMoverPerspectiveCp: null,
    playedAfterMoverPerspectiveCp: null,
    candidateAfterMoverPerspectiveCp: null,
    moverPerspectiveDeltaCp: null,
    moverPerspectiveCpLossCandidate: null,
    beforeExpectedPoints: null,
    playedAfterExpectedPoints: null,
    candidateAfterExpectedPoints: null,
    playedExpectedPointsDelta: null,
    candidateVsPlayedExpectedPointsDelta: null,
    expectedPointsComputed: false,
    expectedPointsModelName: analyzerExpectedPointsModelName,
    expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
    expectedPointsModelIsOfficial: analyzerExpectedPointsModelIsOfficial,
    officialWinPercentComputed: false,
    officialCpLossComputed: false,
    classificationComputed: false,
    moveQualityComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    expectedPointsDeltaProbeSucceeded: false,
    failureMessage:
        'Android analyzer expected-points delta proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35L: false,
    nextRecommendation: analyzerExpectedPointsFailureRecommendation,
    blockers: const ['Android expected-points delta proof was not run.'],
    warnings: const [
      'This is not a successful expected-points delta proof.',
      'Do not proceed to Phase 35L yet.',
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
