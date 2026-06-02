/// Developer-only foundation design for future basic classifier evidence.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_classifier_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';

const basicClassifierFoundationDesignReportVersion =
    'basic-classifier-foundation-design-v1';

enum BasicClassifierFoundationStatus {
  notReady('notReady'),
  blockedByUnsafeClaim('blockedByUnsafeClaim'),
  blockedByMismatch('blockedByMismatch'),
  blockedByRealDeviceProof('blockedByRealDeviceProof'),
  readyForDeveloperDesignOnly('readyForDeveloperDesignOnly'),
  readyForLimitedDeveloperPrototype('readyForLimitedDeveloperPrototype');

  const BasicClassifierFoundationStatus(this.wire);

  final String wire;
}

enum BasicClassifierDesignScope {
  nonQuietBasicEvidenceDesign('nonQuietBasicEvidenceDesign'),
  tacticalEvidenceDesign('tacticalEvidenceDesign'),
  materialSwingEvidenceDesign('materialSwingEvidenceDesign'),
  forcingLineEvidenceDesign('forcingLineEvidenceDesign'),
  kingSafetyEvidenceDesign('kingSafetyEvidenceDesign'),
  endgameEvidenceDesign('endgameEvidenceDesign'),
  safetySuppressionEvidenceDesign('safetySuppressionEvidenceDesign'),
  quietPreparatoryEvidenceClassification(
    'quietPreparatoryEvidenceClassification',
  ),
  productFacingLabels('productFacingLabels'),
  advancedBrilliantGate('advancedBrilliantGate'),
  advancedGreatMoveGate('advancedGreatMoveGate'),
  advancedMissedWinGate('advancedMissedWinGate'),
  officialMetricAccuracy('officialAccuracy'),
  officialMetricAcpl('officialAcpl');

  const BasicClassifierDesignScope(this.wire);

  final String wire;
}

enum BasicClassifierDesignScopeStatus {
  allowedForDesignOnly('allowedForDesignOnly'),
  allowedForDeveloperPrototype('allowedForDeveloperPrototype'),
  blockedByEvidence('blockedByEvidence'),
  blockedByPolicy('blockedByPolicy'),
  blockedByMissingProof('blockedByMissingProof');

  const BasicClassifierDesignScopeStatus(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceField {
  cpLossAvailable('cpLossAvailable'),
  winProbabilityAvailable('winProbabilityAvailable'),
  previousEvalAvailable('previousEvalAvailable'),
  playedMoveEvalAvailable('playedMoveEvalAvailable'),
  bestMoveEvalAvailable('bestMoveEvalAvailable'),
  candidateSpreadAvailable('candidateSpreadAvailable'),
  multiPvAvailable('multiPvAvailable'),
  pvAvailable('pvAvailable'),
  materialSwingAvailable('materialSwingAvailable'),
  tacticalSignalAvailable('tacticalSignalAvailable'),
  forcingLineSignalAvailable('forcingLineSignalAvailable'),
  kingSafetySignalAvailable('kingSafetySignalAvailable'),
  mateSignalAvailable('mateSignalAvailable'),
  openingSuppressionAvailable('openingSuppressionAvailable'),
  forcedMoveSuppressionAvailable('forcedMoveSuppressionAvailable'),
  invalidFenSuppressionAvailable('invalidFenSuppressionAvailable'),
  budgetPressureAvailable('budgetPressureAvailable'),
  negativeGuardScopeExcluded('negativeGuardScopeExcluded');

  const BasicClassifierEvidenceField(this.wire);

  final String wire;
}

enum BasicClassifierNextPhase {
  evidenceContractPrototype(
    'Phase 31B -- Evidence Contract Prototype With Product Labels Blocked',
  ),
  evidenceBlockerResolution('Phase 31B -- Evidence Blocker Resolution');

  const BasicClassifierNextPhase(this.wire);

  final String wire;
}

enum BasicClassifierFoundationDesignReportFormat {
  markdown('markdown'),
  json('json');

  const BasicClassifierFoundationDesignReportFormat(this.wire);

  final String wire;
}

class BasicClassifierFoundationDesignRequest {
  const BasicClassifierFoundationDesignRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.readiness,
    this.review,
    this.triage,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.readinessGate = const GoldenClassifierReadinessGate(),
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
    this.triageRunner = const GoldenEvidenceTriageRunner(),
  });

