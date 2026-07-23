/// Versioned, immutable product explanation for one analysed ply.
///
/// Human copy is a rendered snapshot. Facts and claims are the authority;
/// strings are never parsed to recover chess meaning.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:apex_chess/core/domain/services/analysis_versions.dart';

enum MoveInsightState { available, suppressed, unavailable, contradictory }

enum MoveInsightConfidence { verified, supported }

enum MoveInsightClaimType {
  deliversMate,
  createsStalemate,
  allowsForcedMate,
  missesForcedMate,
  preservesForcedMate,
  missesMaterialWin,
  onlyMoveDefense,
  winsMaterial,
  dropsMaterial,
  promotes,
  recaptures,
  bookTransition,
}

enum MoveInsightFactType {
  legalTransition,
  terminalMate,
  scoreTransition,
  coherentEngineLine,
  materialDelta,
  capture,
  promotion,
  legalMoveCount,
  openingTransition,
  changedRelationship,
  forcedResponse,
  materialInvestment,
  alternativeOutcome,
}

enum MoveInsightCausalStage { move, changedFact, condition, response, outcome }

enum MoveInsightMechanismType {
  none,
  fork,
  doubleAttack,
  absolutePin,
  skewer,
  discoveredAttack,
  opensLine,
  removesDefender,
  soundSacrifice,
  unsoundSacrifice,
  onlyMoveDefense,
  missedMaterialResource,
}

enum MoveInsightConsequenceType {
  none,
  checkmate,
  materialGain,
  materialLoss,
  avoidsCheckmate,
  missedMaterialGain,
}

enum MoveInsightRelationType {
  attacks,
  pinsToKing,
  skewers,
  opensLine,
  defends,
  removesDefense,
  investsMaterial,
  alternativeAllowsMate,
  alternativeWinsMaterial,
}

enum MoveInsightLineType { file, rank, diagonal }

/// One machine fact supporting one or more claims.
class MoveInsightFact {
  const MoveInsightFact({
    required this.id,
    required this.type,
    this.pieceRole,
    this.pieceSide,
    this.fromSquare,
    this.toSquare,
    this.intValue,
    this.textValue,
    this.linePly,
    this.relationType,
    this.relatedPieceRole,
    this.relatedPieceSide,
    this.relatedSquare,
    this.secondaryPieceRole,
    this.secondaryPieceSide,
    this.secondarySquare,
    this.lineType,
    this.lineSquares = const <String>[],
  });

  final String id;
  final MoveInsightFactType type;
  final String? pieceRole;
  final String? pieceSide;
  final String? fromSquare;
  final String? toSquare;
  final int? intValue;
  final String? textValue;
  final int? linePly;
  final MoveInsightRelationType? relationType;
  final String? relatedPieceRole;
  final String? relatedPieceSide;
  final String? relatedSquare;
  final String? secondaryPieceRole;
  final String? secondaryPieceSide;
  final String? secondarySquare;
  final MoveInsightLineType? lineType;
  final List<String> lineSquares;

