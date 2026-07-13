import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';

void main() {
  late Directory hiveDirectory;
  late ArchiveRepository repository;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('apex-review-store-');
    Hive.init(hiveDirectory.path);
    repository = await ArchiveRepository.open();
  });

  setUp(() async {
    await repository.clear();
    repository = await ArchiveRepository.open();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('saves, lists, and reopens two exact variants for one game', () async {
    final stockfish17 = _document(
      engine: 'Stockfish 17',
      profile: 'fast_review',
    );
    final stockfish18 = _document(
      engine: 'Stockfish 18',
      profile: 'fast_review',
    );

    await repository.saveReviewDocument(stockfish17);
    await repository.saveReviewDocument(stockfish18);

    expect(stockfish17.game.gameId.value, stockfish18.game.gameId.value);
    expect(stockfish17.variantId.value, isNot(stockfish18.variantId.value));
    expect(repository.loadAll(), hasLength(2));
    expect(
      repository.listVariants(stockfish17.game.gameId.value),
      hasLength(2),
    );
    expect(
      repository
          .loadReviewDocument(stockfish17.documentId)!
          .compatibility
          .engine
          .engineVersion,
      '17',
    );
    expect(
      repository
          .loadReviewDocument(stockfish18.documentId)!
          .compatibility
          .engine
          .engineVersion,
      '18',
    );
  });

  test(
    'same variant updates exactly and deleting it preserves siblings',
    () async {
      final fast = _document(engine: 'Stockfish 17', profile: 'fast_review');
      final sameVariantLater = _document(
        engine: 'Stockfish 17',
        profile: 'fast_review',
        completedAt: DateTime.utc(2026, 8, 1),
      );
      final deep = _document(engine: 'Stockfish 17', profile: 'deep_review');

      expect(fast.documentId, sameVariantLater.documentId);
      await repository.saveReviewDocument(fast);
      await repository.saveReviewDocument(sameVariantLater);
      await repository.saveReviewDocument(deep);
      expect(repository.loadAll(), hasLength(2));
      expect(
        repository.loadReviewDocument(fast.documentId)!.run.completedAt,
        DateTime.utc(2026, 8, 1),
      );

      await repository.delete(fast.documentId);
      expect(repository.loadReviewDocument(fast.documentId), isNull);
      expect(repository.loadReviewDocument(deep.documentId), isNotNull);
      expect(repository.loadAll(), hasLength(1));
    },
  );

  group('same-variant replacement policy', () {
    test('depth 12 rerun cannot replace trusted depth 18', () async {
      final strong = _document(
        engine: 'Stockfish 17',
        requestedDepth: 18,
        achievedDepth: 18,
      );
      final weak = _document(
        engine: 'Stockfish 17',
        requestedDepth: 18,
        achievedDepth: 12,
        completedAt: DateTime.utc(2026, 8, 1),
      );

      expect(strong.variantId.value, weak.variantId.value);
      await repository.saveReviewDocument(strong);
      await repository.saveReviewDocument(weak);

      expect(
        repository.loadReviewDocument(strong.documentId)!.run.achievedDepth,
        18,
      );
    });

    test('incomplete MultiPV3 cannot replace complete MultiPV3', () async {
      final complete = _document(
        engine: 'Stockfish 17',
        profile: 'deep_review',
        requestedDepth: 22,
        achievedDepth: 22,
        multiPv: 3,
      );
      final incomplete = _document(
        engine: 'Stockfish 17',
        profile: 'deep_review',
        requestedDepth: 22,
        achievedDepth: 22,
        multiPv: 3,
        multiPvReceived: 1,
        completeAlternatives: false,
        completedAt: DateTime.utc(2026, 8, 1),
      );

      await repository.saveReviewDocument(complete);
      await repository.saveReviewDocument(incomplete);

      expect(
        repository
            .loadReviewDocument(complete.documentId)!
            .timeline
            .moves
            .single
            .engineLines,
        hasLength(3),
      );
    });

    test(
      'unknown provenance cannot replace runtime-verified provenance',
      () async {
        final declared = _document(engine: 'Stockfish 17');
        final verified = _withIdentityVerification(
          declared,
          ProvenanceVerification.runtimeVerified,
        );
        final unknown = _withIdentityVerification(
          _document(
            engine: 'Stockfish 17',
            completedAt: DateTime.utc(2026, 8, 1),
          ),
          ProvenanceVerification.unknown,
        );

        await repository.saveReviewDocument(verified);
        await repository.saveReviewDocument(unknown);

        expect(
          repository
              .loadReviewDocument(verified.documentId)!
              .compatibility
              .engine
              .identityVerification,
          ProvenanceVerification.runtimeVerified,
        );
      },
    );

    test('partial, cancelled, and failed reruns are rejected', () async {
      final complete = _document(engine: 'Stockfish 17');
      await repository.saveReviewDocument(complete);

      for (final status in <ReviewDocumentStatus>[
        ReviewDocumentStatus.partial,
        ReviewDocumentStatus.cancelled,
        ReviewDocumentStatus.failed,
      ]) {
        final json = complete.toJson();
        json['status'] = status.name;
        final invalid = ReviewDocument.fromJson(json);
        await expectLater(
          repository.saveReviewDocument(invalid),
          throwsA(isA<ReviewDocumentValidationException>()),
        );
      }
      expect(repository.loadReviewDocument(complete.documentId), isNotNull);
    });

    test(
      'equal-quality, stronger, and exact duplicate reruns are safe',
      () async {
        final depth12 = _document(
          engine: 'Stockfish 17',
          requestedDepth: 18,
          achievedDepth: 12,
        );
        final equalLater = _document(
          engine: 'Stockfish 17',
          requestedDepth: 18,
          achievedDepth: 12,
          completedAt: DateTime.utc(2026, 8, 1),
        );
        final depth18 = _document(
          engine: 'Stockfish 17',
          requestedDepth: 18,
          achievedDepth: 18,
          completedAt: DateTime.utc(2026, 9, 1),
        );

        await repository.saveReviewDocument(depth12);
        await repository.saveReviewDocument(equalLater);
        expect(
          repository.loadReviewDocument(depth12.documentId)!.run.completedAt,
          DateTime.utc(2026, 8, 1),
        );
        await repository.saveReviewDocument(depth18);
        await repository.saveReviewDocument(depth18);
        expect(
          repository.loadReviewDocument(depth18.documentId)!.run.achievedDepth,
          18,
        );
        expect(repository.loadAll(), hasLength(1));
      },
    );
  });

  test('missing index is repaired from validated document', () async {
    final document = _document(engine: 'Stockfish 17');
    await Hive.box<String>(
      ArchiveRepository.documentBoxName,
    ).put(document.documentId, document.encode());

    repository = await ArchiveRepository.open();

    expect(repository.loadAll(), hasLength(1));
    expect(repository.diagnostics.repairedIndexes, 1);
    expect(repository.loadReviewDocument(document.documentId), isNotNull);
  });

  test('mismatched index is quarantined before document-led repair', () async {
    final document = _document(engine: 'Stockfish 17');
    await repository.saveReviewDocument(document);
    final indexBox = Hive.box<String>(ArchiveRepository.indexBoxName);
    await indexBox.put(document.documentId, '{"schemaVersion":1}');

    repository = await ArchiveRepository.open();

    expect(repository.loadReviewDocument(document.documentId), isNotNull);
    expect(repository.loadAll(), hasLength(1));
    expect(repository.diagnostics.repairedIndexes, 1);
    expect(repository.diagnostics.quarantineRecords, 1);
  });

  test('valid-looking stale aggregate cache is detected and rebuilt', () async {
    final document = _document(engine: 'Stockfish 17');
    await repository.saveReviewDocument(document);
    final indexBox = Hive.box<String>(ArchiveRepository.indexBoxName);
    final stale = jsonDecode(indexBox.get(document.documentId)!) as Map;
    stale['verifiedAcpl'] = 999;
    stale['qualityCounts'] = {'blunder': 99};
    await indexBox.put(document.documentId, jsonEncode(stale));

    repository = await ArchiveRepository.open();
    final repaired = repository.loadAll().single;

    expect(repaired.averageCpLoss, 0);
    expect(repaired.qualityCounts[MoveQuality.best], 1);
    expect(repaired.blunderCount, 0);
    expect(repository.diagnostics.repairedIndexes, 1);
    expect(repository.diagnostics.quarantineRecords, 1);
  });

  test('orphan index and malformed legacy JSON are quarantined', () async {
    await Hive.box<String>(ArchiveRepository.indexBoxName).put(
      'missing-document',
      '{"schemaVersion":1,"documentId":"missing-document"}',
    );
    await Hive.box<String>(
      ArchiveRepository.boxName,
    ).put('broken-legacy', '{"id":"broken-legacy",');

    repository = await ArchiveRepository.open();
    final entries = repository.loadAll();

    expect(entries, hasLength(1));
    expect(entries.single.recordKind, ArchivedRecordKind.unavailable);
    expect(repository.diagnostics.orphanedIndexes, 1);
    expect(repository.diagnostics.quarantineRecords, 2);

    repository = await ArchiveRepository.open();
    expect(repository.diagnostics.quarantineRecords, 2);
    expect(repository.loadAll(), hasLength(1));
  });

  test('retry after quarantine write finishes orphan index deletion', () async {
    const sourceKey = 'orphan-after-quarantine';
    const raw = '{"schemaVersion":1,"documentId":"orphan-after-quarantine"}';
    final fingerprint = sha256.convert(utf8.encode(raw)).toString();
    final quarantineKey =
        '${ArchiveRepository.indexBoxName}:$sourceKey:$fingerprint';
    await Hive.box<String>(ArchiveRepository.indexBoxName).put(sourceKey, raw);
    await Hive.box<String>(ArchiveRepository.quarantineBoxName).put(
      quarantineKey,
      jsonEncode({
        'sourceBox': ArchiveRepository.indexBoxName,
        'sourceKey': sourceKey,
        'fingerprint': fingerprint,
        'raw': raw,
      }),
    );

    repository = await ArchiveRepository.open();
    repository = await ArchiveRepository.open();

    expect(
      Hive.box<String>(ArchiveRepository.indexBoxName).containsKey(sourceKey),
      isFalse,
    );
    expect(repository.diagnostics.quarantineRecords, 1);
    expect(repository.loadAll(), isEmpty);
  });

  test('valid legacy migration is copy-on-write and idempotent', () async {
    final document = _document(engine: 'Stockfish 17');
    final legacy = ArchivedGame.fromTimeline(
      timeline: document.timeline,
      id: 'legacy-current',
      source: ArchiveSource.pgn,
      depth: 14,
      pgn: _pgn,
      analysisMode: AnalysisMode.quick,
    );
    await repository.save(legacy);

    final migrationWatch = Stopwatch()..start();
    repository = await ArchiveRepository.open();
    migrationWatch.stop();
    expect(repository.diagnostics.legacyRecords, 1);
    expect(repository.diagnostics.migratedRecords, 1);
    expect(repository.diagnostics.documents, 1);
    expect(
      Hive.box<String>(ArchiveRepository.boxName).get('legacy-current'),
      isNotNull,
      reason: 'migration must retain the original legacy source',
    );
    expect(repository.loadAll(), hasLength(1));
    debugPrint(
      'CHAPTER2_MIGRATION_PERF records=1 '
      'migrationMs=${migrationWatch.elapsedMilliseconds}',
    );
    expect(
      repository.loadAll().single.recordKind,
      ArchivedRecordKind.canonicalDocument,
    );

    repository = await ArchiveRepository.open();
    expect(repository.diagnostics.migratedRecords, 1);
    expect(repository.diagnostics.documents, 1);
    expect(repository.loadAll(), hasLength(1));
  });

  test('migration success marker without document retries safely', () async {
    final document = _document(engine: 'Stockfish 17');
    final legacy = ArchivedGame.fromTimeline(
      timeline: document.timeline,
      id: 'legacy-marker-first',
      source: ArchiveSource.pgn,
      depth: 14,
      pgn: _pgn,
      analysisMode: AnalysisMode.quick,
    );
    final raw = jsonEncode(legacy.toJson());
    await Hive.box<String>(ArchiveRepository.boxName).put(legacy.id, raw);
    await Hive.box<String>(ArchiveRepository.migrationBoxName).put(
      legacy.id,
      jsonEncode({
        'schemaVersion': kReviewMigrationSchemaVersion,
        'sourceKey': legacy.id,
        'fingerprint': sha256.convert(utf8.encode(raw)).toString(),
        'disposition': 'migrated',
        'updatedAt': DateTime.utc(2026, 7, 11).toIso8601String(),
        'documentId': document.documentId,
        'reason': null,
      }),
    );

    repository = await ArchiveRepository.open();

    expect(repository.loadReviewDocument(document.documentId), isNotNull);
    expect(repository.loadAll(), hasLength(1));
    expect(
      Hive.box<String>(ArchiveRepository.boxName).get(legacy.id),
      raw,
      reason: 'the original legacy value must stay untouched',
    );
  });

  test(
    'document before migration marker repairs index and finishes once',
    () async {
      final document = _document(engine: 'Stockfish 17');
      final legacy = ArchivedGame.fromTimeline(
        timeline: document.timeline,
        id: 'legacy-document-first',
        source: ArchiveSource.pgn,
        depth: 14,
        pgn: _pgn,
        analysisMode: AnalysisMode.quick,
      );
      await Hive.box<String>(
        ArchiveRepository.boxName,
      ).put(legacy.id, jsonEncode(legacy.toJson()));
      await Hive.box<String>(
        ArchiveRepository.documentBoxName,
      ).put(document.documentId, document.encode());

      repository = await ArchiveRepository.open();

      expect(repository.diagnostics.repairedIndexes, 1);
      expect(repository.diagnostics.migratedRecords, 1);
      expect(repository.loadAll(), hasLength(1));
      repository = await ArchiveRepository.open();
      expect(repository.diagnostics.documents, 1);
      expect(repository.diagnostics.migratedRecords, 1);
    },
  );

  test('recovery never deletes a valid sibling variant', () async {
    final fast = _document(engine: 'Stockfish 17', profile: 'fast_review');
    final deep = _document(engine: 'Stockfish 17', profile: 'deep_review');
    await repository.saveReviewDocument(fast);
    await repository.saveReviewDocument(deep);
    await Hive.box<String>(
      ArchiveRepository.indexBoxName,
    ).put('orphan-retry', '{"schemaVersion":1,"documentId":"orphan-retry"}');

    repository = await ArchiveRepository.open();
    repository = await ArchiveRepository.open();

    expect(repository.listVariants(fast.game.gameId.value), hasLength(2));
    expect(repository.loadReviewDocument(fast.documentId), isNotNull);
    expect(repository.loadReviewDocument(deep.documentId), isNotNull);
    expect(
      Hive.box<String>(
        ArchiveRepository.indexBoxName,
      ).containsKey('orphan-retry'),
      isFalse,
    );
  });

  test(
    'insufficient legacy evidence stays visible with metrics withheld',
    () async {
      final legacy = ArchivedGame(
        id: 'legacy-stale',
        source: ArchiveSource.pgn,
        white: 'Alpha',
        black: 'Beta',
        result: '*',
        analyzedAt: DateTime.utc(2020),
        depth: 12,
        pgn: _pgn,
        qualityCounts: const {MoveQuality.brilliant: 9},
        averageCpLoss: 1,
        totalPlies: 1,
        classifierVersion: 1,
        tacticalVerifierVersion: 1,
        analysisSchemaVersion: 1,
      );
      await repository.save(legacy);

      repository = await ArchiveRepository.open();
      final visible = repository.loadAll().single;

      expect(visible.recordKind, ArchivedRecordKind.legacy);
      expect(visible.brilliantCount, 0);
      expect(visible.hasVerifiedCpLoss, isFalse);
      expect(repository.diagnostics.legacyUntrustedRecords, 1);
      expect(repository.diagnostics.documents, 0);
    },
  );

  test('compact index remains bounded for 100 realistic games', () async {
    final rssBefore = ProcessInfo.currentRss;
    final saved = <ReviewDocument>[];
    for (var index = 0; index < 100; index++) {
      final pgn = _corpusPgn(index);
      final fast = _document(engine: 'Stockfish 17', pgn: pgn);
      saved.add(fast);
      await repository.saveReviewDocument(fast);
      if (index < 25) {
        final deep = _document(
          engine: 'Stockfish 17',
          profile: 'deep_review',
          pgn: pgn,
        );
        saved.add(deep);
        await repository.saveReviewDocument(deep);
      }
    }
    await Hive.box<String>(
      ArchiveRepository.documentBoxName,
    ).put('intentionally-undecodable-document', 'not json');

    final watch = Stopwatch()..start();
    final entries = repository.loadAll();
    watch.stop();
    final reopenWatch = Stopwatch()..start();
    final reopened = repository.loadReviewDocument(saved.last.documentId);
    reopenWatch.stop();
    final serializedBytes = Hive.box<String>(
      ArchiveRepository.documentBoxName,
    ).values.fold<int>(0, (sum, raw) => sum + utf8.encode(raw).length);
    await Hive.box<String>(ArchiveRepository.indexBoxName).clear();
    final rebuildWatch = Stopwatch()..start();
    repository = await ArchiveRepository.open();
    rebuildWatch.stop();
    final rssAfter = ProcessInfo.currentRss;
    debugPrint(
      'CHAPTER2_PERF games=100 documents=${entries.length} plies=40 '
      'archiveLoadMs=${watch.elapsedMilliseconds} '
      'exactReopenMs=${reopenWatch.elapsedMilliseconds} '
      'indexRebuildMs=${rebuildWatch.elapsedMilliseconds} '
      'serializedBytes=$serializedBytes '
      'rssDeltaBytes=${rssAfter - rssBefore}',
    );

    expect(entries, hasLength(125));
    expect(reopened, isNotNull);
    expect(reopened!.timeline.totalPlies, 40);
    expect(repository.loadAll(), hasLength(125));
    expect(repository.diagnostics.repairedIndexes, 125);
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
    expect(reopenWatch.elapsed, lessThan(const Duration(seconds: 2)));
    expect(rebuildWatch.elapsed, lessThan(const Duration(seconds: 10)));
  });
}

ReviewDocument _document({
  required String engine,
  String profile = 'fast_review',
  DateTime? completedAt,
  String pgn = _pgn,
  int? requestedDepth,
  int? achievedDepth,
  int? multiPv,
  int? multiPvReceived,
  bool completeAlternatives = true,
}) {
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: pgn,
    sourceProvider: 'pgn',
  );
  final requested = requestedDepth ?? (profile == 'deep_review' ? 22 : 14);
  final achieved = achievedDepth ?? requested;
  final requestedMultiPv = multiPv ?? (profile == 'deep_review' ? 3 : 1);
  final received = multiPvReceived ?? requestedMultiPv;
  final analyzedMoves = <MoveAnalysis>[];
  for (final (index, move) in game.moves.indexed) {
    final isWhite = index.isEven;
    final score = isWhite ? 10 : -10;
    final roots = _legalRoots(
      move.fenBefore,
      played: move.uci,
      count: completeAlternatives ? requestedMultiPv : 1,
    );
    final lines = <EngineLine>[
      for (final (rank, root) in roots.indexed)
        EngineLine(
          rank: rank + 1,
          moveUci: root,
          scoreCp: score + (isWhite ? -rank * 10 : rank * 10),
          depth: achieved,
          whiteWinPercent: const WinPercentCalculator().forCp(
            cp: score + (isWhite ? -rank * 10 : rank * 10),
          ),
          pvMoves: [root],
        ),
    ];
    final evidence = MoveClassificationEvidence(
      mover: isWhite ? ClassificationMover.white : ClassificationMover.black,
      evaluationBefore: ClassificationScore.cp(score),
      playedMoveEvaluation: ClassificationScore.cp(score),
      bestMoveEvaluation: ClassificationScore.cp(score),
      playedMoveUci: move.uci,
      bestMoveUci: move.uci,
      candidates: [
        for (final line in lines)
          ClassificationCandidateEvidence(
            rootUci: line.moveUci!,
            rank: line.rank,
            score: ClassificationScore.cp(line.scoreCp!),
            achievedDepth: line.depth,
            isLegal: true,
            pvComplete: true,
          ),
      ],
      requestedMultiPv: requestedMultiPv,
      receivedMultiPv: received,
      candidateSetComplete:
          completeAlternatives &&
          received >= requestedMultiPv &&
          lines.length >= requestedMultiPv,
      candidateSetCoherent: true,
      bestMovePv1Consistent: true,
      searchQualityMet: achieved >= requested,
      achievedDepthFloor: achieved,
      legalMoveCount: _legalMoveCount(move.fenBefore),
      bookState: ClassificationBookState.notBook,
      verificationState: profile == 'deep_review'
          ? ClassificationVerificationState.complete
          : ClassificationVerificationState.notRequested,
      forcedState: ClassificationForcedState.notForced,
      isSacrifice: false,
      isCapture: false,
      isFreeCapture: false,
      isRecapture: false,
      isTrivialRecapture: false,
      isFirstSacrificePly: false,
    );
    final decision = const MoveClassifier().classifyEvidence(evidence);
    analyzedMoves.add(
      MoveAnalysis(
        ply: index,
        san: move.san,
        uci: move.uci,
        fenBefore: move.fenBefore,
        fenAfter: move.fenAfter,
        targetSquare: move.uci.substring(2, 4),
        winPercentBefore: decision.winPercentBefore,
        winPercentAfter: decision.winPercentAfter,
        deltaW: decision.deltaW,
        isWhiteMove: isWhite,
        classification: decision.quality,
        baseClassification: decision.baseQuality,
        finalClassification: decision.quality,
        reasonCode: decision.reasonCode,
        classificationEvidence: evidence,
        classificationReasonCodes: decision.reasonCodes,
        classificationFailedGates: decision.failedGates,
        playedEqualsPv1: decision.playedEqualsPv1,
        moverCpLoss: decision.moverCpLoss,
        scoreCpAfter: score,
        requestedDepth: requested,
        achievedDepthBefore: achieved,
        achievedDepthAfter: achieved,
        multiPvReceived: received,
        searchQualityMet: achieved >= requested,
        engineBestMoveUci: move.uci,
        engineLines: lines,
        message: decision.message,
        engineVersion: 'apex-stockfish-bridge/0.3.0|$engine',
      ),
    );
  }
  final timeline = AnalysisTimeline(
    startingFen: game.startingFen,
    moves: analyzedMoves,
    headers: game.headers,
    winPercentages: [for (final move in analyzedMoves) move.winPercentAfter],
    analysisMode: profile == 'deep_review' ? 'deep' : 'quick',
    analysisProfileId: profile,
    providerId: 'local_offline',
    engineVersion: 'apex-stockfish-bridge/0.3.0|$engine',
    requestedDepth: requested,
    depth: achieved,
    movetimeMs: profile == 'deep_review' ? 6000 : 900,
    multipv: requestedMultiPv,
    candidateVerificationEnabled: profile == 'deep_review',
    completedAt: completedAt ?? DateTime.utc(2026, 7, 11),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: game.moves.length,
    engineSearchCount: game.moves.length + 1,
    engineCacheHitCount: game.moves.length,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: pgn,
    timeline: timeline,
    sourceProvider: 'pgn',
    userIsWhite: false,
  );
}

