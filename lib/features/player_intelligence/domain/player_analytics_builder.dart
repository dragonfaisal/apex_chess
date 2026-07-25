library;

import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_coaching_priority_engine.dart';

class PlayerAnalyticsBuildInput {
  const PlayerAnalyticsBuildInput({
    required this.documents,
    required this.playerIdentityScope,
    this.analysisDigests = const {},
    this.sourceExclusions = const [],
  });

  final List<ReviewDocument> documents;
  final String playerIdentityScope;
  final Map<String, String> analysisDigests;
  final List<PlayerAnalyticsExclusion> sourceExclusions;
}

class PlayerAnalyticsBuilder {
  const PlayerAnalyticsBuilder({
    this.policy = const PlayerAnalyticsPolicy(),
    this.coachingEngine = const PlayerCoachingPriorityEngine(),
  });

  final PlayerAnalyticsPolicy policy;
  final PlayerCoachingPriorityEngine coachingEngine;

  PlayerAnalyticsSnapshot build(PlayerAnalyticsBuildInput input) {
    final selectionWatch = Stopwatch()..start();
    final selection = _selectCanonicalGames(input);
    selectionWatch.stop();

    final manifestWatch = Stopwatch()..start();
    final manifest = _buildManifest(
      playerIdentityScope: input.playerIdentityScope,
      selectedGames: selection.games,
      exclusions: selection.exclusions,
    );
    manifestWatch.stop();

    final aggregationWatch = Stopwatch()..start();
    final base = _aggregate(
      manifest,
      distinctSavedGames: selection.distinctSavedGames,
      inputBytes: input.documents.fold<int>(
        0,
        (sum, document) => sum + utf8.encode(document.encode()).length,
      ),
      selectionMicros: selectionWatch.elapsedMicroseconds,
      manifestMicros: manifestWatch.elapsedMicroseconds,
    );
    aggregationWatch.stop();
    final withAggregationTiming = base.copyWith(
      performance: PlayerAnalyticsPerformance(
        manifestMicros: manifestWatch.elapsedMicroseconds,
        selectionMicros: selectionWatch.elapsedMicroseconds,
        aggregationMicros: aggregationWatch.elapsedMicroseconds,
        inputBytes: base.performance.inputBytes,
      ),
    );

    final priorityWatch = Stopwatch()..start();
    final result = coachingEngine.apply(withAggregationTiming, policy: policy);
    priorityWatch.stop();
    return result.copyWith(
      performance: PlayerAnalyticsPerformance(
        manifestMicros: result.performance.manifestMicros,
        selectionMicros: result.performance.selectionMicros,
        aggregationMicros: result.performance.aggregationMicros,
        priorityMicros: priorityWatch.elapsedMicroseconds,
        inputBytes: result.performance.inputBytes,
      ),
    );
  }

  _CanonicalSelection _selectCanonicalGames(PlayerAnalyticsBuildInput input) {
    final exclusions = [...input.sourceExclusions];
    final byGame = <String, List<ReviewDocument>>{};
    final validGameIds = <String>{};
    final seenDocumentIds = <String>{};
    for (final document in input.documents) {
      final gameId = document.game.gameId.value;
      if (!_gameIdPattern.hasMatch(gameId)) {
        exclusions.add(
          PlayerAnalyticsExclusion(
            reason: PlayerAnalyticsExclusionReason.invalidGameId,
            detail: 'GameId is not a canonical SHA-256 identity.',
            gameId: gameId,
            variantId: document.variantId.value,
            documentId: document.documentId,
          ),
        );
        continue;
      }
      validGameIds.add(gameId);
      if (!seenDocumentIds.add(document.documentId)) {
        continue;
      }
      byGame.putIfAbsent(gameId, () => []).add(document);
    }

    final selected = <CanonicalAnalyzedGame>[];
    final sortedGameIds = byGame.keys.toList()..sort();
    for (final gameId in sortedGameIds) {
      final candidates = byGame[gameId]!;
      final knownSides = candidates
          .where((document) => document.userIsWhite != null)
          .map((document) => document.userIsWhite!)
          .toSet();
      if (knownSides.length > 1) {
        exclusions.add(
          PlayerAnalyticsExclusion(
            reason: PlayerAnalyticsExclusionReason.corruptOrUnavailable,
            detail:
                'Sibling variants contradict the immutable analyzed-player side.',
            gameId: gameId,
          ),
        );
        continue;
      }

      final eligible = <ReviewDocument>[];
      for (final document in candidates) {
        if (!document.isTrustedComplete) {
          exclusions.add(
            _documentExclusion(
              document,
              PlayerAnalyticsExclusionReason.incompleteDocument,
              'ReviewDocument is not complete and trusted.',
            ),
          );
          continue;
        }
        if (document.userIsWhite == null) {
          exclusions.add(
            _documentExclusion(
              document,
              PlayerAnalyticsExclusionReason.unknownPlayerSide,
              'Analyzed-player side is unknown and was not guessed.',
            ),
          );
          continue;
        }
        if (document.timeline.analysisSchemaVersion < 4 ||
            document.timeline.analysisSchemaVersion >
                kApexAnalysisSchemaVersion) {
          exclusions.add(
            _documentExclusion(
              document,
              PlayerAnalyticsExclusionReason.corruptOrUnavailable,
              'Analysis schema is outside the bounded 4/5/6 analytics contract.',
            ),
          );
          continue;
        }
        eligible.add(document);
      }
      if (eligible.isEmpty) continue;
      eligible.sort(_compareDocumentStrength);
      final winner = eligible.first;
      final siblingVariants = eligible
          .skip(1)
          .map((document) => document.variantId.value)
          .toList(growable: false);
      for (final sibling in eligible.skip(1)) {
        exclusions.add(
          _documentExclusion(
            sibling,
            PlayerAnalyticsExclusionReason.duplicateGameVariant,
            'A stronger deterministic sibling variant represents this GameId.',
          ),
        );
      }
      selected.add(
        CanonicalAnalyzedGame(
          document: winner,
          analysisDigest:
              input.analysisDigests[winner.documentId] ??
              _digestCanonicalJson(winner.toJson()),
          playerIsWhite: winner.userIsWhite!,
          orderTimestamp: winner.run.completedAt.toUtc(),
          selectionReason: _selectionReason(winner),
          excludedVariantIds: siblingVariants,
        ),
      );
    }
    selected.sort((a, b) => a.gameId.compareTo(b.gameId));
    exclusions.sort(_compareExclusion);
    return _CanonicalSelection(
      games: List.unmodifiable(selected),
      exclusions: List.unmodifiable(exclusions),
      distinctSavedGames: validGameIds.length,
    );
  }

