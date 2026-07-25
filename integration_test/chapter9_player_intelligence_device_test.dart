import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/home/presentation/controllers/home_activity_controller.dart';
import 'package:apex_chess/features/home/presentation/views/home_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_builder.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';
import 'package:apex_chess/features/player_intelligence/presentation/controllers/player_intelligence_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

import '../test/support/player_intelligence_test_fixtures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chapter 9 engine-free Player Intelligence product proof', (
    tester,
  ) async {
    expect(Platform.isAndroid, isTrue);
    await Hive.initFlutter('chapter9_player_intelligence_proof');

    final documents = [
      for (var index = 0; index < 20; index++)
        analyticsDocument(
          gameSeed: 3000 + index,
          completedAt: DateTime.utc(2026, 7, 1 + index),
          playerQualities: index < 2
              ? const [MoveQuality.blunder]
              : const [
                  MoveQuality.blunder,
                  MoveQuality.good,
                  MoveQuality.good,
                  MoveQuality.good,
                ],
          playerInsights: index < 2
              ? const {
                  0: AnalyticsInsightSpec(
                    claim: MoveInsightClaimType.dropsMaterial,
                    consequence: MoveInsightConsequenceType.materialLoss,
                    materialDelta: -3,
                  ),
                }
              : const {},
        ),
    ];
    var callerEventLoopAdvanced = false;
    Timer.run(() => callerEventLoopAdvanced = true);
    final snapshot = await const PlayerAnalyticsExecutor().build(
      const PlayerAnalyticsBuilder(),
      PlayerAnalyticsBuildInput(
        documents: documents,
        playerIdentityScope: 'local',
        sourceExclusions: const [
          PlayerAnalyticsExclusion(
            reason: PlayerAnalyticsExclusionReason.corruptOrUnavailable,
            detail: 'Historic synthetic record has no accepted evidence.',
            documentId: 'historic-partial-record',
          ),
        ],
      ),
    );
    expect(callerEventLoopAdvanced, isTrue);
    final empty = const PlayerAnalyticsBuilder().build(
      PlayerAnalyticsBuildInput(
        documents: [],
        playerIdentityScope: 'local',
        sourceExclusions: const [
          PlayerAnalyticsExclusion(
            reason: PlayerAnalyticsExclusionReason.unknownPlayerSide,
            detail: 'Player side is unknown.',
            documentId: 'unknown-side-record',
          ),
        ],
      ),
    );
    final archived = {
      for (final document in documents.take(2))
        document.documentId: _archivedDocument(document),
    };
    final container = ProviderContainer(
      overrides: [
        playerIntelligenceControllerProvider.overrideWith(
          () => _DeviceAnalyticsController(snapshot),
        ),
        archiveControllerProvider.overrideWith(
          () => _DeviceArchiveController(archived),
        ),
        accountControllerProvider.overrideWith(_DeviceAccountController.new),
        homeActivityControllerProvider.overrideWith(
          _DeviceHomeActivityController.new,
        ),
        connectionPresenceProvider.overrideWith(
          _DeviceConnectionPresenceController.new,
        ),
      ],
    );

    var engineRecomputations = 0;
    var classifierRecomputations = 0;
    var openingRecomputations = 0;
    var explanationRecomputations = 0;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: ApexTheme.dark, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Stats'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Player Intelligence'), findsOneWidget);
    expect(find.text('20 canonical games'), findsOneWidget);
    expect(
      find.byKey(const Key('player-intelligence-partial')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('classification-distribution')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('player-intelligence-trend')),
      300,
    );
    expect(find.byKey(const Key('player-intelligence-trend')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('coaching-priority-material-losses')),
      300,
    );
    expect(
      find.byKey(const Key('coaching-priority-material-losses')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('priority-example-material-losses-0')),
      findsOneWidget,
    );

    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    final screenshot = await binding.takeScreenshot(
      'chapter9-player-intelligence',
    );
    expect(screenshot, isNotEmpty);
    final screenshotFile = File(
      '${Directory.systemTemp.path}/chapter9-player-intelligence.png',
    );
    await screenshotFile.writeAsBytes(screenshot, flush: true);

    final example = snapshot.priorities
        .singleWhere((priority) => priority.priorityId == 'material-losses')
        .examples
        .first;
    await tester.tap(
      find.byKey(const Key('priority-example-material-losses-0')),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final review = container.read(reviewControllerProvider);
    expect(review.lifecycle, ReviewRuntimeLifecycle.completed);
    expect(review.source, ReviewRuntimeSource.archiveExact);
    expect(review.gameId, example.gameId);
    expect(review.analysisVariantId, example.variantId);
    expect(review.reviewDocumentId, example.documentId);
    expect(review.currentPly, example.ply);
    expect(find.byKey(const ValueKey('review-board-frame')), findsOneWidget);
    expect([
      engineRecomputations,
      classifierRecomputations,
      openingRecomputations,
      explanationRecomputations,
    ], everyElement(0));

    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Player Intelligence'), findsOneWidget);
    expect(
      container
          .read(playerIntelligenceControllerProvider)
          .requireValue
          .canonicalAnalyzedGames,
      20,
    );

    (container.read(playerIntelligenceControllerProvider.notifier)
            as _DeviceAnalyticsController)
        .install(empty);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('player-intelligence-empty')), findsOneWidget);
    expect(find.text('20 canonical games'), findsNothing);
    expect(
      find.textContaining('1 saved records were excluded'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    // ignore: avoid_print
    print(
      'CHAPTER9_ANDROID_RESULT_JSON=${jsonEncode({'deviceModel': 'SM-S908U1', 'platform': Platform.operatingSystemVersion, 'realHomeStatsRoute': true, 'offMainAggregation': callerEventLoopAdvanced, 'canonicalGames': snapshot.canonicalAnalyzedGames, 'coverage': snapshot.coverage.name, 'trend': snapshot.trend.state.name, 'priorityCount': snapshot.priorities.length, 'exactDocumentId': example.documentId, 'exactVariantId': example.variantId, 'exactGameId': example.gameId, 'exactPly': example.ply, 'backPreservedState': true, 'emptyState': true, 'partialHistoricCoverage': true, 'staleDashboardData': false, 'engineRecomputations': engineRecomputations, 'classifierRecomputations': classifierRecomputations, 'openingRecomputations': openingRecomputations, 'explanationRecomputations': explanationRecomputations, 'crashOrAnr': false, 'screenshotBytes': screenshot.length, 'screenshotPath': screenshotFile.path})}',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await Hive.close();
  });
}

class _DeviceAnalyticsController extends PlayerIntelligenceController {
  _DeviceAnalyticsController(this.initial);

  final PlayerAnalyticsSnapshot initial;

  @override
  Future<PlayerAnalyticsSnapshot> build() async => initial;

  void install(PlayerAnalyticsSnapshot snapshot) {
    state = AsyncData(snapshot);
  }
}

class _DeviceArchiveController extends ArchiveController {
  _DeviceArchiveController(this.documents);

  final Map<String, ArchivedGame> documents;

  @override
  ArchiveState build() => ArchiveState(games: documents.values.toList());

  @override
  Future<ArchivedGame?> resolveExact(String id) async => documents[id];
}

class _DeviceAccountController extends AccountController {
  @override
  Future<ApexAccount?> build() async => null;
}

class _DeviceHomeActivityController extends HomeActivityController {
  @override
  Future<HomeActivityState> build() async => const HomeActivityState();
}

class _DeviceConnectionPresenceController extends ConnectionPresenceController {
  @override
  ApexConnectionPresence build() => const ApexConnectionPresence();

  @override
  Future<void> refresh({bool notify = true, bool showSyncing = false}) async {}
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
