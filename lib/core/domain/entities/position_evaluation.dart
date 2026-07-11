library;

import 'package:apex_chess/core/domain/entities/engine_line.dart';

/// Perspective used by every score exposed to the review pipeline.
enum EvaluationPerspective { white }

/// Terminal and failure states are explicit; absence of a score is never
/// interpreted as an equal position.
enum PositionEvaluationStatus { completed, terminal }

/// Immutable evidence returned for one exact position.
class PositionEvaluation {
  const PositionEvaluation({
    this.scoreCp,
    this.mateIn,
    this.secondBestCp,
    this.secondBestMate,
    required this.depth,
    this.bestMoveUci,
    this.pvMoves = const <String>[],
    this.engineLines = const <EngineLine>[],
    this.positionFen = '',
    this.perspective = EvaluationPerspective.white,
    this.status = PositionEvaluationStatus.completed,
    this.requestedDepth,
    this.requestedMovetimeMs,
    this.requestedMultiPv = 1,
    this.nodes,
    this.engineTimeMs,
    this.elapsedMs,
    this.engineVersion = 'unknown',
  });

  final int? scoreCp;
  final int? mateIn;
  final int? secondBestCp;
  final int? secondBestMate;

  /// Achieved search depth. This must never be backfilled from the request.
  final int depth;
  final String? bestMoveUci;
  final List<String> pvMoves;
  final List<EngineLine> engineLines;
  final String positionFen;
  final EvaluationPerspective perspective;
  final PositionEvaluationStatus status;
  final int? requestedDepth;
  final int? requestedMovetimeMs;
  final int requestedMultiPv;
  final int? nodes;
  final int? engineTimeMs;
  final int? elapsedMs;
  final String engineVersion;

  bool get hasUnambiguousScore =>
      (scoreCp != null) != (mateIn != null) && mateIn != 0;

  bool get targetDepthReached =>
      requestedDepth == null || depth >= requestedDepth!;

  int get receivedMultiPv => engineLines.length;

  bool get multiPvComplete => receivedMultiPv >= requestedMultiPv;

  bool isUsableFor(String fen) =>
      status == PositionEvaluationStatus.completed &&
      positionFen == fen &&
      perspective == EvaluationPerspective.white &&
      hasUnambiguousScore;
}
