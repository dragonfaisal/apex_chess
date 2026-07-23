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

const int kChapter6ExplanationCorpusVersion = 1;

class Chapter6CorpusCase {
  const Chapter6CorpusCase({
    required this.id,
    required this.family,
    required this.profile,
    required this.allowedClaims,
    this.requiredClaims = const <String>{},
    this.forbiddenClaims = const <String>{},
    required this.allowedStates,
    required this.rationale,
    required this.provenance,
    this.expectedPieces = const <String>[],
    this.expectedSquares = const <String>[],
    this.betterMoveRequired = false,
    this.humanReviewResolved = false,
  });

  final String id;
  final String family;
  final String profile;
  final Set<String> allowedClaims;
  final Set<String> requiredClaims;
  final Set<String> forbiddenClaims;
  final Set<MoveInsightState> allowedStates;
  final String rationale;
  final String provenance;
  final List<String> expectedPieces;
  final List<String> expectedSquares;
  final bool betterMoveRequired;
  final bool humanReviewResolved;
}

class Chapter6CorpusCaseResult {
  const Chapter6CorpusCaseResult({
    required this.spec,
    required this.input,
    required this.insight,
    required this.actualClaims,
    required this.copyInvariantPassed,
    required this.deterministic,
    required this.passed,
    required this.failureReasons,
  });

  final Chapter6CorpusCase spec;
  final MoveInsightInput input;
  final MoveInsight insight;
  final Set<String> actualClaims;
  final bool copyInvariantPassed;
  final bool deterministic;
  final bool passed;
  final List<String> failureReasons;

  Map<String, Object?> toJson() => <String, Object?>{
    'caseId': spec.id,
    'corpusVersion': kChapter6ExplanationCorpusVersion,
    'family': spec.family,
    'profile': spec.profile,
    'fenBefore': input.fenBefore,
    'playedMoveUci': input.playedMoveUci,
    'playedMoveSan': input.playedMoveSan,
    'fenAfter': input.fenAfter,
    'mover': input.isWhiteMove ? 'white' : 'black',
    'trustedEvidence': <String, Object?>{
      'classification': input.classification.name,
      'classificationEvidence': input.classificationEvidence.toJson(),
      'preMoveLines': input.preMoveLines
          .map((line) => line.toJson())
          .toList(growable: false),
      'postMoveLines': input.postMoveLines
          .map((line) => line.toJson())
          .toList(growable: false),
      'postMoveSearchQualityMet': input.postMoveSearchQualityMet,
      'openingEvidence': input.openingEvidence.toJson(),
    },
    'allowedPrimaryClaims': spec.allowedClaims.toList()..sort(),
    'requiredClaims': spec.requiredClaims.toList()..sort(),
    'forbiddenClaims': spec.forbiddenClaims.toList()..sort(),
    'expectedPieces': spec.expectedPieces,
    'expectedSquares': spec.expectedSquares,
    'allowedStates': spec.allowedStates.map((state) => state.name).toList()
      ..sort(),
    'actualSelectedClaim': insight.primaryClaim?.type.name,
    'actualSupportingClaims': insight.supportingClaims
        .map((claim) => claim.type.name)
        .toList(growable: false),
    'suppressionReason': insight.suppressionReason,
    'finalState': insight.state.name,
    'renderedCopySample': insight.conciseText,
    'betterMoveFact': insight.primaryClaim?.betterMoveSan,
    'continuationFact': insight.primaryClaim?.continuationSan,
    'semanticFingerprint': insight.semanticFingerprint,
    'deterministic': deterministic,
    'copyInvariantPassed': copyInvariantPassed,
    'automatedStatus': passed ? 'pass' : 'fail',
    'humanReviewStatus': spec.humanReviewResolved
        ? 'resolved'
        : spec.allowedStates.contains(MoveInsightState.available)
        ? 'required'
        : 'not_applicable',
    'failureReasons': failureReasons,
    'rationale': spec.rationale,
    'provenance': spec.provenance,
  };
}

class Chapter6CorpusRun {
  const Chapter6CorpusRun({
    required this.results,
    required this.performance,
    required this.duplicateFingerprints,
  });