  bool get isStructurallyValid =>
      _idPattern.hasMatch(id) &&
      _validRole(pieceRole) &&
      _validSide(pieceSide) &&
      _validSquare(fromSquare) &&
      _validSquare(toSquare) &&
      _validRole(relatedPieceRole) &&
      _validSide(relatedPieceSide) &&
      _validSquare(relatedSquare) &&
      _validRole(secondaryPieceRole) &&
      _validSide(secondaryPieceSide) &&
      _validSquare(secondarySquare) &&
      lineSquares.length <= 8 &&
      lineSquares.toSet().length == lineSquares.length &&
      lineSquares.every((square) => _validSquare(square)) &&
      (linePly == null || linePly! >= 0) &&
      (textValue == null || textValue!.length <= 120);

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'type': type.name,
    'pieceRole': pieceRole,
    'pieceSide': pieceSide,
    'fromSquare': fromSquare,
    'toSquare': toSquare,
    'intValue': intValue,
    'textValue': textValue,
    'linePly': linePly,
    'relationType': relationType?.name,
    'relatedPieceRole': relatedPieceRole,
    'relatedPieceSide': relatedPieceSide,
    'relatedSquare': relatedSquare,
    'secondaryPieceRole': secondaryPieceRole,
    'secondaryPieceSide': secondaryPieceSide,
    'secondarySquare': secondarySquare,
    'lineType': lineType?.name,
    'lineSquares': lineSquares,
  };

  factory MoveInsightFact.fromJson(Map<dynamic, dynamic> json) {
    _rejectUnexpectedKeys(json, _moveInsightFactKeys, 'move insight fact');
    return MoveInsightFact(
      id: json['id'] as String? ?? '',
      type: _requiredEnum(
        MoveInsightFactType.values,
        json['type'],
        'move insight fact type',
      ),
      pieceRole: json['pieceRole'] as String?,
      pieceSide: json['pieceSide'] as String?,
      fromSquare: json['fromSquare'] as String?,
      toSquare: json['toSquare'] as String?,
      intValue: (json['intValue'] as num?)?.toInt(),
      textValue: json['textValue'] as String?,
      linePly: (json['linePly'] as num?)?.toInt(),
      relationType: _optionalEnum(
        MoveInsightRelationType.values,
        json['relationType'],
        'move insight relation type',
      ),
      relatedPieceRole: json['relatedPieceRole'] as String?,
      relatedPieceSide: json['relatedPieceSide'] as String?,
      relatedSquare: json['relatedSquare'] as String?,
      secondaryPieceRole: json['secondaryPieceRole'] as String?,
      secondaryPieceSide: json['secondaryPieceSide'] as String?,
      secondarySquare: json['secondarySquare'] as String?,
      lineType: _optionalEnum(
        MoveInsightLineType.values,
        json['lineType'],
        'move insight line type',
      ),
      lineSquares: _strictStringList(
        json['lineSquares'],
        'move insight fact line squares',
      ),
    );
  }
}

/// A conservative semantic assertion backed by explicit fact IDs.
class MoveInsightClaim {
  const MoveInsightClaim({
    required this.id,
    required this.type,
    required this.confidence,
    required this.reasonCode,
    required this.supportingFactIds,
    this.pieceRole,
    this.pieceSquare,
    this.targetRole,
    this.targetSquare,
    this.materialDelta,
    this.betterMoveSan,
    this.opponentReplySan,
    this.continuationSan = const <String>[],
    this.continuationUci = const <String>[],
    this.openingEco,
    this.openingName,
    this.mechanism = MoveInsightMechanismType.none,
    this.consequence = MoveInsightConsequenceType.none,
    this.mechanismReasonCode,
    this.initiatorRole,
    this.initiatorSquare,
    this.secondaryTargetRole,
    this.secondaryTargetSquare,
    this.defenderRole,
    this.defenderSquare,
    this.relationType,
    this.lineType,
    this.lineSquares = const <String>[],
  });

  final String id;
  final MoveInsightClaimType type;
  final MoveInsightConfidence confidence;
  final String reasonCode;
  final List<String> supportingFactIds;
  final String? pieceRole;
  final String? pieceSquare;
  final String? targetRole;
  final String? targetSquare;
  final int? materialDelta;
  final String? betterMoveSan;
  final String? opponentReplySan;
  final List<String> continuationSan;
  final List<String> continuationUci;
  final String? openingEco;
  final String? openingName;
  final MoveInsightMechanismType mechanism;
  final MoveInsightConsequenceType consequence;
  final String? mechanismReasonCode;
  final String? initiatorRole;
  final String? initiatorSquare;
  final String? secondaryTargetRole;
  final String? secondaryTargetSquare;
  final String? defenderRole;
  final String? defenderSquare;
  final MoveInsightRelationType? relationType;
  final MoveInsightLineType? lineType;
  final List<String> lineSquares;

