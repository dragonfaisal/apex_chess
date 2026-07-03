import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval_bridge.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective_normalizer.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef LocalAnalyzerRawEvalLoader =
    Future<LocalRawEngineEval> Function({
      required String requestedFen,
      required int requestedDepth,
      required Duration timeout,
    });

typedef LocalAnalyzerPerspectiveNormalizer =
    LocalRawEvalPerspective Function(LocalRawEngineEval rawEval);

class LocalAnalyzerSingleFenRawEvalAdapter {
  LocalAnalyzerSingleFenRawEvalAdapter({
    LocalRawEngineEvalBridge? bridge,
    LocalRawEvalPerspectiveNormalizer? normalizer,
    LocalAnalyzerRawEvalLoader? rawEvalLoader,
    LocalAnalyzerPerspectiveNormalizer? perspectiveNormalizer,
    Set<String> allowedControlledFens = const {
      analyzerSingleFenRawEvalControlledFen,
    },
  }) : _rawEvalLoader =
           rawEvalLoader ??
           (({
             required String requestedFen,
             required int requestedDepth,
             required Duration timeout,
           }) async {
             return (bridge ??
                     LocalRawEngineEvalBridge(
                       allowedControlledFens: allowedControlledFens,
                     ))
                 .evaluate(
                   requestedFen: requestedFen,
                   requestedDepth: requestedDepth,
                   timeout: timeout,
                 );
           }),
       _perspectiveNormalizer =
           perspectiveNormalizer ??
           ((rawEval) {
             return (normalizer ?? const LocalRawEvalPerspectiveNormalizer())
                 .normalizeRawEval(rawEval);
           }),
       _allowedControlledFens = Set.unmodifiable(allowedControlledFens);

  final LocalAnalyzerRawEvalLoader _rawEvalLoader;
  final LocalAnalyzerPerspectiveNormalizer _perspectiveNormalizer;
  final Set<String> _allowedControlledFens;

  Future<AnalyzerRawEvalResult> evaluate(
    AnalyzerSingleFenRawEvalRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    if (!_allowedControlledFens.contains(request.fen)) {
      return _failure(
        request: request,
        failureMessage:
            'Analyzer single-FEN raw eval accepts only explicitly allowed '
            'controlled FENs.',
      );
    }
    if (request.requestedDepth != analyzerSingleFenRawEvalDepth) {
      return _failure(
        request: request,
        failureMessage: 'Phase 35G accepts only requestedDepth=1.',
      );
    }

    try {
      final rawEval = await _rawEvalLoader(
        requestedFen: request.fen,
        requestedDepth: request.requestedDepth,
        timeout: timeout,
      );
      final perspective = _perspectiveNormalizer(rawEval);
      return _fromRawAndPerspective(
        request: request,
        rawEval: rawEval,
        perspective: perspective,
      );
    } on Object catch (e) {
      return _failure(request: request, failureMessage: _sanitize(e));
    }
  }

