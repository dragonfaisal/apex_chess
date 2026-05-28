/// Pure local analysis scheduler for deciding how aggressively Stockfish
/// should search one review position.
library;

import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';

enum LocalSchedulerProfileId {
  eco('eco'),
  balanced('balanced'),
  performance('performance'),
  owner('owner');

  const LocalSchedulerProfileId(this.wire);

  final String wire;
}

class LocalSchedulerProfile {
  const LocalSchedulerProfile({
    required this.id,
    required this.label,
    required this.fastMovetime,
    required this.deepMovetime,
    required this.fastDepth,
    required this.deepDepth,
    required this.maxDepth,
    required this.maxMultiPv,
    required this.allowDeepReanalysis,
    required this.maxCriticalReanalysisCount,
    required this.thermalSafeMode,
  }) : assert(fastDepth > 0),
       assert(deepDepth > 0),
       assert(maxDepth > 0),
       assert(maxMultiPv >= 1),
       assert(maxCriticalReanalysisCount >= 0);

  final LocalSchedulerProfileId id;
  final String label;
  final Duration fastMovetime;
  final Duration deepMovetime;
  final int fastDepth;
  final int deepDepth;
  final int maxDepth;
  final int maxMultiPv;
  final bool allowDeepReanalysis;
  final int maxCriticalReanalysisCount;
  final bool thermalSafeMode;

  static const eco = LocalSchedulerProfile(
    id: LocalSchedulerProfileId.eco,
    label: 'Eco',
    fastMovetime: Duration(milliseconds: 50),
    deepMovetime: Duration(milliseconds: 100),
    fastDepth: 8,
    deepDepth: 10,
    maxDepth: 10,
    maxMultiPv: 1,
    allowDeepReanalysis: false,
    maxCriticalReanalysisCount: 0,
    thermalSafeMode: true,
  );

  static const balanced = LocalSchedulerProfile(
    id: LocalSchedulerProfileId.balanced,
    label: 'Balanced',
    fastMovetime: Duration(milliseconds: 100),
    deepMovetime: Duration(milliseconds: 500),
    fastDepth: 12,
    deepDepth: 16,
    maxDepth: 16,
    maxMultiPv: 3,
    allowDeepReanalysis: true,
    maxCriticalReanalysisCount: 8,
    thermalSafeMode: false,
  );

  static const performance = LocalSchedulerProfile(
    id: LocalSchedulerProfileId.performance,
    label: 'Performance',
    fastMovetime: Duration(milliseconds: 150),
    deepMovetime: Duration(milliseconds: 900),
    fastDepth: 14,
    deepDepth: 18,
    maxDepth: 18,
    maxMultiPv: 3,
    allowDeepReanalysis: true,
    maxCriticalReanalysisCount: 12,
    thermalSafeMode: false,
  );

  static const owner = LocalSchedulerProfile(
    id: LocalSchedulerProfileId.owner,
    label: 'Owner',
    fastMovetime: Duration(milliseconds: 250),
    deepMovetime: Duration(milliseconds: 1500),
    fastDepth: 16,
    deepDepth: 20,
    maxDepth: 20,
    maxMultiPv: 3,
    allowDeepReanalysis: true,
    maxCriticalReanalysisCount: 16,
    thermalSafeMode: false,
  );

  static const values = <LocalSchedulerProfile>[
    eco,
    balanced,
    performance,
    owner,
  ];

  static LocalSchedulerProfile byId(LocalSchedulerProfileId id) =>
      values.firstWhere((profile) => profile.id == id);

  LocalSchedulerProfile lowPowerVariant() {
    return LocalSchedulerProfile(
      id: id,
      label: '$label Low Power',
      fastMovetime: _minDuration(
        fastMovetime,
        const Duration(milliseconds: 50),
      ),
      deepMovetime: _minDuration(
        deepMovetime,
        const Duration(milliseconds: 100),
      ),
      fastDepth: _minInt(fastDepth, 8),
      deepDepth: _minInt(deepDepth, 10),
      maxDepth: _minInt(maxDepth, 10),
      maxMultiPv: 1,
      allowDeepReanalysis: false,
      maxCriticalReanalysisCount: 0,
      thermalSafeMode: true,
    );
  }
}

