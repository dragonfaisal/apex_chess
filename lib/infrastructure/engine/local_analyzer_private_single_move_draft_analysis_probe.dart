import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_private_draft_classifier_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerPrivateDraftClassifierRunner =
    Future<AnalyzerPrivateDraftClassifierResult> Function(
      AnalyzerPrivateDraftClassifierRequest request, {
      Duration timeout,
    });

class LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe {
  LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe({
    LocalAnalyzerPrivateDraftClassifierProbe? privateClassifierProbe,
    AnalyzerPrivateDraftClassifierRunner? privateClassifierRunner,
  }) : _privateClassifierRunner =
           privateClassifierRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (privateClassifierProbe ??
                     LocalAnalyzerPrivateDraftClassifierProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerPrivateDraftClassifierRunner _privateClassifierRunner;

  Future<AnalyzerPrivateSingleMoveDraftAnalysisResult> run(
    AnalyzerPrivateSingleMoveDraftAnalysisRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final privateClassifier = await _privateClassifierRunner(
        AnalyzerPrivateDraftClassifierRequest(
          playedMoveUci: request.playedMoveUci,
          candidateMoveUci: request.candidateMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:privateClassifier',
        ),
        timeout: timeout,
      );
      return evaluateAnalyzerPrivateSingleMoveDraftAnalysis(
        request: request,
        privateClassifier: privateClassifier,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerPrivateSingleMoveDraftAnalysisResult _failure({
    required AnalyzerPrivateSingleMoveDraftAnalysisRequest request,
    required String failureMessage,
  }) {
    return AnalyzerPrivateSingleMoveDraftAnalysisResult(
      analysisResultId: 'phase35Q:${request.playedMoveUci}:blocked',
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      analysisSource: request.source,
      analysisModelName: analyzerPrivateSingleMoveDraftAnalysisModelName,
      analysisModelVersion: analyzerPrivateSingleMoveDraftAnalysisModelVersion,
      beforeMoverPerspectiveCp: null,
      playedAfterMoverPerspectiveCp: null,
      candidateAfterMoverPerspectiveCp: null,
      moverPerspectiveDeltaCp: null,
      moverPerspectiveCpLossCandidate: null,
      cpDeltaComputed: false,
      cpLossCandidateComputed: false,
      cpLossCandidateDirection: null,
      expectedPointsComputed: false,
      expectedPointsModelName: null,
      expectedPointsModelVersion: null,
      expectedPointsModelIsOfficial: false,
      beforeExpectedPoints: null,
      playedAfterExpectedPoints: null,
      candidateAfterExpectedPoints: null,
      playedExpectedPointsDelta: null,
      candidateVsPlayedExpectedPointsDelta: null,
      draftClassificationGateComputed: false,
      evidenceStructurallyEligibleForFutureClassification: false,
      evidenceIsDeveloperOnly: true,
      gateRecommendation: AnalyzerDraftClassificationGateRecommendation
          .notEligibleMissingEvidence,
      privateDraftClassifierComputed: false,
      privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
      privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
      privateDraftConfidenceTier:
          AnalyzerPrivateDraftConfidenceTier.unavailable,
      privateDraftClassifierIsPublic: false,
      privateDraftClassifierIsOfficialMoveQuality: false,
      privateDraftClassifierIsPublicLabel: false,
      privateSingleMoveDraftAnalysisComputed: false,
      privateSingleMoveDraftAnalysisIsPublic: false,
      privateSingleMoveDraftAnalysisIsProductReview: false,
      privateSingleMoveDraftAnalysisIsSavedAnalysis: false,
      privateSingleMoveDraftAnalysisIsOfficial: false,
      publicLabelComputed: false,
      publicLabel: null,
      officialMoveQualityComputed: false,
      officialMoveQuality: null,
      officialCpLossComputed: false,
      officialWinPercentComputed: false,
      accuracyComputed: false,
      acplComputed: false,
      classificationComputed: false,
      publicClassifierOutputComputed: false,
      savedAnalysisWritten: false,
      uiOutputProduced: false,
      privateSingleMoveDraftAnalysisProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase36A: false,
      nextRecommendation:
          analyzerPrivateSingleMoveDraftAnalysisFailureRecommendation,
      blockers: const ['Private single-move draft analysis proof is blocked.'],
      warnings: const [
        'This is not a successful private single-move draft analysis proof.',
        'Do not proceed to Phase 36A yet.',
      ],
    );
  }

  String? _validateControlledRequest(
    AnalyzerPrivateSingleMoveDraftAnalysisRequest request,
  ) {
    if (request.playedMoveUci !=
        analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci) {
      return 'Phase 35Q accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci !=
        analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci) {
      return 'Phase 35Q accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerPrivateSingleMoveDraftAnalysisDepth) {
      return 'Phase 35Q accepts only requestedDepth=1.';
    }
    return null;
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
