import 'dart:convert';

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_insight_engine.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

const int kChapter7TacticalCorpusVersion = 2;

const List<String> kChapter7ActivatedFamilies = <String>[
  'absolute_pin',
  'discovered_attack',
  'double_attack',
  'fork',
  'missed_material_resource',
  'only_move_defense',
  'removes_defender',
  'skewer',
  'sound_sacrifice',
  'unsound_sacrifice',
];

const List<String> kChapter7DeferredFamilies = <String>[
  'attraction',
  'back_rank',
  'clearance_without_capture',
  'deflection',
  'discovered_check',
  'interference',
  'overload',
  'relative_pin',
  'trapped_piece',
];

class Chapter7CorpusCase {
  const Chapter7CorpusCase({
    required this.id,
    required this.family,
    required this.profile,
    required this.expectedState,
    required this.expectedMechanism,
    required this.forbiddenMechanisms,
    required this.rationale,
    this.humanReviewResolved = false,
  });

  final String id;
  final String family;
  final String profile;
  final MoveInsightState expectedState;
  final MoveInsightMechanismType expectedMechanism;
  final Set<MoveInsightMechanismType> forbiddenMechanisms;
  final String rationale;
  final bool humanReviewResolved;
}

class Chapter7CorpusResult {
  const Chapter7CorpusResult({
    required this.spec,
    required this.input,
    required this.insight,
    required this.deterministic,
    required this.copySafe,
    required this.passed,
    required this.failures,
  });

  final Chapter7CorpusCase spec;
  final MoveInsightInput input;
  final MoveInsight insight;
  final bool deterministic;
  final bool copySafe;
  final bool passed;
  final List<String> failures;

  Map<String, Object?> toJson() {
    final claim = insight.primaryClaim;
    return <String, Object?>{
      'caseId': spec.id,
      'family': spec.family,
      'profile': spec.profile,
      'mover': input.isWhiteMove ? 'white' : 'black',
      'fenBefore': input.fenBefore,
      'playedMoveUci': input.playedMoveUci,
      'playedMoveSan': input.playedMoveSan,
      'fenAfter': input.fenAfter,
      'requiredMechanism': spec.expectedMechanism.name,
      'forbiddenMechanisms':
          spec.forbiddenMechanisms.map((value) => value.name).toList()..sort(),
      'actualSelectedOutcome': claim?.type.name,
      'actualCausalMechanism':
          claim?.mechanism.name ?? MoveInsightMechanismType.none.name,
      'pieces': <String, Object?>{
        'initiator': claim?.initiatorRole,
        'attacker': claim?.pieceRole,
        'target': claim?.targetRole,
        'secondaryTarget': claim?.secondaryTargetRole,
        'defender': claim?.defenderRole,
      },
      'squares': <String, Object?>{
        'initiator': claim?.initiatorSquare,
        'attacker': claim?.pieceSquare,
        'target': claim?.targetSquare,
        'secondaryTarget': claim?.secondaryTargetSquare,
        'defender': claim?.defenderSquare,
        'line': claim?.lineSquares,
      },
      'changedRelationship': claim?.relationType?.name,
      'consequence': claim?.consequence.name,
      'betterMove': claim?.betterMoveSan,
      'continuationSan': claim?.continuationSan,
      'continuationUci': claim?.continuationUci,
      'suppressionState': insight.state.name,
      'suppressionReason': insight.suppressionReason,
      'renderedSentence': insight.conciseText,
      'semanticFingerprint': insight.semanticFingerprint,
      'deterministic': deterministic,
      'copyInvariantPassed': copySafe,
      'humanReviewStatus': spec.humanReviewResolved
          ? 'resolved'
          : insight.isDisplayable
          ? 'required'
          : 'not_applicable',
      'automatedStatus': passed ? 'pass' : 'fail',
      'failureReasons': failures,
      'rationale': spec.rationale,
    };
  }
}

class Chapter7CorpusRun {
  const Chapter7CorpusRun({
    required this.results,
    required this.performance,
    required this.runtimePerformance,
    required this.duplicateFingerprints,
  });

  final List<Chapter7CorpusResult> results;
  final Map<String, Object?> performance;
  final Map<String, Object?> runtimePerformance;
  final Map<String, List<String>> duplicateFingerprints;