  bool get isStructurallyValid =>
      _idPattern.hasMatch(id) &&
      _idPattern.hasMatch(reasonCode) &&
      supportingFactIds.isNotEmpty &&
      supportingFactIds.every(_idPattern.hasMatch) &&
      _validRole(pieceRole) &&
      _validRole(targetRole) &&
      _validRole(initiatorRole) &&
      _validRole(secondaryTargetRole) &&
      _validRole(defenderRole) &&
      _validSquare(pieceSquare) &&
      _validSquare(targetSquare) &&
      _validSquare(initiatorSquare) &&
      _validSquare(secondaryTargetSquare) &&
      _validSquare(defenderSquare) &&
      (mechanismReasonCode == null ||
          _idPattern.hasMatch(mechanismReasonCode!)) &&
      lineSquares.length <= 8 &&
      lineSquares.toSet().length == lineSquares.length &&
      lineSquares.every((square) => _validSquare(square)) &&
      continuationSan.length <= 6 &&
      continuationSan.every(
        (value) => value.trim().isNotEmpty && value.length <= 24,
      ) &&
      continuationUci.length <= 6 &&
      continuationUci.every(
        (value) => RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(value),
      ) &&
      (betterMoveSan == null ||
          (betterMoveSan!.trim().isNotEmpty && betterMoveSan!.length <= 24)) &&
      (opponentReplySan == null ||
          (opponentReplySan!.trim().isNotEmpty &&
              opponentReplySan!.length <= 24)) &&
      (openingEco == null || openingEco!.length <= 8) &&
      (openingName == null || openingName!.length <= 100);

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'type': type.name,
    'confidence': confidence.name,
    'reasonCode': reasonCode,
    'supportingFactIds': supportingFactIds,
    'pieceRole': pieceRole,
    'pieceSquare': pieceSquare,
    'targetRole': targetRole,
    'targetSquare': targetSquare,
    'materialDelta': materialDelta,
    'betterMoveSan': betterMoveSan,
    'opponentReplySan': opponentReplySan,
    'continuationSan': continuationSan,
    'continuationUci': continuationUci,
    'openingEco': openingEco,
    'openingName': openingName,
    'mechanism': mechanism.name,
    'consequence': consequence.name,
    'mechanismReasonCode': mechanismReasonCode,
    'initiatorRole': initiatorRole,
    'initiatorSquare': initiatorSquare,
    'secondaryTargetRole': secondaryTargetRole,
    'secondaryTargetSquare': secondaryTargetSquare,
    'defenderRole': defenderRole,
    'defenderSquare': defenderSquare,
    'relationType': relationType?.name,
    'lineType': lineType?.name,
    'lineSquares': lineSquares,
  };

  factory MoveInsightClaim.fromJson(Map<dynamic, dynamic> json) {
    _rejectUnexpectedKeys(json, _moveInsightClaimKeys, 'move insight claim');
    return MoveInsightClaim(
      id: json['id'] as String? ?? '',
      type: _requiredEnum(
        MoveInsightClaimType.values,
        json['type'],
        'move insight claim type',
      ),
      confidence: _requiredEnum(
        MoveInsightConfidence.values,
        json['confidence'],
        'move insight confidence',
      ),
      reasonCode: json['reasonCode'] as String? ?? '',
      supportingFactIds: _strictStringList(
        json['supportingFactIds'],
        'move insight supporting fact IDs',
      ),
      pieceRole: json['pieceRole'] as String?,
      pieceSquare: json['pieceSquare'] as String?,
      targetRole: json['targetRole'] as String?,
      targetSquare: json['targetSquare'] as String?,
      materialDelta: (json['materialDelta'] as num?)?.toInt(),
      betterMoveSan: json['betterMoveSan'] as String?,
      opponentReplySan: json['opponentReplySan'] as String?,
      continuationSan: _strictStringList(
        json['continuationSan'],
        'move insight continuation SAN',
      ),
      continuationUci: _strictStringList(
        json['continuationUci'],
        'move insight continuation UCI',
      ),
      openingEco: json['openingEco'] as String?,
      openingName: json['openingName'] as String?,
      mechanism: _enumOrDefault(
        MoveInsightMechanismType.values,
        json['mechanism'],
        MoveInsightMechanismType.none,
      ),
      consequence: _enumOrDefault(
        MoveInsightConsequenceType.values,
        json['consequence'],
        MoveInsightConsequenceType.none,
      ),
      mechanismReasonCode: json['mechanismReasonCode'] as String?,
      initiatorRole: json['initiatorRole'] as String?,
      initiatorSquare: json['initiatorSquare'] as String?,
      secondaryTargetRole: json['secondaryTargetRole'] as String?,
      secondaryTargetSquare: json['secondaryTargetSquare'] as String?,
      defenderRole: json['defenderRole'] as String?,
      defenderSquare: json['defenderSquare'] as String?,
      relationType: _optionalEnum(
        MoveInsightRelationType.values,
        json['relationType'],
        'move insight claim relation type',
      ),
      lineType: _optionalEnum(
        MoveInsightLineType.values,
        json['lineType'],
        'move insight claim line type',
      ),
      lineSquares: _strictStringList(
        json['lineSquares'],
        'move insight claim line squares',
      ),
    );
  }
}

