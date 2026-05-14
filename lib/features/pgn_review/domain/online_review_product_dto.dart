/// DTOs for the Apex backend Online Review product contract.
///
/// These models parse `online-review-product-v1` only. They intentionally do
/// not model internal review-draft, schema, governance, or audit sections.
library;

const onlineReviewProductContractVersion = 'online-review-product-v1';

enum OnlineReviewMode {
  onlineFast('onlineFast'),
  onlineDeep('onlineDeep'),
  dev('dev');

  const OnlineReviewMode(this.wire);

  final String wire;

  static OnlineReviewMode fromJson(Object? value) {
    return switch (value?.toString()) {
      'onlineFast' => OnlineReviewMode.onlineFast,
      'onlineDeep' => OnlineReviewMode.onlineDeep,
      'dev' => OnlineReviewMode.dev,
      _ => OnlineReviewMode.dev,
    };
  }
}

enum OnlineReviewProductStatus {
  completed('completed'),
  partial('partial'),
  failed('failed');

  const OnlineReviewProductStatus(this.wire);

  final String wire;

  static OnlineReviewProductStatus fromJson(Object? value) {
    return switch (value?.toString()) {
      'completed' => OnlineReviewProductStatus.completed,
      'partial' => OnlineReviewProductStatus.partial,
      'failed' => OnlineReviewProductStatus.failed,
      _ => OnlineReviewProductStatus.failed,
    };
  }
}

enum OnlineReviewMoveQuality {
  best('best'),
  excellent('excellent'),
  good('good'),
  inaccuracy('inaccuracy'),
  mistake('mistake'),
  blunder('blunder'),
  unclassified('unclassified');

  const OnlineReviewMoveQuality(this.wire);

  final String wire;

  static OnlineReviewMoveQuality fromJson(Object? value) {
    return switch (value?.toString()) {
      'best' => OnlineReviewMoveQuality.best,
      'excellent' => OnlineReviewMoveQuality.excellent,
      'good' => OnlineReviewMoveQuality.good,
      'inaccuracy' => OnlineReviewMoveQuality.inaccuracy,
      'mistake' => OnlineReviewMoveQuality.mistake,
      'blunder' => OnlineReviewMoveQuality.blunder,
      'unclassified' => OnlineReviewMoveQuality.unclassified,
      _ => OnlineReviewMoveQuality.unclassified,
    };
  }
}

enum OnlineReviewConfidence {
  high('high'),
  medium('medium'),
  low('low'),
  unknown('unknown');

  const OnlineReviewConfidence(this.wire);

  final String wire;

  static OnlineReviewConfidence fromJson(Object? value) {
    return switch (value?.toString()) {
      'high' => OnlineReviewConfidence.high,
      'medium' => OnlineReviewConfidence.medium,
      'low' => OnlineReviewConfidence.low,
      'unknown' => OnlineReviewConfidence.unknown,
      _ => OnlineReviewConfidence.unknown,
    };
  }
}

enum OnlineReviewCriticalityLevel {
  none('none'),
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const OnlineReviewCriticalityLevel(this.wire);

  final String wire;

  static OnlineReviewCriticalityLevel fromJson(Object? value) {
    return switch (value?.toString()) {
      'low' => OnlineReviewCriticalityLevel.low,
      'medium' => OnlineReviewCriticalityLevel.medium,
      'high' => OnlineReviewCriticalityLevel.high,
      'critical' => OnlineReviewCriticalityLevel.critical,
      'none' => OnlineReviewCriticalityLevel.none,
      _ => OnlineReviewCriticalityLevel.none,
    };
  }
}

class OnlineReviewProductResponseDto {
  const OnlineReviewProductResponseDto({
    required this.ok,
    required this.contractVersion,
    required this.mode,
    required this.status,
    required this.summary,
    required this.moves,
    required this.providerMetadata,
    this.gameKey,
    this.headers,
    this.debug,
    this.error,
  });