  int get passed => results.where((result) => result.passed).length;
  int get failed => results.length - passed;
  int get positiveCases => results
      .where(
        (result) =>
            result.spec.expectedMechanism != MoveInsightMechanismType.none,
      )
      .length;
  int get negativeCases => results.length - positiveCases;
  int get visibleCases =>
      results.where((result) => result.insight.isDisplayable).length;
  int get suppressedCases => results
      .where((result) => result.insight.state == MoveInsightState.suppressed)
      .length;
  int get contradictoryCases => results
      .where((result) => result.insight.state == MoveInsightState.contradictory)
      .length;
  int get forbiddenViolations => results
      .where(
        (result) => result.spec.forbiddenMechanisms.contains(
          result.insight.primaryClaim?.mechanism,
        ),
      )
      .length;
  int get falsePositiveClaims => results
      .where(
        (result) =>
            result.spec.expectedMechanism == MoveInsightMechanismType.none &&
            result.insight.primaryClaim?.mechanism != null &&
            result.insight.primaryClaim!.mechanism !=
                MoveInsightMechanismType.none,
      )
      .length;
  int get copyFailures => results.where((result) => !result.copySafe).length;
  int get unresolvedHumanReview => results
      .where(
        (result) =>
            result.insight.isDisplayable && !result.spec.humanReviewResolved,
      )
      .length;

