import 'dart:convert';

import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classifier = MoveClassifier();

  group('classification evidence JSON', () {
    test('round-trips exact typed facts', () {
      final evidence = _evidence(
        candidates: const <ClassificationCandidateEvidence>[
          ClassificationCandidateEvidence(
            rootUci: 'e2e4',
            rank: 1,
            score: ClassificationScore.cp(35),
            achievedDepth: 22,
            isLegal: true,
            pvComplete: true,
          ),
        ],
        requestedMultiPv: 1,
        receivedMultiPv: 1,
        complete: true,
        coherent: true,
        searchQualityMet: true,
        bestMovePv1Consistent: true,
        legalMoveCount: 20,
      );

      final decoded = MoveClassificationEvidence.fromJson(
        jsonDecode(jsonEncode(evidence.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.toJson(), evidence.toJson());
      expect(decoded.hasValidCoreScores, isTrue);
      expect(decoded.hasCompleteCandidateSet, isTrue);
    });

    test('missing schema or mover fails closed', () {
      final valid = _evidence().toJson();
      expect(
        () => MoveClassificationEvidence.fromJson(
          Map<String, Object?>.from(valid)..remove('schemaVersion'),
        ),
        throwsFormatException,
      );
      expect(
        () => MoveClassificationEvidence.fromJson(
          Map<String, Object?>.from(valid)..['mover'] = 'unknown',
        ),
        throwsFormatException,
      );
    });

    test('duplicate castling aliases and illegal roots are incoherent', () {
      final duplicate = _evidence(
        candidates: const <ClassificationCandidateEvidence>[
          ClassificationCandidateEvidence(
            rootUci: 'e1g1',
            rank: 1,
            score: ClassificationScore.cp(0),
            achievedDepth: 22,
            isLegal: true,
            pvComplete: true,
          ),
          ClassificationCandidateEvidence(
            rootUci: 'e1h1',
            rank: 2,
            score: ClassificationScore.cp(0),
            achievedDepth: 22,
            isLegal: true,
            pvComplete: true,
          ),
        ],
        requestedMultiPv: 2,
        receivedMultiPv: 2,
        complete: true,
        coherent: true,
      );
      final illegal = _evidence(
        candidates: const <ClassificationCandidateEvidence>[
          ClassificationCandidateEvidence(
            rootUci: 'e2e5',
            rank: 1,
            score: ClassificationScore.cp(0),
            achievedDepth: 22,
            isLegal: false,
            pvComplete: true,
          ),
        ],
        complete: true,
        coherent: true,
      );

      expect(duplicate.hasStructurallyCoherentCandidates, isFalse);
      expect(duplicate.hasCompleteCandidateSet, isFalse);
      expect(illegal.hasStructurallyCoherentCandidates, isFalse);

      final malformed = _evidence(
        candidates: const <ClassificationCandidateEvidence>[
          ClassificationCandidateEvidence(
            rootUci: 'e2e9',
            rank: 1,
            score: ClassificationScore.cp(20),
            achievedDepth: 18,
            isLegal: true,
            pvComplete: true,
          ),
        ],
        requestedMultiPv: 1,
        receivedMultiPv: 1,
        complete: true,
        coherent: true,
      );
      expect(malformed.hasStructurallyCoherentCandidates, isFalse);
    });
  });

  group('unavailable evidence', () {
    test('returns explicit unavailable with no fabricated numeric values', () {
      final decision = classifier.classifyEvidence(
        MoveClassificationEvidence(
          mover: ClassificationMover.white,
          evaluationBefore: null,
          playedMoveEvaluation: const ClassificationScore.cp(0),
          bestMoveEvaluation: null,
          playedMoveUci: 'e2e4',
          bestMoveUci: null,
        ),
      );

      expect(decision.quality, MoveQuality.unavailable);
      expect(decision.deltaW.isNaN, isTrue);
      expect(decision.winPercentBefore.isNaN, isTrue);
      expect(decision.winPercentAfter.isNaN, isTrue);
      expect(decision.moverCpLoss, isNull);
      expect(decision.reasonCode, contains('missingEvaluationBefore'));
      expect(() => jsonEncode(decision.diagnosticJson), returnsNormally);
      expect(decision.diagnosticJsonString, decision.diagnosticJsonString);
      expect(decision.diagnosticJson.containsKey('message'), isFalse);
    });

    test('EvaluationAnalyzer facade fails before persistence', () {
      expect(
        () => const EvaluationAnalyzer().analyze(
          prevCp: null,
          currCp: 0,
          isWhiteMove: true,
        ),
        throwsA(isA<IncompleteMoveEvidenceException>()),
      );
    });

    test('wrong schema and missing or malformed move identity fail closed', () {
      final wrongSchema = classifier.classifyEvidence(
        _evidence(schemaVersion: 99),
      );
      final missingIdentity = classifier.classifyEvidence(
        _evidence(playedMoveUci: null),
      );
      final malformedIdentity = classifier.classifyEvidence(
        _evidence(bestMoveUci: 'e2e9'),
      );

      expect(wrongSchema.quality, MoveQuality.unavailable);
      expect(missingIdentity.quality, MoveQuality.unavailable);
      expect(malformedIdentity.quality, MoveQuality.unavailable);
    });
  });

  group('Best and equivalent alternatives', () {
    test('PV1 requires achieved search quality and coherent identity', () {
      final weak = classifier.classifyEvidence(
        _evidence(candidates: _bestCandidates, complete: true, coherent: true),
      );
      final trusted = classifier.classifyEvidence(
        _evidence(
          candidates: _bestCandidates,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
        ),
      );

      expect(weak.quality, isNot(MoveQuality.best));
      expect(trusted.quality, MoveQuality.best);
      expect(trusted.reasonCode, 'pv1_best');
    });

    test('played root within two Win percentage points is Best-equivalent', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          playedMoveUci: 'd2d4',
          played: const ClassificationScore.cp(25),
          candidates: const <ClassificationCandidateEvidence>[
            ClassificationCandidateEvidence(
              rootUci: 'e2e4',
              rank: 1,
              score: ClassificationScore.cp(35),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
            ClassificationCandidateEvidence(
              rootUci: 'd2d4',
              rank: 2,
              score: ClassificationScore.cp(25),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
          ],
          requestedMultiPv: 2,
          receivedMultiPv: 2,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
        ),
      );

      expect(decision.quality, MoveQuality.best);
      expect(decision.reasonCode, 'equivalent_best');
      expect(decision.playedEqualsPv1, isFalse);
    });

    test('a materially stronger lower-ranked candidate is not equivalent', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(0),
          played: const ClassificationScore.cp(500),
          best: const ClassificationScore.cp(0),
          playedMoveUci: 'd2d4',
          bestMoveUci: 'e2e4',
          candidates: const <ClassificationCandidateEvidence>[
            ClassificationCandidateEvidence(
              rootUci: 'e2e4',
              rank: 1,
              score: ClassificationScore.cp(0),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
            ClassificationCandidateEvidence(
              rootUci: 'd2d4',
              rank: 2,
              score: ClassificationScore.cp(500),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
          ],
          requestedMultiPv: 2,
          receivedMultiPv: 2,
          complete: true,
          coherent: true,
          bestMovePv1Consistent: true,
          searchQualityMet: true,
        ),
      );

      expect(decision.quality, isNot(MoveQuality.best));
      expect(decision.reasonCode, 'baseline_excellent');
      expect(decision.moverCpLoss, 0);
    });
  });

  group('Book and mate policy', () {
    test('verified Book cannot hide a severe CP loss', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(1500),
          best: const ClassificationScore.cp(1500),
          played: const ClassificationScore.cp(1000),
          bookState: ClassificationBookState.verified,
          searchQualityMet: true,
        ),
      );

      expect(decision.moverCpLoss, 500);
      expect(decision.quality, MoveQuality.blunder);
      expect(decision.reasonCode, 'book_severe_cp_loss');
    });

    test('verified Book does not hide the exact minus-20 boundary', () {
      const boundaryClassifier = MoveClassifier(
        winCalc: _ExactBookBoundaryWinCalculator(),
      );
      final decision = boundaryClassifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(200),
          played: const ClassificationScore.cp(0),
          best: const ClassificationScore.cp(200),
          bookState: ClassificationBookState.verified,
          searchQualityMet: true,
          legalMoveCount: 1,
        ),
      );

      expect(decision.deltaW, MoveClassifier.dwMistake);
      expect(decision.quality, MoveQuality.mistake);
      expect(decision.quality, isNot(MoveQuality.forced));
      expect(decision.reasonCode, 'baseline_mistake');
    });

    test('new mate against mover is Blunder', () {
      final decision = classifier.classifyEvidence(
        _evidence(played: const ClassificationScore.mate(-3)),
      );
      expect(decision.quality, MoveQuality.blunder);
      expect(decision.reasonCode, 'allows_forced_mate');
      expect(decision.moverCpLoss, isNull);
    });

    test('PV1 while already mated remains Best', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.mate(-3),
          best: const ClassificationScore.mate(-5),
          played: const ClassificationScore.mate(-5),
          candidates: const <ClassificationCandidateEvidence>[
            ClassificationCandidateEvidence(
              rootUci: 'e2e4',
              rank: 1,
              score: ClassificationScore.mate(-5),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
          ],
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
        ),
      );

      expect(decision.quality, MoveQuality.best);
      expect(decision.reasonCodes, contains('mate_against_best_defense'));
      expect(decision.moverCpLoss, isNull);
    });

    test('non-best mate delay is not a blanket Blunder', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.mate(-3),
          best: const ClassificationScore.mate(-3),
          played: const ClassificationScore.mate(-6),
        ),
      );

      expect(decision.quality, isNot(MoveQuality.blunder));
      expect(decision.reasonCode, 'mate_against_delayed');
      expect(decision.moverCpLoss, isNull);
    });

    test('mate hastening is distinct without CP fabrication', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.mate(-5),
          best: const ClassificationScore.mate(-5),
          played: const ClassificationScore.mate(-2),
        ),
      );

      expect(decision.quality, MoveQuality.mistake);
      expect(decision.reasonCode, 'mate_against_hastened');
      expect(decision.moverCpLoss, isNull);
    });

    test('contradictory best score while already mated fails closed', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.mate(-4),
          played: const ClassificationScore.mate(-2),
          best: const ClassificationScore.cp(0),
        ),
      );

      expect(decision.quality, MoveQuality.unavailable);
    });
  });

  group('special-label evidence gates', () {
    test('Forced requires exactly one legal move', () {
      final forced = classifier.classifyEvidence(_evidence(legalMoveCount: 1));
      final notForced = classifier.classifyEvidence(
        _evidence(
          candidates: _onlyMoveCandidates,
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
          legalMoveCount: 20,
        ),
      );

      expect(forced.quality, MoveQuality.forced);
      expect(forced.reasonCode, 'only_legal_move');
      expect(notForced.quality, MoveQuality.onlyMove);
    });

    test(
      'Only Move requires complete distinct alternatives and outcome loss',
      () {
        final decision = classifier.classifyEvidence(
          _evidence(
            before: const ClassificationScore.cp(100),
            best: const ClassificationScore.cp(100),
            played: const ClassificationScore.cp(100),
            candidates: _onlyMoveCandidates,
            requestedMultiPv: 3,
            receivedMultiPv: 3,
            complete: true,
            coherent: true,
            searchQualityMet: true,
            bestMovePv1Consistent: true,
            legalMoveCount: 20,
          ),
        );

        expect(decision.quality, MoveQuality.onlyMove);
        expect(decision.reasonCode, 'only_outcome_preserving_move');
      },
    );

    test('Missed Win supports a played move outside top MultiPV roots', () {
      final decision = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(400),
          best: const ClassificationScore.cp(400),
          played: const ClassificationScore.cp(0),
          playedMoveUci: 'h2h3',
          candidates: const <ClassificationCandidateEvidence>[
            ClassificationCandidateEvidence(
              rootUci: 'e2e4',
              rank: 1,
              score: ClassificationScore.cp(400),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
            ClassificationCandidateEvidence(
              rootUci: 'd2d4',
              rank: 2,
              score: ClassificationScore.cp(0),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
            ClassificationCandidateEvidence(
              rootUci: 'c2c4',
              rank: 3,
              score: ClassificationScore.cp(-100),
              achievedDepth: 22,
              isLegal: true,
              pvComplete: true,
            ),
          ],
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
        ),
      );

      expect(decision.quality, MoveQuality.missedWin);
      expect(decision.reasonCode, 'missed_decisive_line');
    });

    test('Brilliant requires a real verified sound sacrifice', () {
      final positive = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(20),
          best: const ClassificationScore.cp(30),
          played: const ClassificationScore.cp(30),
          candidates: _brilliantCandidates,
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
          legalMoveCount: 20,
          verificationState: ClassificationVerificationState.complete,
          isSacrifice: true,
          tacticalBestOrNearBest: true,
          tacticalHasForcingOutcome: true,
        ),
      );
      final missingSacrifice = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(20),
          best: const ClassificationScore.cp(30),
          played: const ClassificationScore.cp(30),
          candidates: _brilliantCandidates,
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
          legalMoveCount: 20,
          verificationState: ClassificationVerificationState.complete,
          isSacrifice: false,
          tacticalBestOrNearBest: true,
          tacticalHasForcingOutcome: true,
        ),
      );

      expect(positive.quality, MoveQuality.brilliant);
      expect(missingSacrifice.quality, isNot(MoveQuality.brilliant));
    });

    test('already-crushing sacrifice needs a verified mate exception', () {
      MoveClassification classify({required bool tacticalForcedMate}) =>
          classifier.classifyEvidence(
            _evidence(
              before: const ClassificationScore.cp(650),
              best: const ClassificationScore.cp(620),
              played: const ClassificationScore.cp(620),
              candidates: _brilliantCandidates,
              requestedMultiPv: 3,
              receivedMultiPv: 3,
              complete: true,
              coherent: true,
              searchQualityMet: true,
              bestMovePv1Consistent: true,
              legalMoveCount: 20,
              verificationState: ClassificationVerificationState.complete,
              isSacrifice: true,
              tacticalBestOrNearBest: true,
              tacticalHasForcingOutcome: true,
              tacticalForcedMate: tacticalForcedMate,
            ),
          );

      expect(classify(tacticalForcedMate: false).quality, MoveQuality.best);
      expect(classify(tacticalForcedMate: true).quality, MoveQuality.brilliant);
    });

    test('unverified tactical facts cannot activate Great', () {
      final unverified = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(0),
          best: const ClassificationScore.cp(100),
          played: const ClassificationScore.cp(100),
          candidates: _greatCandidates,
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
          legalMoveCount: 20,
          verificationState: ClassificationVerificationState.incomplete,
          tacticalBestOrNearBest: true,
          tacticalHasForcingOutcome: true,
        ),
      );
      final verified = classifier.classifyEvidence(
        _evidence(
          before: const ClassificationScore.cp(0),
          best: const ClassificationScore.cp(100),
          played: const ClassificationScore.cp(100),
          candidates: _greatCandidates,
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          complete: true,
          coherent: true,
          searchQualityMet: true,
          bestMovePv1Consistent: true,
          legalMoveCount: 20,
          verificationState: ClassificationVerificationState.complete,
          tacticalBestOrNearBest: true,
          tacticalHasForcingOutcome: true,
        ),
      );

      expect(unverified.quality, isNot(MoveQuality.great));
      expect(verified.quality, MoveQuality.great);
    });

    test('legacy profile suppression flag does not change equal evidence', () {
      MoveClassification classify(bool suppress) => classifier.classify(
        MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 100,
          prevWhiteMate: null,
          currWhiteCp: 100,
          currWhiteMate: null,
          engineBestMoveUci: 'e2e4',
          playedMoveUci: 'e2e4',
          candidateEvidence: _onlyMoveCandidates,
          requestedMultiPv: 3,
          receivedMultiPv: 3,
          candidateSetCoherent: true,
          bestMovePv1Consistent: true,
          searchQualityMet: true,
          legalMoveCount: 20,
          alternativeEvidenceComplete: true,
          suppressTrophyTiers: suppress,
        ),
      );

      expect(classify(false).quality, MoveQuality.onlyMove);
      expect(classify(true).quality, MoveQuality.onlyMove);
    });
  });

  test('policy and schema versions are explicit', () {
    expect(kApexClassifierVersion, 6);
    expect(kApexClassifierProfile, 'apex_trustworthy_offline_v6');
    expect(kApexAnalysisSchemaVersion, 4);
  });
}

