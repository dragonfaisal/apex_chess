import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';

void main() {
  testWidgets(
    'canonical archive row resolves and reopens exact saved variant',
    (tester) async {
      final loaded = _loadedReview();
      final summary = ArchivedGame(
        id: loaded.id,
        source: loaded.source,
        white: loaded.white,
        black: loaded.black,
        result: loaded.result,
        analyzedAt: loaded.analyzedAt,
        depth: loaded.depth,
        pgn: '',
        qualityCounts: loaded.qualityCounts,
        averageCpLoss: loaded.averageCpLoss,
        cpLossSampleCount: loaded.cpLossSampleCount,
        totalPlies: loaded.totalPlies,
        analysisMode: loaded.analysisMode,
        analysisProfileId: loaded.analysisProfileId,
        providerId: loaded.providerId,
        recordKind: ArchivedRecordKind.canonicalDocument,
        canonicalGameId: loaded.canonicalGameId,
        analysisVariantId: loaded.analysisVariantId,
        analyzedUserIsWhite: false,
        engineIdentity: loaded.engineIdentity,
        canonicalIndexVerified: true,
      );
      final fakeArchive = _FakeArchiveController(summary, loaded);
      final container = ProviderContainer(
        overrides: [
          archiveControllerProvider.overrideWith(() => fakeArchive),
          accountControllerProvider.overrideWith(_NoAccountController.new),
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
      expect(find.textContaining('Stockfish 17'), findsOneWidget);

      await tester.tap(find.text('Alpha'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeArchive.resolveCount, 1);
      final review = container.read(reviewControllerProvider);
      expect(review.timeline?.moves.single.uci, 'e2e4');
      expect(review.userIsWhite, isFalse);
      expect(review.flipped, isTrue);
    },
  );
}

ArchivedGame _loadedReview() {
  const pgn = '''
[White "Alpha"]
[Black "Beta"]
[Result "*"]

1. e4 *
''';
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: pgn,
    sourceProvider: 'pgn',
  );
  final canonicalMove = game.moves.single;
  final timeline = AnalysisTimeline(
    startingFen: game.startingFen,
    moves: [
      MoveAnalysis(
        ply: 0,
        san: canonicalMove.san,
        uci: canonicalMove.uci,
        fenBefore: canonicalMove.fenBefore,
        fenAfter: canonicalMove.fenAfter,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 51,
        deltaW: 1,
        isWhiteMove: true,
        classification: MoveQuality.best,
        moverCpLoss: 0,
        message: 'Best',
      ),
    ],
    headers: game.headers,
    winPercentages: const [51],
    analysisMode: 'quick',
    analysisProfileId: 'fast_review',
    providerId: 'local_offline',
    engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
    requestedDepth: 14,
    depth: 14,
    movetimeMs: 900,
    multipv: 1,
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
  );
  return ArchivedGame(
    id: 'review-exact',
    source: ArchiveSource.pgn,
    white: 'Alpha',
    black: 'Beta',
    result: '*',
    analyzedAt: DateTime.utc(2026, 7, 11),
    depth: 14,
    pgn: pgn,
    qualityCounts: timeline.qualityCounts,
    averageCpLoss: timeline.averageCpLoss,
    cpLossSampleCount: timeline.cpLossEligibleCount,
    totalPlies: 1,
    cachedTimeline: timeline,
    analysisMode: AnalysisMode.quick,
    analysisProfileId: 'fast_review',
    providerId: 'local_offline',
    recordKind: ArchivedRecordKind.canonicalDocument,
    canonicalGameId: game.gameId.value,
    analysisVariantId: 'variant-exact',
    analyzedUserIsWhite: false,
    engineIdentity: timeline.engineVersion,
    canonicalIndexVerified: true,
  );
}

class _FakeArchiveController extends ArchiveController {
  _FakeArchiveController(this.summary, this.loaded);

  final ArchivedGame summary;
  final ArchivedGame loaded;
  int resolveCount = 0;

  @override
  ArchiveState build() => ArchiveState(games: [summary]);

  @override
  Future<ArchivedGame?> resolveExact(String id) async {
    resolveCount++;
    return id == loaded.id ? loaded : null;
  }
}

class _NoAccountController extends AccountController {
  @override
  Future<ApexAccount?> build() async => null;
}
