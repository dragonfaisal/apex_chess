import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Archive selected filter gets active state', (tester) async {
    await _pumpArchive(
      tester,
      ArchiveState(
        filters: const ArchiveFilters(result: ArchiveResultFilter.wins),
        games: [_game()],
      ),
    );

    expect(
      find.byKey(const ValueKey('archive_filter_wins_selected')),
      findsOneWidget,
    );
  });

  testWidgets('Archive bottom sheet marks current option selected', (
    tester,
  ) async {
    await _pumpArchive(
      tester,
      ArchiveState(
        filters: const ArchiveFilters(result: ArchiveResultFilter.wins),
        games: [_game()],
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('archive_filter_wins_selected')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('archive_sheet_option_wins_selected')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('Archive no matching filter keeps controls visible', (
    tester,
  ) async {
    await _pumpArchive(
      tester,
      ArchiveState(
        filters: const ArchiveFilters(search: 'zzz'),
        games: [_game()],
      ),
    );

    expect(find.text(ApexCopy.noMatchingGames), findsOneWidget);
    expect(find.text(ApexCopy.clearFilters), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}

Future<void> _pumpArchive(WidgetTester tester, ArchiveState state) async {
  final container = ProviderContainer(
    overrides: [
      archiveControllerProvider.overrideWith(
        () => _FakeArchiveController(state),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ArchiveScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

ArchivedGame _game() {
  return ArchivedGame(
    id: 'a1',
    source: ArchiveSource.chessCom,
    white: 'ApexUser',
    black: 'RojoHijo',
    result: '1-0',
    analyzedAt: DateTime(2026, 4, 21),
    depth: 18,
    pgn: '1. e4 *',
    qualityCounts: const {MoveQuality.blunder: 1},
    averageCpLoss: 18,
    totalPlies: 20,
    openingName: 'Philidor Defense',
    ecoCode: 'C41',
  );
}

class _FakeArchiveController extends ArchiveController {
  _FakeArchiveController(this.initial);

  final ArchiveState initial;

  @override
  ArchiveState build() => initial;

  @override
  void clearFilters() {
    state = state.copyWith(filters: const ArchiveFilters());
  }
}