  final List<GoldenAnalysisCase> cases;
  final GoldenClassifierReadinessResult? readiness;
  final GoldenEvidenceReviewResult? review;
  final GoldenEvidenceTriageResult? triage;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final GoldenClassifierReadinessGate readinessGate;
  final GoldenEvidenceReviewRunner reviewRunner;
  final GoldenEvidenceTriageRunner triageRunner;
}

class BasicClassifierScopeDesign {
  const BasicClassifierScopeDesign({
    required this.scope,
    required this.status,
    required this.supportingCaseIds,
    required this.blockedCaseIds,
    required this.blockers,
    required this.recommendation,
  });

  final BasicClassifierDesignScope scope;
  final BasicClassifierDesignScopeStatus status;
  final List<String> supportingCaseIds;
  final List<String> blockedCaseIds;
  final List<String> blockers;
  final String recommendation;

  bool get isAllowed =>
      status == BasicClassifierDesignScopeStatus.allowedForDesignOnly ||
      status == BasicClassifierDesignScopeStatus.allowedForDeveloperPrototype;

  BasicClassifierScopeDesign copyWith({
    BasicClassifierDesignScope? scope,
    BasicClassifierDesignScopeStatus? status,
    List<String>? supportingCaseIds,
    List<String>? blockedCaseIds,
    List<String>? blockers,
    String? recommendation,
  }) {
    return BasicClassifierScopeDesign(
      scope: scope ?? this.scope,
      status: status ?? this.status,
      supportingCaseIds: supportingCaseIds ?? this.supportingCaseIds,
      blockedCaseIds: blockedCaseIds ?? this.blockedCaseIds,
      blockers: blockers ?? this.blockers,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'scope': scope.wire,
      'status': status.wire,
      'supportingCaseIds': supportingCaseIds,
      'blockedCaseIds': blockedCaseIds,
      'blockers': blockers,
      'recommendation': recommendation,
    };
  }
}

class BasicClassifierEvidenceContractField {
  const BasicClassifierEvidenceContractField({
    required this.field,
    required this.available,
    required this.supportingCaseIds,
    required this.note,
  });

  final BasicClassifierEvidenceField field;
  final bool available;
  final List<String> supportingCaseIds;
  final String note;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'field': field.wire,
      'available': available,
      'supportingCaseIds': supportingCaseIds,
      'note': note,
    };
  }
}

class BasicClassifierEvidenceContract {
  const BasicClassifierEvidenceContract({required this.fields});

  final List<BasicClassifierEvidenceContractField> fields;

  bool get computesOfficialAccuracy => false;

  bool get computesOfficialAcpl => false;

  bool get completeForProduct => fields.every((field) => field.available);

  List<BasicClassifierEvidenceField> get missingForProduct => fields
      .where((field) => !field.available)
      .map((field) => field.field)
      .toList(growable: false);

  BasicClassifierEvidenceContractField field(
    BasicClassifierEvidenceField field,
  ) {
    return fields.singleWhere((entry) => entry.field == field);
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'completeForProduct': completeForProduct,
      'computesOfficialAccuracy': computesOfficialAccuracy,
      'computesOfficialAcpl': computesOfficialAcpl,
      'fields': fields.map((field) => field.toJson()).toList(),
      'missingForProduct': missingForProduct
          .map((field) => field.wire)
          .toList(),
    };
  }
}

class BasicClassifierOutputPolicy {
  const BasicClassifierOutputPolicy({
    required this.allowedOutputFamilies,
    required this.forbiddenOutputFamilies,
    this.emittedForbiddenOutputFamilies = const <String>[],
  });

  final List<String> allowedOutputFamilies;
  final List<String> forbiddenOutputFamilies;
  final List<String> emittedForbiddenOutputFamilies;

  bool get hasViolation => emittedForbiddenOutputFamilies.isNotEmpty;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'allowedOutputFamilies': allowedOutputFamilies,
      'forbiddenOutputFamilies': forbiddenOutputFamilies,
      'emittedForbiddenOutputFamilies': emittedForbiddenOutputFamilies,
      'hasViolation': hasViolation,
    };
  }
}