  Map<String, Object?> toJson() {
    final familyCounts = <String, Map<String, int>>{};
    final profileCounts = <String, int>{};
    for (final result in results) {
      final family = familyCounts.putIfAbsent(
        result.spec.family,
        () => <String, int>{'positive': 0, 'negative': 0},
      );
      final key = result.spec.expectedMechanism == MoveInsightMechanismType.none
          ? 'negative'
          : 'positive';
      family[key] = family[key]! + 1;
      profileCounts.update(
        result.spec.profile,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return <String, Object?>{
      'corpusVersion': kChapter7TacticalCorpusVersion,
      'explanationPolicyVersion': kApexExplanationPolicyVersion,
      'claimSchemaVersion': kApexExplanationClaimSchemaVersion,
      'rendererVersion': kApexExplanationRendererVersion,
      'analysisSchemaVersion': kApexAnalysisSchemaVersion,
      'activatedFamilies': kChapter7ActivatedFamilies,
      'deferredFamilies': kChapter7DeferredFamilies,
      'totalCases': results.length,
      'positiveCases': positiveCases,
      'negativeCases': negativeCases,
      'passedCases': passed,
      'failedCases': failed,
      'familyCounts': familyCounts,
      'evidenceBuckets': profileCounts,
      'visibleCases': visibleCases,
      'suppressedCases': suppressedCases,
      'contradictoryCases': contradictoryCases,
      'falsePositiveClaims': falsePositiveClaims,
      'forbiddenViolations': forbiddenViolations,
      'copyFailures': copyFailures,
      'duplicateFingerprints': duplicateFingerprints,
      'unresolvedHumanReview': unresolvedHumanReview,
      'causalSelectionDeterministic': results.every(
        (result) => result.deterministic,
      ),
      'performanceMetrics': performance,
      'cases': results.map((result) => result.toJson()).toList(growable: false),
    };
  }

  String claimMatrixCsv() {
    const columns = <String>[
      'case_id',
      'family',
      'profile',
      'mover',
      'played_san',
      'expected_state',
      'required_mechanism',
      'forbidden_mechanisms',
      'actual_outcome',
      'actual_mechanism',
      'relation',
      'target',
      'secondary_target',
      'defender',
      'consequence',
      'better_move',
      'continuation',
      'rendered_sentence',
      'automated_status',
      'human_review',
      'rationale',
    ];
    final rows = <List<String>>[
      columns,
      for (final result in results)
        <String>[
          result.spec.id,
          result.spec.family,
          result.spec.profile,
          result.input.isWhiteMove ? 'white' : 'black',
          result.input.playedMoveSan,
          result.spec.expectedState.name,
          result.spec.expectedMechanism.name,
          (result.spec.forbiddenMechanisms.map((value) => value.name).toList()
                ..sort())
              .join('|'),
          result.insight.primaryClaim?.type.name ?? '',
          result.insight.primaryClaim?.mechanism.name ?? 'none',
          result.insight.primaryClaim?.relationType?.name ?? '',
          result.insight.primaryClaim?.targetRole ?? '',
          result.insight.primaryClaim?.secondaryTargetRole ?? '',
          result.insight.primaryClaim?.defenderRole ?? '',
          result.insight.primaryClaim?.consequence.name ?? '',
          result.insight.primaryClaim?.betterMoveSan ?? '',
          result.insight.primaryClaim?.continuationSan.join(' ') ?? '',
          result.insight.conciseText ?? '',
          result.passed ? 'pass' : 'fail',
          result.spec.humanReviewResolved
              ? 'resolved'
              : result.insight.isDisplayable
              ? 'required'
              : 'not_applicable',
          result.spec.rationale,
        ],
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }
}

const List<Chapter7CorpusCase> kChapter7CorpusCases = <Chapter7CorpusCase>[
  Chapter7CorpusCase(
    id: 'fork_white_gain_001',
    family: 'fork',
    profile: 'offline',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.fork,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'A new king-and-queen fork survives the best response.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'fork_black_gain_001',
    family: 'fork',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.fork,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'Black mover perspective keeps the same causal contract.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'double_attack_gain_001',
    family: 'double_attack',
    profile: 'offline',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.doubleAttack,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'Two newly attacked rooks cannot both be saved.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'absolute_pin_gain_001',
    family: 'absolute_pin',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.absolutePin,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'The rook blocks an exact bishop-to-king ray and is won.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'skewer_gain_001',
    family: 'skewer',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.skewer,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'The checked king moves and the rear rook is captured.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'discovered_line_gain_001',
    family: 'discovered_attack',
    profile: 'offline',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.discoveredAttack,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'A knight check clears the rook line and the queen is won.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'removes_defender_gain_001',
    family: 'removes_defender',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.removesDefender,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'The captured knight was the target rook’s last defender.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'sound_sacrifice_mate_001',
    family: 'sound_sacrifice',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.soundSacrifice,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'A verified queen investment ends in forced mate.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'unsound_sacrifice_loss_001',
    family: 'unsound_sacrifice',
    profile: 'offline',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.unsoundSacrifice,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.soundSacrifice,
    },
    rationale: 'The rook investment is accepted without compensation.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'only_move_avoids_mate_001',
    family: 'only_move_defense',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.onlyMoveDefense,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale: 'Every complete alternative line ends in mate.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'missed_material_resource_001',
    family: 'missed_material_resource',
    profile: 'deep',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.missedMaterialResource,
    forbiddenMechanisms: <MoveInsightMechanismType>{},
    rationale:
        'The stored best line wins a rook while the played move does not.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'fork_no_gain_001',
    family: 'fork',
    profile: 'fast',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.fork,
    },
    rationale: 'Two attacks without a lasting gain are geometry only.',
  ),
  Chapter7CorpusCase(
    id: 'double_attack_attacker_captured_001',
    family: 'double_attack',
    profile: 'offline',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.doubleAttack,
    },
    rationale: 'A target can capture the attacking bishop.',
  ),
  Chapter7CorpusCase(
    id: 'pin_not_exploited_001',
    family: 'absolute_pin',
    profile: 'offline',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.absolutePin,
    },
    rationale: 'Alignment without a won target is not public causality.',
  ),
  Chapter7CorpusCase(
    id: 'pin_piece_captures_attacker_001',
    family: 'absolute_pin',
    profile: 'offline',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.absolutePin,
    },
    rationale: 'The aligned rook legally captures the pinning rook.',
  ),
  Chapter7CorpusCase(
    id: 'skewer_front_captures_attacker_001',
    family: 'skewer',
    profile: 'offline',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.skewer,
    },
    rationale: 'The front queen can capture the alleged skewer piece.',
  ),
  Chapter7CorpusCase(
    id: 'opened_line_no_consequence_001',
    family: 'discovered_attack',
    profile: 'fast',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.discoveredAttack,
    },
    rationale: 'A cleared rook line without exploitation stays silent.',
  ),
  Chapter7CorpusCase(
    id: 'removed_defender_no_exploitation_001',
    family: 'removes_defender',
    profile: 'offline',
    expectedState: MoveInsightState.available,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.removesDefender,
    },
    rationale: 'The capture wins a knight but never exploits the rook.',
    humanReviewResolved: true,
  ),
  Chapter7CorpusCase(
    id: 'temporary_loss_not_sacrifice_001',
    family: 'sound_sacrifice',
    profile: 'fast',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.soundSacrifice,
      MoveInsightMechanismType.unsoundSacrifice,
    },
    rationale: 'Temporary loss without sacrifice evidence cannot name one.',
  ),
  Chapter7CorpusCase(
    id: 'brilliant_label_only_001',
    family: 'sound_sacrifice',
    profile: 'fast',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.soundSacrifice,
    },
    rationale: 'A Brilliant label is not a causal fact.',
  ),
  Chapter7CorpusCase(
    id: 'only_move_nonterminal_alternative_001',
    family: 'only_move_defense',
    profile: 'deep',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.onlyMoveDefense,
    },
    rationale: 'A mate score without a terminal legal alternative is rejected.',
  ),
  Chapter7CorpusCase(
    id: 'stale_after_fen_001',
    family: 'evidence_negative',
    profile: 'offline',
    expectedState: MoveInsightState.contradictory,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.fork,
    },
    rationale: 'A stale after-FEN contradicts the played move.',
  ),
  Chapter7CorpusCase(
    id: 'illegal_continuation_001',
    family: 'evidence_negative',
    profile: 'offline',
    expectedState: MoveInsightState.contradictory,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.fork,
      MoveInsightMechanismType.soundSacrifice,
    },
    rationale: 'An illegal stored reply line cannot support public causality.',
  ),
  Chapter7CorpusCase(
    id: 'contradictory_score_domain_001',
    family: 'evidence_negative',
    profile: 'deep',
    expectedState: MoveInsightState.contradictory,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.onlyMoveDefense,
      MoveInsightMechanismType.missedMaterialResource,
    },
    rationale: 'A score cannot be CP and mate evidence simultaneously.',
  ),
  Chapter7CorpusCase(
    id: 'incomplete_search_001',
    family: 'evidence_negative',
    profile: 'fast',
    expectedState: MoveInsightState.suppressed,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.onlyMoveDefense,
    },
    rationale: 'Incomplete evidence produces suppression, never filler.',
  ),
  Chapter7CorpusCase(
    id: 'black_perspective_inversion_001',
    family: 'perspective_negative',
    profile: 'deep',
    expectedState: MoveInsightState.contradictory,
    expectedMechanism: MoveInsightMechanismType.none,
    forbiddenMechanisms: <MoveInsightMechanismType>{
      MoveInsightMechanismType.fork,
    },
    rationale: 'A White mover flag on a Black move fails closed.',
  ),
];

