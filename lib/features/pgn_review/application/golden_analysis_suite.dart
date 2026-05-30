/// Durable local-analysis regression cases for scheduler and deep-gating work.
library;

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';

enum GoldenAnalysisCategory {
  tacticalShot('tacticalShot'),
  materialSacrifice('materialSacrifice'),
  queenTrap('queenTrap'),
  forcedMateThreat('forcedMateThreat'),
  onlyMoveDefense('onlyMoveDefense'),
  quietPreparatoryMove('quietPreparatoryMove'),
  zwischenzug('zwischenzug'),
  pinOrSkewer('pinOrSkewer'),
  fork('fork'),
  discoveredAttack('discoveredAttack'),
  promotionTactic('promotionTactic'),
  endgamePrecision('endgamePrecision'),
  openingKnownSkip('openingKnownSkip'),
  forcedMoveSkip('forcedMoveSkip'),
  invalidSafety('invalidSafety'),
  budgetPressure('budgetPressure');

  const GoldenAnalysisCategory(this.wire);

  final String wire;
}

enum GoldenAnalysisSourceType {
  fenPosition('fenPosition'),
  compactPgn('compactPgn'),
  parsedPosition('parsedPosition'),
  syntheticSafetyCase('syntheticSafetyCase');

  const GoldenAnalysisSourceType(this.wire);

  final String wire;
}

enum GoldenMotifTag {
  sacrifice('sacrifice'),
  temporarySacrifice('temporarySacrifice'),
  exchangeSacrifice('exchangeSacrifice'),
  pieceSacrifice('pieceSacrifice'),
  materialCompensation('materialCompensation'),
  queenWin('queenWin'),
  rookWin('rookWin'),
  pieceWin('pieceWin'),
  pawnBreakthrough('pawnBreakthrough'),
  mateThreat('mateThreat'),
  forcedMate('forcedMate'),
  backRankWeakness('backRankWeakness'),
  exposedKing('exposedKing'),
  kingHunt('kingHunt'),
  matingNet('matingNet'),
  forcingLine('forcingLine'),
  checkSequence('checkSequence'),
  onlyMove('onlyMove'),
  quietMove('quietMove'),
  quietPreparatoryMove('quietPreparatoryMove'),
  prophylaxis('prophylaxis'),
  restriction('restriction'),
  outpost('outpost'),
  openFile('openFile'),
  passedPawn('passedPawn'),
  zwischenzug('zwischenzug'),
  fork('fork'),
  pin('pin'),
  skewer('skewer'),
  discoveredAttack('discoveredAttack'),
  deflection('deflection'),
  decoy('decoy'),
  overload('overload'),
  trappedPiece('trappedPiece'),
  clearance('clearance'),
  interference('interference'),
  removeDefender('removeDefender'),
  promotion('promotion'),
  endgamePrecision('endgamePrecision'),
  openingTheory('openingTheory'),
  invalidSafety('invalidSafety'),
  budgetPressure('budgetPressure'),
  evidenceIncomplete('evidenceIncomplete'),
  realDeviceProofNeeded('realDeviceProofNeeded');

  const GoldenMotifTag(this.wire);

  final String wire;
}

enum GoldenMotifGroup {
  materialAndSacrifice('materialAndSacrifice'),
  kingSafetyAndMate('kingSafetyAndMate'),
  forcingAndTactical('forcingAndTactical'),
  positionalAndQuiet('positionalAndQuiet'),
  safetyAndControl('safetyAndControl');

  const GoldenMotifGroup(this.wire);

  final String wire;
}

enum GoldenMotifEvidenceGroup {
  tactical('tactical'),
  material('material'),
  kingSafety('kingSafety'),
  forcing('forcing'),
  positional('positional'),
  suppression('suppression'),
  uncertainty('uncertainty'),
  budget('budget'),
  realDeviceProof('realDeviceProof');

  const GoldenMotifEvidenceGroup(this.wire);

  final String wire;
}

enum GoldenExpectedBehaviorCode {
  shouldRejectInvalidFen('shouldRejectInvalidFen'),
  shouldSkipOpening('shouldSkipOpening'),
  shouldSkipForced('shouldSkipForced'),
  shouldGenerateDeepCandidate('shouldGenerateDeepCandidate'),
  shouldSelectDeepUnderBalanced('shouldSelectDeepUnderBalanced'),
  shouldSelectDeepUnderPerformance('shouldSelectDeepUnderPerformance'),
  shouldNotSelectDeepForQuietOpening('shouldNotSelectDeepForQuietOpening'),
  shouldUseMultiPvAtLeast2('shouldUseMultiPvAtLeast2'),
  shouldStayWithinBalancedBudget('shouldStayWithinBalancedBudget'),
  shouldStayWithinPerformanceBudget('shouldStayWithinPerformanceBudget'),
  shouldPreserveNoTimeouts('shouldPreserveNoTimeouts'),
  shouldReportBudgetPressure('shouldReportBudgetPressure'),
  shouldSurfaceEvidenceWarning('shouldSurfaceEvidenceWarning'),
  shouldNotEmitFinalLabel('shouldNotEmitFinalLabel');

  const GoldenExpectedBehaviorCode(this.wire);

  final String wire;
}

enum GoldenAnalysisSuiteMode {
  metadataOnly('metadataOnly'),
  planOnly('planOnly'),
  fakeEvidence('fakeEvidence');

  const GoldenAnalysisSuiteMode(this.wire);

  final String wire;
}

enum GoldenAnalysisSuiteStatus {
  passed('passed'),
  passedWithWarnings('passedWithWarnings'),
  failed('failed'),
  empty('empty');

  const GoldenAnalysisSuiteStatus(this.wire);

  final String wire;
}

class GoldenAnalysisSafetyFlags {
  const GoldenAnalysisSafetyFlags({
    this.licenseSafe = true,
    this.handcrafted = true,
    this.externalComparisonPending = false,
    this.noFinalLabel = true,
  });

  final bool licenseSafe;
  final bool handcrafted;
  final bool externalComparisonPending;
  final bool noFinalLabel;

  bool get explicitlySafe =>
      licenseSafe && (handcrafted || externalComparisonPending);
}

class GoldenTacticalEvidenceExpectation {
  const GoldenTacticalEvidenceExpectation({
    this.requiresMaterialSwing = false,
    this.requiresMaterialCompensation = false,
    this.requiresMateSignal = false,
    this.requiresForcingLineSignal = false,
    this.requiresKingSafetySignal = false,
    this.requiresOnlyMoveSignal = false,
    this.requiresQuietMoveEvidence = false,
    this.requiresCandidateSpread = false,
    this.requiresMultiPvEvidence = false,
    this.requiresPvNonEmpty = false,
    this.requiresBudgetPressure = false,
    this.requiresSuppressionReason = false,
    this.requiresRealDeviceProof = false,
    this.tacticalReasons = const <DeepCandidateReasonCode>{},
    this.materialReasons = const <DeepCandidateReasonCode>{},
    this.kingSafetyReasons = const <DeepCandidateReasonCode>{},
    this.forcingReasons = const <DeepCandidateReasonCode>{},
    this.positionalReasons = const <DeepCandidateReasonCode>{},
    this.suppressionReasons = const <DeepCandidateReasonCode>{},
    this.uncertaintyReasons = const <DeepCandidateReasonCode>{},
    this.declaredGroups = const <GoldenMotifEvidenceGroup>{},
  });

  final bool requiresMaterialSwing;
  final bool requiresMaterialCompensation;
  final bool requiresMateSignal;
  final bool requiresForcingLineSignal;
  final bool requiresKingSafetySignal;
  final bool requiresOnlyMoveSignal;
  final bool requiresQuietMoveEvidence;
  final bool requiresCandidateSpread;
  final bool requiresMultiPvEvidence;
  final bool requiresPvNonEmpty;
  final bool requiresBudgetPressure;
  final bool requiresSuppressionReason;
  final bool requiresRealDeviceProof;
  final Set<DeepCandidateReasonCode> tacticalReasons;
  final Set<DeepCandidateReasonCode> materialReasons;
  final Set<DeepCandidateReasonCode> kingSafetyReasons;
  final Set<DeepCandidateReasonCode> forcingReasons;
  final Set<DeepCandidateReasonCode> positionalReasons;
  final Set<DeepCandidateReasonCode> suppressionReasons;
  final Set<DeepCandidateReasonCode> uncertaintyReasons;
  final Set<GoldenMotifEvidenceGroup> declaredGroups;

