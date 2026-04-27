/// Per-move analysis entity — the atomic unit of game review.
///
/// Represents a single analyzed ply with its Win%, classification,
/// SAN notation, and engine data. Populated by the backend or mock.
/// All Win% values are from White's perspective (0–100).
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

/// Immutable per-move analysis.
class MoveAnalysis {
  /// 0-indexed ply number.
  final int ply;

  /// Standard Algebraic Notation (e.g., "Nf3", "Bxf7+", "O-O").
  final String san;

  /// UCI notation (e.g., "g1f3").
  final String uci;

  /// FEN before the move was played.
  final String fenBefore;

  /// FEN after the move was played.
  final String fenAfter;

  /// Target square of the move (for SVG overlay placement).
  final String targetSquare;

  /// Win% before this move (White's perspective, 0–100).
  final double winPercentBefore;

  /// Win% after this move (White's perspective, 0–100).
  final double winPercentAfter;

  /// Signed Win% delta: negative = bad for the mover.
  final double deltaW;

  /// True if White played this move.
  final bool isWhiteMove;

  /// Move quality classification.
  final MoveQuality classification;

  /// Engine's best move for the position before (UCI).
  final String? engineBestMoveUci;

  /// Engine's best move in SAN for display.
  final String? engineBestMoveSan;

  /// Centipawn evaluation after the move (White's POV).
  final int? scoreCpAfter;

  /// Mate-in after the move (White's POV).
  final int? mateInAfter;

  /// Whether this position is in the opening book.
  final bool inBook;

  /// Opening name (if detected).
  final String? openingName;

  /// ECO code (e.g., "B97").
  final String? ecoCode;

  /// Human-readable coach message.
  final String message;

  const MoveAnalysis({
    required this.ply,
    required this.san,
    required this.uci,
    required this.fenBefore,
    required this.fenAfter,
    this.targetSquare = '',
    required this.winPercentBefore,
    required this.winPercentAfter,
    required this.deltaW,
    required this.isWhiteMove,
    required this.classification,
    this.engineBestMoveUci,
    this.engineBestMoveSan,
    this.scoreCpAfter,
    this.mateInAfter,
    this.inBook = false,
    this.openingName,
    this.ecoCode,
    required this.message,
  });

  @override
  String toString() =>
      'MoveAnalysis(ply: $ply, san: $san, class: ${classification.label}, '
      'win: ${winPercentAfter.toStringAsFixed(1)}%)';

  // ── Serialisation ──────────────────────────────────────────────
  // Used by the archive layer to persist a full analysed timeline
  // alongside the PGN so a re-opened game skips analysis entirely.
  // Schema is intentionally explicit (no reflection) so a future
  // field rename never silently invalidates old records — instead
  // the missing key falls through to a sensible default in
  // [fromJson].

  Map<String, dynamic> toJson() => {
        'ply': ply,
        'san': san,
        'uci': uci,
        'fenBefore': fenBefore,
        'fenAfter': fenAfter,
        'targetSquare': targetSquare,
        'winPercentBefore': winPercentBefore,
        'winPercentAfter': winPercentAfter,
        'deltaW': deltaW,
        'isWhiteMove': isWhiteMove,
        'classification': classification.name,
        'engineBestMoveUci': engineBestMoveUci,
        'engineBestMoveSan': engineBestMoveSan,
        'scoreCpAfter': scoreCpAfter,
        'mateInAfter': mateInAfter,
        'inBook': inBook,
        'openingName': openingName,
        'ecoCode': ecoCode,
        'message': message,
      };

  factory MoveAnalysis.fromJson(Map<dynamic, dynamic> j) {
    final classRaw = j['classification'] as String?;
    final classification = MoveQuality.values.firstWhere(
      (q) => q.name == classRaw,
      orElse: () => MoveQuality.good,
    );
    return MoveAnalysis(
      ply: (j['ply'] as num).toInt(),
      san: j['san'] as String? ?? '',
      uci: j['uci'] as String? ?? '',
      fenBefore: j['fenBefore'] as String? ?? '',
      fenAfter: j['fenAfter'] as String? ?? '',
      targetSquare: j['targetSquare'] as String? ?? '',
      winPercentBefore:
          (j['winPercentBefore'] as num?)?.toDouble() ?? 50.0,
      winPercentAfter:
          (j['winPercentAfter'] as num?)?.toDouble() ?? 50.0,
      deltaW: (j['deltaW'] as num?)?.toDouble() ?? 0.0,
      isWhiteMove: j['isWhiteMove'] as bool? ?? true,
      classification: classification,
      engineBestMoveUci: j['engineBestMoveUci'] as String?,
      engineBestMoveSan: j['engineBestMoveSan'] as String?,
      scoreCpAfter: (j['scoreCpAfter'] as num?)?.toInt(),
      mateInAfter: (j['mateInAfter'] as num?)?.toInt(),
      inBook: j['inBook'] as bool? ?? false,
      openingName: j['openingName'] as String?,
      ecoCode: j['ecoCode'] as String?,
      message: j['message'] as String? ?? '',
    );
  }
}