Chapter7CorpusRun runChapter7TacticalCorpus() {
  const engine = MoveInsightEngine();
  const extractor = MoveInsightFeatureExtractor();
  const detector = MoveInsightClaimDetector();
  const planner = MoveInsightPlanner();
  const renderer = MoveInsightRenderer();
  final extractionUs = <int>[];
  final detectorUs = <int>[];
  final plannerRendererUs = <int>[];
  final generationUs = <int>[];
  final results = <Chapter7CorpusResult>[];

  for (final spec in kChapter7CorpusCases) {
    final input = _corpusInput(spec.id);
    final extractionWatch = Stopwatch()..start();
    final features = extractor.extract(input);
    extractionWatch.stop();
    extractionUs.add(extractionWatch.elapsedMicroseconds);

    final detectorWatch = Stopwatch()..start();
    final candidates = features.contradiction == null
        ? detector.detect(input, features)
        : const <MoveInsightClaimCandidate>[];
    detectorWatch.stop();
    detectorUs.add(detectorWatch.elapsedMicroseconds);

    final plannerWatch = Stopwatch()..start();
    final plan = planner.select(candidates);
    if (plan != null) renderer.render(plan.claim);
    plannerWatch.stop();
    plannerRendererUs.add(plannerWatch.elapsedMicroseconds);

    final generationWatch = Stopwatch()..start();
    final first = engine.generate(input);
    generationWatch.stop();
    generationUs.add(generationWatch.elapsedMicroseconds);
    final second = engine.generate(input);
    final actualMechanism =
        first.primaryClaim?.mechanism ?? MoveInsightMechanismType.none;
    final failures = <String>[];
    if (first.state != spec.expectedState) failures.add('unexpected_state');
    if (actualMechanism != spec.expectedMechanism) {
      failures.add('required_mechanism_missing');
    }
    if (spec.forbiddenMechanisms.contains(actualMechanism)) {
      failures.add('forbidden_mechanism_selected');
    }
    final deterministic =
        first.integrityDigest == second.integrityDigest &&
        first.semanticFingerprint == second.semanticFingerprint;
    final copySafe = _copyIsSafe(first);
    if (!deterministic) failures.add('non_deterministic');
    if (!copySafe) failures.add('copy_invariant');
    if (!first.hasValidStructure) failures.add('invalid_structure');
    if (first.isDisplayable && !spec.humanReviewResolved) {
      failures.add('human_review_unresolved');
    }
    results.add(
      Chapter7CorpusResult(
        spec: spec,
        input: input,
        insight: first,
        deterministic: deterministic,
        copySafe: copySafe,
        passed: failures.isEmpty,
        failures: List<String>.unmodifiable(failures),
      ),
    );
  }

  final fingerprints = <String, List<String>>{};
  for (final result in results) {
    fingerprints
        .putIfAbsent(result.insight.semanticFingerprint, () => <String>[])
        .add(result.spec.id);
  }
  fingerprints.removeWhere((_, ids) => ids.length == 1);

  final timelineWatch = Stopwatch()..start();
  final hundred = <MoveInsight>[];
  for (final input in _legalHundredPlyInputs()) {
    hundred.add(engine.generate(input));
  }
  timelineWatch.stop();
  final persistedBytes = results
      .map((result) => utf8.encode(jsonEncode(result.insight.toJson())).length)
      .toList(growable: false);
  final runtimePerformance = <String, Object?>{
    'units': 'microseconds',
    'attackDefenseGraphExtractionPerCase': _distribution(extractionUs),
    'advancedDetectorPerCase': _distribution(detectorUs),
    'plannerRendererPerCase': _distribution(plannerRendererUs),
    'fullGenerationPerCase': _distribution(generationUs),
    'corpusTotalUs': generationUs.fold<int>(0, (sum, value) => sum + value),
    'legal100PlyTimelineUs': timelineWatch.elapsedMicroseconds,
    'legal100PlyGeneratedInsights': hundred.length,
    'ordinaryExplanationSpecificEngineSearches': 0,
    'persistedInsightBytes': _distribution(persistedBytes),
  };
  final performance = <String, Object?>{
    'units': 'deterministic_counts_and_bytes',
    'attackDefenseGraphExtractions': results.length,
    'advancedDetectorExecutions': results.length,
    'plannerRendererExecutions': results.length,
    'fullGenerations': results.length,
    'legal100PlyGeneratedInsights': hundred.length,
    'ordinaryExplanationSpecificEngineSearches': 0,
    'persistedInsightBytes': _distribution(persistedBytes),
  };
  return Chapter7CorpusRun(
    results: List<Chapter7CorpusResult>.unmodifiable(results),
    performance: performance,
    runtimePerformance: runtimePerformance,
    duplicateFingerprints: fingerprints,
  );
}