  Set<GoldenMotifEvidenceGroup> get evidenceGroups {
    final groups = <GoldenMotifEvidenceGroup>{...declaredGroups};
    if (requiresCandidateSpread ||
        requiresMultiPvEvidence ||
        requiresPvNonEmpty ||
        tacticalReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.tactical);
    }
    if (requiresMaterialSwing ||
        requiresMaterialCompensation ||
        materialReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.material);
    }
    if (requiresMateSignal ||
        requiresKingSafetySignal ||
        kingSafetyReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.kingSafety);
    }
    if (requiresForcingLineSignal || forcingReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.forcing);
    }
    if (requiresQuietMoveEvidence || positionalReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.positional);
    }
    if (requiresOnlyMoveSignal ||
        requiresSuppressionReason ||
        suppressionReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.suppression);
    }
    if (uncertaintyReasons.isNotEmpty) {
      groups.add(GoldenMotifEvidenceGroup.uncertainty);
    }
    if (requiresBudgetPressure) {
      groups.add(GoldenMotifEvidenceGroup.budget);
    }
    if (requiresRealDeviceProof) {
      groups.add(GoldenMotifEvidenceGroup.realDeviceProof);
    }
    return groups;
  }

  GoldenTacticalEvidenceExpectation merge(
    GoldenTacticalEvidenceExpectation other,
  ) {
    return GoldenTacticalEvidenceExpectation(
      requiresMaterialSwing:
          requiresMaterialSwing || other.requiresMaterialSwing,
      requiresMaterialCompensation:
          requiresMaterialCompensation || other.requiresMaterialCompensation,
      requiresMateSignal: requiresMateSignal || other.requiresMateSignal,
      requiresForcingLineSignal:
          requiresForcingLineSignal || other.requiresForcingLineSignal,
      requiresKingSafetySignal:
          requiresKingSafetySignal || other.requiresKingSafetySignal,
      requiresOnlyMoveSignal:
          requiresOnlyMoveSignal || other.requiresOnlyMoveSignal,
      requiresQuietMoveEvidence:
          requiresQuietMoveEvidence || other.requiresQuietMoveEvidence,
      requiresCandidateSpread:
          requiresCandidateSpread || other.requiresCandidateSpread,
      requiresMultiPvEvidence:
          requiresMultiPvEvidence || other.requiresMultiPvEvidence,
      requiresPvNonEmpty: requiresPvNonEmpty || other.requiresPvNonEmpty,
      requiresBudgetPressure:
          requiresBudgetPressure || other.requiresBudgetPressure,
      requiresSuppressionReason:
          requiresSuppressionReason || other.requiresSuppressionReason,
      requiresRealDeviceProof:
          requiresRealDeviceProof || other.requiresRealDeviceProof,
      tacticalReasons: {...tacticalReasons, ...other.tacticalReasons},
      materialReasons: {...materialReasons, ...other.materialReasons},
      kingSafetyReasons: {...kingSafetyReasons, ...other.kingSafetyReasons},
      forcingReasons: {...forcingReasons, ...other.forcingReasons},
      positionalReasons: {...positionalReasons, ...other.positionalReasons},
      suppressionReasons: {...suppressionReasons, ...other.suppressionReasons},
      uncertaintyReasons: {...uncertaintyReasons, ...other.uncertaintyReasons},
      declaredGroups: {...declaredGroups, ...other.declaredGroups},
    );
  }
}

class GoldenMotifEvidenceProfile {
  const GoldenMotifEvidenceProfile({
    required this.motifGroup,
    this.evidence = const GoldenTacticalEvidenceExpectation(),
    this.requiresFakeEvidence = false,
    this.requiresFutureRealDeviceProof = false,
    this.metadataOnlySafe = false,
    this.doesNotForceDeepByItself = false,
  });

  final GoldenMotifGroup motifGroup;
  final GoldenTacticalEvidenceExpectation evidence;
  final bool requiresFakeEvidence;
  final bool requiresFutureRealDeviceProof;
  final bool metadataOnlySafe;
  final bool doesNotForceDeepByItself;
}

class GoldenMotifEvidenceRequirement {
  const GoldenMotifEvidenceRequirement({
    required this.motifGroups,
    required this.evidence,
    required this.fakeEvidenceMotifs,
    required this.futureRealDeviceProofMotifs,
    required this.metadataOnlySafeMotifs,
    required this.motifsThatDoNotForceDeepByThemselves,
  });

  final Set<GoldenMotifGroup> motifGroups;
  final GoldenTacticalEvidenceExpectation evidence;
  final Set<GoldenMotifTag> fakeEvidenceMotifs;
  final Set<GoldenMotifTag> futureRealDeviceProofMotifs;
  final Set<GoldenMotifTag> metadataOnlySafeMotifs;
  final Set<GoldenMotifTag> motifsThatDoNotForceDeepByThemselves;

  Set<GoldenMotifEvidenceGroup> get evidenceGroups => evidence.evidenceGroups;

  bool get requiresFakeEvidence => fakeEvidenceMotifs.isNotEmpty;

  bool get requiresFutureRealDeviceProof =>
      futureRealDeviceProofMotifs.isNotEmpty ||
      evidence.requiresRealDeviceProof;
}

class GoldenMotifEvidencePolicy {
  const GoldenMotifEvidencePolicy();

  GoldenMotifEvidenceRequirement requirementsFor(
    Iterable<GoldenMotifTag> motifs,
  ) {
    var evidence = const GoldenTacticalEvidenceExpectation();
    final motifGroups = <GoldenMotifGroup>{};
    final fakeEvidenceMotifs = <GoldenMotifTag>{};
    final futureRealDeviceProofMotifs = <GoldenMotifTag>{};
    final metadataOnlySafeMotifs = <GoldenMotifTag>{};
    final motifsThatDoNotForceDeepByThemselves = <GoldenMotifTag>{};

    for (final motif in motifs) {
      final profile = profileFor(motif);
      motifGroups.add(profile.motifGroup);
      evidence = evidence.merge(profile.evidence);
      if (profile.requiresFakeEvidence) {
        fakeEvidenceMotifs.add(motif);
      }
      if (profile.requiresFutureRealDeviceProof) {
        futureRealDeviceProofMotifs.add(motif);
      }
      if (profile.metadataOnlySafe) {
        metadataOnlySafeMotifs.add(motif);
      }
      if (profile.doesNotForceDeepByItself) {
        motifsThatDoNotForceDeepByThemselves.add(motif);
      }
    }

    return GoldenMotifEvidenceRequirement(
      motifGroups: Set<GoldenMotifGroup>.unmodifiable(motifGroups),
      evidence: evidence,
      fakeEvidenceMotifs: Set<GoldenMotifTag>.unmodifiable(fakeEvidenceMotifs),
      futureRealDeviceProofMotifs: Set<GoldenMotifTag>.unmodifiable(
        futureRealDeviceProofMotifs,
      ),
      metadataOnlySafeMotifs: Set<GoldenMotifTag>.unmodifiable(
        metadataOnlySafeMotifs,
      ),
      motifsThatDoNotForceDeepByThemselves: Set<GoldenMotifTag>.unmodifiable(
        motifsThatDoNotForceDeepByThemselves,
      ),
    );
  }

  GoldenMotifEvidenceProfile profileFor(GoldenMotifTag motif) {
    return switch (motif) {
      GoldenMotifTag.sacrifice ||
      GoldenMotifTag.temporarySacrifice ||
      GoldenMotifTag.exchangeSacrifice ||
      GoldenMotifTag.pieceSacrifice => _sacrificeProfile,
      GoldenMotifTag.materialCompensation => _materialCompensationProfile,
      GoldenMotifTag.queenWin => _queenWinProfile,
      GoldenMotifTag.rookWin ||
      GoldenMotifTag.pieceWin ||
      GoldenMotifTag.pawnBreakthrough => _materialWinProfile,
      GoldenMotifTag.mateThreat => _mateThreatProfile,
      GoldenMotifTag.forcedMate => _forcedMateProfile,
      GoldenMotifTag.backRankWeakness ||
      GoldenMotifTag.exposedKing ||
      GoldenMotifTag.kingHunt ||
      GoldenMotifTag.matingNet => _kingSafetyProfile,
      GoldenMotifTag.forcingLine ||
      GoldenMotifTag.checkSequence => _forcingProfile,
      GoldenMotifTag.zwischenzug ||
      GoldenMotifTag.fork ||
      GoldenMotifTag.pin ||
      GoldenMotifTag.skewer ||
      GoldenMotifTag.discoveredAttack ||
      GoldenMotifTag.deflection ||
      GoldenMotifTag.decoy ||
      GoldenMotifTag.overload ||
      GoldenMotifTag.trappedPiece ||
      GoldenMotifTag.clearance ||
      GoldenMotifTag.interference ||
      GoldenMotifTag.removeDefender ||
      GoldenMotifTag.promotion => _tacticalProfile,
      GoldenMotifTag.quietMove ||
      GoldenMotifTag.prophylaxis ||
      GoldenMotifTag.restriction ||
      GoldenMotifTag.outpost ||
      GoldenMotifTag.openFile ||
      GoldenMotifTag.passedPawn ||
      GoldenMotifTag.endgamePrecision => _positionalProfile,
      GoldenMotifTag.quietPreparatoryMove => _quietPreparatoryProfile,
      GoldenMotifTag.onlyMove => _onlyMoveProfile,
      GoldenMotifTag.openingTheory => _openingTheoryProfile,
      GoldenMotifTag.invalidSafety => _invalidSafetyProfile,
      GoldenMotifTag.budgetPressure => _budgetPressureProfile,
      GoldenMotifTag.evidenceIncomplete => _evidenceIncompleteProfile,
      GoldenMotifTag.realDeviceProofNeeded => _realDeviceProofProfile,
    };
  }

