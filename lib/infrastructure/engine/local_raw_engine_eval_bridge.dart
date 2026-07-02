import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart';

const localRawEngineEvalBridgeControlledFen = localSearchEvalProbeControlledFen;
const localRawEngineEvalBridgeDepth = localSearchEvalProbeDepthLimit;

class LocalRawEngineEvalBridge {
  LocalRawEngineEvalBridge({LocalSearchEvalProbe? searchProbe})
    : _searchProbe = searchProbe ?? LocalSearchEvalProbe();

  final LocalSearchEvalProbe _searchProbe;

  Future<LocalRawEngineEval> evaluate({
    String requestedFen = localRawEngineEvalBridgeControlledFen,
    int requestedDepth = localRawEngineEvalBridgeDepth,
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
  }) async {
    if (requestedFen != localRawEngineEvalBridgeControlledFen) {
      return _blocked(
        requestedFen: requestedFen,
        requestedDepth: requestedDepth,
        failureMessage:
            'Phase 35E accepts only the controlled start-position FEN.',
      );
    }
    if (requestedDepth != localRawEngineEvalBridgeDepth) {
      return _blocked(
        requestedFen: requestedFen,
        requestedDepth: requestedDepth,
        failureMessage: 'Phase 35E accepts only requestedDepth=1.',
      );
    }

    final probe = await _searchProbe.run(
      timeout: timeout,
      controlledFen: requestedFen,
    );
    final searchSucceeded =
        probe.searchCommandSent &&
        probe.bestMoveReceived &&
        !probe.timedOut &&
        !probe.failedToLaunch;
    final safeForPhase35F =
        probe.handshakeSucceeded &&
        probe.fenInputSucceeded &&
        searchSucceeded &&
        probe.bestMoveReceived;
    final scoreCp = probe.scoreType == 'cp' ? probe.scoreValue : null;
    final scoreMate = probe.scoreType == 'mate' ? probe.mateValue : null;

    final blockers = <String>[];
    if (!safeForPhase35F) {
      blockers.add('Analyzer adapter raw eval bridge is blocked.');
    }
    if (!probe.handshakeSucceeded) {
      blockers.add('Local UCI handshake did not succeed.');
    }
    if (!probe.fenInputSucceeded) {
      blockers.add('Controlled FEN input did not succeed.');
    }
    if (!searchSucceeded) {
      blockers.add('Depth-1 local search did not succeed.');
    }
    if (probe.searchCommandSent && !probe.bestMoveReceived) {
      blockers.add('bestmove was not received.');
    }
    blockers.addAll(probe.blockers);

    final warnings = <String>[];
    if (!safeForPhase35F) {
      warnings.add('This is not a successful raw eval bridge proof.');
      warnings.add('Do not proceed to Phase 35F yet.');
      warnings.add(
        'Next action is fixing the analyzer adapter raw eval bridge.',
      );
    }
    if (safeForPhase35F && !probe.rawScoreSeen) {
      warnings.add(
        'bestmove was received but no raw score evidence was seen at depth 1.',
      );
    }
    warnings.addAll(probe.warnings);

    blockers.sort();
    warnings.sort();

    return LocalRawEngineEval(
      requestedFen: requestedFen,
      requestedDepth: requestedDepth,
      engineSource: localRawEngineEvalEngineSource,
      bridgeSource: localRawEngineEvalBridgeSource,
      handshakeSucceeded: probe.handshakeSucceeded,
      fenInputSucceeded: probe.fenInputSucceeded,
      searchSucceeded: searchSucceeded,
      bestMove: probe.bestMove,
      bestMoveReceived: probe.bestMoveReceived,
      infoDepthSeen: probe.infoDepthSeen,
      rawScoreSeen: probe.rawScoreSeen,
      scoreType: probe.scoreType,
      scoreCp: scoreCp,
      scoreMate: scoreMate,
      rawScoreValue: scoreCp ?? scoreMate,
      timedOut: probe.timedOut,
      failedToLaunch: probe.failedToLaunch,
      failureMessage: probe.failureMessage,
      sanitizedOutputPreview: probe.sanitizedOutputPreview,
      rawOutputLineCount: probe.rawOutputLineCount,
      safeForAnalyzerAdapterPhase: safeForPhase35F,
      nextRecommendation: safeForPhase35F
          ? localRawEngineEvalNextRecommendation
          : localRawEngineEvalFailureRecommendation,
      blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
      warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
    );
  }

  LocalRawEngineEval _blocked({
    required String requestedFen,
    required int requestedDepth,
    required String failureMessage,
  }) {
    return LocalRawEngineEval(
      requestedFen: requestedFen,
      requestedDepth: requestedDepth,
      engineSource: localRawEngineEvalEngineSource,
      bridgeSource: localRawEngineEvalBridgeSource,
      handshakeSucceeded: false,
      fenInputSucceeded: false,
      searchSucceeded: false,
      bestMove: null,
      bestMoveReceived: false,
      infoDepthSeen: null,
      rawScoreSeen: false,
      scoreType: null,
      scoreCp: null,
      scoreMate: null,
      rawScoreValue: null,
      timedOut: false,
      failedToLaunch: false,
      failureMessage: failureMessage,
      sanitizedOutputPreview: const [],
      rawOutputLineCount: 0,
      safeForAnalyzerAdapterPhase: false,
      nextRecommendation: localRawEngineEvalFailureRecommendation,
      blockers: const ['Analyzer adapter raw eval bridge is blocked.'],
      warnings: const [
        'This is not a successful raw eval bridge proof.',
        'Do not proceed to Phase 35F yet.',
        'Next action is fixing the analyzer adapter raw eval bridge.',
      ],
    );
  }
}
