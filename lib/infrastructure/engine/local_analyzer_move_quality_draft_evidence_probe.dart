import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_expected_points_delta_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerExpectedPointsDeltaRunner =
    Future<AnalyzerExpectedPointsDeltaResult> Function(
      AnalyzerExpectedPointsDeltaRequest request, {
      Duration timeout,
    });

class LocalAnalyzerMoveQualityDraftEvidenceProbe {
  LocalAnalyzerMoveQualityDraftEvidenceProbe({
    LocalAnalyzerExpectedPointsDeltaProbe? expectedPointsProbe,
    AnalyzerExpectedPointsDeltaRunner? expectedPointsRunner,
  }) : _expectedPointsRunner =
           expectedPointsRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (expectedPointsProbe ??
                     LocalAnalyzerExpectedPointsDeltaProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerExpectedPointsDeltaRunner _expectedPointsRunner;

  Future<AnalyzerMoveQualityDraftEvidenceResult> run(
    AnalyzerMoveQualityDraftEvidenceRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final expectedPoints = await _expectedPointsRunner(
        AnalyzerExpectedPointsDeltaRequest(
          beforeFen: analyzerExpectedPointsBeforeFen,
          playedAfterFen: analyzerExpectedPointsPlayedAfterFen,
          candidateAfterFen: analyzerExpectedPointsCandidateAfterFen,
          playedMoveUci: request.playedMoveUci,
          candidateMoveUci: request.candidateMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:expectedPoints',
        ),
        timeout: timeout,
      );
      return _fromExpectedPoints(
        request: request,
        expectedPoints: expectedPoints,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerMoveQualityDraftEvidenceResult _fromExpectedPoints({
    required AnalyzerMoveQualityDraftEvidenceRequest request,
    required AnalyzerExpectedPointsDeltaResult expectedPoints,
  }) {
    const draftEvidenceIsPublic = false;
    const draftEvidenceIsOfficialMoveQuality = false;
    const draftEvidenceIsClassifierOutput = false;
    const publicLabelComputed = false;
    const officialMoveQualityComputed = false;
    const officialCpLossComputed = false;
    const officialWinPercentComputed = false;
    const accuracyComputed = false;
    const acplComputed = false;
    const classificationComputed = false;

    final cpEvidencePresent =
        expectedPoints.beforeMoverPerspectiveCp != null &&
        expectedPoints.playedAfterMoverPerspectiveCp != null &&
        expectedPoints.candidateAfterMoverPerspectiveCp != null &&
        expectedPoints.moverPerspectiveDeltaCp != null &&
        expectedPoints.moverPerspectiveCpLossCandidate != null;
    final expectedPointsEvidencePresent =
        expectedPoints.beforeExpectedPoints != null &&
        expectedPoints.playedAfterExpectedPoints != null &&
        expectedPoints.candidateAfterExpectedPoints != null &&
        expectedPoints.playedExpectedPointsDelta != null &&
        expectedPoints.candidateVsPlayedExpectedPointsDelta != null &&
        expectedPoints.expectedPointsComputed;
    final draftEvidenceComputed =
        expectedPoints.expectedPointsDeltaProbeSucceeded &&
        cpEvidencePresent &&
        expectedPointsEvidencePresent;
    final succeeded =
        draftEvidenceComputed &&
        !draftEvidenceIsPublic &&
        !draftEvidenceIsOfficialMoveQuality &&
        !draftEvidenceIsClassifierOutput &&
        !publicLabelComputed &&
        !officialMoveQualityComputed &&
        !officialCpLossComputed &&
        !officialWinPercentComputed &&
        !accuracyComputed &&
        !acplComputed &&
        !classificationComputed;

    final blockers = <String>[];
    if (!succeeded) {
      blockers.add('Move quality draft evidence proof is blocked.');
    }
    if (!expectedPoints.expectedPointsDeltaProbeSucceeded) {
      blockers.add('Expected-points delta probe did not succeed.');
    }
    if (!cpEvidencePresent) {
      blockers.add('Required CP evidence is incomplete.');
    }
    if (!expectedPointsEvidencePresent) {
      blockers.add('Required expected-points evidence is incomplete.');
    }
    blockers.addAll(expectedPoints.blockers.map((b) => 'expectedPoints: $b'));

    final warnings = <String>[];
    if (!succeeded) {
      warnings.add('This is not a successful draft evidence proof.');
      warnings.add('Do not proceed to Phase 35M yet.');
    }
    warnings.addAll(expectedPoints.warnings.map((w) => 'expectedPoints: $w'));

    final failureMessage = succeeded
        ? null
        : _failureMessage(
            expectedPoints: expectedPoints,
            cpEvidencePresent: cpEvidencePresent,
            expectedPointsEvidencePresent: expectedPointsEvidencePresent,
          );

    return AnalyzerMoveQualityDraftEvidenceResult(
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      evidenceSource: request.source,
      evidenceModelName: analyzerMoveQualityDraftEvidenceModelName,
      evidenceModelVersion: analyzerMoveQualityDraftEvidenceModelVersion,
      beforeMoverPerspectiveCp: expectedPoints.beforeMoverPerspectiveCp,
      playedAfterMoverPerspectiveCp:
          expectedPoints.playedAfterMoverPerspectiveCp,
      candidateAfterMoverPerspectiveCp:
          expectedPoints.candidateAfterMoverPerspectiveCp,
      moverPerspectiveDeltaCp: expectedPoints.moverPerspectiveDeltaCp,
      moverPerspectiveCpLossCandidate:
          expectedPoints.moverPerspectiveCpLossCandidate,
      cpDeltaComputed: expectedPoints.moverPerspectiveDeltaCp != null,
      cpLossCandidateComputed:
          expectedPoints.moverPerspectiveCpLossCandidate != null,
      cpLossCandidateDirection: _cpLossCandidateDirection(
        expectedPoints.moverPerspectiveCpLossCandidate,
      ),
      expectedPointsModelName: expectedPoints.expectedPointsModelName,
      expectedPointsModelVersion: expectedPoints.expectedPointsModelVersion,
      expectedPointsModelIsOfficial:
          expectedPoints.expectedPointsModelIsOfficial,
      beforeExpectedPoints: expectedPoints.beforeExpectedPoints,
      playedAfterExpectedPoints: expectedPoints.playedAfterExpectedPoints,
      candidateAfterExpectedPoints: expectedPoints.candidateAfterExpectedPoints,
      playedExpectedPointsDelta: expectedPoints.playedExpectedPointsDelta,
      candidateVsPlayedExpectedPointsDelta:
          expectedPoints.candidateVsPlayedExpectedPointsDelta,
      expectedPointsComputed: expectedPoints.expectedPointsComputed,
      draftEvidenceComputed: draftEvidenceComputed,
      draftEvidenceIsPublic: draftEvidenceIsPublic,
      draftEvidenceIsOfficialMoveQuality: draftEvidenceIsOfficialMoveQuality,
      draftEvidenceIsClassifierOutput: draftEvidenceIsClassifierOutput,
      publicLabelComputed: publicLabelComputed,
      officialMoveQualityComputed: officialMoveQualityComputed,
      officialCpLossComputed: officialCpLossComputed,
      officialWinPercentComputed: officialWinPercentComputed,
      accuracyComputed: accuracyComputed,
      acplComputed: acplComputed,
      classificationComputed: classificationComputed,
      moveQualityDraftEvidenceProbeSucceeded: succeeded,
      failureMessage: failureMessage,
      safeForPhase35M: succeeded,
      nextRecommendation: succeeded
          ? analyzerMoveQualityDraftEvidenceNextRecommendation
          : analyzerMoveQualityDraftEvidenceFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  AnalyzerMoveQualityDraftEvidenceResult _failure({
    required AnalyzerMoveQualityDraftEvidenceRequest request,
    required String failureMessage,
  }) {
    return AnalyzerMoveQualityDraftEvidenceResult(
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      evidenceSource: request.source,
      evidenceModelName: analyzerMoveQualityDraftEvidenceModelName,
      evidenceModelVersion: analyzerMoveQualityDraftEvidenceModelVersion,
      beforeMoverPerspectiveCp: null,
      playedAfterMoverPerspectiveCp: null,
      candidateAfterMoverPerspectiveCp: null,
      moverPerspectiveDeltaCp: null,
      moverPerspectiveCpLossCandidate: null,
      cpDeltaComputed: false,
      cpLossCandidateComputed: false,
      cpLossCandidateDirection: null,
      expectedPointsModelName: analyzerExpectedPointsModelName,
      expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
      expectedPointsModelIsOfficial: analyzerExpectedPointsModelIsOfficial,
      beforeExpectedPoints: null,
      playedAfterExpectedPoints: null,
      candidateAfterExpectedPoints: null,
      playedExpectedPointsDelta: null,
      candidateVsPlayedExpectedPointsDelta: null,
      expectedPointsComputed: false,
      draftEvidenceComputed: false,
      draftEvidenceIsPublic: false,
      draftEvidenceIsOfficialMoveQuality: false,
      draftEvidenceIsClassifierOutput: false,
      publicLabelComputed: false,
      officialMoveQualityComputed: false,
      officialCpLossComputed: false,
      officialWinPercentComputed: false,
      accuracyComputed: false,
      acplComputed: false,
      classificationComputed: false,
      moveQualityDraftEvidenceProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35M: false,
      nextRecommendation: analyzerMoveQualityDraftEvidenceFailureRecommendation,
      blockers: const ['Move quality draft evidence proof is blocked.'],
      warnings: const [
        'This is not a successful draft evidence proof.',
        'Do not proceed to Phase 35M yet.',
      ],
    );
  }

  String? _validateControlledRequest(
    AnalyzerMoveQualityDraftEvidenceRequest request,
  ) {
    if (request.playedMoveUci !=
        analyzerMoveQualityDraftEvidencePlayedMoveUci) {
      return 'Phase 35L accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci !=
        analyzerMoveQualityDraftEvidenceCandidateMoveUci) {
      return 'Phase 35L accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerMoveQualityDraftEvidenceDepth) {
      return 'Phase 35L accepts only requestedDepth=1.';
    }
    return null;
  }

  String _failureMessage({
    required AnalyzerExpectedPointsDeltaResult expectedPoints,
    required bool cpEvidencePresent,
    required bool expectedPointsEvidencePresent,
  }) {
    if (!expectedPoints.expectedPointsDeltaProbeSucceeded) {
      return expectedPoints.failureMessage ??
          'Expected-points delta probe did not succeed.';
    }
    if (!cpEvidencePresent) return 'Required CP evidence is incomplete.';
    if (!expectedPointsEvidencePresent) {
      return 'Required expected-points evidence is incomplete.';
    }
    return 'Move quality draft evidence proof did not succeed.';
  }

  String _cpLossCandidateDirection(int? value) {
    if (value == null) return 'unavailable';
    if (value > 0) return 'candidateBetter';
    if (value < 0) return 'playedBetter';
    return 'equal';
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
