library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/pgn_mainline_validator.dart';

const int kGameIdAlgorithmVersion = 1;
const int kAnalysisVariantAlgorithmVersion = 1;
const int kAnalysisProfileContractVersion = 1;
const int kScorePerspectiveContractVersion = 1;

class GameId {
  const GameId(this.value, {this.algorithmVersion = kGameIdAlgorithmVersion});

  final String value;
  final int algorithmVersion;

  Map<String, dynamic> toJson() => {
    'value': value,
    'algorithmVersion': algorithmVersion,
  };

  factory GameId.fromJson(Map<dynamic, dynamic> json) => GameId(
    json['value'] as String,
    algorithmVersion: (json['algorithmVersion'] as num).toInt(),
  );
}

class CanonicalGameMove {
  const CanonicalGameMove({
    required this.ply,
    required this.san,
    required this.uci,
    required this.fenBefore,
    required this.fenAfter,
  });

  final int ply;
  final String san;
  final String uci;
  final String fenBefore;
  final String fenAfter;

  Map<String, dynamic> toJson() => {
    'ply': ply,
    'san': san,
    'uci': uci,
    'fenBefore': fenBefore,
    'fenAfter': fenAfter,
  };

  factory CanonicalGameMove.fromJson(Map<dynamic, dynamic> json) =>
      CanonicalGameMove(
        ply: (json['ply'] as num).toInt(),
        san: json['san'] as String,
        uci: json['uci'] as String,
        fenBefore: json['fenBefore'] as String,
        fenAfter: json['fenAfter'] as String,
      );
}

class CanonicalGame {
  const CanonicalGame({
    required this.gameId,
    required this.ruleset,
    required this.startingFen,
    required this.moves,
    required this.originalPgn,
    required this.headers,
    required this.sourceProvider,
    this.sourceGameId,
    this.importedAt,
  });

  final GameId gameId;
  final String ruleset;
  final String startingFen;
  final List<CanonicalGameMove> moves;
  final String originalPgn;
  final Map<String, String> headers;
  final String sourceProvider;
  final String? sourceGameId;
  final DateTime? importedAt;

  String get canonicalIdentityMaterial =>
      CanonicalGameIdentityService.canonicalMaterial(
        ruleset: ruleset,
        startingFen: startingFen,
        uciMoves: moves.map((move) => move.uci),
      );

  Map<String, dynamic> toJson() => {
    'gameId': gameId.toJson(),
    'ruleset': ruleset,
    'startingFen': startingFen,
    'moves': moves.map((move) => move.toJson()).toList(growable: false),
    'originalPgn': originalPgn,
    'headers': headers,
    'sourceProvider': sourceProvider,
    'sourceGameId': sourceGameId,
    'importedAt': importedAt?.toUtc().toIso8601String(),
  };

  factory CanonicalGame.fromJson(Map<dynamic, dynamic> json) => CanonicalGame(
    gameId: GameId.fromJson(json['gameId'] as Map),
    ruleset: json['ruleset'] as String,
    startingFen: json['startingFen'] as String,
    moves: [
      for (final move in json['moves'] as List)
        CanonicalGameMove.fromJson(move as Map),
    ],
    originalPgn: json['originalPgn'] as String,
    headers: {
      for (final entry in (json['headers'] as Map).entries)
        entry.key.toString(): entry.value.toString(),
    },
    sourceProvider: json['sourceProvider'] as String,
    sourceGameId: json['sourceGameId'] as String?,
    importedAt: json['importedAt'] == null
        ? null
        : DateTime.parse(json['importedAt'] as String).toUtc(),
  );
}

class CanonicalGameIdentityService {
  const CanonicalGameIdentityService({
    this.validator = const PgnMainlineValidator(),
  });

  final PgnMainlineValidator validator;

