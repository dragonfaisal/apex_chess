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

    expect(display.card.white.name, 'ALFAISALpro');
    expect(display.card.black.name, 'EMANUEL-1972');
    expect(display.card.white.isUser, isTrue);
    expect(display.card.primaryMeta, '85% · Fast · 28 moves');
    expect(display.subtitle, '85% · Fast · 28 moves');
    expect(display.subtitle, isNot(contains('White won')));
    expect(display.subtitle, isNot(contains('You won')));
  });

  test('RecentScanDisplay keeps long names in side rows for mini-card use', () {
    final display = RecentScanDisplay.fromGame(
      ArchivedGame(
        id: 'scan-2',
        source: ArchiveSource.pgn,
        white: 'ALFAISALpro-extra-long-handle',
        black: 'EMANUEL-1972-extra-long-handle',
        result: '1/2-1/2',
        analyzedAt: DateTime(2026, 5, 2),
        depth: 22,
        pgn: '1. e4 *',
        qualityCounts: const {MoveQuality.blunder: 1},
        averageCpLoss: 12,
        totalPlies: 64,
        analysisMode: AnalysisMode.deep,
      ),
      perspective: 'ALFAISALpro-extra-long-handle',
    );

    expect(display.card.white.name, contains('ALFAISALpro'));
    expect(display.card.black.name, contains('EMANUEL-1972'));
    expect(display.card.primaryMeta, '88% · Deep · 32 moves');
  });
}
