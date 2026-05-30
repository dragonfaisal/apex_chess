/// Developer-only triage and proof queue for golden evidence review.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';

const goldenEvidenceTriageReportVersion = 'golden-evidence-triage-v1';

enum GoldenEvidenceTriagePriority {
  none('none', 0),
  low('low', 1),
  medium('medium', 2),
  high('high', 3),
  critical('critical', 4);

  const GoldenEvidenceTriagePriority(this.wire, this.rank);

  final String wire;
  final int rank;
}

enum GoldenEvidenceTriageNextAction {
  keepProtected('keepProtected'),
  addFakeEvidence('addFakeEvidence'),
  addHandcraftedCase('addHandcraftedCase'),
  runOwnerAndroidProof('runOwnerAndroidProof'),
  adjustExpectation('adjustExpectation'),
  investigateMismatch('investigateMismatch'),
  blockUnsafeClaim('blockUnsafeClaim');

  const GoldenEvidenceTriageNextAction(this.wire);

  final String wire;
}

enum GoldenOwnerRunProofMode {
  realDeviceEvidenceReferenceOnly('realDeviceEvidenceReferenceOnly'),
  selectedDeepSmoke('selectedDeepSmoke'),
  futureGoldenCaseDeviceProof('futureGoldenCaseDeviceProof');

  const GoldenOwnerRunProofMode(this.wire);

  final String wire;
}

enum GoldenMotifCoverageStrength {
  weak('weak'),
  strong('strong');

  const GoldenMotifCoverageStrength(this.wire);

  final String wire;
}

enum GoldenEvidenceTriageReportFormat {
  markdown('markdown'),
  json('json');

  const GoldenEvidenceTriageReportFormat(this.wire);

  final String wire;
}

class GoldenEvidenceTriageRequest {
  const GoldenEvidenceTriageRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.maxProofTargets = 3,
    this.includeProtected = false,
    this.weakMotifGroupThreshold = 2,
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
  }) : assert(maxProofTargets >= 0),
       assert(weakMotifGroupThreshold >= 1);

  final List<GoldenAnalysisCase> cases;
  final int maxProofTargets;
  final bool includeProtected;
  final int weakMotifGroupThreshold;
  final GoldenEvidenceReviewRunner reviewRunner;
}

class GoldenEvidenceTriageEntry {
  const GoldenEvidenceTriageEntry({
    required this.caseId,
    required this.title,
    required this.category,
    required this.motifs,
    required this.currentReviewStatus,
    required this.evidenceGapGroups,
    required this.gapReasonCodes,
    required this.gapSuppressionReasons,
    required this.motifEvidenceGaps,
    required this.realDeviceProofRequired,
    required this.priority,
    required this.nextAction,
    required this.rationale,
  });

  final String caseId;
  final String title;
  final GoldenAnalysisCategory category;
  final List<GoldenMotifTag> motifs;
  final GoldenEvidenceReviewStatus currentReviewStatus;
  final List<GoldenMotifEvidenceGroup> evidenceGapGroups;
  final List<DeepCandidateReasonCode> gapReasonCodes;
  final List<DeepCandidateReasonCode> gapSuppressionReasons;
  final List<String> motifEvidenceGaps;
  final bool realDeviceProofRequired;
  final GoldenEvidenceTriagePriority priority;
  final GoldenEvidenceTriageNextAction nextAction;
  final String rationale;

  bool get isProtected =>
      priority == GoldenEvidenceTriagePriority.none &&
      nextAction == GoldenEvidenceTriageNextAction.keepProtected;

  bool get hasEvidenceGap =>
      evidenceGapGroups.isNotEmpty ||
      gapReasonCodes.isNotEmpty ||
      gapSuppressionReasons.isNotEmpty ||
      motifEvidenceGaps.isNotEmpty;
}

class GoldenMotifGroupTriage {
  const GoldenMotifGroupTriage({
    required this.group,
    required this.caseCount,
    required this.strength,
    required this.rationale,
  });

  final GoldenMotifGroup group;
  final int caseCount;
  final GoldenMotifCoverageStrength strength;
  final String rationale;
}

