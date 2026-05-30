import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/golden_owner_android_proof_queue.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android golden owner proof queue', (_) async {
    if (!isGoldenOwnerAndroidProofQueueEnabled()) {
      final skipped = GoldenOwnerAndroidProofQueueResult.skipped(
        platform: Platform.operatingSystem,
        deviceLabel: Platform.localHostname,
        abi: _runtimeAbiLabel(),
      );
      // ignore: avoid_print
      print(skipped.renderJson());
      // ignore: avoid_print
      print(skipped.renderMarkdownReport());
      markTestSkipped(
        'Set --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE=true '
        'to run the Android golden owner proof queue collector.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      final skipped = GoldenOwnerAndroidProofQueueResult.skipped(
        platform: Platform.operatingSystem,
        deviceLabel: Platform.localHostname,
        abi: _runtimeAbiLabel(),
        reason: 'Golden owner proof queue is Android-only.',
      );
      // ignore: avoid_print
      print(skipped.renderJson());
      // ignore: avoid_print
      print(skipped.renderMarkdownReport());
      markTestSkipped('Run this proof queue on an Android device or emulator.');
      return;
    }

    final includePerformance =
        isGoldenOwnerAndroidProofQueuePerformanceEnabled();
    final engine = StockfishEngine(startupTimeout: const Duration(seconds: 12));
    final eval = LocalEvalService(engine: engine);
    final collector = GoldenOwnerAndroidProofQueueCollector(
      integration: LocalReviewIntegrationExperiment(
        deepGating: GameLevelDeepGatingExperiment(
          orchestration: LocalReviewOrchestrationExperiment(
            measuredReview: MeasuredLocalReviewPrototype(
              executor: LocalSmartAnalysisExecutor(eval: eval),
            ),
          ),
        ),
      ),
    );

    try {
      final maxCalls = includePerformance ? 64 : 24;
      final result = await collector.run(
        GoldenOwnerAndroidProofQueueRequest(
          requestId: 'android-golden-owner-proof-queue',
          includePerformance: includePerformance,
          maxTotalEngineCalls: maxCalls,
          maxTotalElapsedBudgetMs: includePerformance ? 60000 : 30000,
          notes: const ['real Android golden owner proof queue run'],
        ),
        platform: Platform.operatingSystem,
        deviceLabel: Platform.localHostname,
        abi: _runtimeAbiLabel(),
        engineIdentityProvider: () => eval.engineVersion,
      );

      // The emitted artifacts are intentionally log-safe for owner-run notes.
      // ignore: avoid_print
      print(result.renderJson());
      // ignore: avoid_print
      print(result.renderMarkdownReport());

      expect(result.status, isNot(GoldenOwnerAndroidProofQueueStatus.failed));
      expect(result.status, isNot(GoldenOwnerAndroidProofQueueStatus.rejected));
      expect(
        result.status,
        isNot(GoldenOwnerAndroidProofQueueStatus.partialFailure),
      );
      expect(result.failures, isEmpty, reason: result.renderMarkdownReport());
      expect(result.stubIdentityDetected, isFalse);
      expect(result.targetCaseCount, greaterThan(0));
      expect(result.executedTargetCount, greaterThan(0));
      expect(result.totalEngineCalls, lessThanOrEqualTo(maxCalls));
      expect(result.selectedDeepCount, greaterThanOrEqualTo(0));
      expect(result.executedDeepCount, greaterThanOrEqualTo(0));
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