List<String> _legalRoots(
  String fen, {
  required String played,
  required int count,
}) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final roots = <String>[];
  position.legalMoves.forEach((from, destinations) {
    final piece = position.board.pieceAt(from);
    for (final to in destinations.squares) {
      final promotion =
          piece?.role == Role.pawn && (to.rank == 0 || to.rank == 7);
      final roles = promotion
          ? const [Role.queen, Role.rook, Role.bishop, Role.knight]
          : const <Role?>[null];
      for (final role in roles) {
        final move = NormalMove(from: from, to: to, promotion: role);
        if (position.isLegal(move)) roots.add(_uci(move));
      }
    }
  });
  final normalizedPlayed = normalizeCastlingUci(played);
  final distinct =
      roots
          .where((root) => normalizeCastlingUci(root) != normalizedPlayed)
          .toSet()
          .toList(growable: false)
        ..sort();
  return <String>[played, ...distinct].take(count).toList(growable: false);
}

int _legalMoveCount(String fen) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  var count = 0;
  position.legalMoves.forEach((from, destinations) {
    final piece = position.board.pieceAt(from);
    for (final to in destinations.squares) {
      count += piece?.role == Role.pawn && (to.rank == 0 || to.rank == 7)
          ? 4
          : 1;
    }
  });
  return count;
}