MoveInsightInput _corpusInput(String id) {
  switch (id) {
    case 'fork_white_gain_001':
      return _input(
        fen: 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1',
        uci: 'b5c7',
        playedScore: const ClassificationScore.cp(700),
        postMoves: const <String>['e8f8', 'c7a8', 'f8g8'],
      );
    case 'fork_black_gain_001':
      return _input(
        fen: '4k3/8/8/8/1n6/8/8/Q3K3 b - - 0 1',
        uci: 'b4c2',
        playedScore: const ClassificationScore.cp(-700),
        postMoves: const <String>['e1f1', 'c2a1', 'f1g1'],
      );
    case 'double_attack_gain_001':
      return _input(
        fen: '4k3/8/6r1/8/8/8/2r1B3/4K3 w - - 0 1',
        uci: 'e2d3',
        playedScore: const ClassificationScore.cp(500),
        postMoves: const <String>['g6g8', 'd3c2', 'e8f7'],
      );
    case 'absolute_pin_gain_001':
      return _input(
        fen: '4k3/7p/2r5/8/8/8/4B3/4K3 w - - 0 1',
        uci: 'e2b5',
        playedScore: const ClassificationScore.cp(500),
        postMoves: const <String>['h7h6', 'b5c6', 'e8f8'],
      );
    case 'skewer_gain_001':
      return _input(
        fen: '4r3/3k4/8/8/8/8/4B3/5K2 w - - 0 1',
        uci: 'e2b5',
        playedScore: const ClassificationScore.cp(500),
        postMoves: const <String>['d7c8', 'b5e8', 'c8b7'],
      );
    case 'discovered_line_gain_001':
      return _input(
        fen: 'q7/8/8/3k4/8/8/N7/R3K3 w - - 0 1',
        uci: 'a2b4',
        playedScore: const ClassificationScore.cp(800),
        postMoves: const <String>['d5e5', 'a1a8', 'e5d4'],
      );
    case 'removes_defender_gain_001':
      return _input(
        fen: '6k1/8/8/3n4/2B2r2/4Q3/8/4K3 w - - 0 1',
        uci: 'c4d5',
        playedScore: const ClassificationScore.cp(800),
        postMoves: const <String>['g8h8', 'e3f4', 'h8g7'],
      );
    case 'sound_sacrifice_mate_001':
      const fen = '5r1k/6pp/4Q2N/8/8/8/8/4K3 w - - 0 1';
      return _input(
        fen: fen,
        uci: 'e6g8',
        classification: MoveQuality.brilliant,
        beforeScore: const ClassificationScore.mate(3),
        playedScore: const ClassificationScore.mate(1),
        preLines: <EngineLine>[
          _line(fen, const <String>['e6g8', 'f8g8', 'h6f7'], mate: 1),
        ],
        postMoves: const <String>['f8g8', 'h6f7'],
        isSacrifice: true,
        isFirstSacrificePly: true,
        tacticalBestOrNearBest: true,
        tacticalHasForcingOutcome: true,
        tacticalForcedMate: true,
        verificationState: ClassificationVerificationState.complete,
      );
    case 'unsound_sacrifice_loss_001':
      const fen = '4k3/8/8/8/8/8/2q5/R3K3 w Q - 0 1';
      return _input(
        fen: fen,
        uci: 'a1a2',
        classification: MoveQuality.blunder,
        playedScore: const ClassificationScore.cp(-500),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'a1a8',
        bestMoveSan: 'Ra8+',
        preLines: <EngineLine>[
          _line(fen, const <String>['a1a8', 'e8e7'], cp: 0),
        ],
        postMoves: const <String>['c2a2', 'e1f1'],
        isSacrifice: true,
        isFirstSacrificePly: true,
      );
    case 'only_move_avoids_mate_001':
      const fen = 'k2r4/8/1b6/8/4b2b/8/P5PP/7K w - - 0 1';
      return _input(
        fen: fen,
        uci: 'h2h3',
        classification: MoveQuality.onlyMove,
        playedScore: const ClassificationScore.cp(0),
        legalMoveCount: 3,
        preLines: <EngineLine>[
          _line(fen, const <String>['h2h3', 'd8d1', 'h1h2'], cp: 0),
          _line(fen, const <String>['a2a3', 'd8d1'], mate: -1, rank: 2),
          _line(fen, const <String>['a2a4', 'd8d1'], mate: -1, rank: 3),
        ],
      );
    case 'missed_material_resource_001':
      const fen = '4k3/8/8/8/8/8/2r5/3QK3 w - - 0 1';
      return _input(
        fen: fen,
        uci: 'e1f1',
        classification: MoveQuality.missedWin,
        playedScore: const ClassificationScore.cp(0),
        bestScore: const ClassificationScore.cp(500),
        bestMoveUci: 'd1c2',
        bestMoveSan: 'Qxc2',
        preLines: <EngineLine>[
          _line(fen, const <String>['d1c2', 'e8f7', 'c2c7'], cp: 500),
        ],
      );
    case 'fork_no_gain_001':
      return _input(
        fen: 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1',
        uci: 'b5c7',
        playedScore: const ClassificationScore.cp(0),
        postMoves: const <String>['e8f8', 'c7b5'],
      );
    case 'double_attack_attacker_captured_001':
      return _input(
        fen: '4k3/8/6q1/8/8/8/2r1B3/4K3 w - - 0 1',
        uci: 'e2d3',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(-300),
        postMoves: const <String>['g6d3'],
      );
    case 'pin_not_exploited_001':
      return _input(
        fen: '4k3/p2r4/8/8/8/8/4B3/4K3 w - - 0 1',
        uci: 'e2b5',
        playedScore: const ClassificationScore.cp(0),
        postMoves: const <String>['a7a6', 'b5c4'],
      );
    case 'pin_piece_captures_attacker_001':
      return _input(
        fen: '3k4/3r4/8/8/8/8/8/R3K3 w - - 0 1',
        uci: 'a1d1',
        playedScore: const ClassificationScore.cp(0),
        postMoves: const <String>['d7d1', 'e1d1'],
      );
    case 'skewer_front_captures_attacker_001':
      return _input(
        fen: '4r2k/3q4/8/8/8/8/4B3/5K2 w - - 0 1',
        uci: 'e2b5',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(-300),
        postMoves: const <String>['d7b5'],
      );
    case 'opened_line_no_consequence_001':
      return _input(
        fen: 'q7/8/8/3k4/8/8/N7/R3K3 w - - 0 1',
        uci: 'a2b4',
        playedScore: const ClassificationScore.cp(0),
        postMoves: const <String>['d5e5', 'a1a2'],
      );
    case 'removed_defender_no_exploitation_001':
      return _input(
        fen: '6k1/8/8/3n4/2B2r2/4Q3/8/4K3 w - - 0 1',
        uci: 'c4d5',
        playedScore: const ClassificationScore.cp(300),
        postMoves: const <String>['g8h8', 'e3e2'],
      );
    case 'temporary_loss_not_sacrifice_001':
      return _input(
        fen: '4k3/8/8/8/8/8/2q5/R3K3 w Q - 0 1',
        uci: 'a1a2',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(-500),
        postMoves: const <String>['c2a2', 'e1f1'],
      );
    case 'brilliant_label_only_001':
      return _input(
        fen: '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1',
        uci: 'e2e4',
        classification: MoveQuality.brilliant,
        playedScore: const ClassificationScore.cp(20),
      );
    case 'only_move_nonterminal_alternative_001':
      const fen = '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1';
      return _input(
        fen: fen,
        uci: 'e2e4',
        classification: MoveQuality.onlyMove,
        playedScore: const ClassificationScore.cp(0),
        preLines: <EngineLine>[
          _line(fen, const <String>['e2e4', 'e8f7'], cp: 0),
          _line(fen, const <String>['e2e3', 'e8f7'], mate: -1, rank: 2),
        ],
      );
    case 'stale_after_fen_001':
      return _input(
        fen: 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1',
        uci: 'b5c7',
        playedScore: const ClassificationScore.cp(700),
        fenAfterOverride: 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1',
      );
    case 'illegal_continuation_001':
      return _input(
        fen: '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1',
        uci: 'e2e4',
        playedScore: const ClassificationScore.cp(0),
        postMoveLinesOverride: const <EngineLine>[
          EngineLine(
            rank: 1,
            moveUci: 'e8f7',
            moveSan: 'Kf7',
            scoreCp: 0,
            depth: 20,
            whiteWinPercent: 50,
            pvMoves: <String>['e8f7', 'e2e4'],
          ),
        ],
      );
    case 'contradictory_score_domain_001':
      return _input(
        fen: '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1',
        uci: 'e2e4',
        playedScore: const ClassificationScore(whiteCp: 0, whiteMate: 2),
      );
    case 'incomplete_search_001':
      return _input(
        fen: '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1',
        uci: 'e2e4',
        classification: MoveQuality.onlyMove,
        playedScore: const ClassificationScore.cp(0),
        searchQualityMet: false,
      );
    case 'black_perspective_inversion_001':
      return _input(
        fen: '4k3/8/8/8/1n6/8/8/Q3K3 b - - 0 1',
        uci: 'b4c2',
        playedScore: const ClassificationScore.cp(-700),
        isWhiteMoveOverride: true,
      );
  }
  throw ArgumentError.value(id, 'id', 'Unknown Chapter 7 corpus case');
}

