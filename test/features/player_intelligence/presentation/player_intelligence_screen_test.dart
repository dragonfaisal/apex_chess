import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_builder.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';
import 'package:apex_chess/features/player_intelligence/presentation/controllers/player_intelligence_controller.dart';
import 'package:apex_chess/features/player_intelligence/presentation/views/player_intelligence_screen.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

import '../../../support/player_intelligence_test_fixtures.dart';

void main() {
  testWidgets(
    'renders summary, denominators, trend, priorities, and exact links',
    (tester) async {
      final snapshot = _prioritySnapshot();
      await tester.pumpWidget(_host(snapshot));
      await tester.pumpAndSettle();

      expect(find.text('Player Intelligence'), findsOneWidget);
      expect(
        find.byKey(const Key('player-intelligence-summary')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('classification-distribution')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('player-intelligence-trend')),
        260,
      );
      expect(
        find.byKey(const Key('player-intelligence-trend')),
        findsOneWidget,
      );
      expect(find.textContaining('Accuracy'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('coaching-priority-material-losses')),
        260,
      );
      expect(
        find.byKey(const Key('coaching-priority-material-losses')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('priority-example-material-losses-0')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('320px and text scale 1.8 remain scrollable without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(_longPrioritySnapshot(), textScale: 1.8));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('Opening transitions'), 300);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Opening transitions'), findsOneWidget);
  });

  testWidgets('RTL, long opening copy, and 100-game dataset are safe', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Avoid constructing data in build callbacks: prepare the 110-game
    // snapshot once before pumping the widget.
    final large = _largeSnapshot();

    await tester.pumpWidget(
      _host(large, textScale: 1.3, direction: TextDirection.rtl),
    );
    await tester.pumpAndSettle();
    expect(find.text('110 canonical games'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty, partial, and unavailable states are distinct', (
    tester,
  ) async {
    final empty = const PlayerAnalyticsBuilder().build(
      const PlayerAnalyticsBuildInput(
        documents: [],
        playerIdentityScope: 'local',
      ),
    );
    await tester.pumpWidget(_host(empty));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-intelligence-empty')), findsOneWidget);
    expect(find.textContaining('No eligible saved reviews'), findsOneWidget);

    final partial = const PlayerAnalyticsBuilder().build(
      PlayerAnalyticsBuildInput(
        documents: [analyticsDocument(gameSeed: 900)],
        playerIdentityScope: 'local',
        sourceExclusions: const [
          PlayerAnalyticsExclusion(
            reason: PlayerAnalyticsExclusionReason.corruptOrUnavailable,
            detail: 'Corrupt source.',
            documentId: 'corrupt',
          ),
        ],
      ),
    );
    await tester.pumpWidget(_host(partial));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('player-intelligence-partial')),
      120,
    );
    expect(
      find.byKey(const Key('player-intelligence-partial')),
      findsOneWidget,
    );

    await tester.pumpWidget(_errorHost());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('player-intelligence-error')), findsOneWidget);
    expect(find.textContaining('No estimate was substituted'), findsOneWidget);
  });

  testWidgets('classification bars expose equivalent textual semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(_prioritySnapshot()));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp(r'Blunder: \d+ of \d+ eligible moves')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets(
    'priority example opens exact document and ply without analysis',
    (tester) async {
      final documents = [
        for (var index = 0; index < 2; index++)
          analyticsDocument(
            gameSeed: 950 + index,
            playerQualities: const [MoveQuality.blunder],
            playerInsights: const {
              0: AnalyticsInsightSpec(
                claim: MoveInsightClaimType.dropsMaterial,
                consequence: MoveInsightConsequenceType.materialLoss,
                materialDelta: -3,
              ),
            },
          ),
      ];
      final snapshot = const PlayerAnalyticsBuilder().build(
        PlayerAnalyticsBuildInput(
          documents: documents,
          playerIdentityScope: 'local',
        ),
      );
      final archived = {
        for (final document in documents)
          document.documentId: _archivedDocument(document),
      };
      final container = ProviderContainer(
        overrides: [
          playerIntelligenceControllerProvider.overrideWith(
            () => _SnapshotController(snapshot),
          ),
          archiveControllerProvider.overrideWith(
            () => _ExactArchiveController(archived),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ApexTheme.dark,
            home: const PlayerIntelligenceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final example = snapshot.priorities
          .singleWhere((item) => item.priorityId == 'material-losses')
          .examples
          .first;
      final source = documents.singleWhere(
        (document) => document.documentId == example.documentId,
      );
      final sourceMove = source.timeline.moves[example.ply];
      expect(example.classification, sourceMove.classification);
      expect(example.claimType, sourceMove.insight?.primaryClaim?.type);
      expect(example.mechanism, sourceMove.insight?.primaryClaim?.mechanism);
      expect(example.persistedSentence, sourceMove.insight?.conciseText);
      final link = find.byKey(const Key('priority-example-material-losses-0'));
      await tester.scrollUntilVisible(link, 300);
      await tester.tap(link);
      await tester.pumpAndSettle();

      final review = container.read(reviewControllerProvider);
      expect(review.lifecycle, ReviewRuntimeLifecycle.completed);
      expect(review.source, ReviewRuntimeSource.archiveExact);
      expect(review.gameId, example.gameId);
      expect(review.analysisVariantId, example.variantId);
      expect(review.reviewDocumentId, example.documentId);
      expect(review.currentPly, example.ply);
      expect(review.saveState, ReviewSaveState.saved);

      Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
      await tester.pumpAndSettle();
      expect(find.text('Player Intelligence'), findsOneWidget);

      final secondExample = snapshot.priorities
          .singleWhere((item) => item.priorityId == 'material-losses')
          .examples[1];
      final secondLink = find.byKey(
        const Key('priority-example-material-losses-1'),
      );
      await tester.scrollUntilVisible(secondLink, 300);
      await tester.tap(secondLink);
      await tester.pumpAndSettle();
      final replacement = container.read(reviewControllerProvider);
      expect(replacement.reviewDocumentId, secondExample.documentId);
      expect(replacement.analysisVariantId, secondExample.variantId);
      expect(replacement.currentPly, secondExample.ply);
      expect(replacement.reviewDocumentId, isNot(example.documentId));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mismatched persisted evidence is rejected before Review opens', (
    tester,
  ) async {
    final documents = [
      for (var index = 0; index < 2; index++)
        analyticsDocument(
          gameSeed: 970 + index,
          playerQualities: const [MoveQuality.blunder],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.dropsMaterial,
              consequence: MoveInsightConsequenceType.materialLoss,
              materialDelta: -3,
            ),
          },
        ),
    ];
    final snapshot = const PlayerAnalyticsBuilder().build(
      PlayerAnalyticsBuildInput(
        documents: documents,
        playerIdentityScope: 'local',
      ),
    );
    final example = snapshot.priorities.single.examples.first;
    final wrong = analyticsDocument(gameSeed: 999);
    final container = ProviderContainer(
      overrides: [
        playerIntelligenceControllerProvider.overrideWith(
          () => _SnapshotController(snapshot),
        ),
        archiveControllerProvider.overrideWith(
          () => _ExactArchiveController({
            example.documentId: _archivedDocument(wrong),
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ApexTheme.dark,
          home: const PlayerIntelligenceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final link = find.byKey(
      Key('priority-example-${snapshot.priorities.single.priorityId}-0'),
    );
    await tester.scrollUntilVisible(link, 300);
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(
      find.text('This saved review is no longer available.'),
      findsOneWidget,
    );
    expect(
      container.read(reviewControllerProvider).lifecycle,
      ReviewRuntimeLifecycle.idle,
    );
  });
}

PlayerAnalyticsSnapshot _prioritySnapshot() =>
    const PlayerAnalyticsBuilder().build(
      PlayerAnalyticsBuildInput(
        documents: [
          for (var index = 0; index < 3; index++)
            analyticsDocument(
              gameSeed: 800 + index,
              verifiedOpening: true,
              playerQualities: const [
                MoveQuality.blunder,
                MoveQuality.good,
                MoveQuality.good,
                MoveQuality.good,
              ],
              playerInsights: const {
                0: AnalyticsInsightSpec(
                  claim: MoveInsightClaimType.dropsMaterial,
                  consequence: MoveInsightConsequenceType.materialLoss,
                  materialDelta: -3,
                ),
              },
            ),
        ],
        playerIdentityScope: 'local',
      ),
    );

PlayerAnalyticsSnapshot _longPrioritySnapshot() {
  final snapshot = _prioritySnapshot();
  final original = snapshot.priorities.first;
  return snapshot.copyWith(
    priorities: [
      CoachingPriority(
        priorityId: original.priorityId,
        category: original.category,
        title:
            'Review repeated immediate material losses before every forcing continuation',
        action:
            'Check captures, checks, threats, loose pieces, and every forcing reply before committing.',
        eventCount: original.eventCount,
        eligibleDenominator: original.eligibleDenominator,
        gameCount: original.gameCount,
        coverage: original.coverage,
        rank: original.rank,
        examples: original.examples,
      ),
      ...snapshot.priorities.skip(1),
    ],
  );
}

PlayerAnalyticsSnapshot _largeSnapshot() =>
    const PlayerAnalyticsBuilder().build(
      PlayerAnalyticsBuildInput(
        documents: [
          for (var index = 0; index < 110; index++)
            analyticsDocument(gameSeed: 10000 + index, verifiedOpening: true),
        ],
        playerIdentityScope: 'local',
      ),
    );

Widget _host(
  PlayerAnalyticsSnapshot snapshot, {
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      playerIntelligenceControllerProvider.overrideWith(
        () => _SnapshotController(snapshot),
      ),
    ],
    child: MaterialApp(
      theme: ApexTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: child!),
      ),
      home: const PlayerIntelligenceScreen(),
    ),
  );
}

Widget _errorHost() {
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      playerIntelligenceControllerProvider.overrideWith(_ErrorController.new),
    ],
    child: MaterialApp(
      theme: ApexTheme.dark,
      home: const PlayerIntelligenceScreen(),
    ),
  );
}

