library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';

const int kReviewDocumentSchemaVersion = 1;
const int kReviewAggregateCacheVersion = 1;

enum ReviewDocumentStatus { complete, failed, cancelled, partial, unavailable }

enum AnalyzedPlayerPerspective { white, black, both, unknown }

class ReviewDocumentValidationException implements Exception {
  const ReviewDocumentValidationException(this.message);

  final String message;

  @override
  String toString() => 'ReviewDocumentValidationException: $message';
}

class AnalysisRunProvenance {
  const AnalysisRunProvenance({
    required this.runId,
    required this.completedAt,
    required this.achievedDepth,
    required this.achievedNodes,
    required this.achievedElapsedMs,
    required this.engineSearchCount,
    required this.engineCacheHitCount,
    required this.terminationComplete,
  });

  final String runId;
  final DateTime completedAt;
  final int? achievedDepth;
  final int? achievedNodes;
  final int? achievedElapsedMs;
  final int engineSearchCount;
  final int engineCacheHitCount;
  final bool terminationComplete;

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'completedAt': completedAt.toUtc().toIso8601String(),
    'achievedDepth': achievedDepth,
    'achievedNodes': achievedNodes,
    'achievedElapsedMs': achievedElapsedMs,
    'engineSearchCount': engineSearchCount,
    'engineCacheHitCount': engineCacheHitCount,
    'terminationComplete': terminationComplete,
  };

  factory AnalysisRunProvenance.fromJson(Map<dynamic, dynamic> json) =>
      AnalysisRunProvenance(
        runId: json['runId'] as String,
        completedAt: DateTime.parse(json['completedAt'] as String).toUtc(),
        achievedDepth: (json['achievedDepth'] as num?)?.toInt(),
        achievedNodes: (json['achievedNodes'] as num?)?.toInt(),
        achievedElapsedMs: (json['achievedElapsedMs'] as num?)?.toInt(),
        engineSearchCount: (json['engineSearchCount'] as num).toInt(),
        engineCacheHitCount: (json['engineCacheHitCount'] as num).toInt(),
        terminationComplete: json['terminationComplete'] as bool,
      );
}

class ReviewDocument {
  const ReviewDocument({
    required this.schemaVersion,
    required this.documentId,
    required this.game,
    required this.variantId,
    required this.compatibility,
    required this.run,
    required this.createdAt,
    required this.status,
    required this.analyzedPerspective,
    required this.timeline,
  });

  final int schemaVersion;
  final String documentId;
  final CanonicalGame game;
  final AnalysisVariantId variantId;
  final AnalysisCompatibility compatibility;
  final AnalysisRunProvenance run;
  final DateTime createdAt;
  final ReviewDocumentStatus status;
  final AnalyzedPlayerPerspective analyzedPerspective;
  final AnalysisTimeline timeline;

  bool get isTrustedComplete =>
      status == ReviewDocumentStatus.complete &&
      run.terminationComplete &&
      timeline.isComplete;

  bool? get userIsWhite => switch (analyzedPerspective) {
    AnalyzedPlayerPerspective.white => true,
    AnalyzedPlayerPerspective.black => false,
    AnalyzedPlayerPerspective.both || AnalyzedPlayerPerspective.unknown => null,
  };

  int get cpLossEligibleCount => timeline.cpLossEligibleCount;
  double? get verifiedAcpl =>
      timeline.hasVerifiedCpLoss ? timeline.averageCpLoss : null;
  Map<MoveQuality, int> get classificationCounts => timeline.qualityCounts;
  int get bookCount => timeline.moves.where((move) => move.inBook).length;
  int get unavailableCount => timeline.moves
      .where((move) => !move.engineEvaluationAvailable && !move.inBook)
      .length;