  final bool ok;
  final String contractVersion;
  final String? gameKey;
  final OnlineReviewMode mode;
  final OnlineReviewProductStatus status;
  final OnlineReviewHeadersDto? headers;
  final OnlineReviewSummaryDto summary;
  final List<OnlineReviewMoveDto> moves;
  final OnlineReviewProviderMetadataDto providerMetadata;
  final OnlineReviewDebugEnvelopeDto? debug;
  final OnlineReviewErrorDto? error;

  bool get isSuccess => ok && status != OnlineReviewProductStatus.failed;

  bool get isFailure => !ok || status == OnlineReviewProductStatus.failed;

  bool get hasDebug => debug != null;

  factory OnlineReviewProductResponseDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewProductResponseDto(
      ok: _requiredBool(json, 'ok'),
      contractVersion: _requiredString(json, 'contractVersion'),
      gameKey: _nullableString(json['gameKey']),
      mode: OnlineReviewMode.fromJson(_requiredValue(json, 'mode')),
      status: OnlineReviewProductStatus.fromJson(
        _requiredValue(json, 'status'),
      ),
      headers: _nullableMap(json['headers']) == null
          ? null
          : OnlineReviewHeadersDto.fromJson(_nullableMap(json['headers'])!),
      summary: OnlineReviewSummaryDto.fromJson(_requiredMap(json, 'summary')),
      moves: [
        for (final raw in _requiredList(json, 'moves'))
          OnlineReviewMoveDto.fromJson(_mapFromObject(raw)),
      ],
      providerMetadata: OnlineReviewProviderMetadataDto.fromJson(
        _requiredMap(json, 'providerMetadata'),
      ),
      debug: _nullableMap(json['debug']) == null
          ? null
          : OnlineReviewDebugEnvelopeDto.fromJson(_nullableMap(json['debug'])!),
      error: _nullableMap(json['error']) == null
          ? null
          : OnlineReviewErrorDto.fromJson(_nullableMap(json['error'])!),
    );
  }

  Map<String, Object?> toJson() => {
    'ok': ok,
    'contractVersion': contractVersion,
    'gameKey': gameKey,
    'mode': mode.wire,
    'status': status.wire,
    'headers': headers?.toJson(),
    'summary': summary.toJson(),
    'moves': [for (final move in moves) move.toJson()],
    'providerMetadata': providerMetadata.toJson(),
    'debug': debug?.toJson(),
    'error': error?.toJson(),
  };
}

class OnlineReviewHeadersDto {
  const OnlineReviewHeadersDto({
    this.event,
    this.site,
    this.date,
    this.round,
    this.white,
    this.black,
    this.whiteElo,
    this.blackElo,
    this.result,
    this.eco,
    this.opening,
  });

  final String? event;
  final String? site;
  final String? date;
  final String? round;
  final String? white;
  final String? black;
  final String? whiteElo;
  final String? blackElo;
  final String? result;
  final String? eco;
  final String? opening;

  factory OnlineReviewHeadersDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewHeadersDto(
      event: _nullableString(json['event']),
      site: _nullableString(json['site']),
      date: _nullableString(json['date']),
      round: _nullableString(json['round']),
      white: _nullableString(json['white']),
      black: _nullableString(json['black']),
      whiteElo: _nullableString(json['whiteElo']),
      blackElo: _nullableString(json['blackElo']),
      result: _nullableString(json['result']),
      eco: _nullableString(json['eco']),
      opening: _nullableString(json['opening']),
    );
  }

  Map<String, Object?> toJson() => {
    'event': event,
    'site': site,
    'date': date,
    'round': round,
    'white': white,
    'black': black,
    'whiteElo': whiteElo,
    'blackElo': blackElo,
    'result': result,
    'eco': eco,
    'opening': opening,
  };
}

class OnlineReviewSummaryDto {
  const OnlineReviewSummaryDto({
    required this.totalPlies,
    required this.analyzedMoves,
    required this.failedMoves,
    required this.qualityCounts,
    required this.bestMoveCount,
    required this.inaccuracyCount,
    required this.mistakeCount,
    required this.blunderCount,
    required this.criticalMoveCount,
    this.averageCpLoss,
    this.averageExpectedPointsLoss,
    this.maxCpLoss,
    this.maxExpectedPointsLoss,
    this.accuracy,
    this.acpl,
  });

