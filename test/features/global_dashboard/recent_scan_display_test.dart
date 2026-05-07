import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/global_dashboard/presentation/models/recent_scan_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';
import 'package:flutter/material.dart';
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
    expect(display.card.primaryMeta, '85% · Fast');
    expect(display.card.moveCountLabel, '28 moves');
    expect(display.card.secondaryMeta, contains('PGN'));
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
    expect(display.card.primaryMeta, '88% · Deep');
    expect(display.card.moveCountLabel, '32 moves');
  });

  testWidgets('Recent scan compact card does not render player avatars', (
    tester,
  ) async {
    final display = RecentScanDisplay.fromGame(
      ArchivedGame(
        id: 'scan-3',
        source: ArchiveSource.chessCom,
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

    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: Scaffold(body: ApexGameCard(model: display.card, dense: true)),
      ),
    );

    expect(find.byType(ApexPlayerAvatar), findsNothing);
    expect(
      find.byKey(const ValueKey('apex-white-side-marker')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('apex-black-side-marker')),
      findsOneWidget,
    );
    expect(find.text('YOU'), findsOneWidget);
  });
}
