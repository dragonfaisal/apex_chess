import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';

void main() {
  test('complete document round-trips exact chess and provenance evidence', () {
    final document = _document(userIsWhite: false);
    final roundTrip = ReviewDocument.decodeAndValidate(document.encode());

    expect(roundTrip.documentId, document.documentId);
    expect(roundTrip.game.gameId.value, document.game.gameId.value);
    expect(roundTrip.variantId.value, document.variantId.value);
    expect(roundTrip.analyzedPerspective, AnalyzedPlayerPerspective.black);
    expect(roundTrip.userIsWhite, isFalse);
    expect(roundTrip.timeline.moves.first.scoreCpAfter, 24);
    expect(roundTrip.timeline.moves.last.mateInAfter, 5);
    expect(roundTrip.cpLossEligibleCount, 3);
    expect(roundTrip.verifiedAcpl, closeTo(20 / 3, 0.001));
    expect(roundTrip.classificationCounts[MoveQuality.best], 2);
    expect(roundTrip.classificationCounts[MoveQuality.inaccuracy], 1);
    expect(roundTrip.compatibility.engine.engineName, 'Stockfish');
    expect(roundTrip.compatibility.engine.engineVersion, '17');
    expect(
      roundTrip.compatibility.engine.bridgeIdentity,
      'apex-stockfish-bridge/0.3.0',
    );
    expect(
      roundTrip.compatibility.engine.configuredNnueIdentity,
      'nn-37f18f62d772.nnue',
    );
    expect(
      roundTrip.compatibility.engine.nnueVerification,
      ProvenanceVerification.configuredOnly,
    );
  });

  test('unknown perspective remains unknown after roundtrip', () {
    final roundTrip = ReviewDocument.decodeAndValidate(_document().encode());
    expect(roundTrip.analyzedPerspective, AnalyzedPlayerPerspective.unknown);
    expect(roundTrip.userIsWhite, isNull);
  });

  test('schema v4 decision is reproducible and tampering is rejected', () {
    final document = _v4Document();
    final roundTrip = ReviewDocument.decodeAndValidate(document.encode());

    expect(roundTrip.timeline.moves.single.classificationEvidence, isNotNull);
    expect(roundTrip.timeline.moves.single.classification, MoveQuality.best);
    expect(roundTrip.timeline.moves.single.reasonCode, 'pv1_best');

    final json = document.toJson();
    final timelineJson = json['timeline'] as Map<String, dynamic>;
    final movesJson = timelineJson['moves'] as List<dynamic>;
    (movesJson.single as Map<String, dynamic>)['classificationReasonCodes'] = [
      'tampered_reason',
    ];
    expect(
      () => ReviewDocument.decodeAndValidate(_encode(json)),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
  });

  test('schema v4 rejects label, CP-loss, and evidence tampering', () {
    final document = _v4Document();

    void expectTamperRejected(void Function(Map<String, dynamic> move) tamper) {
      final json = jsonDecode(document.encode()) as Map<String, dynamic>;
      final timeline = json['timeline'] as Map<String, dynamic>;
      final moves = timeline['moves'] as List<dynamic>;
      final move = moves.single as Map<String, dynamic>;
      tamper(move);
      expect(
        () => ReviewDocument.decodeAndValidate(_encode(json)),
        throwsA(isA<ReviewDocumentValidationException>()),
      );
    }

    expectTamperRejected((move) => move['classification'] = 'great');
    expectTamperRejected((move) => move['moverCpLoss'] = 999);
    expectTamperRejected((move) {
      final evidence = move['classificationEvidence'] as Map<String, dynamic>;
      final before = evidence['evaluationBefore'] as Map<String, dynamic>;
      before['whiteCp'] = 300;
    });
  });

  test('opening-v2 evidence and exact artifact round-trip', () {
    final document = _v4Document(openingV2: true);
    final roundTrip = ReviewDocument.decodeAndValidate(document.encode());
    final move = roundTrip.timeline.moves.single;

    expect(roundTrip.compatibility.openingBookVersion, 2);
    expect(
      roundTrip.compatibility.openingArtifact?.semanticId,
      _artifact.semanticId,
    );
    expect(
      roundTrip.timeline.openingArtifactVerification,
      OpeningArtifactVerification.verified,
    );
    expect(move.openingEvidence?.state, OpeningMatchState.knownTransition);
    expect(move.openingEvidence?.selectedCandidate?.openingName, 'King Pawn');
    expect(move.classification, MoveQuality.book);
  });

  test('opening-v2 rejects evidence, mirror, and verification tampering', () {
    final document = _v4Document(openingV2: true);

    void expectTamperRejected(void Function(Map<String, dynamic> json) tamper) {
      final json = jsonDecode(document.encode()) as Map<String, dynamic>;
      tamper(json);
      expect(
        () => ReviewDocument.decodeAndValidate(_encode(json)),
        throwsA(isA<Object>()),
      );
    }

    expectTamperRejected((json) {
      final timeline = json['timeline'] as Map<String, dynamic>;
      final move =
          (timeline['moves'] as List<dynamic>).single as Map<String, dynamic>;
      move['openingName'] = 'Tampered Opening';
    });
    expectTamperRejected((json) {
      final timeline = json['timeline'] as Map<String, dynamic>;
      timeline['openingArtifactVerification'] = 'unavailable';
    });
    expectTamperRejected((json) {
      final timeline = json['timeline'] as Map<String, dynamic>;
      final move =
          (timeline['moves'] as List<dynamic>).single as Map<String, dynamic>;
      final evidence = move['openingEvidence'] as Map<String, dynamic>;
      evidence['reasonCode'] = 'tampered_reason';
    });
  });

  test('severe verified transition remains Blunder and ACPL-eligible', () {
    final document = _v4Document(openingV2: true, playedCp: -400);
    final roundTrip = ReviewDocument.decodeAndValidate(document.encode());
    final move = roundTrip.timeline.moves.single;

    expect(move.openingEvidence?.isVerifiedBookTransition, isTrue);
    expect(
      move.classificationEvidence?.bookState,
      ClassificationBookState.verified,
    );
    expect(move.classification, MoveQuality.blunder);
    expect(move.inBook, isFalse);
    expect(move.openingStatus, OpeningStatus.bookTheory);
    expect(roundTrip.cpLossEligibleCount, 1);
    expect(roundTrip.timeline.cpLossEligibleCountWhite, 1);
    expect(roundTrip.bookCount, 0);
    expect(roundTrip.unavailableCount, 0);
  });

  test('verified artifact may persist a weak per-move lookup failure', () {
    final lookupFailed = _v4Document(openingV2: true, lookupUnavailable: true);
    final roundTrip = ReviewDocument.decodeAndValidate(lookupFailed.encode());
    final move = roundTrip.timeline.moves.single;

    expect(
      roundTrip.timeline.openingArtifactVerification,
      OpeningArtifactVerification.verified,
    );
    expect(
      move.openingEvidence?.artifactVerification,
      OpeningArtifactVerification.verified,
    );
    expect(move.openingEvidence?.state, OpeningMatchState.unavailable);
    expect(
      move.classificationEvidence?.bookState,
      ClassificationBookState.unavailable,
    );
    expect(move.openingEvidence?.transitionVerified, isFalse);

    final completeLookup = _v4Document(openingV2: true);
    expect(
      lookupFailed.hasEqualOrStrongerEvidenceThan(completeLookup),
      isFalse,
    );
    expect(completeLookup.hasEqualOrStrongerEvidenceThan(lookupFailed), isTrue);
  });

  test('invalid FEN continuity and invalid variant identity are rejected', () {
    final valid = _document();
    final brokenTimeline = valid.timeline.copyWith(
      moves: [
        valid.timeline.moves.first,
        valid.timeline.moves[1],
        MoveAnalysis.fromJson({
          ...valid.timeline.moves.last.toJson(),
          'fenBefore': valid.timeline.startingFen,
        }),
      ],
    );
    expect(
      () => ReviewDocument.fromCompletedTimeline(
        pgn: _pgn,
        timeline: brokenTimeline,
        sourceProvider: 'pgn',
      ),
      throwsA(isA<ReviewDocumentValidationException>()),
    );

    final json = valid.toJson();
    (json['variantId'] as Map)['value'] =
        '0000000000000000000000000000000000000000000000000000000000000000';
    expect(
      () => ReviewDocument.decodeAndValidate(
        // jsonEncode is deliberately deferred to this helper to keep the
        // malformed object readable in the test.
        _encode(json),
      ),
      throwsA(isA<ReviewDocumentValidationException>()),
    );
  });
}

String _encode(Map<String, dynamic> value) {
  // ReviewDocument uses JSON as its durable Hive representation.
  return const JsonEncoder().convert(value);
}

ReviewDocument _document({bool? userIsWhite}) {
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: _pgn,
    sourceProvider: 'pgn',
  );
  final moves = <MoveAnalysis>[];
  for (var index = 0; index < game.moves.length; index++) {
    final move = game.moves[index];
    moves.add(
      MoveAnalysis(
        ply: index,
        san: move.san,
        uci: move.uci,
        fenBefore: move.fenBefore,
        fenAfter: move.fenAfter,
        targetSquare: move.uci.substring(2, 4),
        winPercentBefore: 50 + index.toDouble(),
        winPercentAfter: 51 + index.toDouble(),
        deltaW: 1,
        isWhiteMove: index.isEven,
        classification: index == 1 ? MoveQuality.inaccuracy : MoveQuality.best,
        moverCpLoss: index == 1 ? 20 : 0,
        requestedDepth: 14,
        achievedDepthBefore: 14,
        achievedDepthAfter: 14,
        multiPvReceived: 1,
        searchQualityMet: true,
        scoreCpAfter: index == 0 ? 24 : null,
        mateInAfter: index == 2 ? 5 : null,
        message: 'evidence',
        analysisMode: 'quick',
        classifierVersion: 5,
        engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
      ),
    );
  }
  final timeline = AnalysisTimeline(
    startingFen: game.startingFen,
    moves: moves,
    headers: game.headers,
    winPercentages: const [51, 52, 53],
    analysisMode: 'quick',
    analysisProfileId: 'fast_review',
    providerId: 'local_offline',
    engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
    classifierVersion: 5,
    analysisSchemaVersion: 3,
    requestedDepth: 14,
    depth: 14,
    movetimeMs: 900,
    multipv: 1,
    completedAt: DateTime.utc(2026, 7, 11),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: moves.length,
    engineSearchCount: 4,
    engineCacheHitCount: 2,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: _pgn,
    timeline: timeline,
    sourceProvider: 'pgn',
    userIsWhite: userIsWhite,
    createdAt: DateTime.utc(2026, 7, 11),
  );
}