class BasicClassifierFoundationDesignResult {
  const BasicClassifierFoundationDesignResult({
    required this.status,
    required this.totalCaseCount,
    required this.protectedCount,
    required this.negativeGuardCount,
    required this.incompleteCount,
    required this.realDeviceNeededCount,
    required this.ownerProofQueueCount,
    required this.capturedAndroidProofCount,
    required this.negativeGuardCaseIds,
    required this.capturedAndroidProofCaseIds,
    required this.scopes,
    required this.evidenceContract,
    required this.outputPolicy,
    required this.blockers,
    required this.nextRecommendedPhase,
    required this.productLabelsReady,
    required this.advancedLabelsReady,
    required this.quietPreparatoryScopeAllowed,
    required this.nonQuietBasicEvidenceDesignAllowed,
    required this.evidenceContractCompleteForProduct,
  });

  final BasicClassifierFoundationStatus status;
  final int totalCaseCount;
  final int protectedCount;
  final int negativeGuardCount;
  final int incompleteCount;
  final int realDeviceNeededCount;
  final int ownerProofQueueCount;
  final int capturedAndroidProofCount;
  final List<String> negativeGuardCaseIds;
  final List<String> capturedAndroidProofCaseIds;
  final List<BasicClassifierScopeDesign> scopes;
  final BasicClassifierEvidenceContract evidenceContract;
  final BasicClassifierOutputPolicy outputPolicy;
  final List<String> blockers;
  final BasicClassifierNextPhase nextRecommendedPhase;
  final bool productLabelsReady;
  final bool advancedLabelsReady;
  final bool quietPreparatoryScopeAllowed;
  final bool nonQuietBasicEvidenceDesignAllowed;
  final bool evidenceContractCompleteForProduct;

  bool get hasUnsafeOutputPolicyViolation =>
      outputPolicy.hasViolation ||
      productLabelsReady ||
      advancedLabelsReady ||
      quietPreparatoryScopeAllowed;

  bool get isStrictlyBlocked =>
      status == BasicClassifierFoundationStatus.blockedByUnsafeClaim ||
      status == BasicClassifierFoundationStatus.blockedByMismatch ||
      status == BasicClassifierFoundationStatus.blockedByRealDeviceProof;

  BasicClassifierScopeDesign scope(BasicClassifierDesignScope scope) {
    return scopes.singleWhere((entry) => entry.scope == scope);
  }