/// Ordered fact reference in the selected causal chain.
class MoveInsightCausalStep {
  const MoveInsightCausalStep({required this.stage, required this.factId});

  final MoveInsightCausalStage stage;
  final String factId;

  bool get isStructurallyValid => _idPattern.hasMatch(factId);

  Map<String, Object?> toJson() => <String, Object?>{
    'stage': stage.name,
    'factId': factId,
  };

  factory MoveInsightCausalStep.fromJson(Map<dynamic, dynamic> json) {
    _rejectUnexpectedKeys(
      json,
      _moveInsightCausalStepKeys,
      'move insight causal step',
    );
    return MoveInsightCausalStep(
      stage: _requiredEnum(
        MoveInsightCausalStage.values,
        json['stage'],
        'move insight causal stage',
      ),
      factId: json['factId'] as String? ?? '',
    );
  }
}

/// Canonical persisted explanation artifact. An explicit non-available state
/// prevents UI fallbacks from inventing prose when evidence is weak.
class MoveInsight {
  const MoveInsight._({
    required this.state,
    required this.policyVersion,
    required this.claimSchemaVersion,
    required this.rendererVersion,
    required this.facts,
    required this.primaryClaim,
    required this.supportingClaims,
    required this.causalChain,
    required this.conciseText,
    required this.causeText,
    required this.consequenceText,
    required this.betterMoveText,
    required this.continuationText,
    required this.suppressionReason,
    required this.integrityDigest,
  });

  factory MoveInsight.create({
    required MoveInsightState state,
    List<MoveInsightFact> facts = const <MoveInsightFact>[],
    MoveInsightClaim? primaryClaim,
    List<MoveInsightClaim> supportingClaims = const <MoveInsightClaim>[],
    List<MoveInsightCausalStep> causalChain = const <MoveInsightCausalStep>[],
    String? conciseText,
    String? causeText,
    String? consequenceText,
    String? betterMoveText,
    String? continuationText,
    String? suppressionReason,
    int policyVersion = kApexExplanationPolicyVersion,
    int claimSchemaVersion = kApexExplanationClaimSchemaVersion,
    int rendererVersion = kApexExplanationRendererVersion,
  }) {
    final draft = MoveInsight._(
      state: state,
      policyVersion: policyVersion,
      claimSchemaVersion: claimSchemaVersion,
      rendererVersion: rendererVersion,
      facts: List<MoveInsightFact>.unmodifiable(facts),
      primaryClaim: primaryClaim,
      supportingClaims: List<MoveInsightClaim>.unmodifiable(supportingClaims),
      causalChain: List<MoveInsightCausalStep>.unmodifiable(causalChain),
      conciseText: _cleanText(conciseText),
      causeText: _cleanText(causeText),
      consequenceText: _cleanText(consequenceText),
      betterMoveText: _cleanText(betterMoveText),
      continuationText: _cleanText(continuationText),
      suppressionReason: _cleanCode(suppressionReason),
      integrityDigest: '',
    );
    return draft._withDigest(_digest(draft._identityJson()));
  }