MoveInsightInput _input({
  required String fen,
  required String uci,
  MoveQuality classification = MoveQuality.best,
  ClassificationScore beforeScore = const ClassificationScore.cp(0),
  required ClassificationScore playedScore,
  ClassificationScore? bestScore,
  String? bestMoveUci,
  String? bestMoveSan,
  List<EngineLine> preLines = const <EngineLine>[],
  List<String> postMoves = const <String>[],
  List<EngineLine>? postMoveLinesOverride,
  bool searchQualityMet = true,
  bool isSacrifice = false,
  bool isFirstSacrificePly = false,
  bool tacticalBestOrNearBest = false,
  bool tacticalHasForcingOutcome = false,
  bool tacticalForcedMate = false,
  int? legalMoveCount,
  ClassificationVerificationState verificationState =
      ClassificationVerificationState.notRequested,
  String? fenAfterOverride,
  bool? isWhiteMoveOverride,
}) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final move = _move(position, uci);
  final after = position.play(move);
  final candidates = <ClassificationCandidateEvidence>[
    for (final line in preLines)
      ClassificationCandidateEvidence(
        rootUci: line.moveUci!,
        rank: line.rank,
        score: line.scoreCp != null
            ? ClassificationScore.cp(line.scoreCp!)
            : ClassificationScore.mate(line.mateIn!),
        achievedDepth: line.depth,
        isLegal: true,
        pvComplete: true,
      ),
  ];
  final actualBest = bestMoveUci ?? preLines.firstOrNull?.moveUci ?? uci;
  final actualBestScore =
      bestScore ??
      (preLines.firstOrNull?.scoreCp != null
          ? ClassificationScore.cp(preLines.first.scoreCp!)
          : preLines.firstOrNull?.mateIn != null
          ? ClassificationScore.mate(preLines.first.mateIn!)
          : playedScore);
  final evidence = MoveClassificationEvidence(
    mover: position.turn == Side.white
        ? ClassificationMover.white
        : ClassificationMover.black,
    evaluationBefore: beforeScore,
    playedMoveEvaluation: playedScore,
    bestMoveEvaluation: actualBestScore,
    playedMoveUci: uci,
    bestMoveUci: actualBest,
    candidates: candidates,
    requestedMultiPv: preLines.isEmpty ? 1 : preLines.length,
    receivedMultiPv: preLines.length,
    candidateSetComplete: preLines.isNotEmpty,
    candidateSetCoherent: preLines.isNotEmpty,
    bestMovePv1Consistent:
        preLines.isNotEmpty && preLines.first.moveUci == actualBest,
    searchQualityMet: searchQualityMet,
    legalMoveCount: legalMoveCount,
    verificationState: verificationState,
    forcedState: ClassificationForcedState.notForced,
    bookState: ClassificationBookState.notBook,
    isSacrifice: isSacrifice,
    isFirstSacrificePly: isFirstSacrificePly,
    isRecapture: false,
    isTrivialRecapture: false,
    isFreeCapture: false,
    tacticalBestOrNearBest: tacticalBestOrNearBest,
    tacticalHasForcingOutcome: tacticalHasForcingOutcome,
    tacticalForcedMate: tacticalForcedMate,
  );
  return MoveInsightInput(
    fenBefore: fen,
    fenAfter: fenAfterOverride ?? after.fen,
    playedMoveUci: uci,
    playedMoveSan: position.makeSan(move).$2,
    isWhiteMove: isWhiteMoveOverride ?? (position.turn == Side.white),
    classification: classification,
    classificationEvidence: evidence,
    preMoveLines: preLines,
    postMoveLines:
        postMoveLinesOverride ??
        (postMoves.isEmpty
            ? const <EngineLine>[]
            : <EngineLine>[
                _line(
                  after.fen,
                  postMoves,
                  cp: playedScore.whiteCp,
                  mate: playedScore.whiteMate,
                ),
              ]),
    postMoveSearchQualityMet: searchQualityMet,
    engineBestMoveSan: bestMoveSan,
    openingEvidence: _noOpening(fen, after.fen, uci),
  );
}

