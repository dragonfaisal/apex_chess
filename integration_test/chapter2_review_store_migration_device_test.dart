import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chapter 2 non-destructive migration and exact reopen proof', (
    tester,
  ) async {
    await Hive.initFlutter('chapter2_android_proof');
    final initial = await ArchiveRepository.open();
    await initial.clear();

    final legacyBox = await Hive.openBox<String>(ArchiveRepository.boxName);
    final legacyDocument = _document(
      pgn: _legacyPgn,
      profile: 'fast_review',
      engine: 'Stockfish 17',
      userIsWhite: true,
    );
    final validLegacy = ArchivedGame.fromTimeline(
      timeline: legacyDocument.timeline,
      id: 'chapter2-valid-legacy',
      source: ArchiveSource.chessCom,
      depth: 14,
      pgn: _legacyPgn,
      analysisMode: AnalysisMode.quick,
    );
    final staleLegacy = ArchivedGame(
      id: 'chapter2-stale-legacy',
      source: ArchiveSource.pgn,
      white: 'Old White',
      black: 'Old Black',
      result: '*',
      analyzedAt: DateTime.utc(2024, 1, 1),
      depth: 10,
      pgn: _legacyPgn,
      qualityCounts: const {MoveQuality.brilliant: 7},
      averageCpLoss: 3,
      totalPlies: 1,
      classifierVersion: 1,
      tacticalVerifierVersion: 1,
      analysisSchemaVersion: 1,
    );
    await legacyBox.put(validLegacy.id, jsonEncode(validLegacy.toJson()));
    await legacyBox.put(staleLegacy.id, jsonEncode(staleLegacy.toJson()));
    await legacyBox.put('chapter2-corrupt-legacy', '{"id":');
    final legacyCountBefore = legacyBox.length;

    final migrationWatch = Stopwatch()..start();
    var repository = await ArchiveRepository.open();
    migrationWatch.stop();
    expect(legacyBox.length, legacyCountBefore);
    expect(repository.diagnostics.migratedRecords, 1);
    expect(repository.diagnostics.legacyUntrustedRecords, 1);
    expect(repository.diagnostics.quarantineRecords, 1);
    expect(
      repository.loadAll().any(
        (entry) => entry.recordKind == ArchivedRecordKind.unavailable,
      ),
      isTrue,
    );

    final fast = _document(
      pgn: _variantPgn,
      profile: 'fast_review',
      engine: 'Stockfish 17',
      userIsWhite: false,
    );
    final deep = _document(
      pgn: _variantPgn,
      profile: 'deep_review',
      engine: 'Stockfish 17',
      userIsWhite: false,
    );
    await repository.saveReviewDocument(fast);
    await repository.saveReviewDocument(deep);
    expect(fast.game.gameId.value, deep.game.gameId.value);
    expect(fast.variantId.value, isNot(deep.variantId.value));
    expect(repository.listVariants(fast.game.gameId.value), hasLength(2));

    final reopenWatch = Stopwatch()..start();
    final exactFast = repository.find(fast.documentId);
    reopenWatch.stop();
    expect(exactFast, isNotNull);
    expect(
      exactFast!.cachedTimeline?.engineSearchCount,
      fast.timeline.engineSearchCount,
    );
    expect(exactFast.analyzedUserIsWhite, isFalse);
    expect(exactFast.engineIdentity, contains('Stockfish 17'));

    var analysisProviderReads = 0;
    final deviceArchiveController = _DeviceArchiveController(repository);
    final container = ProviderContainer(
      overrides: [
        archiveControllerProvider.overrideWith(() => deviceArchiveController),
        accountControllerProvider.overrideWith(_NoAccountController.new),
        reviewAnalysisPipelineProvider.overrideWith((ref) async {
          analysisProviderReads++;
          throw StateError('Exact reopen must not request analysis.');
        }),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ArchiveScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Fast'), findsWidgets);
    expect(find.textContaining('Deep'), findsWidgets);
    expect(find.textContaining('Legacy review'), findsWidgets);
    await tester.tap(find.text('Variant White').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final review = container.read(reviewControllerProvider);
    expect(review.timeline, isNotNull);
    expect(review.userIsWhite, isFalse);
    expect(review.flipped, isTrue);
    expect(analysisProviderReads, 0);

    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    final screenshot = await binding.takeScreenshot(
      'chapter2-exact-saved-variant-reopen',
    );
    expect(screenshot, isNotEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();

    final trustedStrong = _document(
      pgn: _replacementPgn,
      profile: 'fast_review',
      engine: 'Stockfish 17',
      userIsWhite: true,
      requestedDepth: 18,
      achievedDepth: 18,
    );
    final weakerRerun = _document(
      pgn: _replacementPgn,
      profile: 'fast_review',
      engine: 'Stockfish 17',
      userIsWhite: true,
      requestedDepth: 18,
      achievedDepth: 12,
      completedAt: DateTime.utc(2026, 8, 1),
    );
    expect(trustedStrong.variantId.value, weakerRerun.variantId.value);
    await repository.saveReviewDocument(trustedStrong);
    await repository.saveReviewDocument(weakerRerun);
    expect(
      repository
          .loadReviewDocument(trustedStrong.documentId)!
          .run
          .achievedDepth,
      18,
    );

    await Hive.close();
    await Hive.initFlutter('chapter2_android_proof');
    repository = await ArchiveRepository.open();
    expect(repository.listVariants(fast.game.gameId.value), hasLength(2));
    expect(
      repository
          .loadReviewDocument(trustedStrong.documentId)!
          .run
          .achievedDepth,
      18,
    );
    expect(repository.diagnostics.legacyRecords, legacyCountBefore);
    expect(repository.diagnostics.quarantineRecords, 1);

    await repository.delete(fast.documentId);
    expect(repository.loadReviewDocument(fast.documentId), isNull);
    expect(repository.loadReviewDocument(deep.documentId), isNotNull);
    expect(repository.listVariants(deep.game.gameId.value), hasLength(1));
    expect(
      Hive.box<String>(ArchiveRepository.boxName).length,
      legacyCountBefore,
    );

    final documentChars = Hive.box<String>(
      ArchiveRepository.documentBoxName,
    ).values.fold<int>(0, (sum, raw) => sum + raw.length);

    // ignore: avoid_print
    print(
      jsonEncode({
        'proof': 'chapter2_review_store_migration',
        'platform': Platform.operatingSystemVersion,
        'storeSchema': kReviewStoreSchemaVersion,
        'documentSchema': kReviewDocumentSchemaVersion,
        'indexSchema': kReviewIndexSchemaVersion,
        'gameIdAlgorithm': kGameIdAlgorithmVersion,
        'variantIdAlgorithm': kAnalysisVariantAlgorithmVersion,
        'legacyCountBefore': legacyCountBefore,
        'legacyCountAfter': Hive.box<String>(ArchiveRepository.boxName).length,
        'migrationCount': repository.diagnostics.migratedRecords,
        'migrationMs': migrationWatch.elapsedMilliseconds,
        'quarantineCount': repository.diagnostics.quarantineRecords,
        'gameId': deep.game.gameId.value,
        'variantCountAfterDelete': repository
            .listVariants(deep.game.gameId.value)
            .length,
        'replacementPreservedDepth': repository
            .loadReviewDocument(trustedStrong.documentId)!
            .run
            .achievedDepth,
        'reopenLatencyMs': reopenWatch.elapsedMilliseconds,
        'engineSearchOccurredOnReopen': analysisProviderReads > 0,
        'engineIdentity': deep.compatibility.engine.declaredIdentity,
        'profile': deep.compatibility.profileId,
        'perspective': deep.analyzedPerspective.name,
        'serializedDocumentChars': documentChars,
        'restartPreserved': true,
        'screenshotBytes': screenshot.length,
      }),
    );

    await repository.clear();
  });
}

ReviewDocument _document({
  required String pgn,
  required String profile,
  required String engine,
  required bool? userIsWhite,
  int? requestedDepth,
  int? achievedDepth,
  DateTime? completedAt,
}) {
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: pgn,
    sourceProvider: 'pgn',
  );
  final requested = requestedDepth ?? (profile == 'deep_review' ? 22 : 14);
  final achieved = achievedDepth ?? requested;
  final moves = [
    for (final (index, move) in game.moves.indexed)
      MoveAnalysis(
        ply: index,
        san: move.san,
        uci: move.uci,
        fenBefore: move.fenBefore,
        fenAfter: move.fenAfter,
        targetSquare: move.uci.substring(2, 4),
        winPercentBefore: 50,
        winPercentAfter: 51,
        deltaW: 1,
        isWhiteMove: index.isEven,
        classification: MoveQuality.best,
        moverCpLoss: 0,
        requestedDepth: requested,
        achievedDepthBefore: achieved,
        achievedDepthAfter: achieved,
        multiPvReceived: profile == 'deep_review' ? 3 : 1,
        searchQualityMet: true,
        message: 'Best',
        engineVersion: 'apex-stockfish-bridge/0.3.0|$engine',
      ),
  ];
  final timeline = AnalysisTimeline(
    startingFen: game.startingFen,
    moves: moves,
    headers: game.headers,
    winPercentages: [for (var i = 0; i < moves.length; i++) 51],
    analysisMode: profile == 'deep_review' ? 'deep' : 'quick',
    analysisProfileId: profile,
    providerId: 'local_offline',
    engineVersion: 'apex-stockfish-bridge/0.3.0|$engine',
    requestedDepth: requested,
    depth: achieved,
    movetimeMs: profile == 'deep_review' ? 6000 : 900,
    multipv: profile == 'deep_review' ? 3 : 1,
    candidateVerificationEnabled: profile == 'deep_review',
    completedAt: completedAt ?? DateTime.utc(2026, 7, 11),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: moves.length,
    engineSearchCount: moves.length + 1,
    engineCacheHitCount: moves.length,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: pgn,
    timeline: timeline,
    sourceProvider: 'pgn',
    userIsWhite: userIsWhite,
  );
}

class _DeviceArchiveController extends ArchiveController {
  _DeviceArchiveController(this.repository);

  final ArchiveRepository repository;

  @override
  ArchiveState build() => ArchiveState(games: repository.loadAll());

  @override
  Future<ArchivedGame?> resolveExact(String id) async => repository.find(id);
}

class _NoAccountController extends AccountController {
  @override
  Future<ApexAccount?> build() async => null;
}

const _legacyPgn = '''
[Site "https://www.chess.com/game/live/legacy"]
[White "Legacy White"]
[Black "Legacy Black"]
[Result "*"]

1. d4 *
''';

const _variantPgn = '''
[Site "local"]
[White "Variant White"]
[Black "Variant Black"]
[Result "*"]

1. e4 e5 2. Nf3 *
''';

const _replacementPgn = '''
[White "Replacement White"]
[Black "Replacement Black"]
[Result "*"]

1. c4 e5 *
''';
