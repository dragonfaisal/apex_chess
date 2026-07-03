import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_single_fen_raw_eval_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidAnalyzerSingleFenRawEvalProofFlag =
    'APEX_RUN_ANDROID_ANALYZER_SINGLE_FEN_RAW_EVAL_PROOF';

bool isAndroidAnalyzerSingleFenRawEvalProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidAnalyzerSingleFenRawEvalProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analyzer single-FEN raw eval proof', (_) async {
    if (!isAndroidAnalyzerSingleFenRawEvalProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidAnalyzerSingleFenRawEvalProofFlag=true '
        'to run the Android analyzer single-FEN raw eval proof.',
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

    final result = await LocalAnalyzerSingleFenRawEvalAdapter().evaluate(
      const AnalyzerSingleFenRawEvalRequest.controlled(),
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI output so device logs can
    // be copied into Phase 35G review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.fen, analyzerSingleFenRawEvalControlledFen);
    expect(result.requestedDepth, analyzerSingleFenRawEvalDepth);
    expect(result.requestedPlayerColor, AnalyzerRequestedPlayerColor.white);
    expect(result.engineSucceeded, isTrue, reason: result.renderMarkdown());
    expect(
      result.perspectiveNormalizationSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.analyzerRawEvalSucceeded,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.bestMoveReceived, isTrue, reason: result.renderMarkdown());
    expect(result.playerPerspectiveCp, result.whitePerspectiveCp);
    expect(result.safeForPhase35H, isTrue, reason: result.renderMarkdown());
    expect(result.nextRecommendation, analyzerRawEvalNextRecommendation);

    final json = result.toJson();
    for (final forbiddenField in _forbiddenFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'Analyzer raw eval result must not expose forbidden field '
            '$forbiddenField.',
      );
    }
  });
}

const _forbiddenFields = <String>[
  'label',
  'classification',
  'moveQuality',
  'winPercent',
  'whiteWinPercent',
  'cpLoss',
  'accuracy',
  'acpl',
  'book',
  'openingPhase',
  'explanation',
];

AnalyzerRawEvalResult _androidOnlySkippedResult() {
  return AnalyzerRawEvalResult(
    fen: analyzerSingleFenRawEvalControlledFen,
    requestedDepth: analyzerSingleFenRawEvalDepth,
    requestedPlayerColor: AnalyzerRequestedPlayerColor.white,
    engineSource: 'localStockfishUci',
    bridgeSource: 'localSearchEvalProbe',
    rawScoreType: null,
    rawScoreCp: null,
    rawScoreMate: null,
    rawScorePerspective: 'sideToMove',
    sideToMove: null,
    whitePerspectiveCp: null,
    blackPerspectiveCp: null,
    whitePerspectiveMate: null,
    blackPerspectiveMate: null,
    playerPerspectiveCp: null,
    playerPerspectiveMate: null,
    bestMove: null,
    bestMoveReceived: false,
    infoDepthSeen: null,
    engineSucceeded: false,
    perspectiveNormalizationSucceeded: false,
    analyzerRawEvalSucceeded: false,
    failureMessage:
        'Android analyzer single-FEN raw eval proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35H: false,
    nextRecommendation: analyzerRawEvalFailureRecommendation,
    blockers: ['Android analyzer single-FEN raw eval proof was not run.'],
    warnings: [
      'This is not a successful analyzer raw eval proof.',
      'Do not proceed to Phase 35H yet.',
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