  PlayerAnalyticsManifest _buildManifest({
    required String playerIdentityScope,
    required List<CanonicalAnalyzedGame> selectedGames,
    required List<PlayerAnalyticsExclusion> exclusions,
  }) {
    final fields = <String>[
      _lengthPrefixed('analyticsPolicy', policy.policyVersion.toString()),
      _lengthPrefixed('analyticsSchema', policy.schemaVersion.toString()),
      _lengthPrefixed('playerScope', playerIdentityScope.trim().toLowerCase()),
      for (final game in selectedGames) ...[
        _lengthPrefixed('gameId', game.gameId),
        _lengthPrefixed('variantId', game.variantId),
        _lengthPrefixed('documentId', game.documentId),
        _lengthPrefixed('analysisDigest', game.analysisDigest),
        _lengthPrefixed('reviewSchema', game.document.schemaVersion.toString()),
        _lengthPrefixed(
          'analysisSchema',
          game.document.timeline.analysisSchemaVersion.toString(),
        ),
        _lengthPrefixed('playerSide', game.playerIsWhite ? 'white' : 'black'),
        _lengthPrefixed(
          'orderTimestamp',
          game.orderTimestamp.toUtc().toIso8601String(),
        ),
      ],
      for (final exclusion in exclusions)
        _lengthPrefixed(
          'exclusion',
          [
            exclusion.reason.name,
            exclusion.gameId ?? '',
            exclusion.variantId ?? '',
            exclusion.documentId ?? '',
            exclusion.detail,
          ].join('|'),
        ),
    ];
    final material = '${fields.join('\n')}\n';
    return PlayerAnalyticsManifest(
      policyVersion: policy.policyVersion,
      schemaVersion: policy.schemaVersion,
      playerIdentityScope: playerIdentityScope,
      selectedGames: List.unmodifiable(selectedGames),
      exclusions: List.unmodifiable(exclusions),
      snapshotId: sha256.convert(utf8.encode(material)).toString(),
      canonicalMaterial: material,
    );
  }

