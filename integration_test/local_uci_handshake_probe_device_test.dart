import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/infrastructure/engine/local_uci_handshake_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidLocalUciHandshakeProofFlag =
    'APEX_RUN_ANDROID_LOCAL_UCI_HANDSHAKE_PROOF';

bool isAndroidLocalUciHandshakeProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidLocalUciHandshakeProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android local UCI handshake proof', (_) async {
    if (!isAndroidLocalUciHandshakeProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidLocalUciHandshakeProofFlag=true to run '
        'the Android local UCI handshake proof.',
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

    final result = await LocalUciHandshakeProbe().run(
      timeout: const Duration(milliseconds: 5000),
      blockedRecommendation: localUciHandshakeProbeAndroidFailureRecommendation,
    );

    // JSON and markdown are log-safe and omit raw UCI spam so device logs can
    // be copied into Phase 35B.1 review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(
      result.engineLaunchAttempted,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.attemptedHandshake, isTrue, reason: result.renderMarkdown());
    expect(result.uciCommandSent, isTrue, reason: result.renderMarkdown());
    expect(result.isReadyCommandSent, isTrue, reason: result.renderMarkdown());
    expect(result.uciOkReceived, isTrue, reason: result.renderMarkdown());
    expect(result.readyOkReceived, isTrue, reason: result.renderMarkdown());
    expect(result.handshakeSucceeded, isTrue, reason: result.renderMarkdown());
    expect(result.safeForPhase35C, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      localUciHandshakeProbeNextRecommendation,
      reason: result.renderMarkdown(),
    );
  });
}

LocalUciHandshakeProbeResult _androidOnlySkippedResult() {
  return LocalUciHandshakeProbeResult(
    attemptedHandshake: false,
    engineLaunchAttempted: false,
    nativeBridgePathUsed: null,
    processPathUsed: null,
    uciCommandSent: false,
    isReadyCommandSent: false,
    uciOkReceived: false,
    readyOkReceived: false,
    timedOut: false,
    failedToLaunch: false,
    failureMessage:
        'Android local UCI handshake proof is Android-only. Current platform: '
        '${Platform.operatingSystem}; ABI: ${_runtimeAbiLabel()}.',
    rawOutputLineCount: 0,
    sanitizedOutputPreview: const [],
    unsafeOutputSuppressed: false,
    handshakeSucceeded: false,
    safeForPhase35C: false,
    nextRecommendation: localUciHandshakeProbeAndroidFailureRecommendation,
    blockers: const ['Android/device handshake proof was not run.'],
    warnings: const [
      'This is not a successful Android UCI proof.',
      'Do not proceed to Phase 35C yet.',
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
