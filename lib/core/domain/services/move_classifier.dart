/// Versioned Apex move-classification policy.
///
/// [classifyEvidence] is the single authoritative production boundary. The
/// legacy [classify] API is retained only as an adapter while engine callers
/// migrate to the immutable evidence contract.
library;

import 'dart:convert';

import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/deep_tactical_verdict.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart'
    show MoveQuality, normalizeCastlingUci;
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';

/// Deterministic result of one policy pass.
///
/// [message] remains as a compatibility field for existing product surfaces.
/// Evidence and [diagnosticJson] never contain human prose.
class MoveClassification {
  MoveClassification({
    required this.quality,
    required this.baseQuality,
    required List<String> reasonCodes,
    required List<String> failedGates,
    required this.playedEqualsPv1,
    required this.deltaW,
    required this.winPercentBefore,
    required this.winPercentAfter,
    required this.moverCpLoss,
    required this.message,
    required this.policyVersion,
    required Map<String, Object?> diagnosticJson,
    this.engineBestMoveUci,
  }) : reasonCodes = List<String>.unmodifiable(reasonCodes),
       failedGates = List<String>.unmodifiable(failedGates),
       diagnosticJson = Map<String, Object?>.unmodifiable(diagnosticJson);

  final MoveQuality quality;
  final MoveQuality baseQuality;
  final List<String> reasonCodes;
  final List<String> failedGates;
  final bool playedEqualsPv1;
  final double deltaW;
  final double winPercentBefore;
  final double winPercentAfter;
  final int? moverCpLoss;
  final String message;
  final int policyVersion;
  final Map<String, Object?> diagnosticJson;
  final String? engineBestMoveUci;

  String get reasonCode =>
      reasonCodes.isEmpty ? 'classification_unavailable' : reasonCodes.first;

  String get diagnosticJsonString => jsonEncode(diagnosticJson);
}

/// Compatibility input used by older call sites.
///
/// New engine integrations should construct [MoveClassificationEvidence]
/// directly. In particular, a Win%-only list is not exact candidate evidence;
/// callers must provide [candidateEvidence] for evidence-heavy labels.
class MoveClassificationInput {
  const MoveClassificationInput({
    required this.isWhiteMove,
    required this.prevWhiteCp,
    required this.prevWhiteMate,
    required this.currWhiteCp,
    required this.currWhiteMate,
    this.engineBestMoveUci,
    this.playedMoveUci,
    this.secondBestWhiteWinPercent,
    this.multiPvWhiteWinPercents,
    this.altLineWhiteWinPercent,
    this.candidateEvidence = const <ClassificationCandidateEvidence>[],
    this.requestedMultiPv = 1,
    this.receivedMultiPv,
    this.candidateSetCoherent = false,
    this.bestMovePv1Consistent = false,
    this.searchQualityMet = false,
    this.achievedDepthFloor,
    this.legalMoveCount,
    this.forcedState = ClassificationForcedState.unavailable,
    this.isSacrifice = false,
    this.isCapture = false,
    this.isFreeCapture = false,
    this.isRecapture = false,
    this.hasTacticalMotif = false,
    this.tacticalVerdict = DeepTacticalVerdict.none,
    this.isTrivialRecapture = false,
    this.isFirstSacrificePly = true,
    this.isBook = false,
    this.openingName,
    this.ecoCode,
    this.suppressTrophyTiers = false,
    this.alternativeEvidenceComplete = false,
    this.deepVerificationComplete = false,
    this.unavailableReason,
  });

  final bool isWhiteMove;
  final int? prevWhiteCp;
  final int? prevWhiteMate;
  final int? currWhiteCp;
  final int? currWhiteMate;
  final String? engineBestMoveUci;
  final String? playedMoveUci;

  /// Deprecated lossy candidate fields. They are ignored by policy v6.
  final double? secondBestWhiteWinPercent;
  final List<double>? multiPvWhiteWinPercents;
  final double? altLineWhiteWinPercent;

  final List<ClassificationCandidateEvidence> candidateEvidence;
  final int requestedMultiPv;
  final int? receivedMultiPv;
  final bool candidateSetCoherent;
  final bool bestMovePv1Consistent;
  final bool searchQualityMet;
  final int? achievedDepthFloor;
  final int? legalMoveCount;
  final ClassificationForcedState forcedState;