class LocalAnalysisPositionInput {
  const LocalAnalysisPositionInput({
    required this.fen,
    this.moveNumber,
    this.plyIndex,
    this.legalMoveCount,
    this.isOpeningKnown = false,
    this.isOnlyLegalMove = false,
    this.materialDeltaAfterMoveCp,
    this.previousEvalCp,
    this.provisionalEvalCp,
    this.candidateEvalSpreadCp,
    this.hasCheck = false,
    this.givesCheck = false,
    this.isCapture = false,
    this.isPromotion = false,
    this.isCastle = false,
    this.lowPowerMode = false,
    this.tags = const <String>[],
  });

  final String fen;
  final int? moveNumber;
  final int? plyIndex;
  final int? legalMoveCount;
  final bool isOpeningKnown;
  final bool isOnlyLegalMove;

  /// Negative values mean the mover has given up material.
  final int? materialDeltaAfterMoveCp;

  /// Centipawn values supplied by callers in a consistent perspective.
  /// The scheduler only uses absolute swings, not quality labels.
  final int? previousEvalCp;
  final int? provisionalEvalCp;
  final int? candidateEvalSpreadCp;

  final bool hasCheck;
  final bool givesCheck;
  final bool isCapture;
  final bool isPromotion;
  final bool isCastle;
  final bool lowPowerMode;
  final List<String> tags;
}

enum LocalSchedulerDecisionType {
  rejectInvalidFen('rejectInvalidFen'),
  skipOpening('skipOpening'),
  skipForced('skipForced'),
  fastPassOnly('fastPassOnly'),
  fastPassThenMaybeDeep('fastPassThenMaybeDeep'),
  deepReanalysis('deepReanalysis'),
  multipvProbe('multipvProbe'),
  lowPowerFastOnly('lowPowerFastOnly');

  const LocalSchedulerDecisionType(this.wire);

  final String wire;
}

enum LocalSchedulerReasonCode {
  invalidFen('invalidFen'),
  openingKnown('openingKnown'),
  onlyLegalMove('onlyLegalMove'),
  lowPowerMode('lowPowerMode'),
  ecoBudget('ecoBudget'),
  quietPosition('quietPosition'),
  tacticalSignal('tacticalSignal'),
  materialSacrifice('materialSacrifice'),
  largeEvalSpread('largeEvalSpread'),
  majorEvalSwing('majorEvalSwing'),
  highLegalMoveCount('highLegalMoveCount'),
  complexPosition('complexPosition'),
  profileAllowsDeep('profileAllowsDeep'),
  multipvUseful('multipvUseful'),
  cappedByProfile('cappedByProfile');

  const LocalSchedulerReasonCode(this.wire);

  final String wire;
}

enum LocalEngineSearchStepKind {
  fastPass('fastPass'),
  deepReanalysis('deepReanalysis'),
  multipvProbe('multipvProbe');

  const LocalEngineSearchStepKind(this.wire);

  final String wire;
}

class LocalEngineSearchStep {
  const LocalEngineSearchStep({
    required this.kind,
    required this.depth,
    required this.movetime,
    required this.multiPv,
    this.gatedByPriorResult = false,
  }) : assert(depth > 0),
       assert(multiPv >= 1),
       assert(movetime > Duration.zero);

  final LocalEngineSearchStepKind kind;
  final int depth;
  final Duration movetime;
  final int multiPv;

  /// True when this is a reserved follow-up budget, not a mandatory first
  /// search. A later executor can decide whether the fast-pass result earned it.
  final bool gatedByPriorResult;

  String get debugLabel =>
      '${kind.wire}: depth=$depth movetimeMs=${movetime.inMilliseconds} '
      'multipv=$multiPv gated=$gatedByPriorResult';
}

class LocalSchedulerSafetyBudget {
  const LocalSchedulerSafetyBudget({
    required this.maxDepth,
    required this.maxMovetime,
    required this.maxMultiPv,
    required this.maxCriticalReanalysisCount,
    required this.thermalSafeMode,
  }) : assert(maxDepth > 0),
       assert(maxMovetime > Duration.zero),
       assert(maxMultiPv >= 1),
       assert(maxCriticalReanalysisCount >= 0);

  final int maxDepth;
  final Duration maxMovetime;
  final int maxMultiPv;
  final int maxCriticalReanalysisCount;
  final bool thermalSafeMode;

