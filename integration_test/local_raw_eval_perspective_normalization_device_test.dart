import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval_bridge.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const androidLocalRawEvalPerspectiveProofFlag =
    'APEX_RUN_ANDROID_LOCAL_RAW_EVAL_PERSPECTIVE_PROOF';

bool isAndroidLocalRawEvalPerspectiveProofEnabled({
  String flagValue = const String.fromEnvironment(
    androidLocalRawEvalPerspectiveProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android raw eval perspective normalization proof', (
    _,
  ) async {
    if (!isAndroidLocalRawEvalPerspectiveProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidLocalRawEvalPerspectiveProofFlag=true '
        'to run the Android raw eval perspective normalization proof.',
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

    final result = await LocalRawEvalPerspectiveNormalizationProbe().run(
      timeout: const Duration(milliseconds: 5000),
    );

    // JSON and markdown are log-safe and omit raw UCI spam so device logs can
    // be copied into Phase 35F review notes.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.requestedFen, localRawEngineEvalBridgeControlledFen);
    expect(result.requestedDepth, localRawEngineEvalBridgeDepth);
    expect(result.sideToMove, LocalRawEvalSideToMove.white);
    expect(result.rawScoreType, 'cp');
    expect(result.rawScoreCp, isNotNull);
    expect(result.rawScoreMate, isNull);
    expect(result.rawScorePerspective, localRawEvalPerspectiveScorePerspective);
    expect(result.whitePerspectiveCp, result.rawScoreCp);
    expect(result.blackPerspectiveCp, -result.rawScoreCp!);
    expect(result.playerPerspectiveCpWhite, result.whitePerspectiveCp);
    expect(result.playerPerspectiveCpBlack, result.blackPerspectiveCp);
    expect(result.normalizationSucceeded, isTrue);
    expect(result.safeForPhase35G, isTrue);
    expect(
      result.nextRecommendation,
      localRawEvalPerspectiveNextRecommendation,
    );

    final json = result.toJson();
    for (final forbiddenField in _forbiddenProductOrClassifierFields) {
      expect(
        json.containsKey(forbiddenField),
        isFalse,
        reason:
            'Perspective normalization must not expose product/classifier '
            'field $forbiddenField.',
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
  'book',
];

LocalRawEvalPerspective _androidOnlySkippedResult() {
  return LocalRawEvalPerspective(
    requestedFen: localRawEngineEvalBridgeControlledFen,
    requestedDepth: localRawEngineEvalBridgeDepth,
    sideToMove: null,
    rawScoreType: null,
    rawScoreCp: null,
    rawScoreMate: null,
    rawScorePerspective: localRawEvalPerspectiveScorePerspective,
    whitePerspectiveCp: null,
    blackPerspectiveCp: null,
    whitePerspectiveMate: null,
    blackPerspectiveMate: null,
    playerPerspectiveCpWhite: null,
    playerPerspectiveCpBlack: null,
    playerPerspectiveMateWhite: null,
    playerPerspectiveMateBlack: null,
    normalizationSucceeded: false,
    failureMessage:
        'Android raw eval perspective normalization proof is Android-only. '
        'Current platform: ${Platform.operatingSystem}; ABI: '
        '${_runtimeAbiLabel()}.',
    safeForPhase35G: false,
    nextRecommendation: localRawEvalPerspectiveFailureRecommendation,
    blockers: const ['Android raw eval perspective proof was not run.'],
    warnings: const [
      'This is not a successful raw eval perspective normalization proof.',
      'Do not proceed to Phase 35G yet.',
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