  PlayerAnalyticsSnapshot _aggregate(
    PlayerAnalyticsManifest manifest, {
    required int distinctSavedGames,
    required int inputBytes,
    required int selectionMicros,
    required int manifestMicros,
  }) {
    final classificationCounts = {
      for (final quality in MoveQuality.values) quality: 0,
    };
    final criticalCounts = {
      'inaccuracy': 0,
      'mistake': 0,
      'blunder': 0,
      'missedWin': 0,
    };
    final mate = <String, _EventAccumulator>{
      'deliveredForcedMate': _EventAccumulator(),
      'preservedForcedMate': _EventAccumulator(),
      'allowedForcedMate': _EventAccumulator(),
      'missedForcedMate': _EventAccumulator(),
      'onlyMovePreventingMate': _EventAccumulator(),
    };
    final material = <String, _EventAccumulator>{
      'droppedMaterial': _EventAccumulator(),
      'wonMaterial': _EventAccumulator(),
      'missedMaterialResource': _EventAccumulator(),
      'soundSacrifice': _EventAccumulator(),
      'unsoundSacrifice': _EventAccumulator(),
    };
    final mechanisms = {
      for (final mechanism in MoveInsightMechanismType.values)
        if (mechanism != MoveInsightMechanismType.none)
          mechanism: _EventAccumulator(),
    };
    final openingAccumulators = <String, _OpeningAccumulator>{};
    final allExamples = <String, PlayerAnalyticsExample>{};
    final gameFacts = <_GameFacts>[];
    var totalPlayerMoves = 0;
    var classificationEligibleMoves = 0;
    var classificationExcludedMoves = 0;
    var insightEligibleMoves = 0;
    var openingEligibleGames = 0;
    var gamesWithBlunder = 0;

    for (final game in manifest.selectedGames) {
      final timeline = game.document.timeline;
      final playerMoves = timeline.moves
          .where((move) => move.isWhiteMove == game.playerIsWhite)
          .toList(growable: false);
      totalPlayerMoves += playerMoves.length;
      final classificationPolicyCompatible =
          timeline.classifierVersion == kApexClassifierVersion &&
          timeline.analysisSchemaVersion >= 4;
      var gameEligibleMoves = 0;
      var gameCriticalErrors = 0;
      var gameBlunders = 0;

      for (final move in playerMoves) {
        final classificationEligible =
            classificationPolicyCompatible &&
            move.classification != MoveQuality.unavailable &&
            move.classificationEvidence != null;
        if (classificationEligible) {
          classificationEligibleMoves++;
          gameEligibleMoves++;
          classificationCounts[move.classification] =
              classificationCounts[move.classification]! + 1;
          final bucket = _criticalBucket(move.classification);
          if (bucket != null) {
            criticalCounts[bucket] = criticalCounts[bucket]! + 1;
            gameCriticalErrors++;
            if (bucket == 'blunder') gameBlunders++;
          }
        } else {
          classificationExcludedMoves++;
          if (move.classification == MoveQuality.unavailable) {
            classificationCounts[MoveQuality.unavailable] =
                classificationCounts[MoveQuality.unavailable]! + 1;
          }
        }

        final insightContractEligible =
            timeline.hasSupportedExplanationContract;
        if (insightContractEligible) insightEligibleMoves++;
        final insight = insightContractEligible ? move.insight : null;
        if (insight?.isDisplayable != true) continue;
        final claim = insight!.primaryClaim!;
        final example = _example(game, move, claim);
        allExamples[example.identity] = example;
        final negative = _isNegative(move.classification);
        _countClaimEvent(claim, example, mate: mate, material: material);
        if (claim.mechanism != MoveInsightMechanismType.none) {
          mechanisms[claim.mechanism]!.add(
            example,
            negative:
                negative ||
                claim.mechanism == MoveInsightMechanismType.unsoundSacrifice ||
                claim.mechanism ==
                    MoveInsightMechanismType.missedMaterialResource,
          );
          if (claim.mechanism == MoveInsightMechanismType.soundSacrifice) {
            material['soundSacrifice']!.add(example, negative: false);
          } else if (claim.mechanism ==
              MoveInsightMechanismType.unsoundSacrifice) {
            material['unsoundSacrifice']!.add(example, negative: true);
          } else if (claim.mechanism ==
              MoveInsightMechanismType.missedMaterialResource) {
            material['missedMaterialResource']!.add(example, negative: true);
          }
        }
      }
      if (gameBlunders > 0) gamesWithBlunder++;
      gameFacts.add(
        _GameFacts(
          game: game,
          totalMoves: playerMoves.length,
          eligibleMoves: gameEligibleMoves,
          criticalErrors: gameCriticalErrors,
          blunders: gameBlunders,
        ),
      );

      final opening = _openingFacts(game);
      if (opening != null) {
        openingEligibleGames++;
        final accumulator = openingAccumulators.putIfAbsent(
          opening.openingId,
          () => _OpeningAccumulator(
            openingId: opening.openingId,
            eco: opening.eco,
            name: opening.name,
          ),
        );
        accumulator.add(opening);
      }
    }

    final coverage = manifest.selectedGames.isEmpty
        ? PlayerAnalyticsCoverageState.unavailable
        : manifest.exclusions.isEmpty &&
              classificationEligibleMoves == totalPlayerMoves
        ? PlayerAnalyticsCoverageState.complete
        : PlayerAnalyticsCoverageState.partial;
    final classificationMetrics = <MoveQuality, PlayerMetric>{};
    for (final quality in MoveQuality.values) {
      final isUnavailable = quality == MoveQuality.unavailable;
      classificationMetrics[quality] = PlayerMetric(
        metricId: 'classification.${quality.name}',
        displayLabel: quality.label,
        numerator: classificationCounts[quality]!.toDouble(),
        denominator: isUnavailable
            ? totalPlayerMoves
            : classificationEligibleMoves,
        eligibleGameCount: manifest.selectedGames.length,
        excludedGameCount: manifest.exclusions.length,
        excludedMoveCount: classificationExcludedMoves,
        coverage: classificationEligibleMoves == 0
            ? PlayerAnalyticsCoverageState.unavailable
            : coverage,
        policyVersion: policy.policyVersion,
        suppressionReason: classificationEligibleMoves == 0
            ? 'No player moves carry compatible classification evidence.'
            : null,
      );
    }

    final combinedCritical = criticalCounts.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    final perGameCritical =
        gameFacts.map((game) => game.criticalErrors).toList()..sort();
    final criticalMetrics = <String, PlayerMetric>{
      'inaccuraciesPer100': _rateMetric(
        'inaccuracies-per-100',
        'Inaccuracies per 100 eligible moves',
        criticalCounts['inaccuracy']!,
        classificationEligibleMoves,
        manifest,
        classificationExcludedMoves,
        coverage,
      ),
      'mistakesPer100': _rateMetric(
        'mistakes-per-100',
        'Mistakes per 100 eligible moves',
        criticalCounts['mistake']!,
        classificationEligibleMoves,
        manifest,
        classificationExcludedMoves,
        coverage,
      ),
      'blundersPer100': _rateMetric(
        'blunders-per-100',
        'Blunders per 100 eligible moves',
        criticalCounts['blunder']!,
        classificationEligibleMoves,
        manifest,
        classificationExcludedMoves,
        coverage,
      ),
      'missedWinsPer100': _rateMetric(
        'missed-wins-per-100',
        'Missed wins per 100 eligible moves',
        criticalCounts['missedWin']!,
        classificationEligibleMoves,
        manifest,
        classificationExcludedMoves,
        coverage,
      ),
      'criticalErrorsPer100': _rateMetric(
        'critical-errors-per-100',
        'Critical errors per 100 eligible moves',
        combinedCritical,
        classificationEligibleMoves,
        manifest,
        classificationExcludedMoves,
        coverage,
      ),
      'gamesWithBlunder': PlayerMetric(
        metricId: 'games-with-blunder',
        displayLabel: 'Games containing at least one blunder',
        numerator: gamesWithBlunder.toDouble(),
        denominator: manifest.selectedGames.length,
        eligibleGameCount: manifest.selectedGames.length,
        excludedGameCount: manifest.exclusions.length,
        excludedMoveCount: classificationExcludedMoves,
        coverage: coverage,
        policyVersion: policy.policyVersion,
      ),
      'medianCriticalErrorsPerGame': PlayerMetric(
        metricId: 'median-critical-errors-per-game',
        displayLabel: 'Median critical errors per analyzed game',
        numerator: _medianInt(perGameCritical) ?? 0,
        denominator: gameFacts.length,
        eligibleGameCount: gameFacts.length,
        excludedGameCount: manifest.exclusions.length,
        excludedMoveCount: classificationExcludedMoves,
        coverage: gameFacts.isEmpty
            ? PlayerAnalyticsCoverageState.unavailable
            : coverage,
        policyVersion: policy.policyVersion,
      ),
    };

    final openings =
        openingAccumulators.values
            .map((accumulator) => accumulator.toSummary())
            .toList()
          ..sort((a, b) {
            final count = b.gameCount.compareTo(a.gameCount);
            return count != 0 ? count : a.openingId.compareTo(b.openingId);
          });
    final trend = _trend(gameFacts);
    final eventCoverage = insightEligibleMoves == 0
        ? PlayerAnalyticsCoverageState.unavailable
        : insightEligibleMoves < totalPlayerMoves
        ? PlayerAnalyticsCoverageState.partial
        : PlayerAnalyticsCoverageState.complete;

    return PlayerAnalyticsSnapshot(
      manifest: manifest,
      distinctSavedGames: distinctSavedGames,
      canonicalAnalyzedGames: manifest.selectedGames.length,
      knownSideGames: manifest.selectedGames.length,
      totalPlayerMoves: totalPlayerMoves,
      classificationEligibleMoves: classificationEligibleMoves,
      insightEligibleMoves: insightEligibleMoves,
      openingEligibleGames: openingEligibleGames,
      classificationDistribution: Map.unmodifiable(classificationMetrics),
      criticalErrorMetrics: Map.unmodifiable(criticalMetrics),
      mateEvents: Map.unmodifiable({
        for (final entry in mate.entries)
          entry.key: entry.value.toSummary(
            eventId: entry.key,
            displayLabel: _eventLabel(entry.key),
            eligibleGameCount: manifest.selectedGames.length,
            eligibleMoveCount: insightEligibleMoves,
            coverage: eventCoverage,
          ),
      }),
      materialEvents: Map.unmodifiable({
        for (final entry in material.entries)
          entry.key: entry.value.toSummary(
            eventId: entry.key,
            displayLabel: _eventLabel(entry.key),
            eligibleGameCount: manifest.selectedGames.length,
            eligibleMoveCount: insightEligibleMoves,
            coverage: eventCoverage,
          ),
      }),
      tacticalMechanisms: Map.unmodifiable({
        for (final entry in mechanisms.entries)
          entry.key: entry.value.toSummary(
            eventId: entry.key.name,
            displayLabel: _mechanismLabel(entry.key),
            eligibleGameCount: manifest.selectedGames.length,
            eligibleMoveCount: insightEligibleMoves,
            coverage: eventCoverage,
          ),
      }),
      openings: List.unmodifiable(openings),
      trend: trend,
      priorities: const [],
      suppressedPriorities: const [],
      reviewQueue: allExamples.values.toList(growable: false),
      coverage: coverage,
      windowLabel: 'Most recently saved analyzed games',
      performance: PlayerAnalyticsPerformance(
        manifestMicros: manifestMicros,
        selectionMicros: selectionMicros,
        inputBytes: inputBytes,
      ),
    );
  }