  factory LocalSchedulerSafetyBudget.fromProfile(
    LocalSchedulerProfile profile,
  ) {
    return LocalSchedulerSafetyBudget(
      maxDepth: profile.maxDepth,
      maxMovetime: profile.deepMovetime,
      maxMultiPv: profile.maxMultiPv,
      maxCriticalReanalysisCount: profile.maxCriticalReanalysisCount,
      thermalSafeMode: profile.thermalSafeMode,
    );
  }

  bool allows(LocalEngineSearchStep step) {
    return step.depth <= maxDepth &&
        step.movetime.inMilliseconds <= maxMovetime.inMilliseconds &&
        step.multiPv <= maxMultiPv;
  }
}

class LocalSchedulerDecision {
  const LocalSchedulerDecision({
    required this.type,
    required this.reasons,
    required this.engineRequired,
    required this.safetyBudget,
    required this.steps,
    required this.developerNote,
  }) : assert(engineRequired || steps.length == 0),
       assert(!engineRequired || steps.length > 0);

  final LocalSchedulerDecisionType type;
  final List<LocalSchedulerReasonCode> reasons;
  final bool engineRequired;
  final LocalSchedulerSafetyBudget safetyBudget;
  final List<LocalEngineSearchStep> steps;
  final String developerNote;

  LocalEngineSearchStep? get primaryStep => steps.isEmpty ? null : steps.first;

  int? get requestedDepth => primaryStep?.depth;
  Duration? get requestedMovetime => primaryStep?.movetime;
  int? get requestedMultiPv => primaryStep?.multiPv;

  bool get withinSafetyBudget => steps.every(safetyBudget.allows);

  String get debugSummary {
    final reasonText = reasons.map((reason) => reason.wire).join(',');
    final stepText = steps.map((step) => step.debugLabel).join(' | ');
    return '${type.wire} engineRequired=$engineRequired reasons=[$reasonText] '
        'steps=[$stepText] note="$developerNote"';
  }
}

class LocalSmartAnalysisScheduler {
  const LocalSmartAnalysisScheduler({
    this.profile = LocalSchedulerProfile.balanced,
  });

  final LocalSchedulerProfile profile;