  final int totalPlies;
  final int analyzedMoves;
  final int failedMoves;
  final Map<String, int> qualityCounts;
  final int bestMoveCount;
  final int inaccuracyCount;
  final int mistakeCount;
  final int blunderCount;
  final int criticalMoveCount;
  final double? averageCpLoss;
  final double? averageExpectedPointsLoss;
  final int? maxCpLoss;
  final double? maxExpectedPointsLoss;
  final double? accuracy;
  final double? acpl;

  factory OnlineReviewSummaryDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewSummaryDto(
      totalPlies: _requiredInt(json, 'totalPlies'),
      analyzedMoves: _requiredInt(json, 'analyzedMoves'),
      failedMoves: _requiredInt(json, 'failedMoves'),
      qualityCounts: _stringIntMap(_requiredMap(json, 'qualityCounts')),
      bestMoveCount: _requiredInt(json, 'bestMoveCount'),
      inaccuracyCount: _requiredInt(json, 'inaccuracyCount'),
      mistakeCount: _requiredInt(json, 'mistakeCount'),
      blunderCount: _requiredInt(json, 'blunderCount'),
      criticalMoveCount: _requiredInt(json, 'criticalMoveCount'),
      averageCpLoss: _nullableDouble(json['averageCpLoss']),
      averageExpectedPointsLoss: _nullableDouble(
        json['averageExpectedPointsLoss'],
      ),
      maxCpLoss: _nullableInt(json['maxCpLoss']),
      maxExpectedPointsLoss: _nullableDouble(json['maxExpectedPointsLoss']),
      accuracy: _nullableDouble(json['accuracy']),
      acpl: _nullableDouble(json['acpl']),
    );
  }

  Map<String, Object?> toJson() => {
    'totalPlies': totalPlies,
    'analyzedMoves': analyzedMoves,
    'failedMoves': failedMoves,
    'qualityCounts': qualityCounts,
    'bestMoveCount': bestMoveCount,
    'inaccuracyCount': inaccuracyCount,
    'mistakeCount': mistakeCount,
    'blunderCount': blunderCount,
    'criticalMoveCount': criticalMoveCount,
    'averageCpLoss': averageCpLoss,
    'averageExpectedPointsLoss': averageExpectedPointsLoss,
    'maxCpLoss': maxCpLoss,
    'maxExpectedPointsLoss': maxExpectedPointsLoss,
    'accuracy': accuracy,
    'acpl': acpl,
  };
}

class OnlineReviewMoveDto {
  const OnlineReviewMoveDto({
    required this.ply,
    required this.moveNumber,
    required this.side,
    required this.quality,
    required this.confidence,
    required this.criticalityLevel,
    required this.isCritical,
    required this.isTacticalCandidate,
    required this.hasMateWarning,
    required this.warnings,
    this.san,
    this.uci,
    this.cpLoss,
    this.expectedPointsLoss,
    this.beforeFen,
    this.afterFen,
    this.engineBestMove,
    this.playedMatchesEngineBest,
    this.betterMove,
    this.engineLine,
  });

  final int ply;
  final int moveNumber;
  final String side;
  final String? san;
  final String? uci;
  final OnlineReviewMoveQuality quality;
  final OnlineReviewConfidence confidence;
  final int? cpLoss;
  final double? expectedPointsLoss;
  final String? beforeFen;
  final String? afterFen;
  final String? engineBestMove;
  final bool? playedMatchesEngineBest;
  final OnlineReviewBetterMoveDto? betterMove;
  final OnlineReviewEngineLineDto? engineLine;
  final OnlineReviewCriticalityLevel criticalityLevel;
  final bool isCritical;
  final bool isTacticalCandidate;
  final bool hasMateWarning;
  final List<String> warnings;

  bool get hasBetterMove => betterMove?.moveUci != null;