  PlayerTrend _trend(List<_GameFacts> allGames) {
    final ordered = [...allGames]
      ..sort((a, b) {
        final date = b.game.orderTimestamp.compareTo(a.game.orderTimestamp);
        return date != 0 ? date : a.game.gameId.compareTo(b.game.gameId);
      });
    final recent = ordered.take(policy.recentWindowGames).toList();
    final previous = ordered
        .skip(policy.recentWindowGames)
        .take(policy.recentWindowGames)
        .toList();
    final recentMoves = recent.fold<int>(
      0,
      (sum, game) => sum + game.eligibleMoves,
    );
    final previousMoves = previous.fold<int>(
      0,
      (sum, game) => sum + game.eligibleMoves,
    );
    final recentTotalMoves = recent.fold<int>(
      0,
      (sum, game) => sum + game.totalMoves,
    );
    final previousTotalMoves = previous.fold<int>(
      0,
      (sum, game) => sum + game.totalMoves,
    );
    if (recent.length < policy.minimumTrendGamesPerWindow ||
        previous.length < policy.minimumTrendGamesPerWindow ||
        recentMoves < policy.minimumTrendMovesPerWindow ||
        previousMoves < policy.minimumTrendMovesPerWindow ||
        recentMoves != recentTotalMoves ||
        previousMoves != previousTotalMoves) {
      final incompatibleCoverage =
          recentMoves != recentTotalMoves ||
          previousMoves != previousTotalMoves;
      return PlayerTrend(
        state: PlayerAnalyticsTrendState.insufficientEvidence,
        metricId: 'critical-errors-per-100',
        windowLabel: 'Equal non-overlapping saved-analysis windows',
        previousValue: null,
        recentValue: null,
        absoluteDelta: null,
        relativeDelta: null,
        previousGameCount: previous.length,
        recentGameCount: recent.length,
        previousMoveCount: previousMoves,
        recentMoveCount: recentMoves,
        coverage: PlayerAnalyticsCoverageState.insufficient,
        suppressionReason: incompatibleCoverage
            ? 'The two windows do not have fully compatible move eligibility.'
            : 'Needs ${policy.minimumTrendGamesPerWindow} games and '
                  '${policy.minimumTrendMovesPerWindow} eligible moves in each window.',
      );
    }
    final recentErrors = recent.fold<int>(
      0,
      (sum, game) => sum + game.criticalErrors,
    );
    final previousErrors = previous.fold<int>(
      0,
      (sum, game) => sum + game.criticalErrors,
    );
    final recentRate = (recentErrors / recentMoves) * 100;
    final previousRate = (previousErrors / previousMoves) * 100;
    final delta = recentRate - previousRate;
    final relative = previousRate == 0 ? null : delta / previousRate.abs();
    final threshold =
        policy.trendAbsoluteRateThreshold >
            previousRate.abs() * policy.trendRelativeThreshold
        ? policy.trendAbsoluteRateThreshold
        : previousRate.abs() * policy.trendRelativeThreshold;
    final outlierDominated =
        _outlierDominated(recent) || _outlierDominated(previous);
    final state = delta.abs() < threshold
        ? PlayerAnalyticsTrendState.stable
        : outlierDominated
        ? PlayerAnalyticsTrendState.insufficientEvidence
        : delta < 0
        ? PlayerAnalyticsTrendState.improving
        : PlayerAnalyticsTrendState.declining;
    return PlayerTrend(
      state: state,
      metricId: 'critical-errors-per-100',
      windowLabel: 'Equal non-overlapping saved-analysis windows',
      previousValue: previousRate,
      recentValue: recentRate,
      absoluteDelta: delta,
      relativeDelta: relative,
      previousGameCount: previous.length,
      recentGameCount: recent.length,
      previousMoveCount: previousMoves,
      recentMoveCount: recentMoves,
      coverage: outlierDominated && delta.abs() >= threshold
          ? PlayerAnalyticsCoverageState.insufficient
          : PlayerAnalyticsCoverageState.complete,
      suppressionReason: outlierDominated && delta.abs() >= threshold
          ? 'One game dominates the apparent change.'
          : null,
    );
  }