  LocalSchedulerDecision plan(LocalAnalysisPositionInput input) {
    final validation = validateFenForEngineCommand(input.fen);
    final effectiveProfile = input.lowPowerMode
        ? profile.lowPowerVariant()
        : profile;
    final safetyBudget = LocalSchedulerSafetyBudget.fromProfile(
      effectiveProfile,
    );

    if (!validation.isValid) {
      return _staticDecision(
        type: LocalSchedulerDecisionType.rejectInvalidFen,
        reasons: const [LocalSchedulerReasonCode.invalidFen],
        safetyBudget: safetyBudget,
        developerNote: 'Rejected before any local engine command.',
      );
    }

    if (input.isOpeningKnown) {
      return _staticDecision(
        type: LocalSchedulerDecisionType.skipOpening,
        reasons: const [LocalSchedulerReasonCode.openingKnown],
        safetyBudget: safetyBudget,
        developerNote: 'Known opening position; no engine search needed.',
      );
    }

    if (input.isOnlyLegalMove) {
      return _staticDecision(
        type: LocalSchedulerDecisionType.skipForced,
        reasons: const [LocalSchedulerReasonCode.onlyLegalMove],
        safetyBudget: safetyBudget,
        developerNote: 'Only one legal move; engine search skipped.',
      );
    }

    if (input.lowPowerMode) {
      final step = _fastStep(effectiveProfile);
      return _engineDecision(
        type: LocalSchedulerDecisionType.lowPowerFastOnly,
        reasons: const [LocalSchedulerReasonCode.lowPowerMode],
        safetyBudget: safetyBudget,
        steps: [step],
        developerNote: 'Low-power mode forces a small single-PV fast pass.',
      );
    }

    if (effectiveProfile.id == LocalSchedulerProfileId.eco) {
      final step = _fastStep(effectiveProfile);
      return _engineDecision(
        type: LocalSchedulerDecisionType.fastPassOnly,
        reasons: const [LocalSchedulerReasonCode.ecoBudget],
        safetyBudget: safetyBudget,
        steps: [step],
        developerNote: 'Eco profile uses the smallest finite search budget.',
      );
    }

    final signals = _PositionSignals.from(input);

    if (signals.critical && effectiveProfile.allowDeepReanalysis) {
      final multiPv = _multiPvFor(
        input: input,
        signals: signals,
        profile: effectiveProfile,
      );
      final step = _deepStep(effectiveProfile, multiPv: multiPv);
      return _engineDecision(
        type: LocalSchedulerDecisionType.deepReanalysis,
        reasons: [
          ...signals.reasonCodes,
          LocalSchedulerReasonCode.profileAllowsDeep,
          if (multiPv > 1) LocalSchedulerReasonCode.multipvUseful,
        ],
        safetyBudget: safetyBudget,
        steps: [step],
        developerNote: 'Critical tactical or eval signal earns deep budget.',
      );
    }

    if (signals.needsMultiPvProbe && effectiveProfile.maxMultiPv >= 2) {
      final multiPv = _multiPvFor(
        input: input,
        signals: signals,
        profile: effectiveProfile,
      );
      final step = _boundedStep(
        kind: LocalEngineSearchStepKind.multipvProbe,
        profile: effectiveProfile,
        depth: effectiveProfile.fastDepth,
        movetime: effectiveProfile.fastMovetime,
        multiPv: multiPv,
      );
      return _engineDecision(
        type: LocalSchedulerDecisionType.multipvProbe,
        reasons: [
          ...signals.reasonCodes,
          LocalSchedulerReasonCode.multipvUseful,
        ],
        safetyBudget: safetyBudget,
        steps: [step],
        developerNote: 'Complex position gets MultiPV without full deep scan.',
      );
    }

    if (signals.suspicious && effectiveProfile.allowDeepReanalysis) {
      final fast = _fastStep(effectiveProfile);
      final deep = _deepStep(
        effectiveProfile,
        multiPv: _multiPvFor(
          input: input,
          signals: signals,
          profile: effectiveProfile,
        ),
        gatedByPriorResult: true,
      );
      return _engineDecision(
        type: LocalSchedulerDecisionType.fastPassThenMaybeDeep,
        reasons: [
          ...signals.reasonCodes,
          LocalSchedulerReasonCode.profileAllowsDeep,
        ],
        safetyBudget: safetyBudget,
        steps: [fast, deep],
        developerNote: 'Fast pass first; deep budget is reserved and gated.',
      );
    }

    return _engineDecision(
      type: LocalSchedulerDecisionType.fastPassOnly,
      reasons: const [LocalSchedulerReasonCode.quietPosition],
      safetyBudget: safetyBudget,
      steps: [_fastStep(effectiveProfile)],
      developerNote: 'Quiet position stays on a single-PV fast pass.',
    );
  }

  static LocalSchedulerDecision _staticDecision({
    required LocalSchedulerDecisionType type,
    required List<LocalSchedulerReasonCode> reasons,
    required LocalSchedulerSafetyBudget safetyBudget,
    required String developerNote,
  }) {
    return LocalSchedulerDecision(
      type: type,
      reasons: List<LocalSchedulerReasonCode>.unmodifiable(reasons),
      engineRequired: false,
      safetyBudget: safetyBudget,
      steps: const <LocalEngineSearchStep>[],
      developerNote: developerNote,
    );
  }

  static LocalSchedulerDecision _engineDecision({
    required LocalSchedulerDecisionType type,
    required List<LocalSchedulerReasonCode> reasons,
    required LocalSchedulerSafetyBudget safetyBudget,
    required List<LocalEngineSearchStep> steps,
    required String developerNote,
  }) {
    return LocalSchedulerDecision(
      type: type,
      reasons: List<LocalSchedulerReasonCode>.unmodifiable(reasons),
      engineRequired: true,
      safetyBudget: safetyBudget,
      steps: List<LocalEngineSearchStep>.unmodifiable(steps),
      developerNote: developerNote,
    );
  }

  static LocalEngineSearchStep _fastStep(LocalSchedulerProfile profile) {
    return _boundedStep(
      kind: LocalEngineSearchStepKind.fastPass,
      profile: profile,
      depth: profile.fastDepth,
      movetime: profile.fastMovetime,
      multiPv: 1,
    );
  }

  static LocalEngineSearchStep _deepStep(
    LocalSchedulerProfile profile, {
    required int multiPv,
    bool gatedByPriorResult = false,
  }) {
    return _boundedStep(
      kind: LocalEngineSearchStepKind.deepReanalysis,
      profile: profile,
      depth: profile.deepDepth,
      movetime: profile.deepMovetime,
      multiPv: multiPv,
      gatedByPriorResult: gatedByPriorResult,
    );
  }