  bool requiresFakeEvidence(Iterable<GoldenMotifTag> motifs) =>
      requirementsFor(motifs).requiresFakeEvidence;

  bool requiresFutureRealDeviceProof(Iterable<GoldenMotifTag> motifs) =>
      requirementsFor(motifs).requiresFutureRealDeviceProof;

  bool metadataOnlySafe(Iterable<GoldenMotifTag> motifs) {
    final requirement = requirementsFor(motifs);
    return requirement.metadataOnlySafeMotifs.length == motifs.length;
  }

  bool shouldForceDeepByItself(GoldenMotifTag motif) =>
      !profileFor(motif).doesNotForceDeepByItself;
}

const _materialReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.materialSwing,
  DeepCandidateReasonCode.captureOrPromotion,
};

const _majorMaterialReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.materialSwing,
  DeepCandidateReasonCode.majorEvalSwing,
  DeepCandidateReasonCode.captureOrPromotion,
};

const _tacticalReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.tacticalSignal,
  DeepCandidateReasonCode.givesCheck,
  DeepCandidateReasonCode.captureOrPromotion,
  DeepCandidateReasonCode.candidateEvalSpread,
};

const _forcingReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.tacticalSignal,
  DeepCandidateReasonCode.givesCheck,
  DeepCandidateReasonCode.candidateEvalSpread,
  DeepCandidateReasonCode.mateScoreDetected,
};

const _mateReasons = <DeepCandidateReasonCode>{
  DeepCandidateReasonCode.mateScoreDetected,
  DeepCandidateReasonCode.tacticalSignal,
  DeepCandidateReasonCode.givesCheck,
};

const _sacrificeProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.materialAndSacrifice,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresMaterialSwing: true,
    requiresMaterialCompensation: true,
    tacticalReasons: _tacticalReasons,
    materialReasons: _materialReasons,
  ),
);

const _materialCompensationProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.materialAndSacrifice,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresMaterialCompensation: true,
    materialReasons: _materialReasons,
  ),
);

const _queenWinProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.materialAndSacrifice,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresMaterialSwing: true,
    requiresMultiPvEvidence: true,
    tacticalReasons: _tacticalReasons,
    materialReasons: _majorMaterialReasons,
  ),
);

const _materialWinProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.materialAndSacrifice,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresMaterialSwing: true,
    materialReasons: _materialReasons,
  ),
);

const _mateThreatProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.kingSafetyAndMate,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresMateSignal: true,
    requiresKingSafetySignal: true,
    requiresForcingLineSignal: true,
    kingSafetyReasons: _mateReasons,
    forcingReasons: _forcingReasons,
  ),
  requiresFakeEvidence: true,
);

const _forcedMateProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.kingSafetyAndMate,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresMateSignal: true,
    requiresPvNonEmpty: true,
    requiresRealDeviceProof: true,
    kingSafetyReasons: _mateReasons,
    forcingReasons: _forcingReasons,
  ),
  requiresFakeEvidence: true,
  requiresFutureRealDeviceProof: true,
);

const _kingSafetyProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.kingSafetyAndMate,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresKingSafetySignal: true,
    kingSafetyReasons: _mateReasons,
    forcingReasons: _forcingReasons,
  ),
);

const _forcingProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.forcingAndTactical,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresForcingLineSignal: true,
    forcingReasons: _forcingReasons,
  ),
);

const _tacticalProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.forcingAndTactical,
  evidence: GoldenTacticalEvidenceExpectation(
    tacticalReasons: _tacticalReasons,
  ),
);

const _positionalProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.positionalAndQuiet,
  evidence: GoldenTacticalEvidenceExpectation(
    declaredGroups: <GoldenMotifEvidenceGroup>{
      GoldenMotifEvidenceGroup.positional,
    },
  ),
  metadataOnlySafe: true,
  doesNotForceDeepByItself: true,
);

const _quietPreparatoryProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.positionalAndQuiet,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresQuietMoveEvidence: true,
    declaredGroups: <GoldenMotifEvidenceGroup>{
      GoldenMotifEvidenceGroup.positional,
      GoldenMotifEvidenceGroup.uncertainty,
    },
    uncertaintyReasons: <DeepCandidateReasonCode>{
      DeepCandidateReasonCode.missingFastPv,
    },
  ),
  doesNotForceDeepByItself: true,
);

const _onlyMoveProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.safetyAndControl,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresOnlyMoveSignal: true,
    requiresSuppressionReason: true,
    suppressionReasons: <DeepCandidateReasonCode>{
      DeepCandidateReasonCode.forcedSuppressed,
    },
  ),
  metadataOnlySafe: true,
  doesNotForceDeepByItself: true,
);

const _openingTheoryProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.safetyAndControl,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresSuppressionReason: true,
    suppressionReasons: <DeepCandidateReasonCode>{
      DeepCandidateReasonCode.openingSuppressed,
    },
  ),
  metadataOnlySafe: true,
  doesNotForceDeepByItself: true,
);

const _invalidSafetyProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.safetyAndControl,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresSuppressionReason: true,
    suppressionReasons: <DeepCandidateReasonCode>{
      DeepCandidateReasonCode.invalidFenSuppressed,
    },
  ),
  metadataOnlySafe: true,
  doesNotForceDeepByItself: true,
);

const _budgetPressureProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.safetyAndControl,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresBudgetPressure: true,
    requiresSuppressionReason: true,
    suppressionReasons: <DeepCandidateReasonCode>{
      DeepCandidateReasonCode.budgetSuppressed,
    },
  ),
  doesNotForceDeepByItself: true,
);

const _evidenceIncompleteProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.safetyAndControl,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresQuietMoveEvidence: true,
    declaredGroups: <GoldenMotifEvidenceGroup>{
      GoldenMotifEvidenceGroup.uncertainty,
    },
    uncertaintyReasons: <DeepCandidateReasonCode>{
      DeepCandidateReasonCode.missingFastPv,
    },
  ),
  doesNotForceDeepByItself: true,
);

const _realDeviceProofProfile = GoldenMotifEvidenceProfile(
  motifGroup: GoldenMotifGroup.safetyAndControl,
  evidence: GoldenTacticalEvidenceExpectation(
    requiresPvNonEmpty: true,
    requiresRealDeviceProof: true,
  ),
  requiresFutureRealDeviceProof: true,
  doesNotForceDeepByItself: true,
);

class GoldenEvidenceExpectation {
  const GoldenEvidenceExpectation({
    this.evalSwingMinCp,
    this.candidateSpreadMinCp,
    this.materialSwingMinCp,
    this.mateScoreExpected = false,
    this.pvShouldBeNonEmpty = false,
    this.minMultiPvIfSelected,
    this.expectedReasonCodes = const <DeepCandidateReasonCode>{},
    this.expectedSuppressionReasons = const <DeepCandidateReasonCode>{},
    this.tactical = const GoldenTacticalEvidenceExpectation(),
  }) : assert(evalSwingMinCp == null || evalSwingMinCp >= 0),
       assert(candidateSpreadMinCp == null || candidateSpreadMinCp >= 0),
       assert(materialSwingMinCp == null || materialSwingMinCp >= 0),
       assert(minMultiPvIfSelected == null || minMultiPvIfSelected >= 1);

  final int? evalSwingMinCp;
  final int? candidateSpreadMinCp;
  final int? materialSwingMinCp;
  final bool mateScoreExpected;
  final bool pvShouldBeNonEmpty;
  final int? minMultiPvIfSelected;
  final Set<DeepCandidateReasonCode> expectedReasonCodes;
  final Set<DeepCandidateReasonCode> expectedSuppressionReasons;
  final GoldenTacticalEvidenceExpectation tactical;
}