  final bool isSacrifice;
  final bool isCapture;
  final bool isFreeCapture;
  final bool isRecapture;
  final bool hasTacticalMotif;
  final DeepTacticalVerdict tacticalVerdict;
  final bool isTrivialRecapture;
  final bool isFirstSacrificePly;
  final bool isBook;
  final String? openingName;
  final String? ecoCode;

  /// Retained for source compatibility only. Policy v6 never reads a profile
  /// mode; evidence availability suppresses special labels naturally.
  final bool suppressTrophyTiers;

  final bool alternativeEvidenceComplete;
  final bool deepVerificationComplete;
  final ClassificationUnavailableReason? unavailableReason;

  MoveClassificationEvidence toEvidence() {
    ClassificationScore? score(int? cp, int? mate) {
      if (cp == null && mate == null) return null;
      return ClassificationScore(whiteCp: cp, whiteMate: mate);
    }

    final tactical = tacticalVerdict;
    return MoveClassificationEvidence(
      mover: isWhiteMove
          ? ClassificationMover.white
          : ClassificationMover.black,
      evaluationBefore: score(prevWhiteCp, prevWhiteMate),
      playedMoveEvaluation: score(currWhiteCp, currWhiteMate),
      bestMoveEvaluation: score(prevWhiteCp, prevWhiteMate),
      playedMoveUci: playedMoveUci,
      bestMoveUci: engineBestMoveUci,
      candidates: candidateEvidence,
      requestedMultiPv: requestedMultiPv,
      receivedMultiPv: receivedMultiPv ?? candidateEvidence.length,
      candidateSetComplete: alternativeEvidenceComplete,
      candidateSetCoherent: candidateSetCoherent,
      bestMovePv1Consistent: bestMovePv1Consistent,
      searchQualityMet: searchQualityMet,
      achievedDepthFloor: achievedDepthFloor,
      legalMoveCount: legalMoveCount,
      bookState: isBook
          ? ClassificationBookState.verified
          : ClassificationBookState.notBook,
      verificationState: deepVerificationComplete && tactical.verified
          ? ClassificationVerificationState.complete
          : tactical.isCandidate
          ? ClassificationVerificationState.incomplete
          : ClassificationVerificationState.notRequested,
      forcedState: forcedState,
      isSacrifice: isSacrifice,
      isCapture: isCapture,
      isFreeCapture: isFreeCapture,
      isRecapture: isRecapture,
      isTrivialRecapture: isTrivialRecapture,
      isFirstSacrificePly: isFirstSacrificePly,
      tacticalBestOrNearBest: tactical.isBestOrNearBest,
      tacticalHasForcingOutcome: tactical.hasForcingOutcome,
      tacticalForcedMate: tactical.forcedMate,
      unavailableReason: unavailableReason,
    );
  }
}

/// Retained for source compatibility. Policy v6 returns `unavailable` instead
/// of throwing when classification evidence is absent or ambiguous.
class IncompleteMoveEvidenceException implements Exception {
  const IncompleteMoveEvidenceException(this.message);
  final String message;

  @override
  String toString() => 'IncompleteMoveEvidenceException: $message';
}

class MoveClassifier {
  const MoveClassifier({
    WinPercentCalculator winCalc = const WinPercentCalculator(),
    MoverPerspective perspective = const MoverPerspective(),
  }) : _win = winCalc,
       _persp = perspective;

  final WinPercentCalculator _win;
  final MoverPerspective _persp;

  // General thresholds are intentionally preserved from policy v5.
  static const double dwExcellent = -2.0;
  static const double dwGood = -5.0;
  static const double dwInaccuracy = -10.0;
  static const double dwMistake = -20.0;
  static const double winningCutoff = 70.0;
  static const double equalCeiling = 60.0;
  static const int brilliantCpLossCap = 40;
  static const double forcedDropPp = 20.0;
  static const double greatCaptureGapPp = 15.0;
  static const double equivalentBestTolerancePp = 2.0;
  static const int bookCpLossOverride = 250;

  MoveClassification classify(MoveClassificationInput input) =>
      classifyEvidence(input.toEvidence());

