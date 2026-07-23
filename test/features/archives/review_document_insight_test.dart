import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:apex_chess/core/domain/services/move_insight_engine.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

import '../../support/move_insight_test_fixtures.dart';

void main() {
  test('current insight document round-trips exact v2 variant and copy', () {
    final document = _document();
    final reopened = ReviewDocument.decodeAndValidate(document.encode());

    expect(
      reopened.variantId.algorithmVersion,
      kAnalysisVariantAlgorithmVersion,
    );
    expect(reopened.timeline.analysisSchemaVersion, kApexAnalysisSchemaVersion);
    expect(
      reopened.timeline.explanationPolicyVersion,
      kApexExplanationPolicyVersion,
    );
    expect(
      reopened.timeline.explanationRendererVersion,
      kApexExplanationRendererVersion,
    );
    expect(
      reopened.timeline.moves.single.insight?.integrityDigest,
      document.timeline.moves.single.insight?.integrityDigest,
    );
    expect(
      reopened.timeline.moves.single.insight?.conciseText,
      "This follows B00 · King's Pawn Game theory.",
    );
    expect(reopened.timeline.moves.single.coachExplanation, isEmpty);
  });

  test('historic schema-v5 renderer-v1 reopens with exact durable IDs', () {
    final current = _document();
    final sourceMove = current.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    const renderer = MoveInsightRenderer();
    final historicCopy = renderer.renderForVersion(
      sourceInsight.primaryClaim!,
      kApexLegacyExplanationRendererVersion,
    );
    final historicInsight = MoveInsight.create(
      state: sourceInsight.state,
      facts: sourceInsight.facts,
      primaryClaim: sourceInsight.primaryClaim,
      supportingClaims: sourceInsight.supportingClaims,
      causalChain: sourceInsight.causalChain,
      conciseText: historicCopy.concise,
      causeText: historicCopy.cause,
      consequenceText: historicCopy.consequence,
      betterMoveText: historicCopy.betterMove,
      continuationText: historicCopy.continuation,
      policyVersion: kApexLegacyExplanationPolicyVersion,
      claimSchemaVersion: kApexLegacyExplanationClaimSchemaVersion,
      rendererVersion: kApexLegacyExplanationRendererVersion,
    );
    final historicMove = MoveAnalysis.fromJson(
      sourceMove.toJson()..['insight'] = historicInsight.toJson(),
    ).sealAnalysisIntegrity();
    final historic = ReviewDocument.fromCompletedTimeline(
      pgn: _pgn,
      timeline: current.timeline.copyWith(
        moves: <MoveAnalysis>[historicMove],
        analysisSchemaVersion: kApexLegacyInsightAnalysisSchemaVersion,
        explanationPolicyVersion: kApexLegacyExplanationPolicyVersion,
        explanationClaimSchemaVersion: kApexLegacyExplanationClaimSchemaVersion,
        explanationRendererVersion: kApexLegacyExplanationRendererVersion,
      ),
      sourceProvider: 'pgn',
      createdAt: DateTime.utc(2026, 7, 18),
      userIsWhite: true,
    );
    final reopened = ReviewDocument.decodeAndValidate(historic.encode());

    expect(
      reopened.variantId.algorithmVersion,
      kAnalysisVariantAlgorithmVersion,
    );
    expect(reopened.variantId.value, historic.variantId.value);
    expect(reopened.documentId, historic.documentId);
    expect(reopened.game.gameId.value, historic.game.gameId.value);
    expect(
      reopened.timeline.moves.single.insight?.rendererVersion,
      kApexLegacyExplanationRendererVersion,
    );
    expect(
      reopened.timeline.moves.single.insight?.causeText,
      'The exact move and position match the verified opening index.',
    );
    expect(reopened.timeline.hasSupportedExplanationContract, isTrue);
    expect(reopened.timeline.hasCurrentExplanationContract, isFalse);
    expect(reopened.variantId.value, isNot(current.variantId.value));
  });

  test('historic schema-v5 renderer-v2 text and IDs remain immutable', () {
    final current = _document();
    final sourceMove = current.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    const renderer = MoveInsightRenderer();
    final historicCopy = renderer.renderForVersion(
      sourceInsight.primaryClaim!,
      kApexChapter6ExplanationRendererVersion,
    );
    final historicInsight = MoveInsight.create(
      state: sourceInsight.state,
      facts: sourceInsight.facts,
      primaryClaim: sourceInsight.primaryClaim,
      supportingClaims: sourceInsight.supportingClaims,
      causalChain: sourceInsight.causalChain,
      conciseText: historicCopy.concise,
      causeText: historicCopy.cause,
      consequenceText: historicCopy.consequence,
      betterMoveText: historicCopy.betterMove,
      continuationText: historicCopy.continuation,
      policyVersion: kApexLegacyExplanationPolicyVersion,
      claimSchemaVersion: kApexLegacyExplanationClaimSchemaVersion,
      rendererVersion: kApexChapter6ExplanationRendererVersion,
    );
    final historicMove = MoveAnalysis.fromJson(
      sourceMove.toJson()..['insight'] = historicInsight.toJson(),
    ).sealAnalysisIntegrity();
    final historic = ReviewDocument.fromCompletedTimeline(
      pgn: _pgn,
      timeline: current.timeline.copyWith(
        moves: <MoveAnalysis>[historicMove],
        analysisSchemaVersion: kApexLegacyInsightAnalysisSchemaVersion,
        explanationPolicyVersion: kApexLegacyExplanationPolicyVersion,
        explanationClaimSchemaVersion: kApexLegacyExplanationClaimSchemaVersion,
        explanationRendererVersion: kApexChapter6ExplanationRendererVersion,
      ),
      sourceProvider: 'pgn',
      createdAt: DateTime.utc(2026, 7, 18),
      userIsWhite: true,
    );
    final reopened = ReviewDocument.decodeAndValidate(historic.encode());

    expect(reopened.variantId.value, historic.variantId.value);
    expect(reopened.documentId, historic.documentId);
    expect(
      reopened.timeline.moves.single.insight?.conciseText,
      "This follows B00 · King's Pawn Game theory.",
    );
    expect(reopened.timeline.hasSupportedExplanationContract, isTrue);
    expect(reopened.timeline.hasCurrentExplanationContract, isFalse);
    expect(reopened.variantId.value, isNot(current.variantId.value));
  });

  test('historic schema-v4 variant remains algorithm v1 and insight-free', () {
    final current = _document();
    final evidence = current.timeline.moves.single.classificationEvidence!;
    final decision = const MoveClassifier().classifyEvidence(evidence);
    final moveJson = current.timeline.moves.single.toJson()
      ..remove('insight')
      ..remove('analysisIntegrityDigest')
      ..['classification'] = decision.quality.name
      ..['baseClassification'] = decision.baseQuality.name
      ..['finalClassification'] = decision.quality.name
      ..['reasonCode'] = decision.reasonCode
      ..['classificationReasonCodes'] = decision.reasonCodes
      ..['classificationFailedGates'] = decision.failedGates
      ..['moverCpLoss'] = decision.moverCpLoss
      ..['deltaW'] = decision.deltaW
      ..['winPercentBefore'] = decision.winPercentBefore
      ..['winPercentAfter'] = decision.winPercentAfter
      ..['message'] = decision.message;
    moveJson['coachExplanation'] = 'Historic raw compatibility text.';
    final historicMove = MoveAnalysis.fromJson(moveJson);
    final historicTimeline = current.timeline.copyWith(
      moves: <MoveAnalysis>[historicMove],
      analysisSchemaVersion: kApexLegacyAnalysisSchemaVersion,
      explanationPolicyVersion: 0,
      explanationClaimSchemaVersion: 0,
      explanationRendererVersion: 0,
    );
    final historic = ReviewDocument.fromCompletedTimeline(
      pgn: _pgn,
      timeline: historicTimeline,
      sourceProvider: 'pgn',
      createdAt: DateTime.utc(2026, 7, 18),
      userIsWhite: true,
    );
    final reopened = ReviewDocument.decodeAndValidate(historic.encode());

    expect(
      reopened.variantId.algorithmVersion,
      kLegacyAnalysisVariantAlgorithmVersion,
    );
    expect(reopened.timeline.moves.single.insight, isNull);
    expect(
      reopened.timeline.moves.single.coachExplanation,
      'Historic raw compatibility text.',
    );
    final currentBytes = utf8.encode(current.encode()).length;
    final historicBytes = utf8.encode(historic.encode()).length;
    debugPrint(
      'CHAPTER6_STORAGE currentOnePlyBytes=$currentBytes '
      'historicOnePlyBytes=$historicBytes deltaBytes=${currentBytes - historicBytes}',
    );
  });

  test(
    'claim, confidence, square, reason, and rendered-copy tampering reject',
    () {
      final original = _document();
      final mutations = <void Function(Map<String, dynamic>)>[
        (root) => _insight(root)['state'] = 'suppressed',
        (root) => _claim(root)['type'] = 'deliversMate',
        (root) => _claim(root)['confidence'] = 'supported',
        (root) => (_facts(root).first as Map)['pieceRole'] = 'queen',
        (root) => (_facts(root).first as Map)['toSquare'] = 'd4',
        (root) => _claim(root)['reasonCode'] = 'invented_reason',
        (root) => _claim(root)['supportingFactIds'] = <String>['f_missing'],
        (root) => _claim(root)['betterMoveSan'] = 'd4',
        (root) => _claim(root)['mechanism'] = 'futureMechanism',
        (root) => _claim(root)['consequence'] = 'futureConsequence',
        (root) => _claim(root)['unsupportedCausalField'] = 'invented',
        (root) =>
            _insight(root)['facts'] = <Object?>[..._facts(root), 'not_a_fact'],
        (root) {
          _claim(root)['continuationUci'] = <String>['e2e4'];
          _claim(root)['continuationSan'] = <String>['e4'];
        },
        (root) =>
            _insight(root)['conciseText'] = 'This improves your position.',
        (root) => _insight(root)['rendererVersion'] = 4,
        (root) =>
            _insight(root)['integrityDigest'] = List.filled(64, '0').join(),
        (root) => _move(root)['analysisIntegrityDigest'] = List.filled(
          64,
          '0',
        ).join(),
        (root) => _move(root)['coachExplanation'] = 'Spoofed current prose.',
      ];

      for (final mutate in mutations) {
        final json = jsonDecode(original.encode()) as Map<String, dynamic>;
        mutate(json);
        expect(
          () => ReviewDocument.decodeAndValidate(jsonEncode(json)),
          throwsA(anything),
        );
      }
    },
  );

  test('recomputed artifact digest still rejects semantic opening drift', () {
    final original = _document();
    final move = original.timeline.moves.single;
    final spoofedInsight = testBookInsight(name: 'Invented Opening');
    final moveJson = move.toJson()..['insight'] = spoofedInsight.toJson();
    final resealedMove = MoveAnalysis.fromJson(
      moveJson,
    ).sealAnalysisIntegrity();
    final timeline = original.timeline.copyWith(
      moves: <MoveAnalysis>[resealedMove],
    );

    expect(
      () => ReviewDocument.fromCompletedTimeline(
        pgn: _pgn,
        timeline: timeline,
        sourceProvider: 'pgn',
        createdAt: DateTime.utc(2026, 7, 18),
        userIsWhite: true,
      ),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
  });

  test('resealed advanced-causality tampering is rejected semantically', () {
    final original = _forkDocument();
    final sourceMove = original.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    final mutations = <void Function(Map<String, dynamic>)>[
      (claim) => claim['mechanism'] = 'doubleAttack',
      (claim) => claim['consequence'] = 'materialLoss',
      (claim) => claim['pieceRole'] = 'bishop',
      (claim) => claim['pieceSquare'] = 'd3',
      (claim) => claim['targetRole'] = 'rook',
      (claim) => claim['targetSquare'] = 'a7',
      (claim) => claim['secondaryTargetRole'] = 'queen',
      (claim) => claim['secondaryTargetSquare'] = 'd8',
      (claim) => claim['relationType'] = 'removesDefense',
      (claim) => claim['confidence'] = 'supported',
      (claim) {
        final target = claim['targetRole'];
        final targetSquare = claim['targetSquare'];
        claim['targetRole'] = claim['secondaryTargetRole'];
        claim['targetSquare'] = claim['secondaryTargetSquare'];
        claim['secondaryTargetRole'] = target;
        claim['secondaryTargetSquare'] = targetSquare;
      },
      (claim) => claim['mechanismReasonCode'] = 'invented_fork_reason',
      (claim) => claim['initiatorSquare'] = 'c6',
      (claim) {
        claim['continuationUci'] = <String>['b5c7', 'e8f8', 'c7b5'];
        claim['continuationSan'] = <String>['Nc7+', 'Kf8', 'Nb5'];
      },
    ];

    for (final mutate in mutations) {
      final claimJson = Map<String, dynamic>.from(
        sourceInsight.primaryClaim!.toJson(),
      );
      mutate(claimJson);
      final claim = MoveInsightClaim.fromJson(claimJson);
      final rendered = const MoveInsightRenderer().render(claim);
      final tamperedInsight = MoveInsight.create(
        state: MoveInsightState.available,
        facts: sourceInsight.facts,
        primaryClaim: claim,
        causalChain: sourceInsight.causalChain,
        conciseText: rendered.concise,
        causeText: rendered.cause,
        consequenceText: rendered.consequence,
        betterMoveText: rendered.betterMove,
        continuationText: rendered.continuation,
      );
      final move = MoveAnalysis.fromJson(
        sourceMove.toJson()..['insight'] = tamperedInsight.toJson(),
      ).sealAnalysisIntegrity();

      expect(
        () => ReviewDocument.fromCompletedTimeline(
          pgn: _forkPgn,
          timeline: original.timeline.copyWith(moves: <MoveAnalysis>[move]),
          sourceProvider: 'pgn',
          createdAt: original.createdAt,
          userIsWhite: true,
        ),
        throwsA(isA<ReviewDocumentValidationException>()),
      );
    }
  });

  test('resealed causal fact perspective tampering is rejected', () {
    final original = _forkDocument();
    final sourceMove = original.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    final facts = sourceInsight.facts
        .map((fact) {
          if (fact.id != 'f_causal_fork') return fact;
          return MoveInsightFact.fromJson(
            fact.toJson()
              ..['pieceSide'] = 'black'
              ..['relatedPieceSide'] = 'white',
          );
        })
        .toList(growable: false);
    final claim = sourceInsight.primaryClaim!;
    final rendered = const MoveInsightRenderer().render(claim);
    final tamperedInsight = MoveInsight.create(
      state: MoveInsightState.available,
      facts: facts,
      primaryClaim: claim,
      causalChain: sourceInsight.causalChain,
      conciseText: rendered.concise,
      causeText: rendered.cause,
      consequenceText: rendered.consequence,
      betterMoveText: rendered.betterMove,
      continuationText: rendered.continuation,
    );
    final move = MoveAnalysis.fromJson(
      sourceMove.toJson()..['insight'] = tamperedInsight.toJson(),
    ).sealAnalysisIntegrity();

    expect(
      () => ReviewDocument.fromCompletedTimeline(
        pgn: _forkPgn,
        timeline: original.timeline.copyWith(moves: <MoveAnalysis>[move]),
        sourceProvider: 'pgn',
        createdAt: original.createdAt,
        userIsWhite: true,
      ),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
  });

  test('resealed pin line geometry tampering is rejected semantically', () {
    final original = _causalDocument(
      _causalInput(
        fen: '4k3/7p/2r5/8/8/8/4B3/4K3 w - - 0 1',
        uci: 'e2b5',
        postMoves: const <String>['h7h6', 'b5c6', 'e8f8'],
        scoreCp: 500,
      ),
    );
    final sourceMove = original.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    final claimJson = sourceInsight.primaryClaim!.toJson()
      ..['lineType'] = 'rank'
      ..['lineSquares'] = <String>['b5', 'c5', 'd5', 'e5'];
    final claim = MoveInsightClaim.fromJson(claimJson);
    final facts = sourceInsight.facts
        .map(
          (fact) => fact.id == 'f_causal_absolutepin'
              ? MoveInsightFact.fromJson(
                  fact.toJson()
                    ..['lineType'] = 'rank'
                    ..['lineSquares'] = <String>['b5', 'c5', 'd5', 'e5'],
                )
              : fact,
        )
        .toList(growable: false);

    expect(
      () => _rebuildCausal(original, sourceMove, claim, facts),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
  });

  test('resealed defender identity tampering is rejected semantically', () {
    final original = _causalDocument(
      _causalInput(
        fen: '6k1/8/8/3n4/2B2r2/4Q3/8/4K3 w - - 0 1',
        uci: 'c4d5',
        postMoves: const <String>['g8h8', 'e3f4', 'h8g7'],
        scoreCp: 800,
      ),
    );
    final sourceMove = original.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    final claimJson = sourceInsight.primaryClaim!.toJson()
      ..['defenderRole'] = 'bishop'
      ..['defenderSquare'] = 'c6';
    final claim = MoveInsightClaim.fromJson(claimJson);
    final facts = sourceInsight.facts
        .map(
          (fact) => fact.id == 'f_causal_removesdefender'
              ? MoveInsightFact.fromJson(
                  fact.toJson()
                    ..['secondaryPieceRole'] = 'bishop'
                    ..['secondarySquare'] = 'c6',
                )
              : fact,
        )
        .toList(growable: false);

    expect(
      () => _rebuildCausal(original, sourceMove, claim, facts),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
  });

  test('resealed unexpected claim payload is rejected before persistence', () {
    final original = _document();
    final sourceMove = original.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    final mutations = <void Function(Map<String, dynamic>)>[
      (claim) => claim['betterMoveSan'] = 'd4',
      (claim) {
        claim['initiatorRole'] = 'pawn';
        claim['initiatorSquare'] = 'e4';
        claim['relationType'] = 'attacks';
      },
      (claim) {
        claim['continuationUci'] = <String>['e2e4'];
        claim['continuationSan'] = <String>['e4'];
      },
    ];

    for (final mutate in mutations) {
      final claimJson = Map<String, dynamic>.from(
        sourceInsight.primaryClaim!.toJson(),
      );
      mutate(claimJson);
      final claim = MoveInsightClaim.fromJson(claimJson);
      final rendered = const MoveInsightRenderer().render(claim);
      final spoofed = MoveInsight.create(
        state: MoveInsightState.available,
        facts: sourceInsight.facts,
        primaryClaim: claim,
        causalChain: sourceInsight.causalChain,
        conciseText: rendered.concise,
        causeText: rendered.cause,
        consequenceText: rendered.consequence,
        betterMoveText: rendered.betterMove,
        continuationText: rendered.continuation,
      );
      final resealedMove = MoveAnalysis.fromJson(
        sourceMove.toJson()..['insight'] = spoofed.toJson(),
      ).sealAnalysisIntegrity();

      expect(
        () => _rebuild(original, resealedMove),
        throwsA(isA<ReviewDocumentValidationException>()),
      );
    }
  });

  test('same-variant replacement rejects missing or conflicting insight', () {
    final verified = _document();
    final move = verified.timeline.moves.single;
    final suppressed = MoveInsight.create(
      state: MoveInsightState.suppressed,
      suppressionReason: 'no_high_signal_verified_claim',
    );
    final weakerMove = MoveAnalysis.fromJson(
      move.toJson()..['insight'] = suppressed.toJson(),
    ).sealAnalysisIntegrity();
    final weaker = _rebuild(verified, weakerMove);
    final conflictingMove = MoveAnalysis.fromJson(
      move.toJson()..['insight'] = testBookInsight(name: 'Other Name').toJson(),
    ).sealAnalysisIntegrity();

    expect(weaker.hasEqualOrStrongerEvidenceThan(verified), isFalse);
    expect(
      () => _rebuild(verified, conflictingMove),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
    expect(verified.hasEqualOrStrongerEvidenceThan(verified), isTrue);
  });

  test(
    'Hive restart exact reopen performs zero detector and planner work',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'apex_chapter6_reopen_',
      );
      addTearDown(() async {
        await Hive.close();
        await directory.delete(recursive: true);
      });
      Hive.init(directory.path);
      final causality = _CountingCausalityAnalyzer();
      final extractor = _CountingExtractor(causality);
      final detector = _CountingDetector();
      final planner = _CountingPlanner();
      final renderer = _CountingRenderer();
      final engine = MoveInsightEngine(
        extractor: extractor,
        detector: detector,
        planner: planner,
        renderer: renderer,
      );
      final generated = engine.generate(_bookInput());
      final document = _document(insight: generated);
      var repository = await ArchiveRepository.open();
      await repository.saveReviewDocument(document);
      expect(extractor.calls, 1);
      expect(causality.calls, 1);
      expect(detector.calls, 1);
      expect(planner.calls, 1);
      expect(renderer.calls, 1);

      await Hive.close();
      Hive.init(directory.path);
      repository = await ArchiveRepository.open();
      final watch = Stopwatch()..start();
      final archived = repository.find(document.documentId);
      watch.stop();
      expect(archived, isNotNull);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final opened = container
          .read(reviewControllerProvider.notifier)
          .openSavedReview(archived!, source: ReviewRuntimeSource.archiveExact);
      expect(opened, isTrue);
      final notifier = container.read(reviewControllerProvider.notifier);
      notifier.goToStart();
      notifier.next();
      expect(extractor.calls, 1);
      expect(causality.calls, 1);
      expect(detector.calls, 1);
      expect(planner.calls, 1);
      expect(renderer.calls, 1);
      expect(
        container
            .read(reviewControllerProvider)
            .timeline!
            .moves
            .single
            .insight!
            .integrityDigest,
        generated.integrityDigest,
      );
      // The stored-current path returns before the historic classifier replay;
      // no analyzer or opening lookup object participates in this call graph.
      debugPrint(
        'CHAPTER7_REOPEN_PERF latencyUs=${watch.elapsedMicroseconds} '
        'engineCalls=0 classifierCalls=0 openingLookups=0 '
        'featureExtractionsAfterReopen=${extractor.calls - 1} '
        'causalityCallsAfterReopen=${causality.calls - 1} '
        'detectorCallsAfterReopen=${detector.calls - 1} '
        'plannerCallsAfterReopen=${planner.calls - 1} '
        'rendererCallsAfterReopen=${renderer.calls - 1}',
      );
    },
  );
}

ReviewDocument _document({MoveInsight? insight}) {
  final opening = _openingEvidence();
  final classificationEvidence = MoveClassificationEvidence(
    mover: ClassificationMover.white,
    evaluationBefore: const ClassificationScore.cp(0),
    playedMoveEvaluation: const ClassificationScore.cp(20),
    bestMoveEvaluation: const ClassificationScore.cp(20),
    playedMoveUci: 'e2e4',
    bestMoveUci: 'e2e4',
    searchQualityMet: true,
    bookState: ClassificationBookState.verified,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
  );
  final move = MoveAnalysis(
    ply: 0,
    san: 'e4',
    uci: 'e2e4',
    fenBefore: _startFen,
    fenAfter: _afterE4,
    targetSquare: 'e4',
    winPercentBefore: 50,
    winPercentAfter: 52,
    deltaW: 2,
    isWhiteMove: true,
    classification: MoveQuality.book,
    baseClassification: MoveQuality.book,
    finalClassification: MoveQuality.book,
    reasonCode: 'verified_book_transition',
    classificationEvidence: classificationEvidence,
    openingEvidence: opening,
    classificationReasonCodes: const <String>['verified_book_transition'],
    playedEqualsPv1: true,
    engineEvaluationAvailable: true,
    requestedDepth: 14,
    achievedDepthBefore: 14,
    achievedDepthAfter: 14,
    multiPvReceived: 0,
    searchQualityMet: true,
    scoreCpAfter: 20,
    inBook: true,
    openingStatus: OpeningStatus.bookTheory,
    openingName: "King's Pawn Game",
    ecoCode: 'B00',
    message: "B00 • King's Pawn Game",
    coachExplanation: '',
    insight: insight ?? testBookInsight(),
    analysisMode: 'quick',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
  ).sealAnalysisIntegrity();
  final timeline = AnalysisTimeline(
    moves: <MoveAnalysis>[move],
    startingFen: _startFen,
    headers: const <String, String>{'White': 'Apex', 'Black': 'Test'},
    winPercentages: const <double>[52],
    analysisMode: 'quick',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
    providerId: 'local_offline',
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    openingArtifact: kApexOpeningArtifactIdentity,
    openingArtifactVerification: OpeningArtifactVerification.verified,
    explanationPolicyVersion: kApexExplanationPolicyVersion,
    explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
    explanationRendererVersion: kApexExplanationRendererVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    depth: 14,
    requestedDepth: 14,
    movetimeMs: 900,
    multipv: 1,
    completedAt: DateTime.utc(2026, 7, 18),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
    engineSearchCount: 2,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: _pgn,
    timeline: timeline,
    sourceProvider: 'pgn',
    createdAt: DateTime.utc(2026, 7, 18),
    userIsWhite: true,
  );
}

MoveInsightInput _bookInput() {
  final opening = _openingEvidence();
  final evidence = MoveClassificationEvidence(
    mover: ClassificationMover.white,
    evaluationBefore: const ClassificationScore.cp(0),
    playedMoveEvaluation: const ClassificationScore.cp(20),
    bestMoveEvaluation: const ClassificationScore.cp(20),
    playedMoveUci: 'e2e4',
    bestMoveUci: 'e2e4',
    searchQualityMet: true,
    bookState: ClassificationBookState.verified,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
  );
  return MoveInsightInput(
    fenBefore: _startFen,
    fenAfter: _afterE4,
    playedMoveUci: 'e2e4',
    playedMoveSan: 'e4',
    isWhiteMove: true,
    classification: MoveQuality.book,
    classificationEvidence: evidence,
    preMoveLines: const [],
    postMoveLines: const [],
    postMoveSearchQualityMet: true,
    engineBestMoveSan: 'e4',
    openingEvidence: opening,
  );
}

ReviewDocument _forkDocument() {
  final input = _forkInput();
  final insight = const MoveInsightEngine().generate(input);
  final move = MoveAnalysis(
    ply: 0,
    san: input.playedMoveSan,
    uci: input.playedMoveUci,
    fenBefore: input.fenBefore,
    fenAfter: input.fenAfter,
    targetSquare: 'c7',
    winPercentBefore: 50,
    winPercentAfter: 90,
    deltaW: 40,
    isWhiteMove: true,
    classification: MoveQuality.best,
    baseClassification: MoveQuality.best,
    finalClassification: MoveQuality.best,
    reasonCode: 'best_move',
    classificationEvidence: input.classificationEvidence,
    openingEvidence: input.openingEvidence,
    classificationReasonCodes: const <String>['best_move'],
    playedEqualsPv1: true,
    engineEvaluationAvailable: true,
    engineBestMoveSan: input.playedMoveSan,
    engineBestMoveUci: input.playedMoveUci,
    requestedDepth: 20,
    achievedDepthBefore: 20,
    achievedDepthAfter: 20,
    multiPvReceived: 0,
    searchQualityMet: true,
    scoreCpAfter: 700,
    openingStatus: OpeningStatus.notOpening,
    message: 'Best move.',
    coachExplanation: '',
    insight: insight,
    analysisMode: 'deep',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
  ).sealAnalysisIntegrity();
  final timeline = AnalysisTimeline(
    moves: <MoveAnalysis>[move],
    startingFen: input.fenBefore,
    headers: const <String, String>{'White': 'Apex', 'Black': 'Test'},
    winPercentages: const <double>[90],
    analysisMode: 'deep',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
    providerId: 'local_offline',
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    openingArtifact: kApexOpeningArtifactIdentity,
    openingArtifactVerification: OpeningArtifactVerification.verified,
    explanationPolicyVersion: kApexExplanationPolicyVersion,
    explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
    explanationRendererVersion: kApexExplanationRendererVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    depth: 20,
    requestedDepth: 20,
    movetimeMs: 1200,
    multipv: 1,
    completedAt: DateTime.utc(2026, 7, 23),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
    engineSearchCount: 2,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: _forkPgn,
    timeline: timeline,
    sourceProvider: 'pgn',
    createdAt: DateTime.utc(2026, 7, 23),
    userIsWhite: true,
  );
}

ReviewDocument _causalDocument(MoveInsightInput input) {
  final insight = const MoveInsightEngine().generate(input);
  final move = MoveAnalysis(
    ply: 0,
    san: input.playedMoveSan,
    uci: input.playedMoveUci,
    fenBefore: input.fenBefore,
    fenAfter: input.fenAfter,
    targetSquare: input.playedMoveUci.substring(2, 4),
    winPercentBefore: 50,
    winPercentAfter: 90,
    deltaW: 40,
    isWhiteMove: input.isWhiteMove,
    classification: MoveQuality.best,
    baseClassification: MoveQuality.best,
    finalClassification: MoveQuality.best,
    reasonCode: 'best_move',
    classificationEvidence: input.classificationEvidence,
    openingEvidence: input.openingEvidence,
    classificationReasonCodes: const <String>['best_move'],
    playedEqualsPv1: true,
    engineEvaluationAvailable: true,
    engineBestMoveSan: input.playedMoveSan,
    engineBestMoveUci: input.playedMoveUci,
    requestedDepth: 20,
    achievedDepthBefore: 20,
    achievedDepthAfter: 20,
    multiPvReceived: 0,
    searchQualityMet: true,
    scoreCpAfter: input.classificationEvidence.playedMoveEvaluation?.whiteCp,
    openingStatus: OpeningStatus.notOpening,
    message: 'Best move.',
    coachExplanation: '',
    insight: insight,
    analysisMode: 'deep',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
  ).sealAnalysisIntegrity();
  final timeline = AnalysisTimeline(
    moves: <MoveAnalysis>[move],
    startingFen: input.fenBefore,
    headers: const <String, String>{'White': 'Apex', 'Black': 'Test'},
    winPercentages: const <double>[90],
    analysisMode: 'deep',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
    providerId: 'local_offline',
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    openingArtifact: kApexOpeningArtifactIdentity,
    openingArtifactVerification: OpeningArtifactVerification.verified,
    explanationPolicyVersion: kApexExplanationPolicyVersion,
    explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
    explanationRendererVersion: kApexExplanationRendererVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    depth: 20,
    requestedDepth: 20,
    movetimeMs: 1200,
    multipv: 1,
    completedAt: DateTime.utc(2026, 7, 23),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
    engineSearchCount: 2,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn:
        '[SetUp "1"]\n'
        '[FEN "${input.fenBefore}"]\n'
        '[Result "*"]\n\n'
        '1. ${input.playedMoveSan} *',
    timeline: timeline,
    sourceProvider: 'pgn',
    createdAt: DateTime.utc(2026, 7, 23),
    userIsWhite: input.isWhiteMove,
  );
}

MoveInsightInput _causalInput({
  required String fen,
  required String uci,
  required List<String> postMoves,
  required int scoreCp,
}) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final move = _legalMove(position, uci);
  final after = position.play(move);
  final san = position.makeSan(move).$2;
  final evidence = MoveClassificationEvidence(
    mover: position.turn == Side.white
        ? ClassificationMover.white
        : ClassificationMover.black,
    evaluationBefore: const ClassificationScore.cp(0),
    playedMoveEvaluation: ClassificationScore.cp(scoreCp),
    bestMoveEvaluation: ClassificationScore.cp(scoreCp),
    playedMoveUci: uci,
    bestMoveUci: uci,
    searchQualityMet: true,
    bookState: ClassificationBookState.notBook,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
  );
  return MoveInsightInput(
    fenBefore: fen,
    fenAfter: after.fen,
    playedMoveUci: uci,
    playedMoveSan: san,
    isWhiteMove: position.turn == Side.white,
    classification: MoveQuality.best,
    classificationEvidence: evidence,
    preMoveLines: const <EngineLine>[],
    postMoveLines: <EngineLine>[_engineLine(after.fen, postMoves, cp: scoreCp)],
    postMoveSearchQualityMet: true,
    engineBestMoveSan: san,
    openingEvidence: _noOpening(fen, after.fen, uci),
  );
}

MoveInsightInput _forkInput() {
  const fen = 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1';
  const uci = 'b5c7';
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final move = _legalMove(position, uci);
  final after = position.play(move);
  final post = _engineLine(after.fen, const <String>[
    'e8f8',
    'c7a8',
    'f8g8',
  ], cp: 700);
  final evidence = MoveClassificationEvidence(
    mover: ClassificationMover.white,
    evaluationBefore: const ClassificationScore.cp(0),
    playedMoveEvaluation: const ClassificationScore.cp(700),
    bestMoveEvaluation: const ClassificationScore.cp(700),
    playedMoveUci: uci,
    bestMoveUci: uci,
    searchQualityMet: true,
    bookState: ClassificationBookState.notBook,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
  );
  return MoveInsightInput(
    fenBefore: fen,
    fenAfter: after.fen,
    playedMoveUci: uci,
    playedMoveSan: position.makeSan(move).$2,
    isWhiteMove: true,
    classification: MoveQuality.best,
    classificationEvidence: evidence,
    preMoveLines: const <EngineLine>[],
    postMoveLines: <EngineLine>[post],
    postMoveSearchQualityMet: true,
    engineBestMoveSan: position.makeSan(move).$2,
    openingEvidence: _noOpening(fen, after.fen, uci),
  );
}

EngineLine _engineLine(String fen, List<String> moves, {int? cp, int? mate}) {
  Position position = Chess.fromSetup(Setup.parseFen(fen));
  final first = _legalMove(position, moves.first);
  final firstSan = position.makeSan(first).$2;
  for (final uci in moves) {
    position = position.play(_legalMove(position, uci));
  }
  return EngineLine(
    rank: 1,
    moveUci: moves.first,
    moveSan: firstSan,
    scoreCp: cp,
    mateIn: mate,
    depth: 20,
    whiteWinPercent: mate == null ? 90 : (mate > 0 ? 100 : 0),
    pvMoves: moves,
  );
}

NormalMove _legalMove(Position position, String uci) {
  final from = Square(uci.codeUnitAt(0) - 97 + (uci.codeUnitAt(1) - 49) * 8);
  final to = Square(uci.codeUnitAt(2) - 97 + (uci.codeUnitAt(3) - 49) * 8);
  final move = NormalMove(from: from, to: to);
  if (!position.isLegal(move)) {
    throw StateError('$uci must be legal in ${position.fen}');
  }
  return move;
}

OpeningEvidence _noOpening(String before, String after, String uci) =>
    OpeningEvidence(
      artifact: kApexOpeningArtifactIdentity,
      artifactVerification: OpeningArtifactVerification.verified,
      state: OpeningMatchState.noMatch,
      beforePositionKey: OpeningPositionKey.fromFen(before).value,
      afterPositionKey: OpeningPositionKey.fromFen(after).value,
      playedUci: uci,
      transitionVerified: false,
      totalCandidateCount: 0,
      matchedPly: 1,
      reasonCode: 'position_and_transition_not_found',
    );

class _CountingExtractor extends MoveInsightFeatureExtractor {
  _CountingExtractor(MoveInsightCausalityAnalyzer causality)
    : super(causalityAnalyzer: causality);

  int calls = 0;

  @override
  MoveInsightFeatures extract(MoveInsightInput input) {
    calls++;
    return super.extract(input);
  }
}

class _CountingCausalityAnalyzer extends MoveInsightCausalityAnalyzer {
  int calls = 0;

  @override
  List<MoveInsightCausalProof> analyze({
    required MoveInsightInput input,
    required Position before,
    required Position after,
    required NormalMove playedMove,
    required Side moverSide,
    required String movingRole,
    required MoveInsightLineTrace? playedTrace,
    required MoveInsightLineTrace? bestTrace,
  }) {
    calls++;
    return super.analyze(
      input: input,
      before: before,
      after: after,
      playedMove: playedMove,
      moverSide: moverSide,
      movingRole: movingRole,
      playedTrace: playedTrace,
      bestTrace: bestTrace,
    );
  }
}

class _CountingDetector extends MoveInsightClaimDetector {
  int calls = 0;

  @override
  List<MoveInsightClaimCandidate> detect(
    MoveInsightInput input,
    MoveInsightFeatures features,
  ) {
    calls++;
    return super.detect(input, features);
  }
}

class _CountingPlanner extends MoveInsightPlanner {
  int calls = 0;

  @override
  MoveInsightPlan? select(List<MoveInsightClaimCandidate> candidates) {
    calls++;
    return super.select(candidates);
  }
}

class _CountingRenderer extends MoveInsightRenderer {
  int calls = 0;

  @override
  MoveInsightRenderedCopy render(MoveInsightClaim claim) {
    calls++;
    return super.render(claim);
  }
}

ReviewDocument _rebuild(ReviewDocument source, MoveAnalysis move) =>
    ReviewDocument.fromCompletedTimeline(
      pgn: _pgn,
      timeline: source.timeline.copyWith(moves: <MoveAnalysis>[move]),
      sourceProvider: 'pgn',
      createdAt: source.createdAt,
      userIsWhite: true,
    );

ReviewDocument _rebuildCausal(
  ReviewDocument source,
  MoveAnalysis sourceMove,
  MoveInsightClaim claim,
  List<MoveInsightFact> facts,
) {
  final rendered = const MoveInsightRenderer().render(claim);
  final tamperedInsight = MoveInsight.create(
    state: MoveInsightState.available,
    facts: facts,
    primaryClaim: claim,
    causalChain: sourceMove.insight!.causalChain,
    conciseText: rendered.concise,
    causeText: rendered.cause,
    consequenceText: rendered.consequence,
    betterMoveText: rendered.betterMove,
    continuationText: rendered.continuation,
  );
  final move = MoveAnalysis.fromJson(
    sourceMove.toJson()..['insight'] = tamperedInsight.toJson(),
  ).sealAnalysisIntegrity();
  return ReviewDocument.fromCompletedTimeline(
    pgn: source.game.originalPgn,
    timeline: source.timeline.copyWith(moves: <MoveAnalysis>[move]),
    sourceProvider: 'pgn',
    createdAt: source.createdAt,
    userIsWhite: source.userIsWhite,
  );
}

OpeningEvidence _openingEvidence() {
  const candidate = OpeningCandidate(
    ecoCode: 'B00',
    openingName: "King's Pawn Game",
    sourceLineId:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    sourceTerminalPly: 1,
    matchedPly: 1,
    exactPositionName: true,
  );
  return OpeningEvidence(
    artifact: kApexOpeningArtifactIdentity,
    artifactVerification: OpeningArtifactVerification.verified,
    state: OpeningMatchState.knownTransition,
    beforePositionKey: OpeningPositionKey.fromFen(_startFen).value,
    afterPositionKey: OpeningPositionKey.fromFen(_afterE4).value,
    playedUci: 'e2e4',
    transitionVerified: true,
    selectedCandidate: candidate,
    totalCandidateCount: 1,
    matchedPly: 1,
    reasonCode: 'verified_known_transition',
  );
}

Map<String, dynamic> _move(Map<String, dynamic> root) =>
    (((root['timeline'] as Map)['moves'] as List).single as Map)
        .cast<String, dynamic>();

Map<String, dynamic> _insight(Map<String, dynamic> root) =>
    (_move(root)['insight'] as Map).cast<String, dynamic>();

Map<String, dynamic> _claim(Map<String, dynamic> root) =>
    (_insight(root)['primaryClaim'] as Map).cast<String, dynamic>();

List<dynamic> _facts(Map<String, dynamic> root) =>
    _insight(root)['facts'] as List<dynamic>;

const _pgn = '1. e4 *';
const _forkPgn = '''
[SetUp "1"]
[FEN "q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1"]
[Result "*"]

1. Nc7+ *
''';
const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _afterE4 = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
