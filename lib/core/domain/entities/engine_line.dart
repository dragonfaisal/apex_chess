/// Ranked engine candidate line for a single analysed position.
///
/// Scores are normalised to White's perspective so callers can compare
/// PV1/PV2/PV3 without knowing whose turn it is.
library;

class EngineLine {
  const EngineLine({
    required this.rank,
    this.moveUci,
    this.moveSan,
    this.scoreCp,
    this.mateIn,
    required this.depth,
    required this.whiteWinPercent,
    this.pvMoves = const <String>[],
  });

  /// 1-based MultiPV rank: PV1, PV2, PV3.
  final int rank;

  /// First move of the PV in UCI notation.
  final String? moveUci;

  /// First move of the PV in SAN, when it can be derived locally.
  final String? moveSan;

  /// Centipawn score from White's perspective.
  final int? scoreCp;

  /// Mate score from White's perspective.
  final int? mateIn;

  /// Search depth reached for this line.
  final int depth;

  /// Win percentage from White's perspective.
  final double whiteWinPercent;

  /// Full principal variation in UCI notation.
  final List<String> pvMoves;

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'moveUci': moveUci,
    'moveSan': moveSan,
    'scoreCp': scoreCp,
    'mateIn': mateIn,
    'depth': depth,
    'whiteWinPercent': whiteWinPercent,
    'pvMoves': pvMoves,
  };

  factory EngineLine.fromJson(Map<dynamic, dynamic> j) => EngineLine(
    rank: (j['rank'] as num?)?.toInt() ?? 1,
    moveUci: j['moveUci'] as String?,
    moveSan: j['moveSan'] as String?,
    scoreCp: (j['scoreCp'] as num?)?.toInt(),
    mateIn: (j['mateIn'] as num?)?.toInt(),
    depth: (j['depth'] as num?)?.toInt() ?? 0,
    whiteWinPercent: (j['whiteWinPercent'] as num?)?.toDouble() ?? 50.0,
    pvMoves:
        (j['pvMoves'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const <String>[],
  );
}