  /// A rerun may replace the exact same variant only when every persisted
  /// trust/evidence dimension is equal or stronger. Timestamps, search counts,
  /// cache hits, and display labels are deliberately excluded from strength.
  bool hasEqualOrStrongerEvidenceThan(ReviewDocument existing) {
    if (documentId != existing.documentId ||
        variantId.value != existing.variantId.value ||
        game.gameId.value != existing.game.gameId.value ||
        !isTrustedComplete ||
        !existing.isTrustedComplete) {
      return false;
    }
    final candidate = _evidenceDimensions;
    final current = existing._evidenceDimensions;
    for (var index = 0; index < candidate.length; index++) {
      if (candidate[index] < current[index]) return false;
    }
    return true;
  }

  List<int> get _evidenceDimensions {
    final evaluated = timeline.moves
        .where((move) => move.engineEvaluationAvailable && !move.inBook)
        .toList(growable: false);
    final requestedMultiPv = compatibility.searchPolicy.multiPv ?? 1;
    var multiPvCompletePlies = 0;
    var alternativeLineCount = 0;
    var scoredPlies = 0;
    var cpLossPlies = 0;
    var searchQualityPlies = 0;
    var minimumMultiPvReceived = evaluated.isEmpty ? 0 : 1 << 30;
    var achievedDepthFloor = evaluated.isEmpty ? 0 : 1 << 30;
    for (final move in evaluated) {
      final distinctRoots = move.engineLines
          .map((line) => line.moveUci)
          .whereType<String>()
          .where((root) => root.isNotEmpty)
          .toSet()
          .length;
      alternativeLineCount += distinctRoots;
      minimumMultiPvReceived = _min(
        minimumMultiPvReceived,
        move.multiPvReceived,
      );
      if (move.searchQualityMet) searchQualityPlies++;
      if (move.scoreCpAfter != null || move.mateInAfter != null) scoredPlies++;
      if (move.moverCpLoss != null) cpLossPlies++;
      final beforeDepth = move.achievedDepthBefore ?? 0;
      final afterDepth = move.achievedDepthAfter ?? 0;
      achievedDepthFloor = _min(
        achievedDepthFloor,
        _min(beforeDepth, afterDepth),
      );
      final alternativesComplete = requestedMultiPv <= 1
          ? move.multiPvReceived >= 1 || move.searchQualityMet
          : move.multiPvReceived >= requestedMultiPv &&
                distinctRoots >= requestedMultiPv;
      if (alternativesComplete) multiPvCompletePlies++;
    }
    return <int>[
      compatibility.engine.identityVerification.index,
      compatibility.engine.nnueVerification.index,
      run.achievedDepth ?? 0,
      run.achievedNodes ?? 0,
      evaluated.length,
      searchQualityPlies,
      multiPvCompletePlies,
      minimumMultiPvReceived,
      alternativeLineCount,
      achievedDepthFloor,
      scoredPlies,
      cpLossPlies,
    ];
  }

  factory ReviewDocument.fromCompletedTimeline({
    required String pgn,
    required AnalysisTimeline timeline,
    required String sourceProvider,
    String? sourceGameId,
    DateTime? importedAt,
    bool? userIsWhite,
    DateTime? createdAt,
    String? timeControl,
  }) {
    if (!timeline.isComplete) {
      throw const ReviewDocumentValidationException(
        'Only a complete timeline can create a trusted review document.',
      );
    }
    final game = const CanonicalGameIdentityService().fromPgn(
      pgn: pgn,
      sourceProvider: sourceProvider,
      sourceGameId: sourceGameId,
      importedAt: importedAt,
      supplementalHeaders: {
        if (timeControl != null && timeControl.trim().isNotEmpty)
          'TimeControl': timeControl.trim(),
      },
    );
    final compatibility = AnalysisCompatibility.fromTimeline(
      gameId: game.gameId,
      timeline: timeline,
    );
    final variantId = AnalysisVariantId.fromCompatibility(compatibility);
    final completedAt = (timeline.completedAt ?? createdAt ?? DateTime.now())
        .toUtc();
    final runMaterial = [
      variantId.value,
      completedAt.toIso8601String(),
      timeline.cacheKey ?? 'no-cache-key',
      timeline.engineSearchCount,
      timeline.engineCacheHitCount,
    ].join('|');
    final runId = sha256.convert(utf8.encode(runMaterial)).toString();
    final documentMaterial =
        '${game.gameId.value}|${variantId.value}|$kReviewDocumentSchemaVersion';
    final document = ReviewDocument(
      schemaVersion: kReviewDocumentSchemaVersion,
      documentId:
          'review_${sha256.convert(utf8.encode(documentMaterial)).toString()}',
      game: game,
      variantId: variantId,
      compatibility: compatibility,
      run: AnalysisRunProvenance(
        runId: runId,
        completedAt: completedAt,
        achievedDepth: timeline.depth,
        achievedNodes: null,
        achievedElapsedMs: null,
        engineSearchCount: timeline.engineSearchCount,
        engineCacheHitCount: timeline.engineCacheHitCount,
        terminationComplete: timeline.isComplete,
      ),
      createdAt: (createdAt ?? completedAt).toUtc(),
      status: ReviewDocumentStatus.complete,
      analyzedPerspective: userIsWhite == null
          ? AnalyzedPlayerPerspective.unknown
          : userIsWhite
          ? AnalyzedPlayerPerspective.white
          : AnalyzedPlayerPerspective.black,
      timeline: timeline,
    );
    document.validate();
    return document;
  }