  static LocalEngineSearchStep _boundedStep({
    required LocalEngineSearchStepKind kind,
    required LocalSchedulerProfile profile,
    required int depth,
    required Duration movetime,
    required int multiPv,
    bool gatedByPriorResult = false,
  }) {
    return LocalEngineSearchStep(
      kind: kind,
      depth: _minInt(depth, profile.maxDepth),
      movetime: _minDuration(movetime, profile.deepMovetime),
      multiPv: _clampInt(multiPv, 1, profile.maxMultiPv),
      gatedByPriorResult: gatedByPriorResult,
    );
  }

  static int _multiPvFor({
    required LocalAnalysisPositionInput input,
    required _PositionSignals signals,
    required LocalSchedulerProfile profile,
  }) {
    if (profile.maxMultiPv <= 1) return 1;
    if (signals.critical) return _minInt(3, profile.maxMultiPv);
    if (input.legalMoveCount != null &&
        input.legalMoveCount! >= 35 &&
        (profile.id == LocalSchedulerProfileId.performance ||
            profile.id == LocalSchedulerProfileId.owner)) {
      return _minInt(3, profile.maxMultiPv);
    }
    if (signals.needsMultiPvProbe) return _minInt(2, profile.maxMultiPv);
    return 1;
  }
}

class _PositionSignals {
  const _PositionSignals({
    required this.reasonCodes,
    required this.suspicious,
    required this.critical,
    required this.needsMultiPvProbe,
  });

  final List<LocalSchedulerReasonCode> reasonCodes;
  final bool suspicious;
  final bool critical;
  final bool needsMultiPvProbe;

  factory _PositionSignals.from(LocalAnalysisPositionInput input) {
    final reasons = <LocalSchedulerReasonCode>[];

    final tactical =
        input.hasCheck ||
        input.givesCheck ||
        input.isPromotion ||
        (input.isCapture && (input.legalMoveCount ?? 0) >= 20);
    if (tactical) reasons.add(LocalSchedulerReasonCode.tacticalSignal);

    final materialSacrifice =
        input.materialDeltaAfterMoveCp != null &&
        input.materialDeltaAfterMoveCp! <= -150;
    if (materialSacrifice) {
      reasons.add(LocalSchedulerReasonCode.materialSacrifice);
    }

    final spread = input.candidateEvalSpreadCp?.abs() ?? 0;
    final largeSpread = spread >= 120;
    final criticalSpread = spread >= 200;
    if (largeSpread) reasons.add(LocalSchedulerReasonCode.largeEvalSpread);

    final swing =
        input.previousEvalCp != null && input.provisionalEvalCp != null
        ? (input.previousEvalCp! - input.provisionalEvalCp!).abs()
        : 0;
    final majorSwing = swing >= 200;
    final criticalSwing = swing >= 300;
    if (majorSwing) reasons.add(LocalSchedulerReasonCode.majorEvalSwing);

    final highLegalMoveCount =
        input.legalMoveCount != null && input.legalMoveCount! >= 35;
    if (highLegalMoveCount) {
      reasons.add(LocalSchedulerReasonCode.highLegalMoveCount);
    }

    final complex =
        highLegalMoveCount ||
        largeSpread ||
        (tactical &&
            input.legalMoveCount != null &&
            input.legalMoveCount! >= 16);
    if (complex) reasons.add(LocalSchedulerReasonCode.complexPosition);

    final critical =
        materialSacrifice ||
        criticalSpread ||
        criticalSwing ||
        input.isPromotion;
    final suspicious =
        critical || tactical || largeSpread || majorSwing || highLegalMoveCount;
    final needsMultiPvProbe = complex || largeSpread || highLegalMoveCount;

    return _PositionSignals(
      reasonCodes: List<LocalSchedulerReasonCode>.unmodifiable(reasons),
      suspicious: suspicious,
      critical: critical,
      needsMultiPvProbe: needsMultiPvProbe,
    );
  }
}

int _minInt(int a, int b) => a < b ? a : b;

int _clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

Duration _minDuration(Duration a, Duration b) =>
    a.inMilliseconds <= b.inMilliseconds ? a : b;
