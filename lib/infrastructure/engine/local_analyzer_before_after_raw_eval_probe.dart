import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_single_fen_raw_eval_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerSingleFenRawEvalRunner =
    Future<AnalyzerRawEvalResult> Function(
      AnalyzerSingleFenRawEvalRequest request, {
      Duration timeout,
    });

class LocalAnalyzerBeforeAfterRawEvalProbe {
  LocalAnalyzerBeforeAfterRawEvalProbe({
    LocalAnalyzerSingleFenRawEvalAdapter? adapter,
    AnalyzerSingleFenRawEvalRunner? singleFenRunner,
  }) : _singleFenRunner =
           singleFenRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             final effectiveAdapter =
                 adapter ??
                 LocalAnalyzerSingleFenRawEvalAdapter(
                   allowedControlledFens:
                       analyzerBeforeAfterRawEvalControlledFens,
                 );
             return effectiveAdapter.evaluate(request, timeout: timeout);
           });

  final AnalyzerSingleFenRawEvalRunner _singleFenRunner;

  Future<AnalyzerBeforeAfterRawEvalResult> run(
    AnalyzerBeforeAfterRawEvalRequest request, {
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
      final after = await _singleFenRunner(
        AnalyzerSingleFenRawEvalRequest(
          fen: request.afterFen,
          requestedDepth: request.requestedDepth,
          requestedPlayerColor: requestedPlayerColor,
          source: '${request.source}:after',
        ),
        timeout: timeout,
      );
      return _fromSingleFenResults(
        request: request,
        before: before,
        after: after,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerBeforeAfterRawEvalResult _fromSingleFenResults({
    required AnalyzerBeforeAfterRawEvalRequest request,
    required AnalyzerRawEvalResult before,
    required AnalyzerRawEvalResult after,
  }) {
    const deltaComputed = false;
    const cpLossComputed = false;
    const winPercentComputed = false;
    const classificationComputed = false;

    final moverPerspectiveBeforeCp = switch (request.moverColor) {
      AnalyzerMoverColor.white => before.whitePerspectiveCp,
      AnalyzerMoverColor.black => before.blackPerspectiveCp,
    };
    final moverPerspectiveAfterCp = switch (request.moverColor) {
      AnalyzerMoverColor.white => after.whitePerspectiveCp,
      AnalyzerMoverColor.black => after.blackPerspectiveCp,
    };
    final moverPerspectiveBeforeMate = switch (request.moverColor) {
      AnalyzerMoverColor.white => before.whitePerspectiveMate,
      AnalyzerMoverColor.black => before.blackPerspectiveMate,
    };
    final moverPerspectiveAfterMate = switch (request.moverColor) {
      AnalyzerMoverColor.white => after.whitePerspectiveMate,
      AnalyzerMoverColor.black => after.blackPerspectiveMate,
    };

    final beforeEvalSucceeded = before.analyzerRawEvalSucceeded;
    final afterEvalSucceeded = after.analyzerRawEvalSucceeded;
    final beforeAfterRawEvalSucceeded =
        beforeEvalSucceeded &&
        afterEvalSucceeded &&
        before.bestMoveReceived &&
        after.bestMoveReceived &&
        request.requestedDepth == analyzerBeforeAfterRawEvalDepth &&
        _hasMoverPerspective(before, request.moverColor) &&
        _hasMoverPerspective(after, request.moverColor) &&
        !deltaComputed &&
        !cpLossComputed &&
        !winPercentComputed &&
        !classificationComputed;

    final blockers = <String>[];
    if (!beforeAfterRawEvalSucceeded) {
      blockers.add('Analyzer before/after raw eval proof is blocked.');
    }
    if (!beforeEvalSucceeded) {
      blockers.add('Before-position raw eval did not succeed.');
    }
    if (!afterEvalSucceeded) {
      blockers.add('After-position raw eval did not succeed.');
    }
    if (!before.bestMoveReceived) {
      blockers.add('Before-position bestmove was not received.');
    }
    if (!after.bestMoveReceived) {
      blockers.add('After-position bestmove was not received.');
    }
    if (!_hasMoverPerspective(before, request.moverColor)) {
      blockers.add('Before-position mover perspective was not populated.');
    }
    if (!_hasMoverPerspective(after, request.moverColor)) {
      blockers.add('After-position mover perspective was not populated.');
    }
    blockers.addAll(before.blockers.map((b) => 'before: $b'));
    blockers.addAll(after.blockers.map((b) => 'after: $b'));

    final warnings = <String>[];
    if (!beforeAfterRawEvalSucceeded) {
      warnings.add('This is not a successful before/after raw eval proof.');
      warnings.add('Do not proceed to Phase 35I yet.');
    }
    warnings.addAll(before.warnings.map((w) => 'before: $w'));
    warnings.addAll(after.warnings.map((w) => 'after: $w'));

    final failureMessage = beforeAfterRawEvalSucceeded
        ? null
        : _combinedFailureMessage(before, after);

    return AnalyzerBeforeAfterRawEvalResult(
      beforeFen: request.beforeFen,
      afterFen: request.afterFen,
      playedMoveUci: request.playedMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      beforeEvalSucceeded: beforeEvalSucceeded,
      afterEvalSucceeded: afterEvalSucceeded,
      beforeSideToMove: before.sideToMove,
      afterSideToMove: after.sideToMove,
      beforeRawScoreType: before.rawScoreType,
      afterRawScoreType: after.rawScoreType,
      beforeRawScoreCp: before.rawScoreCp,
      afterRawScoreCp: after.rawScoreCp,
      beforeRawScoreMate: before.rawScoreMate,
      afterRawScoreMate: after.rawScoreMate,
      beforeWhitePerspectiveCp: before.whitePerspectiveCp,
      afterWhitePerspectiveCp: after.whitePerspectiveCp,
      beforeBlackPerspectiveCp: before.blackPerspectiveCp,
      afterBlackPerspectiveCp: after.blackPerspectiveCp,
      beforeWhitePerspectiveMate: before.whitePerspectiveMate,
      afterWhitePerspectiveMate: after.whitePerspectiveMate,
      beforeBlackPerspectiveMate: before.blackPerspectiveMate,
      afterBlackPerspectiveMate: after.blackPerspectiveMate,
      moverPerspectiveBeforeCp: moverPerspectiveBeforeCp,
      moverPerspectiveAfterCp: moverPerspectiveAfterCp,
      moverPerspectiveBeforeMate: moverPerspectiveBeforeMate,
      moverPerspectiveAfterMate: moverPerspectiveAfterMate,
      beforeBestMove: before.bestMove,
      afterBestMove: after.bestMove,
      beforeBestMoveReceived: before.bestMoveReceived,
      afterBestMoveReceived: after.bestMoveReceived,
      beforeInfoDepthSeen: before.infoDepthSeen,
      afterInfoDepthSeen: after.infoDepthSeen,
      beforeAfterRawEvalSucceeded: beforeAfterRawEvalSucceeded,
      deltaComputed: deltaComputed,
      cpLossComputed: cpLossComputed,
      winPercentComputed: winPercentComputed,
      classificationComputed: classificationComputed,
      failureMessage: failureMessage,
      safeForPhase35I: beforeAfterRawEvalSucceeded,
      nextRecommendation: beforeAfterRawEvalSucceeded
          ? analyzerBeforeAfterRawEvalNextRecommendation
          : analyzerBeforeAfterRawEvalFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  AnalyzerBeforeAfterRawEvalResult _failure({
    required AnalyzerBeforeAfterRawEvalRequest request,
    required String failureMessage,
  }) {
    return AnalyzerBeforeAfterRawEvalResult(
      beforeFen: request.beforeFen,
      afterFen: request.afterFen,
      playedMoveUci: request.playedMoveUci,
      moverColor: request.moverColor,
      requestedDepth: request.requestedDepth,
      beforeEvalSucceeded: false,
      afterEvalSucceeded: false,
      beforeSideToMove: null,
      afterSideToMove: null,
      beforeRawScoreType: null,
      afterRawScoreType: null,
      beforeRawScoreCp: null,
      afterRawScoreCp: null,
      beforeRawScoreMate: null,
      afterRawScoreMate: null,
      beforeWhitePerspectiveCp: null,
      afterWhitePerspectiveCp: null,
      beforeBlackPerspectiveCp: null,
      afterBlackPerspectiveCp: null,
      beforeWhitePerspectiveMate: null,
      afterWhitePerspectiveMate: null,
      beforeBlackPerspectiveMate: null,
      afterBlackPerspectiveMate: null,
      moverPerspectiveBeforeCp: null,
      moverPerspectiveAfterCp: null,
      moverPerspectiveBeforeMate: null,
      moverPerspectiveAfterMate: null,
      beforeBestMove: null,
      afterBestMove: null,
      beforeBestMoveReceived: false,
      afterBestMoveReceived: false,
      beforeInfoDepthSeen: null,
      afterInfoDepthSeen: null,
      beforeAfterRawEvalSucceeded: false,
      deltaComputed: false,
      cpLossComputed: false,
      winPercentComputed: false,
      classificationComputed: false,
      failureMessage: failureMessage,
      safeForPhase35I: false,
      nextRecommendation: analyzerBeforeAfterRawEvalFailureRecommendation,
      blockers: const ['Analyzer before/after raw eval proof is blocked.'],
      warnings: const [
        'This is not a successful before/after raw eval proof.',
        'Do not proceed to Phase 35I yet.',
      ],
    );
  }

  bool _hasMoverPerspective(
    AnalyzerRawEvalResult result,
    AnalyzerMoverColor moverColor,
  ) {
    return switch (moverColor) {
      AnalyzerMoverColor.white =>
        result.whitePerspectiveCp != null ||
            result.whitePerspectiveMate != null,
      AnalyzerMoverColor.black =>
        result.blackPerspectiveCp != null ||
            result.blackPerspectiveMate != null,
    };
  }

  String? _validateControlledRequest(
    AnalyzerBeforeAfterRawEvalRequest request,
  ) {
    if (request.beforeFen != analyzerBeforeAfterRawEvalControlledBeforeFen) {
      return 'Phase 35H accepts only the controlled before FEN.';
    }
    if (request.afterFen != analyzerBeforeAfterRawEvalControlledAfterFen) {
      return 'Phase 35H accepts only the controlled after FEN.';
    }
    if (request.playedMoveUci != analyzerBeforeAfterRawEvalPlayedMoveUci) {
      return 'Phase 35H accepts only playedMoveUci=e2e4.';
    }
    if (request.requestedDepth != analyzerBeforeAfterRawEvalDepth) {
      return 'Phase 35H accepts only requestedDepth=1.';
    }
    return null;
  }

  String _combinedFailureMessage(
    AnalyzerRawEvalResult before,
    AnalyzerRawEvalResult after,
  ) {
    final failures = <String>[];
    if (!before.analyzerRawEvalSucceeded) {
      failures.add(
        'Before eval failed: '
        '${before.failureMessage ?? 'analyzer raw eval did not succeed'}.',
      );
    }
    if (!after.analyzerRawEvalSucceeded) {
      failures.add(
        'After eval failed: '
        '${after.failureMessage ?? 'analyzer raw eval did not succeed'}.',
      );
    }
    if (failures.isEmpty) {
      failures.add('Analyzer before/after raw eval proof did not succeed.');
    }
    return failures.join(' ');
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