  CanonicalGame fromPgn({
    required String pgn,
    required String sourceProvider,
    String? sourceGameId,
    DateTime? importedAt,
    Map<String, String> supplementalHeaders = const {},
  }) {
    final parsed = validator.validate(pgn);
    final material = canonicalMaterial(
      ruleset: 'standard',
      startingFen: parsed.startingFen,
      uciMoves: parsed.moves.map((move) => move.uci),
    );
    return CanonicalGame(
      gameId: GameId(sha256.convert(utf8.encode(material)).toString()),
      ruleset: 'standard',
      startingFen: parsed.startingFen,
      moves: [
        for (var ply = 0; ply < parsed.moves.length; ply++)
          CanonicalGameMove(
            ply: ply,
            san: parsed.moves[ply].san,
            uci: parsed.moves[ply].uci,
            fenBefore: parsed.moves[ply].fenBefore,
            fenAfter: parsed.moves[ply].fenAfter,
          ),
      ],
      originalPgn: pgn,
      headers: Map<String, String>.unmodifiable({
        ...parsed.headers,
        ...supplementalHeaders,
      }),
      sourceProvider: sourceProvider,
      sourceGameId: _cleanOptional(sourceGameId),
      importedAt: importedAt?.toUtc(),
    );
  }

  static String canonicalMaterial({
    required String ruleset,
    required String startingFen,
    required Iterable<String> uciMoves,
  }) {
    final moves = uciMoves.toList(growable: false);
    final buffer = StringBuffer()
      ..writeln('apex-chess-game-id')
      ..writeln('algorithm=$kGameIdAlgorithmVersion')
      ..writeln(_lengthPrefixed('ruleset', ruleset))
      ..writeln(_lengthPrefixed('starting-fen', startingFen))
      ..writeln('move-count=${moves.length}');
    for (var index = 0; index < moves.length; index++) {
      buffer.writeln(_lengthPrefixed('move-$index', moves[index]));
    }
    return buffer.toString();
  }
}

enum ProvenanceVerification {
  unknown,
  declared,
  configuredOnly,
  runtimeVerified,
}

class ReviewEngineIdentity {
  const ReviewEngineIdentity({
    required this.declaredIdentity,
    required this.engineName,
    required this.engineVersion,
    required this.bridgeIdentity,
    required this.configuredNnueIdentity,
    required this.nnueVerification,
    required this.identityVerification,
  });

  final String declaredIdentity;
  final String? engineName;
  final String? engineVersion;
  final String? bridgeIdentity;
  final String? configuredNnueIdentity;
  final ProvenanceVerification nnueVerification;
  final ProvenanceVerification identityVerification;

  factory ReviewEngineIdentity.fromDeclared(String raw) {
    final declared = raw.trim().isEmpty ? 'unknown' : raw.trim();
    final parts = declared.split('|').map((part) => part.trim()).toList();
    final enginePart = parts.length > 1 ? parts.last : declared;
    final match = RegExp(
      r'^(.*?)[ /]([0-9]+(?:\.[0-9]+)*)$',
    ).firstMatch(enginePart);
    final isStockfish17 = enginePart.toLowerCase().contains('stockfish 17');
    return ReviewEngineIdentity(
      declaredIdentity: declared,
      engineName: match?.group(1)?.trim(),
      engineVersion: match?.group(2),
      bridgeIdentity: parts.length > 1 ? parts.first : null,
      configuredNnueIdentity: isStockfish17 ? 'nn-37f18f62d772.nnue' : null,
      nnueVerification: isStockfish17
          ? ProvenanceVerification.configuredOnly
          : ProvenanceVerification.unknown,
      identityVerification: declared == 'unknown'
          ? ProvenanceVerification.unknown
          : ProvenanceVerification.declared,
    );
  }

  Map<String, dynamic> toJson() => {
    'declaredIdentity': declaredIdentity,
    'engineName': engineName,
    'engineVersion': engineVersion,
    'bridgeIdentity': bridgeIdentity,
    'configuredNnueIdentity': configuredNnueIdentity,
    'nnueVerification': nnueVerification.name,
    'identityVerification': identityVerification.name,
  };

  factory ReviewEngineIdentity.fromJson(Map<dynamic, dynamic> json) =>
      ReviewEngineIdentity(
        declaredIdentity: json['declaredIdentity'] as String,
        engineName: json['engineName'] as String?,
        engineVersion: json['engineVersion'] as String?,
        bridgeIdentity: json['bridgeIdentity'] as String?,
        configuredNnueIdentity: json['configuredNnueIdentity'] as String?,
        nnueVerification: _enumByName(
          ProvenanceVerification.values,
          json['nnueVerification'],
          ProvenanceVerification.unknown,
        ),
        identityVerification: _enumByName(
          ProvenanceVerification.values,
          json['identityVerification'],
          ProvenanceVerification.unknown,
        ),
      );
}