  static bool _outlierDominated(List<_GameFacts> games) {
    final total = games.fold<int>(0, (sum, game) => sum + game.criticalErrors);
    if (total < 2) return false;
    final largest = games.fold<int>(
      0,
      (best, game) => game.criticalErrors > best ? game.criticalErrors : best,
    );
    return largest / total > 0.5;
  }

  PlayerMetric _rateMetric(
    String id,
    String label,
    int numerator,
    int denominator,
    PlayerAnalyticsManifest manifest,
    int excludedMoves,
    PlayerAnalyticsCoverageState coverage,
  ) => PlayerMetric(
    metricId: id,
    displayLabel: label,
    numerator: numerator.toDouble(),
    denominator: denominator,
    eligibleGameCount: manifest.selectedGames.length,
    excludedGameCount: manifest.exclusions.length,
    excludedMoveCount: excludedMoves,
    coverage: denominator == 0
        ? PlayerAnalyticsCoverageState.unavailable
        : coverage,
    policyVersion: policy.policyVersion,
    suppressionReason: denominator == 0
        ? 'No compatible classification-eligible player moves.'
        : null,
  );

  static _OpeningFacts? _openingFacts(CanonicalAnalyzedGame game) {
    final timeline = game.document.timeline;
    if (timeline.openingBookVersion != kApexOpeningBookVersion ||
        timeline.moves.isEmpty) {
      return null;
    }
    final evidence = timeline.moves
        .map((move) => move.openingEvidence)
        .toList(growable: false);
    if (evidence.any(
      (item) =>
          item == null ||
          !item.hasValidIntegrity ||
          !item.isArtifactVerified ||
          item.state == OpeningMatchState.unavailable,
    )) {
      return null;
    }
    OpeningCandidate? selected;
    int? leavingTheoryPly;
    var theoryMoves = 0;
    for (final item in evidence.whereType<OpeningEvidence>()) {
      if (item.isVerifiedBookTransition) {
        theoryMoves++;
        selected = item.selectedCandidate ?? selected;
      }
      if (item.state == OpeningMatchState.leftTheory &&
          item.leavingTheoryPly != null) {
        leavingTheoryPly = leavingTheoryPly == null
            ? item.leavingTheoryPly
            : (item.leavingTheoryPly! < leavingTheoryPly
                  ? item.leavingTheoryPly
                  : leavingTheoryPly);
      }
    }
    if (selected == null) return null;
    final criticalExamples = <PlayerAnalyticsExample>[];
    if (leavingTheoryPly != null) {
      for (final move in timeline.moves) {
        if (move.isWhiteMove != game.playerIsWhite ||
            move.ply + 1 < leavingTheoryPly ||
            !_isNegative(move.classification)) {
          continue;
        }
        final claim = move.insight?.isDisplayable == true
            ? move.insight!.primaryClaim
            : null;
        criticalExamples.add(
          PlayerAnalyticsExample(
            gameId: game.gameId,
            variantId: game.variantId,
            documentId: game.documentId,
            ply: move.ply,
            classification: move.classification,
            orderTimestamp: game.orderTimestamp,
            claimType: claim?.type,
            mechanism: claim?.mechanism,
            persistedSentence: move.insight?.conciseText,
          ),
        );
      }
    }
    return _OpeningFacts(
      openingId: '${selected.ecoCode.trim()}|${selected.openingName.trim()}',
      eco: selected.ecoCode.trim(),
      name: selected.openingName.trim(),
      theoryMoves: theoryMoves,
      leavingTheoryPly: leavingTheoryPly,
      criticalExamples: criticalExamples,
    );
  }

