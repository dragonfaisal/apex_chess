import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_pgn_fixture_device_smoke.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_pgn_fixture_profiles.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android PGN fixture selected-deep smoke', (_) async {
    if (!isLocalReviewPgnFixtureDeviceSmokeEnabled()) {
      final skipped = LocalReviewPgnFixtureDeviceSmokeResult.skipped(
        platform: Platform.operatingSystem,
        deviceLabel: Platform.localHostname,
        abi: _runtimeAbiLabel(),
      );
      // ignore: avoid_print
      print(skipped.renderJson());
      // ignore: avoid_print
      print(skipped.renderMarkdownReport());
      markTestSkipped(
        'Set --dart-define=APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE=true '
        'to run the Android PGN fixture selected-deep smoke collector.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      final skipped = LocalReviewPgnFixtureDeviceSmokeResult.skipped(
        platform: Platform.operatingSystem,
        deviceLabel: Platform.localHostname,
        abi: _runtimeAbiLabel(),
        reason: 'PGN fixture selected-deep smoke is Android-only.',
      );
      // ignore: avoid_print
      print(skipped.renderJson());
      // ignore: avoid_print
      print(skipped.renderMarkdownReport());
      markTestSkipped('Run this smoke on an Android device or emulator.');
      return;
    }

    final includePerformance =
        isLocalReviewPgnFixtureDeviceSmokePerformanceEnabled();
    final engine = StockfishEngine(startupTimeout: const Duration(seconds: 12));
    final eval = LocalEvalService(engine: engine);
    final collector = LocalReviewPgnFixtureDeviceSmokeCollector(
      runner: LocalReviewPgnFixtureProfileRunner(
        integration: LocalReviewIntegrationExperiment(
          deepGating: GameLevelDeepGatingExperiment(
            orchestration: LocalReviewOrchestrationExperiment(
              measuredReview: MeasuredLocalReviewPrototype(
                executor: LocalSmartAnalysisExecutor(eval: eval),
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final result = await collector.run(
        LocalReviewPgnFixtureDeviceSmokeRequest(
          requestId: 'android-pgn-fixture-smoke',
          includePerformancePreset: includePerformance,
          maxTotalEngineCalls: includePerformance ? 72 : 32,
          maxTotalElapsedBudgetMs: includePerformance ? 60000 : 30000,
          notes: const ['real Android selected-deep smoke run'],
        ),
        platform: Platform.operatingSystem,
        deviceLabel: Platform.localHostname,
        abi: _runtimeAbiLabel(),
        engineIdentityProvider: () => eval.engineVersion,
      );

      // The JSON and markdown are intentionally log-safe so owners can copy
      // them into engineering notes without raw engine traffic.
      // ignore: avoid_print
      print(result.renderJson());
      // ignore: avoid_print
      print(result.renderMarkdownReport());

      expect(
        result.status,
        isNot(LocalReviewPgnFixtureDeviceSmokeStatus.failed),
      );
      expect(
        result.status,
        isNot(LocalReviewPgnFixtureDeviceSmokeStatus.rejected),
      );
      expect(
        result.status,
        isNot(LocalReviewPgnFixtureDeviceSmokeStatus.partialFailure),
      );
      expect(result.failures, isEmpty, reason: result.renderMarkdownReport());
      expect(result.stubIdentityDetected, isFalse);
      expect(
        result.summaries.where(
          (summary) =>
              summary.presetId ==
              LocalReviewIntegrationBudgetPresetId.balancedDefault,
        ),
        isNotEmpty,
      );
      expect(result.mappedPositions, greaterThan(0));
      expect(
        result.totalEngineCalls,
        lessThanOrEqualTo(includePerformance ? 72 : 32),
      );
      expect(result.selectedDeepRatio, lessThan(1));
    } finally {
      await engine.dispose();
    }
  });
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