const _bestCandidates = <ClassificationCandidateEvidence>[
  ClassificationCandidateEvidence(
    rootUci: 'e2e4',
    rank: 1,
    score: ClassificationScore.cp(35),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
];

const _onlyMoveCandidates = <ClassificationCandidateEvidence>[
  ClassificationCandidateEvidence(
    rootUci: 'e2e4',
    rank: 1,
    score: ClassificationScore.cp(100),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
  ClassificationCandidateEvidence(
    rootUci: 'd2d4',
    rank: 2,
    score: ClassificationScore.cp(-300),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
  ClassificationCandidateEvidence(
    rootUci: 'c2c4',
    rank: 3,
    score: ClassificationScore.cp(-500),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
];

const _brilliantCandidates = <ClassificationCandidateEvidence>[
  ClassificationCandidateEvidence(
    rootUci: 'e2e4',
    rank: 1,
    score: ClassificationScore.cp(30),
    achievedDepth: 24,
    isLegal: true,
    pvComplete: true,
  ),
  ClassificationCandidateEvidence(
    rootUci: 'd2d4',
    rank: 2,
    score: ClassificationScore.cp(-100),
    achievedDepth: 24,
    isLegal: true,
    pvComplete: true,
  ),
  ClassificationCandidateEvidence(
    rootUci: 'c2c4',
    rank: 3,
    score: ClassificationScore.cp(-200),
    achievedDepth: 24,
    isLegal: true,
    pvComplete: true,
  ),
];

const _greatCandidates = <ClassificationCandidateEvidence>[
  ClassificationCandidateEvidence(
    rootUci: 'e2e4',
    rank: 1,
    score: ClassificationScore.cp(100),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
  ClassificationCandidateEvidence(
    rootUci: 'd2d4',
    rank: 2,
    score: ClassificationScore.cp(-200),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
  ClassificationCandidateEvidence(
    rootUci: 'c2c4',
    rank: 3,
    score: ClassificationScore.cp(-300),
    achievedDepth: 22,
    isLegal: true,
    pvComplete: true,
  ),
];

MoveClassificationEvidence _evidence({
  int schemaVersion = 1,
  ClassificationMover mover = ClassificationMover.white,
  ClassificationScore before = const ClassificationScore.cp(35),
  ClassificationScore played = const ClassificationScore.cp(35),
  ClassificationScore best = const ClassificationScore.cp(35),
  String? playedMoveUci = 'e2e4',
  String? bestMoveUci = 'e2e4',
  List<ClassificationCandidateEvidence> candidates = const [],
  int requestedMultiPv = 1,
  int receivedMultiPv = 0,
  bool complete = false,
  bool coherent = false,
  bool bestMovePv1Consistent = false,
  bool searchQualityMet = false,
  int? legalMoveCount = 20,
  ClassificationBookState bookState = ClassificationBookState.notBook,
  ClassificationVerificationState verificationState =
      ClassificationVerificationState.notRequested,
  bool? isSacrifice = false,
  bool tacticalBestOrNearBest = false,
  bool tacticalHasForcingOutcome = false,
  bool tacticalForcedMate = false,
}) => MoveClassificationEvidence(
  schemaVersion: schemaVersion,
  mover: mover,
  evaluationBefore: before,
  playedMoveEvaluation: played,
  bestMoveEvaluation: best,
  playedMoveUci: playedMoveUci,
  bestMoveUci: bestMoveUci,
  candidates: candidates,
  requestedMultiPv: requestedMultiPv,
  receivedMultiPv: receivedMultiPv,
  candidateSetComplete: complete,
  candidateSetCoherent: coherent,
  bestMovePv1Consistent: bestMovePv1Consistent,
  searchQualityMet: searchQualityMet,
  achievedDepthFloor: searchQualityMet ? 22 : null,
  legalMoveCount: legalMoveCount,
  bookState: bookState,
  verificationState: verificationState,
  forcedState: legalMoveCount == 1
      ? ClassificationForcedState.onlyLegalMove
      : ClassificationForcedState.notForced,
  isSacrifice: isSacrifice,
  isCapture: false,
  isFreeCapture: false,
  isRecapture: false,
  isTrivialRecapture: false,
  isFirstSacrificePly: true,
  tacticalBestOrNearBest: tacticalBestOrNearBest,
  tacticalHasForcingOutcome: tacticalHasForcingOutcome,
  tacticalForcedMate: tacticalForcedMate,
);

class _ExactBookBoundaryWinCalculator extends WinPercentCalculator {
  const _ExactBookBoundaryWinCalculator();

  @override
  double forCp({int? cp, int? mate}) {
    if (mate != null) return super.forCp(cp: cp, mate: mate);
    return switch (cp) {
      200 => 60.0,
      0 => 40.0,
      _ => super.forCp(cp: cp, mate: mate),
    };
  }
}
