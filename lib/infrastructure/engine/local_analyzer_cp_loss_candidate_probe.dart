import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_loss_candidate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_single_fen_raw_eval_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerCpLossSingleFenRunner =
    Future<AnalyzerRawEvalResult> Function(
      AnalyzerSingleFenRawEvalRequest request, {
      Duration timeout,
    });

class LocalAnalyzerCpLossCandidateProbe {
  LocalAnalyzerCpLossCandidateProbe({
    LocalAnalyzerSingleFenRawEvalAdapter? adapter,
    AnalyzerCpLossSingleFenRunner? singleFenRunner,
  }) : _singleFenRunner =
           singleFenRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             final effectiveAdapter =
                 adapter ??
                 LocalAnalyzerSingleFenRawEvalAdapter(
                   allowedControlledFens: analyzerCpLossCandidateControlledFens,
                 );
             return effectiveAdapter.evaluate(request, timeout: timeout);
           });

  final AnalyzerCpLossSingleFenRunner _singleFenRunner;

  Future<AnalyzerCpLossCandidateResult> run(
    AnalyzerCpLossCandidateRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final requestedPlayerColor = request.moverColor.requestedPlayerColor;
      final before = await _singleFenRunner(
        AnalyzerSingleFenRawEvalRequest(
          fen: request.beforeFen,
          requestedDepth: request.requestedDepth,
          requestedPlayerColor: requestedPlayerColor,
          source: '${request.source}:before',
        ),
        timeout: timeout,
      );
      final playedAfter = await _singleFenRunner(
        AnalyzerSingleFenRawEvalRequest(
          fen: request.playedAfterFen,
          requestedDepth: request.requestedDepth,
          requestedPlayerColor: requestedPlayerColor,
          source: '${request.source}:playedAfter',
        ),
        timeout: timeout,
      );
      final candidateAfter = await _singleFenRunner(
        AnalyzerSingleFenRawEvalRequest(
          fen: request.candidateAfterFen,
          requestedDepth: request.requestedDepth,
          requestedPlayerColor: requestedPlayerColor,
          source: '${request.source}:candidateAfter',
        ),
        timeout: timeout,
      );

      return _fromSingleFenResults(
        request: request,
        before: before,
        playedAfter: playedAfter,
        candidateAfter: candidateAfter,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerCpLossCandidateResult _fromSingleFenResults({
    required AnalyzerCpLossCandidateRequest request,
    required AnalyzerRawEvalResult before,
    required AnalyzerRawEvalResult playedAfter,
    required AnalyzerRawEvalResult candidateAfter,
  }) {
    const officialCpLossComputed = false;
    const winPercentComputed = false;
    const classificationComputed = false;
    const moveQualityComputed = false;
    const accuracyComputed = false;

    final beforeEvalSucceeded = before.analyzerRawEvalSucceeded;
    final playedAfterEvalSucceeded = playedAfter.analyzerRawEvalSucceeded;
    final candidateAfterEvalSucceeded = candidateAfter.analyzerRawEvalSucceeded;
    final beforeCp = before.playerPerspectiveCp;
    final playedAfterCp = playedAfter.playerPerspectiveCp;
    final candidateAfterCp = candidateAfter.playerPerspectiveCp;

    final cpDeltaComputed =
        beforeEvalSucceeded &&
        playedAfterEvalSucceeded &&
        beforeCp != null &&
        playedAfterCp != null;
    final moverPerspectiveDeltaCp = cpDeltaComputed
        ? playedAfterCp - beforeCp
        : null;
    final cpLossCandidateComputed =
        playedAfterEvalSucceeded &&
        candidateAfterEvalSucceeded &&
        playedAfterCp != null &&
        candidateAfterCp != null;
    final moverPerspectiveCpLossCandidate = cpLossCandidateComputed
        ? candidateAfterCp - playedAfterCp
        : null;
    final cpLossCandidateDirection = _direction(
      moverPerspectiveCpLossCandidate,
    );

    final cpLossCandidateProbeSucceeded =
        beforeEvalSucceeded &&
        playedAfterEvalSucceeded &&
        candidateAfterEvalSucceeded &&
        playedAfterCp != null &&
        candidateAfterCp != null &&
        cpLossCandidateComputed &&
        !officialCpLossComputed &&
        !winPercentComputed &&
        !classificationComputed &&
        !moveQualityComputed &&
        !accuracyComputed;

    final blockers = <String>[];
    if (!cpLossCandidateProbeSucceeded) {
      blockers.add('Analyzer CP loss candidate proof is blocked.');
    }
    if (!beforeEvalSucceeded) {
      blockers.add('Before-position raw eval did not succeed.');
    }
    if (!playedAfterEvalSucceeded) {
      blockers.add('Played-after raw eval did not succeed.');
    }
    if (!candidateAfterEvalSucceeded) {
      blockers.add('Candidate-after raw eval did not succeed.');
    }
    if (playedAfterCp == null) {
      blockers.add('Played-after mover-perspective CP is unavailable.');
    }
    if (candidateAfterCp == null) {
      blockers.add('Candidate-after mover-perspective CP is unavailable.');
    }
    blockers.addAll(before.blockers.map((b) => 'before: $b'));
    blockers.addAll(playedAfter.blockers.map((b) => 'playedAfter: $b'));
    blockers.addAll(candidateAfter.blockers.map((b) => 'candidateAfter: $b'));

    final warnings = <String>[];
    if (!cpLossCandidateProbeSucceeded) {
      warnings.add('This is not a successful CP loss candidate proof.');
      warnings.add('Do not proceed to Phase 35K yet.');
    }
    if (before.playerPerspectiveMate != null ||
        playedAfter.playerPerspectiveMate != null ||
        candidateAfter.playerPerspectiveMate != null) {
      warnings.add('Mate evidence was present but not converted to CP.');
    }
    warnings.addAll(before.warnings.map((w) => 'before: $w'));
    warnings.addAll(playedAfter.warnings.map((w) => 'playedAfter: $w'));
    warnings.addAll(candidateAfter.warnings.map((w) => 'candidateAfter: $w'));

    final failureMessage = cpLossCandidateProbeSucceeded
        ? null
        : _failureMessage(
            before: before,
            playedAfter: playedAfter,
            candidateAfter: candidateAfter,
            playedAfterCp: playedAfterCp,
            candidateAfterCp: candidateAfterCp,
          );

    return AnalyzerCpLossCandidateResult(
      beforeFen: request.beforeFen,
      playedAfterFen: request.playedAfterFen,
      candidateAfterFen: request.candidateAfterFen,
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      beforeEvalSucceeded: beforeEvalSucceeded,
      beforeMoverPerspectiveCp: beforeCp,
      beforeMoverPerspectiveMate: before.playerPerspectiveMate,
      beforeBestMove: before.bestMove,
      beforeBestMoveReceived: before.bestMoveReceived,
      playedAfterEvalSucceeded: playedAfterEvalSucceeded,
      playedAfterMoverPerspectiveCp: playedAfterCp,
      playedAfterMoverPerspectiveMate: playedAfter.playerPerspectiveMate,
      playedAfterBestMove: playedAfter.bestMove,
      playedAfterBestMoveReceived: playedAfter.bestMoveReceived,
      candidateAfterEvalSucceeded: candidateAfterEvalSucceeded,
      candidateAfterMoverPerspectiveCp: candidateAfterCp,
      candidateAfterMoverPerspectiveMate: candidateAfter.playerPerspectiveMate,
      candidateAfterBestMove: candidateAfter.bestMove,
      candidateAfterBestMoveReceived: candidateAfter.bestMoveReceived,
      cpDeltaComputed: cpDeltaComputed,
      moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
      cpLossCandidateComputed: cpLossCandidateComputed,
      moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
      cpLossCandidateDirection: cpLossCandidateDirection,
      officialCpLossComputed: officialCpLossComputed,
      winPercentComputed: winPercentComputed,
      classificationComputed: classificationComputed,
      moveQualityComputed: moveQualityComputed,
      accuracyComputed: accuracyComputed,
      cpLossCandidateProbeSucceeded: cpLossCandidateProbeSucceeded,
      failureMessage: failureMessage,
      safeForPhase35K: cpLossCandidateProbeSucceeded,
      nextRecommendation: cpLossCandidateProbeSucceeded
          ? analyzerCpLossCandidateNextRecommendation
          : analyzerCpLossCandidateFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  AnalyzerCpLossCandidateResult _failure({
    required AnalyzerCpLossCandidateRequest request,
    required String failureMessage,
  }) {
    return AnalyzerCpLossCandidateResult(
      beforeFen: request.beforeFen,
      playedAfterFen: request.playedAfterFen,
      candidateAfterFen: request.candidateAfterFen,
      playedMoveUci: request.playedMoveUci,
      candidateMoveUci: request.candidateMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      beforeEvalSucceeded: false,
      beforeMoverPerspectiveCp: null,
      beforeMoverPerspectiveMate: null,
      beforeBestMove: null,
      beforeBestMoveReceived: false,
      playedAfterEvalSucceeded: false,
      playedAfterMoverPerspectiveCp: null,
      playedAfterMoverPerspectiveMate: null,
      playedAfterBestMove: null,
      playedAfterBestMoveReceived: false,
      candidateAfterEvalSucceeded: false,
      candidateAfterMoverPerspectiveCp: null,
      candidateAfterMoverPerspectiveMate: null,
      candidateAfterBestMove: null,
      candidateAfterBestMoveReceived: false,
      cpDeltaComputed: false,
      moverPerspectiveDeltaCp: null,
      cpLossCandidateComputed: false,
      moverPerspectiveCpLossCandidate: null,
      cpLossCandidateDirection: AnalyzerCpLossCandidateDirection.unavailable,
      officialCpLossComputed: false,
      winPercentComputed: false,
      classificationComputed: false,
      moveQualityComputed: false,
      accuracyComputed: false,
      cpLossCandidateProbeSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35K: false,
      nextRecommendation: analyzerCpLossCandidateFailureRecommendation,
      blockers: const ['Analyzer CP loss candidate proof is blocked.'],
      warnings: const [
        'This is not a successful CP loss candidate proof.',
        'Do not proceed to Phase 35K yet.',
      ],
    );
  }

  AnalyzerCpLossCandidateDirection _direction(int? cpLossCandidate) {
    if (cpLossCandidate == null) {
      return AnalyzerCpLossCandidateDirection.unavailable;
    }
    if (cpLossCandidate > 0) {
      return AnalyzerCpLossCandidateDirection.candidateBetter;
    }
    if (cpLossCandidate < 0) {
      return AnalyzerCpLossCandidateDirection.playedBetter;
    }
    return AnalyzerCpLossCandidateDirection.equal;
  }

  String? _validateControlledRequest(AnalyzerCpLossCandidateRequest request) {
    if (request.beforeFen != analyzerCpLossCandidateBeforeFen) {
      return 'Phase 35J accepts only the controlled before FEN.';
    }
    if (request.playedAfterFen != analyzerCpLossCandidatePlayedAfterFen) {
      return 'Phase 35J accepts only the controlled played-after FEN.';
    }
    if (request.candidateAfterFen != analyzerCpLossCandidateCandidateAfterFen) {
      return 'Phase 35J accepts only the controlled candidate-after FEN.';
    }
    if (request.playedMoveUci != analyzerCpLossCandidatePlayedMoveUci) {
      return 'Phase 35J accepts only playedMoveUci=e2e4.';
    }
    if (request.candidateMoveUci != analyzerCpLossCandidateCandidateMoveUci) {
      return 'Phase 35J accepts only candidateMoveUci=e2e3.';
    }
    if (request.requestedDepth != analyzerCpLossCandidateDepth) {
      return 'Phase 35J accepts only requestedDepth=1.';
    }
    return null;
  }

  String _failureMessage({
    required AnalyzerRawEvalResult before,
    required AnalyzerRawEvalResult playedAfter,
    required AnalyzerRawEvalResult candidateAfter,
    required int? playedAfterCp,
    required int? candidateAfterCp,
  }) {
    if (!before.analyzerRawEvalSucceeded) {
      return 'Before eval failed: '
          '${before.failureMessage ?? 'analyzer raw eval did not succeed'}.';
    }
    if (!playedAfter.analyzerRawEvalSucceeded) {
      return 'Played-after eval failed: '
          '${playedAfter.failureMessage ?? 'analyzer raw eval did not succeed'}.';
    }
    if (!candidateAfter.analyzerRawEvalSucceeded) {
      return 'Candidate-after eval failed: '
          '${candidateAfter.failureMessage ?? 'analyzer raw eval did not succeed'}.';
    }
    if (playedAfterCp == null && candidateAfterCp == null) {
      return 'Played-after and candidate-after mover-perspective CP are unavailable.';
    }
    if (playedAfterCp == null) {
      return 'Played-after mover-perspective CP is unavailable.';
    }
    if (candidateAfterCp == null) {
      return 'Candidate-after mover-perspective CP is unavailable.';
    }
    return 'Analyzer CP loss candidate proof did not succeed.';
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
