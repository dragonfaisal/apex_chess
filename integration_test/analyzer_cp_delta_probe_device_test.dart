import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_delta.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_cp_delta_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerCpDeltaProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_CP_DELTA_PROOF';

bool isAndroidAnalyzerCpDeltaProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerCpDeltaProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer CP delta proof', (_) async {
    if (!isAndroidAnalyzerCpDeltaProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerCpDeltaProofFlag=true '
        'to run the Android analyzer CP delta proof.',
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

    final result = await LocalAnalyzerCpDeltaProbe().run(
      const AnalyzerCpDeltaRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35I review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.beforeFen, analyzerCpDeltaControlledBeforeFen);
    expect(result.afterFen, analyzerCpDeltaControlledAfterFen);
    expect(result.playedMoveUci, analyzerCpDeltaPlayedMoveUci);
    expect(result.moverColor, AnalyzerMoverColor.white);
    expect(result.requestedDepth, analyzerCpDeltaDepth);
    expect(
      result.beforeAfterRawEvalSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.beforeEvalSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.afterEvalSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.moverPerspectiveBeforeCp, isNotNull);
    expect(result.moverPerspectiveAfterCp, isNotNull);
    expect(result.cpDeltaComputed, isTrue, reason: result.renderMarkdown());
    expect(
      result.moverPerspectiveDeltaCp,
      result.moverPerspectiveAfterCp! - result.moverPerspectiveBeforeCp!,
    );
    expect(result.deltaDirection, isNot(AnalyzerCpDeltaDirection.unavailable));
    expect(result.cpLossComputed, isFalse);
    expect(result.winPercentComputed, isFalse);
    expect(result.classificationComputed, isFalse);
    expect(result.moveQualityComputed, isFalse);
    expect(result.safeForPhase35J, isTrue, reason: result.renderMarkdown());
    expect(result.nextRecommendation, analyzerCpDeltaNextRecommendation);

    final json = result.toJson();
    for (final forbiddenField in _forbiddenFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'CP delta result must not expose forbidden field '
            '$forbiddenField.',
      );
    }
  });
}

const _forbiddenFields = <String>[
  'label',
  'moveLabel',
  'classification',
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

AnalyzerCpDeltaResult _androidOnlySkippedResult() {
  return AnalyzerCpDeltaResult(
    beforeFen: analyzerCpDeltaControlledBeforeFen,
    afterFen: analyzerCpDeltaControlledAfterFen,
    playedMoveUci: analyzerCpDeltaPlayedMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerCpDeltaDepth,
    beforeAfterRawEvalSucceeded: false,
    beforeEvalSucceeded: false,
    afterEvalSucceeded: false,
    moverPerspectiveBeforeCp: null,
    moverPerspectiveAfterCp: null,
    moverPerspectiveBeforeMate: null,
    moverPerspectiveAfterMate: null,
    cpDeltaComputed: false,
    moverPerspectiveDeltaCp: null,
    deltaDirection: AnalyzerCpDeltaDirection.unavailable,
    cpLossComputed: false,
    winPercentComputed: false,
    classificationComputed: false,
    moveQualityComputed: false,
    failureMessage:
        'Android analyzer CP delta proof is Android-only. Current platform: '
        '${Platform.operatingSystem}; ABI: ${_runtimeAbiLabel()}.',
    safeForPhase35J: false,
    nextRecommendation: analyzerCpDeltaFailureRecommendation,
    blockers: const ['Android CP delta proof was not run.'],
    warnings: const [
      'This is not a successful CP delta proof.',
      'Do not proceed to Phase 35J yet.',
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
