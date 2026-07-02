import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval_bridge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidLocalRawEngineEvalBridgeProofFlag =
    'APEX_RUN_ANDROID_LOCAL_RAW_ENGINE_EVAL_BRIDGE_PROOF';

bool isAndroidLocalRawEngineEvalBridgeProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidLocalRawEngineEvalBridgeProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android local raw engine eval bridge proof', (_) async {
    if (!isAndroidLocalRawEngineEvalBridgeProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidLocalRawEngineEvalBridgeProofFlag=true '
        'to run the Android local raw engine eval bridge proof.',
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

    final result = await LocalRawEngineEvalBridge().evaluate();

    // JSON and markdown are log-safe and omit raw UCI spam so device logs can
    // be copied into Phase 35E review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.requestedFen, localRawEngineEvalBridgeControlledFen);
    expect(result.requestedDepth, localRawEngineEvalBridgeDepth);
    expect(result.handshakeSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.fenInputSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.searchSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.bestMoveReceived, isTrue, reason: result.renderMarkdown());
    expect(result.bestMove, isNotNull, reason: result.renderMarkdown());
    expect(result.bestMove, isNot('(none)'), reason: result.renderMarkdown());
    expect(result.safeForPhase35F, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      localRawEngineEvalNextRecommendation,
      reason: result.renderMarkdown(),
    );

    final json = result.toJson();
    for (final forbiddenField in _forbiddenProductOrClassifierFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'Raw eval bridge must not expose product/classifier field '
            '$forbiddenField.',
      );
    }
  });
}

const _forbiddenProductOrClassifierFields = <String>[
  'moveQuality',
  'winPercent',
  'whiteWinPercent',
  'cpLoss',
  'accuracy',
  'acpl',
  'label',
  'classification',
  'brilliant',
  'great',
  'mistake',
  'blunder',
  'perspectiveNormalizedScore',
];

LocalRawEngineEval _androidOnlySkippedResult() {
  return LocalRawEngineEval(
    requestedFen: localRawEngineEvalBridgeControlledFen,
    requestedDepth: localRawEngineEvalBridgeDepth,
    engineSource: localRawEngineEvalEngineSource,
    bridgeSource: localRawEngineEvalBridgeSource,
    handshakeSucceeded: false,
    fenInputSucceeded: false,
    searchSucceeded: false,
    bestMove: null,
    bestMoveReceived: false,
    infoDepthSeen: null,
    rawScoreSeen: false,
    scoreType: null,
    scoreCp: null,
    scoreMate: null,
    rawScoreValue: null,
    timedOut: false,
    failedToLaunch: false,
    failureMessage:
        'Android raw engine eval bridge proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    sanitizedOutputPreview: const [],
    rawOutputLineCount: 0,
    safeForAnalyzerAdapterPhase: false,
    nextRecommendation: localRawEngineEvalFailureRecommendation,
    blockers: const ['Android raw engine eval bridge proof was not run.'],
    warnings: const [
      'This is not a successful raw eval bridge proof.',
      'Do not proceed to Phase 35F yet.',
      'Run the proof on an Android device or emulator.',
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