  final MoveInsightState state;
  final int policyVersion;
  final int claimSchemaVersion;
  final int rendererVersion;
  final List<MoveInsightFact> facts;
  final MoveInsightClaim? primaryClaim;
  final List<MoveInsightClaim> supportingClaims;
  final List<MoveInsightCausalStep> causalChain;
  final String? conciseText;
  final String? causeText;
  final String? consequenceText;
  final String? betterMoveText;
  final String? continuationText;
  final String? suppressionReason;
  final String integrityDigest;

  bool get isDisplayable =>
      state == MoveInsightState.available &&
      primaryClaim != null &&
      conciseText?.isNotEmpty == true;

  int get trustRank => switch (state) {
    MoveInsightState.contradictory => 0,
    MoveInsightState.unavailable => 1,
    MoveInsightState.suppressed => 2,
    MoveInsightState.available =>
      primaryClaim?.confidence == MoveInsightConfidence.verified ? 4 : 3,
  };

  bool get hasValidIntegrity =>
      _sha256Pattern.hasMatch(integrityDigest) &&
      integrityDigest == _digest(_identityJson());

  bool get hasValidStructure {
    if (policyVersion <= 0 ||
        (claimSchemaVersion != kApexLegacyExplanationClaimSchemaVersion &&
            claimSchemaVersion != kApexExplanationClaimSchemaVersion) ||
        rendererVersion <= 0 ||
        !hasValidIntegrity ||
        facts.any((fact) => !fact.isStructurallyValid) ||
        (claimSchemaVersion == kApexLegacyExplanationClaimSchemaVersion &&
            facts.any((fact) => !_factHasNoCausalV2Payload(fact))) ||
        supportingClaims.any((claim) => !claim.isStructurallyValid) ||
        causalChain.any((step) => !step.isStructurallyValid)) {
      return false;
    }
    final factIds = facts.map((fact) => fact.id).toSet();
    if (factIds.length != facts.length) return false;
    final claims = <MoveInsightClaim>[
      if (primaryClaim != null) primaryClaim!,
      ...supportingClaims,
    ];
    if (claims.map((claim) => claim.id).toSet().length != claims.length ||
        claims.any(
          (claim) =>
              !claim.isStructurallyValid ||
              (claimSchemaVersion == kApexLegacyExplanationClaimSchemaVersion &&
                  !_hasNoCausalV2Payload(claim)) ||
              claim.supportingFactIds.any((id) => !factIds.contains(id)),
        ) ||
        causalChain.any((step) => !factIds.contains(step.factId))) {
      return false;
    }
    if (state == MoveInsightState.available) {
      return primaryClaim != null &&
          conciseText?.isNotEmpty == true &&
          suppressionReason == null &&
          causalChain.isNotEmpty;
    }
    return primaryClaim == null &&
        supportingClaims.isEmpty &&
        conciseText == null &&
        suppressionReason != null;
  }

