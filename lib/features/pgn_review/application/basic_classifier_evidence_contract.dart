/// Developer-only evidence contract prototype for future basic classifier work.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';

const basicClassifierEvidenceContractReportVersion =
    'basic-classifier-evidence-contract-v1';

enum BasicClassifierEvidenceContractStatus {
  readyForDeveloperEvidencePrototype('readyForDeveloperEvidencePrototype'),
  blockedByValidation('blockedByValidation'),
  blockedByEvidence('blockedByEvidence');

  const BasicClassifierEvidenceContractStatus(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceFieldStatus {
  present('present'),
  missing('missing'),
  blockedByPolicy('blockedByPolicy'),
  futureOnly('futureOnly'),
  excludedByNegativeGuard('excludedByNegativeGuard'),
  notImplemented('notImplemented'),
  unsupported('unsupported');

  const BasicClassifierEvidenceFieldStatus(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceGroupReadiness {
  readyForDeveloperEvidence('readyForDeveloperEvidence'),
  partial('partial'),
  blocked('blocked'),
  excluded('excluded'),
  futureOnly('futureOnly');

  const BasicClassifierEvidenceGroupReadiness(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceGroup {
  evaluationAvailability('evaluationAvailability'),
  tacticalEvidence('tacticalEvidence'),
  materialEvidence('materialEvidence'),
  forcingEvidence('forcingEvidence'),
  kingSafetyEvidence('kingSafetyEvidence'),
  safetySuppressionEvidence('safetySuppressionEvidence'),
  quietPreparatoryEvidence('quietPreparatoryEvidence'),
  futureProductInputs('futureProductInputs');

  const BasicClassifierEvidenceGroup(this.wire);

  final String wire;
}

enum BasicClassifierContractField {
  previousEvalAvailable('previousEvalAvailable'),
  playedMoveEvalAvailable('playedMoveEvalAvailable'),
  bestMoveEvalAvailable('bestMoveEvalAvailable'),
  candidateSpreadAvailable('candidateSpreadAvailable'),
  multiPvAvailable('multiPvAvailable'),
  pvAvailable('pvAvailable'),
  tacticalSignalAvailable('tacticalSignalAvailable'),
  captureOrPromotionAvailable('captureOrPromotionAvailable'),
  givesCheckAvailable('givesCheckAvailable'),
  candidateSpreadSignalAvailable('candidateSpreadSignalAvailable'),
  forcingLineSignalAvailable('forcingLineSignalAvailable'),
  mateSignalAvailable('mateSignalAvailable'),
  materialSwingAvailable('materialSwingAvailable'),
  majorEvalSwingAvailable('majorEvalSwingAvailable'),
  queenWinEvidenceAvailable('queenWinEvidenceAvailable'),
  sacrificeCompensationAvailable('sacrificeCompensationAvailable'),
  kingSafetySignalAvailable('kingSafetySignalAvailable'),
  exposedKingSignalAvailable('exposedKingSignalAvailable'),
  matingNetSignalAvailable('matingNetSignalAvailable'),
  kingHuntSignalAvailable('kingHuntSignalAvailable'),
  openingSuppressionAvailable('openingSuppressionAvailable'),
  forcedMoveSuppressionAvailable('forcedMoveSuppressionAvailable'),
  invalidFenSuppressionAvailable('invalidFenSuppressionAvailable'),
  budgetPressureAvailable('budgetPressureAvailable'),
  negativeGuardScopeExcluded('negativeGuardScopeExcluded'),
  cpLossAvailable('cpLossAvailable'),
  winProbabilityAvailable('winProbabilityAvailable'),
  officialAccuracyAvailable('officialAccuracyAvailable'),
  officialAcplAvailable('officialAcplAvailable'),
  productLabelOutputAvailable('productLabelOutputAvailable');

  const BasicClassifierContractField(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceContractNextPhase {
  internalNonLabelBucketDesign('Phase 31C -- Internal Non-Label Bucket Design'),
  evidenceContractFixes('Phase 31C -- Evidence Contract Fixes');

  const BasicClassifierEvidenceContractNextPhase(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceContractReportFormat {
  markdown('markdown'),
  json('json');

  const BasicClassifierEvidenceContractReportFormat(this.wire);

  final String wire;
}

enum BasicClassifierEvidenceValidationSeverity {
  warning('warning'),
  error('error');

  const BasicClassifierEvidenceValidationSeverity(this.wire);

  final String wire;
}

class BasicClassifierEvidenceContractRequest {
  const BasicClassifierEvidenceContractRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.foundationDesign,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.foundationDesigner = const BasicClassifierFoundationDesigner(),
  });

  final List<GoldenAnalysisCase> cases;
  final BasicClassifierFoundationDesignResult? foundationDesign;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final BasicClassifierFoundationDesigner foundationDesigner;
}

class BasicClassifierEvidenceFieldPrototype {
  const BasicClassifierEvidenceFieldPrototype({
    required this.field,
    required this.group,
    required this.status,
    required this.supportingCaseIds,
    required this.blockers,
    required this.note,
  });

  final BasicClassifierContractField field;
  final BasicClassifierEvidenceGroup group;
  final BasicClassifierEvidenceFieldStatus status;
  final List<String> supportingCaseIds;
  final List<String> blockers;
  final String note;

  bool get isPresent =>
      status == BasicClassifierEvidenceFieldStatus.present ||
      status == BasicClassifierEvidenceFieldStatus.excludedByNegativeGuard;

  BasicClassifierEvidenceFieldPrototype copyWith({
    BasicClassifierContractField? field,
    BasicClassifierEvidenceGroup? group,
    BasicClassifierEvidenceFieldStatus? status,
    List<String>? supportingCaseIds,
    List<String>? blockers,
    String? note,
  }) {
    return BasicClassifierEvidenceFieldPrototype(
      field: field ?? this.field,
      group: group ?? this.group,
      status: status ?? this.status,
      supportingCaseIds: supportingCaseIds ?? this.supportingCaseIds,
      blockers: blockers ?? this.blockers,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'field': field.wire,
      'group': group.wire,
      'status': status.wire,
      'supportingCaseIds': supportingCaseIds,
      'blockers': blockers,
      'note': note,
    };
  }
}

class BasicClassifierEvidenceGroupPrototype {
  const BasicClassifierEvidenceGroupPrototype({
    required this.group,
    required this.readiness,
    required this.fieldIds,
    required this.supportingCaseIds,
    required this.blockerCaseIds,
    required this.blockers,
    required this.recommendation,
  });

  final BasicClassifierEvidenceGroup group;
  final BasicClassifierEvidenceGroupReadiness readiness;
  final List<BasicClassifierContractField> fieldIds;
  final List<String> supportingCaseIds;
  final List<String> blockerCaseIds;
  final List<String> blockers;
  final String recommendation;

  BasicClassifierEvidenceGroupPrototype copyWith({
    BasicClassifierEvidenceGroup? group,
    BasicClassifierEvidenceGroupReadiness? readiness,
    List<BasicClassifierContractField>? fieldIds,
    List<String>? supportingCaseIds,
    List<String>? blockerCaseIds,
    List<String>? blockers,
    String? recommendation,
  }) {
    return BasicClassifierEvidenceGroupPrototype(
      group: group ?? this.group,
      readiness: readiness ?? this.readiness,
      fieldIds: fieldIds ?? this.fieldIds,
      supportingCaseIds: supportingCaseIds ?? this.supportingCaseIds,
      blockerCaseIds: blockerCaseIds ?? this.blockerCaseIds,
      blockers: blockers ?? this.blockers,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'group': group.wire,
      'readiness': readiness.wire,
      'fieldIds': fieldIds.map((field) => field.wire).toList(),
      'supportingCaseIds': supportingCaseIds,
      'blockerCaseIds': blockerCaseIds,
      'blockers': blockers,
      'recommendation': recommendation,
    };
  }
}

class BasicClassifierEvidenceValidationFinding {
  const BasicClassifierEvidenceValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.field,
    this.group,
    this.caseId,
  });

  final String id;
  final BasicClassifierEvidenceValidationSeverity severity;
  final String message;
  final BasicClassifierContractField? field;
  final BasicClassifierEvidenceGroup? group;
  final String? caseId;

  bool get isError =>
      severity == BasicClassifierEvidenceValidationSeverity.error;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (field != null) 'field': field!.wire,
      if (group != null) 'group': group!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class BasicClassifierEvidenceContractPrototype {
  const BasicClassifierEvidenceContractPrototype({
    required this.status,
    required this.foundationStatus,
    required this.totalCaseCount,
    required this.protectedCount,
    required this.negativeGuardCount,
    required this.incompleteCount,
    required this.realDeviceNeededCount,
    required this.ownerProofQueueCount,
    required this.capturedAndroidProofCount,
    required this.negativeGuardCaseIds,
    required this.capturedAndroidProofCaseIds,
    required this.fields,
    required this.groups,
    required this.excludedScopes,
    required this.blockedOutputFamilies,
    required this.emittedOutputFamilies,
    required this.validationFindings,
    required this.nextRecommendedPhase,
    required this.readyForPhase31C,
  });

  final BasicClassifierEvidenceContractStatus status;
  final BasicClassifierFoundationStatus foundationStatus;
  final int totalCaseCount;
  final int protectedCount;
  final int negativeGuardCount;
  final int incompleteCount;
  final int realDeviceNeededCount;
  final int ownerProofQueueCount;
  final int capturedAndroidProofCount;
  final List<String> negativeGuardCaseIds;
  final List<String> capturedAndroidProofCaseIds;
  final List<BasicClassifierEvidenceFieldPrototype> fields;
  final List<BasicClassifierEvidenceGroupPrototype> groups;
  final List<String> excludedScopes;
  final List<String> blockedOutputFamilies;
  final List<String> emittedOutputFamilies;
  final List<BasicClassifierEvidenceValidationFinding> validationFindings;
  final BasicClassifierEvidenceContractNextPhase nextRecommendedPhase;
  final bool readyForPhase31C;

  bool get hasValidationErrors =>
      validationFindings.any((finding) => finding.isError);

  bool get hasUnsafeOutputPolicyViolation {
    if (_field(
      BasicClassifierContractField.productLabelOutputAvailable,
    ).isPresent) {
      return true;
    }
    if (_field(
      BasicClassifierContractField.officialAccuracyAvailable,
    ).isPresent) {
      return true;
    }
    if (_field(BasicClassifierContractField.officialAcplAvailable).isPresent) {
      return true;
    }
    if (_quietGroup.readiness !=
        BasicClassifierEvidenceGroupReadiness.excluded) {
      return true;
    }
    return emittedOutputFamilies.any(_isForbiddenEmittedOutput);
  }

  bool get isStrictlyBlocked =>
      hasValidationErrors ||
      status !=
          BasicClassifierEvidenceContractStatus
              .readyForDeveloperEvidencePrototype;

  BasicClassifierEvidenceFieldPrototype field(
    BasicClassifierContractField field,
  ) {
    return _field(field);
  }

  BasicClassifierEvidenceGroupPrototype group(
    BasicClassifierEvidenceGroup group,
  ) {
    return groups.singleWhere((entry) => entry.group == group);
  }

  BasicClassifierEvidenceContractPrototype copyWith({
    BasicClassifierEvidenceContractStatus? status,
    List<BasicClassifierEvidenceFieldPrototype>? fields,
    List<BasicClassifierEvidenceGroupPrototype>? groups,
    List<String>? emittedOutputFamilies,
    List<BasicClassifierEvidenceValidationFinding>? validationFindings,
    BasicClassifierEvidenceContractNextPhase? nextRecommendedPhase,
    bool? readyForPhase31C,
  }) {
    return BasicClassifierEvidenceContractPrototype(
      status: status ?? this.status,
      foundationStatus: foundationStatus,
      totalCaseCount: totalCaseCount,
      protectedCount: protectedCount,
      negativeGuardCount: negativeGuardCount,
      incompleteCount: incompleteCount,
      realDeviceNeededCount: realDeviceNeededCount,
      ownerProofQueueCount: ownerProofQueueCount,
      capturedAndroidProofCount: capturedAndroidProofCount,
      negativeGuardCaseIds: negativeGuardCaseIds,
      capturedAndroidProofCaseIds: capturedAndroidProofCaseIds,
      fields: fields ?? this.fields,
      groups: groups ?? this.groups,
      excludedScopes: excludedScopes,
      blockedOutputFamilies: blockedOutputFamilies,
      emittedOutputFamilies:
          emittedOutputFamilies ?? this.emittedOutputFamilies,
      validationFindings: validationFindings ?? this.validationFindings,
      nextRecommendedPhase: nextRecommendedPhase ?? this.nextRecommendedPhase,
      readyForPhase31C: readyForPhase31C ?? this.readyForPhase31C,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Basic Classifier Evidence Contract Prototype')
      ..writeln()
      ..writeln('- version: $basicClassifierEvidenceContractReportVersion')
      ..writeln('- status: ${status.wire}')
      ..writeln('- foundation status: ${foundationStatus.wire}')
      ..writeln('- developer only: true')
      ..writeln('- classifier work: false')
      ..writeln('- ready for Phase 31C: $readyForPhase31C')
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
      ..writeln('## Evidence Field Table')
      ..writeln('| Field | Group | Status | Support | Blockers | Note |')
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final field in fields) {
      buffer.writeln(
        '| ${field.field.wire} | ${field.group.wire} | '
        '${field.status.wire} | ${_ids(field.supportingCaseIds)} | '
        '${_ids(field.blockers)} | ${field.note} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Evidence Group Readiness')
      ..writeln('| Group | Readiness | Support | Blockers | Recommendation |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final group in groups) {
      buffer.writeln(
        '| ${group.group.wire} | ${group.readiness.wire} | '
        '${_ids(group.supportingCaseIds)} | ${_ids(group.blockers)} | '
        '${group.recommendation} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('## Support Mapping');
    for (final group in groups) {
      buffer.writeln('- ${group.group.wire}: ${_ids(group.supportingCaseIds)}');
    }

    buffer
      ..writeln()
      ..writeln('## Blocked And Future Fields');
    for (final field in fields.where((field) => !field.isPresent)) {
      buffer.writeln('- ${field.field.wire}: ${field.status.wire}');
    }

    buffer
      ..writeln()
      ..writeln('## Quiet Preparatory Exclusion')
      ..writeln('- negative guard case IDs: ${_ids(negativeGuardCaseIds)}')
      ..writeln('- excluded scopes: ${_ids(excludedScopes)}')
      ..writeln(
        '- protected quiet evidence remains support only: '
        '${_ids(group(BasicClassifierEvidenceGroup.quietPreparatoryEvidence).supportingCaseIds)}',
      )
      ..writeln()
      ..writeln('## Product Output Policy')
      ..writeln('- blocked output families: ${_ids(blockedOutputFamilies)}')
      ..writeln('- emitted output families: ${_ids(emittedOutputFamilies)}')
      ..writeln()
      ..writeln('## Validation');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id}: ${finding.message}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Next Recommended Phase')
      ..writeln(nextRecommendedPhase.wire)
      ..writeln()
      ..writeln(
        'This report defines developer-only evidence fields and group '
        'readiness. It does not score moves, classify moves, compute product '
        'metrics, change product review output, or emit user-facing output.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': basicClassifierEvidenceContractReportVersion,
      'status': status.wire,
      'foundationStatus': foundationStatus.wire,
      'summary': <String, Object?>{
        'totalCases': totalCaseCount,
        'protectedCount': protectedCount,
        'negativeGuardCount': negativeGuardCount,
        'incompleteCount': incompleteCount,
        'realDeviceNeededCount': realDeviceNeededCount,
        'ownerProofQueueCount': ownerProofQueueCount,
        'capturedAndroidProofCount': capturedAndroidProofCount,
      },
      'readyForPhase31C': readyForPhase31C,
      'fields': fields.map((field) => field.toJson()).toList(),
      'groups': groups.map((group) => group.toJson()).toList(),
      'negativeGuardCaseIds': negativeGuardCaseIds,
      'capturedAndroidProofCaseIds': capturedAndroidProofCaseIds,
      'excludedScopes': excludedScopes,
      'blockedOutputFamilies': blockedOutputFamilies,
      'emittedOutputFamilies': emittedOutputFamilies,
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'nextRecommendedPhase': nextRecommendedPhase.wire,
      'developerOnly': true,
      'classifierWork': false,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  BasicClassifierEvidenceFieldPrototype _field(
    BasicClassifierContractField field,
  ) {
    return fields.singleWhere((entry) => entry.field == field);
  }

  BasicClassifierEvidenceGroupPrototype get _quietGroup =>
      group(BasicClassifierEvidenceGroup.quietPreparatoryEvidence);
}

class BasicClassifierEvidenceContractBuilder {
  const BasicClassifierEvidenceContractBuilder({
    this.validator = const BasicClassifierEvidenceContractValidator(),
  });

  final BasicClassifierEvidenceContractValidator validator;

  BasicClassifierEvidenceContractPrototype evaluate(
    BasicClassifierEvidenceContractRequest request,
  ) {
    final foundation =
        request.foundationDesign ??
        request.foundationDesigner.evaluate(
          BasicClassifierFoundationDesignRequest(
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
          ),
        );
    final review = const GoldenEvidenceReviewRunner().review(
      GoldenEvidenceReviewRequest(
        cases: request.cases,
        mode: GoldenEvidenceReviewMode.realDeviceEvidenceReferenceOnly,
        requireAllEvidence: true,
        androidProofEvidence: request.androidProofEvidence,
      ),
    );

    final fields = _fields(
      foundation: foundation,
      review: review,
      androidProofEvidence: request.androidProofEvidence,
    );
    final groups = _groups(
      foundation: foundation,
      fields: fields,
      review: review,
    );
    final base = BasicClassifierEvidenceContractPrototype(
      status: _statusFor(
        foundation,
        const <BasicClassifierEvidenceValidationFinding>[],
      ),
      foundationStatus: foundation.status,
      totalCaseCount: foundation.totalCaseCount,
      protectedCount: foundation.protectedCount,
      negativeGuardCount: foundation.negativeGuardCount,
      incompleteCount: foundation.incompleteCount,
      realDeviceNeededCount: foundation.realDeviceNeededCount,
      ownerProofQueueCount: foundation.ownerProofQueueCount,
      capturedAndroidProofCount: foundation.capturedAndroidProofCount,
      negativeGuardCaseIds: foundation.negativeGuardCaseIds,
      capturedAndroidProofCaseIds: foundation.capturedAndroidProofCaseIds,
      fields: List<BasicClassifierEvidenceFieldPrototype>.unmodifiable(fields),
      groups: List<BasicClassifierEvidenceGroupPrototype>.unmodifiable(groups),
      excludedScopes: const <String>['quietPreparatoryEvidenceClassification'],
      blockedOutputFamilies: _sortedStrings(const <String>[
        'advancedCandidateLabelOutput',
        'moveQualityLabelOutput',
        'finalMoveLabelOutput',
        'officialMetricOutput',
        'productReviewOutput',
        'userFacingAdviceOutput',
      ]),
      emittedOutputFamilies: const <String>[],
      validationFindings: const <BasicClassifierEvidenceValidationFinding>[],
      nextRecommendedPhase:
          BasicClassifierEvidenceContractNextPhase.internalNonLabelBucketDesign,
      readyForPhase31C: _readyForPhase31C(foundation, groups),
    );
    final findings = validator.validate(base);
    return base.copyWith(
      status: _statusFor(foundation, findings),
      validationFindings: findings,
      nextRecommendedPhase: findings.any((finding) => finding.isError)
          ? BasicClassifierEvidenceContractNextPhase.evidenceContractFixes
          : BasicClassifierEvidenceContractNextPhase
                .internalNonLabelBucketDesign,
      readyForPhase31C:
          _readyForPhase31C(foundation, groups) &&
          !findings.any((finding) => finding.isError),
    );
  }
}

class BasicClassifierEvidenceContractValidator {
  const BasicClassifierEvidenceContractValidator();

  List<BasicClassifierEvidenceValidationFinding> validate(
    BasicClassifierEvidenceContractPrototype contract,
  ) {
    final findings = <BasicClassifierEvidenceValidationFinding>[];

    void error({
      required String id,
      required String message,
      BasicClassifierContractField? field,
      BasicClassifierEvidenceGroup? group,
      String? caseId,
    }) {
      findings.add(
        BasicClassifierEvidenceValidationFinding(
          id: id,
          severity: BasicClassifierEvidenceValidationSeverity.error,
          message: message,
          field: field,
          group: group,
          caseId: caseId,
        ),
      );
    }

    for (final field in _policyBlockedFields) {
      if (contract.field(field).isPresent) {
        error(
          id: 'blockedFieldPresent',
          message: '${field.wire} must stay blocked or not implemented',
          field: field,
        );
      }
    }

    if (contract
            .group(BasicClassifierEvidenceGroup.quietPreparatoryEvidence)
            .readiness !=
        BasicClassifierEvidenceGroupReadiness.excluded) {
      error(
        id: 'quietScopeAllowed',
        message: 'quiet/preparatory evidence must remain excluded',
        group: BasicClassifierEvidenceGroup.quietPreparatoryEvidence,
      );
    }

    for (final group in contract.groups) {
      if (group.readiness ==
              BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence &&
          group.supportingCaseIds.isEmpty) {
        error(
          id: 'readyGroupWithoutSupport',
          message: '${group.group.wire} cannot be ready without support cases',
          group: group.group,
        );
      }
    }

    final proven = contract.capturedAndroidProofCaseIds.toSet();
    for (final field in <BasicClassifierContractField>[
      BasicClassifierContractField.pvAvailable,
      BasicClassifierContractField.multiPvAvailable,
    ]) {
      for (final caseId in contract.field(field).supportingCaseIds) {
        if (!proven.contains(caseId)) {
          error(
            id: 'unprovenRealDeviceProof',
            message: '${field.wire} cannot cite unproven real-device evidence',
            field: field,
            caseId: caseId,
          );
        }
      }
    }

    for (final output in contract.emittedOutputFamilies) {
      if (_isForbiddenEmittedOutput(output)) {
        error(
          id: 'forbiddenOutputEmitted',
          message: 'forbidden output family emitted: $output',
        );
      }
    }

    return findings..sort((a, b) => a.id.compareTo(b.id));
  }
}

BasicClassifierEvidenceContractStatus _statusFor(
  BasicClassifierFoundationDesignResult foundation,
  List<BasicClassifierEvidenceValidationFinding> findings,
) {
  if (findings.any((finding) => finding.isError)) {
    return BasicClassifierEvidenceContractStatus.blockedByValidation;
  }
  if (foundation.realDeviceNeededCount > 0 ||
      foundation.ownerProofQueueCount > 0 ||
      foundation.incompleteCount > 0) {
    return BasicClassifierEvidenceContractStatus.blockedByEvidence;
  }
  return BasicClassifierEvidenceContractStatus
      .readyForDeveloperEvidencePrototype;
}

bool _readyForPhase31C(
  BasicClassifierFoundationDesignResult foundation,
  List<BasicClassifierEvidenceGroupPrototype> groups,
) {
  if (!foundation.nonQuietBasicEvidenceDesignAllowed ||
      foundation.productLabelsReady ||
      foundation.advancedLabelsReady ||
      foundation.quietPreparatoryScopeAllowed) {
    return false;
  }
  final readinessByGroup = {for (final group in groups) group.group: group};
  return _nonQuietReadyGroups.every(
        (group) =>
            readinessByGroup[group]?.readiness ==
            BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence,
      ) &&
      readinessByGroup[BasicClassifierEvidenceGroup.quietPreparatoryEvidence]
              ?.readiness ==
          BasicClassifierEvidenceGroupReadiness.excluded;
}

List<BasicClassifierEvidenceFieldPrototype> _fields({
  required BasicClassifierFoundationDesignResult foundation,
  required GoldenEvidenceReviewResult review,
  required GoldenAndroidProofEvidence? androidProofEvidence,
}) {
  final capturedProof = foundation.capturedAndroidProofCaseIds;
  final negativeGuards = foundation.negativeGuardCaseIds;
  List<String> reasonCases(DeepCandidateReasonCode reason) {
    return _caseIdsWithReason(
      review,
      reason,
      androidProofEvidence: androidProofEvidence,
      capturedProofCaseIds: capturedProof,
    );
  }

  return <BasicClassifierEvidenceFieldPrototype>[
    _field(
      BasicClassifierContractField.previousEvalAvailable,
      BasicClassifierEvidenceGroup.evaluationAvailability,
      BasicClassifierEvidenceFieldStatus.futureOnly,
      const <String>[],
      'future eval input; not computed by this contract',
    ),
    _field(
      BasicClassifierContractField.playedMoveEvalAvailable,
      BasicClassifierEvidenceGroup.evaluationAvailability,
      BasicClassifierEvidenceFieldStatus.futureOnly,
      const <String>[],
      'future eval input; not computed by this contract',
    ),
    _field(
      BasicClassifierContractField.bestMoveEvalAvailable,
      BasicClassifierEvidenceGroup.evaluationAvailability,
      BasicClassifierEvidenceFieldStatus.futureOnly,
      const <String>[],
      'future eval input; not computed by this contract',
    ),
    _presentField(
      BasicClassifierContractField.candidateSpreadAvailable,
      BasicClassifierEvidenceGroup.evaluationAvailability,
      reasonCases(DeepCandidateReasonCode.candidateEvalSpread),
      'candidate spread evidence is present in protected golden cases',
    ),
    _presentField(
      BasicClassifierContractField.multiPvAvailable,
      BasicClassifierEvidenceGroup.evaluationAvailability,
      capturedProof,
      'captured Android proof supports this field only for proven cases',
    ),
    _presentField(
      BasicClassifierContractField.pvAvailable,
      BasicClassifierEvidenceGroup.evaluationAvailability,
      capturedProof,
      'captured Android proof supports this field only for proven cases',
    ),
    _presentField(
      BasicClassifierContractField.tacticalSignalAvailable,
      BasicClassifierEvidenceGroup.tacticalEvidence,
      reasonCases(DeepCandidateReasonCode.tacticalSignal),
      'tactical signal evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.captureOrPromotionAvailable,
      BasicClassifierEvidenceGroup.tacticalEvidence,
      reasonCases(DeepCandidateReasonCode.captureOrPromotion),
      'capture or promotion evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.givesCheckAvailable,
      BasicClassifierEvidenceGroup.tacticalEvidence,
      reasonCases(DeepCandidateReasonCode.givesCheck),
      'check evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.candidateSpreadSignalAvailable,
      BasicClassifierEvidenceGroup.tacticalEvidence,
      reasonCases(DeepCandidateReasonCode.candidateEvalSpread),
      'candidate spread can support tactical design',
    ),
    _presentField(
      BasicClassifierContractField.forcingLineSignalAvailable,
      BasicClassifierEvidenceGroup.forcingEvidence,
      _caseIdsWithEvidenceGroup(review, GoldenMotifEvidenceGroup.forcing),
      'forcing-line evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.mateSignalAvailable,
      BasicClassifierEvidenceGroup.tacticalEvidence,
      reasonCases(DeepCandidateReasonCode.mateScoreDetected),
      'mate signal is internal evidence only',
    ),
    _presentField(
      BasicClassifierContractField.materialSwingAvailable,
      BasicClassifierEvidenceGroup.materialEvidence,
      reasonCases(DeepCandidateReasonCode.materialSwing),
      'material swing evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.majorEvalSwingAvailable,
      BasicClassifierEvidenceGroup.materialEvidence,
      reasonCases(DeepCandidateReasonCode.majorEvalSwing),
      'major swing evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.queenWinEvidenceAvailable,
      BasicClassifierEvidenceGroup.materialEvidence,
      _caseIdsWithMotif(review, GoldenMotifTag.queenWin),
      'queen-win evidence is present as internal taxonomy',
    ),
    _presentField(
      BasicClassifierContractField.sacrificeCompensationAvailable,
      BasicClassifierEvidenceGroup.materialEvidence,
      _caseIdsWithAnyMotif(review, const <GoldenMotifTag>[
        GoldenMotifTag.materialCompensation,
        GoldenMotifTag.sacrifice,
      ]),
      'sacrifice compensation evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.kingSafetySignalAvailable,
      BasicClassifierEvidenceGroup.kingSafetyEvidence,
      _caseIdsWithEvidenceGroup(review, GoldenMotifEvidenceGroup.kingSafety),
      'king-safety evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.exposedKingSignalAvailable,
      BasicClassifierEvidenceGroup.kingSafetyEvidence,
      _caseIdsWithMotif(review, GoldenMotifTag.exposedKing),
      'exposed-king evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.matingNetSignalAvailable,
      BasicClassifierEvidenceGroup.kingSafetyEvidence,
      _caseIdsWithMotif(review, GoldenMotifTag.matingNet),
      'mating-net evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.kingHuntSignalAvailable,
      BasicClassifierEvidenceGroup.kingSafetyEvidence,
      _caseIdsWithMotif(review, GoldenMotifTag.kingHunt),
      'king-hunt evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.openingSuppressionAvailable,
      BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      _caseIdsWithSuppression(
        review,
        DeepCandidateReasonCode.openingSuppressed,
      ),
      'opening suppression evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.forcedMoveSuppressionAvailable,
      BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      _caseIdsWithSuppression(review, DeepCandidateReasonCode.forcedSuppressed),
      'forced-move suppression evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.invalidFenSuppressionAvailable,
      BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      _caseIdsWithSuppression(
        review,
        DeepCandidateReasonCode.invalidFenSuppressed,
      ),
      'invalid-FEN suppression evidence is present',
    ),
    _presentField(
      BasicClassifierContractField.budgetPressureAvailable,
      BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      _caseIdsWithSuppression(review, DeepCandidateReasonCode.budgetSuppressed),
      'budget-pressure evidence is present',
    ),
    BasicClassifierEvidenceFieldPrototype(
      field: BasicClassifierContractField.negativeGuardScopeExcluded,
      group: BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      status: BasicClassifierEvidenceFieldStatus.excludedByNegativeGuard,
      supportingCaseIds: List<String>.unmodifiable(negativeGuards),
      blockers: List<String>.unmodifiable(negativeGuards),
      note: 'negative guard excludes quiet/preparatory classification',
    ),
    _field(
      BasicClassifierContractField.cpLossAvailable,
      BasicClassifierEvidenceGroup.futureProductInputs,
      BasicClassifierEvidenceFieldStatus.notImplemented,
      const <String>[],
      'future-only product input; not computed by this contract',
    ),
    _field(
      BasicClassifierContractField.winProbabilityAvailable,
      BasicClassifierEvidenceGroup.futureProductInputs,
      BasicClassifierEvidenceFieldStatus.notImplemented,
      const <String>[],
      'future-only product input; not computed by this contract',
    ),
    _field(
      BasicClassifierContractField.officialAccuracyAvailable,
      BasicClassifierEvidenceGroup.futureProductInputs,
      BasicClassifierEvidenceFieldStatus.blockedByPolicy,
      const <String>[],
      'blocked official metric field',
    ),
    _field(
      BasicClassifierContractField.officialAcplAvailable,
      BasicClassifierEvidenceGroup.futureProductInputs,
      BasicClassifierEvidenceFieldStatus.blockedByPolicy,
      const <String>[],
      'blocked official metric field',
    ),
    _field(
      BasicClassifierContractField.productLabelOutputAvailable,
      BasicClassifierEvidenceGroup.futureProductInputs,
      BasicClassifierEvidenceFieldStatus.blockedByPolicy,
      const <String>[],
      'product label output is blocked',
    ),
  ]..sort((a, b) => a.field.wire.compareTo(b.field.wire));
}

List<BasicClassifierEvidenceGroupPrototype> _groups({
  required BasicClassifierFoundationDesignResult foundation,
  required List<BasicClassifierEvidenceFieldPrototype> fields,
  required GoldenEvidenceReviewResult review,
}) {
  final fieldsByGroup =
      <
        BasicClassifierEvidenceGroup,
        List<BasicClassifierEvidenceFieldPrototype>
      >{};
  for (final field in fields) {
    fieldsByGroup
        .putIfAbsent(
          field.group,
          () => <BasicClassifierEvidenceFieldPrototype>[],
        )
        .add(field);
  }

  BasicClassifierEvidenceGroupPrototype group(
    BasicClassifierEvidenceGroup group,
    BasicClassifierEvidenceGroupReadiness readiness,
    List<String> support,
    String recommendation, {
    List<String> blockers = const <String>[],
    List<String> blockerCaseIds = const <String>[],
  }) {
    final groupFields =
        fieldsByGroup[group] ?? const <BasicClassifierEvidenceFieldPrototype>[];
    return BasicClassifierEvidenceGroupPrototype(
      group: group,
      readiness: readiness,
      fieldIds: groupFields.map((field) => field.field).toList()
        ..sort((a, b) => a.wire.compareTo(b.wire)),
      supportingCaseIds: _sortedStrings(support),
      blockerCaseIds: _sortedStrings(blockerCaseIds),
      blockers: _sortedStrings(blockers),
      recommendation: recommendation,
    );
  }

  return <BasicClassifierEvidenceGroupPrototype>[
    group(
      BasicClassifierEvidenceGroup.evaluationAvailability,
      BasicClassifierEvidenceGroupReadiness.partial,
      _supportForFields(
        fieldsByGroup[BasicClassifierEvidenceGroup.evaluationAvailability],
      ),
      'Partial: PV, MultiPV, and candidate spread are represented, while eval inputs remain future-only.',
    ),
    group(
      BasicClassifierEvidenceGroup.tacticalEvidence,
      _readyIfSupported(
        _supportForFields(
          fieldsByGroup[BasicClassifierEvidenceGroup.tacticalEvidence],
        ),
      ),
      _supportForFields(
        fieldsByGroup[BasicClassifierEvidenceGroup.tacticalEvidence],
      ),
      'Ready for developer evidence design only.',
    ),
    group(
      BasicClassifierEvidenceGroup.materialEvidence,
      _readyIfSupported(
        _supportForFields(
          fieldsByGroup[BasicClassifierEvidenceGroup.materialEvidence],
        ),
      ),
      _supportForFields(
        fieldsByGroup[BasicClassifierEvidenceGroup.materialEvidence],
      ),
      'Ready for developer evidence design only.',
    ),
    group(
      BasicClassifierEvidenceGroup.forcingEvidence,
      _readyIfSupported(
        _supportForFields(
          fieldsByGroup[BasicClassifierEvidenceGroup.forcingEvidence],
        ),
      ),
      _supportForFields(
        fieldsByGroup[BasicClassifierEvidenceGroup.forcingEvidence],
      ),
      'Ready for developer evidence design only.',
    ),
    group(
      BasicClassifierEvidenceGroup.kingSafetyEvidence,
      _readyIfSupported(
        _supportForFields(
          fieldsByGroup[BasicClassifierEvidenceGroup.kingSafetyEvidence],
        ),
      ),
      _supportForFields(
        fieldsByGroup[BasicClassifierEvidenceGroup.kingSafetyEvidence],
      ),
      'Ready for developer evidence design only.',
    ),
    group(
      BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      _readyIfSupported(
        _supportForFields(
          fieldsByGroup[BasicClassifierEvidenceGroup.safetySuppressionEvidence],
        ),
      ),
      _supportForFields(
        fieldsByGroup[BasicClassifierEvidenceGroup.safetySuppressionEvidence],
      ),
      'Ready for developer evidence design only.',
    ),
    group(
      BasicClassifierEvidenceGroup.quietPreparatoryEvidence,
      BasicClassifierEvidenceGroupReadiness.excluded,
      _quietProtectedSupport(review),
      'Excluded by negative guard; protected quiet evidence does not unblock classification.',
      blockers: const <String>['quiet/preparatory excluded by negative guard'],
      blockerCaseIds: foundation.negativeGuardCaseIds,
    ),
    group(
      BasicClassifierEvidenceGroup.futureProductInputs,
      BasicClassifierEvidenceGroupReadiness.futureOnly,
      const <String>[],
      'Future-only and policy-blocked product inputs remain unavailable.',
      blockers: const <String>[
        'product outputs and official metrics are blocked',
      ],
    ),
  ]..sort((a, b) => a.group.wire.compareTo(b.group.wire));
}

BasicClassifierEvidenceGroupReadiness _readyIfSupported(List<String> support) {
  return support.isEmpty
      ? BasicClassifierEvidenceGroupReadiness.partial
      : BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence;
}

BasicClassifierEvidenceFieldPrototype _field(
  BasicClassifierContractField field,
  BasicClassifierEvidenceGroup group,
  BasicClassifierEvidenceFieldStatus status,
  List<String> support,
  String note, {
  List<String> blockers = const <String>[],
}) {
  return BasicClassifierEvidenceFieldPrototype(
    field: field,
    group: group,
    status: status,
    supportingCaseIds: _sortedStrings(support),
    blockers: _sortedStrings(blockers),
    note: note,
  );
}

BasicClassifierEvidenceFieldPrototype _presentField(
  BasicClassifierContractField field,
  BasicClassifierEvidenceGroup group,
  List<String> support,
  String note,
) {
  return _field(
    field,
    group,
    support.isEmpty
        ? BasicClassifierEvidenceFieldStatus.missing
        : BasicClassifierEvidenceFieldStatus.present,
    support,
    support.isEmpty ? '$note; no supporting case yet' : note,
  );
}

List<String> _supportForFields(
  List<BasicClassifierEvidenceFieldPrototype>? fields,
) {
  final support = <String>{};
  for (final field
      in fields ?? const <BasicClassifierEvidenceFieldPrototype>[]) {
    support.addAll(field.supportingCaseIds);
  }
  return support.toList()..sort();
}

List<String> _caseIdsWithReason(
  GoldenEvidenceReviewResult review,
  DeepCandidateReasonCode reason, {
  GoldenAndroidProofEvidence? androidProofEvidence,
  List<String> capturedProofCaseIds = const <String>[],
}) {
  final ids = <String>{
    ...review.caseReviews
        .where(
          (item) =>
              item.passedLike && item.satisfiedReasonCodes.contains(reason),
        )
        .map((item) => item.caseId),
  };
  if (androidProofEvidence != null) {
    for (final caseId in capturedProofCaseIds) {
      if (androidProofEvidence.reasonCountsFor(caseId).containsKey(reason)) {
        ids.add(caseId);
      }
    }
  }
  return _sortedStrings(ids);
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

List<String> _caseIdsWithMotif(
  GoldenEvidenceReviewResult review,
  GoldenMotifTag motif,
) {
  return _caseIdsWithAnyMotif(review, <GoldenMotifTag>[motif]);
}

List<String> _caseIdsWithAnyMotif(
  GoldenEvidenceReviewResult review,
  List<GoldenMotifTag> motifs,
) {
  final motifSet = motifs.toSet();
  return _sortedStrings(
    review.caseReviews
        .where((item) => item.passedLike && item.motifs.any(motifSet.contains))
        .map((item) => item.caseId),
  );
}

List<String> _quietProtectedSupport(GoldenEvidenceReviewResult review) {
  return _sortedStrings(
    review.caseReviews
        .where(
          (item) =>
              item.passedLike &&
              item.motifs.contains(GoldenMotifTag.quietPreparatoryMove),
        )
        .map((item) => item.caseId),
  );
}

String _ids(List<String> values) => values.isEmpty ? '-' : values.join(', ');

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
}

bool _isForbiddenEmittedOutput(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('productlabel') ||
      normalized.contains('movequality') ||
      normalized.contains('finalmove') ||
      normalized.contains('advancedcandidate') ||
      normalized.contains('brilliant') ||
      normalized.contains('great') ||
      normalized.contains('miss') ||
      normalized.contains('best') ||
      normalized.contains('good') ||
      normalized.contains('inaccuracy') ||
      normalized.contains('mistake') ||
      normalized.contains('blunder') ||
      normalized.contains('accuracy') ||
      normalized.contains('acpl');
}

const _policyBlockedFields = <BasicClassifierContractField>{
  BasicClassifierContractField.productLabelOutputAvailable,
  BasicClassifierContractField.officialAccuracyAvailable,
  BasicClassifierContractField.officialAcplAvailable,
  BasicClassifierContractField.cpLossAvailable,
  BasicClassifierContractField.winProbabilityAvailable,
};

const _nonQuietReadyGroups = <BasicClassifierEvidenceGroup>{
  BasicClassifierEvidenceGroup.tacticalEvidence,
  BasicClassifierEvidenceGroup.materialEvidence,
  BasicClassifierEvidenceGroup.forcingEvidence,
  BasicClassifierEvidenceGroup.kingSafetyEvidence,
  BasicClassifierEvidenceGroup.safetySuppressionEvidence,
};