  /// The one authoritative policy-v6 classification entry point.
  MoveClassification classifyEvidence(MoveClassificationEvidence evidence) {
    final unavailable = _coreUnavailableReason(evidence);
    if (unavailable != null) {
      return _unavailableDecision(evidence, unavailable);
    }

    final before = evidence.evaluationBefore!;
    final played = evidence.playedMoveEvaluation!;
    final bestScore = evidence.bestMoveEvaluation!;
    final isWhiteMove = evidence.mover == ClassificationMover.white;
    final whiteWinBefore = _winFor(before);
    final whiteWinAfter = _winFor(played);
    final whiteWinBest = _winFor(bestScore);
    final moverWinBefore = _persp.moverWinPercent(
      whiteWinBefore,
      isWhiteMove: isWhiteMove,
    );
    final moverWinAfter = _persp.moverWinPercent(
      whiteWinAfter,
      isWhiteMove: isWhiteMove,
    );
    final bestMoverWin = _persp.moverWinPercent(
      whiteWinBest,
      isWhiteMove: isWhiteMove,
    );
    final deltaW = _persp.deltaW(
      whiteWinBefore: whiteWinBefore,
      whiteWinAfter: whiteWinAfter,
      isWhiteMove: isWhiteMove,
    );
    final signedCpLoss = _persp.cpLoss(
      whiteCpBefore: bestScore.whiteCp,
      whiteCpAfter: played.whiteCp,
      mateBefore: bestScore.whiteMate,
      mateAfter: played.whiteMate,
      isWhiteMove: isWhiteMove,
    );
    final cpLossMover = signedCpLoss == null
        ? null
        : signedCpLoss < 0
        ? 0
        : signedCpLoss;

    final candidatesCoherent = evidence.hasStructurallyCoherentCandidates;
    final candidatesComplete = evidence.hasCompleteCandidateSet;
    final pv1 = candidatesCoherent ? evidence.candidates.first : null;
    final bestMovePv1Consistent =
        candidatesCoherent &&
        evidence.bestMovePv1Consistent &&
        _sameMove(evidence.bestMoveUci, pv1?.rootUci);
    final playedCandidate = candidatesCoherent
        ? evidence.candidates
              .where(
                (candidate) =>
                    _sameMove(candidate.rootUci, evidence.playedMoveUci),
              )
              .firstOrNull
        : null;
    final playedEqualsPv1 = bestMovePv1Consistent && playedCandidate?.rank == 1;
    final playedCandidateWin = playedCandidate == null
        ? null
        : _moverWinFor(playedCandidate.score, isWhiteMove: isWhiteMove);
    final bestCandidateWin = pv1 == null
        ? bestMoverWin
        : _moverWinFor(pv1.score, isWhiteMove: isWhiteMove);
    final playedEquivalentBest =
        bestMovePv1Consistent &&
        playedCandidateWin != null &&
        (bestCandidateWin - playedCandidateWin).abs() <=
            equivalentBestTolerancePp;
    final qualifiesBest =
        evidence.searchQualityMet &&
        bestMovePv1Consistent &&
        (playedEqualsPv1 || playedEquivalentBest);
    final equivalentBestCount = candidatesCoherent
        ? evidence.candidates
              .where(
                (candidate) =>
                    (bestCandidateWin -
                            _moverWinFor(
                              candidate.score,
                              isWhiteMove: isWhiteMove,
                            ))
                        .abs() <=
                    equivalentBestTolerancePp,
              )
              .length
        : 0;

    final beforeMateState = _mateStateForMover(
      before,
      isWhiteMove: isWhiteMove,
    );
    final playedMateState = _mateStateForMover(
      played,
      isWhiteMove: isWhiteMove,
    );
    final bestMateState = _mateStateForMover(
      bestScore,
      isWhiteMove: isWhiteMove,
    );
    final enteringNewMateAgainst =
        playedMateState == _MateState.againstMover &&
        beforeMateState != _MateState.againstMover;
    final remainedMateAgainst =
        beforeMateState == _MateState.againstMover &&
        playedMateState == _MateState.againstMover;
    if (remainedMateAgainst && bestMateState != _MateState.againstMover) {
      return _unavailableDecision(
        evidence,
        ClassificationUnavailableReason.contradictoryBestMove,
      );
    }
    final brilliantMateException =
        playedMateState == _MateState.forMover || evidence.tacticalForcedMate;

    final baseQuality = _baselineQuality(
      deltaW: deltaW,
      cpLossMover: cpLossMover,
      moverWinBefore: moverWinBefore,
      moverWinAfter: moverWinAfter,
      qualifiesBest: qualifiesBest,
    );

    final failedGates = _failedGates(
      evidence: evidence,
      candidatesCoherent: candidatesCoherent,
      candidatesComplete: candidatesComplete,
      bestMovePv1Consistent: bestMovePv1Consistent,
      qualifiesBest: qualifiesBest,
      equivalentBestCount: equivalentBestCount,
      deltaW: deltaW,
      cpLossMover: cpLossMover,
      moverWinBefore: moverWinBefore,
      moverWinAfter: moverWinAfter,
      brilliantMateException: brilliantMateException,
    );

    MoveClassification finish(
      MoveQuality quality,
      MoveQuality base,
      List<String> reasons,
    ) {
      final diagnostics = <String, Object?>{
        'policyVersion': kApexClassifierVersion,
        'selectedLabel': quality.name,
        'baseLabel': base.name,
        'reasonCodes': List<String>.unmodifiable(reasons),
        'failedGates': List<String>.unmodifiable(failedGates),
        'mover': evidence.mover.name,
        'deltaW': deltaW,
        'moverCpLoss': cpLossMover,
        'moverWinBefore': moverWinBefore,
        'moverWinAfter': moverWinAfter,
        'bestMoverWin': bestMoverWin,
        'scoreDomainBefore': before.domain.name,
        'scoreDomainAfter': played.domain.name,
        'candidateCount': evidence.candidates.length,
        'requestedMultiPv': evidence.requestedMultiPv,
        'receivedMultiPv': evidence.receivedMultiPv,
        'candidateSetComplete': candidatesComplete,
        'candidateSetCoherent': candidatesCoherent,
        'bestMovePv1Consistent': bestMovePv1Consistent,
        'bestEquivalentMoveCount': equivalentBestCount,
        'playedCandidateRank': playedCandidate?.rank,
        'searchQualityMet': evidence.searchQualityMet,
        'achievedDepthFloor': evidence.achievedDepthFloor,
        'bookState': evidence.bookState.name,
        'verificationState': evidence.verificationState.name,
        'forcedState': evidence.forcedState.name,
        'legalMoveCount': evidence.legalMoveCount,
      };
      return MoveClassification(
        quality: quality,
        baseQuality: base,
        reasonCodes: reasons,
        failedGates: failedGates,
        playedEqualsPv1: playedEqualsPv1,
        deltaW: deltaW,
        winPercentBefore: whiteWinBefore,
        winPercentAfter: whiteWinAfter,
        moverCpLoss: cpLossMover,
        message: _messageFor(quality),
        policyVersion: kApexClassifierVersion,
        diagnosticJson: diagnostics,
        engineBestMoveUci: evidence.bestMoveUci,
      );
    }

    List<String> baselineReasons() => <String>[
      if (baseQuality == MoveQuality.best)
        playedEqualsPv1 ? 'pv1_best' : 'equivalent_best'
      else
        _baseReason(baseQuality, qualifiesBest),
    ];

    // A newly-entered forced mate against the mover dominates every badge.
    if (enteringNewMateAgainst) {
      return finish(MoveQuality.blunder, MoveQuality.blunder, const <String>[
        'allows_forced_mate',
      ]);
    }

    // Do not repeatedly label an already-forced mate as a fresh Blunder.
    // Keep mate distance in its native domain and distinguish the best
    // defense, preservation/delay, and a move that hastens mate.
    if (remainedMateAgainst) {
      if (qualifiesBest) {
        return finish(MoveQuality.best, MoveQuality.best, <String>[
          playedEqualsPv1 ? 'pv1_best' : 'equivalent_best',
          'mate_against_best_defense',
        ]);
      }
      final bestDistance = bestScore.whiteMate!.abs();
      final playedDistance = played.whiteMate!.abs();
      if (playedDistance < bestDistance) {
        return finish(MoveQuality.mistake, baseQuality, const <String>[
          'mate_against_hastened',
        ]);
      }
      return finish(baseQuality, baseQuality, <String>[
        playedDistance > bestDistance
            ? 'mate_against_delayed'
            : 'mate_against_preserved',
      ]);
    }

    final missedWin = _missedWinDecision(
      evidence: evidence,
      candidatesComplete: candidatesComplete,
      bestMovePv1Consistent: bestMovePv1Consistent,
      qualifiesBest: qualifiesBest,
      bestMateState: bestMateState,
      playedMateState: playedMateState,
      bestMoverWin: bestMoverWin,
      moverWinAfter: moverWinAfter,
      deltaW: deltaW,
    );
    if (missedWin != null) {
      return finish(missedWin.$1, baseQuality, <String>[missedWin.$2]);
    }

    if (evidence.bookState == ClassificationBookState.verified) {
      if (evidence.searchQualityMet &&
          cpLossMover != null &&
          cpLossMover > bookCpLossOverride) {
        return finish(MoveQuality.blunder, baseQuality, const <String>[
          'book_severe_cp_loss',
        ]);
      }
      final adverseMateTransition =
          beforeMateState == _MateState.forMover &&
          playedMateState != _MateState.forMover;
      if (evidence.searchQualityMet &&
          deltaW > dwMistake &&
          !adverseMateTransition) {
        return finish(MoveQuality.book, MoveQuality.book, const <String>[
          'verified_book_safe',
        ]);
      }
      // Verified opening provenance is never permission to fall through into
      // a trophy/forced label. If Book is unsafe, keep the ordinary factual
      // verdict selected above (Missed Win and mate loss already took
      // precedence).
      return finish(baseQuality, baseQuality, baselineReasons());
    }

    // Forced means exactly one legal move. MultiPV gaps never manufacture it.
    if (evidence.legalMoveCount == 1) {
      return finish(MoveQuality.forced, baseQuality, const <String>[
        'only_legal_move',
      ]);
    }

    final brilliant =
        evidence.isSacrifice == true &&
        evidence.isFirstSacrificePly == true &&
        evidence.isRecapture != true &&
        evidence.isTrivialRecapture != true &&
        evidence.isFreeCapture != true &&
        evidence.verificationState ==
            ClassificationVerificationState.complete &&
        evidence.tacticalBestOrNearBest &&
        evidence.tacticalHasForcingOutcome &&
        evidence.searchQualityMet &&
        candidatesComplete &&
        bestMovePv1Consistent &&
        playedCandidate != null &&
        equivalentBestCount == 1 &&
        deltaW >= dwExcellent &&
        (cpLossMover == null || cpLossMover <= brilliantCpLossCap) &&
        (moverWinBefore < 90.0 || brilliantMateException) &&
        (playedMateState == _MateState.forMover || moverWinAfter >= 50.0);
    if (brilliant) {
      return finish(MoveQuality.brilliant, baseQuality, const <String>[
        'verified_sound_sacrifice',
      ]);
    }

    final onlyMove = _isOnlyMove(
      evidence: evidence,
      candidatesComplete: candidatesComplete,
      bestMovePv1Consistent: bestMovePv1Consistent,
      playedEqualsPv1: playedEqualsPv1,
      isWhiteMove: isWhiteMove,
    );
    if (onlyMove) {
      return finish(MoveQuality.onlyMove, baseQuality, const <String>[
        'only_outcome_preserving_move',
      ]);
    }

    final soundForGreat =
        deltaW >= dwExcellent &&
        moverWinAfter >= 30.0 &&
        (baseQuality == MoveQuality.best ||
            baseQuality == MoveQuality.excellent);
    final greatGap = candidatesComplete && evidence.candidates.length >= 3
        ? bestCandidateWin -
              _moverWinFor(
                evidence.candidates[1].score,
                isWhiteMove: isWhiteMove,
              )
        : 0.0;
    final great =
        evidence.searchQualityMet &&
        candidatesComplete &&
        bestMovePv1Consistent &&
        playedCandidate != null &&
        (playedEqualsPv1 || playedEquivalentBest) &&
        equivalentBestCount == 1 &&
        soundForGreat &&
        evidence.isRecapture != true &&
        evidence.isTrivialRecapture != true &&
        evidence.isFreeCapture != true &&
        evidence.isSacrifice != true &&
        ((evidence.verificationState ==
                    ClassificationVerificationState.complete &&
                evidence.tacticalHasForcingOutcome) ||
            (evidence.isCapture == true && greatGap >= greatCaptureGapPp));
    if (great) {
      return finish(MoveQuality.great, baseQuality, const <String>[
        'verified_great_move',
      ]);
    }

    return finish(baseQuality, baseQuality, baselineReasons());
  }