  bool get hasEngineLine => engineLine != null;

  bool get isCriticalOrTactical => isCritical || isTacticalCandidate;

  bool get hasWarnings => warnings.isNotEmpty;

  factory OnlineReviewMoveDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewMoveDto(
      ply: _requiredInt(json, 'ply'),
      moveNumber: _requiredInt(json, 'moveNumber'),
      side: _requiredString(json, 'side'),
      san: _nullableString(json['san']),
      uci: _nullableString(json['uci']),
      quality: OnlineReviewMoveQuality.fromJson(
        _requiredValue(json, 'quality'),
      ),
      confidence: OnlineReviewConfidence.fromJson(
        _requiredValue(json, 'confidence'),
      ),
      cpLoss: _nullableInt(json['cpLoss']),
      expectedPointsLoss: _nullableDouble(json['expectedPointsLoss']),
      beforeFen: _nullableString(json['beforeFen']),
      afterFen: _nullableString(json['afterFen']),
      engineBestMove: _nullableString(json['engineBestMove']),
      playedMatchesEngineBest: _nullableBool(json['playedMatchesEngineBest']),
      betterMove: _nullableMap(json['betterMove']) == null
          ? null
          : OnlineReviewBetterMoveDto.fromJson(
              _nullableMap(json['betterMove'])!,
            ),
      engineLine: _nullableMap(json['engineLine']) == null
          ? null
          : OnlineReviewEngineLineDto.fromJson(
              _nullableMap(json['engineLine'])!,
            ),
      criticalityLevel: OnlineReviewCriticalityLevel.fromJson(
        _requiredValue(json, 'criticalityLevel'),
      ),
      isCritical: _requiredBool(json, 'isCritical'),
      isTacticalCandidate: _requiredBool(json, 'isTacticalCandidate'),
      hasMateWarning: _requiredBool(json, 'hasMateWarning'),
      warnings: _stringList(_requiredList(json, 'warnings')),
    );
  }

  Map<String, Object?> toJson() => {
    'ply': ply,
    'moveNumber': moveNumber,
    'side': side,
    'san': san,
    'uci': uci,
    'quality': quality.wire,
    'confidence': confidence.wire,
    'cpLoss': cpLoss,
    'expectedPointsLoss': expectedPointsLoss,
    'beforeFen': beforeFen,
    'afterFen': afterFen,
    'engineBestMove': engineBestMove,
    'playedMatchesEngineBest': playedMatchesEngineBest,
    'betterMove': betterMove?.toJson(),
    'engineLine': engineLine?.toJson(),
    'criticalityLevel': criticalityLevel.wire,
    'isCritical': isCritical,
    'isTacticalCandidate': isTacticalCandidate,
    'hasMateWarning': hasMateWarning,
    'warnings': warnings,
  };
}

class OnlineReviewBetterMoveDto {
  const OnlineReviewBetterMoveDto({
    required this.source,
    required this.confidence,
    this.moveUci,
    this.san,
  });

  final String? moveUci;
  final String? san;
  final String source;
  final OnlineReviewConfidence confidence;

  factory OnlineReviewBetterMoveDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewBetterMoveDto(
      moveUci: _nullableString(json['moveUci']),
      san: _nullableString(json['san']),
      source: _requiredString(json, 'source'),
      confidence: OnlineReviewConfidence.fromJson(
        _requiredValue(json, 'confidence'),
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'moveUci': moveUci,
    'san': san,
    'source': source,
    'confidence': confidence.wire,
  };
}

class OnlineReviewEngineLineDto {
  const OnlineReviewEngineLineDto({
    required this.pv,
    required this.multiPvCount,
    this.depth,
    this.bestMoveUci,
    this.score,
  });

  final int? depth;
  final String? bestMoveUci;
  final List<String> pv;
  final OnlineReviewScoreDto? score;
  final int multiPvCount;

  factory OnlineReviewEngineLineDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewEngineLineDto(
      depth: _nullableInt(json['depth']),
      bestMoveUci: _nullableString(json['bestMoveUci']),
      pv: _stringList(_requiredList(json, 'pv')),
      score: _nullableMap(json['score']) == null
          ? null
          : OnlineReviewScoreDto.fromJson(_nullableMap(json['score'])!),
      multiPvCount: _requiredInt(json, 'multiPvCount'),
    );
  }

  Map<String, Object?> toJson() => {
    'depth': depth,
    'bestMoveUci': bestMoveUci,
    'pv': pv,
    'score': score?.toJson(),
    'multiPvCount': multiPvCount,
  };
}

class OnlineReviewScoreDto {
  const OnlineReviewScoreDto({
    required this.scoreType,
    this.value,
    this.whiteCentipawns,
    this.moverCentipawns,
    this.mate,
  });

  final String scoreType;
  final int? value;
  final int? whiteCentipawns;
  final int? moverCentipawns;
  final int? mate;

  factory OnlineReviewScoreDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewScoreDto(
      scoreType: _requiredString(json, 'scoreType'),
      value: _nullableInt(json['value']),
      whiteCentipawns: _nullableInt(json['whiteCentipawns']),
      moverCentipawns: _nullableInt(json['moverCentipawns']),
      mate: _nullableInt(json['mate']),
    );
  }

  Map<String, Object?> toJson() => {
    'scoreType': scoreType,
    'value': value,
    'whiteCentipawns': whiteCentipawns,
    'moverCentipawns': moverCentipawns,
    'mate': mate,
  };
}

class OnlineReviewProviderMetadataDto {
  const OnlineReviewProviderMetadataDto({
    required this.provider,
    required this.engine,
    required this.analysisVersion,
    required this.classifierVersion,
    required this.productContractVersion,
    required this.mode,
    required this.targetDepthTier,
    required this.isExecutionHintOnly,
  });

  final String provider;
  final String engine;
  final String analysisVersion;
  final String classifierVersion;
  final String productContractVersion;
  final OnlineReviewMode mode;
  final String targetDepthTier;
  final bool isExecutionHintOnly;

  factory OnlineReviewProviderMetadataDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewProviderMetadataDto(
      provider: _requiredString(json, 'provider'),
      engine: _requiredString(json, 'engine'),
      analysisVersion: _requiredString(json, 'analysisVersion'),
      classifierVersion: _requiredString(json, 'classifierVersion'),
      productContractVersion: _requiredString(json, 'productContractVersion'),
      mode: OnlineReviewMode.fromJson(_requiredValue(json, 'mode')),
      targetDepthTier: _requiredString(json, 'targetDepthTier'),
      isExecutionHintOnly: _requiredBool(json, 'isExecutionHintOnly'),
    );
  }

  Map<String, Object?> toJson() => {
    'provider': provider,
    'engine': engine,
    'analysisVersion': analysisVersion,
    'classifierVersion': classifierVersion,
    'productContractVersion': productContractVersion,
    'mode': mode.wire,
    'targetDepthTier': targetDepthTier,
    'isExecutionHintOnly': isExecutionHintOnly,
  };
}

class OnlineReviewDebugEnvelopeDto {
  const OnlineReviewDebugEnvelopeDto({
    required this.enabled,
    required this.sourceEndpoint,
    required this.omittedInternalSections,
    this.internalGameKey,
    this.internalSafetySummary,
  });

  final bool enabled;
  final String sourceEndpoint;
  final String? internalGameKey;
  final List<String> omittedInternalSections;
  final OnlineReviewInternalSafetySummaryDto? internalSafetySummary;

  factory OnlineReviewDebugEnvelopeDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewDebugEnvelopeDto(
      enabled: _requiredBool(json, 'enabled'),
      sourceEndpoint: _requiredString(json, 'sourceEndpoint'),
      internalGameKey: _nullableString(json['internalGameKey']),
      omittedInternalSections: _stringList(
        _requiredList(json, 'omittedInternalSections'),
      ),
      internalSafetySummary: _nullableMap(json['internalSafetySummary']) == null
          ? null
          : OnlineReviewInternalSafetySummaryDto.fromJson(
              _nullableMap(json['internalSafetySummary'])!,
            ),
    );
  }

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'sourceEndpoint': sourceEndpoint,
    'internalGameKey': internalGameKey,
    'omittedInternalSections': omittedInternalSections,
    'internalSafetySummary': internalSafetySummary?.toJson(),
  };
}

