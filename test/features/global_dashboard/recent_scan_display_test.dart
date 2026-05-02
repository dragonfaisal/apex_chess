import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/global_dashboard/presentation/models/recent_scan_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RecentScanDisplay maps a scan into a readable two-line model', () {
    final display = RecentScanDisplay.fromGame(
      ArchivedGame(
        id: 'scan-1',
        source: ArchiveSource.pgn,
        white: 'ALFAISALpro',
        black: 'EMANUEL-1972',
        result: '1-0',
        analyzedAt: DateTime(2026, 5, 2),
        depth: 14,
        pgn: '1. e4 *',
        qualityCounts: const {MoveQuality.blunder: 1},
        averageCpLoss: 15,
        totalPlies: 56,
        analysisMode: AnalysisMode.quick,
      ),
      perspective: 'ALFAISALpro',
    );

    expect(display.title, 'ALFAISALpro vs EMANUEL-1972');
    expect(display.subtitle, 'You won · 85% · Fast · 28 moves');
    expect(display.subtitle, isNot(contains('White won')));
  });
}
