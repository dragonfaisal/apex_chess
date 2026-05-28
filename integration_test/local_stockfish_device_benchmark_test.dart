import 'package:apex_chess/features/pgn_review/infrastructure/android_local_engine_proof.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android local Stockfish proof and benchmark', (_) async {
    if (!isAndroidDeviceBenchmarkEnabled()) {
      markTestSkipped(
        'Set --dart-define=$androidDeviceBenchmarkFlag=true to run the '
        'Android local Stockfish proof collector.',
      );
    }

    final result = await AndroidLocalEngineProofCollector().run();
    // The result is intentionally printed as JSON and markdown so device logs
    // can be copied into the audit doc without inventing benchmark rows.
    // ignore: avoid_print
    print(result.renderJson());
    // ignore: avoid_print
    print(result.renderMarkdown());

    expect(result.deviceRunAttempted, isTrue);
    expect(result.deviceBlockers, isEmpty, reason: result.renderMarkdown());
  });
}
