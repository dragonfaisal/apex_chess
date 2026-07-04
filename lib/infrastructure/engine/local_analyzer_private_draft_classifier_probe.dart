import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_draft_classification_gate_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerDraftClassificationGateRunner =
    Future<AnalyzerDraftClassificationGateResult> Function(
      AnalyzerDraftClassificationGateRequest request, {
      Duration timeout,
    });

class LocalAnalyzerPrivateDraftClassifierProbe {
  LocalAnalyzerPrivateDraftClassifierProbe({
    LocalAnalyzerDraftClassificationGateProbe? gateProbe,
    AnalyzerDraftClassificationGateRunner? gateRunner,
  }) : _gateRunner =
           gateRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (gateProbe ?? LocalAnalyzerDraftClassificationGateProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerDraftClassificationGateRunner _gateRunner;

  Future<AnalyzerPrivateDraftClassifierResult> run(
    AnalyzerPrivateDraftClassifierRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final gate = await _gateRunner(
        AnalyzerDraftClassificationGateRequest(
          playedMoveUci: request.playedMoveUci,
          candidateMoveUci: request.candidateMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:gate',
        ),
        timeout: timeout,
      );
      return evaluateAnalyzerPrivateDraftClassifier(
        request: request,
        gate: gate,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerPrivateDraftClassifierResult _failure({
    required AnalyzerPrivateDraftClassifierRequest request,
    required String failureMessage,
  }) {
    return AnalyzerPrivateDraftClassifierResult(
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      privateClassifierSource: request.source,
      privateClassifierModelName: analyzerPrivateDraftClassifierModelName,
      privateClassifierModelVersion: analyzerPrivateDraftClassifierModelVersion,
      draftClassificationGateComputed: false,
      evidenceStructurallyEligibleForFutureClassification: false,
      evidenceIsDeveloperOnly: true,
      gateRecommendation: AnalyzerDraftClassificationGateRecommendation
          .notEligibleMissingEvidence,
      moverPerspectiveDeltaCp: null,
      moverPerspectiveCpLossCandidate: null,
      cpLossCandidateDirection: null,
      playedExpectedPointsDelta: null,
      candidateVsPlayedExpectedPointsDelta: null,
      privateDraftClassifierComputed: false,
      privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
      privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
      privateDraftConfidenceTier:
          AnalyzerPrivateDraftConfidenceTier.unavailable,
      privateDraftClassifierIsPublic: false,
      privateDraftClassifierIsOfficialMoveQuality: false,
      privateDraftClassifierIsPublicLabel: false,
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
      privateDraftClassifierProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35O: false,
      nextRecommendation: analyzerPrivateDraftClassifierFailureRecommendation,
      blockers: const ['Private draft classifier proof is blocked.'],
      warnings: const [
        'This is not a successful private draft classifier proof.',
        'Do not proceed to Phase 35O yet.',
      ],
    );
  }

  String? _validateControlledRequest(
    AnalyzerPrivateDraftClassifierRequest request,
  ) {
    if (request.playedMoveUci != analyzerPrivateDraftClassifierPlayedMoveUci) {
      return 'Phase 35N accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci !=
        analyzerPrivateDraftClassifierCandidateMoveUci) {
      return 'Phase 35N accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerPrivateDraftClassifierDepth) {
      return 'Phase 35N accepts only requestedDepth=1.';
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