class GoldenExpectedBehavior {
  const GoldenExpectedBehavior({
    required this.behaviors,
    this.evidence = const GoldenEvidenceExpectation(),
    this.maxSelectedDeepRatio,
    this.maxDeepCandidates,
    this.maxDeepEngineCalls,
    this.maxTotalEngineCalls,
    this.maxTotalElapsedBudgetMs,
  }) : assert(
         maxSelectedDeepRatio == null ||
             (maxSelectedDeepRatio >= 0 && maxSelectedDeepRatio <= 1),
       ),
       assert(maxDeepCandidates == null || maxDeepCandidates >= 0),
       assert(maxDeepEngineCalls == null || maxDeepEngineCalls >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  final Set<GoldenExpectedBehaviorCode> behaviors;
  final GoldenEvidenceExpectation evidence;
  final double? maxSelectedDeepRatio;
  final int? maxDeepCandidates;
  final int? maxDeepEngineCalls;
  final int? maxTotalEngineCalls;
  final int? maxTotalElapsedBudgetMs;

  bool expects(GoldenExpectedBehaviorCode behavior) =>
      behaviors.contains(behavior);
}

class GoldenAnalysisCase {
  const GoldenAnalysisCase({
    required this.id,
    required this.title,
    required this.category,
    required this.sourceType,
    required this.inputs,
    required this.motifTags,
    required this.expected,
    this.fen,
    this.compactPgn,
    this.sideToMove,
    this.candidateMoveUci,
    this.expectedCandidateMovesUci = const <String>[],
    this.notes = const <String>[],
    this.safety = const GoldenAnalysisSafetyFlags(),
    this.fakeEvidence = const <GameLevelProvidedFastEvidence>[],
  });

  final String id;
  final String title;
  final GoldenAnalysisCategory category;
  final GoldenAnalysisSourceType sourceType;
  final List<LocalAnalysisPositionInput> inputs;
  final String? fen;
  final String? compactPgn;
  final String? sideToMove;
  final String? candidateMoveUci;
  final List<String> expectedCandidateMovesUci;
  final List<GoldenMotifTag> motifTags;
  final List<String> notes;
  final GoldenAnalysisSafetyFlags safety;
  final GoldenExpectedBehavior expected;
  final List<GameLevelProvidedFastEvidence> fakeEvidence;

  bool get hasSource {
    return switch (sourceType) {
      GoldenAnalysisSourceType.compactPgn => _hasText(compactPgn),
      GoldenAnalysisSourceType.fenPosition ||
      GoldenAnalysisSourceType.parsedPosition ||
      GoldenAnalysisSourceType.syntheticSafetyCase => _hasText(fen),
    };
  }

  bool get containsBlockedClaim {
    final searchable = <String>[
      id,
      title,
      if (fen != null) fen!,
      if (compactPgn != null) compactPgn!,
      if (sideToMove != null) sideToMove!,
      if (candidateMoveUci != null) candidateMoveUci!,
      ...expectedCandidateMovesUci,
      ...notes,
    ].join(' ');
    return _containsBlockedTerm(searchable);
  }

  GoldenAnalysisCase copyWith({
    String? id,
    String? title,
    GoldenAnalysisCategory? category,
    GoldenAnalysisSourceType? sourceType,
    List<LocalAnalysisPositionInput>? inputs,
    String? fen,
    bool clearFen = false,
    String? compactPgn,
    bool clearCompactPgn = false,
    List<GoldenMotifTag>? motifTags,
    GoldenAnalysisSafetyFlags? safety,
    GoldenExpectedBehavior? expected,
    List<GameLevelProvidedFastEvidence>? fakeEvidence,
  }) {
    return GoldenAnalysisCase(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      sourceType: sourceType ?? this.sourceType,
      inputs: inputs ?? this.inputs,
      motifTags: motifTags ?? this.motifTags,
      expected: expected ?? this.expected,
      fen: clearFen ? null : fen ?? this.fen,
      compactPgn: clearCompactPgn ? null : compactPgn ?? this.compactPgn,
      sideToMove: sideToMove,
      candidateMoveUci: candidateMoveUci,
      expectedCandidateMovesUci: expectedCandidateMovesUci,
      notes: notes,
      safety: safety ?? this.safety,
      fakeEvidence: fakeEvidence ?? this.fakeEvidence,
    );
  }
}

class GoldenAnalysisCaseResult {
  const GoldenAnalysisCaseResult({
    required this.caseId,
    required this.mode,
    required this.passed,
    required this.skipped,
    required this.candidateCount,
    required this.selectedDeepCount,
    required this.reasonCounts,
    required this.suppressionCounts,
    required this.warnings,
    required this.failures,
    required this.requiresFutureRealEngineProof,
  }) : assert(candidateCount >= 0),
       assert(selectedDeepCount >= 0);

  final String caseId;
  final GoldenAnalysisSuiteMode mode;
  final bool passed;
  final bool skipped;
  final int candidateCount;
  final int selectedDeepCount;
  final Map<DeepCandidateReasonCode, int> reasonCounts;
  final Map<DeepCandidateReasonCode, int> suppressionCounts;
  final List<String> warnings;
  final List<String> failures;
  final bool requiresFutureRealEngineProof;
}

class GoldenAnalysisSuiteRequest {
  const GoldenAnalysisSuiteRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.mode = GoldenAnalysisSuiteMode.metadataOnly,
    this.profile = LocalSchedulerProfile.balanced,
    this.lowPower = false,
  });

  final List<GoldenAnalysisCase> cases;
  final GoldenAnalysisSuiteMode mode;
  final LocalSchedulerProfile profile;
  final bool lowPower;
}

class GoldenAnalysisSuiteResult {
  const GoldenAnalysisSuiteResult({
    required this.status,
    required this.caseCount,
    required this.passedCount,
    required this.warningCount,
    required this.failedCount,
    required this.skippedCount,
    required this.categoriesCovered,
    required this.motifCoverage,
    required this.behaviorCoverage,
    required this.budgetPressureCases,
    required this.invalidSafetyCases,
    required this.casesRequiringFutureRealEngineProof,
    required this.caseResults,
    required this.warnings,
    required this.failures,
  }) : assert(caseCount >= 0),
       assert(passedCount >= 0),
       assert(warningCount >= 0),
       assert(failedCount >= 0),
       assert(skippedCount >= 0),
       assert(budgetPressureCases >= 0),
       assert(invalidSafetyCases >= 0),
       assert(casesRequiringFutureRealEngineProof >= 0);

