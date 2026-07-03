import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_move_quality_draft_evidence_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerMoveQualityDraftEvidenceRunner =
    Future<AnalyzerMoveQualityDraftEvidenceResult> Function(
      AnalyzerMoveQualityDraftEvidenceRequest request, {
      Duration timeout,
    });

class LocalAnalyzerDraftClassificationGateProbe {
  LocalAnalyzerDraftClassificationGateProbe({
    LocalAnalyzerMoveQualityDraftEvidenceProbe? draftEvidenceProbe,
    AnalyzerMoveQualityDraftEvidenceRunner? draftEvidenceRunner,
  }) : _draftEvidenceRunner =
           draftEvidenceRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (draftEvidenceProbe ??
                     LocalAnalyzerMoveQualityDraftEvidenceProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerMoveQualityDraftEvidenceRunner _draftEvidenceRunner;

  Future<AnalyzerDraftClassificationGateResult> run(
    AnalyzerDraftClassificationGateRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final draftEvidence = await _draftEvidenceRunner(
        AnalyzerMoveQualityDraftEvidenceRequest(
          playedMoveUci: request.playedMoveUci,
          candidateMoveUci: request.candidateMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:draftEvidence',
        ),
        timeout: timeout,
      );
      return evaluateAnalyzerDraftClassificationGate(
        request: request,
        draftEvidence: draftEvidence,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerDraftClassificationGateResult _failure({
    required AnalyzerDraftClassificationGateRequest request,
    required String failureMessage,
  }) {
    return AnalyzerDraftClassificationGateResult(
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      gateSource: request.source,
      gateModelName: analyzerDraftClassificationGateModelName,
      gateModelVersion: analyzerDraftClassificationGateModelVersion,
      draftEvidenceComputed: false,
      cpDeltaComputed: false,
      cpLossCandidateComputed: false,
      expectedPointsComputed: false,
      expectedPointsModelIsOfficial: analyzerExpectedPointsModelIsOfficial,
      draftEvidenceIsPublic: false,
      draftEvidenceIsOfficialMoveQuality: false,
      draftEvidenceIsClassifierOutput: false,
      moverPerspectiveDeltaCp: null,
      moverPerspectiveCpLossCandidate: null,
      cpLossCandidateDirection: null,
      playedExpectedPointsDelta: null,
      candidateVsPlayedExpectedPointsDelta: null,
      draftClassificationGateComputed: false,
      evidenceStructurallyEligibleForFutureClassification: false,
      evidenceHasBeforeAfterCp: false,
      evidenceHasCandidateComparison: false,
      evidenceHasExpectedPoints: false,
      evidenceIsDeveloperOnly: true,
      gateRecommendation: AnalyzerDraftClassificationGateRecommendation
          .notEligibleMissingEvidence,
      publicLabelComputed: false,
      publicLabel: null,
      officialMoveQualityComputed: false,
      officialMoveQuality: null,
      officialCpLossComputed: false,
      officialWinPercentComputed: false,
      accuracyComputed: false,
      acplComputed: false,
      classificationComputed: false,
      classifierOutputComputed: false,
      draftClassificationGateProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35N: false,
      nextRecommendation: analyzerDraftClassificationGateFailureRecommendation,
      blockers: const ['Draft classification gate proof is blocked.'],
      warnings: const [
        'This is not a successful draft classification gate proof.',
        'Do not proceed to Phase 35N yet.',
      ],
    );
  }

  String? _validateControlledRequest(
    AnalyzerDraftClassificationGateRequest request,
  ) {
    if (request.playedMoveUci != analyzerDraftClassificationGatePlayedMoveUci) {
      return 'Phase 35M accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci !=
        analyzerDraftClassificationGateCandidateMoveUci) {
      return 'Phase 35M accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerDraftClassificationGateDepth) {
      return 'Phase 35M accepts only requestedDepth=1.';
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