class OnlineReviewInternalSafetySummaryDto {
  const OnlineReviewInternalSafetySummaryDto({
    required this.reviewDraftOk,
    required this.moveCount,
    required this.failedMoves,
    required this.classifierVersion,
    required this.ledgerPersistent,
    required this.runtimeMigrationReady,
  });

  final bool reviewDraftOk;
  final int moveCount;
  final int failedMoves;
  final String classifierVersion;
  final bool ledgerPersistent;
  final bool runtimeMigrationReady;

  factory OnlineReviewInternalSafetySummaryDto.fromJson(
    Map<String, Object?> json,
  ) {
    return OnlineReviewInternalSafetySummaryDto(
      reviewDraftOk: _requiredBool(json, 'reviewDraftOk'),
      moveCount: _requiredInt(json, 'moveCount'),
      failedMoves: _requiredInt(json, 'failedMoves'),
      classifierVersion: _requiredString(json, 'classifierVersion'),
      ledgerPersistent: _requiredBool(json, 'ledgerPersistent'),
      runtimeMigrationReady: _requiredBool(json, 'runtimeMigrationReady'),
    );
  }

  Map<String, Object?> toJson() => {
    'reviewDraftOk': reviewDraftOk,
    'moveCount': moveCount,
    'failedMoves': failedMoves,
    'classifierVersion': classifierVersion,
    'ledgerPersistent': ledgerPersistent,
    'runtimeMigrationReady': runtimeMigrationReady,
  };
}

class OnlineReviewErrorDto {
  const OnlineReviewErrorDto({required this.code, required this.message});

  final String code;
  final String message;

  factory OnlineReviewErrorDto.fromJson(Map<String, Object?> json) {
    return OnlineReviewErrorDto(
      code: _requiredString(json, 'code'),
      message: _requiredString(json, 'message'),
    );
  }

  Map<String, Object?> toJson() => {'code': code, 'message': message};
}

Object? _requiredValue(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) {
    throw FormatException('Missing required online review field: $key');
  }
  return json[key];
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = _requiredValue(json, key);
  if (value is String) return value;
  throw FormatException('Expected string for online review field: $key');
}

bool _requiredBool(Map<String, Object?> json, String key) {
  final value = _requiredValue(json, key);
  if (value is bool) return value;
  throw FormatException('Expected bool for online review field: $key');
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = _requiredValue(json, key);
  if (value is int) return value;
  if (value is num && value % 1 == 0) return value.toInt();
  throw FormatException('Expected int for online review field: $key');
}

Map<String, Object?> _requiredMap(Map<String, Object?> json, String key) {
  return _mapFromObject(_requiredValue(json, key));
}

List<Object?> _requiredList(Map<String, Object?> json, String key) {
  final value = _requiredValue(json, key);
  if (value is List) return value.cast<Object?>();
  throw FormatException('Expected list for online review field: $key');
}

Map<String, Object?> _mapFromObject(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const FormatException('Expected object for online review field');
}

Map<String, Object?>? _nullableMap(Object? value) {
  if (value == null) return null;
  return _mapFromObject(value);
}

String? _nullableString(Object? value) => value?.toString();

bool? _nullableBool(Object? value) => value is bool ? value : null;

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num && value % 1 == 0) return value.toInt();
  return null;
}

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return null;
}

List<String> _stringList(List<Object?> values) {
  return [
    for (final value in values)
      if (value != null) value.toString(),
  ];
}

Map<String, int> _stringIntMap(Map<String, Object?> json) {
  return {
    for (final entry in json.entries)
      entry.key: (entry.value is num) ? (entry.value! as num).toInt() : 0,
  };
}
