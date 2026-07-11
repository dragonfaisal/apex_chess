import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_before_after_raw_eval_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerBeforeAfterRawEvalProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_BEFORE_AFTER_RAW_EVAL_PROOF';

bool isAndroidAnalyzerBeforeAfterRawEvalProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerBeforeAfterRawEvalProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer before/after raw eval proof', (_) async {
    if (!isAndroidAnalyzerBeforeAfterRawEvalProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerBeforeAfterRawEvalProofFlag=true '
        'to run the Android analyzer before/after raw eval proof.',
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

    final result = await LocalAnalyzerBeforeAfterRawEvalProbe().run(
      const AnalyzerBeforeAfterRawEvalRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35H review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.beforeFen, analyzerBeforeAfterRawEvalControlledBeforeFen);
    expect(result.afterFen, analyzerBeforeAfterRawEvalControlledAfterFen);
    expect(result.playedMoveUci, analyzerBeforeAfterRawEvalPlayedMoveUci);
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerBeforeAfterRawEvalDepth);
    expect(result.beforeEvalSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.afterEvalSucceeded, isTrue, reason: result.renderMarkdown());
    expect(
      result.beforeAfterRawEvalSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.beforeBestMoveReceived,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.afterBestMoveReceived,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.moverPerspectiveBeforeCp, result.beforeWhitePerspectiveCp);
    expect(result.moverPerspectiveAfterCp, result.afterWhitePerspectiveCp);
    expect(result.deltaComputed, isFalse);
    expect(result.cpLossComputed, isFalse);
    expect(result.winPercentComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.safeForPhase35I, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      analyzerBeforeAfterRawEvalNextRecommendation,
    );

    final json = result.toJson();
    for (final forbiddenField in _forbiddenFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'Before/after raw eval result must not expose forbidden field '
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

AnalyzerBeforeAfterRawEvalResult _androidOnlySkippedResult() {
  return AnalyzerBeforeAfterRawEvalResult(
    beforeFen: analyzerBeforeAfterRawEvalControlledBeforeFen,
    afterFen: analyzerBeforeAfterRawEvalControlledAfterFen,
    playedMoveUci: analyzerBeforeAfterRawEvalPlayedMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerBeforeAfterRawEvalDepth,
    beforeEvalSucceeded: false,
    afterEvalSucceeded: false,
    beforeSideToMove: null,
    afterSideToMove: null,
    beforeRawScoreType: null,
    afterRawScoreType: null,
    beforeRawScoreCp: null,
    afterRawScoreCp: null,
    beforeRawScoreMate: null,
    afterRawScoreMate: null,
    beforeWhitePerspectiveCp: null,
    afterWhitePerspectiveCp: null,
    beforeBlackPerspectiveCp: null,
    afterBlackPerspectiveCp: null,
    beforeWhitePerspectiveMate: null,
    afterWhitePerspectiveMate: null,
    beforeBlackPerspectiveMate: null,
    afterBlackPerspectiveMate: null,
    moverPerspectiveBeforeCp: null,
    moverPerspectiveAfterCp: null,
    moverPerspectiveBeforeMate: null,
    moverPerspectiveAfterMate: null,
    beforeBestMove: null,
    afterBestMove: null,
    beforeBestMoveReceived: false,
    afterBestMoveReceived: false,
    beforeInfoDepthSeen: null,
    afterInfoDepthSeen: null,
    beforeAfterRawEvalSucceeded: false,
    deltaComputed: false,
    cpLossComputed: false,
    winPercentComputed: false,
    classificationComputed: false,
    failureMessage:
        'Android analyzer before/after raw eval proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35I: false,
    nextRecommendation: analyzerBeforeAfterRawEvalFailureRecommendation,
    blockers: const ['Android before/after raw eval proof was not run.'],
    warnings: const [
      'This is not a successful before/after raw eval proof.',
      'Do not proceed to Phase 35I yet.',
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