class GoldenHandcraftedHardCaseArea {
  const GoldenHandcraftedHardCaseArea({
    required this.id,
    required this.motifGroup,
    this.evidenceGroup,
    required this.priority,
    required this.rationale,
  });

  final String id;
  final GoldenMotifGroup motifGroup;
  final GoldenMotifEvidenceGroup? evidenceGroup;
  final GoldenEvidenceTriagePriority priority;
  final String rationale;
}

class GoldenOwnerRunProofTarget {
  const GoldenOwnerRunProofTarget({
    required this.caseId,
    required this.priority,
    required this.reason,
    required this.suggestedMode,
  });

  final String caseId;
  final GoldenEvidenceTriagePriority priority;
  final String reason;
  final GoldenOwnerRunProofMode suggestedMode;
}

class GoldenOwnerRunProofQueue {
  const GoldenOwnerRunProofQueue({
    required this.targets,
    required this.maxTargetCount,
    required this.suggestedCommandGuidance,
  });

  final List<GoldenOwnerRunProofTarget> targets;
  final int maxTargetCount;
  final String suggestedCommandGuidance;

  List<String> get targetCaseIds =>
      targets.map((target) => target.caseId).toList(growable: false);
}

class GoldenEvidenceTriageResult {
  const GoldenEvidenceTriageResult({
    required this.totalCases,
    required this.entries,
    required this.weakMotifGroups,
    required this.strongMotifGroups,
    required this.recommendedOwnerRunProofQueue,
    required this.recommendedNewHandcraftedHardCaseAreas,
    required this.warnings,
    required this.failures,
    required this.includeProtected,
    required this.androidProofEvidenceSourceId,
    required this.androidProofEvidenceCaseIds,
  });

  final int totalCases;
  final List<GoldenEvidenceTriageEntry> entries;
  final List<GoldenMotifGroupTriage> weakMotifGroups;
  final List<GoldenMotifGroupTriage> strongMotifGroups;
  final GoldenOwnerRunProofQueue recommendedOwnerRunProofQueue;
  final List<GoldenHandcraftedHardCaseArea>
  recommendedNewHandcraftedHardCaseAreas;
  final List<String> warnings;
  final List<String> failures;
  final bool includeProtected;
  final String? androidProofEvidenceSourceId;
  final List<String> androidProofEvidenceCaseIds;

  List<GoldenEvidenceTriageEntry> get protectedCases =>
      entries.where((entry) => entry.isProtected).toList(growable: false);

  List<GoldenEvidenceTriageEntry> get incompleteCases => entries
      .where(
        (entry) =>
            entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.incompleteEvidence,
      )
      .toList(growable: false);

  List<GoldenEvidenceTriageEntry> get realDeviceNeededCases => entries
      .where((entry) => entry.realDeviceProofRequired)
      .toList(growable: false);

  List<GoldenEvidenceTriageEntry> get behaviorMismatchCases => entries
      .where(
        (entry) =>
            entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.behaviorMismatch,
      )
      .toList(growable: false);

  List<GoldenEvidenceTriageEntry> get budgetMismatchCases => entries
      .where(
        (entry) =>
            entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.budgetMismatch,
      )
      .toList(growable: false);

  List<GoldenEvidenceTriageEntry> get blockedUnsafeCases => entries
      .where(
        (entry) =>
            entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.blockedUnsafeClaim,
      )
      .toList(growable: false);

  List<GoldenEvidenceTriageEntry> get motifEvidenceGapCases =>
      entries.where((entry) => entry.hasEvidenceGap).toList(growable: false);

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Golden Evidence Triage')
      ..writeln()
      ..writeln('- version: $goldenEvidenceTriageReportVersion')
      ..writeln('- total cases: $totalCases')
      ..writeln('- protected: ${protectedCases.length}')
      ..writeln('- incomplete: ${incompleteCases.length}')
      ..writeln('- needs real-device proof: ${realDeviceNeededCases.length}')
      ..writeln('- behavior mismatches: ${behaviorMismatchCases.length}')
      ..writeln('- budget mismatches: ${budgetMismatchCases.length}')
      ..writeln('- unsafe or blocked: ${blockedUnsafeCases.length}')
      ..writeln('- motif evidence gap cases: ${motifEvidenceGapCases.length}')
      ..writeln()
      ..writeln('## Attention Queue')
      ..writeln('| Case | Status | Priority | Next Action | Rationale |')
      ..writeln('| --- | --- | --- | --- | --- |');