  AnalyzerRawEvalResult _fromRawAndPerspective({
    required AnalyzerSingleFenRawEvalRequest request,
    required LocalRawEngineEval rawEval,
    required LocalRawEvalPerspective perspective,
  }) {
    final engineSucceeded =
        rawEval.safeForPhase35F &&
        rawEval.searchSucceeded &&
        rawEval.bestMoveReceived;
    final perspectiveSucceeded = perspective.normalizationSucceeded;
    final playerPerspectiveCp = switch (request.requestedPlayerColor) {
      AnalyzerRequestedPlayerColor.white => perspective.whitePerspectiveCp,
      AnalyzerRequestedPlayerColor.black => perspective.blackPerspectiveCp,
    };
    final playerPerspectiveMate = switch (request.requestedPlayerColor) {
      AnalyzerRequestedPlayerColor.white => perspective.whitePerspectiveMate,
      AnalyzerRequestedPlayerColor.black => perspective.blackPerspectiveMate,
    };
    final analyzerRawEvalSucceeded =
        engineSucceeded &&
        perspectiveSucceeded &&
        rawEval.bestMoveReceived &&
        request.requestedDepth == analyzerSingleFenRawEvalDepth &&
        _hasExplicitPerspective(perspective);
    final blockers = <String>[];
    if (!analyzerRawEvalSucceeded) {
      blockers.add('Analyzer single-FEN raw eval contract is blocked.');
    }
    if (!engineSucceeded) {
      blockers.add('Raw engine eval bridge did not succeed.');
    }
    if (!perspectiveSucceeded) {
      blockers.add('Perspective normalization did not succeed.');
    }
    if (!rawEval.bestMoveReceived) {
      blockers.add('bestmove was not received.');
    }
    blockers.addAll(rawEval.blockers);
    blockers.addAll(perspective.blockers);

    final warnings = <String>[];
    if (!analyzerRawEvalSucceeded) {
      warnings.add('This is not a successful analyzer raw eval proof.');
      warnings.add('Do not proceed to Phase 35H yet.');
    }
    warnings.addAll(rawEval.warnings);
    warnings.addAll(perspective.warnings);

    final failureMessage = analyzerRawEvalSucceeded
        ? null
        : rawEval.failureMessage ??
              perspective.failureMessage ??
              'Analyzer single-FEN raw eval contract did not succeed.';

    return AnalyzerRawEvalResult(
      fen: request.fen,
      requestedDepth: request.requestedDepth,
      requestedPlayerColor: request.requestedPlayerColor,
      engineSource: rawEval.engineSource,
      bridgeSource: rawEval.bridgeSource,
      rawScoreType: perspective.rawScoreType,
      rawScoreCp: perspective.rawScoreCp,
      rawScoreMate: perspective.rawScoreMate,
      rawScorePerspective: perspective.rawScorePerspective,
      sideToMove: _mapSideToMove(perspective.sideToMove),
      whitePerspectiveCp: perspective.whitePerspectiveCp,
      blackPerspectiveCp: perspective.blackPerspectiveCp,
      whitePerspectiveMate: perspective.whitePerspectiveMate,
      blackPerspectiveMate: perspective.blackPerspectiveMate,
      playerPerspectiveCp: playerPerspectiveCp,
      playerPerspectiveMate: playerPerspectiveMate,
      bestMove: rawEval.bestMove,
      bestMoveReceived: rawEval.bestMoveReceived,
      infoDepthSeen: rawEval.infoDepthSeen,
      engineSucceeded: engineSucceeded,
      perspectiveNormalizationSucceeded: perspectiveSucceeded,
      analyzerRawEvalSucceeded: analyzerRawEvalSucceeded,
      failureMessage: failureMessage,
      safeForPhase35H: analyzerRawEvalSucceeded,
      nextRecommendation: analyzerRawEvalSucceeded
          ? analyzerRawEvalNextRecommendation
          : analyzerRawEvalFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  AnalyzerRawEvalResult _failure({
    required AnalyzerSingleFenRawEvalRequest request,
    required String failureMessage,
  }) {
    return AnalyzerRawEvalResult(
      fen: request.fen,
      requestedDepth: request.requestedDepth,
      requestedPlayerColor: request.requestedPlayerColor,
      engineSource: localRawEngineEvalEngineSource,
      bridgeSource: localRawEngineEvalBridgeSource,
      rawScoreType: null,
      rawScoreCp: null,
      rawScoreMate: null,
      rawScorePerspective: localRawEvalPerspectiveScorePerspective,
      sideToMove: null,
      whitePerspectiveCp: null,
      blackPerspectiveCp: null,
      whitePerspectiveMate: null,
      blackPerspectiveMate: null,
      playerPerspectiveCp: null,
      playerPerspectiveMate: null,
      bestMove: null,
      bestMoveReceived: false,
      infoDepthSeen: null,
      engineSucceeded: false,
      perspectiveNormalizationSucceeded: false,
      analyzerRawEvalSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35H: false,
      nextRecommendation: analyzerRawEvalFailureRecommendation,
      blockers: const ['Analyzer single-FEN raw eval contract is blocked.'],
      warnings: const [
        'This is not a successful analyzer raw eval proof.',
        'Do not proceed to Phase 35H yet.',
      ],
    );
  }

  bool _hasExplicitPerspective(LocalRawEvalPerspective perspective) {
    final hasCp =
        perspective.whitePerspectiveCp != null &&
        perspective.blackPerspectiveCp != null;
    final hasMate =
        perspective.whitePerspectiveMate != null &&
        perspective.blackPerspectiveMate != null;
    return hasCp || hasMate;
  }

  AnalyzerFenSideToMove? _mapSideToMove(LocalRawEvalSideToMove? sideToMove) {
    return switch (sideToMove) {
      LocalRawEvalSideToMove.white => AnalyzerFenSideToMove.white,
      LocalRawEvalSideToMove.black => AnalyzerFenSideToMove.black,
      null => null,
    };
  }
}

String _sanitize(Object value) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= 160) return safe;
  return '${safe.substring(0, 160)}...';
}
