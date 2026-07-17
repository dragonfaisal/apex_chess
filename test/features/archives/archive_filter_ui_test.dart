import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _afterNf3 = 'rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1';

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

  test('Archive source filter Chess.com shows only Chess.com games', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(source: ArchiveSource.chessCom),
      games: [
        _game(id: 'chess', source: ArchiveSource.chessCom),
        _game(id: 'lichess', source: ArchiveSource.lichess),
        _game(id: 'pgn', source: ArchiveSource.pgn),
      ],
    );

    expect(state.visible.map((g) => g.id), ['chess']);
  });

  test('Archive source filter Lichess shows only Lichess games', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(source: ArchiveSource.lichess),
      games: [
        _game(id: 'chess', source: ArchiveSource.chessCom),
        _game(id: 'lichess', source: ArchiveSource.lichess),
        _game(id: 'pgn', source: ArchiveSource.pgn),
      ],
    );

    expect(state.visible.map((g) => g.id), ['lichess']);
  });

  test('Archive source filter PGN shows only PGN games', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(source: ArchiveSource.pgn),
      games: [
        _game(id: 'chess', source: ArchiveSource.chessCom),
        _game(id: 'lichess', source: ArchiveSource.lichess),
        _game(id: 'pgn', source: ArchiveSource.pgn),
      ],
    );

    expect(state.visible.map((g) => g.id), ['pgn']);
  });

  test('Archive source filter combines with side result and quality', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(
        source: ArchiveSource.lichess,
        perspective: 'ApexUser',
        color: ArchiveColorFilter.white,
        result: ArchiveResultFilter.wins,
        quality: ArchiveQualityFilter.blunder,
      ),
      games: [
        _game(
          id: 'match',
          source: ArchiveSource.lichess,
          white: 'ApexUser',
          result: '1-0',
          qualities: const {MoveQuality.blunder: 1},
        ),
        _game(
          id: 'wrong-source',
          source: ArchiveSource.chessCom,
          white: 'ApexUser',
          result: '1-0',
          qualities: const {MoveQuality.blunder: 1},
        ),
        _game(
          id: 'wrong-side',
          source: ArchiveSource.lichess,
          white: 'Opponent',
          black: 'ApexUser',
          result: '0-1',
          qualities: const {MoveQuality.blunder: 1},
        ),
      ],
    );

    expect(state.visible.map((g) => g.id), ['match']);
  });

  test('Archive visible records collapse duplicate Fast and Deep reviews', () {
    const pgn = '''
[Event "Duplicate"]
[White "ApexUser"]
[Black "RojoHijo"]
[Result "1-0"]

1. e4 e5 *
''';
    final state = ArchiveState(
      games: ArchivedGame.collapseCanonical([
        _game(
          id: 'fast',
          pgn: pgn,
          analysisMode: AnalysisMode.quick,
          analysisProfileId: 'fast_review',
          depth: 14,
          analysisMovetimeMs: 900,
          analysisMultiPv: 1,
        ),
        _game(
          id: 'deep',
          pgn: pgn,
          analysisMode: AnalysisMode.deep,
          analysisProfileId: 'deep_review',
          depth: 22,
          analysisMovetimeMs: 6000,
          analysisMultiPv: 3,
          candidateVerificationEnabled: true,
        ),
      ]),
    );

    expect(state.visible, hasLength(1));
    expect(state.visible.single.id, 'deep');
    expect(state.visible.single.reviewModeLabel, 'Deep');
  });

  test('Archive keeps canonical Fast and Deep variants distinguishable', () {
    final state = ArchiveState(
      games: ArchivedGame.preserveAnalysisVariants([
        _game(
          id: 'review-fast',
          analysisMode: AnalysisMode.quick,
          analysisProfileId: 'fast_review',
          recordKind: ArchivedRecordKind.canonicalDocument,
          canonicalGameId: 'game-sha256',
          analysisVariantId: 'variant-fast',
          engineIdentity: 'bridge|Stockfish 17',
          depth: 22,
          analysisMovetimeMs: 6000,
          analysisMultiPv: 3,
          candidateVerificationEnabled: true,
        ),
        _game(
          id: 'review-deep',
          analysisMode: AnalysisMode.deep,
          analysisProfileId: 'deep_review',
          recordKind: ArchivedRecordKind.canonicalDocument,
          canonicalGameId: 'game-sha256',
          analysisVariantId: 'variant-deep',
          engineIdentity: 'bridge|Stockfish 17',
          depth: 14,
          analysisMovetimeMs: 900,
          analysisMultiPv: 1,
        ),
      ]),
    );

    expect(state.visible, hasLength(2));
    expect(state.visible.map((game) => game.reviewModeLabel).toSet(), {
      'Fast',
      'Deep',
    });
    expect(ArchivedGame.collapseCanonical(state.games), hasLength(1));
    expect(
      ArchivedGame.collapseCanonical(state.games).single.reviewModeLabel,
      'Fast',
    );
  });

  test('Archive filters still apply after duplicate collapse', () {
    const pgn = '''
[Event "Duplicate"]
[White "ApexUser"]
[Black "RojoHijo"]
[Result "1-0"]

1. e4 e5 *
''';
    final state = ArchiveState(
      filters: const ArchiveFilters(
        source: ArchiveSource.chessCom,
        perspective: 'ApexUser',
        color: ArchiveColorFilter.white,
        result: ArchiveResultFilter.wins,
      ),
      games: ArchivedGame.collapseCanonical([
        _game(
          id: 'fast',
          pgn: pgn,
          source: ArchiveSource.chessCom,
          analysisMode: AnalysisMode.quick,
          analysisProfileId: 'fast_review',
          depth: 14,
          analysisMovetimeMs: 900,
          analysisMultiPv: 1,
        ),
        _game(
          id: 'deep',
          pgn: pgn,
          source: ArchiveSource.chessCom,
          analysisMode: AnalysisMode.deep,
          analysisProfileId: 'deep_review',
          depth: 22,
          analysisMovetimeMs: 6000,
          analysisMultiPv: 3,
          candidateVerificationEnabled: true,
        ),
        _game(id: 'wrong-source', source: ArchiveSource.lichess),
      ]),
    );

    expect(state.visible.map((g) => g.id), ['deep']);
  });

  test('Lowest ACPL sort ranks only current verified metrics', () {
    final state = ArchiveState(
      filters: const ArchiveFilters(sort: ArchiveSort.highestAccuracy),
      games: [
        _game(id: 'unavailable', averageCpLoss: 0),
        _game(id: 'higher-acpl', metricAvailable: true, averageCpLoss: 42),
        _game(id: 'lower-acpl', metricAvailable: true, averageCpLoss: 18),
      ],
    );

    expect(state.visible.map((game) => game.id), [
      'lower-acpl',
      'higher-acpl',
      'unavailable',
    ]);
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

  testWidgets('Archive active source chip renders source label', (
    tester,
  ) async {
    await _pumpArchive(
      tester,
      ArchiveState(
        filters: const ArchiveFilters(source: ArchiveSource.pgn),
        games: [_game(source: ArchiveSource.pgn)],
      ),
    );

    expect(find.text('PGN'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('archive_filter_pgn_selected')),
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
  ArchiveSource source = ArchiveSource.chessCom,
  String? pgn,
  AnalysisMode analysisMode = AnalysisMode.deep,
  String? analysisProfileId,
  bool metricAvailable = false,
  double averageCpLoss = 18,
  int depth = 18,
  int? analysisMovetimeMs,
  int? analysisMultiPv,
  bool candidateVerificationEnabled = false,
  ArchivedRecordKind recordKind = ArchivedRecordKind.legacy,
  String? canonicalGameId,
  String? analysisVariantId,
  String? engineIdentity,
}) {
  final moves = <MoveAnalysis>[];
  var ply = 0;
  for (final entry in qualities.entries) {
    for (var count = 0; count < entry.value; count++) {
      final currentPly = ply++;
      moves.add(
        MoveAnalysis(
          ply: currentPly,
          san: 'Nf3',
          uci: 'g1f3',
          fenBefore: _fen,
          fenAfter: _afterNf3,
          winPercentBefore: 50,
          winPercentAfter: 50,
          deltaW: 0,
          isWhiteMove: currentPly.isEven,
          classification: entry.key,
          moverCpLoss: metricAvailable ? averageCpLoss.round() : null,
          engineEvaluationAvailable: metricAvailable,
          openingEvidence: OpeningEvidence(
            artifact: _openingArtifact,
            artifactVerification: OpeningArtifactVerification.verified,
            state: OpeningMatchState.noMatch,
            beforePositionKey: OpeningPositionKey.fromFen(_fen).value,
            afterPositionKey: OpeningPositionKey.fromFen(_afterNf3).value,
            playedUci: 'g1f3',
            transitionVerified: false,
            totalCandidateCount: 0,
            matchedPly: currentPly + 1,
            reasonCode: 'no_match',
          ),
          message: '',
        ),
      );
    }
  }
  final timeline = AnalysisTimeline(
    moves: moves,
    startingFen: 'fixture',
    headers: {'White': white, 'Black': black, 'Result': result},
    winPercentages: [for (final move in moves) move.winPercentAfter],
    analysisMode: analysisMode.wire,
    analysisProfileId: analysisProfileId,
    openingBookVersion: kApexOpeningBookVersion,
    openingArtifact: _openingArtifact,
    openingArtifactVerification: OpeningArtifactVerification.verified,
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: moves.length,
  );
  return ArchivedGame(
    id: id,
    source: source,
    white: white,
    black: black,
    result: result,
    analyzedAt: DateTime(2026, 4, 21),
    depth: depth,
    pgn:
        pgn ??
        '''
[Event "$id"]
[White "$white"]
[Black "$black"]
[Result "$result"]

1. e4 *
''',
    qualityCounts: qualities,
    averageCpLoss: averageCpLoss,
    totalPlies: 20,
    openingName: opening,
    ecoCode: eco,
    analysisMode: analysisMode,
    analysisProfileId: analysisProfileId,
    openingBookVersion: kApexOpeningBookVersion,
    cachedTimeline: moves.isEmpty ? null : timeline,
    recordKind: recordKind,
    canonicalGameId: canonicalGameId,
    analysisVariantId: analysisVariantId,
    engineIdentity: engineIdentity,
    canonicalIndexVerified: recordKind == ArchivedRecordKind.canonicalDocument,
    analysisMovetimeMs: analysisMovetimeMs,
    analysisMultiPv: analysisMultiPv,
    candidateVerificationEnabled: candidateVerificationEnabled,
  );
}

const _openingArtifact = OpeningArtifactIdentity(
  datasetName: 'apex-eco',
  sourceRevision: '2026-07-17',
  sourceSha256:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  contentSha256:
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  licenseSpdx: 'MIT',
  provenanceReference: 'assets/openings/PROVENANCE.md',
);

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
