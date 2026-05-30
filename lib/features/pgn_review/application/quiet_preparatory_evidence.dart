/// Pure evidence model for quiet/preparatory golden cases.
library;

enum QuietPreparatoryEvidenceStatus {
  unsupportedQuietMove('unsupportedQuietMove'),
  incompleteQuietEvidence('incompleteQuietEvidence'),
  fakeEvidenceSupported('fakeEvidenceSupported'),
  needsRealDeviceProof('needsRealDeviceProof'),
  quietEvidenceProtected('quietEvidenceProtected'),
  quietEvidenceMismatch('quietEvidenceMismatch');

  const QuietPreparatoryEvidenceStatus(this.wire);

  final String wire;
}

enum QuietPreparatoryEvidenceSupportGroup {
  candidateSpreadFutureThreat('candidateSpreadFutureThreat'),
  threatReduction('threatReduction'),
  kingSafetyOrPositional('kingSafetyOrPositional'),
  forcingLineEnabledNext('forcingLineEnabledNext'),
  pvSupport('pvSupport'),
  multiPvSupport('multiPvSupport'),
  alternativeWeakness('alternativeWeakness'),
  endgamePlan('endgamePlan');

  const QuietPreparatoryEvidenceSupportGroup(this.wire);

  final String wire;
}

class QuietPreparatoryEvidence {
  const QuietPreparatoryEvidence({
    this.candidateSpreadPresent = false,
    this.futureTacticalThreatPrepared = false,
    this.opponentThreatReduced = false,
    this.kingSafetyImproved = false,
    this.pieceActivityImproved = false,
    this.keySquareControlImproved = false,
    this.passedPawnOrEndgamePlanImproved = false,
    this.forcingLineEnabledNext = false,
    this.quietMoveHasPvSupport = false,
    this.quietMoveHasMultiPvSupport = false,
    this.alternativeMovesAreClearlyWorse = false,
    this.noImmediateCaptureCheckPromotion = false,
    this.uncertaintyReason,
    this.requiresRealDeviceProof = false,
    this.contradictionReasons = const <String>[],
  });

  final bool candidateSpreadPresent;
  final bool futureTacticalThreatPrepared;
  final bool opponentThreatReduced;
  final bool kingSafetyImproved;
  final bool pieceActivityImproved;
  final bool keySquareControlImproved;
  final bool passedPawnOrEndgamePlanImproved;
  final bool forcingLineEnabledNext;
  final bool quietMoveHasPvSupport;
  final bool quietMoveHasMultiPvSupport;
  final bool alternativeMovesAreClearlyWorse;
  final bool noImmediateCaptureCheckPromotion;
  final String? uncertaintyReason;
  final bool requiresRealDeviceProof;
  final List<String> contradictionReasons;

  bool get hasAnyEvidence =>
      candidateSpreadPresent ||
      futureTacticalThreatPrepared ||
      opponentThreatReduced ||
      kingSafetyImproved ||
      pieceActivityImproved ||
      keySquareControlImproved ||
      passedPawnOrEndgamePlanImproved ||
      forcingLineEnabledNext ||
      quietMoveHasPvSupport ||
      quietMoveHasMultiPvSupport ||
      alternativeMovesAreClearlyWorse ||
      noImmediateCaptureCheckPromotion ||
      _hasText(uncertaintyReason) ||
      requiresRealDeviceProof ||
      contradictionReasons.isNotEmpty;

  List<String> get searchableText {
    return <String>[
      if (_hasText(uncertaintyReason)) uncertaintyReason!.trim(),
      ...contradictionReasons,
    ];
  }

  List<QuietPreparatoryEvidenceSupportGroup> get supportGroups {
    final groups = <QuietPreparatoryEvidenceSupportGroup>{};
    if (candidateSpreadPresent && futureTacticalThreatPrepared) {
      groups.add(
        QuietPreparatoryEvidenceSupportGroup.candidateSpreadFutureThreat,
      );
    }
    if (opponentThreatReduced &&
        (kingSafetyImproved ||
            pieceActivityImproved ||
            keySquareControlImproved)) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.threatReduction);
    }
    if (kingSafetyImproved ||
        pieceActivityImproved ||
        keySquareControlImproved) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.kingSafetyOrPositional);
    }
    if (forcingLineEnabledNext) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.forcingLineEnabledNext);
    }
    if (quietMoveHasPvSupport) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.pvSupport);
    }
    if (quietMoveHasMultiPvSupport) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.multiPvSupport);
    }
    if (alternativeMovesAreClearlyWorse) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.alternativeWeakness);
    }
    if (passedPawnOrEndgamePlanImproved) {
      groups.add(QuietPreparatoryEvidenceSupportGroup.endgamePlan);
    }
    return groups.toList()..sort((a, b) => a.wire.compareTo(b.wire));
  }
}

