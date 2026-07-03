import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval_bridge.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const defaultLocalRawEvalPerspectiveNormalizationTimeout =
    defaultLocalSearchEvalProbeTimeout;

class LocalRawEvalPerspectiveNormalizer {
  const LocalRawEvalPerspectiveNormalizer();

  LocalRawEvalPerspective normalizeRawEval(LocalRawEngineEval rawEval) {
    if (!rawEval.safeForPhase35F) {
      return _failure(
        requestedFen: rawEval.requestedFen,
        requestedDepth: rawEval.requestedDepth,
        rawScoreType: rawEval.scoreType,
        rawScoreCp: rawEval.scoreCp,
        rawScoreMate: rawEval.scoreMate,
        failureMessage:
            rawEval.failureMessage ??
            'Raw engine eval bridge was not safe for Phase 35F.',
      );
    }

    return normalizeRawEvidence(
      requestedFen: rawEval.requestedFen,
      requestedDepth: rawEval.requestedDepth,
      rawScoreType: rawEval.scoreType,
      rawScoreCp: rawEval.scoreCp,
      rawScoreMate: rawEval.scoreMate,
    );
  }

  LocalRawEvalPerspective normalizeRawEvidence({
    required String requestedFen,
    required int requestedDepth,
    required String? rawScoreType,
    required int? rawScoreCp,
    required int? rawScoreMate,
  }) {
    final sideToMoveResult = _extractSideToMove(requestedFen);
    final sideToMove = sideToMoveResult.sideToMove;
    if (sideToMove == null) {
      return _failure(
        requestedFen: requestedFen,
        requestedDepth: requestedDepth,
        rawScoreType: rawScoreType,
        rawScoreCp: rawScoreCp,
        rawScoreMate: rawScoreMate,
        failureMessage: sideToMoveResult.failureMessage!,
      );
    }

    if (rawScoreType == 'cp' && rawScoreCp != null) {
      final whitePerspectiveCp = switch (sideToMove) {
        LocalRawEvalSideToMove.white => rawScoreCp,
        LocalRawEvalSideToMove.black => -rawScoreCp,
      };
      final blackPerspectiveCp = -whitePerspectiveCp;
      return _success(
        requestedFen: requestedFen,
        requestedDepth: requestedDepth,
        sideToMove: sideToMove,
        rawScoreType: 'cp',
        rawScoreCp: rawScoreCp,
        rawScoreMate: null,
        whitePerspectiveCp: whitePerspectiveCp,
        blackPerspectiveCp: blackPerspectiveCp,
        whitePerspectiveMate: null,
        blackPerspectiveMate: null,
      );
    }

    if (rawScoreType == 'mate' && rawScoreMate != null) {
      final whitePerspectiveMate = switch (sideToMove) {
        LocalRawEvalSideToMove.white => rawScoreMate,
        LocalRawEvalSideToMove.black => -rawScoreMate,
      };
      final blackPerspectiveMate = -whitePerspectiveMate;
      return _success(
        requestedFen: requestedFen,
        requestedDepth: requestedDepth,
        sideToMove: sideToMove,
        rawScoreType: 'mate',
        rawScoreCp: null,
        rawScoreMate: rawScoreMate,
        whitePerspectiveCp: null,
        blackPerspectiveCp: null,
        whitePerspectiveMate: whitePerspectiveMate,
        blackPerspectiveMate: blackPerspectiveMate,
      );
    }

    return _failure(
      requestedFen: requestedFen,
      requestedDepth: requestedDepth,
      sideToMove: sideToMove,
      rawScoreType: rawScoreType,
      rawScoreCp: rawScoreCp,
      rawScoreMate: rawScoreMate,
      failureMessage:
          'Raw score evidence must include scoreType cp with rawScoreCp '
          'or scoreType mate with rawScoreMate.',
    );
  }