ReviewDocument _v4Document({
  bool openingV2 = false,
  bool lookupUnavailable = false,
  int playedCp = 0,
}) {
  const pgn = '[White "Alpha"]\n[Black "Beta"]\n[Result "*"]\n\n1. e4 *';
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: pgn,
    sourceProvider: 'pgn',
  );
  final canonical = game.moves.single;
  final openingEvidence = openingV2
      ? OpeningEvidence(
          artifact: _artifact,
          artifactVerification: OpeningArtifactVerification.verified,
          state: lookupUnavailable
              ? OpeningMatchState.unavailable
              : OpeningMatchState.knownTransition,
          beforePositionKey: OpeningPositionKey.fromFen(
            canonical.fenBefore,
          ).value,
          afterPositionKey: OpeningPositionKey.fromFen(
            canonical.fenAfter,
          ).value,
          playedUci: canonical.uci,
          transitionVerified: !lookupUnavailable,
          selectedCandidate: lookupUnavailable
              ? null
              : const OpeningCandidate(
                  ecoCode: 'C20',
                  openingName: 'King Pawn',
                  sourceLineId:
                      'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
                  sourceTerminalPly: 1,
                  matchedPly: 1,
                  exactPositionName: true,
                ),
          totalCandidateCount: lookupUnavailable ? 0 : 1,
          matchedPly: 1,
          reasonCode: lookupUnavailable
              ? 'lookup_exception'
              : 'known_transition',
        )
      : null;
  final evidence = MoveClassificationEvidence(
    mover: ClassificationMover.white,
    evaluationBefore: const ClassificationScore.cp(0),
    playedMoveEvaluation: ClassificationScore.cp(playedCp),
    bestMoveEvaluation: const ClassificationScore.cp(0),
    playedMoveUci: canonical.uci,
    bestMoveUci: canonical.uci,
    candidates: [
      ClassificationCandidateEvidence(
        rootUci: canonical.uci,
        rank: 1,
        score: const ClassificationScore.cp(0),
        achievedDepth: 14,
        isLegal: true,
        pvComplete: true,
      ),
    ],
    requestedMultiPv: 1,
    receivedMultiPv: 1,
    candidateSetComplete: true,
    candidateSetCoherent: true,
    bestMovePv1Consistent: true,
    searchQualityMet: true,
    achievedDepthFloor: 14,
    legalMoveCount: 20,
    bookState: !openingV2
        ? ClassificationBookState.notBook
        : lookupUnavailable
        ? ClassificationBookState.unavailable
        : ClassificationBookState.verified,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
    isSacrifice: false,
    isCapture: false,
    isFreeCapture: false,
    isRecapture: false,
    isTrivialRecapture: false,
    isFirstSacrificePly: false,
  );
  final decision = const MoveClassifier().classifyEvidence(evidence);
  final move = MoveAnalysis(
    ply: 0,
    san: canonical.san,
    uci: canonical.uci,
    fenBefore: canonical.fenBefore,
    fenAfter: canonical.fenAfter,
    targetSquare: canonical.uci.substring(2, 4),
    winPercentBefore: decision.winPercentBefore,
    winPercentAfter: decision.winPercentAfter,
    deltaW: decision.deltaW,
    isWhiteMove: true,
    classification: decision.quality,
    baseClassification: decision.baseQuality,
    finalClassification: decision.quality,
    reasonCode: decision.reasonCode,
    classificationEvidence: evidence,
    classificationReasonCodes: decision.reasonCodes,
    classificationFailedGates: decision.failedGates,
    openingEvidence: openingEvidence,
    playedEqualsPv1: decision.playedEqualsPv1,
    moverCpLoss: decision.moverCpLoss,
    requestedDepth: 14,
    achievedDepthBefore: 14,
    achievedDepthAfter: 14,
    multiPvReceived: 1,
    searchQualityMet: true,
    engineBestMoveUci: canonical.uci,
    engineLines: [
      EngineLine(
        rank: 1,
        moveUci: canonical.uci,
        scoreCp: 0,
        depth: 14,
        whiteWinPercent: 50,
        pvMoves: [canonical.uci],
      ),
    ],
    scoreCpAfter: playedCp,
    inBook: decision.quality == MoveQuality.book,
    openingStatus: openingV2 && !lookupUnavailable
        ? OpeningStatus.bookTheory
        : OpeningStatus.notOpening,
    openingName: openingEvidence?.selectedCandidate?.openingName,
    ecoCode: openingEvidence?.selectedCandidate?.ecoCode,
    message: decision.message,
    analysisMode: 'quick',
    engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
  );
  final timeline = AnalysisTimeline(
    startingFen: game.startingFen,
    moves: [move],
    headers: game.headers,
    winPercentages: [decision.winPercentAfter],
    analysisMode: 'quick',
    analysisProfileId: 'fast_review',
    providerId: 'local_offline',
    engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
    requestedDepth: 14,
    depth: 14,
    movetimeMs: 900,
    multipv: 1,
    openingBookVersion: openingV2 ? 2 : kApexLegacyOpeningBookVersion,
    openingArtifact: openingV2 ? _artifact : null,
    openingArtifactVerification: openingV2
        ? OpeningArtifactVerification.verified
        : null,
    completedAt: DateTime.utc(2026, 7, 12),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
    engineSearchCount: 2,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: pgn,
    timeline: timeline,
    sourceProvider: 'pgn',
  );
}

const _artifact = OpeningArtifactIdentity(
  datasetName: 'apex-eco',
  sourceRevision: '2026-07-17',
  sourceSha256:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  contentSha256:
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  licenseSpdx: 'MIT',
  provenanceReference: 'assets/openings/PROVENANCE.md',
);

const _pgn = '''
[White "Alpha"]
[Black "Beta"]
[Result "*"]
[Opening "King's Pawn"]
[ECO "C20"]

1. e4 e5 2. Nf3 *
''';