class QuietPreparatoryEvidenceAssessment {
  const QuietPreparatoryEvidenceAssessment({
    required this.status,
    required this.supportGroups,
    required this.blockers,
    required this.requiresRealDeviceProof,
  });

  final QuietPreparatoryEvidenceStatus status;
  final List<QuietPreparatoryEvidenceSupportGroup> supportGroups;
  final List<String> blockers;
  final bool requiresRealDeviceProof;

  bool get isProtectedForReview =>
      status == QuietPreparatoryEvidenceStatus.fakeEvidenceSupported ||
      status == QuietPreparatoryEvidenceStatus.quietEvidenceProtected;

  bool get isIncomplete =>
      status == QuietPreparatoryEvidenceStatus.unsupportedQuietMove ||
      status == QuietPreparatoryEvidenceStatus.incompleteQuietEvidence;

  bool get isMismatch =>
      status == QuietPreparatoryEvidenceStatus.quietEvidenceMismatch;
}

class GoldenQuietPreparatoryEvidencePolicy {
  const GoldenQuietPreparatoryEvidencePolicy();

  QuietPreparatoryEvidenceAssessment assess({
    required bool isQuietPreparatory,
    required QuietPreparatoryEvidence evidence,
  }) {
    if (!isQuietPreparatory) {
      return const QuietPreparatoryEvidenceAssessment(
        status: QuietPreparatoryEvidenceStatus.unsupportedQuietMove,
        supportGroups: <QuietPreparatoryEvidenceSupportGroup>[],
        blockers: <String>['not a quiet-preparatory case'],
        requiresRealDeviceProof: false,
      );
    }

    final supportGroups = evidence.supportGroups;
    final blockers = <String>[];

    if (evidence.contradictionReasons.isNotEmpty) {
      blockers.addAll(evidence.contradictionReasons);
      return QuietPreparatoryEvidenceAssessment(
        status: QuietPreparatoryEvidenceStatus.quietEvidenceMismatch,
        supportGroups: supportGroups,
        blockers: List<String>.unmodifiable(blockers..sort()),
        requiresRealDeviceProof: evidence.requiresRealDeviceProof,
      );
    }

    if (evidence.requiresRealDeviceProof) {
      return QuietPreparatoryEvidenceAssessment(
        status: QuietPreparatoryEvidenceStatus.needsRealDeviceProof,
        supportGroups: supportGroups,
        blockers: const <String>['quiet evidence requires PV or MultiPV proof'],
        requiresRealDeviceProof: true,
      );
    }

    if (supportGroups.isEmpty) {
      final reason = _hasText(evidence.uncertaintyReason)
          ? evidence.uncertaintyReason!.trim()
          : 'quiet move has no supporting evidence';
      return QuietPreparatoryEvidenceAssessment(
        status: _hasText(evidence.uncertaintyReason)
            ? QuietPreparatoryEvidenceStatus.incompleteQuietEvidence
            : QuietPreparatoryEvidenceStatus.unsupportedQuietMove,
        supportGroups: const <QuietPreparatoryEvidenceSupportGroup>[],
        blockers: <String>[reason],
        requiresRealDeviceProof: false,
      );
    }

    if (!evidence.noImmediateCaptureCheckPromotion) {
      return QuietPreparatoryEvidenceAssessment(
        status: QuietPreparatoryEvidenceStatus.quietEvidenceMismatch,
        supportGroups: supportGroups,
        blockers: const <String>[
          'quiet evidence must confirm no immediate capture, check, or promotion',
        ],
        requiresRealDeviceProof: false,
      );
    }

    final status = supportGroups.length >= 2
        ? QuietPreparatoryEvidenceStatus.quietEvidenceProtected
        : QuietPreparatoryEvidenceStatus.fakeEvidenceSupported;
    return QuietPreparatoryEvidenceAssessment(
      status: status,
      supportGroups: List<QuietPreparatoryEvidenceSupportGroup>.unmodifiable(
        supportGroups,
      ),
      blockers: const <String>[],
      requiresRealDeviceProof: false,
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
