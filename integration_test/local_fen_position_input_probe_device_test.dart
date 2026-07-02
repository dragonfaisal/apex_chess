import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/infrastructure/engine/local_fen_position_input_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidLocalFenPositionInputProofFlag =
    'APEX_RUN_ANDROID_LOCAL_FEN_POSITION_INPUT_PROOF';

bool isAndroidLocalFenPositionInputProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidLocalFenPositionInputProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android controlled FEN position input proof', (_) async {
    if (!isAndroidLocalFenPositionInputProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidLocalFenPositionInputProofFlag=true to run '
        'the Android controlled FEN position input proof.',
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

    final result = await LocalFenPositionInputProbe().run(
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI spam so device logs can
    // be copied into Phase 35C review notes.
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
    expect(result.uciOkReceived, isTrue, reason: result.renderMarkdown());
    expect(
      result.initialReadyOkReceived,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.fenInputAttempted, isTrue, reason: result.renderMarkdown());
    expect(
      result.fenInputAcceptedByProbe,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.positionCommandSent, isTrue, reason: result.renderMarkdown());
    expect(
      result.postPositionIsReadySent,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(
      result.postPositionReadyOkReceived,
      isTrue,
      reason: result.renderMarkdown(),
    );
    expect(result.timedOut, isFalse, reason: result.renderMarkdown());
    expect(result.failedToLaunch, isFalse, reason: result.renderMarkdown());
    expect(result.safeForPhase35D, isTrue, reason: result.renderMarkdown());
    expect(
      result.nextRecommendation,
      localFenPositionInputProbeNextRecommendation,
      reason: result.renderMarkdown(),
    );
  });
}

LocalFenPositionInputProbeResult _androidOnlySkippedResult() {
  return LocalFenPositionInputProbeResult(
    attemptedProbe: false,
    engineLaunchAttempted: false,
    nativeBridgePathUsed: null,
    processPathUsed: null,
    uciCommandSent: false,
    initialIsReadyCommandSent: false,
    handshakeSucceeded: false,
    uciOkReceived: false,
    initialReadyOkReceived: false,
    newGameCommandSent: false,
    fenInputAttempted: false,
    fenInputAcceptedByProbe: false,
    positionCommandSent: false,
    postPositionIsReadySent: false,
    postPositionReadyOkReceived: false,
    timedOut: false,
    failedToLaunch: false,
    failureMessage:
        'Android controlled FEN position input proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    rawOutputLineCount: 0,
    sanitizedOutputPreview: const [],
    unsafeOutputSuppressed: false,
    safeForPhase35D: false,
    nextRecommendation: localFenPositionInputProbeFailureRecommendation,
    blockers: const ['Android controlled FEN proof was not run.'],
    warnings: const [
      'This is not a successful FEN input proof.',
      'Do not proceed to Phase 35D yet.',
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
