import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _afterE4 = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';

class AnalyticsInsightSpec {
  const AnalyticsInsightSpec({
    required this.claim,
    this.mechanism = MoveInsightMechanismType.none,
    this.consequence = MoveInsightConsequenceType.none,
    this.materialDelta,
  });

  final MoveInsightClaimType claim;
  final MoveInsightMechanismType mechanism;
  final MoveInsightConsequenceType consequence;
  final int? materialDelta;
}

ReviewDocument analyticsDocument({
  required int gameSeed,
  String variantSeed = 'base',
  bool? playerIsWhite = true,
  List<MoveQuality> playerQualities = const [
    MoveQuality.good,
    MoveQuality.good,
    MoveQuality.good,
    MoveQuality.good,
  ],
  List<MoveQuality> opponentQualities = const [],
  Map<int, AnalyticsInsightSpec> playerInsights = const {},
  int analysisSchema = kApexAnalysisSchemaVersion,
  int depth = 14,
  bool completeCandidates = false,
  bool verifiedOpening = false,
  bool trustedComplete = true,
  DateTime? completedAt,
  String engineIdentity = 'Stockfish 17',
}) {
  final gameId = GameId(_hash('game:$gameSeed'));
  final variantId = AnalysisVariantId(_hash('variant:$gameSeed:$variantSeed'));
  final side = playerIsWhite ?? true;
  final moves = <MoveAnalysis>[];
  final maximum = playerQualities.length > opponentQualities.length
      ? playerQualities.length
      : opponentQualities.length;
  var ply = 0;
  for (var index = 0; index < maximum; index++) {
    if (index < playerQualities.length) {
      moves.add(
        _move(
          ply: ply++,
          isWhite: side,
          quality: playerQualities[index],
          schema: analysisSchema,
          insightSpec: playerInsights[index],
          completeCandidates: completeCandidates,
          verifiedOpening: verifiedOpening,
        ),
      );
    }
    if (index < opponentQualities.length) {
      moves.add(
        _move(
          ply: ply++,
          isWhite: !side,
          quality: opponentQualities[index],
          schema: analysisSchema,
          completeCandidates: completeCandidates,
          verifiedOpening: verifiedOpening,
        ),
      );
    }
  }
  final timestamp = completedAt ?? DateTime.utc(2026, 7, 1 + gameSeed % 20);
  final explanationPolicy = analysisSchema == kApexAnalysisSchemaVersion
      ? kApexExplanationPolicyVersion
      : analysisSchema == kApexLegacyInsightAnalysisSchemaVersion
      ? kApexLegacyExplanationPolicyVersion
      : 0;
  final claimSchema = analysisSchema == kApexAnalysisSchemaVersion
      ? kApexExplanationClaimSchemaVersion
      : analysisSchema == kApexLegacyInsightAnalysisSchemaVersion
      ? kApexLegacyExplanationClaimSchemaVersion
      : 0;
  final renderer = analysisSchema == kApexAnalysisSchemaVersion
      ? kApexExplanationRendererVersion
      : analysisSchema == kApexLegacyInsightAnalysisSchemaVersion
      ? kApexChapter6ExplanationRendererVersion
      : 0;
  final timeline = AnalysisTimeline(
    moves: moves,
    startingFen: _startFen,
    headers: {
      'White': side ? 'Apex Player' : 'Opponent $gameSeed',
      'Black': side ? 'Opponent $gameSeed' : 'Apex Player',
      'Result': gameSeed.isEven ? '1-0' : '0-1',
    },
    winPercentages: [for (final move in moves) move.winPercentAfter],
    analysisMode: depth >= 18 ? 'deep' : 'quick',
    classifierVersion: kApexClassifierVersion,
    engineVersion: engineIdentity,
    analysisProfileId: depth >= 18 ? 'deep_review' : 'fast_review',
    providerId: 'local_offline',
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: verifiedOpening
        ? kApexOpeningBookVersion
        : kApexLegacyOpeningBookVersion,
    openingArtifact: verifiedOpening ? kApexOpeningArtifactIdentity : null,
    openingArtifactVerification: verifiedOpening
        ? OpeningArtifactVerification.verified
        : null,
    explanationPolicyVersion: explanationPolicy,
    explanationClaimSchemaVersion: claimSchema,
    explanationRendererVersion: renderer,
    analysisSchemaVersion: analysisSchema,
    depth: depth,
    requestedDepth: depth,
    movetimeMs: 900,
    multipv: completeCandidates ? 3 : 1,
    candidateVerificationEnabled: completeCandidates,
    completedAt: timestamp,
    completionStatus: trustedComplete
        ? AnalysisCompletionStatus.complete
        : AnalysisCompletionStatus.incomplete,
    expectedPlies: moves.length,
    engineSearchCount: moves.length + 1,
  );
  final compatibility = AnalysisCompatibility.fromTimeline(
    gameId: gameId,
    timeline: timeline,
  );
  return ReviewDocument(
    schemaVersion: kReviewDocumentSchemaVersion,
    documentId: _hash('document:$gameSeed:$variantSeed'),
    game: CanonicalGame(
      gameId: gameId,
      ruleset: 'standard',
      startingFen: _startFen,
      moves: const [],
      originalPgn: '[Event "Synthetic analytics history"]\n\n1. e4 *',
      headers: timeline.headers,
      sourceProvider: 'chapter9-corpus',
      sourceGameId: 'history-$gameSeed',
      importedAt: timestamp,
    ),
    variantId: variantId,
    compatibility: compatibility,
    run: AnalysisRunProvenance(
      runId: _hash('run:$gameSeed:$variantSeed'),
      completedAt: timestamp,
      achievedDepth: depth,
      achievedNodes: null,
      achievedElapsedMs: 10,
      engineSearchCount: moves.length + 1,
      engineCacheHitCount: 0,
      terminationComplete: trustedComplete,
    ),
    createdAt: timestamp,
    status: trustedComplete
        ? ReviewDocumentStatus.complete
        : ReviewDocumentStatus.partial,
    analyzedPerspective: switch (playerIsWhite) {
      true => AnalyzedPlayerPerspective.white,
      false => AnalyzedPlayerPerspective.black,
      null => AnalyzedPlayerPerspective.unknown,
    },
    timeline: timeline,
  );
}

