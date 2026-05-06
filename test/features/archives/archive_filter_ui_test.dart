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
      find.byKey(const ValueKey('archive_filter_won_selected')),
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

    await tester.tap(find.byKey(const ValueKey('archive_filter_won_selected')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('archive_sheet_option_won_selected')),
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
        filters: const ArchiveFilters(
          perspective: 'ApexUser',
          color: ArchiveColorFilter.black,
          result: ArchiveResultFilter.losses,
          search: 'zzz',
        ),
        games: [_game()],
      ),
    );

    expect(find.text(ApexCopy.noMatchingGames), findsOneWidget);
    expect(find.text(ApexCopy.clearFilters), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('You: Black'), findsOneWidget);
    expect(find.text('Lost'), findsOneWidget);
    expect(find.text('zzz'), findsWidgets);
  });

  test('Archive quality filter keeps only matching games', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(quality: ArchiveQualityFilter.blunder),
      games: [
        _game(id: 'blunder', qualities: const {MoveQuality.blunder: 1}),
        _game(id: 'clean', qualities: const {MoveQuality.good: 4}),
      ],
    );

    expect(state.visible.map((g) => g.id), ['blunder']);
  });

  test('Archive controller applies side filter correctly', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(
        perspective: 'ApexUser',
        color: ArchiveColorFilter.white,
      ),
      games: [
        _game(id: 'white', white: 'ApexUser', black: 'OpponentA'),
        _game(id: 'black', white: 'OpponentB', black: 'ApexUser'),
      ],
    );

    expect(state.visible.map((g) => g.id), ['white']);
  });

  test('Archive controller applies side and result with AND logic', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(
        perspective: 'ApexUser',
        color: ArchiveColorFilter.white,
        result: ArchiveResultFilter.wins,
      ),
      games: [
        _game(id: 'white-win', white: 'ApexUser', result: '1-0'),
        _game(id: 'white-loss', white: 'ApexUser', result: '0-1'),
        _game(
          id: 'black-win',
          white: 'Opponent',
          black: 'ApexUser',
          result: '0-1',
        ),
      ],
    );

    expect(state.visible.map((g) => g.id), ['white-win']);
  });

  test('Archive controller applies side and quality with AND logic', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(
        perspective: 'ApexUser',
        color: ArchiveColorFilter.black,
        quality: ArchiveQualityFilter.blunder,
      ),
      games: [
        _game(
          id: 'black-blunder',
          white: 'OpponentA',
          black: 'ApexUser',
          qualities: const {MoveQuality.blunder: 1},
        ),
        _game(
          id: 'white-blunder',
          white: 'ApexUser',
          black: 'OpponentB',
          qualities: const {MoveQuality.blunder: 1},
        ),
        _game(
          id: 'black-clean',
          white: 'OpponentC',
          black: 'ApexUser',
          qualities: const {MoveQuality.good: 4},
        ),
      ],
    );

    expect(state.visible.map((g) => g.id), ['black-blunder']);
  });

  testWidgets('Archive active chips render scoped labels', (tester) async {
    await _pumpArchive(
      tester,
      ArchiveState(
        filters: const ArchiveFilters(
          perspective: 'ApexUser',
          color: ArchiveColorFilter.white,
          result: ArchiveResultFilter.wins,
          quality: ArchiveQualityFilter.blunder,
          search: 'C50',
        ),
        games: [
          _game(
            id: 'match',
            white: 'ApexUser',
            result: '1-0',
            qualities: const {MoveQuality.blunder: 1},
            eco: 'C50',
          ),
        ],
      ),
    );

    expect(find.text('You: White'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('archive_filter_won_selected')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('archive_filter_blunder_selected')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('archive_filter_c50_selected')),
      findsOneWidget,
    );
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

ArchivedGame _game({
  String id = 'a1',
  String white = 'ApexUser',
  String black = 'RojoHijo',
  String result = '1-0',
  Map<MoveQuality, int> qualities = const {MoveQuality.blunder: 1},
  String opening = 'Philidor Defense',
  String eco = 'C41',
}) {
  return ArchivedGame(
    id: id,
    source: ArchiveSource.chessCom,
    white: white,
    black: black,
    result: result,
    analyzedAt: DateTime(2026, 4, 21),
    depth: 18,
    pgn: '1. e4 *',
    qualityCounts: qualities,
    averageCpLoss: 18,
    totalPlies: 20,
    openingName: opening,
    ecoCode: eco,
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