  ClassificationUnavailableReason? _coreUnavailableReason(
    MoveClassificationEvidence evidence,
  ) {
    if (evidence.schemaVersion != 1) {
      return ClassificationUnavailableReason.unsupportedSchema;
    }
    if (evidence.unavailableReason != null) return evidence.unavailableReason;
    if (evidence.evaluationBefore == null) {
      return ClassificationUnavailableReason.missingEvaluationBefore;
    }
    if (evidence.playedMoveEvaluation == null) {
      return ClassificationUnavailableReason.missingPlayedMoveEvaluation;
    }
    if (evidence.bestMoveEvaluation == null) {
      return ClassificationUnavailableReason.missingBestMoveEvaluation;
    }
    if (!evidence.evaluationBefore!.isValid ||
        !evidence.playedMoveEvaluation!.isValid ||
        !evidence.bestMoveEvaluation!.isValid) {
      return ClassificationUnavailableReason.ambiguousScore;
    }
    if (!evidence.hasExactMoveIdentity) {
      return ClassificationUnavailableReason.missingMoveIdentity;
    }
    return null;
  }

  MoveClassification _unavailableDecision(
    MoveClassificationEvidence evidence,
    ClassificationUnavailableReason reason,
  ) {
    final reasonCode = 'evidence_unavailable_${reason.name}';
    final diagnostic = <String, Object?>{
      'policyVersion': kApexClassifierVersion,
      'selectedLabel': MoveQuality.unavailable.name,
      'baseLabel': MoveQuality.unavailable.name,
      'reasonCodes': <String>[reasonCode],
      'failedGates': <String>['core.${reason.name}'],
      'mover': evidence.mover.name,
      'candidateCount': evidence.candidates.length,
      'candidateSetComplete': evidence.hasCompleteCandidateSet,
      'candidateSetCoherent': evidence.hasStructurallyCoherentCandidates,
      'bookState': evidence.bookState.name,
      'verificationState': evidence.verificationState.name,
    };
    return MoveClassification(
      quality: MoveQuality.unavailable,
      baseQuality: MoveQuality.unavailable,
      reasonCodes: <String>[reasonCode],
      failedGates: <String>['core.${reason.name}'],
      playedEqualsPv1: false,
      deltaW: double.nan,
      winPercentBefore: double.nan,
      winPercentAfter: double.nan,
      moverCpLoss: null,
      message: _messageFor(MoveQuality.unavailable),
      policyVersion: kApexClassifierVersion,
      diagnosticJson: diagnostic,
      engineBestMoveUci: evidence.bestMoveUci,
    );
  }