  BasicClassifierFoundationDesignResult copyWith({
    BasicClassifierFoundationStatus? status,
    List<BasicClassifierScopeDesign>? scopes,
    BasicClassifierOutputPolicy? outputPolicy,
    List<String>? blockers,
    bool? productLabelsReady,
    bool? advancedLabelsReady,
    bool? quietPreparatoryScopeAllowed,
  }) {
    return BasicClassifierFoundationDesignResult(
      status: status ?? this.status,
      totalCaseCount: totalCaseCount,
      protectedCount: protectedCount,
      negativeGuardCount: negativeGuardCount,
      incompleteCount: incompleteCount,
      realDeviceNeededCount: realDeviceNeededCount,
      ownerProofQueueCount: ownerProofQueueCount,
      capturedAndroidProofCount: capturedAndroidProofCount,
      negativeGuardCaseIds: negativeGuardCaseIds,
      capturedAndroidProofCaseIds: capturedAndroidProofCaseIds,
      scopes: scopes ?? this.scopes,
      evidenceContract: evidenceContract,
      outputPolicy: outputPolicy ?? this.outputPolicy,
      blockers: blockers ?? this.blockers,
      nextRecommendedPhase: nextRecommendedPhase,
      productLabelsReady: productLabelsReady ?? this.productLabelsReady,
      advancedLabelsReady: advancedLabelsReady ?? this.advancedLabelsReady,
      quietPreparatoryScopeAllowed:
          quietPreparatoryScopeAllowed ?? this.quietPreparatoryScopeAllowed,
      nonQuietBasicEvidenceDesignAllowed: nonQuietBasicEvidenceDesignAllowed,
      evidenceContractCompleteForProduct: evidenceContractCompleteForProduct,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Basic Classifier Foundation Design')
      ..writeln()
      ..writeln('- version: $basicClassifierFoundationDesignReportVersion')
      ..writeln('- status: ${status.wire}')
      ..writeln('- developer only: true')
      ..writeln('- classifier work: false')
      ..writeln('- product labels ready: $productLabelsReady')
      ..writeln('- advanced labels ready: $advancedLabelsReady')
      ..writeln(
        '- quiet/preparatory scope allowed: $quietPreparatoryScopeAllowed',
      )
      ..writeln(
        '- non-quiet basic evidence design allowed: '
        '$nonQuietBasicEvidenceDesignAllowed',
      )
      ..writeln(
        '- evidence contract complete for product: '
        '$evidenceContractCompleteForProduct',
      )
      ..writeln()
      ..writeln('## Summary')
      ..writeln('- total cases: $totalCaseCount')
      ..writeln('- protected count: $protectedCount')
      ..writeln('- negative guard count: $negativeGuardCount')
      ..writeln('- incomplete count: $incompleteCount')
      ..writeln('- real-device-needed count: $realDeviceNeededCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- captured Android proof count: $capturedAndroidProofCount')
      ..writeln()
      ..writeln('## Allowed Design Scopes');
    for (final scope in scopes.where((scope) => scope.isAllowed)) {
      buffer.writeln(
        '- ${scope.scope.wire}: ${scope.status.wire}; support: '
        '${_ids(scope.supportingCaseIds)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Blocked Scopes');
    for (final scope in scopes.where((scope) => !scope.isAllowed)) {
      buffer.writeln(
        '- ${scope.scope.wire}: ${scope.status.wire}; blockers: '
        '${_ids(scope.blockers)}; cases: ${_ids(scope.blockedCaseIds)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Evidence Contract')
      ..writeln('| Field | Available | Support | Note |')
      ..writeln('| --- | --- | --- | --- |');
    for (final field in evidenceContract.fields) {
      buffer.writeln(
        '| ${field.field.wire} | ${field.available ? 'yes' : 'future'} | '
        '${_ids(field.supportingCaseIds)} | ${field.note} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Output Policy')
      ..writeln(
        '- allowed output families: '
        '${_ids(outputPolicy.allowedOutputFamilies)}',
      )
      ..writeln(
        '- forbidden output families: '
        '${_ids(outputPolicy.forbiddenOutputFamilies)}',
      )
      ..writeln(
        '- emitted forbidden output families: '
        '${_ids(outputPolicy.emittedForbiddenOutputFamilies)}',
      )
      ..writeln()
      ..writeln('## Negative Guard Exclusion')
      ..writeln('- negative guard case IDs: ${_ids(negativeGuardCaseIds)}')
      ..writeln('- excluded scope: quietPreparatoryEvidenceClassification')
      ..writeln()
      ..writeln('## Captured Android Proof')
      ..writeln('- case IDs: ${_ids(capturedAndroidProofCaseIds)}')
      ..writeln()
      ..writeln('## Blockers');
    if (blockers.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final blocker in blockers) {
        buffer.writeln('- $blocker');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Next Recommended Phase')
      ..writeln(nextRecommendedPhase.wire)
      ..writeln()
      ..writeln(
        'This is a developer-only foundation design report. It defines future '
        'evidence inputs and scope blockers, but it does not score moves, '
        'classify moves, change product review output, or emit user-facing '
        'move-quality output.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': basicClassifierFoundationDesignReportVersion,
      'status': status.wire,
      'summary': <String, Object?>{
        'totalCases': totalCaseCount,
        'protectedCount': protectedCount,
        'negativeGuardCount': negativeGuardCount,
        'incompleteCount': incompleteCount,
        'realDeviceNeededCount': realDeviceNeededCount,
        'ownerProofQueueCount': ownerProofQueueCount,
        'capturedAndroidProofCount': capturedAndroidProofCount,
      },
      'productLabelsReady': productLabelsReady,
      'advancedLabelsReady': advancedLabelsReady,
      'quietPreparatoryScopeAllowed': quietPreparatoryScopeAllowed,
      'nonQuietBasicEvidenceDesignAllowed': nonQuietBasicEvidenceDesignAllowed,
      'evidenceContractCompleteForProduct': evidenceContractCompleteForProduct,
      'scopes': scopes.map((scope) => scope.toJson()).toList(),
      'evidenceContract': evidenceContract.toJson(),
      'outputPolicy': outputPolicy.toJson(),
      'negativeGuardCaseIds': negativeGuardCaseIds,
      'capturedAndroidProofCaseIds': capturedAndroidProofCaseIds,
      'blockers': blockers,
      'nextRecommendedPhase': nextRecommendedPhase.wire,
      'developerOnly': true,
      'classifierWork': false,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class BasicClassifierFoundationDesigner {
  const BasicClassifierFoundationDesigner();

  BasicClassifierFoundationDesignResult evaluate(
    BasicClassifierFoundationDesignRequest request,
  ) {
    final review =
        request.review ??
        request.reviewRunner.review(
          GoldenEvidenceReviewRequest(
            cases: request.cases,
            mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
            requireAllEvidence: true,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final triage =
        request.triage ??
        request.triageRunner.run(
          GoldenEvidenceTriageRequest(cases: request.cases),
        );
    final readiness =
        request.readiness ??
        request.readinessGate.evaluate(
          GoldenClassifierReadinessRequest(
            cases: request.cases,
            review: review,
            triage: triage,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );

    final scopes = <BasicClassifierScopeDesign>[
      _fromReadinessScope(
        scope: BasicClassifierDesignScope.nonQuietBasicEvidenceDesign,
        readinessScope: readiness.scope(
          GoldenClassifierScope.basicMoveQualityFoundation,
        ),
      ),
      _fromReadinessScope(
        scope: BasicClassifierDesignScope.tacticalEvidenceDesign,
        readinessScope: readiness.scope(
          GoldenClassifierScope.tacticalCandidateFoundation,
        ),
      ),
      _fromReadinessScope(
        scope: BasicClassifierDesignScope.materialSwingEvidenceDesign,
        readinessScope: readiness.scope(
          GoldenClassifierScope.materialSwingFoundation,
        ),
      ),
      _fromReadinessScope(
        scope: BasicClassifierDesignScope.forcingLineEvidenceDesign,
        readinessScope: readiness.scope(
          GoldenClassifierScope.forcingLineFoundation,
        ),
      ),
      _fromReadinessScope(
        scope: BasicClassifierDesignScope.kingSafetyEvidenceDesign,
        readinessScope: readiness.scope(
          GoldenClassifierScope.kingSafetyFoundation,
        ),
      ),
      _fromReadinessScope(
        scope: BasicClassifierDesignScope.endgameEvidenceDesign,
        readinessScope: readiness.scope(
          GoldenClassifierScope.endgamePrecisionFoundation,
        ),
      ),
      BasicClassifierScopeDesign(
        scope: BasicClassifierDesignScope.safetySuppressionEvidenceDesign,
        status: BasicClassifierDesignScopeStatus.allowedForDesignOnly,
        supportingCaseIds: _safetySuppressionSupport(review),
        blockedCaseIds: const <String>[],
        blockers: const <String>[],
        recommendation:
            'Design only for safety and suppression evidence; emit no labels.',
      ),
      BasicClassifierScopeDesign(
        scope:
            BasicClassifierDesignScope.quietPreparatoryEvidenceClassification,
        status: BasicClassifierDesignScopeStatus.blockedByEvidence,
        supportingCaseIds: readiness
            .scope(GoldenClassifierScope.quietPreparatoryFoundation)
            .supportingCaseIds,
        blockedCaseIds: readiness.negativeGuardCaseIds,
        blockers: const <String>[
          'quiet/preparatory scope excluded by negative guard',
        ],
        recommendation:
            'Keep quiet/preparatory classification excluded in this phase.',
      ),
      _blockedPolicyScope(BasicClassifierDesignScope.productFacingLabels),
      _blockedPolicyScope(BasicClassifierDesignScope.advancedBrilliantGate),
      _blockedPolicyScope(BasicClassifierDesignScope.advancedGreatMoveGate),
      _blockedPolicyScope(BasicClassifierDesignScope.advancedMissedWinGate),
      _blockedPolicyScope(BasicClassifierDesignScope.officialMetricAccuracy),
      _blockedPolicyScope(BasicClassifierDesignScope.officialMetricAcpl),
    ];

    final nonQuietAllowed = scopes
        .singleWhere(
          (scope) =>
              scope.scope ==
              BasicClassifierDesignScope.nonQuietBasicEvidenceDesign,
        )
        .isAllowed;
    final quietAllowed = scopes
        .singleWhere(
          (scope) =>
              scope.scope ==
              BasicClassifierDesignScope.quietPreparatoryEvidenceClassification,
        )
        .isAllowed;

    final outputPolicy = BasicClassifierOutputPolicy(
      allowedOutputFamilies: _sortedStrings(const <String>[
        'developerOnlyDesignReports',
        'scopeReadiness',
        'evidenceContractCoverage',
        'blockers',
        'supportingGoldenCaseIds',
        'missingEvidenceFields',
        'guardrailFailures',
      ]),
      forbiddenOutputFamilies: _sortedStrings(const <String>[
        'advancedCandidateLabels',
        'moveQualityLabels',
        'finalMoveLabels',
        'officialMetricAccuracy',
        'officialMetricAcpl',
        'userFacingAdvice',
        'uiCopy',
      ]),
    );
    final evidenceContract = _evidenceContract(
      review: review,
      readiness: readiness,
    );
    final blockers = _foundationBlockers(readiness, quietAllowed);

    return BasicClassifierFoundationDesignResult(
      status: _foundationStatus(readiness, nonQuietAllowed),
      totalCaseCount: readiness.totalCaseCount,
      protectedCount: readiness.protectedCount,
      negativeGuardCount: readiness.negativeGuardCount,
      incompleteCount: readiness.incompleteCount,
      realDeviceNeededCount: readiness.realDeviceNeededCount,
      ownerProofQueueCount: readiness.ownerProofQueueCount,
      capturedAndroidProofCount: readiness.capturedAndroidProofCount,
      negativeGuardCaseIds: readiness.negativeGuardCaseIds,
      capturedAndroidProofCaseIds: readiness.capturedAndroidProofCaseIds,
      scopes: List<BasicClassifierScopeDesign>.unmodifiable(scopes),
      evidenceContract: evidenceContract,
      outputPolicy: outputPolicy,
      blockers: blockers,
      nextRecommendedPhase: blockers.any(_isGlobalEvidenceBlocker)
          ? BasicClassifierNextPhase.evidenceBlockerResolution
          : BasicClassifierNextPhase.evidenceContractPrototype,
      productLabelsReady: false,
      advancedLabelsReady: false,
      quietPreparatoryScopeAllowed: quietAllowed,
      nonQuietBasicEvidenceDesignAllowed: nonQuietAllowed,
      evidenceContractCompleteForProduct: evidenceContract.completeForProduct,
    );
  }
}

BasicClassifierScopeDesign _fromReadinessScope({
  required BasicClassifierDesignScope scope,
  required GoldenClassifierScopeReadiness readinessScope,
}) {
  return BasicClassifierScopeDesign(
    scope: scope,
    status: _scopeStatusFromReadiness(readinessScope.status),
    supportingCaseIds: readinessScope.supportingCaseIds,
    blockedCaseIds: readinessScope.missingCaseIds,
    blockers: readinessScope.blockers,
    recommendation:
        '${readinessScope.recommendation} Design only in Phase 31A.',
  );
}

BasicClassifierScopeDesign _blockedPolicyScope(
  BasicClassifierDesignScope scope,
) {
  return BasicClassifierScopeDesign(
    scope: scope,
    status: BasicClassifierDesignScopeStatus.blockedByPolicy,
    supportingCaseIds: const <String>[],
    blockedCaseIds: const <String>[],
    blockers: const <String>['blocked by output policy'],
    recommendation:
        'Blocked in Phase 31A; this foundation may only render design evidence.',
  );
}

BasicClassifierDesignScopeStatus _scopeStatusFromReadiness(
  GoldenClassifierScopeStatus status,
) {
  return switch (status) {
    GoldenClassifierScopeStatus.allowedForDesignOnly =>
      BasicClassifierDesignScopeStatus.allowedForDesignOnly,
    GoldenClassifierScopeStatus.allowedForDeveloperPrototype =>
      BasicClassifierDesignScopeStatus.allowedForDeveloperPrototype,
    GoldenClassifierScopeStatus.blockedByMissingProof =>
      BasicClassifierDesignScopeStatus.blockedByMissingProof,
    GoldenClassifierScopeStatus.blockedByPolicy =>
      BasicClassifierDesignScopeStatus.blockedByPolicy,
    GoldenClassifierScopeStatus.blockedByEvidence ||
    GoldenClassifierScopeStatus.blockedByIncompleteCases =>
      BasicClassifierDesignScopeStatus.blockedByEvidence,
  };
}

BasicClassifierFoundationStatus _foundationStatus(
  GoldenClassifierReadinessResult readiness,
  bool nonQuietAllowed,
) {
  if (readiness.unsafeCount > 0) {
    return BasicClassifierFoundationStatus.blockedByUnsafeClaim;
  }
  if (readiness.mismatchCount > 0) {
    return BasicClassifierFoundationStatus.blockedByMismatch;
  }
  if (readiness.realDeviceNeededCount > 0 ||
      readiness.ownerProofQueueCount > 0) {
    return BasicClassifierFoundationStatus.blockedByRealDeviceProof;
  }
  if (nonQuietAllowed &&
      readiness.status ==
          GoldenClassifierReadinessStatus.readyForLimitedClassifierFoundation) {
    return BasicClassifierFoundationStatus.readyForLimitedDeveloperPrototype;
  }
  if (nonQuietAllowed) {
    return BasicClassifierFoundationStatus.readyForDeveloperDesignOnly;
  }
  return BasicClassifierFoundationStatus.notReady;
}

List<String> _foundationBlockers(
  GoldenClassifierReadinessResult readiness,
  bool quietAllowed,
) {
  return _sortedStrings(<String>[
    if (readiness.unsafeCount > 0) 'unsafe golden evidence blocks design',
    if (readiness.mismatchCount > 0) 'mismatch evidence blocks design',
    if (readiness.realDeviceNeededCount > 0 ||
        readiness.ownerProofQueueCount > 0)
      'real-device proof is still required',
    if (quietAllowed) 'quiet/preparatory scope was unexpectedly allowed',
    'product-facing labels are blocked',
    'advanced labels are blocked',
    'quiet/preparatory scope is excluded by negative guard',
  ]);
}

bool _isGlobalEvidenceBlocker(String blocker) =>
    blocker.startsWith('unsafe') ||
    blocker.startsWith('mismatch') ||
    blocker.startsWith('real-device');

BasicClassifierEvidenceContract _evidenceContract({
  required GoldenEvidenceReviewResult review,
  required GoldenClassifierReadinessResult readiness,
}) {
  final capturedProof = readiness.capturedAndroidProofCaseIds;
  return BasicClassifierEvidenceContract(
    fields: List<BasicClassifierEvidenceContractField>.unmodifiable(
      [
        _futureField(
          BasicClassifierEvidenceField.cpLossAvailable,
          'future classifier input; not computed in design phase',
        ),
        _futureField(
          BasicClassifierEvidenceField.winProbabilityAvailable,
          'future classifier input; not computed in design phase',
        ),
        _futureField(
          BasicClassifierEvidenceField.previousEvalAvailable,
          'future classifier input; not computed in design phase',
        ),
        _futureField(
          BasicClassifierEvidenceField.playedMoveEvalAvailable,
          'future classifier input; not computed in design phase',
        ),
        _futureField(
          BasicClassifierEvidenceField.bestMoveEvalAvailable,
          'future classifier input; not computed in design phase',
        ),
        _availableField(
          BasicClassifierEvidenceField.candidateSpreadAvailable,
          _caseIdsWithReason(
            review,
            DeepCandidateReasonCode.candidateEvalSpread,
          ),
          'golden evidence contains candidate-spread support',
        ),
        _availableField(
          BasicClassifierEvidenceField.multiPvAvailable,
          capturedProof,
          'captured Android proof preserves MultiPV facts for proven cases',
        ),
        _availableField(
          BasicClassifierEvidenceField.pvAvailable,
          capturedProof,
          'captured Android proof preserves PV facts for proven cases',
        ),
        _availableField(
          BasicClassifierEvidenceField.materialSwingAvailable,
          _caseIdsWithAnyReason(review, const <DeepCandidateReasonCode>[
            DeepCandidateReasonCode.materialSwing,
            DeepCandidateReasonCode.majorEvalSwing,
          ]),
          'material and swing evidence exists in protected golden cases',
        ),
        _availableField(
          BasicClassifierEvidenceField.tacticalSignalAvailable,
          _caseIdsWithAnyReason(review, const <DeepCandidateReasonCode>[
            DeepCandidateReasonCode.tacticalSignal,
            DeepCandidateReasonCode.captureOrPromotion,
            DeepCandidateReasonCode.givesCheck,
          ]),
          'tactical evidence exists in protected golden cases',
        ),
        _availableField(
          BasicClassifierEvidenceField.forcingLineSignalAvailable,
          _caseIdsWithEvidenceGroup(review, GoldenMotifEvidenceGroup.forcing),
          'forcing-line evidence exists in protected golden cases',
        ),
        _availableField(
          BasicClassifierEvidenceField.kingSafetySignalAvailable,
          _caseIdsWithEvidenceGroup(
            review,
            GoldenMotifEvidenceGroup.kingSafety,
          ),
          'king-safety evidence exists in protected golden cases',
        ),
        _availableField(
          BasicClassifierEvidenceField.mateSignalAvailable,
          _caseIdsWithReason(review, DeepCandidateReasonCode.mateScoreDetected),
          'mate signal exists only as internal evidence, not as a label',
        ),
        _availableField(
          BasicClassifierEvidenceField.openingSuppressionAvailable,
          _caseIdsWithSuppression(
            review,
            DeepCandidateReasonCode.openingSuppressed,
          ),
          'opening suppression is covered by golden evidence',
        ),
        _availableField(
          BasicClassifierEvidenceField.forcedMoveSuppressionAvailable,
          _caseIdsWithSuppression(
            review,
            DeepCandidateReasonCode.forcedSuppressed,
          ),
          'forced-move suppression is covered by golden evidence',
        ),
        _availableField(
          BasicClassifierEvidenceField.invalidFenSuppressionAvailable,
          _caseIdsWithSuppression(
            review,
            DeepCandidateReasonCode.invalidFenSuppressed,
          ),
          'invalid-FEN suppression is covered by golden evidence',
        ),
        _availableField(
          BasicClassifierEvidenceField.budgetPressureAvailable,
          _caseIdsWithSuppression(
            review,
            DeepCandidateReasonCode.budgetSuppressed,
          ),
          'budget-pressure suppression is covered by golden evidence',
        ),
        _availableField(
          BasicClassifierEvidenceField.negativeGuardScopeExcluded,
          readiness.negativeGuardCaseIds,
          'negative guard keeps quiet/preparatory classification excluded',
        ),
      ]..sort((a, b) => a.field.wire.compareTo(b.field.wire)),
    ),
  );
}

BasicClassifierEvidenceContractField _futureField(
  BasicClassifierEvidenceField field,
  String note,
) {
  return BasicClassifierEvidenceContractField(
    field: field,
    available: false,
    supportingCaseIds: const <String>[],
    note: note,
  );
}

BasicClassifierEvidenceContractField _availableField(
  BasicClassifierEvidenceField field,
  List<String> supportingCaseIds,
  String note,
) {
  return BasicClassifierEvidenceContractField(
    field: field,
    available: supportingCaseIds.isNotEmpty,
    supportingCaseIds: _sortedStrings(supportingCaseIds),
    note: supportingCaseIds.isEmpty ? '$note; no supporting case yet' : note,
  );
}

List<String> _safetySuppressionSupport(GoldenEvidenceReviewResult review) {
  return _sortedStrings(
    review.caseReviews
        .where(
          (item) =>
              item.passedLike &&
              (item.expectedSuppressionsSatisfied.isNotEmpty ||
                  item.motifEvidenceGroups.contains(
                    GoldenMotifEvidenceGroup.suppression,
                  ) ||
                  item.motifEvidenceGroups.contains(
                    GoldenMotifEvidenceGroup.budget,
                  )),
        )
        .map((item) => item.caseId),
  );
}

List<String> _caseIdsWithReason(
  GoldenEvidenceReviewResult review,
  DeepCandidateReasonCode reason,
) {
  return _caseIdsWithAnyReason(review, <DeepCandidateReasonCode>[reason]);
}

List<String> _caseIdsWithAnyReason(
  GoldenEvidenceReviewResult review,
  List<DeepCandidateReasonCode> reasons,
) {
  final reasonSet = reasons.toSet();
  return _sortedStrings(
    review.caseReviews
        .where(
          (item) =>
              item.passedLike &&
              item.satisfiedReasonCodes.any(reasonSet.contains),
        )
        .map((item) => item.caseId),
  );
}

List<String> _caseIdsWithSuppression(
  GoldenEvidenceReviewResult review,
  DeepCandidateReasonCode reason,
) {
  return _sortedStrings(
    review.caseReviews
        .where(
          (item) =>
              item.passedLike &&
              item.expectedSuppressionsSatisfied.contains(reason),
        )
        .map((item) => item.caseId),
  );
}

List<String> _caseIdsWithEvidenceGroup(
  GoldenEvidenceReviewResult review,
  GoldenMotifEvidenceGroup group,
) {
  return _sortedStrings(
    review.caseReviews
        .where(
          (item) =>
              item.passedLike &&
              item.satisfiedMotifEvidenceGroups.contains(group),
        )
        .map((item) => item.caseId),
  );
}

String _ids(List<String> values) {
  if (values.isEmpty) return '-';
  return values.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
}