  final List<Chapter6CorpusCaseResult> results;
  final Map<String, Object?> performance;
  final Map<String, List<String>> duplicateFingerprints;

  int get passed => results.where((result) => result.passed).length;
  int get failed => results.length - passed;
  int get humanReviewCases =>
      results.where((result) => result.spec.humanReviewResolved).length;
  int get unresolvedHumanReviewCases => results.where((result) {
    return result.spec.allowedStates.contains(MoveInsightState.available) &&
        !result.spec.humanReviewResolved;
  }).length;
  int get forbiddenClaimViolations => results.where((result) {
    return result.actualClaims
        .intersection(result.spec.forbiddenClaims)
        .isNotEmpty;
  }).length;
  int get falsePositiveClaims => results
      .where((result) {
        return !result.spec.allowedClaims.containsAll(result.actualClaims);
      })
      .fold<int>(0, (total, result) {
        return total +
            result.actualClaims.difference(result.spec.allowedClaims).length;
      });
  int get copyInvariantFailures =>
      results.where((result) => !result.copyInvariantPassed).length;
  int get unexplainableCases => results
      .where((result) => result.insight.state != MoveInsightState.available)
      .length;

  Map<String, Object?> toJson() {
    final familyCounts = <String, int>{};
    final stateCounts = <String, int>{};
    final profileCounts = <String, Map<String, int>>{};
    for (final result in results) {
      familyCounts.update(
        result.spec.family,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      stateCounts.update(
        result.insight.state.name,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      final profile = profileCounts.putIfAbsent(
        result.spec.profile,
        () => <String, int>{'cases': 0, 'available': 0, 'suppressed': 0},
      );
      profile['cases'] = profile['cases']! + 1;
      if (result.insight.state == MoveInsightState.available) {
        profile['available'] = profile['available']! + 1;
      } else {
        profile['suppressed'] = profile['suppressed']! + 1;
      }
    }
    return <String, Object?>{
      'corpusVersion': kChapter6ExplanationCorpusVersion,
      'explanationPolicyVersion': kApexExplanationPolicyVersion,
      'claimSchemaVersion': kApexExplanationClaimSchemaVersion,
      'rendererVersion': kApexExplanationRendererVersion,
      'totalCases': results.length,
      'passedCases': passed,
      'failedCases': failed,
      'claimFamilyCounts': familyCounts,
      'stateCounts': stateCounts,
      'profileCoverage': profileCounts,
      'falsePositiveClaims': falsePositiveClaims,
      'forbiddenClaimViolations': forbiddenClaimViolations,
      'copyInvariantFailures': copyInvariantFailures,
      'duplicateFingerprints': duplicateFingerprints,
      'unexplainableCases': unexplainableCases,
      'humanReviewCases': humanReviewCases,
      'unresolvedHumanReviewCases': unresolvedHumanReviewCases,
      'claimSelectionDeterministic': results.every(
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
      'required_claims',
      'forbidden_claims',
      'actual_claim',
      'state',
      'suppression_reason',
      'better_move',
      'continuation',
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
          (result.spec.requiredClaims.toList()..sort()).join('|'),
          (result.spec.forbiddenClaims.toList()..sort()).join('|'),
          result.insight.primaryClaim?.type.name ?? '',
          result.insight.state.name,
          result.insight.suppressionReason ?? '',
          result.insight.primaryClaim?.betterMoveSan ?? '',
          result.insight.primaryClaim?.continuationSan.join(' ') ?? '',
          result.passed ? 'pass' : 'fail',
          result.spec.humanReviewResolved
              ? 'resolved'
              : result.spec.allowedStates.contains(MoveInsightState.available)
              ? 'required'
              : 'not_applicable',
          result.spec.rationale,
        ],
    ];
    return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
  }
}

const List<Chapter6CorpusCase> kChapter6CorpusCases = <Chapter6CorpusCase>[
  Chapter6CorpusCase(
    id: 'mate_white_001',
    family: 'forced_outcome',
    profile: 'fast',
    allowedClaims: <String>{'deliversMate'},
    requiredClaims: <String>{'deliversMate'},
    forbiddenClaims: <String>{'matingAttack'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale: 'Legal terminal state proves White delivered mate.',
    provenance: 'project_generated_legal_position',
    expectedPieces: <String>['white queen'],
    expectedSquares: <String>['f7'],
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'mate_black_001',
    family: 'forced_outcome',
    profile: 'fast',
    allowedClaims: <String>{'deliversMate'},
    requiredClaims: <String>{'deliversMate'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale:
        'Black mate remains in White-score mate domain and mover perspective.',
    provenance: 'project_generated_legal_position',
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'stalemate_001',
    family: 'forced_outcome',
    profile: 'fast',
    allowedClaims: <String>{'createsStalemate'},
    requiredClaims: <String>{'createsStalemate'},
    forbiddenClaims: <String>{'deliversMate'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale: 'The exact post-move board is stalemate rather than checkmate.',
    provenance: 'project_generated_legal_position',
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'allows_mate_001',
    family: 'forced_outcome',
    profile: 'deep',
    allowedClaims: <String>{'allowsForcedMate'},
    requiredClaims: <String>{'allowsForcedMate'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale: 'Stored legal reply ends in mate and the best move avoids it.',
    provenance: 'curated_tactical_case',
    betterMoveRequired: true,
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'missing_mate_pv_001',
    family: 'forced_outcome_negative',
    profile: 'fast',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'allowsForcedMate'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'A mate score without a stored legal reply cannot explain the mechanism.',
    provenance: 'adversarial_incomplete_evidence',
  ),
  Chapter6CorpusCase(
    id: 'misses_mate_001',
    family: 'forced_outcome',
    profile: 'deep',
    allowedClaims: <String>{'missesForcedMate'},
    requiredClaims: <String>{'missesForcedMate'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale:
        'PV1 legally mates while the played continuation leaves mate domain.',
    provenance: 'curated_tactical_case',
    betterMoveRequired: true,
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'preserves_mate_001',
    family: 'forced_outcome',
    profile: 'deep',
    allowedClaims: <String>{'preservesForcedMate'},
    requiredClaims: <String>{'preservesForcedMate'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale:
        'The stored legal continuation verifies that the mate remains forced.',
    provenance: 'curated_tactical_case',
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'drops_rook_001',
    family: 'material',
    profile: 'deep',
    allowedClaims: <String>{'dropsMaterial'},
    requiredClaims: <String>{'dropsMaterial'},
    forbiddenClaims: <String>{'soundMaterialInvestment'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale: 'The best-response continuation proves a lasting rook loss.',
    provenance: 'curated_tactical_case',
    expectedPieces: <String>['white rook'],
    expectedSquares: <String>['a2'],
    betterMoveRequired: true,
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'wins_rook_001',
    family: 'material',
    profile: 'offline',
    allowedClaims: <String>{'winsMaterial'},
    requiredClaims: <String>{'winsMaterial'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale: 'A legal opponent reply still leaves a sustained rook gain.',
    provenance: 'curated_tactical_case',
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'temporary_material_001',
    family: 'material_negative',
    profile: 'offline',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'winsMaterial', 'soundMaterialInvestment'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'An adverse stored score prevents a geometric capture from becoming a material-win claim.',
    provenance: 'adversarial_temporary_material',
  ),
  Chapter6CorpusCase(
    id: 'promotion_001',
    family: 'promotion',
    profile: 'fast',
    allowedClaims: <String>{'promotes'},
    requiredClaims: <String>{'promotes'},
    forbiddenClaims: <String>{'winsPromotionRace'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale: 'Legal move notation and post-board prove promotion to a queen.',
    provenance: 'project_generated_legal_position',
    expectedSquares: <String>['a8'],
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'recapture_001',
    family: 'material',
    profile: 'fast',
    allowedClaims: <String>{'recaptures'},
    requiredClaims: <String>{'recaptures'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale:
        'Trusted recapture evidence is corroborated by an exact legal capture.',
    provenance: 'project_generated_legal_position',
    expectedSquares: <String>['e4'],
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'book_transition_001',
    family: 'opening',
    profile: 'fast',
    allowedClaims: <String>{'bookTransition'},
    requiredClaims: <String>{'bookTransition'},
    forbiddenClaims: <String>{'strategicJustification'},
    allowedStates: <MoveInsightState>{MoveInsightState.available},
    rationale:
        'Verified Opening V2 transition may identify theory without tactical claims.',
    provenance: 'apex_opening_fixture',
    humanReviewResolved: true,
  ),
  Chapter6CorpusCase(
    id: 'check_not_mate_001',
    family: 'geometry_negative',
    profile: 'fast',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'deliversMate', 'matingAttack'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'A check and mate-domain score without a complete mating line is not a mating explanation.',
    provenance: 'adversarial_geometry',
  ),
  Chapter6CorpusCase(
    id: 'incomplete_search_001',
    family: 'evidence_negative',
    profile: 'fast',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'onlyMove', 'winsMaterial'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale: 'Incomplete search evidence must produce explicit suppression.',
    provenance: 'adversarial_incomplete_evidence',
  ),
  Chapter6CorpusCase(
    id: 'contradictory_after_fen_001',
    family: 'evidence_negative',
    profile: 'offline',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'bookTransition', 'winsMaterial'},
    allowedStates: <MoveInsightState>{MoveInsightState.contradictory},
    rationale:
        'A stale or wrong-ply after-FEN contradicts the legal move transition.',
    provenance: 'adversarial_stale_fact',
  ),
  Chapter6CorpusCase(
    id: 'label_only_brilliant_001',
    family: 'label_negative',
    profile: 'fast',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'brilliantSacrifice', 'onlyMove'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale: 'A special label alone is never accepted as causal evidence.',
    provenance: 'chapter4_adversarial_label',
  ),
  Chapter6CorpusCase(
    id: 'best_without_cause_001',
    family: 'label_negative',
    profile: 'fast',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'genericBestMove'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'A best move with no concrete causal distinction receives no filler.',
    provenance: 'adversarial_label_only',
  ),
  Chapter6CorpusCase(
    id: 'castling_without_attack_001',
    family: 'king_safety_negative',
    profile: 'offline',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'improvesKingSafety'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'Castling alone does not prove that an immediate danger was resolved.',
    provenance: 'adversarial_strategy',
  ),
  Chapter6CorpusCase(
    id: 'two_attacks_no_fork_001',
    family: 'geometry_negative',
    profile: 'offline',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'fork', 'doubleAttack'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'Two geometric attacks without a forced valuable consequence are not a meaningful fork.',
    provenance: 'adversarial_geometry',
  ),
  Chapter6CorpusCase(
    id: 'opened_line_no_consequence_001',
    family: 'geometry_negative',
    profile: 'offline',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'opensLine', 'discoveredAttack'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'An opened line without a verified consequence is intentionally omitted.',
    provenance: 'adversarial_geometry',
  ),
  Chapter6CorpusCase(
    id: 'pinned_looking_piece_001',
    family: 'geometry_negative',
    profile: 'offline',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'pin', 'winsMaterial'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'A pinned-looking piece that has a legal move cannot create a pin claim.',
    provenance: 'adversarial_geometry',
  ),
  Chapter6CorpusCase(
    id: 'defender_removed_no_target_001',
    family: 'defender_negative',
    profile: 'deep',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'removesDefender', 'deflection'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale:
        'Capturing a defender without an exploitable target proves no causal defender claim.',
    provenance: 'adversarial_defender',
  ),
  Chapter6CorpusCase(
    id: 'passed_pawn_loses_race_001',
    family: 'promotion_negative',
    profile: 'deep',
    allowedClaims: <String>{},
    forbiddenClaims: <String>{'winsPromotionRace', 'createsPassedPawn'},
    allowedStates: <MoveInsightState>{MoveInsightState.suppressed},
    rationale: 'Pawn distance alone cannot prove a promotion race.',
    provenance: 'adversarial_pawn_race',
  ),
];

Chapter6CorpusRun runChapter6ExplanationCorpus() {
  const engine = MoveInsightEngine();
  const extractor = MoveInsightFeatureExtractor();
  const detector = MoveInsightClaimDetector();
  const planner = MoveInsightPlanner();
  const renderer = MoveInsightRenderer();
  final extractionUs = <int>[];
  final detectorUs = <int>[];
  final plannerRendererUs = <int>[];
  final totalUs = <int>[];
  final results = <Chapter6CorpusCaseResult>[];

  for (final spec in kChapter6CorpusCases) {
    final input = _corpusInput(spec.id);
    final stageWatch = Stopwatch()..start();
    final features = extractor.extract(input);
    stageWatch.stop();
    extractionUs.add(stageWatch.elapsedMicroseconds);

    List<MoveInsightClaimCandidate> candidates =
        const <MoveInsightClaimCandidate>[];
    if (features.contradiction == null) {
      stageWatch
        ..reset()
        ..start();
      candidates = detector.detect(input, features);
      stageWatch.stop();
      detectorUs.add(stageWatch.elapsedMicroseconds);
      stageWatch
        ..reset()
        ..start();
      final plan = planner.select(candidates);
      if (plan != null) renderer.render(plan.claim);
      stageWatch.stop();
      plannerRendererUs.add(stageWatch.elapsedMicroseconds);
    }

    final totalWatch = Stopwatch()..start();
    final first = engine.generate(input);
    totalWatch.stop();
    totalUs.add(totalWatch.elapsedMicroseconds);
    final second = engine.generate(input);
    final actualClaims = <String>{
      if (first.primaryClaim != null) first.primaryClaim!.type.name,
      ...first.supportingClaims.map((claim) => claim.type.name),
    };
    final copyInvariantPassed = _copyIsSafe(first);
    final deterministic =
        first.integrityDigest == second.integrityDigest &&
        first.semanticFingerprint == second.semanticFingerprint;
    final failures = <String>[];
    if (!spec.allowedStates.contains(first.state)) {
      failures.add('unexpected_state');
    }
    if (!actualClaims.containsAll(spec.requiredClaims)) {
      failures.add('required_claim_missing');
    }
    if (!spec.allowedClaims.containsAll(actualClaims)) {
      failures.add('false_positive_claim');
    }
    if (actualClaims.intersection(spec.forbiddenClaims).isNotEmpty) {
      failures.add('forbidden_claim_selected');
    }
    if (spec.betterMoveRequired &&
        first.primaryClaim?.betterMoveSan?.isNotEmpty != true) {
      failures.add('better_move_missing');
    }
    if (!_referencesExpectedPieces(first, spec.expectedPieces)) {
      failures.add('expected_piece_reference_missing');
    }
    if (!_referencesExpectedSquares(first, spec.expectedSquares)) {
      failures.add('expected_square_reference_missing');
    }
    if (spec.allowedStates.contains(MoveInsightState.available) &&
        !spec.humanReviewResolved) {
      failures.add('human_review_unresolved');
    }
    if (!first.hasValidStructure) failures.add('invalid_structure');
    if (!copyInvariantPassed) failures.add('copy_invariant');
    if (!deterministic) failures.add('non_deterministic');
    results.add(
      Chapter6CorpusCaseResult(
        spec: spec,
        input: input,
        insight: first,
        actualClaims: actualClaims,
        copyInvariantPassed: copyInvariantPassed,
        deterministic: deterministic,
        passed: failures.isEmpty,
        failureReasons: List<String>.unmodifiable(failures),
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
  final performanceInsights = <MoveInsight>[];
  for (final input in _legalHundredPlyInputs()) {
    performanceInsights.add(engine.generate(input));
  }
  timelineWatch.stop();
  final persistedSizes = results
      .map((result) => utf8.encode(jsonEncode(result.insight.toJson())).length)
      .toList(growable: false);
  final performance = <String, Object?>{
    'units': 'microseconds',
    'featureExtractionPerCase': _distribution(extractionUs),
    'detectorPerCase': _distribution(detectorUs),
    'plannerRendererPerCase': _distribution(plannerRendererUs),
    'fullGenerationPerCase': _distribution(totalUs),
    'corpusTotalUs': totalUs.fold<int>(0, (sum, value) => sum + value),
    'legal100PlyTimelineUs': timelineWatch.elapsedMicroseconds,
    'legal100PlyGeneratedInsights': performanceInsights.length,
    'ordinaryExplanationSpecificEngineSearches': 0,
    'persistedInsightBytes': _distribution(persistedSizes),
  };
  return Chapter6CorpusRun(
    results: List<Chapter6CorpusCaseResult>.unmodifiable(results),
    performance: performance,
    duplicateFingerprints: fingerprints,
  );
}

MoveInsightInput _corpusInput(String id) {
  switch (id) {
    case 'mate_white_001':
      return _input(
        fen:
            'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
        uci: 'h5f7',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.mate(1),
      );
    case 'mate_black_001':
      return _input(
        fen: 'k3r3/8/8/8/8/P7/5PPP/6K1 b - - 0 1',
        uci: 'e8e1',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.mate(-1),
      );
    case 'stalemate_001':
      return _input(
        fen: 'k7/2Q5/2K5/8/8/8/8/8 w - - 0 1',
        uci: 'c7b6',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );
    case 'allows_mate_001':
      const fen = 'k3r3/8/8/8/8/8/P4PPP/6K1 w - - 0 1';
      final after = _play(fen, 'a2a3');
      return _input(
        fen: fen,
        uci: 'a2a3',
        classification: MoveQuality.blunder,
        beforeScore: const ClassificationScore.cp(0),
        playedScore: const ClassificationScore.mate(-1),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'g2g3',
        bestMoveSan: 'g3',
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['e8e1'],
            mate: -1,
          ),
        ],
      );
    case 'missing_mate_pv_001':
      return _input(
        fen: 'k3r3/8/8/8/8/8/P4PPP/6K1 w - - 0 1',
        uci: 'a2a3',
        classification: MoveQuality.blunder,
        playedScore: const ClassificationScore.mate(-1),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'g2g3',
      );
    case 'misses_mate_001':
      const fen =
          'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4';
      final best = _line(
        rank: 1,
        fen: fen,
        moves: const <String>['h5f7'],
        mate: 1,
      );
      return _input(
        fen: fen,
        uci: 'h5h3',
        classification: MoveQuality.missedWin,
        beforeScore: const ClassificationScore.mate(1),
        playedScore: const ClassificationScore.cp(40),
        bestScore: const ClassificationScore.mate(1),
        bestMoveUci: 'h5f7',
        bestMoveSan: 'Qxf7#',
        preLines: <EngineLine>[best],
      );
    case 'preserves_mate_001':
      const fen = '7k/8/5KQ1/8/8/8/8/8 w - - 0 1';
      final after = _play(fen, 'g6h6');
      return _input(
        fen: fen,
        uci: 'g6h6',
        classification: MoveQuality.best,
        beforeScore: const ClassificationScore.mate(3),
        playedScore: const ClassificationScore.mate(2),
        bestScore: const ClassificationScore.mate(3),
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['h8g8', 'h6g7'],
            mate: 2,
          ),
        ],
      );
    case 'drops_rook_001':
      const fen = '4k3/8/8/8/8/8/2q5/R3K3 w Q - 0 1';
      final after = _play(fen, 'a1a2');
      return _input(
        fen: fen,
        uci: 'a1a2',
        classification: MoveQuality.blunder,
        playedScore: const ClassificationScore.cp(-500),
        bestScore: const ClassificationScore.cp(0),
        bestMoveUci: 'a1a8',
        bestMoveSan: 'Ra8+',
        preLines: <EngineLine>[
          _line(
            rank: 1,
            fen: fen,
            moves: const <String>['a1a8', 'e8e7'],
            cp: 0,
          ),
          _line(
            rank: 2,
            fen: fen,
            moves: const <String>['a1a2', 'c2a2', 'e1f1'],
            cp: -500,
          ),
        ],
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['c2a2', 'e1f1'],
            cp: -500,
          ),
        ],
      );
    case 'wins_rook_001':
    case 'temporary_material_001':
      const fen = '4k3/8/8/8/8/8/2r5/3QK3 w - - 0 1';
      final after = _play(fen, 'd1c2');
      final isWin = id == 'wins_rook_001';
      final cp = isWin ? 320 : -200;
      return _input(
        fen: fen,
        uci: 'd1c2',
        classification: isWin ? MoveQuality.best : MoveQuality.mistake,
        playedScore: ClassificationScore.cp(cp),
        bestScore: ClassificationScore.cp(isWin ? 320 : 0),
        postLines: <EngineLine>[
          _line(
            rank: 1,
            fen: after.fen,
            moves: const <String>['e8f7', 'c2c7'],
            cp: cp,
          ),
        ],
      );
    case 'promotion_001':
      return _input(
        fen: '4k3/P7/8/8/8/8/8/4K3 w - - 0 1',
        uci: 'a7a8q',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.cp(900),
      );
    case 'recapture_001':
      return _input(
        fen: '4k3/8/8/8/4p3/3P4/8/4K3 w - - 0 1',
        uci: 'd3e4',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
        isRecapture: true,
      );
    case 'book_transition_001':
      const fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
      final after = _play(fen, 'e2e4');
      return _input(
        fen: fen,
        uci: 'e2e4',
        classification: MoveQuality.book,
        playedScore: const ClassificationScore.cp(20),
        opening: _bookOpening(fen, after.fen, 'e2e4'),
      );
    case 'check_not_mate_001':
      return _input(
        fen: '7k/8/5KQ1/8/8/8/8/8 w - - 0 1',
        uci: 'g6h6',
        classification: MoveQuality.best,
        playedScore: const ClassificationScore.mate(3),
      );
    case 'incomplete_search_001':
      return _plain(
        uci: 'e2e4',
        classification: MoveQuality.good,
        searchQualityMet: false,
      );
    case 'contradictory_after_fen_001':
      return _plain(uci: 'e2e4', fenAfterOverride: _startFen);
    case 'label_only_brilliant_001':
      return _plain(uci: 'd2d4', classification: MoveQuality.brilliant);
    case 'best_without_cause_001':
      return _plain(uci: 'c2c4', classification: MoveQuality.best);
    case 'castling_without_attack_001':
      return _input(
        fen: 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1',
        uci: 'e1g1',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );
    case 'two_attacks_no_fork_001':
      return _plain(uci: 'g1f3');
    case 'opened_line_no_consequence_001':
      return _plain(uci: 'e2e3');
    case 'pinned_looking_piece_001':
      return _input(
        fen: '4k3/8/8/2b5/8/2N5/8/4K3 w - - 0 1',
        uci: 'c3d5',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );
    case 'defender_removed_no_target_001':
      return _input(
        fen: '4k3/8/8/8/8/2b5/1B1N4/4K3 w - - 0 1',
        uci: 'b2c3',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      );
    case 'passed_pawn_loses_race_001':
      return _input(
        fen: '4k3/8/P7/8/8/7p/8/4K3 w - - 0 1',
        uci: 'a6a7',
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(-100),
      );
  }
  throw ArgumentError.value(id, 'id', 'Unknown Chapter 6 corpus case');
}

const String _startFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

MoveInsightInput _plain({
  required String uci,
  MoveQuality classification = MoveQuality.good,
  bool searchQualityMet = true,
  String? fenAfterOverride,
}) => _input(
  fen: _startFen,
  uci: uci,
  classification: classification,
  playedScore: const ClassificationScore.cp(0),
  searchQualityMet: searchQualityMet,
  fenAfterOverride: fenAfterOverride,
);

MoveInsightInput _input({
  required String fen,
  required String uci,
  required MoveQuality classification,
  required ClassificationScore playedScore,
  ClassificationScore beforeScore = const ClassificationScore.cp(0),
  ClassificationScore? bestScore,
  String? bestMoveUci,
  String? bestMoveSan,
  List<EngineLine> preLines = const <EngineLine>[],
  List<EngineLine> postLines = const <EngineLine>[],
  bool postMoveSearchQualityMet = true,
  bool searchQualityMet = true,
  bool isRecapture = false,
  OpeningEvidence? opening,
  String? fenAfterOverride,
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
  final evidence = MoveClassificationEvidence(
    mover: position.turn == Side.white
        ? ClassificationMover.white
        : ClassificationMover.black,
    evaluationBefore: beforeScore,
    playedMoveEvaluation: playedScore,
    bestMoveEvaluation:
        bestScore ??
        (preLines.firstOrNull?.scoreCp != null
            ? ClassificationScore.cp(preLines.first.scoreCp!)
            : preLines.firstOrNull?.mateIn != null
            ? ClassificationScore.mate(preLines.first.mateIn!)
            : playedScore),
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
    bookState: opening?.isVerifiedBookTransition == true
        ? ClassificationBookState.verified
        : ClassificationBookState.notBook,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
    isRecapture: isRecapture,
  );
  return MoveInsightInput(
    fenBefore: fen,
    fenAfter: fenAfterOverride ?? after.fen,
    playedMoveUci: uci,
    playedMoveSan: position.makeSan(move).$2,
    isWhiteMove: position.turn == Side.white,
    classification: classification,
    classificationEvidence: evidence,
    preMoveLines: preLines,
    postMoveLines: postLines,
    postMoveSearchQualityMet: postMoveSearchQualityMet,
    engineBestMoveSan: bestMoveSan,
    openingEvidence: opening ?? _noOpening(fen, after.fen, uci),
  );
}

EngineLine _line({
  required int rank,
  required String fen,
  required List<String> moves,
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
    depth: 18,
    whiteWinPercent: cp == null ? (mate! > 0 ? 100 : 0) : 50,
    pvMoves: moves,
  );
}

Position _play(String fen, String uci) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  return position.play(_move(position, uci));
}

NormalMove _move(Position position, String uci) {
  final from = _square(uci.substring(0, 2));
  final to = _square(uci.substring(2, 4));
  final promotion = uci.length == 5
      ? switch (uci[4]) {
          'q' => Role.queen,
          'r' => Role.rook,
          'b' => Role.bishop,
          'n' => Role.knight,
          _ => null,
        }
      : null;
  final move = NormalMove(from: from, to: to, promotion: promotion);
  if (!position.isLegal(move)) {
    throw StateError('$uci must be legal in ${position.fen}');
  }
  return move;
}

Square _square(String value) {
  final file = value.codeUnitAt(0) - 97;
  final rank = value.codeUnitAt(1) - 49;
  return Square(file + rank * 8);
}

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

OpeningEvidence _bookOpening(String before, String after, String uci) {
  const candidate = OpeningCandidate(
    ecoCode: 'B00',
    openingName: "King's Pawn Game",
    sourceLineId:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    sourceTerminalPly: 1,
    matchedPly: 1,
    exactPositionName: true,
  );
  return OpeningEvidence(
    artifact: kApexOpeningArtifactIdentity,
    artifactVerification: OpeningArtifactVerification.verified,
    state: OpeningMatchState.knownTransition,
    beforePositionKey: OpeningPositionKey.fromFen(before).value,
    afterPositionKey: OpeningPositionKey.fromFen(after).value,
    playedUci: uci,
    transitionVerified: true,
    selectedCandidate: candidate,
    totalCandidateCount: 1,
    matchedPly: 1,
    reasonCode: 'verified_known_transition',
  );
}

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
    final after = position.play(move);
    inputs.add(
      _input(
        fen: position.fen,
        uci: uci,
        classification: MoveQuality.good,
        playedScore: const ClassificationScore.cp(0),
      ),
    );
    position = after;
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
  if (insight.state != MoveInsightState.available) return text.isEmpty;
  return text.isNotEmpty &&
      !RegExp(
        r'\b(stockfish|uci|fen|multipv|centipawn|classifier|policy|detector|validation|verified)\b',
      ).hasMatch(text) &&
      !text.contains('the engine prefers') &&
      !text.contains('this is a good move') &&
      !text.contains('this is a brilliant sacrifice');
}

bool _referencesExpectedPieces(
  MoveInsight insight,
  List<String> expectedPieces,
) {
  final actual = <String>{
    for (final fact in insight.facts)
      if (fact.pieceSide != null && fact.pieceRole != null)
        '${fact.pieceSide} ${fact.pieceRole}',
  };
  return actual.containsAll(expectedPieces);
}

bool _referencesExpectedSquares(
  MoveInsight insight,
  List<String> expectedSquares,
) {
  final claim = insight.primaryClaim;
  final actual = <String>{
    for (final fact in insight.facts)
      if (fact.fromSquare != null) fact.fromSquare!,
    for (final fact in insight.facts)
      if (fact.toSquare != null) fact.toSquare!,
    if (claim?.pieceSquare != null) claim!.pieceSquare!,
    if (claim?.targetSquare != null) claim!.targetSquare!,
  };
  return actual.containsAll(expectedSquares);
}

String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';