  (MoveQuality, String)? _missedWinDecision({
    required MoveClassificationEvidence evidence,
    required bool candidatesComplete,
    required bool bestMovePv1Consistent,
    required bool qualifiesBest,
    required _MateState bestMateState,
    required _MateState playedMateState,
    required double bestMoverWin,
    required double moverWinAfter,
    required double deltaW,
  }) {
    final hasRequiredEvidence =
        evidence.searchQualityMet &&
        candidatesComplete &&
        evidence.candidates.length >= 2 &&
        bestMovePv1Consistent &&
        evidence.playedMoveUci != null &&
        evidence.playedMoveUci!.length >= 4;
    if (!hasRequiredEvidence || qualifiesBest) return null;

    if (bestMateState == _MateState.forMover &&
        playedMateState != _MateState.forMover) {
      if (moverWinAfter < 50.0 && deltaW <= dwMistake) {
        return (MoveQuality.blunder, 'missed_forced_mate_collapse');
      }
      return (MoveQuality.missedWin, 'missed_forced_mate');
    }

    if (bestMoverWin > winningCutoff &&
        moverWinAfter < equalCeiling &&
        deltaW <= dwInaccuracy) {
      if (moverWinAfter < 50.0 && deltaW <= dwMistake) {
        return (MoveQuality.blunder, 'missed_win_collapse');
      }
      return (MoveQuality.missedWin, 'missed_decisive_line');
    }
    return null;
  }