    final detailEntries = _sortedEntriesForReport(entries)
        .where((entry) => includeProtected || !entry.isProtected)
        .toList(growable: false);
    if (detailEntries.isEmpty) {
      buffer.writeln('| - | - | none | keepProtected | no attention items |');
    } else {
      for (final entry in detailEntries) {
        buffer.writeln(
          '| ${_cell(entry.caseId)} | ${entry.currentReviewStatus.wire} | '
          '${entry.priority.wire} | ${entry.nextAction.wire} | '
          '${_cell(entry.rationale)} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Top Evidence Gaps');
    final gapEntries = motifEvidenceGapCases.toList(growable: false)
      ..sort(_compareEntriesForReport);
    if (gapEntries.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final entry in gapEntries) {
        final groups = entry.evidenceGapGroups
            .map((group) => group.wire)
            .join(', ');
        final gaps = [
          ...entry.motifEvidenceGaps,
          ...entry.gapReasonCodes.map((reason) => reason.wire),
          ...entry.gapSuppressionReasons.map((reason) => reason.wire),
        ]..sort();
        buffer.writeln(
          '- ${entry.caseId}: ${groups.isEmpty ? "unspecified" : groups}; '
          '${gaps.isEmpty ? "no detail" : gaps.join(", ")}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Android Proof Evidence');
    if (androidProofEvidenceSourceId == null) {
      buffer.writeln('- none');
    } else {
      buffer
        ..writeln('- source: $androidProofEvidenceSourceId')
        ..writeln(
          '- proven cases: '
          '${androidProofEvidenceCaseIds.isEmpty ? "-" : androidProofEvidenceCaseIds.join(", ")}',
        );
    }

    buffer
      ..writeln()
      ..writeln('## Proof Queue');
    if (recommendedOwnerRunProofQueue.targets.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final target in recommendedOwnerRunProofQueue.targets) {
        buffer.writeln(
          '- ${target.caseId}: ${target.priority.wire}, '
          '${target.suggestedMode.wire}, ${target.reason}',
        );
      }
      buffer
        ..writeln()
        ..writeln('Reference command:')
        ..writeln()
        ..writeln('```powershell')
        ..writeln(recommendedOwnerRunProofQueue.suggestedCommandGuidance)
        ..writeln('```');
    }

    buffer
      ..writeln()
      ..writeln('## Weak Motif Groups');
    if (weakMotifGroups.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final group in weakMotifGroups) {
        buffer.writeln(
          '- ${group.group.wire}: ${group.caseCount} case(s), '
          '${group.rationale}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Strong Motif Groups');
    if (strongMotifGroups.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final group in strongMotifGroups) {
        buffer.writeln('- ${group.group.wire}: ${group.caseCount} case(s)');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Handcrafted Case Areas');
    if (recommendedNewHandcraftedHardCaseAreas.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final area in recommendedNewHandcraftedHardCaseAreas) {
        final evidence = area.evidenceGroup == null
            ? ''
            : ', ${area.evidenceGroup!.wire} evidence';
        buffer.writeln(
          '- ${area.id}: ${area.priority.wire}, ${area.motifGroup.wire}'
          '$evidence, ${area.rationale}',
        );
      }
    }

    if (warnings.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Warnings');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }

    if (failures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Failures');
      for (final failure in failures) {
        buffer.writeln('- $failure');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Next Recommended Action')
      ..writeln(_nextRecommendation(this))
      ..writeln()
      ..writeln(
        'This report is developer-only triage output. It recommends proof and '
        'case-building work, but does not run Android or create product claims.',
      );

    return buffer.toString();
  }

  String renderJsonReport() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': goldenEvidenceTriageReportVersion,
      'summary': <String, Object?>{
        'totalCases': totalCases,
        'protectedCount': protectedCases.length,
        'incompleteCount': incompleteCases.length,
        'realDeviceProofCount': realDeviceNeededCases.length,
        'behaviorMismatchCount': behaviorMismatchCases.length,
        'budgetMismatchCount': budgetMismatchCases.length,
        'blockedUnsafeCount': blockedUnsafeCases.length,
        'evidenceGapCaseCount': motifEvidenceGapCases.length,
      },
      'entries': [
        for (final entry in _sortedEntriesForReport(
          entries,
        ).where((entry) => includeProtected || !entry.isProtected))
          _entryToJson(entry),
      ],
      'proofQueue': _proofQueueToJson(recommendedOwnerRunProofQueue),
      'androidProofEvidence': <String, Object?>{
        'sourceId': androidProofEvidenceSourceId,
        'provenCaseIds': androidProofEvidenceCaseIds,
        'present': androidProofEvidenceSourceId != null,
      },
      'weakMotifGroups': [
        for (final group in weakMotifGroups) _motifGroupToJson(group),
      ],
      'strongMotifGroups': [
        for (final group in strongMotifGroups) _motifGroupToJson(group),
      ],
      'hardCaseAreas': [
        for (final area in recommendedNewHandcraftedHardCaseAreas)
          _hardCaseAreaToJson(area),
      ],
      'warnings': warnings,
      'failures': failures,
      'developerOnly': true,
      'productClaims': false,
    };
  }
}

class GoldenEvidenceTriageRunner {
  const GoldenEvidenceTriageRunner({
    this.policy = const GoldenEvidenceTriagePolicy(),
  });

  final GoldenEvidenceTriagePolicy policy;

  GoldenEvidenceTriageResult run(GoldenEvidenceTriageRequest request) {
    final review = request.reviewRunner.review(
      GoldenEvidenceReviewRequest(
        cases: request.cases,
        mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
        requireAllEvidence: true,
      ),
    );
    final caseById = <String, GoldenAnalysisCase>{
      for (final item in request.cases) item.id: item,
    };
    final entries = <GoldenEvidenceTriageEntry>[
      for (final reviewCase in review.caseReviews)
        policy.entryFor(caseById[reviewCase.caseId]!, reviewCase),
    ];
    final motifGroups = policy.motifGroupCoverage(
      review.motifGroupCoverage,
      weakThreshold: request.weakMotifGroupThreshold,
    );
    final weakGroups = motifGroups
        .where((group) => group.strength == GoldenMotifCoverageStrength.weak)
        .toList(growable: false);
    final strongGroups = motifGroups
        .where((group) => group.strength == GoldenMotifCoverageStrength.strong)
        .toList(growable: false);
    final proofQueue = policy.proofQueueFor(
      entries,
      maxTargets: request.maxProofTargets,
      suggestedCommandGuidance: review.realDeviceEvidenceCommand,
    );

    return GoldenEvidenceTriageResult(
      totalCases: request.cases.length,
      entries: List<GoldenEvidenceTriageEntry>.unmodifiable(entries),
      weakMotifGroups: List<GoldenMotifGroupTriage>.unmodifiable(weakGroups),
      strongMotifGroups: List<GoldenMotifGroupTriage>.unmodifiable(
        strongGroups,
      ),
      recommendedOwnerRunProofQueue: proofQueue,
      recommendedNewHandcraftedHardCaseAreas:
          List<GoldenHandcraftedHardCaseArea>.unmodifiable(
            policy.hardCaseAreasFor(
              entries: entries,
              weakGroups: weakGroups,
              motifEvidenceCoverage: review.motifEvidenceGroupCoverage,
              categoryCoverage: review.categoryCoverage,
            ),
          ),
      warnings: List<String>.unmodifiable(_warningsFor(entries)),
      failures: List<String>.unmodifiable(_failuresFor(entries)),
      includeProtected: request.includeProtected,
      androidProofEvidenceSourceId: review.androidProofEvidenceSourceId,
      androidProofEvidenceCaseIds: review.androidProofEvidenceCaseIds,
    );
  }
}

class GoldenEvidenceTriagePolicy {
  const GoldenEvidenceTriagePolicy();

  GoldenEvidenceTriageEntry entryFor(
    GoldenAnalysisCase item,
    GoldenEvidenceCaseReview review,
  ) {
    final priority = _priorityFor(item, review);
    final action = _actionFor(item, review, priority);
    return GoldenEvidenceTriageEntry(
      caseId: item.id,
      title: item.title,
      category: item.category,
      motifs: List<GoldenMotifTag>.unmodifiable(item.motifTags),
      currentReviewStatus: review.status,
      evidenceGapGroups: List<GoldenMotifEvidenceGroup>.unmodifiable(
        review.missingMotifEvidenceGroups,
      ),
      gapReasonCodes: List<DeepCandidateReasonCode>.unmodifiable(
        review.missingReasonCodes,
      ),
      gapSuppressionReasons: List<DeepCandidateReasonCode>.unmodifiable(
        review.expectedSuppressionsMissing,
      ),
      motifEvidenceGaps: List<String>.unmodifiable(review.missingMotifEvidence),
      realDeviceProofRequired: review.realEngineEvidenceNeeded,
      priority: priority,
      nextAction: action,
      rationale: _rationaleFor(item, review, priority, action),
    );
  }

  List<GoldenMotifGroupTriage> motifGroupCoverage(
    Map<GoldenMotifGroup, int> coverage, {
    required int weakThreshold,
  }) {
    return GoldenMotifGroup.values.map((group) {
      final count = coverage[group] ?? 0;
      final strength = count >= weakThreshold
          ? GoldenMotifCoverageStrength.strong
          : GoldenMotifCoverageStrength.weak;
      return GoldenMotifGroupTriage(
        group: group,
        caseCount: count,
        strength: strength,
        rationale: strength == GoldenMotifCoverageStrength.weak
            ? 'below target coverage of $weakThreshold'
            : 'meets target coverage of $weakThreshold',
      );
    }).toList()..sort((a, b) => a.group.wire.compareTo(b.group.wire));
  }

  GoldenOwnerRunProofQueue proofQueueFor(
    List<GoldenEvidenceTriageEntry> entries, {
    required int maxTargets,
    required String suggestedCommandGuidance,
  }) {
    final targets =
        entries
            .where(
              (entry) =>
                  entry.realDeviceProofRequired &&
                  entry.nextAction ==
                      GoldenEvidenceTriageNextAction.runOwnerAndroidProof,
            )
            .map(
              (entry) => GoldenOwnerRunProofTarget(
                caseId: entry.caseId,
                priority: entry.priority,
                reason: 'real-device proof required for selected-deep evidence',
                suggestedMode: GoldenOwnerRunProofMode.selectedDeepSmoke,
              ),
            )
            .toList()
          ..sort(_compareProofTargets);
    return GoldenOwnerRunProofQueue(
      targets: List<GoldenOwnerRunProofTarget>.unmodifiable(
        targets.take(maxTargets),
      ),
      maxTargetCount: maxTargets,
      suggestedCommandGuidance: suggestedCommandGuidance,
    );
  }

  List<GoldenHandcraftedHardCaseArea> hardCaseAreasFor({
    required List<GoldenEvidenceTriageEntry> entries,
    required List<GoldenMotifGroupTriage> weakGroups,
    required Map<GoldenMotifEvidenceGroup, int> motifEvidenceCoverage,
    required Map<GoldenAnalysisCategory, int> categoryCoverage,
  }) {
    final areas = <GoldenHandcraftedHardCaseArea>[];
    void add(GoldenHandcraftedHardCaseArea area) {
      if (areas.any((existing) => existing.id == area.id)) return;
      areas.add(area);
    }

    if ((categoryCoverage[GoldenAnalysisCategory.materialSacrifice] ?? 0) <=
        1) {
      add(
        const GoldenHandcraftedHardCaseArea(
          id: 'sacrifice-compensation-variation',
          motifGroup: GoldenMotifGroup.materialAndSacrifice,
          evidenceGroup: GoldenMotifEvidenceGroup.material,
          priority: GoldenEvidenceTriagePriority.medium,
          rationale: 'only one sacrifice-compensation row is currently covered',
        ),
      );
    }
    if (entries.any(
      (entry) =>
          entry.motifs.contains(GoldenMotifTag.quietPreparatoryMove) &&
          entry.currentReviewStatus ==
              GoldenEvidenceReviewStatus.incompleteEvidence,
    )) {
      add(
        const GoldenHandcraftedHardCaseArea(
          id: 'quiet-preparatory-evidence',
          motifGroup: GoldenMotifGroup.positionalAndQuiet,
          evidenceGroup: GoldenMotifEvidenceGroup.uncertainty,
          priority: GoldenEvidenceTriagePriority.medium,
          rationale: 'quiet preparatory evidence remains incomplete',
        ),
      );
    }
    if (weakGroups.any(
          (group) => group.group == GoldenMotifGroup.kingSafetyAndMate,
        ) ||
        entries.any(
          (entry) => entry.motifs.contains(GoldenMotifTag.matingNet),
        )) {
      add(
        const GoldenHandcraftedHardCaseArea(
          id: 'king-safety-mating-net-proof',
          motifGroup: GoldenMotifGroup.kingSafetyAndMate,
          evidenceGroup: GoldenMotifEvidenceGroup.kingSafety,
          priority: GoldenEvidenceTriagePriority.high,
          rationale: 'king-safety and mating-net coverage remains thin',
        ),
      );
    }
    if ((motifEvidenceCoverage[GoldenMotifEvidenceGroup.forcing] ?? 0) <= 4) {
      add(
        const GoldenHandcraftedHardCaseArea(
          id: 'forcing-line-proof-variation',
          motifGroup: GoldenMotifGroup.forcingAndTactical,
          evidenceGroup: GoldenMotifEvidenceGroup.forcing,
          priority: GoldenEvidenceTriagePriority.medium,
          rationale: 'forcing-line proof should get another handcrafted row',
        ),
      );
    }
    if ((categoryCoverage[GoldenAnalysisCategory.endgamePrecision] ?? 0) <= 1) {
      add(
        const GoldenHandcraftedHardCaseArea(
          id: 'endgame-precision-proof',
          motifGroup: GoldenMotifGroup.positionalAndQuiet,
          evidenceGroup: GoldenMotifEvidenceGroup.positional,
          priority: GoldenEvidenceTriagePriority.medium,
          rationale: 'technical endgame coverage is represented by one row',
        ),
      );
    }

    areas.sort((a, b) {
      final priority = b.priority.rank.compareTo(a.priority.rank);
      if (priority != 0) return priority;
      return a.id.compareTo(b.id);
    });
    return List<GoldenHandcraftedHardCaseArea>.unmodifiable(areas);
  }
}

GoldenEvidenceTriagePriority _priorityFor(
  GoldenAnalysisCase item,
  GoldenEvidenceCaseReview review,
) {
  return switch (review.status) {
    GoldenEvidenceReviewStatus.blockedUnsafeClaim =>
      GoldenEvidenceTriagePriority.critical,
    GoldenEvidenceReviewStatus.behaviorMismatch ||
    GoldenEvidenceReviewStatus.budgetMismatch =>
      GoldenEvidenceTriagePriority.high,
    GoldenEvidenceReviewStatus.failed => GoldenEvidenceTriagePriority.high,
    GoldenEvidenceReviewStatus.needsRealEngineEvidence =>
      GoldenEvidenceTriagePriority.high,
    GoldenEvidenceReviewStatus.incompleteEvidence => _incompletePriority(item),
    GoldenEvidenceReviewStatus.passed ||
    GoldenEvidenceReviewStatus.passedWithWarnings =>
      GoldenEvidenceTriagePriority.none,
  };
}

GoldenEvidenceTriagePriority _incompletePriority(GoldenAnalysisCase item) {
  if (item.motifTags.any(_isHighValueMotif)) {
    return GoldenEvidenceTriagePriority.high;
  }
  if (item.motifTags.contains(GoldenMotifTag.quietPreparatoryMove) ||
      item.motifTags.contains(GoldenMotifTag.evidenceIncomplete)) {
    return GoldenEvidenceTriagePriority.medium;
  }
  return GoldenEvidenceTriagePriority.medium;
}

bool _isHighValueMotif(GoldenMotifTag motif) {
  return switch (motif) {
    GoldenMotifTag.sacrifice ||
    GoldenMotifTag.temporarySacrifice ||
    GoldenMotifTag.exchangeSacrifice ||
    GoldenMotifTag.pieceSacrifice ||
    GoldenMotifTag.mateThreat ||
    GoldenMotifTag.forcedMate ||
    GoldenMotifTag.queenWin ||
    GoldenMotifTag.forcingLine => true,
    _ => false,
  };
}

GoldenEvidenceTriageNextAction _actionFor(
  GoldenAnalysisCase item,
  GoldenEvidenceCaseReview review,
  GoldenEvidenceTriagePriority priority,
) {
  if (review.status == GoldenEvidenceReviewStatus.blockedUnsafeClaim) {
    return GoldenEvidenceTriageNextAction.blockUnsafeClaim;
  }
  if (review.status == GoldenEvidenceReviewStatus.behaviorMismatch ||
      review.status == GoldenEvidenceReviewStatus.budgetMismatch) {
    return GoldenEvidenceTriageNextAction.investigateMismatch;
  }
  if (review.status == GoldenEvidenceReviewStatus.failed) {
    return GoldenEvidenceTriageNextAction.adjustExpectation;
  }
  if (review.realEngineEvidenceNeeded &&
      review.status == GoldenEvidenceReviewStatus.needsRealEngineEvidence) {
    return GoldenEvidenceTriageNextAction.runOwnerAndroidProof;
  }
  if (review.status == GoldenEvidenceReviewStatus.incompleteEvidence) {
    if (item.motifTags.contains(GoldenMotifTag.evidenceIncomplete) &&
        review.missingReasonCodes.isEmpty) {
      return GoldenEvidenceTriageNextAction.addFakeEvidence;
    }
    return GoldenEvidenceTriageNextAction.addFakeEvidence;
  }
  if (priority == GoldenEvidenceTriagePriority.none) {
    return GoldenEvidenceTriageNextAction.keepProtected;
  }
  return GoldenEvidenceTriageNextAction.adjustExpectation;
}

String _rationaleFor(
  GoldenAnalysisCase item,
  GoldenEvidenceCaseReview review,
  GoldenEvidenceTriagePriority priority,
  GoldenEvidenceTriageNextAction action,
) {
  if (action == GoldenEvidenceTriageNextAction.keepProtected) {
    return 'case is protected in the current reference review';
  }
  if (action == GoldenEvidenceTriageNextAction.blockUnsafeClaim) {
    return 'unsafe claim or unsafe source metadata blocks evidence use';
  }
  if (action == GoldenEvidenceTriageNextAction.investigateMismatch) {
    return 'current behavior does not match the golden expectation';
  }
  if (action == GoldenEvidenceTriageNextAction.runOwnerAndroidProof) {
    return 'future owner Android proof is required for selected-deep evidence';
  }
  if (action == GoldenEvidenceTriageNextAction.addFakeEvidence) {
    final gaps = review.missingMotifEvidence.isEmpty
        ? review.missingReasonCodes.map((reason) => reason.wire).join(', ')
        : review.missingMotifEvidence.join(', ');
    return gaps.isEmpty
        ? 'evidence is incomplete'
        : 'evidence is incomplete: $gaps';
  }
  if (action == GoldenEvidenceTriageNextAction.adjustExpectation) {
    return 'review failure requires expectation cleanup';
  }
  return 'priority ${priority.wire} for ${item.category.wire}';
}

List<GoldenEvidenceTriageEntry> _sortedEntriesForReport(
  List<GoldenEvidenceTriageEntry> entries,
) {
  return entries.toList()..sort(_compareEntriesForReport);
}

int _compareEntriesForReport(
  GoldenEvidenceTriageEntry a,
  GoldenEvidenceTriageEntry b,
) {
  final priority = b.priority.rank.compareTo(a.priority.rank);
  if (priority != 0) return priority;
  return a.caseId.compareTo(b.caseId);
}

int _compareProofTargets(
  GoldenOwnerRunProofTarget a,
  GoldenOwnerRunProofTarget b,
) {
  final priority = b.priority.rank.compareTo(a.priority.rank);
  if (priority != 0) return priority;
  return a.caseId.compareTo(b.caseId);
}

List<String> _warningsFor(List<GoldenEvidenceTriageEntry> entries) {
  final warnings = <String>[];
  for (final entry in entries) {
    if (entry.currentReviewStatus ==
        GoldenEvidenceReviewStatus.incompleteEvidence) {
      warnings.add('${entry.caseId}: evidence gap remains visible');
    }
    if (entry.realDeviceProofRequired) {
      warnings.add('${entry.caseId}: owner-run Android proof recommended');
    }
  }
  warnings.sort();
  return warnings;
}

List<String> _failuresFor(List<GoldenEvidenceTriageEntry> entries) {
  final failures = <String>[];
  for (final entry in entries) {
    if (entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.behaviorMismatch ||
        entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.budgetMismatch ||
        entry.currentReviewStatus ==
            GoldenEvidenceReviewStatus.blockedUnsafeClaim ||
        entry.currentReviewStatus == GoldenEvidenceReviewStatus.failed) {
      failures.add('${entry.caseId}: ${entry.currentReviewStatus.wire}');
    }
  }
  failures.sort();
  return failures;
}

String _nextRecommendation(GoldenEvidenceTriageResult result) {
  if (result.blockedUnsafeCases.isNotEmpty) {
    return 'Resolve unsafe golden rows before adding evidence.';
  }
  if (result.behaviorMismatchCases.isNotEmpty ||
      result.budgetMismatchCases.isNotEmpty) {
    return 'Investigate mismatches before widening the golden suite.';
  }
  if (result.recommendedOwnerRunProofQueue.targets.isNotEmpty) {
    return 'Run the smallest owner Android proof set, then update evidence rows.';
  }
  if (result.incompleteCases.isNotEmpty) {
    return 'Add deterministic fake evidence or clarify incomplete expectations.';
  }
  return 'Use weak motif groups to choose the next handcrafted hard case.';
}

Map<String, Object?> _entryToJson(GoldenEvidenceTriageEntry entry) {
  return <String, Object?>{
    'caseId': entry.caseId,
    'category': entry.category.wire,
    'motifs': entry.motifs.map((motif) => motif.wire).toList()..sort(),
    'status': entry.currentReviewStatus.wire,
    'evidenceGapGroups': entry.evidenceGapGroups
        .map((group) => group.wire)
        .toList(),
    'gapReasonCodes': entry.gapReasonCodes
        .map((reason) => reason.wire)
        .toList(),
    'gapSuppressionReasons': entry.gapSuppressionReasons
        .map((reason) => reason.wire)
        .toList(),
    'motifEvidenceGaps': entry.motifEvidenceGaps,
    'realDeviceProofRequired': entry.realDeviceProofRequired,
    'priority': entry.priority.wire,
    'nextAction': entry.nextAction.wire,
    'rationale': entry.rationale,
  };
}

Map<String, Object?> _proofQueueToJson(GoldenOwnerRunProofQueue queue) {
  return <String, Object?>{
    'maxTargetCount': queue.maxTargetCount,
    'targetCaseIds': queue.targetCaseIds,
    'targets': [
      for (final target in queue.targets)
        <String, Object?>{
          'caseId': target.caseId,
          'priority': target.priority.wire,
          'reason': target.reason,
          'suggestedMode': target.suggestedMode.wire,
        },
    ],
    'suggestedCommandGuidance': queue.suggestedCommandGuidance,
  };
}

Map<String, Object?> _motifGroupToJson(GoldenMotifGroupTriage group) {
  return <String, Object?>{
    'group': group.group.wire,
    'caseCount': group.caseCount,
    'strength': group.strength.wire,
    'rationale': group.rationale,
  };
}

Map<String, Object?> _hardCaseAreaToJson(GoldenHandcraftedHardCaseArea area) {
  return <String, Object?>{
    'id': area.id,
    'motifGroup': area.motifGroup.wire,
    'evidenceGroup': area.evidenceGroup?.wire,
    'priority': area.priority.wire,
    'rationale': area.rationale,
  };
}

String _cell(String value) => value.replaceAll('|', '/');