MoveAnalysis _move({
  required int ply,
  required bool isWhite,
  required MoveQuality quality,
  required int schema,
  AnalyticsInsightSpec? insightSpec,
  required bool completeCandidates,
  required bool verifiedOpening,
}) {
  const uci = 'e2e4';
  final score = isWhite ? 20 : -20;
  final candidates = completeCandidates
      ? const [
          ClassificationCandidateEvidence(
            rootUci: 'e2e4',
            rank: 1,
            score: ClassificationScore.cp(20),
            achievedDepth: 20,
            isLegal: true,
            pvComplete: true,
          ),
          ClassificationCandidateEvidence(
            rootUci: 'd2d4',
            rank: 2,
            score: ClassificationScore.cp(10),
            achievedDepth: 20,
            isLegal: true,
            pvComplete: true,
          ),
          ClassificationCandidateEvidence(
            rootUci: 'g1f3',
            rank: 3,
            score: ClassificationScore.cp(5),
            achievedDepth: 20,
            isLegal: true,
            pvComplete: true,
          ),
        ]
      : const <ClassificationCandidateEvidence>[];
  final evidence = MoveClassificationEvidence(
    mover: isWhite ? ClassificationMover.white : ClassificationMover.black,
    evaluationBefore: ClassificationScore.cp(score),
    playedMoveEvaluation: ClassificationScore.cp(score),
    bestMoveEvaluation: ClassificationScore.cp(score),
    playedMoveUci: uci,
    bestMoveUci: uci,
    candidates: candidates,
    requestedMultiPv: completeCandidates ? 3 : 1,
    receivedMultiPv: completeCandidates ? 3 : 0,
    candidateSetComplete: completeCandidates,
    candidateSetCoherent: completeCandidates,
    bestMovePv1Consistent: true,
    searchQualityMet: true,
    achievedDepthFloor: completeCandidates ? 20 : 14,
    legalMoveCount: 20,
    bookState: verifiedOpening
        ? ClassificationBookState.verified
        : ClassificationBookState.notBook,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: quality == MoveQuality.onlyMove
        ? ClassificationForcedState.verifiedForcedResponse
        : ClassificationForcedState.notForced,
  );
  final opening = verifiedOpening ? _opening(ply) : null;
  final supportsInsight = schema >= kApexLegacyInsightAnalysisSchemaVersion;
  final insight = supportsInsight
      ? insightSpec == null
            ? MoveInsight.create(
                state: MoveInsightState.suppressed,
                suppressionReason: 'no_supported_claim',
                policyVersion: schema == kApexAnalysisSchemaVersion
                    ? kApexExplanationPolicyVersion
                    : kApexLegacyExplanationPolicyVersion,
                claimSchemaVersion: schema == kApexAnalysisSchemaVersion
                    ? kApexExplanationClaimSchemaVersion
                    : kApexLegacyExplanationClaimSchemaVersion,
                rendererVersion: schema == kApexAnalysisSchemaVersion
                    ? kApexExplanationRendererVersion
                    : kApexChapter6ExplanationRendererVersion,
              )
            : _insight(insightSpec, schema)
      : null;
  return MoveAnalysis(
    ply: ply,
    san: 'e4',
    uci: uci,
    fenBefore: _startFen,
    fenAfter: _afterE4,
    targetSquare: 'e4',
    winPercentBefore: 50,
    winPercentAfter: 50,
    deltaW: 0,
    isWhiteMove: isWhite,
    classification: quality,
    baseClassification: quality,
    finalClassification: quality,
    reasonCode: 'chapter9_fixture',
    classificationEvidence: evidence,
    openingEvidence: opening,
    classificationReasonCodes: const ['chapter9_fixture'],
    playedEqualsPv1: true,
    moverCpLoss: quality == MoveQuality.blunder ? 300 : 0,
    engineEvaluationAvailable: true,
    requestedDepth: completeCandidates ? 20 : 14,
    achievedDepthBefore: completeCandidates ? 20 : 14,
    achievedDepthAfter: completeCandidates ? 20 : 14,
    multiPvReceived: completeCandidates ? 3 : 0,
    searchQualityMet: true,
    scoreCpAfter: score,
    inBook: quality == MoveQuality.book,
    openingStatus: verifiedOpening
        ? ply == 0
              ? OpeningStatus.bookTheory
              : OpeningStatus.bookDeviation
        : OpeningStatus.notOpening,
    openingName: verifiedOpening ? "King's Pawn Game" : null,
    ecoCode: verifiedOpening ? 'C20' : null,
    message: '',
    coachExplanation: '',
    insight: insight,
    analysisMode: completeCandidates ? 'deep' : 'quick',
    classifierVersion: kApexClassifierVersion,
    engineVersion: 'Stockfish 17',
  );
}

