import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/local_stockfish_benchmark.dart';

Future<void> main() async {
  final report = await LocalStockfishBenchmarkRunner().run();
  stdout.write(report.render());
}