  String get semanticFingerprint => _digest(<String, Object?>{
    'state': state.name,
    'facts': facts.map((fact) => fact.toJson()).toList(growable: false),
    'primaryClaim': primaryClaim?.toJson(),
    'supportingClaims': supportingClaims
        .map((claim) => claim.toJson())
        .toList(growable: false),
    'causalChain': causalChain
        .map((step) => step.toJson())
        .toList(growable: false),
    'suppressionReason': suppressionReason,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    ..._identityJson(),
    'integrityDigest': integrityDigest,
  };

  factory MoveInsight.fromJson(Map<dynamic, dynamic> json) {
    _rejectUnexpectedKeys(json, _moveInsightKeys, 'move insight');
    final primary = json['primaryClaim'];
    if (primary != null && primary is! Map) {
      throw const FormatException(
        'Move insight primary claim must be an object.',
      );
    }
    return MoveInsight._(
      state: _requiredEnum(
        MoveInsightState.values,
        json['state'],
        'move insight state',
      ),
      policyVersion: (json['policyVersion'] as num?)?.toInt() ?? -1,
      claimSchemaVersion: (json['claimSchemaVersion'] as num?)?.toInt() ?? -1,
      rendererVersion: (json['rendererVersion'] as num?)?.toInt() ?? -1,
      facts: List<MoveInsightFact>.unmodifiable(
        _strictMapList(
          json['facts'],
          'move insight facts',
        ).map(MoveInsightFact.fromJson),
      ),
      primaryClaim: primary is Map ? MoveInsightClaim.fromJson(primary) : null,
      supportingClaims: List<MoveInsightClaim>.unmodifiable(
        _strictMapList(
          json['supportingClaims'],
          'move insight supporting claims',
        ).map(MoveInsightClaim.fromJson),
      ),
      causalChain: List<MoveInsightCausalStep>.unmodifiable(
        _strictMapList(
          json['causalChain'],
          'move insight causal chain',
        ).map(MoveInsightCausalStep.fromJson),
      ),
      conciseText: _cleanText(json['conciseText'] as String?),
      causeText: _cleanText(json['causeText'] as String?),
      consequenceText: _cleanText(json['consequenceText'] as String?),
      betterMoveText: _cleanText(json['betterMoveText'] as String?),
      continuationText: _cleanText(json['continuationText'] as String?),
      suppressionReason: _cleanCode(json['suppressionReason'] as String?),
      integrityDigest: json['integrityDigest'] as String? ?? '',
    );
  }

  MoveInsight _withDigest(String digest) => MoveInsight._(
    state: state,
    policyVersion: policyVersion,
    claimSchemaVersion: claimSchemaVersion,
    rendererVersion: rendererVersion,
    facts: facts,
    primaryClaim: primaryClaim,
    supportingClaims: supportingClaims,
    causalChain: causalChain,
    conciseText: conciseText,
    causeText: causeText,
    consequenceText: consequenceText,
    betterMoveText: betterMoveText,
    continuationText: continuationText,
    suppressionReason: suppressionReason,
    integrityDigest: digest,
  );

  Map<String, Object?> _identityJson() => <String, Object?>{
    'state': state.name,
    'policyVersion': policyVersion,
    'claimSchemaVersion': claimSchemaVersion,
    'rendererVersion': rendererVersion,
    'facts': facts.map((fact) => fact.toJson()).toList(growable: false),
    'primaryClaim': primaryClaim?.toJson(),
    'supportingClaims': supportingClaims
        .map((claim) => claim.toJson())
        .toList(growable: false),
    'causalChain': causalChain
        .map((step) => step.toJson())
        .toList(growable: false),
    'conciseText': conciseText,
    'causeText': causeText,
    'consequenceText': consequenceText,
    'betterMoveText': betterMoveText,
    'continuationText': continuationText,
    'suppressionReason': suppressionReason,
  };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

String? _cleanText(String? value) {
  final clean = value?.replaceAll(RegExp(r'\s+'), ' ').trim();
  return clean == null || clean.isEmpty ? null : clean;
}

String? _cleanCode(String? value) {
  final clean = value?.trim().toLowerCase();
  return clean == null || clean.isEmpty ? null : clean;
}

T _requiredEnum<T extends Enum>(List<T> values, Object? raw, String label) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  throw FormatException('Unknown $label: $raw');
}

T _enumOrDefault<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw == null) return fallback;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  throw FormatException('Unknown enum value: $raw');
}

T? _optionalEnum<T extends Enum>(List<T> values, Object? raw, String label) {
  if (raw == null) return null;
  return _requiredEnum(values, raw, label);
}

void _rejectUnexpectedKeys(
  Map<dynamic, dynamic> json,
  Set<String> allowed,
  String label,
) {
  for (final key in json.keys) {
    if (key is! String || !allowed.contains(key)) {
      throw FormatException('Unsupported $label field: $key');
    }
  }
}