  final GoldenAnalysisSuiteStatus status;
  final int caseCount;
  final int passedCount;
  final int warningCount;
  final int failedCount;
  final int skippedCount;
  final Set<GoldenAnalysisCategory> categoriesCovered;
  final Map<GoldenMotifTag, int> motifCoverage;
  final Map<GoldenExpectedBehaviorCode, int> behaviorCoverage;
  final int budgetPressureCases;
  final int invalidSafetyCases;
  final int casesRequiringFutureRealEngineProof;
  final List<GoldenAnalysisCaseResult> caseResults;
  final List<String> warnings;
  final List<String> failures;

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Golden Analysis Suite')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- cases: $caseCount')
      ..writeln('- passed: $passedCount')
      ..writeln('- warnings: $warningCount')
      ..writeln('- failed: $failedCount')
      ..writeln('- skipped: $skippedCount')
      ..writeln(
        '- future real-engine evidence: '
        '$casesRequiringFutureRealEngineProof',
      )
      ..writeln()
      ..writeln('## Category Coverage');
    for (final category
        in categoriesCovered.toList()
          ..sort((a, b) => a.wire.compareTo(b.wire))) {
      buffer.writeln('- ${category.wire}');
    }
    buffer
      ..writeln()
      ..writeln('## Motif Coverage');
    for (final entry in _sortedEnumCounts(motifCoverage)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }
    buffer
      ..writeln()
      ..writeln('## Behavior Coverage');
    for (final entry in _sortedEnumCounts(behaviorCoverage)) {
      buffer.writeln('- ${entry.key.wire}: ${entry.value}');
    }
    buffer
      ..writeln()
      ..writeln('## Case Results');
    for (final result in caseResults) {
      final outcome = result.passed ? 'pass' : 'fail';
      buffer.writeln(
        '- ${result.caseId}: $outcome, candidates=${result.candidateCount}, '
        'selected=${result.selectedDeepCount}, warnings='
        '${result.warnings.length}, failures=${result.failures.length}',
      );
    }
    if (warnings.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Warnings');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
    if (failures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Failures');
      for (final failure in failures) {
        buffer.writeln('- $failure');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Next Recommendation')
      ..writeln(
        failedCount == 0
            ? 'Use this suite as the durable quality-memory gate before '
                  'future analysis-intelligence changes.'
            : 'Fix failed golden expectations before tuning downstream '
                  'analysis behavior.',
      );
    return buffer.toString();
  }
}

class GoldenAnalysisSuiteRunner {
  const GoldenAnalysisSuiteRunner({this.policy = const DeepGatingPolicy()});

  final DeepGatingPolicy policy;

  GoldenAnalysisSuiteResult run(GoldenAnalysisSuiteRequest request) {
    if (request.cases.isEmpty) {
      return const GoldenAnalysisSuiteResult(
        status: GoldenAnalysisSuiteStatus.empty,
        caseCount: 0,
        passedCount: 0,
        warningCount: 0,
        failedCount: 0,
        skippedCount: 0,
        categoriesCovered: <GoldenAnalysisCategory>{},
        motifCoverage: <GoldenMotifTag, int>{},
        behaviorCoverage: <GoldenExpectedBehaviorCode, int>{},
        budgetPressureCases: 0,
        invalidSafetyCases: 0,
        casesRequiringFutureRealEngineProof: 0,
        caseResults: <GoldenAnalysisCaseResult>[],
        warnings: <String>[],
        failures: <String>[],
      );
    }

    final duplicateIds = _duplicateIds(request.cases);
    final caseResults = <GoldenAnalysisCaseResult>[];
    final globalWarnings = <String>[];
    final globalFailures = <String>[];

    for (final duplicate in duplicateIds) {
      globalFailures.add('duplicate golden case id: $duplicate');
    }

    for (final item in request.cases) {
      final result = _runCase(
        item,
        mode: request.mode,
        profile: request.profile,
        lowPower: request.lowPower,
        duplicateIds: duplicateIds,
      );
      caseResults.add(result);
      globalWarnings.addAll(
        result.warnings.map((warning) => '${item.id}: $warning'),
      );
      globalFailures.addAll(
        result.failures.map((failure) => '${item.id}: $failure'),
      );
    }

    final failedCount = caseResults.where((result) => !result.passed).length;
    final warningCount = globalWarnings.length;
    final status = failedCount > 0
        ? GoldenAnalysisSuiteStatus.failed
        : warningCount > 0
        ? GoldenAnalysisSuiteStatus.passedWithWarnings
        : GoldenAnalysisSuiteStatus.passed;

    return GoldenAnalysisSuiteResult(
      status: status,
      caseCount: request.cases.length,
      passedCount: caseResults.where((result) => result.passed).length,
      warningCount: warningCount,
      failedCount: failedCount,
      skippedCount: caseResults.where((result) => result.skipped).length,
      categoriesCovered: {for (final item in request.cases) item.category},
      motifCoverage: _motifCoverage(request.cases),
      behaviorCoverage: _behaviorCoverage(request.cases),
      budgetPressureCases: request.cases
          .where(
            (item) =>
                item.category == GoldenAnalysisCategory.budgetPressure ||
                item.motifTags.contains(GoldenMotifTag.budgetPressure),
          )
          .length,
      invalidSafetyCases: request.cases
          .where(
            (item) => item.category == GoldenAnalysisCategory.invalidSafety,
          )
          .length,
      casesRequiringFutureRealEngineProof: caseResults
          .where((result) => result.requiresFutureRealEngineProof)
          .length,
      caseResults: List<GoldenAnalysisCaseResult>.unmodifiable(caseResults),
      warnings: List<String>.unmodifiable(globalWarnings),
      failures: List<String>.unmodifiable(globalFailures),
    );
  }

  GoldenAnalysisCaseResult _runCase(
    GoldenAnalysisCase item, {
    required GoldenAnalysisSuiteMode mode,
    required LocalSchedulerProfile profile,
    required bool lowPower,
    required Set<String> duplicateIds,
  }) {
    final warnings = <String>[];
    final failures = <String>[];

    _validateMetadata(item, duplicateIds, failures);

    DeepGatingPlan? plan;
    if (mode != GoldenAnalysisSuiteMode.metadataOnly &&
        failures.isEmpty &&
        item.inputs.isNotEmpty) {
      final evidence = mode == GoldenAnalysisSuiteMode.fakeEvidence
          ? _fastResultsFor(item)
          : const <GameLevelFastPassResult>[];
      plan = policy.plan(
        DeepGatingPolicyRequest(
          positions: item.inputs,
          profile: profile,
          fastPassResults: evidence,
          maxDeepCandidates: item.expected.maxDeepCandidates,
          maxDeepEngineCalls: item.expected.maxDeepEngineCalls,
          maxTotalEngineCalls: item.expected.maxTotalEngineCalls,
          maxTotalElapsedBudgetMs: item.expected.maxTotalElapsedBudgetMs,
          lowPower: lowPower,
        ),
      );
      warnings.addAll(plan.warnings);
      _validatePlanExpectations(item, plan, mode, profile, warnings, failures);
    }

    final reasonCounts = plan == null
        ? const <DeepCandidateReasonCode, int>{}
        : _reasonCounts(plan.candidates);
    final suppressionCounts = plan == null
        ? const <DeepCandidateReasonCode, int>{}
        : _suppressionCounts(plan.suppressions);
    final requiresReal =
        item.expected.evidence.pvShouldBeNonEmpty ||
        item.expected.evidence.tactical.requiresRealDeviceProof ||
        const GoldenMotifEvidencePolicy().requiresFutureRealDeviceProof(
          item.motifTags,
        );

    if (requiresReal && mode != GoldenAnalysisSuiteMode.metadataOnly) {
      warnings.add('PV evidence expectation requires future real-engine proof');
    }

    return GoldenAnalysisCaseResult(
      caseId: item.id,
      mode: mode,
      passed: failures.isEmpty,
      skipped: mode == GoldenAnalysisSuiteMode.metadataOnly,
      candidateCount: plan?.candidates.length ?? 0,
      selectedDeepCount: plan?.selectedCandidates.length ?? 0,
      reasonCounts: reasonCounts,
      suppressionCounts: suppressionCounts,
      warnings: List<String>.unmodifiable(warnings),
      failures: List<String>.unmodifiable(failures),
      requiresFutureRealEngineProof: requiresReal,
    );
  }

  static List<GameLevelFastPassResult> _fastResultsFor(
    GoldenAnalysisCase item,
  ) {
    return item.fakeEvidence
        .where((evidence) => evidence.positionIndex < item.inputs.length)
        .map(
          (evidence) => GameLevelFastPassResult.fromProvided(
            input: item.inputs[evidence.positionIndex],
            evidence: evidence,
          ),
        )
        .toList(growable: false);
  }

  static void _validateMetadata(
    GoldenAnalysisCase item,
    Set<String> duplicateIds,
    List<String> failures,
  ) {
    if (duplicateIds.contains(item.id)) {
      failures.add('case id is duplicated');
    }
    if (item.id.trim().isEmpty) {
      failures.add('case id is empty');
    }
    if (item.title.trim().isEmpty) {
      failures.add('case title is empty');
    }
    if (!item.hasSource) {
      failures.add('case source is missing');
    }
    if (item.inputs.isEmpty) {
      failures.add('case has no scheduler-ready input');
    }
    if (item.motifTags.isEmpty &&
        item.category != GoldenAnalysisCategory.invalidSafety) {
      failures.add('case has no motif tag');
    }
    if (!item.safety.explicitlySafe || !item.safety.noFinalLabel) {
      failures.add('case is not explicitly marked safe');
    }
    if (item.containsBlockedClaim) {
      failures.add('case contains blocked product claim or official metric');
    }
    if (item.category == GoldenAnalysisCategory.invalidSafety &&
        !item.expected.expects(
          GoldenExpectedBehaviorCode.shouldRejectInvalidFen,
        )) {
      failures.add('invalid safety case must expect rejection');
    }
    if (item.category == GoldenAnalysisCategory.openingKnownSkip &&
        !item.expected.expects(GoldenExpectedBehaviorCode.shouldSkipOpening)) {
      failures.add('opening skip case must expect opening suppression');
    }
    if (item.category == GoldenAnalysisCategory.forcedMoveSkip &&
        !item.expected.expects(GoldenExpectedBehaviorCode.shouldSkipForced)) {
      failures.add('forced skip case must expect forced suppression');
    }
  }

  static void _validatePlanExpectations(
    GoldenAnalysisCase item,
    DeepGatingPlan plan,
    GoldenAnalysisSuiteMode mode,
    LocalSchedulerProfile profile,
    List<String> warnings,
    List<String> failures,
  ) {
    final expected = item.expected;
    final suppressionReasons = plan.suppressions
        .map((suppression) => suppression.reasonCode)
        .toSet();
    final candidateReasons = plan.candidates
        .expand((candidate) => candidate.reasonCodes)
        .toSet();
    final selectedDeepRatio = item.inputs.isEmpty
        ? 0.0
        : plan.selectedCandidates.length / item.inputs.length;

    if (expected.expects(GoldenExpectedBehaviorCode.shouldRejectInvalidFen) &&
        !suppressionReasons.contains(
          DeepCandidateReasonCode.invalidFenSuppressed,
        )) {
      failures.add('invalid position was not rejected before deep gating');
    }
    if (expected.expects(GoldenExpectedBehaviorCode.shouldSkipOpening) &&
        !suppressionReasons.contains(
          DeepCandidateReasonCode.openingSuppressed,
        )) {
      failures.add('opening-known position was not suppressed');
    }
    if (expected.expects(GoldenExpectedBehaviorCode.shouldSkipForced) &&
        !suppressionReasons.contains(
          DeepCandidateReasonCode.forcedSuppressed,
        )) {
      failures.add('forced position was not suppressed');
    }
    if (expected.expects(
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
        ) &&
        plan.candidates.isEmpty) {
      failures.add('deep candidate was expected but none was generated');
    }
    if (expected.expects(
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
        ) &&
        profile.id == LocalSchedulerProfileId.balanced &&
        plan.selectedCandidates.isEmpty) {
      failures.add('balanced profile did not select expected deep candidate');
    }
    if (expected.expects(
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderPerformance,
        ) &&
        profile.id == LocalSchedulerProfileId.performance &&
        plan.selectedCandidates.isEmpty) {
      failures.add(
        'performance profile did not select expected deep candidate',
      );
    }
    if (expected.expects(
          GoldenExpectedBehaviorCode.shouldNotSelectDeepForQuietOpening,
        ) &&
        plan.selectedCandidates.isNotEmpty) {
      failures.add('quiet/opening case selected unexpected deep work');
    }
    if (expected.expects(GoldenExpectedBehaviorCode.shouldUseMultiPvAtLeast2)) {
      final maxMultiPv = plan.selectedCandidates
          .map((candidate) => candidate.proposedMultiPv)
          .fold<int>(0, (current, value) => current > value ? current : value);
      if (maxMultiPv < 2) {
        failures.add('selected candidate did not request MultiPV >= 2');
      }
    }
    if (expected.expects(
          GoldenExpectedBehaviorCode.shouldReportBudgetPressure,
        ) &&
        !suppressionReasons.contains(
          DeepCandidateReasonCode.budgetSuppressed,
        )) {
      failures.add('budget pressure was expected but not surfaced');
    }
    if (expected.expects(
          GoldenExpectedBehaviorCode.shouldSurfaceEvidenceWarning,
        ) &&
        plan.warnings.isEmpty) {
      failures.add('evidence warning was expected but none was surfaced');
    }
    if (expected.maxSelectedDeepRatio != null &&
        selectedDeepRatio > expected.maxSelectedDeepRatio!) {
      failures.add(
        'selected-deep ratio ${_formatRatio(selectedDeepRatio)} exceeded '
        'guardrail ${_formatRatio(expected.maxSelectedDeepRatio!)}',
      );
    }
    if (expected.maxDeepCandidates != null &&
        plan.selectedCandidates.length > expected.maxDeepCandidates!) {
      failures.add('selected deep count exceeded case cap');
    }
    if (expected.maxDeepEngineCalls != null) {
      final selectedCost = _selectedCost(plan);
      if (selectedCost > expected.maxDeepEngineCalls!) {
        failures.add('selected deep engine-call estimate exceeded cap');
      }
    }
    if (expected.maxTotalEngineCalls != null) {
      final selectedCost = _selectedCost(plan);
      if (selectedCost > expected.maxTotalEngineCalls!) {
        failures.add('selected total engine-call estimate exceeded cap');
      }
    }

    if (mode == GoldenAnalysisSuiteMode.fakeEvidence) {
      for (final reason in expected.evidence.expectedReasonCodes) {
        if (!candidateReasons.contains(reason)) {
          failures.add('expected reason code missing: ${reason.wire}');
        }
      }
    }
    for (final reason in expected.evidence.expectedSuppressionReasons) {
      if (!suppressionReasons.contains(reason)) {
        failures.add('expected suppression missing: ${reason.wire}');
      }
    }
    if (mode == GoldenAnalysisSuiteMode.fakeEvidence &&
        expected.evidence.mateScoreExpected &&
        !candidateReasons.contains(DeepCandidateReasonCode.mateScoreDetected)) {
      failures.add('mate-score evidence was expected but absent');
    }
    final minMultiPv = expected.evidence.minMultiPvIfSelected;
    if (minMultiPv != null && plan.selectedCandidates.isNotEmpty) {
      final maxMultiPv = plan.selectedCandidates
          .map((candidate) => candidate.proposedMultiPv)
          .fold<int>(0, (current, value) => current > value ? current : value);
      if (maxMultiPv < minMultiPv) {
        failures.add('selected candidate MultiPV below expectation');
      }
    }
    if (expected.evidence.pvShouldBeNonEmpty) {
      warnings.add('PV content is reserved for opt-in real-engine proof');
    }
  }
}

class GoldenAnalysisCases {
  const GoldenAnalysisCases._();

  static const defaults = <GoldenAnalysisCase>[
    GoldenAnalysisCase(
      id: 'quiet-opening-skip',
      title: 'Quiet opening development skip',
      category: GoldenAnalysisCategory.openingKnownSkip,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _startFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _startFen,
          moveNumber: 1,
          plyIndex: 0,
          isOpeningKnown: true,
        ),
      ],
      motifTags: [GoldenMotifTag.openingTheory, GoldenMotifTag.quietMove],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldSkipOpening,
          GoldenExpectedBehaviorCode.shouldNotSelectDeepForQuietOpening,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          expectedSuppressionReasons: {
            DeepCandidateReasonCode.openingSuppressed,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresSuppressionReason: true,
            suppressionReasons: {DeepCandidateReasonCode.openingSuppressed},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'invalid-fen-safety',
      title: 'Malformed position safety gate',
      category: GoldenAnalysisCategory.invalidSafety,
      sourceType: GoldenAnalysisSourceType.syntheticSafetyCase,
      fen: 'bad fen',
      inputs: [
        LocalAnalysisPositionInput(
          fen: 'bad fen',
          materialDeltaAfterMoveCp: 900,
        ),
      ],
      motifTags: [GoldenMotifTag.invalidSafety],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldRejectInvalidFen,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          expectedSuppressionReasons: {
            DeepCandidateReasonCode.invalidFenSuppressed,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresSuppressionReason: true,
            suppressionReasons: {DeepCandidateReasonCode.invalidFenSuppressed},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'forced-move-skip',
      title: 'Forced move suppression with supplied hint',
      category: GoldenAnalysisCategory.forcedMoveSkip,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 8,
          isOnlyLegalMove: true,
          candidateEvalSpreadCp: 420,
        ),
      ],
      motifTags: [GoldenMotifTag.onlyMove, GoldenMotifTag.forcingLine],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldSkipForced,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          expectedSuppressionReasons: {
            DeepCandidateReasonCode.forcedSuppressed,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresOnlyMoveSignal: true,
            requiresForcingLineSignal: true,
            requiresSuppressionReason: true,
            suppressionReasons: {DeepCandidateReasonCode.forcedSuppressed},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'simple-tactical-capture-check',
      title: 'Simple tactical capture and check signal',
      category: GoldenAnalysisCategory.tacticalShot,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 10,
          legalMoveCount: 32,
          givesCheck: true,
          isCapture: true,
          candidateEvalSpreadCp: 260,
        ),
      ],
      motifTags: [
        GoldenMotifTag.forcingLine,
        GoldenMotifTag.checkSequence,
        GoldenMotifTag.fork,
      ],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldUseMultiPvAtLeast2,
          GoldenExpectedBehaviorCode.shouldStayWithinBalancedBudget,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          candidateSpreadMinCp: 220,
          minMultiPvIfSelected: 2,
          expectedReasonCodes: {
            DeepCandidateReasonCode.tacticalSignal,
            DeepCandidateReasonCode.givesCheck,
            DeepCandidateReasonCode.captureOrPromotion,
            DeepCandidateReasonCode.candidateEvalSpread,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresForcingLineSignal: true,
            requiresCandidateSpread: true,
            requiresMultiPvEvidence: true,
            tacticalReasons: {
              DeepCandidateReasonCode.tacticalSignal,
              DeepCandidateReasonCode.givesCheck,
              DeepCandidateReasonCode.captureOrPromotion,
              DeepCandidateReasonCode.candidateEvalSpread,
            },
            forcingReasons: {
              DeepCandidateReasonCode.tacticalSignal,
              DeepCandidateReasonCode.givesCheck,
              DeepCandidateReasonCode.candidateEvalSpread,
            },
          ),
        ),
        maxDeepCandidates: 1,
        maxDeepEngineCalls: 2,
        maxTotalEngineCalls: 2,
      ),
    ),
    GoldenAnalysisCase(
      id: 'material-sacrifice-compensation',
      title: 'Material sacrifice compensation signal',
      category: GoldenAnalysisCategory.materialSacrifice,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 12,
          materialDeltaAfterMoveCp: -330,
          isCapture: true,
          candidateEvalSpreadCp: 180,
        ),
      ],
      motifTags: [
        GoldenMotifTag.sacrifice,
        GoldenMotifTag.pieceSacrifice,
        GoldenMotifTag.materialCompensation,
        GoldenMotifTag.deflection,
      ],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          materialSwingMinCp: 300,
          expectedReasonCodes: {
            DeepCandidateReasonCode.materialSwing,
            DeepCandidateReasonCode.captureOrPromotion,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresMaterialSwing: true,
            requiresMaterialCompensation: true,
            tacticalReasons: {DeepCandidateReasonCode.captureOrPromotion},
            materialReasons: {
              DeepCandidateReasonCode.materialSwing,
              DeepCandidateReasonCode.captureOrPromotion,
            },
          ),
        ),
      ),
    ),
    GoldenAnalysisCase(
      id: 'mate-threat-fast-evidence',
      title: 'Mate-threat evidence from fast pass',
      category: GoldenAnalysisCategory.forcedMateThreat,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _mateThreatFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _mateThreatFen,
          plyIndex: 18,
          givesCheck: true,
          candidateEvalSpreadCp: 220,
        ),
      ],
      fakeEvidence: [
        GameLevelProvidedFastEvidence(
          positionIndex: 0,
          mateIn: 3,
          bestMoveUci: 'g2g4',
          pvCount: 1,
          elapsedMilliseconds: 80,
        ),
      ],
      motifTags: [
        GoldenMotifTag.mateThreat,
        GoldenMotifTag.exposedKing,
        GoldenMotifTag.matingNet,
        GoldenMotifTag.forcingLine,
        GoldenMotifTag.realDeviceProofNeeded,
      ],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldUseMultiPvAtLeast2,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          mateScoreExpected: true,
          minMultiPvIfSelected: 2,
          pvShouldBeNonEmpty: true,
          expectedReasonCodes: {
            DeepCandidateReasonCode.mateScoreDetected,
            DeepCandidateReasonCode.tacticalSignal,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresMateSignal: true,
            requiresKingSafetySignal: true,
            requiresForcingLineSignal: true,
            requiresPvNonEmpty: true,
            requiresRealDeviceProof: true,
            kingSafetyReasons: {
              DeepCandidateReasonCode.mateScoreDetected,
              DeepCandidateReasonCode.tacticalSignal,
            },
            forcingReasons: {
              DeepCandidateReasonCode.mateScoreDetected,
              DeepCandidateReasonCode.tacticalSignal,
            },
          ),
        ),
      ),
    ),
    GoldenAnalysisCase(
      id: 'quiet-preparatory-uncertain',
      title: 'Quiet preparatory move remains uncertain without evidence',
      category: GoldenAnalysisCategory.quietPreparatoryMove,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _quietFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _quietFen,
          plyIndex: 20,
          legalMoveCount: 24,
        ),
      ],
      motifTags: [
        GoldenMotifTag.quietMove,
        GoldenMotifTag.quietPreparatoryMove,
        GoldenMotifTag.evidenceIncomplete,
      ],
      expected: GoldenExpectedBehavior(
        behaviors: {GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel},
        evidence: GoldenEvidenceExpectation(
          tactical: GoldenTacticalEvidenceExpectation(
            requiresQuietMoveEvidence: true,
            declaredGroups: {
              GoldenMotifEvidenceGroup.positional,
              GoldenMotifEvidenceGroup.uncertainty,
            },
            uncertaintyReasons: {DeepCandidateReasonCode.missingFastPv},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'technical-endgame-conservative',
      title: 'Technical endgame stays conservative without evidence',
      category: GoldenAnalysisCategory.endgamePrecision,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _endgameFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _endgameFen,
          plyIndex: 44,
          legalMoveCount: 10,
        ),
      ],
      motifTags: [
        GoldenMotifTag.endgamePrecision,
        GoldenMotifTag.passedPawn,
        GoldenMotifTag.restriction,
      ],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldStayWithinBalancedBudget,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          tactical: GoldenTacticalEvidenceExpectation(
            declaredGroups: {GoldenMotifEvidenceGroup.positional},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'budget-pressure-candidates',
      title: 'Multiple tactical candidates expose deep budget pressure',
      category: GoldenAnalysisCategory.budgetPressure,
      sourceType: GoldenAnalysisSourceType.syntheticSafetyCase,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 24,
          givesCheck: true,
          isCapture: true,
          candidateEvalSpreadCp: 260,
        ),
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 25,
          materialDeltaAfterMoveCp: -420,
          isCapture: true,
        ),
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 26,
          previousEvalCp: 220,
          provisionalEvalCp: -150,
        ),
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 27,
          legalMoveCount: 38,
          candidateEvalSpreadCp: 240,
        ),
      ],
      motifTags: [GoldenMotifTag.budgetPressure, GoldenMotifTag.forcingLine],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldReportBudgetPressure,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          expectedSuppressionReasons: {
            DeepCandidateReasonCode.budgetSuppressed,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresBudgetPressure: true,
            requiresSuppressionReason: true,
            suppressionReasons: {DeepCandidateReasonCode.budgetSuppressed},
          ),
        ),
        maxDeepCandidates: 2,
        maxDeepEngineCalls: 4,
        maxTotalEngineCalls: 4,
        maxSelectedDeepRatio: 0.5,
      ),
    ),
    GoldenAnalysisCase(
      id: 'queen-win-major-swing',
      title: 'Queen win major material swing',
      category: GoldenAnalysisCategory.queenTrap,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 30,
          materialDeltaAfterMoveCp: 900,
          previousEvalCp: -80,
          provisionalEvalCp: 540,
          isCapture: true,
        ),
      ],
      motifTags: [
        GoldenMotifTag.queenWin,
        GoldenMotifTag.overload,
        GoldenMotifTag.fork,
      ],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldUseMultiPvAtLeast2,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          evalSwingMinCp: 300,
          materialSwingMinCp: 300,
          minMultiPvIfSelected: 2,
          expectedReasonCodes: {
            DeepCandidateReasonCode.materialSwing,
            DeepCandidateReasonCode.majorEvalSwing,
            DeepCandidateReasonCode.captureOrPromotion,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresMaterialSwing: true,
            requiresMultiPvEvidence: true,
            tacticalReasons: {DeepCandidateReasonCode.captureOrPromotion},
            materialReasons: {
              DeepCandidateReasonCode.materialSwing,
              DeepCandidateReasonCode.majorEvalSwing,
              DeepCandidateReasonCode.captureOrPromotion,
            },
          ),
        ),
      ),
    ),
    GoldenAnalysisCase(
      id: 'king-safety-mating-net-hard-case',
      title: 'King safety mating-net pressure',
      category: GoldenAnalysisCategory.forcedMateThreat,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _mateThreatFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _mateThreatFen,
          plyIndex: 34,
          legalMoveCount: 28,
          givesCheck: true,
          candidateEvalSpreadCp: 240,
        ),
      ],
      motifTags: [
        GoldenMotifTag.exposedKing,
        GoldenMotifTag.matingNet,
        GoldenMotifTag.kingHunt,
        GoldenMotifTag.mateThreat,
        GoldenMotifTag.forcingLine,
      ],
      notes: ['handcrafted license-safe Phase 30W regression input'],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          candidateSpreadMinCp: 220,
          expectedReasonCodes: {
            DeepCandidateReasonCode.tacticalSignal,
            DeepCandidateReasonCode.givesCheck,
            DeepCandidateReasonCode.candidateEvalSpread,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresKingSafetySignal: true,
            requiresForcingLineSignal: true,
            requiresCandidateSpread: true,
            kingSafetyReasons: {
              DeepCandidateReasonCode.tacticalSignal,
              DeepCandidateReasonCode.givesCheck,
            },
            forcingReasons: {
              DeepCandidateReasonCode.tacticalSignal,
              DeepCandidateReasonCode.givesCheck,
              DeepCandidateReasonCode.candidateEvalSpread,
            },
          ),
        ),
        maxDeepCandidates: 1,
        maxDeepEngineCalls: 2,
        maxTotalEngineCalls: 2,
      ),
    ),
    GoldenAnalysisCase(
      id: 'quiet-preparatory-hard-case',
      title: 'Quiet preparatory evidence gap',
      category: GoldenAnalysisCategory.quietPreparatoryMove,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _quietFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _quietFen,
          plyIndex: 36,
          legalMoveCount: 22,
        ),
      ],
      motifTags: [
        GoldenMotifTag.quietPreparatoryMove,
        GoldenMotifTag.quietMove,
        GoldenMotifTag.evidenceIncomplete,
      ],
      notes: ['handcrafted license-safe Phase 30W regression input'],
      expected: GoldenExpectedBehavior(
        behaviors: {GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel},
        evidence: GoldenEvidenceExpectation(
          tactical: GoldenTacticalEvidenceExpectation(
            requiresQuietMoveEvidence: true,
            declaredGroups: {
              GoldenMotifEvidenceGroup.positional,
              GoldenMotifEvidenceGroup.uncertainty,
            },
            uncertaintyReasons: {DeepCandidateReasonCode.missingFastPv},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'sacrifice-compensation-hard-case',
      title: 'Sacrifice compensation variation',
      category: GoldenAnalysisCategory.materialSacrifice,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 38,
          materialDeltaAfterMoveCp: -420,
          isCapture: true,
          candidateEvalSpreadCp: 230,
        ),
      ],
      motifTags: [
        GoldenMotifTag.sacrifice,
        GoldenMotifTag.exchangeSacrifice,
        GoldenMotifTag.materialCompensation,
        GoldenMotifTag.forcingLine,
      ],
      notes: ['handcrafted license-safe Phase 30W regression input'],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          candidateSpreadMinCp: 220,
          materialSwingMinCp: 300,
          expectedReasonCodes: {
            DeepCandidateReasonCode.materialSwing,
            DeepCandidateReasonCode.captureOrPromotion,
            DeepCandidateReasonCode.candidateEvalSpread,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresMaterialSwing: true,
            requiresMaterialCompensation: true,
            requiresForcingLineSignal: true,
            requiresCandidateSpread: true,
            tacticalReasons: {
              DeepCandidateReasonCode.captureOrPromotion,
              DeepCandidateReasonCode.candidateEvalSpread,
            },
            materialReasons: {
              DeepCandidateReasonCode.materialSwing,
              DeepCandidateReasonCode.captureOrPromotion,
            },
            forcingReasons: {DeepCandidateReasonCode.candidateEvalSpread},
          ),
        ),
        maxDeepCandidates: 1,
        maxDeepEngineCalls: 2,
        maxTotalEngineCalls: 2,
      ),
    ),
    GoldenAnalysisCase(
      id: 'endgame-precision-hard-case',
      title: 'Endgame precision conservative row',
      category: GoldenAnalysisCategory.endgamePrecision,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _endgameFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _endgameFen,
          plyIndex: 58,
          legalMoveCount: 8,
        ),
      ],
      motifTags: [
        GoldenMotifTag.endgamePrecision,
        GoldenMotifTag.passedPawn,
        GoldenMotifTag.prophylaxis,
      ],
      notes: ['handcrafted license-safe Phase 30W regression input'],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldStayWithinBalancedBudget,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          tactical: GoldenTacticalEvidenceExpectation(
            declaredGroups: {GoldenMotifEvidenceGroup.positional},
          ),
        ),
        maxSelectedDeepRatio: 0,
      ),
    ),
    GoldenAnalysisCase(
      id: 'forcing-line-variation-hard-case',
      title: 'Forcing-line tactical variation',
      category: GoldenAnalysisCategory.tacticalShot,
      sourceType: GoldenAnalysisSourceType.fenPosition,
      fen: _tacticalFen,
      inputs: [
        LocalAnalysisPositionInput(
          fen: _tacticalFen,
          plyIndex: 40,
          legalMoveCount: 34,
          givesCheck: true,
          isCapture: true,
          candidateEvalSpreadCp: 250,
        ),
      ],
      motifTags: [
        GoldenMotifTag.forcingLine,
        GoldenMotifTag.checkSequence,
        GoldenMotifTag.zwischenzug,
        GoldenMotifTag.deflection,
        GoldenMotifTag.removeDefender,
      ],
      notes: ['handcrafted license-safe Phase 30W regression input'],
      expected: GoldenExpectedBehavior(
        behaviors: {
          GoldenExpectedBehaviorCode.shouldGenerateDeepCandidate,
          GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
          GoldenExpectedBehaviorCode.shouldNotEmitFinalLabel,
        },
        evidence: GoldenEvidenceExpectation(
          candidateSpreadMinCp: 220,
          expectedReasonCodes: {
            DeepCandidateReasonCode.tacticalSignal,
            DeepCandidateReasonCode.givesCheck,
            DeepCandidateReasonCode.captureOrPromotion,
            DeepCandidateReasonCode.candidateEvalSpread,
          },
          tactical: GoldenTacticalEvidenceExpectation(
            requiresForcingLineSignal: true,
            requiresCandidateSpread: true,
            tacticalReasons: {
              DeepCandidateReasonCode.tacticalSignal,
              DeepCandidateReasonCode.givesCheck,
              DeepCandidateReasonCode.captureOrPromotion,
              DeepCandidateReasonCode.candidateEvalSpread,
            },
            forcingReasons: {
              DeepCandidateReasonCode.tacticalSignal,
              DeepCandidateReasonCode.givesCheck,
              DeepCandidateReasonCode.candidateEvalSpread,
            },
          ),
        ),
        maxDeepCandidates: 1,
        maxDeepEngineCalls: 2,
        maxTotalEngineCalls: 2,
      ),
    ),
  ];
}