MoveInsight _insight(AnalyticsInsightSpec spec, int schema) {
  const facts = [
    MoveInsightFact(
      id: 'f_legal',
      type: MoveInsightFactType.legalTransition,
      pieceRole: 'pawn',
      pieceSide: 'white',
      fromSquare: 'e2',
      toSquare: 'e4',
    ),
    MoveInsightFact(
      id: 'f_outcome',
      type: MoveInsightFactType.materialDelta,
      intValue: -3,
    ),
  ];
  final claim = MoveInsightClaim(
    id: 'c_primary',
    type: spec.claim,
    confidence: MoveInsightConfidence.verified,
    reasonCode: 'chapter9_fixture',
    supportingFactIds: const ['f_legal', 'f_outcome'],
    materialDelta: spec.materialDelta,
    mechanism: spec.mechanism,
    consequence: spec.consequence,
    mechanismReasonCode: spec.mechanism == MoveInsightMechanismType.none
        ? null
        : 'chapter9_fixture_mechanism',
  );
  return MoveInsight.create(
    state: MoveInsightState.available,
    facts: facts,
    primaryClaim: claim,
    causalChain: const [
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.move,
        factId: 'f_legal',
      ),
      MoveInsightCausalStep(
        stage: MoveInsightCausalStage.outcome,
        factId: 'f_outcome',
      ),
    ],
    conciseText: 'Persisted Chapter 9 evidence.',
    policyVersion: schema == kApexAnalysisSchemaVersion
        ? kApexExplanationPolicyVersion
        : kApexLegacyExplanationPolicyVersion,
    claimSchemaVersion: schema == kApexAnalysisSchemaVersion
        ? kApexExplanationClaimSchemaVersion
        : kApexLegacyExplanationClaimSchemaVersion,
    rendererVersion: schema == kApexAnalysisSchemaVersion
        ? kApexExplanationRendererVersion
        : kApexChapter6ExplanationRendererVersion,
  );
}

OpeningEvidence _opening(int ply) => OpeningEvidence(
  artifact: kApexOpeningArtifactIdentity,
  artifactVerification: OpeningArtifactVerification.verified,
  state: ply == 0
      ? OpeningMatchState.knownTransition
      : OpeningMatchState.leftTheory,
  beforePositionKey: OpeningPositionKey.fromFen(_startFen).value,
  afterPositionKey: OpeningPositionKey.fromFen(_afterE4).value,
  playedUci: 'e2e4',
  transitionVerified: ply == 0,
  selectedCandidate: ply == 0
      ? const OpeningCandidate(
          ecoCode: 'C20',
          openingName: "King's Pawn Game: Long Synthetic Name",
          sourceLineId:
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          sourceTerminalPly: 8,
          matchedPly: 1,
          exactPositionName: true,
        )
      : null,
  totalCandidateCount: ply == 0 ? 1 : 0,
  matchedPly: ply + 1,
  leavingTheoryPly: ply == 0 ? null : 2,
  reasonCode: ply == 0 ? 'known_transition' : 'left_theory',
);

String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
