import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_delta.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_before_after_raw_eval_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerBeforeAfterRawEvalRunner =
    Future<AnalyzerBeforeAfterRawEvalResult> Function(
      AnalyzerBeforeAfterRawEvalRequest request, {
      Duration timeout,
    });

class LocalAnalyzerCpDeltaProbe {
  LocalAnalyzerCpDeltaProbe({
    LocalAnalyzerBeforeAfterRawEvalProbe? beforeAfterProbe,
    AnalyzerBeforeAfterRawEvalRunner? beforeAfterRunner,
  }) : _beforeAfterRunner =
           beforeAfterRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (beforeAfterProbe ?? LocalAnalyzerBeforeAfterRawEvalProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerBeforeAfterRawEvalRunner _beforeAfterRunner;

  Future<AnalyzerCpDeltaResult> run(
    AnalyzerCpDeltaRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    final invalidReason = _validateControlledRequest(request);
    if (invalidReason != null) {
      return _failure(request: request, failureMessage: invalidReason);
    }

    try {
      final beforeAfter = await _beforeAfterRunner(
        AnalyzerBeforeAfterRawEvalRequest(
          beforeFen: request.beforeFen,
          afterFen: request.afterFen,
          playedMoveUci: request.playedMoveUci,
          moverColor: request.moverColor,
          requestedDepth: request.requestedDepth,
          source: '${request.source}:beforeAfter',
        ),
        timeout: timeout,
      );
      return _fromBeforeAfter(request: request, beforeAfter: beforeAfter);
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerCpDeltaResult _fromBeforeAfter({
    required AnalyzerCpDeltaRequest request,
    required AnalyzerBeforeAfterRawEvalResult beforeAfter,
  }) {
    const cpLossComputed = false;
    const winPercentComputed = false;
    const classificationComputed = false;
    const moveQualityComputed = false;

    final beforeCp = beforeAfter.moverPerspectiveBeforeCp;
    final afterCp = beforeAfter.moverPerspectiveAfterCp;
    final cpDeltaComputed =
        beforeAfter.beforeAfterRawEvalSucceeded &&
        beforeCp != null &&
        afterCp != null;
    final moverPerspectiveDeltaCp = cpDeltaComputed ? afterCp - beforeCp : null;
    final deltaDirection = _direction(moverPerspectiveDeltaCp);

    final safeForPhase35J =
        beforeAfter.beforeAfterRawEvalSucceeded &&
        beforeAfter.beforeEvalSucceeded &&
        beforeAfter.afterEvalSucceeded &&
        beforeCp != null &&
        afterCp != null &&
        cpDeltaComputed &&
        moverPerspectiveDeltaCp != null &&
        !cpLossComputed &&
        !winPercentComputed &&
        !classificationComputed &&
        !moveQualityComputed;

    final blockers = <String>[];
    if (!safeForPhase35J) {
      blockers.add('Analyzer CP delta proof is blocked.');
    }
    if (!beforeAfter.beforeAfterRawEvalSucceeded) {
      blockers.add('Before/after raw eval did not succeed.');
    }
    if (!beforeAfter.beforeEvalSucceeded) {
      blockers.add('Before-position raw eval did not succeed.');
    }
    if (!beforeAfter.afterEvalSucceeded) {
      blockers.add('After-position raw eval did not succeed.');
    }
    if (beforeCp == null) {
      blockers.add('Mover-perspective before CP is unavailable.');
    }
    if (afterCp == null) {
      blockers.add('Mover-perspective after CP is unavailable.');
    }
    blockers.addAll(beforeAfter.blockers.map((b) => 'beforeAfter: $b'));

    final warnings = <String>[];
    if (!safeForPhase35J) {
      warnings.add('This is not a successful CP delta proof.');
      warnings.add('Do not proceed to Phase 35J yet.');
    }
    if (beforeAfter.moverPerspectiveBeforeMate != null ||
        beforeAfter.moverPerspectiveAfterMate != null) {
      warnings.add('Mate evidence was present but not converted to CP.');
    }
    warnings.addAll(beforeAfter.warnings.map((w) => 'beforeAfter: $w'));

    final failureMessage = safeForPhase35J
        ? null
        : _failureMessage(
            beforeAfter: beforeAfter,
            beforeCp: beforeCp,
            afterCp: afterCp,
          );

    return AnalyzerCpDeltaResult(
      beforeFen: request.beforeFen,
      afterFen: request.afterFen,
      playedMoveUci: request.playedMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      beforeAfterRawEvalSucceeded: beforeAfter.beforeAfterRawEvalSucceeded,
      beforeEvalSucceeded: beforeAfter.beforeEvalSucceeded,
      afterEvalSucceeded: beforeAfter.afterEvalSucceeded,
      moverPerspectiveBeforeCp: beforeCp,
      moverPerspectiveAfterCp: afterCp,
      moverPerspectiveBeforeMate: beforeAfter.moverPerspectiveBeforeMate,
      moverPerspectiveAfterMate: beforeAfter.moverPerspectiveAfterMate,
      cpDeltaComputed: cpDeltaComputed,
      moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
      deltaDirection: deltaDirection,
      cpLossComputed: cpLossComputed,
      winPercentComputed: winPercentComputed,
      classificationComputed: classificationComputed,
      moveQualityComputed: moveQualityComputed,
      failureMessage: failureMessage,
      safeForPhase35J: safeForPhase35J,
      nextRecommendation: safeForPhase35J
          ? analyzerCpDeltaNextRecommendation
          : analyzerCpDeltaFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  AnalyzerCpDeltaResult _failure({
    required AnalyzerCpDeltaRequest request,
    required String failureMessage,
  }) {
    return AnalyzerCpDeltaResult(
      beforeFen: request.beforeFen,
      afterFen: request.afterFen,
      playedMoveUci: request.playedMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      beforeAfterRawEvalSucceeded: false,
      beforeEvalSucceeded: false,
      afterEvalSucceeded: false,
      moverPerspectiveBeforeCp: null,
      moverPerspectiveAfterCp: null,
      moverPerspectiveBeforeMate: null,
      moverPerspectiveAfterMate: null,
      cpDeltaComputed: false,
      moverPerspectiveDeltaCp: null,
      deltaDirection: AnalyzerCpDeltaDirection.unavailable,
      cpLossComputed: false,
      winPercentComputed: false,
      classificationComputed: false,
      moveQualityComputed: false,
      failureMessage: failureMessage,
      safeForPhase35J: false,
      nextRecommendation: analyzerCpDeltaFailureRecommendation,
      blockers: const ['Analyzer CP delta proof is blocked.'],
      warnings: const [
        'This is not a successful CP delta proof.',
        'Do not proceed to Phase 35J yet.',
      ],
    );
  }

  AnalyzerCpDeltaDirection _direction(int? deltaCp) {
    if (deltaCp == null) return AnalyzerCpDeltaDirection.unavailable;
    if (deltaCp > 0) return AnalyzerCpDeltaDirection.improved;
    if (deltaCp < 0) return AnalyzerCpDeltaDirection.worsened;
    return AnalyzerCpDeltaDirection.unchanged;
  }

  String? _validateControlledRequest(AnalyzerCpDeltaRequest request) {
    if (request.beforeFen != analyzerCpDeltaControlledBeforeFen) {
      return 'Phase 35I accepts only the controlled before FEN.';
    }
    if (request.afterFen != analyzerCpDeltaControlledAfterFen) {
      return 'Phase 35I accepts only the controlled after FEN.';
    }
    if (request.playedMoveUci != analyzerCpDeltaPlayedMoveUci) {
      return 'Phase 35I accepts only playedMoveUci=e2e4.';
    }
    if (request.requestedDepth != analyzerCpDeltaDepth) {
      return 'Phase 35I accepts only requestedDepth=1.';
    }
    return null;
  }

  String _failureMessage({
    required AnalyzerBeforeAfterRawEvalResult beforeAfter,
    required int? beforeCp,
    required int? afterCp,
  }) {
    if (!beforeAfter.beforeAfterRawEvalSucceeded) {
      return beforeAfter.failureMessage ??
          'Before/after raw eval did not succeed.';
    }
    if (beforeCp == null && afterCp == null) {
      return 'Mover-perspective before and after CP are unavailable.';
    }
    if (beforeCp == null) {
      return 'Mover-perspective before CP is unavailable.';
    }
    if (afterCp == null) {
      return 'Mover-perspective after CP is unavailable.';
    }
    return 'Analyzer CP delta proof did not succeed.';
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