String _uci(NormalMove move) => normalizeCastlingUci(
  '${_square(move.from)}${_square(move.to)}'
  '${move.promotion == null ? '' : _role(move.promotion!)}',
);

String _square(Square square) =>
    '${String.fromCharCode('a'.codeUnitAt(0) + square.file)}${square.rank + 1}';

String _role(Role role) => switch (role) {
  Role.queen => 'q',
  Role.rook => 'r',
  Role.bishop => 'b',
  Role.knight => 'n',
  Role.pawn || Role.king => '',
};

ReviewDocument _withIdentityVerification(
  ReviewDocument document,
  ProvenanceVerification verification,
) {
  final json = document.toJson();
  final compatibility = json['compatibility'] as Map<String, dynamic>;
  final engine = compatibility['engine'] as Map<String, dynamic>;
  engine['identityVerification'] = verification.name;
  final changed = ReviewDocument.fromJson(json);
  changed.validate();
  return changed;
}

String _corpusPgn(int seed) {
  final moves = <String>[];
  for (var cycle = 0; cycle < 10; cycle++) {
    final digit = cycle < 4 ? (seed >> (cycle * 2)) & 3 : 0;
    final whiteOut = digit.isEven ? 'Nf3' : 'Nh3';
    final blackOut = digit < 2 ? 'Nf6' : 'Nh6';
    final firstMoveNumber = cycle * 2 + 1;
    moves.add(
      '$firstMoveNumber. $whiteOut $blackOut '
      '${firstMoveNumber + 1}. Ng1 Ng8',
    );
  }
  return '''
[Event "Chapter 2 corpus $seed"]
[White "Corpus White $seed"]
[Black "Corpus Black $seed"]
[Result "*"]

${moves.join(' ')} *
''';
}

const _pgn = '''
[White "Alpha"]
[Black "Beta"]
[Result "*"]

1. e4 *
''';