class _SnapshotController extends PlayerIntelligenceController {
  _SnapshotController(this.snapshot);

  final PlayerAnalyticsSnapshot snapshot;

  @override
  Future<PlayerAnalyticsSnapshot> build() async => snapshot;
}

class _ErrorController extends PlayerIntelligenceController {
  @override
  Future<PlayerAnalyticsSnapshot> build() =>
      Future.error(StateError('synthetic unavailable state'));
}

class _ExactArchiveController extends ArchiveController {
  _ExactArchiveController(this.documents);

  final Map<String, ArchivedGame> documents;

  @override
  ArchiveState build() => ArchiveState(games: documents.values.toList());

  @override
  Future<ArchivedGame?> resolveExact(String id) async => documents[id];
}

ArchivedGame _archivedDocument(ReviewDocument document) => ArchivedGame(
  id: document.documentId,
  source: ArchiveSource.pgn,
  white: document.game.headers['White'] ?? 'Apex Player',
  black: document.game.headers['Black'] ?? 'Opponent',
  result: document.game.headers['Result'] ?? '*',
  analyzedAt: document.createdAt,
  depth: document.timeline.depth ?? 14,
  pgn: document.game.originalPgn,
  qualityCounts: document.classificationCounts,
  averageCpLoss: document.verifiedAcpl ?? 0,
  cpLossSampleCount: document.cpLossEligibleCount,
  totalPlies: document.timeline.totalPlies,
  cachedTimeline: document.timeline,
  classifierVersion: document.timeline.classifierVersion,
  analysisMode: AnalysisMode.quick,
  analysisProfileId: document.timeline.analysisProfileId,
  providerId: document.timeline.providerId,
  tacticalVerifierVersion: document.timeline.tacticalVerifierVersion,
  openingBookVersion: document.timeline.openingBookVersion,
  analysisSchemaVersion: document.timeline.analysisSchemaVersion,
  recordKind: ArchivedRecordKind.canonicalDocument,
  canonicalGameId: document.game.gameId.value,
  analysisVariantId: document.variantId.value,
  analyzedUserIsWhite: document.userIsWhite,
  engineIdentity: document.timeline.engineVersion,
  canonicalIndexVerified: true,
);