  LocalRawEvalPerspective _success({
    required String requestedFen,
    required int requestedDepth,
    required LocalRawEvalSideToMove sideToMove,
    required String rawScoreType,
    required int? rawScoreCp,
    required int? rawScoreMate,
    required int? whitePerspectiveCp,
    required int? blackPerspectiveCp,
    required int? whitePerspectiveMate,
    required int? blackPerspectiveMate,
  }) {
    return LocalRawEvalPerspective(
      requestedFen: requestedFen,
      requestedDepth: requestedDepth,
      sideToMove: sideToMove,
      rawScoreType: rawScoreType,
      rawScoreCp: rawScoreCp,
      rawScoreMate: rawScoreMate,
      rawScorePerspective: localRawEvalPerspectiveScorePerspective,
      whitePerspectiveCp: whitePerspectiveCp,
      blackPerspectiveCp: blackPerspectiveCp,
      whitePerspectiveMate: whitePerspectiveMate,
      blackPerspectiveMate: blackPerspectiveMate,
      playerPerspectiveCpWhite: whitePerspectiveCp,
      playerPerspectiveCpBlack: blackPerspectiveCp,
      playerPerspectiveMateWhite: whitePerspectiveMate,
      playerPerspectiveMateBlack: blackPerspectiveMate,
      normalizationSucceeded: true,
      failureMessage: null,
      safeForPhase35G: true,
      nextRecommendation: localRawEvalPerspectiveNextRecommendation,
      blockers: const [],
      warnings: const [],
    );
  }

  LocalRawEvalPerspective _failure({
    required String requestedFen,
    required int requestedDepth,
    LocalRawEvalSideToMove? sideToMove,
    required String? rawScoreType,
    required int? rawScoreCp,
    required int? rawScoreMate,
    required String failureMessage,
  }) {
    return LocalRawEvalPerspective(
      requestedFen: requestedFen,
      requestedDepth: requestedDepth,
      sideToMove: sideToMove,
      rawScoreType: rawScoreType,
      rawScoreCp: rawScoreCp,
      rawScoreMate: rawScoreMate,
      rawScorePerspective: localRawEvalPerspectiveScorePerspective,
      whitePerspectiveCp: null,
      blackPerspectiveCp: null,
      whitePerspectiveMate: null,
      blackPerspectiveMate: null,
      playerPerspectiveCpWhite: null,
      playerPerspectiveCpBlack: null,
      playerPerspectiveMateWhite: null,
      playerPerspectiveMateBlack: null,
      normalizationSucceeded: false,
      failureMessage: failureMessage,
      safeForPhase35G: false,
      nextRecommendation: localRawEvalPerspectiveFailureRecommendation,
      blockers: const ['Raw eval perspective normalization is blocked.'],
      warnings: const [
        'This is not a successful raw eval perspective normalization proof.',
        'Do not proceed to Phase 35G yet.',
      ],
    );
  }
}

class LocalRawEvalPerspectiveNormalizationProbe {
  LocalRawEvalPerspectiveNormalizationProbe({
    LocalRawEngineEvalBridge? bridge,
    LocalRawEvalPerspectiveNormalizer normalizer =
        const LocalRawEvalPerspectiveNormalizer(),
  }) : _bridge = bridge ?? LocalRawEngineEvalBridge(),
       _normalizer = normalizer;

  final LocalRawEngineEvalBridge _bridge;
  final LocalRawEvalPerspectiveNormalizer _normalizer;

  Future<LocalRawEvalPerspective> run({
    Duration timeout = defaultLocalRawEvalPerspectiveNormalizationTimeout,
  }) async {
    final rawEval = await _bridge.evaluate(timeout: timeout);
    return _normalizer.normalizeRawEval(rawEval);
  }
}

class _SideToMoveResult {
  const _SideToMoveResult.valid(this.sideToMove) : failureMessage = null;

  const _SideToMoveResult.invalid(this.failureMessage) : sideToMove = null;

  final LocalRawEvalSideToMove? sideToMove;
  final String? failureMessage;
}

_SideToMoveResult _extractSideToMove(String fen) {
  final parts = fen.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) {
    return const _SideToMoveResult.invalid(
      'FEN side-to-move field is missing.',
    );
  }

  return switch (parts[1]) {
    'w' => const _SideToMoveResult.valid(LocalRawEvalSideToMove.white),
    'b' => const _SideToMoveResult.valid(LocalRawEvalSideToMove.black),
    _ => _SideToMoveResult.invalid(
      'FEN side-to-move field must be w or b. Actual: ${parts[1]}.',
    ),
  };
}
