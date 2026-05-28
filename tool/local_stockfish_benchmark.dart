import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/local_engine_audit.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/local_stockfish_benchmark.dart';

Future<void> main(List<String> args) async {
  final auditOnly = args.contains('--audit-only');
  final auditPackaging = args.contains('--audit-packaging');
  final help = args.contains('--help') || args.contains('-h');

  if (help) {
    stdout.writeln('Apex local Stockfish benchmark/audit');
    stdout.writeln('');
    stdout.writeln('Usage:');
    stdout.writeln('  dart run tool/local_stockfish_benchmark.dart');
    stdout.writeln(
      '  dart run tool/local_stockfish_benchmark.dart --audit-only',
    );
    stdout.writeln(
      '  dart run tool/local_stockfish_benchmark.dart --audit-packaging',
    );
    stdout.writeln('');
    stdout.writeln('Notes:');
    stdout.writeln(
      '  --format=markdown is accepted for compatibility; output is markdown.',
    );
    return;
  }

  if (auditOnly || auditPackaging) {
    final audit = await const LocalEngineAuditor().run();
    stdout.write(
      auditPackaging ? audit.androidPackagingAudit.render() : audit.render(),
    );
    return;
  }

  final report = await LocalStockfishBenchmarkRunner().run();
  stdout.write(report.render());
}