EngineLine _line(
  String fen,
  List<String> moves, {
  int rank = 1,
  int? cp,
  int? mate,
}) {
  Position position = Chess.fromSetup(Setup.parseFen(fen));
  final first = _move(position, moves.first);
  final firstSan = position.makeSan(first).$2;
  for (final uci in moves) {
    position = position.play(_move(position, uci));
  }
  return EngineLine(
    rank: rank,
    moveUci: moves.first,
    moveSan: firstSan,
    scoreCp: cp,
    mateIn: mate,
    depth: 20,
    whiteWinPercent: mate == null ? 50 : (mate > 0 ? 100 : 0),
    pvMoves: moves,
  );
}

NormalMove _move(Position position, String uci) {
  final move = NormalMove(
    from: _square(uci.substring(0, 2)),
    to: _square(uci.substring(2, 4)),
  );
  if (!position.isLegal(move)) {
    throw StateError('$uci must be legal in ${position.fen}');
  }
  return move;
}

Square _square(String value) =>
    Square(value.codeUnitAt(0) - 97 + (value.codeUnitAt(1) - 49) * 8);

OpeningEvidence _noOpening(String before, String after, String uci) =>
    OpeningEvidence(
      artifact: kApexOpeningArtifactIdentity,
      artifactVerification: OpeningArtifactVerification.verified,
      state: OpeningMatchState.noMatch,
      beforePositionKey: OpeningPositionKey.fromFen(before).value,
      afterPositionKey: OpeningPositionKey.fromFen(after).value,
      playedUci: uci,
      transitionVerified: false,
      totalCandidateCount: 0,
      matchedPly: 1,
      reasonCode: 'position_and_transition_not_found',
    );

