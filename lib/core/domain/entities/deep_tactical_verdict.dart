/// Serializable tactical verification result for a reviewed ply.
///
/// The verifier is intentionally modelled as data rather than UI copy or
/// screen logic. Every analysis entry point writes the same structure into
/// [MoveAnalysis], and downstream surfaces can render it without re-running
/// classifier rules.
library;

class DeepTacticalVerdict {
  const DeepTacticalVerdict({
    required this.isCandidate,
    required this.verified,
    required this.candidateType,
    required this.isBestOrNearBest,
    required this.isOnlyMove,
    required this.isNonObvious,
    required this.lowDepthRejectedHighDepthApproved,
    required this.forcingLineLength,
    required this.forcedMate,
    required this.forcedPromotion,
    required this.decisiveMaterialWin,
    required this.sacrificeTrajectory,
    required this.delayedSacrifice,
    required this.queenSacrifice,
    required this.rookSacrifice,
    required this.decoy,
    required this.deflection,
    required this.matingNet,
    required this.promotionNet,
    required this.reasonCode,
    required this.humanExplanation,
    this.lowDepthRank,
    this.highDepthRank,
    this.lowDepthScore,
    this.highDepthScore,
    this.lowDepthBestMove,
    this.highDepthBestMove,
    this.nonObviousScore = 0,
    this.movedPieceCapturedInPV = false,
    this.capturedOnPlyOffset,
    this.firstCommitmentPly,
    this.candidateVerified = false,
    this.verificationDepth,
    this.verificationMultiPV,
  });

  static const none = DeepTacticalVerdict(
    isCandidate: false,
    verified: false,
    candidateType: 'none',
    isBestOrNearBest: false,
    isOnlyMove: false,
    isNonObvious: false,
    lowDepthRejectedHighDepthApproved: false,
    forcingLineLength: 0,
    forcedMate: false,
    forcedPromotion: false,
    decisiveMaterialWin: false,
    sacrificeTrajectory: false,
    delayedSacrifice: false,
    queenSacrifice: false,
    rookSacrifice: false,
    decoy: false,
    deflection: false,
    matingNet: false,
    promotionNet: false,
    reasonCode: 'none',
    humanExplanation: '',
  );

  final bool isCandidate;
  final bool verified;
  final String candidateType;
  final bool isBestOrNearBest;
  final bool isOnlyMove;
  final bool isNonObvious;
  final bool lowDepthRejectedHighDepthApproved;
  final int forcingLineLength;
  final bool forcedMate;
  final bool forcedPromotion;
  final bool decisiveMaterialWin;
  final bool sacrificeTrajectory;
  final bool delayedSacrifice;
  final bool queenSacrifice;
  final bool rookSacrifice;
  final bool decoy;
  final bool deflection;
  final bool matingNet;
  final bool promotionNet;
  final String reasonCode;
  final String humanExplanation;

  final int? lowDepthRank;
  final int? highDepthRank;
  final String? lowDepthScore;
  final String? highDepthScore;
  final String? lowDepthBestMove;
  final String? highDepthBestMove;
  final double nonObviousScore;
  final bool movedPieceCapturedInPV;
  final int? capturedOnPlyOffset;
  final int? firstCommitmentPly;
  final bool candidateVerified;
  final int? verificationDepth;
  final int? verificationMultiPV;

  bool get hasSacrificeMotif =>
      sacrificeTrajectory ||
      delayedSacrifice ||
      queenSacrifice ||
      rookSacrifice;

  bool get hasForcingOutcome =>
      forcedMate ||
      forcedPromotion ||
      decisiveMaterialWin ||
      matingNet ||
      promotionNet;

