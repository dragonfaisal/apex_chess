/// Per-move analysis entity — the atomic unit of game review.
///
/// Represents a single analyzed ply with its Win%, classification,
/// SAN notation, and engine data. Populated by the backend or mock.
/// All Win% values are from White's perspective (0–100).
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/deep_tactical_verdict.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

/// Opening-state provenance for a move.
///
/// `bookTheory` is reserved for confirmed ECO/book hits. Early moves that
/// are not in the local book stay explicitly separate so UI copy can say
/// "Opening phase" without pretending the move is known theory.
enum OpeningStatus {
  bookTheory,
  openingPhaseUnknown,
  bookDeviation,
  notOpening,
}

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

  /// Classification before rare review badges are applied.
  final MoveQuality baseClassification;

  /// Final classification after strict special-tier gates.
  final MoveQuality finalClassification;

  /// Stable machine-readable reason for calibration/debug export.
  final String reasonCode;

  /// Versioned provider-neutral facts that reproduce the stored decision.
  /// Historic records written before analysis schema v4 leave this null;
  /// absence is unavailable evidence, never a neutral evaluation.
  final MoveClassificationEvidence? classificationEvidence;

  /// Versioned opening facts used to derive Book provenance. Historic
  /// records written before opening policy v2 leave this null.
  final OpeningEvidence? openingEvidence;

  /// Structured decision diagnostics. These are machine facts only and are
  /// not rendered as explanation prose.
  final List<String> classificationReasonCodes;
  final List<String> classificationFailedGates;

  /// Whether the played move matched the engine's PV1 move.
  final bool playedEqualsPv1;

  /// Mover-perspective centipawn loss, when both evals are cp scores.
  final int? moverCpLoss;

  /// Whether this ply has a complete before/after engine pair. Book moves
  /// deliberately set this false and are excluded from numeric metrics.
  final bool engineEvaluationAvailable;
  final int? requestedDepth;
  final int? achievedDepthBefore;
  final int? achievedDepthAfter;
  final int multiPvReceived;
  final bool searchQualityMet;

  /// Tactical/material tags used by the classifier and debug export.
  final bool isCapture;
  final bool isFreeCapture;
  final bool isRecapture;
  final bool isSacrifice;
  final bool isFirstSacrificePly;

  /// Candidate-only deep tactical verification result.
  final DeepTacticalVerdict tacticalVerdict;

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

  /// Whether this move is confirmed theory, an early sideline, or no longer
  /// in the opening.
  final OpeningStatus openingStatus;

  /// Opening name (if detected).
  final String? openingName;

  /// ECO code (e.g., "B97").
  final String? ecoCode;

  /// Ranked engine lines from the position before this move.
  final List<EngineLine> engineLines;

  /// Human-readable coach message.
  final String message;

  /// Shared coach explanation seed written by the analysis brain. UI copy
  /// services may adapt this only for historic schemas. Current offline
  /// analysis writes an explicit [insight] and leaves this empty.
  final String coachExplanation;

  /// Canonical Chapter 6 explanation. A non-null suppressed/unavailable state
  /// is intentional and prevents any fallback prose from becoming authority.
  final MoveInsight? insight;

  /// Digest over every persisted per-ply field except this digest. Current
  /// documents validate it without rerunning classifier or explanation policy.
  final String? analysisIntegrityDigest;

  /// Analysis/cache provenance for archive invalidation and debug export.
  final String analysisMode;
  final int classifierVersion;
  final String engineVersion;
  final Map<String, dynamic> debugMetadata;

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
    MoveQuality? baseClassification,
    MoveQuality? finalClassification,
    this.reasonCode = 'legacy',
    this.classificationEvidence,
    this.openingEvidence,
    this.classificationReasonCodes = const <String>[],
    this.classificationFailedGates = const <String>[],
    this.playedEqualsPv1 = false,
    this.moverCpLoss,
    this.engineEvaluationAvailable = true,
    this.requestedDepth,
    this.achievedDepthBefore,
    this.achievedDepthAfter,
    this.multiPvReceived = 0,
    this.searchQualityMet = false,
    this.isCapture = false,
    this.isFreeCapture = false,
    this.isRecapture = false,
    this.isSacrifice = false,
    this.isFirstSacrificePly = false,
    this.tacticalVerdict = DeepTacticalVerdict.none,
    this.engineBestMoveUci,
    this.engineBestMoveSan,
    this.scoreCpAfter,
    this.mateInAfter,
    this.inBook = false,
    this.openingStatus = OpeningStatus.notOpening,
    this.openingName,
    this.ecoCode,
    this.engineLines = const <EngineLine>[],
    required this.message,
    String? coachExplanation,
    this.insight,
    this.analysisIntegrityDigest,
    this.analysisMode = 'deep',
    this.classifierVersion = kApexClassifierVersion,
    this.engineVersion = 'unknown',
    this.debugMetadata = const <String, dynamic>{},
  }) : baseClassification = baseClassification ?? classification,
       finalClassification = finalClassification ?? classification,
       coachExplanation = coachExplanation ?? message;

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
    'baseClassification': baseClassification.name,
    'finalClassification': finalClassification.name,
    'reasonCode': reasonCode,
    'classificationEvidence': classificationEvidence?.toJson(),
    'openingEvidence': openingEvidence?.toJson(),
    'classificationReasonCodes': classificationReasonCodes,
    'classificationFailedGates': classificationFailedGates,
    'playedEqualsPv1': playedEqualsPv1,
    'moverCpLoss': moverCpLoss,
    'engineEvaluationAvailable': engineEvaluationAvailable,
    'requestedDepth': requestedDepth,
    'achievedDepthBefore': achievedDepthBefore,
    'achievedDepthAfter': achievedDepthAfter,
    'multiPvReceived': multiPvReceived,
    'searchQualityMet': searchQualityMet,
    'isCapture': isCapture,
    'isFreeCapture': isFreeCapture,
    'isRecapture': isRecapture,
    'isSacrifice': isSacrifice,
    'isFirstSacrificePly': isFirstSacrificePly,
    'tacticalVerdict': tacticalVerdict.toJson(),
    'engineBestMoveUci': engineBestMoveUci,
    'engineBestMoveSan': engineBestMoveSan,
    'scoreCpAfter': scoreCpAfter,
    'mateInAfter': mateInAfter,
    'inBook': inBook,
    'openingStatus': openingStatus.name,
    'openingName': openingName,
    'ecoCode': ecoCode,
    'engineLines': engineLines.map((l) => l.toJson()).toList(),
    'message': message,
    'coachExplanation': coachExplanation,
    if (insight != null) 'insight': insight!.toJson(),
    if (analysisIntegrityDigest != null)
      'analysisIntegrityDigest': analysisIntegrityDigest,
    'analysisMode': analysisMode,
    'classifierVersion': classifierVersion,
    'engineVersion': engineVersion,
    'debugMetadata': debugMetadata,
  };

  factory MoveAnalysis.fromJson(Map<dynamic, dynamic> j) {
    final hasStoredNumericEvidence =
        j['winPercentBefore'] is num &&
        j['winPercentAfter'] is num &&
        j['deltaW'] is num;
    final classRaw = j['classification'] as String?;
    MoveQuality? classification;
    for (final quality in MoveQuality.values) {
      if (quality.name == classRaw) {
        classification = quality;
        break;
      }
    }
    if (classification == null) {
      throw FormatException('Unknown persisted move classification: $classRaw');
    }
    MoveQuality parseQuality(String? raw, MoveQuality fallback) => MoveQuality
        .values
        .firstWhere((q) => q.name == raw, orElse: () => fallback);
    final openingStatusRaw = j['openingStatus'] as String?;
    final openingStatus = OpeningStatus.values.firstWhere(
      (s) => s.name == openingStatusRaw,
      orElse: () => (j['inBook'] as bool? ?? false)
          ? OpeningStatus.bookTheory
          : OpeningStatus.notOpening,
    );
    final rawLines = j['engineLines'] as List<dynamic>?;
    return MoveAnalysis(
      ply: (j['ply'] as num).toInt(),
      san: j['san'] as String? ?? '',
      uci: j['uci'] as String? ?? '',
      fenBefore: j['fenBefore'] as String? ?? '',
      fenAfter: j['fenAfter'] as String? ?? '',
      targetSquare: j['targetSquare'] as String? ?? '',
      winPercentBefore: (j['winPercentBefore'] as num?)?.toDouble() ?? 50.0,
      winPercentAfter: (j['winPercentAfter'] as num?)?.toDouble() ?? 50.0,
      deltaW: (j['deltaW'] as num?)?.toDouble() ?? 0.0,
      isWhiteMove: j['isWhiteMove'] as bool? ?? true,
      classification: classification,
      baseClassification: parseQuality(
        j['baseClassification'] as String?,
        classification,
      ),
      finalClassification: parseQuality(
        j['finalClassification'] as String?,
        classification,
      ),
      reasonCode: j['reasonCode'] as String? ?? 'legacy',
      classificationEvidence: j['classificationEvidence'] is Map
          ? MoveClassificationEvidence.fromJson(
              j['classificationEvidence'] as Map,
            )
          : null,
      openingEvidence: j['openingEvidence'] is Map
          ? OpeningEvidence.fromJson(j['openingEvidence'] as Map)
          : null,
      classificationReasonCodes:
          (j['classificationReasonCodes'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList(growable: false) ??
          <String>[j['reasonCode'] as String? ?? 'legacy'],
      classificationFailedGates:
          (j['classificationFailedGates'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList(growable: false) ??
          const <String>[],
      playedEqualsPv1: j['playedEqualsPv1'] as bool? ?? false,
      moverCpLoss: (j['moverCpLoss'] as num?)?.toInt(),
      engineEvaluationAvailable:
          j['engineEvaluationAvailable'] as bool? ??
          (hasStoredNumericEvidence && !(j['inBook'] as bool? ?? false)),
      requestedDepth: (j['requestedDepth'] as num?)?.toInt(),
      achievedDepthBefore: (j['achievedDepthBefore'] as num?)?.toInt(),
      achievedDepthAfter: (j['achievedDepthAfter'] as num?)?.toInt(),
      multiPvReceived: (j['multiPvReceived'] as num?)?.toInt() ?? 0,
      searchQualityMet: j['searchQualityMet'] as bool? ?? false,
      isCapture: j['isCapture'] as bool? ?? false,
      isFreeCapture: j['isFreeCapture'] as bool? ?? false,
      isRecapture: j['isRecapture'] as bool? ?? false,
      isSacrifice: j['isSacrifice'] as bool? ?? false,
      isFirstSacrificePly: j['isFirstSacrificePly'] as bool? ?? false,
      tacticalVerdict: DeepTacticalVerdict.fromJson(
        j['tacticalVerdict'] is Map ? j['tacticalVerdict'] as Map : null,
      ),
      engineBestMoveUci: j['engineBestMoveUci'] as String?,
      engineBestMoveSan: j['engineBestMoveSan'] as String?,
      scoreCpAfter: (j['scoreCpAfter'] as num?)?.toInt(),
      mateInAfter: (j['mateInAfter'] as num?)?.toInt(),
      inBook: j['inBook'] as bool? ?? false,
      openingStatus: openingStatus,
      openingName: j['openingName'] as String?,
      ecoCode: j['ecoCode'] as String?,
      engineLines:
          rawLines
              ?.whereType<Map<dynamic, dynamic>>()
              .map(EngineLine.fromJson)
              .toList(growable: false) ??
          const <EngineLine>[],
      message: j['message'] as String? ?? '',
      coachExplanation: j['coachExplanation'] as String?,
      insight: j['insight'] is Map
          ? MoveInsight.fromJson(j['insight'] as Map)
          : null,
      analysisIntegrityDigest: j['analysisIntegrityDigest'] as String?,
      analysisMode: j['analysisMode'] as String? ?? 'deep',
      classifierVersion: (j['classifierVersion'] as num?)?.toInt() ?? 1,
      engineVersion: j['engineVersion'] as String? ?? 'unknown',
      debugMetadata:
          (j['debugMetadata'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v),
          ) ??
          const <String, dynamic>{},
    );
  }

  String get computedAnalysisIntegrityDigest {
    final json = Map<String, dynamic>.from(toJson())
      ..remove('analysisIntegrityDigest');
    return sha256.convert(utf8.encode(jsonEncode(json))).toString();
  }

  bool get hasValidAnalysisIntegrity =>
      analysisIntegrityDigest != null &&
      RegExp(r'^[0-9a-f]{64}$').hasMatch(analysisIntegrityDigest!) &&
      analysisIntegrityDigest == computedAnalysisIntegrityDigest;

  /// Seals a newly generated move after all classifier/opening/insight fields
  /// are final. Historic/synthetic callers can keep using the const constructor.
  MoveAnalysis sealAnalysisIntegrity() {
    final json = Map<String, dynamic>.from(toJson())
      ..remove('analysisIntegrityDigest');
    json['analysisIntegrityDigest'] = sha256
        .convert(utf8.encode(jsonEncode(json)))
        .toString();
    return MoveAnalysis.fromJson(json);
  }
}