  bool _isOnlyMove({
    required MoveClassificationEvidence evidence,
    required bool candidatesComplete,
    required bool bestMovePv1Consistent,
    required bool playedEqualsPv1,
    required bool isWhiteMove,
  }) {
    if (!candidatesComplete ||
        !bestMovePv1Consistent ||
        !evidence.searchQualityMet ||
        evidence.candidates.length < 3 ||
        evidence.requestedMultiPv < 3 ||
        evidence.legalMoveCount == null ||
        evidence.legalMoveCount! <= 1 ||
        !playedEqualsPv1) {
      return false;
    }
    final best = _moverWinFor(
      evidence.candidates[0].score,
      isWhiteMove: isWhiteMove,
    );
    final second = _moverWinFor(
      evidence.candidates[1].score,
      isWhiteMove: isWhiteMove,
    );
    final third = _moverWinFor(
      evidence.candidates[2].score,
      isWhiteMove: isWhiteMove,
    );
    if (best - second <= forcedDropPp || best - third <= forcedDropPp) {
      return false;
    }
    final bestBand = _outcomeBand(
      evidence.candidates[0].score,
      best,
      isWhiteMove: isWhiteMove,
    );
    final secondBand = _outcomeBand(
      evidence.candidates[1].score,
      second,
      isWhiteMove: isWhiteMove,
    );
    return bestBand.index > secondBand.index;
  }

