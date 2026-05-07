import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = '8/8/8/8/8/8/8/8 w - - 0 1';

void main() {
  test('same PGN and profile produce stable archive identity', () {
    final a = archiveIdForAnalysis(
      pgn: _pgn,
      analysisProfileId: AnalysisProfileId.fastReview,
      providerId: 'local_offline',
      engineVersion: 'local-test',
    );
    final b = archiveIdForAnalysis(
      pgn: _pgn.replaceAll('\n', '\r\n'),
      analysisProfileId: AnalysisProfileId.fastReview,
      providerId: 'local_offline',
      engineVersion: 'local-test',
    );

    expect(a, b);
  });

  test(
    'Fast and Deep cache identities are distinct but canonical key is shared',
    () {
      final fastCache = archiveIdForAnalysis(
        pgn: _pgn,
        analysisProfileId: AnalysisProfileId.fastReview,
        providerId: 'local_offline',
        engineVersion: 'local-test',
      );
      final deepCache = archiveIdForAnalysis(
        pgn: _pgn,
        analysisProfileId: AnalysisProfileId.deepReview,
        providerId: 'local_offline',
        engineVersion: 'local-test',
      );
      final fastArchive = ArchivedGame.canonicalKeyFor(
        pgn: _pgn,
        pgnHash: archiveIdForPgn(_pgn),
        white: 'Alpha',
        black: 'Beta',
        result: '1-0',
      );
      final deepArchive = ArchivedGame.canonicalKeyFor(
        pgn: _pgn,
        pgnHash: archiveIdForPgn(_pgn),
        white: 'Alpha',
        black: 'Beta',
        result: '1-0',
      );

      expect(fastCache, isNot(deepCache));
      expect(fastArchive, deepArchive);
    },
  );

  testWidgets('saving same review twice upserts and keeps display fields', (
    tester,
  ) async {
    final saved = <String, ArchivedGame>{};

    final firstId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(),
      pgn: _pgn,
      depth: 14,
      source: ArchiveSource.chessCom,
      playedAt: DateTime(2026, 5, 6),
      analysisMode: AnalysisMode.quick,
      timeControl: '3 min',
    );
    final secondId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(),
      pgn: _pgn,
      depth: 14,
      source: ArchiveSource.chessCom,
      playedAt: DateTime(2026, 5, 6),
      analysisMode: AnalysisMode.quick,
      timeControl: '3 min',
    );

    expect(firstId, secondId);
    expect(saved, hasLength(1));
    final game = saved.values.single;
    expect(game.white, 'Alpha');
    expect(game.black, 'Beta');
    expect(game.source, ArchiveSource.chessCom);
    expect(game.result, '1-0');
    expect(game.reviewModeLabel, 'Fast');
    expect(game.timeControl, '3 min');
    expect(game.cachedTimeline, isNotNull);
    expect(game.qualityCountsLive[MoveQuality.best], 1);
  });

  testWidgets('Fast then Deep same PGN shows one canonical saved review', (
    tester,
  ) async {
    final saved = <String, ArchivedGame>{};

    final fastId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(
        analysisMode: 'quick',
        analysisProfileId: 'fast_review',
      ),
      pgn: _pgn,
      depth: 14,
      source: ArchiveSource.pgn,
      analysisMode: AnalysisMode.quick,
    );
    final deepId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(
        analysisMode: 'deep',
        analysisProfileId: 'deep_review',
      ),
      pgn: _pgn,
      depth: 22,
      source: ArchiveSource.pgn,
      analysisMode: AnalysisMode.deep,
    );

    expect(fastId, deepId);
    expect(ArchivedGame.collapseCanonical(saved.values), hasLength(1));
    expect(
      ArchivedGame.collapseCanonical(saved.values).single.reviewModeLabel,
      'Deep',
    );
    expect(ArchivedGame.collapseCanonical(saved.values).single.depth, 22);
  });
}

Future<String?> _saveWithWidgetRef(
  WidgetTester tester,
  Map<String, ArchivedGame> saved, {
  required AnalysisTimeline timeline,
  required String pgn,
  required int depth,
  required ArchiveSource source,
  DateTime? playedAt,
  AnalysisMode analysisMode = AnalysisMode.deep,
  String? timeControl,
}) async {
  Future<String?>? pending;
  var started = false;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        archiveControllerProvider.overrideWith(
          () => _FakeArchiveController(saved),
        ),
      ],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, _) {
            if (!started) {
              started = true;
              pending = saveAnalysisToArchive(
                ref: ref,
                timeline: timeline,
                pgn: pgn,
                depth: depth,
                source: source,
                playedAt: playedAt,
                analysisMode: analysisMode,
                timeControl: timeControl,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return pending == null ? null : await pending!;
}

const _pgn = '''
[Site "https://www.chess.com/game/live/123"]
[White "Alpha"]
[Black "Beta"]
[Result "1-0"]

1. e4 *
''';

AnalysisTimeline _timeline({
  String analysisMode = 'quick',
  String analysisProfileId = 'fast_review',
}) {
  return AnalysisTimeline(
    startingFen: _fen,
    moves: [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _fen,
        fenAfter: _fen,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 52,
        deltaW: 2,
        isWhiteMove: true,
        classification: MoveQuality.best,
        message: 'Best',
      ),
    ],
    headers: const {
      'White': 'Alpha',
      'Black': 'Beta',
      'Result': '1-0',
      'ECO': 'C20',
      'Opening': 'King Pawn',
    },
    winPercentages: const [52],
    analysisMode: analysisMode,
    analysisProfileId: analysisProfileId,
    providerId: 'local_offline',
    engineVersion: 'local-test',
    pgnHash: archiveIdForPgn(_pgn),
  );
}

class _FakeArchiveController extends ArchiveController {
  _FakeArchiveController(this.saved);

  final Map<String, ArchivedGame> saved;

  @override
  ArchiveState build() => ArchiveState(games: saved.values.toList());

  @override
  Future<void> save(ArchivedGame g) async {
    saved[g.id] = g;
    state = ArchiveState(games: saved.values.toList());
  }
}