  Map<String, dynamic> toJson() => {
    'isCandidate': isCandidate,
    'verified': verified,
    'candidateType': candidateType,
    'isBestOrNearBest': isBestOrNearBest,
    'isOnlyMove': isOnlyMove,
    'isNonObvious': isNonObvious,
    'lowDepthRejectedHighDepthApproved': lowDepthRejectedHighDepthApproved,
    'forcingLineLength': forcingLineLength,
    'forcedMate': forcedMate,
    'forcedPromotion': forcedPromotion,
    'decisiveMaterialWin': decisiveMaterialWin,
    'sacrificeTrajectory': sacrificeTrajectory,
    'delayedSacrifice': delayedSacrifice,
    'queenSacrifice': queenSacrifice,
    'rookSacrifice': rookSacrifice,
    'decoy': decoy,
    'deflection': deflection,
    'matingNet': matingNet,
    'promotionNet': promotionNet,
    'reasonCode': reasonCode,
    'humanExplanation': humanExplanation,
    'lowDepthRank': lowDepthRank,
    'highDepthRank': highDepthRank,
    'lowDepthScore': lowDepthScore,
    'highDepthScore': highDepthScore,
    'lowDepthBestMove': lowDepthBestMove,
    'highDepthBestMove': highDepthBestMove,
    'nonObviousScore': nonObviousScore,
    'movedPieceCapturedInPV': movedPieceCapturedInPV,
    'capturedOnPlyOffset': capturedOnPlyOffset,
    'firstCommitmentPly': firstCommitmentPly,
    'candidateVerified': candidateVerified,
    'verificationDepth': verificationDepth,
    'verificationMultiPV': verificationMultiPV,
  };

  factory DeepTacticalVerdict.fromJson(Map<dynamic, dynamic>? j) {
    if (j == null) return DeepTacticalVerdict.none;
    return DeepTacticalVerdict(
      isCandidate: j['isCandidate'] as bool? ?? false,
      verified: j['verified'] as bool? ?? false,
      candidateType: j['candidateType'] as String? ?? 'none',
      isBestOrNearBest: j['isBestOrNearBest'] as bool? ?? false,
      isOnlyMove: j['isOnlyMove'] as bool? ?? false,
      isNonObvious: j['isNonObvious'] as bool? ?? false,
      lowDepthRejectedHighDepthApproved:
          j['lowDepthRejectedHighDepthApproved'] as bool? ?? false,
      forcingLineLength: (j['forcingLineLength'] as num?)?.toInt() ?? 0,
      forcedMate: j['forcedMate'] as bool? ?? false,
      forcedPromotion: j['forcedPromotion'] as bool? ?? false,
      decisiveMaterialWin: j['decisiveMaterialWin'] as bool? ?? false,
      sacrificeTrajectory: j['sacrificeTrajectory'] as bool? ?? false,
      delayedSacrifice: j['delayedSacrifice'] as bool? ?? false,
      queenSacrifice: j['queenSacrifice'] as bool? ?? false,
      rookSacrifice: j['rookSacrifice'] as bool? ?? false,
      decoy: j['decoy'] as bool? ?? false,
      deflection: j['deflection'] as bool? ?? false,
      matingNet: j['matingNet'] as bool? ?? false,
      promotionNet: j['promotionNet'] as bool? ?? false,
      reasonCode: j['reasonCode'] as String? ?? 'none',
      humanExplanation: j['humanExplanation'] as String? ?? '',
      lowDepthRank: (j['lowDepthRank'] as num?)?.toInt(),
      highDepthRank: (j['highDepthRank'] as num?)?.toInt(),
      lowDepthScore: j['lowDepthScore'] as String?,
      highDepthScore: j['highDepthScore'] as String?,
      lowDepthBestMove: j['lowDepthBestMove'] as String?,
      highDepthBestMove: j['highDepthBestMove'] as String?,
      nonObviousScore: (j['nonObviousScore'] as num?)?.toDouble() ?? 0,
      movedPieceCapturedInPV: j['movedPieceCapturedInPV'] as bool? ?? false,
      capturedOnPlyOffset: (j['capturedOnPlyOffset'] as num?)?.toInt(),
      firstCommitmentPly: (j['firstCommitmentPly'] as num?)?.toInt(),
      candidateVerified: j['candidateVerified'] as bool? ?? false,
      verificationDepth: (j['verificationDepth'] as num?)?.toInt(),
      verificationMultiPV: (j['verificationMultiPV'] as num?)?.toInt(),
    );
  }
}