class AnalysisSearchPolicy {
  const AnalysisSearchPolicy({
    this.requestedDepth,
    this.requestedMovetimeMs,
    this.requestedNodes,
    this.multiPv,
    required this.candidateVerificationEnabled,
    this.engineOptions = const {},
  });

  final int? requestedDepth;
  final int? requestedMovetimeMs;
  final int? requestedNodes;
  final int? multiPv;
  final bool candidateVerificationEnabled;
  final Map<String, String> engineOptions;

  Map<String, dynamic> toJson() => {
    'requestedDepth': requestedDepth,
    'requestedMovetimeMs': requestedMovetimeMs,
    'requestedNodes': requestedNodes,
    'multiPv': multiPv,
    'candidateVerificationEnabled': candidateVerificationEnabled,
    'engineOptions': engineOptions,
  };

  factory AnalysisSearchPolicy.fromJson(Map<dynamic, dynamic> json) =>
      AnalysisSearchPolicy(
        requestedDepth: (json['requestedDepth'] as num?)?.toInt(),
        requestedMovetimeMs: (json['requestedMovetimeMs'] as num?)?.toInt(),
        requestedNodes: (json['requestedNodes'] as num?)?.toInt(),
        multiPv: (json['multiPv'] as num?)?.toInt(),
        candidateVerificationEnabled:
            json['candidateVerificationEnabled'] as bool? ?? false,
        engineOptions: {
          for (final entry
              in ((json['engineOptions'] as Map?) ?? const {}).entries)
            entry.key.toString(): entry.value.toString(),
        },
      );
}

class AnalysisCompatibility {
  const AnalysisCompatibility({
    required this.gameId,
    required this.profileId,
    required this.profileVersion,
    required this.providerId,
    required this.engine,
    required this.searchPolicy,
    required this.analysisSchemaVersion,
    required this.classifierVersion,
    required this.tacticalVerifierVersion,
    required this.openingBookVersion,
    this.openingArtifact,
    required this.scorePerspectiveContractVersion,
  });

  final GameId gameId;
  final String profileId;
  final int profileVersion;
  final String providerId;
  final ReviewEngineIdentity engine;
  final AnalysisSearchPolicy searchPolicy;
  final int analysisSchemaVersion;
  final int classifierVersion;
  final int tacticalVerifierVersion;
  final int openingBookVersion;
  final OpeningArtifactIdentity? openingArtifact;
  final int scorePerspectiveContractVersion;

  factory AnalysisCompatibility.fromTimeline({
    required GameId gameId,
    required AnalysisTimeline timeline,
  }) => AnalysisCompatibility(
    gameId: gameId,
    profileId: timeline.analysisProfileId,
    profileVersion: kAnalysisProfileContractVersion,
    providerId: timeline.providerId,
    engine: ReviewEngineIdentity.fromDeclared(timeline.engineVersion),
    searchPolicy: AnalysisSearchPolicy(
      requestedDepth: timeline.requestedDepth,
      requestedMovetimeMs: timeline.movetimeMs,
      multiPv: timeline.multipv,
      candidateVerificationEnabled: timeline.candidateVerificationEnabled,
    ),
    analysisSchemaVersion: timeline.analysisSchemaVersion,
    classifierVersion: timeline.classifierVersion,
    tacticalVerifierVersion: timeline.tacticalVerifierVersion,
    openingBookVersion: timeline.openingBookVersion,
    openingArtifact: timeline.openingArtifact,
    scorePerspectiveContractVersion: kScorePerspectiveContractVersion,
  );

