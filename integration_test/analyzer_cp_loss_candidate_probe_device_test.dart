import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_loss_candidate.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_cp_loss_candidate_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerCpLossCandidateProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_CP_LOSS_CANDIDATE_PROOF';

bool isAndroidAnalyzerCpLossCandidateProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerCpLossCandidateProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer CP loss candidate proof', (_) async {
    if (!isAndroidAnalyzerCpLossCandidateProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerCpLossCandidateProofFlag=true '
        'to run the Android analyzer CP loss candidate proof.',
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

    final result = await LocalAnalyzerCpLossCandidateProbe().run(
      const AnalyzerCpLossCandidateRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35J review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.beforeFen, analyzerCpLossCandidateBeforeFen);
    expect(result.playedAfterFen, analyzerCpLossCandidatePlayedAfterFen);
    expect(result.candidateAfterFen, analyzerCpLossCandidateCandidateAfterFen);
    expect(result.playedMoveUci, analyzerCpLossCandidatePlayedMoveUci);
    expect(result.candidateMoveUci, analyzerCpLossCandidateCandidateMoveUci);
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerCpLossCandidateDepth);
    expect(result.beforeEvalSucceeded, isTrue, reason: result.renderMarkdown());
    expect(
      result.playedAfterEvalSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.candidateAfterEvalSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.playedAfterMoverPerspectiveCp, isNotNull);
    expect(result.candidateAfterMoverPerspectiveCp, isNotNull);
    expect(
      result.cpLossCandidateComputed,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.moverPerspectiveCpLossCandidate,
      result.candidateAfterMoverPerspectiveCp! -
          result.playedAfterMoverPerspectiveCp!,
    );
    expect(result.officialCpLossComputed, isFalse);
    expect(result.winPercentComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.moveQualityComputed, isFalse);
    expect(result.accuracyComputed, isFalse);
    expect(result.safeForPhase35K, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      analyzerCpLossCandidateNextRecommendation,
    );

    final json = result.toJson();
    for (final forbiddenField in _forbiddenFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'CP loss candidate result must not expose forbidden field '
            '$forbiddenField.',
      );
    }
  });
}

const _forbiddenFields = <String>[
  'label',
  'moveLabel',
  'moveQuality',
  'winPercent',
  'whiteWinPercent',
  'blackWinPercent',
  'cpLoss',
  'accuracy',
  'acpl',
  'book',
  'openingPhase',
  'explanation',
];

AnalyzerCpLossCandidateResult _androidOnlySkippedResult() {
  return AnalyzerCpLossCandidateResult(
    beforeFen: analyzerCpLossCandidateBeforeFen,
    playedAfterFen: analyzerCpLossCandidatePlayedAfterFen,
    candidateAfterFen: analyzerCpLossCandidateCandidateAfterFen,
    playedMoveUci: analyzerCpLossCandidatePlayedMoveUci,
    candidateMoveUci: analyzerCpLossCandidateCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerCpLossCandidateDepth,
    beforeEvalSucceeded: false,
    beforeMoverPerspectiveCp: null,
    beforeMoverPerspectiveMate: null,
    beforeBestMove: null,
    beforeBestMoveReceived: false,
    playedAfterEvalSucceeded: false,
    playedAfterMoverPerspectiveCp: null,
    playedAfterMoverPerspectiveMate: null,
    playedAfterBestMove: null,
    playedAfterBestMoveReceived: false,
    candidateAfterEvalSucceeded: false,
    candidateAfterMoverPerspectiveCp: null,
    candidateAfterMoverPerspectiveMate: null,
    candidateAfterBestMove: null,
    candidateAfterBestMoveReceived: false,
    cpDeltaComputed: false,
    moverPerspectiveDeltaCp: null,
    cpLossCandidateComputed: false,
    moverPerspectiveCpLossCandidate: null,
    cpLossCandidateDirection: AnalyzerCpLossCandidateDirection.unavailable,
    officialCpLossComputed: false,
    winPercentComputed: false,
    classificationComputed: false,
    moveQualityComputed: false,
    accuracyComputed: false,
    cpLossCandidateProbeSucceeded: false,
    failureMessage:
        'Android analyzer CP loss candidate proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35K: false,
    nextRecommendation: analyzerCpLossCandidateFailureRecommendation,
    blockers: const ['Android CP loss candidate proof was not run.'],
    warnings: const [
      'This is not a successful CP loss candidate proof.',
      'Do not proceed to Phase 35K yet.',
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
