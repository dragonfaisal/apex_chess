import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_loss_candidate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_cp_loss_candidate_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerCpLossCandidateRunner =
    Future<AnalyzerCpLossCandidateResult> Function(
      AnalyzerCpLossCandidateRequest request, {
      Duration timeout,
    });

class LocalAnalyzerExpectedPointsDeltaProbe {
  LocalAnalyzerExpectedPointsDeltaProbe({
    LocalAnalyzerCpLossCandidateProbe? cpLossCandidateProbe,
    AnalyzerCpLossCandidateRunner? cpLossCandidateRunner,
    ProvisionalExpectedPointsConverter converter =
        const ProvisionalExpectedPointsConverter(),
  }) : _cpLossCandidateRunner =
           cpLossCandidateRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (cpLossCandidateProbe ??
                     LocalAnalyzerCpLossCandidateProbe())
                 .run(request, timeout: timeout);
           }),
       _converter = converter;

  final AnalyzerCpLossCandidateRunner _cpLossCandidateRunner;
  final ProvisionalExpectedPointsConverter _converter;

  Future<AnalyzerExpectedPointsDeltaResult> run(
    AnalyzerExpectedPointsDeltaRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final cpLossCandidate = await _cpLossCandidateRunner(
        AnalyzerCpLossCandidateRequest(
          beforeFen: request.beforeFen,
          playedAfterFen: request.playedAfterFen,
          candidateAfterFen: request.candidateAfterFen,
          playedMoveUci: request.playedMoveUci,
          candidateMoveUci: request.candidateMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:cpLossCandidate',
        ),
        timeout: timeout,
      );
      return _fromCpLossCandidate(
        request: request,
        cpLossCandidate: cpLossCandidate,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerExpectedPointsDeltaResult _fromCpLossCandidate({
    required AnalyzerExpectedPointsDeltaRequest request,
    required AnalyzerCpLossCandidateResult cpLossCandidate,
  }) {
    const expectedPointsModelIsOfficial = analyzerExpectedPointsModelIsOfficial;
    const officialWinPercentComputed = false;
    const officialCpLossComputed = false;
    const classificationComputed = false;
    const moveQualityComputed = false;
    const accuracyComputed = false;
    const acplComputed = false;

    final beforeCp = cpLossCandidate.beforeMoverPerspectiveCp;
    final playedAfterCp = cpLossCandidate.playedAfterMoverPerspectiveCp;
    final candidateAfterCp = cpLossCandidate.candidateAfterMoverPerspectiveCp;
    final beforeExpectedPoints = _converter.convertCp(beforeCp);
    final playedAfterExpectedPoints = _converter.convertCp(playedAfterCp);
    final candidateAfterExpectedPoints = _converter.convertCp(candidateAfterCp);
    final expectedPointsComputed =
        cpLossCandidate.cpLossCandidateProbeSucceeded &&
        beforeExpectedPoints != null &&
        playedAfterExpectedPoints != null &&
        candidateAfterExpectedPoints != null;
    final playedExpectedPointsDelta = expectedPointsComputed
        ? playedAfterExpectedPoints - beforeExpectedPoints
        : null;
    final candidateVsPlayedExpectedPointsDelta = expectedPointsComputed
        ? candidateAfterExpectedPoints - playedAfterExpectedPoints
        : null;

    final expectedPointsDeltaProbeSucceeded =
        cpLossCandidate.cpLossCandidateProbeSucceeded &&
        beforeCp != null &&
        playedAfterCp != null &&
        candidateAfterCp != null &&
        expectedPointsComputed &&
        !expectedPointsModelIsOfficial &&
        !officialWinPercentComputed &&
        !officialCpLossComputed &&
        !classificationComputed &&
        !moveQualityComputed &&
        !accuracyComputed &&
        !acplComputed;

    final blockers = <String>[];
    if (!expectedPointsDeltaProbeSucceeded) {
      blockers.add('Analyzer expected-points delta proof is blocked.');
    }
    if (!cpLossCandidate.cpLossCandidateProbeSucceeded) {
      blockers.add('CP loss candidate probe did not succeed.');
    }
    if (beforeCp == null) {
      blockers.add('Before mover-perspective CP is unavailable.');
    }
    if (playedAfterCp == null) {
      blockers.add('Played-after mover-perspective CP is unavailable.');
    }
    if (candidateAfterCp == null) {
      blockers.add('Candidate-after mover-perspective CP is unavailable.');
    }
    blockers.addAll(cpLossCandidate.blockers.map((b) => 'cpLossCandidate: $b'));

    final warnings = <String>[];
    if (!expectedPointsDeltaProbeSucceeded) {
      warnings.add('This is not a successful expected-points delta proof.');
      warnings.add('Do not proceed to Phase 35L yet.');
    }
    if (cpLossCandidate.beforeMoverPerspectiveMate != null ||
        cpLossCandidate.playedAfterMoverPerspectiveMate != null ||
        cpLossCandidate.candidateAfterMoverPerspectiveMate != null) {
      warnings.add('Mate evidence was present but not converted to CP.');
    }
    warnings.addAll(cpLossCandidate.warnings.map((w) => 'cpLossCandidate: $w'));

    final failureMessage = expectedPointsDeltaProbeSucceeded
        ? null
        : _failureMessage(
            cpLossCandidate: cpLossCandidate,
            beforeCp: beforeCp,
            playedAfterCp: playedAfterCp,
            candidateAfterCp: candidateAfterCp,
          );

    return AnalyzerExpectedPointsDeltaResult(
      beforeFen: request.beforeFen,
      playedAfterFen: request.playedAfterFen,
      candidateAfterFen: request.candidateAfterFen,
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      cpLossCandidateProbeSucceeded:
          cpLossCandidate.cpLossCandidateProbeSucceeded,
      beforeMoverPerspectiveCp: beforeCp,
      playedAfterMoverPerspectiveCp: playedAfterCp,
      candidateAfterMoverPerspectiveCp: candidateAfterCp,
      moverPerspectiveDeltaCp: cpLossCandidate.moverPerspectiveDeltaCp,
      moverPerspectiveCpLossCandidate:
          cpLossCandidate.moverPerspectiveCpLossCandidate,
      beforeExpectedPoints: beforeExpectedPoints,
      playedAfterExpectedPoints: playedAfterExpectedPoints,
      candidateAfterExpectedPoints: candidateAfterExpectedPoints,
      playedExpectedPointsDelta: playedExpectedPointsDelta,
      candidateVsPlayedExpectedPointsDelta:
          candidateVsPlayedExpectedPointsDelta,
      expectedPointsComputed: expectedPointsComputed,
      expectedPointsModelName: analyzerExpectedPointsModelName,
      expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
      expectedPointsModelIsOfficial: expectedPointsModelIsOfficial,
      officialWinPercentComputed: officialWinPercentComputed,
      officialCpLossComputed: officialCpLossComputed,
      classificationComputed: classificationComputed,
      moveQualityComputed: moveQualityComputed,
      accuracyComputed: accuracyComputed,
      acplComputed: acplComputed,
      expectedPointsDeltaProbeSucceeded: expectedPointsDeltaProbeSucceeded,
      failureMessage: failureMessage,
      safeForPhase35L: expectedPointsDeltaProbeSucceeded,
      nextRecommendation: expectedPointsDeltaProbeSucceeded
          ? analyzerExpectedPointsNextRecommendation
          : analyzerExpectedPointsFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  AnalyzerExpectedPointsDeltaResult _failure({
    required AnalyzerExpectedPointsDeltaRequest request,
    required String failureMessage,
  }) {
    return AnalyzerExpectedPointsDeltaResult(
      beforeFen: request.beforeFen,
      playedAfterFen: request.playedAfterFen,
      candidateAfterFen: request.candidateAfterFen,
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      cpLossCandidateProbeSucceeded: false,
      beforeMoverPerspectiveCp: null,
      playedAfterMoverPerspectiveCp: null,
      candidateAfterMoverPerspectiveCp: null,
      moverPerspectiveDeltaCp: null,
      moverPerspectiveCpLossCandidate: null,
      beforeExpectedPoints: null,
      playedAfterExpectedPoints: null,
      candidateAfterExpectedPoints: null,
      playedExpectedPointsDelta: null,
      candidateVsPlayedExpectedPointsDelta: null,
      expectedPointsComputed: false,
      expectedPointsModelName: analyzerExpectedPointsModelName,
      expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
      expectedPointsModelIsOfficial: analyzerExpectedPointsModelIsOfficial,
      officialWinPercentComputed: false,
      officialCpLossComputed: false,
      classificationComputed: false,
      moveQualityComputed: false,
      accuracyComputed: false,
      acplComputed: false,
      expectedPointsDeltaProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35L: false,
      nextRecommendation: analyzerExpectedPointsFailureRecommendation,
      blockers: const ['Analyzer expected-points delta proof is blocked.'],
      warnings: const [
        'This is not a successful expected-points delta proof.',
        'Do not proceed to Phase 35L yet.',
      ],
    );
  }

  String? _validateControlledRequest(
    AnalyzerExpectedPointsDeltaRequest request,
  ) {
    if (request.beforeFen != analyzerExpectedPointsBeforeFen) {
      return 'Phase 35K accepts only the controlled before FEN.';
    }
    if (request.playedAfterFen != analyzerExpectedPointsPlayedAfterFen) {
      return 'Phase 35K accepts only the proven controlled played-after FEN.';
    }
    if (request.candidateAfterFen != analyzerExpectedPointsCandidateAfterFen) {
      return 'Phase 35K accepts only the controlled candidate-after FEN.';
    }
    if (request.playedMoveUci != analyzerExpectedPointsPlayedMoveUci) {
      return 'Phase 35K accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci != analyzerExpectedPointsCandidateMoveUci) {
      return 'Phase 35K accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerExpectedPointsDepth) {
      return 'Phase 35K accepts only requestedDepth=1.';
    }
    return null;
  }

  String _failureMessage({
    required AnalyzerCpLossCandidateResult cpLossCandidate,
    required int? beforeCp,
    required int? playedAfterCp,
    required int? candidateAfterCp,
  }) {
    if (beforeCp == null) return 'Before mover-perspective CP is unavailable.';
    if (playedAfterCp == null) {
      return 'Played-after mover-perspective CP is unavailable.';
    }
    if (candidateAfterCp == null) {
      return 'Candidate-after mover-perspective CP is unavailable.';
    }
    if (!cpLossCandidate.cpLossCandidateProbeSucceeded) {
      return cpLossCandidate.failureMessage ??
          'CP loss candidate probe did not succeed.';
    }
    return 'Analyzer expected-points delta proof did not succeed.';
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
