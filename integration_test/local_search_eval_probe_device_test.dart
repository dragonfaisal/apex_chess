import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidLocalSearchEvalProofFlag =
    'APEX_RUN_ANDROID_LOCAL_SEARCH_EVAL_PROOF';

bool isAndroidLocalSearchEvalProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidLocalSearchEvalProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android local search eval proof', (_) async {
    if (!isAndroidLocalSearchEvalProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidLocalSearchEvalProofFlag=true to run '
        'the Android local search eval proof.',
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

    final result = await LocalSearchEvalProbe().run(
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI spam so device logs can
    // be copied into Phase 35D review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.attemptedProbe, isTrue, reason: result.renderMarkdown());
    expect(
      result.engineLaunchAttempted,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.handshakeSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.fenInputSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.searchCommandSent, isTrue, reason: result.renderMarkdown());
    expect(result.searchCommand, localSearchEvalProbeSearchCommand);
    expect(result.depthLimit, localSearchEvalProbeDepthLimit);
    expect(result.bestMoveReceived, isTrue, reason: result.renderMarkdown());
    expect(result.bestMove, isNotNull, reason: result.renderMarkdown());
    expect(result.bestMove, isNot('(none)'), reason: result.renderMarkdown());
    expect(result.timedOut, isFalse, reason: result.renderMarkdown());
    expect(result.failedToLaunch, isFalse, reason: result.renderMarkdown());
    expect(result.safeForPhase35E, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      localSearchEvalProbeNextRecommendation,
      reason: result.renderMarkdown(),
    );
  });
}

LocalSearchEvalProbeResult _androidOnlySkippedResult() {
  return LocalSearchEvalProbeResult(
    attemptedProbe: false,
    engineLaunchAttempted: false,
    nativeBridgePathUsed: null,
    processPathUsed: null,
    handshakeSucceeded: false,
    uciOkReceived: false,
    initialReadyOkReceived: false,
    fenInputSucceeded: false,
    fenInputAttempted: false,
    fenInputAcceptedByProbe: false,
    positionCommandSent: false,
    postPositionReadyOkReceived: false,
    searchCommandSent: false,
    searchCommand: localSearchEvalProbeSearchCommand,
    depthLimit: localSearchEvalProbeDepthLimit,
    bestMoveReceived: false,
    bestMove: null,
    rawScoreSeen: false,
    scoreType: null,
    scoreValue: null,
    mateValue: null,
    infoDepthSeen: null,
    timedOut: false,
    failedToLaunch: false,
    failureMessage:
        'Android local search eval proof is Android-only. Current platform: '
        '${Platform.operatingSystem}; ABI: ${_runtimeAbiLabel()}.',
    rawOutputLineCount: 0,
    sanitizedOutputPreview: const [],
    unsafeOutputSuppressed: false,
    safeForPhase35E: false,
    nextRecommendation: localSearchEvalProbeFailureRecommendation,
    blockers: const ['Android local search eval proof was not run.'],
    warnings: const [
      'This is not a successful local search/eval proof.',
      'Do not proceed to Phase 35E yet.',
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
