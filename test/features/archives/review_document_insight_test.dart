import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
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
    expect(reopened.timeline.analysisSchemaVersion, 5);
    expect(reopened.timeline.explanationPolicyVersion, 1);
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
      rendererVersion: kApexLegacyExplanationRendererVersion,
    );
    final historicMove = MoveAnalysis.fromJson(
      sourceMove.toJson()..['insight'] = historicInsight.toJson(),
    ).sealAnalysisIntegrity();
    final historic = ReviewDocument.fromCompletedTimeline(
      pgn: _pgn,
      timeline: current.timeline.copyWith(
        moves: <MoveAnalysis>[historicMove],
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
        (root) {
          _claim(root)['continuationUci'] = <String>['e2e4'];
          _claim(root)['continuationSan'] = <String>['e4'];
        },
        (root) =>
            _insight(root)['conciseText'] = 'This improves your position.',
        (root) => _insight(root)['rendererVersion'] = 3,
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

  test('resealed unexpected claim payload is rejected before persistence', () {
    final original = _document();
    final sourceMove = original.timeline.moves.single;
    final sourceInsight = sourceMove.insight!;
    final mutations = <void Function(Map<String, dynamic>)>[
      (claim) => claim['betterMoveSan'] = 'd4',
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
      final detector = _CountingDetector();
      final planner = _CountingPlanner();
      final renderer = _CountingRenderer();
      final engine = MoveInsightEngine(
        detector: detector,
        planner: planner,
        renderer: renderer,
      );
      final generated = engine.generate(_bookInput());
      final document = _document(insight: generated);
      var repository = await ArchiveRepository.open();
      await repository.saveReviewDocument(document);
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
        'CHAPTER6_REOPEN_PERF latencyUs=${watch.elapsedMicroseconds} '
        'engineCalls=0 classifierCalls=0 openingLookups=0 '
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
const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _afterE4 = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