  List<String> _failedGates({
    required MoveClassificationEvidence evidence,
    required bool candidatesCoherent,
    required bool candidatesComplete,
    required bool bestMovePv1Consistent,
    required bool qualifiesBest,
    required int equivalentBestCount,
    required double deltaW,
    required int? cpLossMover,
    required double moverWinBefore,
    required double moverWinAfter,
    required bool brilliantMateException,
  }) => <String>[
    if (!evidence.searchQualityMet) 'best.search_quality',
    if (!candidatesCoherent) 'alternatives.coherent',
    if (!candidatesComplete) 'alternatives.complete',
    if (!bestMovePv1Consistent) 'best.bestmove_pv1_consistency',
    if (!qualifiesBest) 'best.played_root',
    if (evidence.legalMoveCount != 1) 'forced.only_legal_move',
    if (evidence.legalMoveCount == null || evidence.legalMoveCount! <= 1)
      'only_move.multiple_legal_moves',
    if (evidence.verificationState != ClassificationVerificationState.complete)
      'brilliant.deep_verification',
    if (evidence.isSacrifice != true) 'brilliant.real_sacrifice',
    if (evidence.isFirstSacrificePly != true) 'brilliant.first_sacrifice_ply',
    if (deltaW < dwExcellent) 'special.sound_delta',
    if (cpLossMover != null && cpLossMover > brilliantCpLossCap)
      'brilliant.cp_loss',
    if (moverWinBefore >= 90.0 && !brilliantMateException)
      'brilliant.already_crushing',
    if (moverWinAfter < 50.0) 'brilliant.outcome',
    if (equivalentBestCount > 1) 'special.equivalent_alternatives',
  ];

  MoveQuality _baselineQuality({
    required double deltaW,
    required int? cpLossMover,
    required double moverWinBefore,
    required double moverWinAfter,
    required bool qualifiesBest,
  }) {
    var primary = _fromWinDelta(deltaW);
    primary = _safetyNet(primary, cpLossMover);

    final wasAlreadyLost = moverWinBefore <= 10.0;
    final winningDrift =
        moverWinBefore >= 90.0 &&
        moverWinAfter >= 60.0 &&
        (cpLossMover == null || cpLossMover < 250);
    if ((wasAlreadyLost || winningDrift) && primary == MoveQuality.blunder) {
      primary = MoveQuality.mistake;
    }
    if (qualifiesBest && deltaW >= dwExcellent) return MoveQuality.best;
    return primary;
  }

  MoveQuality _fromWinDelta(double deltaW) {
    if (deltaW < dwMistake) return MoveQuality.blunder;
    if (deltaW < dwInaccuracy) return MoveQuality.mistake;
    if (deltaW < dwGood) return MoveQuality.inaccuracy;
    if (deltaW < dwExcellent) return MoveQuality.good;
    return MoveQuality.excellent;
  }

  MoveQuality _safetyNet(MoveQuality picked, int? cpLossMover) {
    if (cpLossMover == null) return picked;
    final MoveQuality cap;
    if (cpLossMover <= 60) {
      cap = MoveQuality.excellent;
    } else if (cpLossMover <= 120) {
      cap = MoveQuality.inaccuracy;
    } else if (cpLossMover <= 250) {
      cap = MoveQuality.mistake;
    } else {
      cap = MoveQuality.blunder;
    }
    return _severity(cap) < _severity(picked) ? cap : picked;
  }