List<Map<dynamic, dynamic>> _strictMapList(Object? raw, String label) {
  if (raw == null) return const <Map<dynamic, dynamic>>[];
  if (raw is! List) throw FormatException('$label must be a list.');
  final values = <Map<dynamic, dynamic>>[];
  for (final value in raw) {
    if (value is! Map) throw FormatException('$label must contain objects.');
    values.add(value);
  }
  return values;
}

List<String> _strictStringList(Object? raw, String label) {
  if (raw == null) return const <String>[];
  if (raw is! List) throw FormatException('$label must be a list.');
  final values = <String>[];
  for (final value in raw) {
    if (value is! String) {
      throw FormatException('$label must contain strings.');
    }
    values.add(value);
  }
  return values;
}

const Set<String> _moveInsightFactKeys = <String>{
  'id',
  'type',
  'pieceRole',
  'pieceSide',
  'fromSquare',
  'toSquare',
  'intValue',
  'textValue',
  'linePly',
  'relationType',
  'relatedPieceRole',
  'relatedPieceSide',
  'relatedSquare',
  'secondaryPieceRole',
  'secondaryPieceSide',
  'secondarySquare',
  'lineType',
  'lineSquares',
};

const Set<String> _moveInsightClaimKeys = <String>{
  'id',
  'type',
  'confidence',
  'reasonCode',
  'supportingFactIds',
  'pieceRole',
  'pieceSquare',
  'targetRole',
  'targetSquare',
  'materialDelta',
  'betterMoveSan',
  'opponentReplySan',
  'continuationSan',
  'continuationUci',
  'openingEco',
  'openingName',
  'mechanism',
  'consequence',
  'mechanismReasonCode',
  'initiatorRole',
  'initiatorSquare',
  'secondaryTargetRole',
  'secondaryTargetSquare',
  'defenderRole',
  'defenderSquare',
  'relationType',
  'lineType',
  'lineSquares',
};

const Set<String> _moveInsightCausalStepKeys = <String>{'stage', 'factId'};

const Set<String> _moveInsightKeys = <String>{
  'state',
  'policyVersion',
  'claimSchemaVersion',
  'rendererVersion',
  'facts',
  'primaryClaim',
  'supportingClaims',
  'causalChain',
  'conciseText',
  'causeText',
  'consequenceText',
  'betterMoveText',
  'continuationText',
  'suppressionReason',
  'integrityDigest',
};

bool _hasNoCausalV2Payload(MoveInsightClaim claim) =>
    claim.mechanism == MoveInsightMechanismType.none &&
    claim.consequence == MoveInsightConsequenceType.none &&
    claim.mechanismReasonCode == null &&
    claim.initiatorRole == null &&
    claim.initiatorSquare == null &&
    claim.secondaryTargetRole == null &&
    claim.secondaryTargetSquare == null &&
    claim.defenderRole == null &&
    claim.defenderSquare == null &&
    claim.relationType == null &&
    claim.lineType == null &&
    claim.lineSquares.isEmpty;

bool _factHasNoCausalV2Payload(MoveInsightFact fact) =>
    fact.relationType == null &&
    fact.relatedPieceRole == null &&
    fact.relatedPieceSide == null &&
    fact.relatedSquare == null &&
    fact.secondaryPieceRole == null &&
    fact.secondaryPieceSide == null &&
    fact.secondarySquare == null &&
    fact.lineType == null &&
    fact.lineSquares.isEmpty &&
    fact.type != MoveInsightFactType.changedRelationship &&
    fact.type != MoveInsightFactType.forcedResponse &&
    fact.type != MoveInsightFactType.materialInvestment &&
    fact.type != MoveInsightFactType.alternativeOutcome;

bool _validRole(String? value) =>
    value == null ||
    const {'pawn', 'knight', 'bishop', 'rook', 'queen', 'king'}.contains(value);

bool _validSide(String? value) =>
    value == null || value == 'white' || value == 'black';

bool _validSquare(String? value) =>
    value == null || RegExp(r'^[a-h][1-8]$').hasMatch(value);

final RegExp _idPattern = RegExp(r'^[a-z0-9][a-z0-9_]{1,63}$');
final RegExp _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');