List<MoveInsightInput> _legalHundredPlyInputs() {
  final moves = <String>[
    for (var i = 0; i < 12; i++) ...<String>['g1f3', 'g8f6', 'f3g1', 'f6g8'],
    'a2a3',
    'a7a6',
    for (var i = 0; i < 12; i++) ...<String>['b1c3', 'b8c6', 'c3b1', 'c6b8'],
    'h2h3',
    'h7h6',
  ];
  Position position = Chess.initial;
  final inputs = <MoveInsightInput>[];
  for (final uci in moves) {
    final move = _move(position, uci);
    inputs.add(
      _input(
        fen: position.fen,
        uci: uci,
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      ),
    );
    position = position.play(move);
  }
  return inputs;
}

Map<String, int> _distribution(List<int> values) {
  final sorted = List<int>.of(values)..sort();
  if (sorted.isEmpty) return const <String, int>{'count': 0};
  int percentile(double value) =>
      sorted[((sorted.length - 1) * value).round().clamp(0, sorted.length - 1)];
  return <String, int>{
    'count': sorted.length,
    'min': sorted.first,
    'p50': percentile(0.50),
    'p95': percentile(0.95),
    'max': sorted.last,
    'total': sorted.fold<int>(0, (sum, value) => sum + value),
  };
}

bool _copyIsSafe(MoveInsight insight) {
  final text = <String?>[
    insight.conciseText,
    insight.causeText,
    insight.consequenceText,
    insight.betterMoveText,
    insight.continuationText,
  ].whereType<String>().join(' ').toLowerCase();
  if (!insight.isDisplayable) return text.isEmpty;
  return text.isNotEmpty &&
      !RegExp(
        r'\b(stockfish|uci|fen|multipv|centipawn|classifier|policy|detector|candidate|evidence|verified|pv)\b',
      ).hasMatch(text) &&
      !text.contains('this is a brilliant') &&
      !text.contains('this is a great move');
}

String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';