  int _severity(MoveQuality quality) => switch (quality) {
    MoveQuality.brilliant ||
    MoveQuality.great ||
    MoveQuality.onlyMove ||
    MoveQuality.best ||
    MoveQuality.book => 0,
    MoveQuality.forced => 1,
    MoveQuality.excellent => 2,
    MoveQuality.good => 3,
    MoveQuality.inaccuracy || MoveQuality.missedWin => 4,
    MoveQuality.mistake => 5,
    MoveQuality.blunder => 6,
    MoveQuality.unavailable => 7,
  };

  String _baseReason(MoveQuality quality, bool qualifiesBest) {
    if (quality == MoveQuality.best && qualifiesBest) return 'pv1_best';
    return switch (quality) {
      MoveQuality.excellent => 'baseline_excellent',
      MoveQuality.good => 'baseline_solid',
      MoveQuality.inaccuracy => 'baseline_inaccuracy',
      MoveQuality.mistake => 'baseline_mistake',
      MoveQuality.blunder => 'baseline_blunder',
      MoveQuality.best => 'baseline_best',
      MoveQuality.book => 'verified_book_safe',
      MoveQuality.brilliant => 'verified_sound_sacrifice',
      MoveQuality.great => 'verified_great_move',
      MoveQuality.onlyMove => 'only_outcome_preserving_move',
      MoveQuality.forced => 'only_legal_move',
      MoveQuality.missedWin => 'missed_decisive_line',
      MoveQuality.unavailable => 'classification_unavailable',
    };
  }

  String _messageFor(MoveQuality quality) => switch (quality) {
    MoveQuality.blunder => 'Blunder - gives the opponent a decisive chance.',
    MoveQuality.mistake => 'Mistake - a stronger continuation was available.',
    MoveQuality.inaccuracy => 'Inaccuracy - a cleaner move was available.',
    MoveQuality.good => 'Solid - keeps the position playable.',
    MoveQuality.excellent => 'Excellent - strong, accurate move.',
    MoveQuality.best => 'Best move - top engine choice.',
    MoveQuality.brilliant => 'Brilliant - a verified sound sacrifice.',
    MoveQuality.great => 'Great find - verified by complete alternatives.',
    MoveQuality.onlyMove => 'Only move - the alternatives lose the outcome.',
    MoveQuality.forced => 'Forced response - the only legal move.',
    MoveQuality.book => 'Opening theory.',
    MoveQuality.missedWin => 'Missed win - a decisive line was available.',
    MoveQuality.unavailable => 'Move classification unavailable.',
  };

  double _winFor(ClassificationScore score) =>
      _win.forCp(cp: score.whiteCp, mate: score.whiteMate);

  double _moverWinFor(ClassificationScore score, {required bool isWhiteMove}) =>
      _persp.moverWinPercent(_winFor(score), isWhiteMove: isWhiteMove);

  _MateState _mateStateForMover(
    ClassificationScore score, {
    required bool isWhiteMove,
  }) {
    final mate = score.whiteMate;
    if (mate == null) return _MateState.none;
    return _persp.moverForcesMate(mate, isWhiteMove: isWhiteMove)
        ? _MateState.forMover
        : _MateState.againstMover;
  }

  _OutcomeBand _outcomeBand(
    ClassificationScore score,
    double moverWin, {
    required bool isWhiteMove,
  }) {
    final mate = _mateStateForMover(score, isWhiteMove: isWhiteMove);
    if (mate == _MateState.forMover) return _OutcomeBand.forcedWin;
    if (mate == _MateState.againstMover) return _OutcomeBand.forcedLoss;
    if (moverWin >= winningCutoff) return _OutcomeBand.winning;
    if (moverWin <= 30.0) return _OutcomeBand.losing;
    return _OutcomeBand.equal;
  }

  bool _sameMove(String? a, String? b) {
    if (a == null || b == null) return false;
    return normalizeCastlingUci(a.toLowerCase()) ==
        normalizeCastlingUci(b.toLowerCase());
  }
}

enum _MateState { againstMover, none, forMover }

enum _OutcomeBand { forcedLoss, losing, equal, winning, forcedWin }

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