const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _tacticalFen =
    'rn1qkbnr/ppp2ppp/3b4/3pp3/4P3/2NP1N2/PPP2PPP/R1BQKB1R w KQkq - 2 5';
const _quietFen =
    'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/2N2N2/PPPP1PPP/R1BQKB1R w KQkq - 2 3';
const _mateThreatFen = '6k1/5ppp/8/8/8/8/5PPP/6K1 w - - 0 1';
const _endgameFen = '8/8/8/2k5/8/8/4K3/8 w - - 0 1';

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

bool _containsBlockedTerm(String value) {
  final lower = value.toLowerCase();
  final blocked = <String>[
    'brill'
        'iant',
    'gr'
        'eat',
    'mi'
        'ss',
    'ac'
        'pl',
    'accur'
        'acy',
  ];
  return blocked.any(lower.contains);
}

Set<String> _duplicateIds(List<GoldenAnalysisCase> cases) {
  final seen = <String>{};
  final duplicates = <String>{};
  for (final item in cases) {
    if (!seen.add(item.id)) {
      duplicates.add(item.id);
    }
  }
  return duplicates;
}

Map<GoldenMotifTag, int> _motifCoverage(List<GoldenAnalysisCase> cases) {
  final counts = <GoldenMotifTag, int>{};
  for (final item in cases) {
    for (final motif in item.motifTags) {
      counts[motif] = (counts[motif] ?? 0) + 1;
    }
  }
  return Map<GoldenMotifTag, int>.unmodifiable(counts);
}