  void validate() {
    if (schemaVersion != kReviewDocumentSchemaVersion) {
      throw ReviewDocumentValidationException(
        'Unsupported review document schema $schemaVersion.',
      );
    }
    if (!isTrustedComplete) {
      throw const ReviewDocumentValidationException(
        'Trusted saved reviews must be complete.',
      );
    }
    if (game.gameId.algorithmVersion != kGameIdAlgorithmVersion ||
        variantId.algorithmVersion != kAnalysisVariantAlgorithmVersion) {
      throw const ReviewDocumentValidationException(
        'Unsupported identity algorithm version.',
      );
    }
    final expectedGameId = sha256
        .convert(utf8.encode(game.canonicalIdentityMaterial))
        .toString();
    if (game.gameId.value != expectedGameId) {
      throw const ReviewDocumentValidationException('Invalid GameId.');
    }
    final reparsedGame = const CanonicalGameIdentityService().fromPgn(
      pgn: game.originalPgn,
      sourceProvider: game.sourceProvider,
      sourceGameId: game.sourceGameId,
      importedAt: game.importedAt,
    );
    if (reparsedGame.gameId.value != game.gameId.value ||
        reparsedGame.moves.length != game.moves.length) {
      throw const ReviewDocumentValidationException(
        'Preserved PGN does not match the canonical game.',
      );
    }
    for (var index = 0; index < game.moves.length; index++) {
      final reparsed = reparsedGame.moves[index];
      final stored = game.moves[index];
      if (reparsed.ply != stored.ply ||
          reparsed.san != stored.san ||
          reparsed.uci != stored.uci ||
          reparsed.fenBefore != stored.fenBefore ||
          reparsed.fenAfter != stored.fenAfter) {
        throw ReviewDocumentValidationException(
          'Preserved PGN move mismatch at ply $index.',
        );
      }
    }
    if (compatibility.gameId.value != game.gameId.value ||
        compatibility.gameId.algorithmVersion != game.gameId.algorithmVersion) {
      throw const ReviewDocumentValidationException(
        'Variant compatibility references a different game.',
      );
    }
    final expectedVariant = AnalysisVariantId.fromCompatibility(compatibility);
    if (variantId.value != expectedVariant.value) {
      throw const ReviewDocumentValidationException(
        'Invalid AnalysisVariantId.',
      );
    }
    final expectedDocumentMaterial =
        '${game.gameId.value}|${variantId.value}|$schemaVersion';
    final expectedDocumentId =
        'review_${sha256.convert(utf8.encode(expectedDocumentMaterial)).toString()}';
    if (documentId != expectedDocumentId) {
      throw const ReviewDocumentValidationException('Invalid document id.');
    }
    if (timeline.startingFen != game.startingFen ||
        timeline.moves.length != game.moves.length ||
        timeline.expectedPlies != game.moves.length ||
        timeline.winPercentages.length != game.moves.length) {
      throw const ReviewDocumentValidationException(
        'Timeline does not match canonical game length or starting FEN.',
      );
    }
    for (var index = 0; index < game.moves.length; index++) {
      final canonical = game.moves[index];
      final analyzed = timeline.moves[index];
      if (canonical.ply != index ||
          analyzed.ply != index ||
          canonical.san != analyzed.san ||
          canonical.uci != analyzed.uci ||
          canonical.fenBefore != analyzed.fenBefore ||
          canonical.fenAfter != analyzed.fenAfter) {
        throw ReviewDocumentValidationException(
          'Move continuity mismatch at ply $index.',
        );
      }
      if (index > 0 && game.moves[index - 1].fenAfter != canonical.fenBefore) {
        throw ReviewDocumentValidationException(
          'Broken FEN continuity at ply $index.',
        );
      }
    }
    if (timeline.classifierVersion != compatibility.classifierVersion ||
        timeline.tacticalVerifierVersion !=
            compatibility.tacticalVerifierVersion ||
        timeline.openingBookVersion != compatibility.openingBookVersion ||
        timeline.analysisSchemaVersion != compatibility.analysisSchemaVersion ||
        timeline.analysisProfileId != compatibility.profileId ||
        timeline.providerId != compatibility.providerId ||
        timeline.engineVersion != compatibility.engine.declaredIdentity ||
        timeline.requestedDepth != compatibility.searchPolicy.requestedDepth ||
        timeline.movetimeMs != compatibility.searchPolicy.requestedMovetimeMs ||
        timeline.multipv != compatibility.searchPolicy.multiPv ||
        timeline.candidateVerificationEnabled !=
            compatibility.searchPolicy.candidateVerificationEnabled) {
      throw const ReviewDocumentValidationException(
        'Timeline provenance does not match variant compatibility.',
      );
    }
    final expectedRunMaterial = [
      variantId.value,
      run.completedAt.toIso8601String(),
      timeline.cacheKey ?? 'no-cache-key',
      timeline.engineSearchCount,
      timeline.engineCacheHitCount,
    ].join('|');
    final expectedRunId = sha256
        .convert(utf8.encode(expectedRunMaterial))
        .toString();
    if (run.runId != expectedRunId ||
        run.achievedDepth != timeline.depth ||
        run.engineSearchCount != timeline.engineSearchCount ||
        run.engineCacheHitCount != timeline.engineCacheHitCount) {
      throw const ReviewDocumentValidationException(
        'Analysis run provenance does not match the timeline.',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'documentId': documentId,
    'game': game.toJson(),
    'variantId': variantId.toJson(),
    'compatibility': compatibility.toJson(),
    'run': run.toJson(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'status': status.name,
    'analyzedPerspective': analyzedPerspective.name,
    'timeline': timeline.toJson(),
  };

  factory ReviewDocument.fromJson(Map<dynamic, dynamic> json) => ReviewDocument(
    schemaVersion: (json['schemaVersion'] as num).toInt(),
    documentId: json['documentId'] as String,
    game: CanonicalGame.fromJson(json['game'] as Map),
    variantId: AnalysisVariantId.fromJson(json['variantId'] as Map),
    compatibility: AnalysisCompatibility.fromJson(json['compatibility'] as Map),
    run: AnalysisRunProvenance.fromJson(json['run'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    status: _enumByName(
      ReviewDocumentStatus.values,
      json['status'],
      ReviewDocumentStatus.unavailable,
    ),
    analyzedPerspective: _enumByName(
      AnalyzedPlayerPerspective.values,
      json['analyzedPerspective'],
      AnalyzedPlayerPerspective.unknown,
    ),
    timeline: AnalysisTimeline.fromJson(json['timeline'] as Map),
  );

  String encode() => jsonEncode(toJson());

  factory ReviewDocument.decodeAndValidate(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const ReviewDocumentValidationException(
        'Review document root must be an object.',
      );
    }
    final document = ReviewDocument.fromJson(decoded);
    document.validate();
    return document;
  }
}

int _min(int a, int b) => a < b ? a : b;

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return fallback;
}
