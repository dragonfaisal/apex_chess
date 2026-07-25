library;

import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';

const List<String> kPlayerCoachingPriorityIds = [
  'material-losses',
  'missed-tactical-wins',
  'mate-threat-awareness',
  'unsound-sacrifices',
  'forks-double-attacks',
  'pins-skewers',
  'removed-defenders',
  'opening-exits',
  'only-move-defenses',
];

class PlayerCoachingPriorityEngine {
  const PlayerCoachingPriorityEngine();

  PlayerAnalyticsSnapshot apply(
    PlayerAnalyticsSnapshot snapshot, {
    required PlayerAnalyticsPolicy policy,
  }) {
    final orderRank = <String, int>{};
    final ordered = [...snapshot.manifest.selectedGames]
      ..sort((a, b) => a.orderTimestamp.compareTo(b.orderTimestamp));
    for (var index = 0; index < ordered.length; index++) {
      orderRank[ordered[index].gameId] = index + 1;
    }

    final candidates = <_PriorityCandidate>[
      _eventCandidate(
        priorityId: 'material-losses',
        specificity: 1,
        category: CoachingPriorityCategory.materialSafety,
        title: 'Stop immediate material losses',
        action:
            'Before committing, check every forcing reply against the piece you leave undefended.',
        summary: snapshot.materialEvents['droppedMaterial'],
        denominator: snapshot.insightEligibleMoves,
      ),
      _combinedCandidate(
        priorityId: 'missed-tactical-wins',
        specificity: 2,
        category: CoachingPriorityCategory.tacticalConversion,
        title: 'Convert winning tactical resources',
        action:
            'Pause on forcing positions and compare checks, captures, and direct threats before choosing.',
        summaries: [
          snapshot.materialEvents['missedMaterialResource'],
          snapshot.criticalErrorMetrics['missedWinsPer100'] == null
              ? null
              : _fromMetric(
                  snapshot.criticalErrorMetrics['missedWinsPer100']!,
                  snapshot.reviewQueue.where(
                    (example) =>
                        example.classification == MoveQuality.missedWin,
                  ),
                ),
        ],
        denominator: snapshot.classificationEligibleMoves,
      ),
      _combinedCandidate(
        priorityId: 'mate-threat-awareness',
        specificity: 1,
        category: CoachingPriorityCategory.mateAwareness,
        title: 'Improve mate-threat awareness',
        action:
            'Check opponent mating threats before calculating quieter continuations.',
        summaries: [
          snapshot.mateEvents['allowedForcedMate'],
          snapshot.mateEvents['missedForcedMate'],
        ],
        denominator: snapshot.insightEligibleMoves,
      ),
      _mechanismCandidate(
        priorityId: 'unsound-sacrifices',
        specificity: 3,
        category: CoachingPriorityCategory.sacrificeDiscipline,
        title: 'Avoid unsound sacrifices',
        action: 'Require a concrete forced return before investing material.',
        summary: snapshot
            .tacticalMechanisms[MoveInsightMechanismType.unsoundSacrifice],
        denominator: snapshot.insightEligibleMoves,
      ),
      _combinedMechanismCandidate(
        priorityId: 'forks-double-attacks',
        specificity: 2,
        category: CoachingPriorityCategory.tacticalRecognition,
        title: 'Recognize forks and double attacks',
        action:
            'Scan every candidate move for one piece attacking two valuable targets.',
        summaries: [
          snapshot.tacticalMechanisms[MoveInsightMechanismType.fork],
          snapshot.tacticalMechanisms[MoveInsightMechanismType.doubleAttack],
        ],
        negativeOnly: true,
        denominator: snapshot.insightEligibleMoves,
      ),
      _combinedMechanismCandidate(
        priorityId: 'pins-skewers',
        specificity: 2,
        category: CoachingPriorityCategory.tacticalRecognition,
        title: 'Recognize pins and skewers',
        action:
            'Trace files, ranks, and diagonals through high-value pieces before moving.',
        summaries: [
          snapshot.tacticalMechanisms[MoveInsightMechanismType.absolutePin],
          snapshot.tacticalMechanisms[MoveInsightMechanismType.skewer],
        ],
        negativeOnly: true,
        denominator: snapshot.insightEligibleMoves,
      ),
      _mechanismCandidate(
        priorityId: 'removed-defenders',
        specificity: 2,
        category: CoachingPriorityCategory.defenderAwareness,
        title: 'Track defenders before captures',
        action: 'Count defenders again after every exchange or deflection.',
        summary: snapshot
            .tacticalMechanisms[MoveInsightMechanismType.removesDefender],
        denominator: snapshot.insightEligibleMoves,
      ),
      _openingCandidate(snapshot),
      _positiveCombinedCandidate(
        priorityId: 'only-move-defenses',
        specificity: 2,
        category: CoachingPriorityCategory.defensiveResources,
        title: 'Review Only-Move defensive positions',
        action:
            'Revisit positions where one move alone held the game and identify the threat it answered.',
        summaries: [
          snapshot.mateEvents['onlyMovePreventingMate'],
          snapshot.tacticalMechanisms[MoveInsightMechanismType.onlyMoveDefense],
        ],
        denominator: snapshot.insightEligibleMoves,
      ),
    ];

    final active = <CoachingPriority>[];
    final suppressed = <SuppressedCoachingPriority>[];
    final supportingExamples = <String, List<PlayerAnalyticsExample>>{};
    for (final candidate in candidates) {
      final games = candidate.examples.map((example) => example.gameId).toSet();
      final examples = [...candidate.examples]
        ..sort((a, b) {
          final time = b.orderTimestamp.compareTo(a.orderTimestamp);
          if (time != 0) return time;
          final game = a.gameId.compareTo(b.gameId);
          return game != 0 ? game : a.ply.compareTo(b.ply);
        });
      final rank = CoachingPriorityRank(
        severity: examples.fold<int>(
          0,
          (sum, example) => sum + _severity(example.classification),
        ),
        frequency: candidate.eventCount,
        recency: examples.fold<int>(
          0,
          (best, example) => (orderRank[example.gameId] ?? 0) > best
              ? orderRank[example.gameId] ?? 0
              : best,
        ),
        specificity: candidate.specificity,
      );
      supportingExamples[candidate.priorityId] = examples;

      if (candidate.denominator < candidate.eventCount) {
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: candidate.priorityId,
            code: CoachingPrioritySuppressionCode.insufficientDenominator,
            reason:
                'The eligible denominator is smaller than the persisted event count.',
            eventCount: candidate.eventCount,
            gameCount: games.length,
            eligibleDenominator: candidate.denominator,
            rank: rank,
          ),
        );
        continue;
      }
      if (candidate.denominator == 0) {
        final incompatible = snapshot.canonicalAnalyzedGames > 0;
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: candidate.priorityId,
            code: incompatible
                ? CoachingPrioritySuppressionCode.incompatibleEvidence
                : CoachingPrioritySuppressionCode.noEligibleEvidence,
            reason: incompatible
                ? 'Saved reviews do not carry a compatible evidence contract for this priority.'
                : 'No eligible saved-review evidence is available.',
            eventCount: candidate.eventCount,
            gameCount: games.length,
            eligibleDenominator: candidate.denominator,
            rank: rank,
          ),
        );
        continue;
      }
      if (candidate.eventCount == 0) {
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: candidate.priorityId,
            code: CoachingPrioritySuppressionCode.noEligibleEvidence,
            reason: 'No supported event is present in the eligible sample.',
            eventCount: 0,
            gameCount: 0,
            eligibleDenominator: candidate.denominator,
            rank: rank,
          ),
        );
        continue;
      }
      if (candidate.eventCount < policy.minimumPriorityEvents) {
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: candidate.priorityId,
            code: CoachingPrioritySuppressionCode.belowEventThreshold,
            reason:
                'Needs at least ${policy.minimumPriorityEvents} repeated events.',
            eventCount: candidate.eventCount,
            gameCount: games.length,
            eligibleDenominator: candidate.denominator,
            rank: rank,
          ),
        );
        continue;
      }
      if (games.length < policy.minimumPriorityGames) {
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: candidate.priorityId,
            code: CoachingPrioritySuppressionCode.belowGameThreshold,
            reason:
                'Needs evidence from at least ${policy.minimumPriorityGames} games.',
            eventCount: candidate.eventCount,
            gameCount: games.length,
            eligibleDenominator: candidate.denominator,
            rank: rank,
          ),
        );
        continue;
      }
      active.add(
        CoachingPriority(
          priorityId: candidate.priorityId,
          category: candidate.category,
          title: candidate.title,
          action: candidate.action,
          eventCount: candidate.eventCount,
          eligibleDenominator: candidate.denominator,
          gameCount: games.length,
          coverage: PlayerAnalyticsCoverageState.complete,
          rank: rank,
          examples: examples.take(3).toList(growable: false),
        ),
      );
    }
    active.sort(_comparePriority);
    final published = <CoachingPriority>[];
    final publishedExamples = <String>{};
    for (final priority in active) {
      final allExamples = supportingExamples[priority.priorityId]!;
      final identities = allExamples.map((example) => example.identity).toSet();
      if (identities.isNotEmpty &&
          identities.every(publishedExamples.contains)) {
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: priority.priorityId,
            code: CoachingPrioritySuppressionCode.overlappingPublishedPriority,
            reason:
                'Its supporting moments are already represented by a higher-ranked priority.',
            eventCount: priority.eventCount,
            gameCount: priority.gameCount,
            eligibleDenominator: priority.eligibleDenominator,
            rank: priority.rank,
          ),
        );
        continue;
      }
      if (published.length == 3) {
        suppressed.add(
          SuppressedCoachingPriority(
            priorityId: priority.priorityId,
            code: CoachingPrioritySuppressionCode.maximumThreeLimit,
            reason:
                'Displaced by higher-ranked priorities under the maximum-three limit.',
            eventCount: priority.eventCount,
            gameCount: priority.gameCount,
            eligibleDenominator: priority.eligibleDenominator,
            rank: priority.rank,
          ),
        );
        continue;
      }
      final uniqueExamples = allExamples
          .where((example) => !publishedExamples.contains(example.identity))
          .take(3)
          .toList(growable: false);
      published.add(_withExamples(priority, uniqueExamples));
      publishedExamples.addAll(identities);
    }
    final queueByIdentity = <String, PlayerAnalyticsExample>{};
    for (final priority in published) {
      for (final example in priority.examples) {
        queueByIdentity.putIfAbsent(example.identity, () => example);
      }
    }

    return snapshot.copyWith(
      priorities: published,
      suppressedPriorities: suppressed,
      reviewQueue: queueByIdentity.values.take(6).toList(growable: false),
      strength: _supportedStrength(snapshot, policy),
      clearStrength: _supportedStrength(snapshot, policy) == null,
    );
  }

  static int _comparePriority(CoachingPriority left, CoachingPriority right) {
    var comparison = right.rank.severity.compareTo(left.rank.severity);
    if (comparison != 0) return comparison;
    comparison = right.rank.frequency.compareTo(left.rank.frequency);
    if (comparison != 0) return comparison;
    comparison = right.rank.recency.compareTo(left.rank.recency);
    if (comparison != 0) return comparison;
    comparison = right.rank.specificity.compareTo(left.rank.specificity);
    if (comparison != 0) return comparison;
    return left.priorityId.compareTo(right.priorityId);
  }

  static CoachingPriority _withExamples(
    CoachingPriority priority,
    List<PlayerAnalyticsExample> examples,
  ) => CoachingPriority(
    priorityId: priority.priorityId,
    category: priority.category,
    title: priority.title,
    action: priority.action,
    eventCount: priority.eventCount,
    eligibleDenominator: priority.eligibleDenominator,
    gameCount: priority.gameCount,
    coverage: priority.coverage,
    rank: priority.rank,
    examples: examples,
  );

  static int _severity(MoveQuality quality) => switch (quality) {
    MoveQuality.blunder || MoveQuality.missedWin => 4,
    MoveQuality.mistake => 3,
    MoveQuality.inaccuracy => 2,
    _ => 1,
  };

  static _PriorityCandidate _eventCandidate({
    required String priorityId,
    required int specificity,
    required CoachingPriorityCategory category,
    required String title,
    required String action,
    required PlayerEventSummary? summary,
    required int denominator,
  }) => _PriorityCandidate(
    priorityId: priorityId,
    specificity: specificity,
    category: category,
    title: title,
    action: action,
    eventCount: summary?.negativeCount ?? 0,
    denominator: denominator,
    examples:
        summary?.examples
            .where(
              (example) => _isNegativeClassification(example.classification),
            )
            .toList(growable: false) ??
        const [],
  );

  static _PriorityCandidate _mechanismCandidate({
    required String priorityId,
    required int specificity,
    required CoachingPriorityCategory category,
    required String title,
    required String action,
    required PlayerEventSummary? summary,
    required int denominator,
  }) => _PriorityCandidate(
    priorityId: priorityId,
    specificity: specificity,
    category: category,
    title: title,
    action: action,
    eventCount: summary?.negativeCount ?? 0,
    denominator: denominator,
    examples:
        summary?.examples
            .where(
              (example) => _isNegativeClassification(example.classification),
            )
            .toList(growable: false) ??
        const [],
  );

  static _PriorityCandidate _combinedCandidate({
    required String priorityId,
    required int specificity,
    required CoachingPriorityCategory category,
    required String title,
    required String action,
    required List<PlayerEventSummary?> summaries,
    required int denominator,
  }) {
    final examples = <String, PlayerAnalyticsExample>{};
    for (final summary in summaries.whereType<PlayerEventSummary>()) {
      for (final example in summary.examples) {
        if (_isNegativeClassification(example.classification)) {
          examples[example.identity] = example;
        }
      }
    }
    return _PriorityCandidate(
      priorityId: priorityId,
      specificity: specificity,
      category: category,
      title: title,
      action: action,
      eventCount: examples.length,
      denominator: denominator,
      examples: examples.values.toList(growable: false),
    );
  }

  static _PriorityCandidate _combinedMechanismCandidate({
    required String priorityId,
    required int specificity,
    required CoachingPriorityCategory category,
    required String title,
    required String action,
    required List<PlayerEventSummary?> summaries,
    required bool negativeOnly,
    required int denominator,
  }) {
    final examples = <String, PlayerAnalyticsExample>{};
    for (final summary in summaries.whereType<PlayerEventSummary>()) {
      for (final example in summary.examples) {
        if (!negativeOnly ||
            _isNegativeClassification(example.classification)) {
          examples[example.identity] = example;
        }
      }
    }
    return _PriorityCandidate(
      priorityId: priorityId,
      specificity: specificity,
      category: category,
      title: title,
      action: action,
      eventCount: examples.length,
      denominator: denominator,
      examples: examples.values.toList(growable: false),
    );
  }

  static _PriorityCandidate _positiveCombinedCandidate({
    required String priorityId,
    required int specificity,
    required CoachingPriorityCategory category,
    required String title,
    required String action,
    required List<PlayerEventSummary?> summaries,
    required int denominator,
  }) {
    final examples = <String, PlayerAnalyticsExample>{};
    for (final summary in summaries.whereType<PlayerEventSummary>()) {
      for (final example in summary.examples) {
        if (!_isNegativeClassification(example.classification)) {
          examples[example.identity] = example;
        }
      }
    }
    return _PriorityCandidate(
      priorityId: priorityId,
      specificity: specificity,
      category: category,
      title: title,
      action: action,
      eventCount: examples.length,
      denominator: denominator,
      examples: examples.values.toList(growable: false),
    );
  }

  static _PriorityCandidate _openingCandidate(
    PlayerAnalyticsSnapshot snapshot,
  ) {
    final examples = <String, PlayerAnalyticsExample>{};
    for (final opening in snapshot.openings) {
      for (final example in opening.examples) {
        examples[example.identity] = example;
      }
    }
    return _PriorityCandidate(
      priorityId: 'opening-exits',
      specificity: 2,
      category: CoachingPriorityCategory.openingTransitions,
      title: 'Review recurring opening exits',
      action:
          'Study the first position after verified theory where critical errors recur.',
      eventCount: examples.length,
      denominator: snapshot.openingEligibleGames,
      examples: examples.values.toList(growable: false),
    );
  }

  static PlayerEventSummary _fromMetric(
    PlayerMetric metric,
    Iterable<PlayerAnalyticsExample> examples,
  ) => PlayerEventSummary(
    eventId: metric.metricId,
    displayLabel: metric.displayLabel,
    positiveCount: 0,
    negativeCount: metric.numerator.toInt(),
    eligibleGameCount: metric.eligibleGameCount,
    eligibleMoveCount: metric.denominator,
    coverage: metric.coverage,
    examples: examples.toList(growable: false),
  );

  static SupportedPlayerStrength? _supportedStrength(
    PlayerAnalyticsSnapshot snapshot,
    PlayerAnalyticsPolicy policy,
  ) {
    if (snapshot.canonicalAnalyzedGames < policy.minimumStrengthGames) {
      return null;
    }
    final critical = snapshot.criticalErrorMetrics['criticalErrorsPer100'];
    if (critical?.rate != null &&
        critical!.denominator >= 50 &&
        critical.rate! <= 1.0) {
      return SupportedPlayerStrength(
        strengthId: 'low-critical-error-burden',
        title: 'Low critical-error burden in the analyzed sample',
        evidenceCount: critical.numerator.toInt(),
        gameCount: critical.eligibleGameCount,
        denominator: critical.denominator,
      );
    }
    final mechanisms = snapshot.tacticalMechanisms.values.toList()
      ..sort((a, b) => b.positiveCount.compareTo(a.positiveCount));
    if (mechanisms.isEmpty) return null;
    final strongest = mechanisms.first;
    final gameCount = strongest.examples
        .where((example) => !_isNegativeClassification(example.classification))
        .map((example) => example.gameId)
        .toSet()
        .length;
    if (strongest.positiveCount < 3 || gameCount < 3) return null;
    return SupportedPlayerStrength(
      strengthId: 'repeated-${strongest.eventId}',
      title: 'Repeated ${strongest.displayLabel.toLowerCase()} resources',
      evidenceCount: strongest.positiveCount,
      gameCount: gameCount,
      denominator: strongest.eligibleMoveCount,
    );
  }

  static bool _isNegativeClassification(MoveQuality quality) =>
      switch (quality) {
        MoveQuality.inaccuracy ||
        MoveQuality.mistake ||
        MoveQuality.blunder ||
        MoveQuality.missedWin => true,
        _ => false,
      };
}

class _PriorityCandidate {
  const _PriorityCandidate({
    required this.priorityId,
    required this.specificity,
    required this.category,
    required this.title,
    required this.action,
    required this.eventCount,
    required this.denominator,
    required this.examples,
  });

  final String priorityId;
  final int specificity;
  final CoachingPriorityCategory category;
  final String title;
  final String action;
  final int eventCount;
  final int denominator;
  final List<PlayerAnalyticsExample> examples;
}