Map<GoldenExpectedBehaviorCode, int> _behaviorCoverage(
  List<GoldenAnalysisCase> cases,
) {
  final counts = <GoldenExpectedBehaviorCode, int>{};
  for (final item in cases) {
    for (final behavior in item.expected.behaviors) {
      counts[behavior] = (counts[behavior] ?? 0) + 1;
    }
  }
  return Map<GoldenExpectedBehaviorCode, int>.unmodifiable(counts);
}

Map<DeepCandidateReasonCode, int> _reasonCounts(
  List<DeepReanalysisCandidate> candidates,
) {
  final counts = <DeepCandidateReasonCode, int>{};
  for (final candidate in candidates) {
    for (final reason in candidate.reasonCodes) {
      counts[reason] = (counts[reason] ?? 0) + 1;
    }
  }
  return Map<DeepCandidateReasonCode, int>.unmodifiable(counts);
}

Map<DeepCandidateReasonCode, int> _suppressionCounts(
  List<DeepCandidateSuppression> suppressions,
) {
  final counts = <DeepCandidateReasonCode, int>{};
  for (final suppression in suppressions) {
    counts[suppression.reasonCode] = (counts[suppression.reasonCode] ?? 0) + 1;
  }
  return Map<DeepCandidateReasonCode, int>.unmodifiable(counts);
}

int _selectedCost(DeepGatingPlan plan) {
  return plan.selectedCandidates.fold<int>(
    0,
    (total, candidate) => total + candidate.budgetCostEstimate,
  );
}

String _formatRatio(double value) => value.toStringAsFixed(2);

List<MapEntry<T, int>> _sortedEnumCounts<T extends Enum>(Map<T, int> counts) {
  return counts.entries.toList()
    ..sort((a, b) => a.key.name.compareTo(b.key.name));
}