  static void _countClaimEvent(
    MoveInsightClaim claim,
    PlayerAnalyticsExample example, {
    required Map<String, _EventAccumulator> mate,
    required Map<String, _EventAccumulator> material,
  }) {
    switch (claim.type) {
      case MoveInsightClaimType.deliversMate:
        mate['deliveredForcedMate']!.add(example, negative: false);
      case MoveInsightClaimType.preservesForcedMate:
        mate['preservedForcedMate']!.add(example, negative: false);
      case MoveInsightClaimType.allowsForcedMate:
        mate['allowedForcedMate']!.add(example, negative: true);
      case MoveInsightClaimType.missesForcedMate:
        mate['missedForcedMate']!.add(example, negative: true);
      case MoveInsightClaimType.onlyMoveDefense:
        if (claim.consequence == MoveInsightConsequenceType.avoidsCheckmate) {
          mate['onlyMovePreventingMate']!.add(example, negative: false);
        }
      case MoveInsightClaimType.winsMaterial:
        material['wonMaterial']!.add(example, negative: false);
      case MoveInsightClaimType.dropsMaterial:
        material['droppedMaterial']!.add(example, negative: true);
      case MoveInsightClaimType.missesMaterialWin:
        material['missedMaterialResource']!.add(example, negative: true);
      case MoveInsightClaimType.createsStalemate ||
          MoveInsightClaimType.promotes ||
          MoveInsightClaimType.recaptures ||
          MoveInsightClaimType.bookTransition:
        break;
    }
  }

