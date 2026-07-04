import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_private_single_move_draft_analysis_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerPrivateSingleMoveDraftAnalysisRunner =
    Future<AnalyzerPrivateSingleMoveDraftAnalysisResult> Function(
      AnalyzerPrivateSingleMoveDraftAnalysisRequest request, {
      Duration timeout,
    });

class LocalAnalyzerLegacyReintegrationProbe {
  LocalAnalyzerLegacyReintegrationProbe({
    LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe? phase35QProbe,
    AnalyzerPrivateSingleMoveDraftAnalysisRunner? phase35QRunner,
  }) : _phase35QRunner =
           phase35QRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (phase35QProbe ??
                     LocalAnalyzerPrivateSingleMoveDraftAnalysisProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerPrivateSingleMoveDraftAnalysisRunner _phase35QRunner;

  Future<AnalyzerLegacyReintegrationResult> run(
    AnalyzerLegacyReintegrationRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final phase35Q = await _phase35QRunner(
        AnalyzerPrivateSingleMoveDraftAnalysisRequest(
          playedMoveUci: request.playedMoveUci,
          candidateMoveUci: request.candidateMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:phase35Q',
        ),
        timeout: timeout,
      );
      return evaluateAnalyzerLegacyReintegration(
        request: request,
        phase35Q: phase35Q,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerLegacyReintegrationResult _failure({
    required AnalyzerLegacyReintegrationRequest request,
    required String failureMessage,
  }) {
    return AnalyzerLegacyReintegrationResult(
      legacyReintegrationResultId: 'phase36A:${request.playedMoveUci}:blocked',
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      reintegrationSource: request.source,
      reintegrationModelName: analyzerLegacyReintegrationModelName,
      reintegrationModelVersion: analyzerLegacyReintegrationModelVersion,
      phase35QAnalysisResultId: 'unavailable',
      privateSingleMoveDraftAnalysisComputed: false,
      privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
      privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
      privateDraftConfidenceTier:
          AnalyzerPrivateDraftConfidenceTier.unavailable,
      legacyReintegrationComputed: false,
      legacyReintegrationIsPublic: false,
      legacyReintegrationIsProductReview: false,
      legacyReintegrationIsSavedAnalysis: false,
      legacyReintegrationIsOfficial: false,
      legacyPublicLabelProduced: false,
      legacyOfficialMoveQualityProduced: false,
      legacySavedAnalysisWritten: false,
      legacyUiOutputProduced: false,
      legacyArchiveStatsTouched: false,
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
      legacyReintegrationProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase36B: false,
      nextRecommendation: analyzerLegacyReintegrationFailureRecommendation,
      blockers: const ['Legacy reintegration proof is blocked.'],
      warnings: const [
        'This is not a successful legacy reintegration proof.',
        'Do not proceed to Phase 36B yet.',
      ],
    );
  }

  String? _validateControlledRequest(
    AnalyzerLegacyReintegrationRequest request,
  ) {
    if (request.playedMoveUci != analyzerLegacyReintegrationPlayedMoveUci) {
      return 'Phase 36A accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci !=
        analyzerLegacyReintegrationCandidateMoveUci) {
      return 'Phase 36A accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerLegacyReintegrationDepth) {
      return 'Phase 36A accepts only requestedDepth=1.';
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