  String get canonicalMaterial {
    final artifact = openingArtifact;
    if (openingBookVersion >= 2 &&
        (artifact == null ||
            !artifact.isStructurallyValid ||
            artifact.openingPolicyVersion != openingBookVersion)) {
      throw StateError(
        'Opening contract v$openingBookVersion requires its exact artifact.',
      );
    }
    final sortedOptions = searchPolicy.engineOptions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final fields = <String>[
      'apex-analysis-variant',
      'algorithm=$kAnalysisVariantAlgorithmVersion',
      'game=${gameId.algorithmVersion}:${gameId.value}',
      _lengthPrefixed('profile', profileId),
      'profile-version=$profileVersion',
      _lengthPrefixed('provider', providerId),
      _lengthPrefixed('engine-declared', engine.declaredIdentity),
      _lengthPrefixed('engine-name', engine.engineName ?? 'unknown'),
      _lengthPrefixed('engine-version', engine.engineVersion ?? 'unknown'),
      _lengthPrefixed('bridge', engine.bridgeIdentity ?? 'unknown'),
      _lengthPrefixed('nnue', engine.configuredNnueIdentity ?? 'unknown'),
      'nnue-verification=${engine.nnueVerification.name}',
      'depth=${searchPolicy.requestedDepth ?? 'unknown'}',
      'movetime-ms=${searchPolicy.requestedMovetimeMs ?? 'unknown'}',
      'nodes=${searchPolicy.requestedNodes ?? 'unknown'}',
      'multipv=${searchPolicy.multiPv ?? 'unknown'}',
      'candidate-verification=${searchPolicy.candidateVerificationEnabled}',
      for (final option in sortedOptions)
        _lengthPrefixed('option:${option.key}', option.value),
      'analysis-schema=$analysisSchemaVersion',
      'classifier=$classifierVersion',
      'tactical=$tacticalVerifierVersion',
      'opening=$openingBookVersion',
      if (openingBookVersion >= 2) 'opening-artifact=${artifact!.semanticId}',
      'score-perspective=$scorePerspectiveContractVersion',
    ];
    return '${fields.join('\n')}\n';
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId.toJson(),
    'profileId': profileId,
    'profileVersion': profileVersion,
    'providerId': providerId,
    'engine': engine.toJson(),
    'searchPolicy': searchPolicy.toJson(),
    'analysisSchemaVersion': analysisSchemaVersion,
    'classifierVersion': classifierVersion,
    'tacticalVerifierVersion': tacticalVerifierVersion,
    'openingBookVersion': openingBookVersion,
    if (openingArtifact != null) 'openingArtifact': openingArtifact!.toJson(),
    'scorePerspectiveContractVersion': scorePerspectiveContractVersion,
  };

  factory AnalysisCompatibility.fromJson(
    Map<dynamic, dynamic> json,
  ) => AnalysisCompatibility(
    gameId: GameId.fromJson(json['gameId'] as Map),
    profileId: json['profileId'] as String,
    profileVersion: (json['profileVersion'] as num).toInt(),
    providerId: json['providerId'] as String,
    engine: ReviewEngineIdentity.fromJson(json['engine'] as Map),
    searchPolicy: AnalysisSearchPolicy.fromJson(json['searchPolicy'] as Map),
    analysisSchemaVersion: (json['analysisSchemaVersion'] as num).toInt(),
    classifierVersion: (json['classifierVersion'] as num).toInt(),
    tacticalVerifierVersion: (json['tacticalVerifierVersion'] as num).toInt(),
    openingBookVersion: (json['openingBookVersion'] as num).toInt(),
    openingArtifact: json['openingArtifact'] is Map
        ? OpeningArtifactIdentity.fromJson(json['openingArtifact'] as Map)
        : null,
    scorePerspectiveContractVersion:
        (json['scorePerspectiveContractVersion'] as num).toInt(),
  );
}

class AnalysisVariantId {
  const AnalysisVariantId(
    this.value, {
    this.algorithmVersion = kAnalysisVariantAlgorithmVersion,
  });

  final String value;
  final int algorithmVersion;

  factory AnalysisVariantId.fromCompatibility(
    AnalysisCompatibility compatibility,
  ) => AnalysisVariantId(
    sha256.convert(utf8.encode(compatibility.canonicalMaterial)).toString(),
  );

  Map<String, dynamic> toJson() => {
    'value': value,
    'algorithmVersion': algorithmVersion,
  };

  factory AnalysisVariantId.fromJson(Map<dynamic, dynamic> json) =>
      AnalysisVariantId(
        json['value'] as String,
        algorithmVersion: (json['algorithmVersion'] as num).toInt(),
      );
}

String _lengthPrefixed(String key, String value) =>
    '$key=${utf8.encode(value).length}:$value';

String? _cleanOptional(String? value) {
  final clean = value?.trim();
  if (clean == null || clean.isEmpty || clean == '?') return null;
  return clean;
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return fallback;
}