  static PlayerAnalyticsExample _example(
    CanonicalAnalyzedGame game,
    MoveAnalysis move,
    MoveInsightClaim claim,
  ) => PlayerAnalyticsExample(
    gameId: game.gameId,
    variantId: game.variantId,
    documentId: game.documentId,
    ply: move.ply,
    classification: move.classification,
    orderTimestamp: game.orderTimestamp,
    claimType: claim.type,
    mechanism: claim.mechanism,
    persistedSentence: move.insight?.conciseText,
  );

  static int _compareDocumentStrength(
    ReviewDocument left,
    ReviewDocument right,
  ) {
    final leftVector = _strengthVector(left);
    final rightVector = _strengthVector(right);
    for (var index = 0; index < leftVector.length; index++) {
      final comparison = rightVector[index].compareTo(leftVector[index]);
      if (comparison != 0) return comparison;
    }
    final variant = left.variantId.value.compareTo(right.variantId.value);
    return variant != 0 ? variant : left.documentId.compareTo(right.documentId);
  }

  static List<int> _strengthVector(ReviewDocument document) {
    final timeline = document.timeline;
    final currentInsight = timeline.hasCurrentExplanationContract ? 1 : 0;
    final displayableInsights = timeline.moves
        .where((move) => move.insight?.isDisplayable == true)
        .length;
    final completeMultiPv = timeline.moves
        .where(
          (move) =>
              move.classificationEvidence?.hasCompleteCandidateSet == true,
        )
        .length;
    final verifiedOpening = timeline.moves
        .where(
          (move) =>
              move.openingEvidence?.isArtifactVerified == true &&
              move.openingEvidence?.hasValidIntegrity == true,
        )
        .length;
    final trustedEngine = _trustedEngineIdentity(timeline.engineVersion)
        ? document.compatibility.engine.identityVerification.index
        : 0;
    return [
      trustedEngine,
      completeMultiPv,
      document.run.achievedDepth ?? 0,
      timeline.multipv ?? 0,
      timeline.analysisSchemaVersion,
      currentInsight,
      displayableInsights,
      verifiedOpening,
    ];
  }

  static String _selectionReason(ReviewDocument document) {
    final vector = _strengthVector(document);
    return 'trustedEngine=${vector[0]},completeMultiPvPlies=${vector[1]},'
        'depth=${vector[2]},multipv=${vector[3]},schema=${vector[4]},'
        'currentInsight=${vector[5]},displayableInsights=${vector[6]},'
        'verifiedOpeningPlies=${vector[7]}';
  }

  static bool _trustedEngineIdentity(String identity) {
    final normalized = identity.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'unknown' &&
        !normalized.contains('stub') &&
        !normalized.contains('mock');
  }

  static PlayerAnalyticsExclusion _documentExclusion(
    ReviewDocument document,
    PlayerAnalyticsExclusionReason reason,
    String detail,
  ) => PlayerAnalyticsExclusion(
    reason: reason,
    detail: detail,
    gameId: document.game.gameId.value,
    variantId: document.variantId.value,
    documentId: document.documentId,
  );

  static int _compareExclusion(
    PlayerAnalyticsExclusion left,
    PlayerAnalyticsExclusion right,
  ) {
    var comparison = (left.gameId ?? '').compareTo(right.gameId ?? '');
    if (comparison != 0) return comparison;
    comparison = (left.variantId ?? '').compareTo(right.variantId ?? '');
    if (comparison != 0) return comparison;
    comparison = left.reason.name.compareTo(right.reason.name);
    if (comparison != 0) return comparison;
    return left.detail.compareTo(right.detail);
  }

  static String? _criticalBucket(MoveQuality quality) => switch (quality) {
    MoveQuality.inaccuracy => 'inaccuracy',
    MoveQuality.mistake => 'mistake',
    MoveQuality.blunder => 'blunder',
    MoveQuality.missedWin => 'missedWin',
    _ => null,
  };

  static bool _isNegative(MoveQuality quality) =>
      _criticalBucket(quality) != null;

  static String _eventLabel(String event) => switch (event) {
    'deliveredForcedMate' => 'Delivered forced mate',
    'preservedForcedMate' => 'Preserved forced mate',
    'allowedForcedMate' => 'Allowed forced mate',
    'missedForcedMate' => 'Missed forced mate',
    'onlyMovePreventingMate' => 'Only Move preventing mate',
    'droppedMaterial' => 'Dropped material',
    'wonMaterial' => 'Won material',
    'missedMaterialResource' => 'Missed material resource',
    'soundSacrifice' => 'Sound sacrifice',
    'unsoundSacrifice' => 'Unsound sacrifice',
    _ => event,
  };

