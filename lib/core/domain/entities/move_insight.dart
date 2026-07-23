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
}

enum MoveInsightCausalStage { move, changedFact, condition, response, outcome }

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

  bool get isStructurallyValid =>
      _idPattern.hasMatch(id) &&
      _validRole(pieceRole) &&
      _validSide(pieceSide) &&
      _validSquare(fromSquare) &&
      _validSquare(toSquare) &&
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
  };

  factory MoveInsightFact.fromJson(Map<dynamic, dynamic> json) =>
      MoveInsightFact(
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
      );
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

  bool get isStructurallyValid =>
      _idPattern.hasMatch(id) &&
      _idPattern.hasMatch(reasonCode) &&
      supportingFactIds.isNotEmpty &&
      supportingFactIds.every(_idPattern.hasMatch) &&
      _validRole(pieceRole) &&
      _validRole(targetRole) &&
      _validSquare(pieceSquare) &&
      _validSquare(targetSquare) &&
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
  };

  factory MoveInsightClaim.fromJson(Map<dynamic, dynamic> json) =>
      MoveInsightClaim(
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
        supportingFactIds:
            (json['supportingFactIds'] as List<dynamic>? ?? const <dynamic>[])
                .map((value) => value.toString())
                .toList(growable: false),
        pieceRole: json['pieceRole'] as String?,
        pieceSquare: json['pieceSquare'] as String?,
        targetRole: json['targetRole'] as String?,
        targetSquare: json['targetSquare'] as String?,
        materialDelta: (json['materialDelta'] as num?)?.toInt(),
        betterMoveSan: json['betterMoveSan'] as String?,
        opponentReplySan: json['opponentReplySan'] as String?,
        continuationSan:
            (json['continuationSan'] as List<dynamic>? ?? const <dynamic>[])
                .map((value) => value.toString())
                .toList(growable: false),
        continuationUci:
            (json['continuationUci'] as List<dynamic>? ?? const <dynamic>[])
                .map((value) => value.toString())
                .toList(growable: false),
        openingEco: json['openingEco'] as String?,
        openingName: json['openingName'] as String?,
      );
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

  factory MoveInsightCausalStep.fromJson(Map<dynamic, dynamic> json) =>
      MoveInsightCausalStep(
        stage: _requiredEnum(
          MoveInsightCausalStage.values,
          json['stage'],
          'move insight causal stage',
        ),
        factId: json['factId'] as String? ?? '',
      );
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
        claimSchemaVersion <= 0 ||
        rendererVersion <= 0 ||
        !hasValidIntegrity ||
        facts.any((fact) => !fact.isStructurallyValid) ||
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

  factory MoveInsight.fromJson(Map<dynamic, dynamic> json) => MoveInsight._(
    state: _requiredEnum(
      MoveInsightState.values,
      json['state'],
      'move insight state',
    ),
    policyVersion: (json['policyVersion'] as num?)?.toInt() ?? -1,
    claimSchemaVersion: (json['claimSchemaVersion'] as num?)?.toInt() ?? -1,
    rendererVersion: (json['rendererVersion'] as num?)?.toInt() ?? -1,
    facts: List<MoveInsightFact>.unmodifiable(
      (json['facts'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(MoveInsightFact.fromJson),
    ),
    primaryClaim: json['primaryClaim'] is Map
        ? MoveInsightClaim.fromJson(json['primaryClaim'] as Map)
        : null,
    supportingClaims: List<MoveInsightClaim>.unmodifiable(
      (json['supportingClaims'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(MoveInsightClaim.fromJson),
    ),
    causalChain: List<MoveInsightCausalStep>.unmodifiable(
      (json['causalChain'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<dynamic, dynamic>>()
          .map(MoveInsightCausalStep.fromJson),
    ),
    conciseText: _cleanText(json['conciseText'] as String?),
    causeText: _cleanText(json['causeText'] as String?),
    consequenceText: _cleanText(json['consequenceText'] as String?),
    betterMoveText: _cleanText(json['betterMoveText'] as String?),
    continuationText: _cleanText(json['continuationText'] as String?),
    suppressionReason: _cleanCode(json['suppressionReason'] as String?),
    integrityDigest: json['integrityDigest'] as String? ?? '',
  );

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

bool _validRole(String? value) =>
    value == null ||
    const {'pawn', 'knight', 'bishop', 'rook', 'queen', 'king'}.contains(value);

bool _validSide(String? value) =>
    value == null || value == 'white' || value == 'black';

bool _validSquare(String? value) =>
    value == null || RegExp(r'^[a-h][1-8]$').hasMatch(value);

final RegExp _idPattern = RegExp(r'^[a-z0-9][a-z0-9_]{1,63}$');
final RegExp _sha256Pattern = RegExp(r'^[0-9a-f]{64}$');