  static String _mechanismLabel(MoveInsightMechanismType mechanism) =>
      switch (mechanism) {
        MoveInsightMechanismType.fork => 'Fork',
        MoveInsightMechanismType.doubleAttack => 'Double attack',
        MoveInsightMechanismType.absolutePin => 'Absolute pin',
        MoveInsightMechanismType.skewer => 'Skewer',
        MoveInsightMechanismType.discoveredAttack => 'Discovered attack',
        MoveInsightMechanismType.opensLine => 'Opened line',
        MoveInsightMechanismType.removesDefender => 'Removed defender',
        MoveInsightMechanismType.soundSacrifice => 'Sound sacrifice',
        MoveInsightMechanismType.unsoundSacrifice => 'Unsound sacrifice',
        MoveInsightMechanismType.onlyMoveDefense => 'Only Move defense',
        MoveInsightMechanismType.missedMaterialResource =>
          'Missed material resource',
        MoveInsightMechanismType.none => 'None',
      };

  static double? _medianInt(List<int> sorted) {
    if (sorted.isEmpty) return null;
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[middle].toDouble();
    return (sorted[middle - 1] + sorted[middle]) / 2;
  }
}

class _CanonicalSelection {
  const _CanonicalSelection({
    required this.games,
    required this.exclusions,
    required this.distinctSavedGames,
  });

  final List<CanonicalAnalyzedGame> games;
  final List<PlayerAnalyticsExclusion> exclusions;
  final int distinctSavedGames;
}

class _EventAccumulator {
  int positive = 0;
  int negative = 0;
  final Map<String, PlayerAnalyticsExample> examples = {};

  void add(PlayerAnalyticsExample example, {required bool negative}) {
    if (negative) {
      this.negative++;
    } else {
      positive++;
    }
    examples[example.identity] = example;
  }

  PlayerEventSummary toSummary({
    required String eventId,
    required String displayLabel,
    required int eligibleGameCount,
    required int eligibleMoveCount,
    required PlayerAnalyticsCoverageState coverage,
  }) => PlayerEventSummary(
    eventId: eventId,
    displayLabel: displayLabel,
    positiveCount: positive,
    negativeCount: negative,
    eligibleGameCount: eligibleGameCount,
    eligibleMoveCount: eligibleMoveCount,
    coverage: coverage,
    examples: examples.values.toList(growable: false),
  );
}

class _GameFacts {
  const _GameFacts({
    required this.game,
    required this.totalMoves,
    required this.eligibleMoves,
    required this.criticalErrors,
    required this.blunders,
  });

  final CanonicalAnalyzedGame game;
  final int totalMoves;
  final int eligibleMoves;
  final int criticalErrors;
  final int blunders;
}

class _OpeningFacts {
  const _OpeningFacts({
    required this.openingId,
    required this.eco,
    required this.name,
    required this.theoryMoves,
    required this.leavingTheoryPly,
    required this.criticalExamples,
  });

  final String openingId;
  final String eco;
  final String name;
  final int theoryMoves;
  final int? leavingTheoryPly;
  final List<PlayerAnalyticsExample> criticalExamples;
}

class _OpeningAccumulator {
  _OpeningAccumulator({
    required this.openingId,
    required this.eco,
    required this.name,
  });

  final String openingId;
  final String eco;
  final String name;
  int games = 0;
  int theoryMoves = 0;
  final List<int> leavingTheoryPlies = [];
  final Map<String, PlayerAnalyticsExample> examples = {};

  void add(_OpeningFacts facts) {
    games++;
    theoryMoves += facts.theoryMoves;
    if (facts.leavingTheoryPly != null) {
      leavingTheoryPlies.add(facts.leavingTheoryPly!);
    }
    for (final example in facts.criticalExamples) {
      examples[example.identity] = example;
    }
  }

  PlayerOpeningSummary toSummary() {
    leavingTheoryPlies.sort();
    return PlayerOpeningSummary(
      openingId: openingId,
      eco: eco,
      name: name,
      gameCount: games,
      verifiedTheoryMoveCount: theoryMoves,
      leavingTheorySamples: leavingTheoryPlies.length,
      medianLeavingTheoryPly: PlayerAnalyticsBuilder._medianInt(
        leavingTheoryPlies,
      ),
      criticalErrorsAfterTheory: examples.length,
      examples: examples.values.toList(growable: false),
    );
  }
}

final RegExp _gameIdPattern = RegExp(r'^[0-9a-f]{64}$');

String _lengthPrefixed(String key, String value) =>
    '${key.length}:$key=${utf8.encode(value).length}:$value';

String _digestCanonicalJson(Object? value) {
  final canonical = _canonicalize(value);
  return sha256.convert(utf8.encode(jsonEncode(canonical))).toString();
}

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final sorted = SplayTreeMap<String, Object?>();
    for (final entry in value.entries) {
      sorted[entry.key.toString()] = _canonicalize(entry.value);
    }
    return sorted;
  }
  if (value is Iterable) {
    return value.map(_canonicalize).toList(growable: false);
  }
  return value;
}
