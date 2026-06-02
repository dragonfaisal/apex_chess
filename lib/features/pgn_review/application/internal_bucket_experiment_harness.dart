/// Developer-only harness for approved internal bucket experiments.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_classifier_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';

const internalBucketExperimentHarnessReportVersion =
    'internal-bucket-experiment-harness-v1';

enum InternalBucketExperimentHarnessStatus {
  skippedByGuard('skippedByGuard'),
  completedInternalOnly('completedInternalOnly'),
  completedWithWarnings('completedWithWarnings'),
  blocked('blocked'),
  invalidRequest('invalidRequest'),
  failed('failed');

  const InternalBucketExperimentHarnessStatus(this.wire);

  final String wire;
}

enum InternalBucketExperimentHarnessNextRecommendation {
  futureInternalNonLabelAnalysis(
    'Phase 31F -- Internal Evidence Area Analysis With Labels Still Blocked',
  ),
  guardPolicyFixes('Phase 31F -- Guard Policy Fixes'),
  evidenceSupportFixes('Phase 31F -- Evidence Support Fixes');

  const InternalBucketExperimentHarnessNextRecommendation(this.wire);

  final String wire;
}

enum InternalBucketExperimentHarnessReportFormat {
  markdown('markdown'),
  json('json');

  const InternalBucketExperimentHarnessReportFormat(this.wire);

  final String wire;
}

class InternalBucketExperimentHarnessRequest {
  const InternalBucketExperimentHarnessRequest({
    this.experimentRequest = const InternalBucketExperimentRequest.safeDemo(),
    this.guardResult,
    this.includePartialBuckets = false,
    this.includeSupportCases = true,
    this.includeAndroidProofReferences = true,
    this.strictGuardRequired = true,
    this.notes = const <String>[],
  });

  InternalBucketExperimentHarnessRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    this.includePartialBuckets = false,
    this.includeSupportCases = true,
    this.includeAndroidProofReferences = true,
    this.strictGuardRequired = true,
    this.notes = const <String>[],
    this.guardResult,
  }) : experimentRequest = InternalBucketExperimentRequest.safeDemo(
         cases: cases,
       );

  final InternalBucketExperimentRequest experimentRequest;
  final InternalBucketExperimentGuardResult? guardResult;
  final bool includePartialBuckets;
  final bool includeSupportCases;
  final bool includeAndroidProofReferences;
  final bool strictGuardRequired;
  final List<String> notes;

  String get experimentId => experimentRequest.experimentId;

  List<InternalEvidenceBucketId> get requestedBuckets =>
      experimentRequest.requestedBuckets;
}

class InternalBucketExperimentObservation {
  const InternalBucketExperimentObservation({
    required this.bucketId,
    required this.bucketStatus,
    required this.observed,
    required this.supportCaseIds,
    required this.androidProofCaseIds,
    this.warningReason,
    this.blockedReason,
    required this.evidenceGroup,
    this.isProductOutput = false,
    this.isClassifierLabel = false,
    this.isOfficialMetric = false,
    this.isQuietScope = false,
  });

  final InternalEvidenceBucketId bucketId;
  final InternalEvidenceBucketStatus bucketStatus;
  final bool observed;
  final List<String> supportCaseIds;
  final List<String> androidProofCaseIds;
  final String? warningReason;
  final String? blockedReason;
  final String evidenceGroup;
  final bool isProductOutput;
  final bool isClassifierLabel;
  final bool isOfficialMetric;
  final bool isQuietScope;

  bool get hasWarning => _hasText(warningReason);

  bool get isUnsafeIfObserved =>
      observed &&
      (isProductOutput ||
          isClassifierLabel ||
          isOfficialMetric ||
          isQuietScope);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'bucketId': bucketId.wire,
      'bucketStatus': bucketStatus.wire,
      'observed': observed,
      'supportCaseIds': supportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReason': warningReason,
      'blockedReason': blockedReason,
      'evidenceGroup': evidenceGroup,
      'isProductOutput': isProductOutput,
      'isClassifierLabel': isClassifierLabel,
      'isOfficialMetric': isOfficialMetric,
      'isQuietScope': isQuietScope,
    };
  }
}

class InternalBucketExperimentHarnessResult {
  const InternalBucketExperimentHarnessResult({
    required this.experimentId,
    required this.status,
    required this.guardStatus,
    required this.guardAllowed,
    required this.requestedBucketCount,
    required this.observations,
    required this.inactiveObservations,
    required this.guardPolicyViolations,
    required this.supportingCaseIds,
    required this.androidProofCaseIds,
    required this.unprovenAndroidCaseIds,
    required this.excludedScopeIds,
    required this.readyEvidenceAreas,
    required this.blockedEvidenceAreas,
    required this.partialWarnings,
    required this.skippedBucketIds,
    required this.blockedBucketIds,
    required this.warnings,
    required this.failures,
    required this.nextRecommendation,
    this.developerOnly = true,
    this.productOutputEmitted = false,
    this.classifierLabelsEmitted = false,
    this.officialMetricsEmitted = false,
    this.cpLossComputed = false,
    this.winProbabilityComputed = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
  });

  final String experimentId;
  final InternalBucketExperimentHarnessStatus status;
  final InternalBucketExperimentGuardStatus guardStatus;
  final bool guardAllowed;
  final int requestedBucketCount;
  final List<InternalBucketExperimentObservation> observations;
  final List<InternalBucketExperimentObservation> inactiveObservations;
  final List<InternalBucketExperimentPolicyViolation> guardPolicyViolations;
  final List<String> supportingCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> unprovenAndroidCaseIds;
  final List<String> excludedScopeIds;
  final List<String> readyEvidenceAreas;
  final List<String> blockedEvidenceAreas;
  final List<String> partialWarnings;
  final List<InternalEvidenceBucketId> skippedBucketIds;
  final List<InternalEvidenceBucketId> blockedBucketIds;
  final List<String> warnings;
  final List<String> failures;
  final InternalBucketExperimentHarnessNextRecommendation nextRecommendation;
  final bool developerOnly;
  final bool productOutputEmitted;
  final bool classifierLabelsEmitted;
  final bool officialMetricsEmitted;
  final bool cpLossComputed;
  final bool winProbabilityComputed;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;

  int get observedBucketCount =>
      observations.where((observation) => observation.observed).length;

  bool get allowed =>
      status == InternalBucketExperimentHarnessStatus.completedInternalOnly ||
      status == InternalBucketExperimentHarnessStatus.completedWithWarnings;

  bool get hasWarnings =>
      warnings.isNotEmpty ||
      partialWarnings.isNotEmpty ||
      observations.any((observation) => observation.hasWarning);

  bool get isStrictlyBlocked =>
      status == InternalBucketExperimentHarnessStatus.skippedByGuard ||
      status == InternalBucketExperimentHarnessStatus.blocked ||
      status == InternalBucketExperimentHarnessStatus.invalidRequest ||
      status == InternalBucketExperimentHarnessStatus.failed;

  bool get hasUnsafeHarnessOutputPolicyViolation {
    if (observations.any((observation) => observation.isUnsafeIfObserved)) {
      return true;
    }
    if (productOutputEmitted ||
        classifierLabelsEmitted ||
        officialMetricsEmitted ||
        cpLossComputed ||
        winProbabilityComputed ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed) {
      return true;
    }
    return guardPolicyViolations.any(_isUnsafeGuardViolation) ||
        unprovenAndroidCaseIds.isNotEmpty;
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Bucket Experiment Harness')
      ..writeln()
      ..writeln('- version: $internalBucketExperimentHarnessReportVersion')
      ..writeln('- experiment ID: $experimentId')
      ..writeln('- harness status: ${status.wire}')
      ..writeln('- guard status: ${guardStatus.wire}')
      ..writeln('- guard allowed: $guardAllowed')
      ..writeln('- developer only: $developerOnly')
      ..writeln('- classifier output emitted: false')
      ..writeln()
      ..writeln('## Summary')
      ..writeln('- requested bucket count: $requestedBucketCount')
      ..writeln('- observed bucket count: $observedBucketCount')
      ..writeln('- skipped bucket IDs: ${_bucketIds(skippedBucketIds)}')
      ..writeln('- blocked bucket IDs: ${_bucketIds(blockedBucketIds)}')
      ..writeln()
      ..writeln('## Guard-First Decision');
    if (guardPolicyViolations.isEmpty) {
      buffer.writeln('- guard violations: none');
    } else {
      for (final violation in guardPolicyViolations) {
        buffer.writeln(
          '- ${violation.severity.wire}: ${violation.id}: '
          '${violation.message}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Observations')
      ..writeln(
        '| Bucket | Status | Observed | Evidence Area | Support Cases | Android Proof References | Warning |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    if (observations.isEmpty) {
      buffer.writeln('| - | - | false | - | - | - | - |');
    } else {
      for (final observation in observations) {
        buffer.writeln(
          '| ${observation.bucketId.wire} | ${observation.bucketStatus.wire} | '
          '${observation.observed} | ${observation.evidenceGroup} | '
          '${_ids(observation.supportCaseIds)} | '
          '${_ids(observation.androidProofCaseIds)} | '
          '${_cell(observation.warningReason ?? "-")} |',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Inactive Excluded Or Blocked Areas');
    if (inactiveObservations.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final observation in inactiveObservations) {
        buffer.writeln(
          '- ${observation.bucketId.wire}: ${observation.bucketStatus.wire}; '
          '${observation.blockedReason ?? "inactive"}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Partial Warnings');
    if (partialWarnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in partialWarnings) {
        buffer.writeln('- $warning');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Support Cases')
      ..writeln('- case IDs: ${_ids(supportingCaseIds)}')
      ..writeln()
      ..writeln('## Android Proof References')
      ..writeln('- proven case IDs: ${_ids(androidProofCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
      ..writeln()
      ..writeln('## Quiet Preparatory Exclusion')
      ..writeln('- excluded scope IDs: ${_ids(excludedScopeIds)}')
      ..writeln()
      ..writeln('## Product And Metric Blocks')
      ..writeln('- product-label block: active')
      ..writeln('- advanced-label block: active')
      ..writeln('- official-metric block: active')
      ..writeln('- CP-loss computation block: active')
      ..writeln('- win-probability computation block: active')
      ..writeln('- direct-engine block: active')
      ..writeln('- UI/backend/persistence block: active')
      ..writeln()
      ..writeln('## Ready Evidence Areas')
      ..writeln('- ${_ids(readyEvidenceAreas)}')
      ..writeln()
      ..writeln('## Areas That Remain Blocked Or Excluded')
      ..writeln('- ${_ids(blockedEvidenceAreas)}')
      ..writeln()
      ..writeln('## Warnings');
    if (warnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- $failure');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Next Recommendation')
      ..writeln(nextRecommendation.wire)
      ..writeln()
      ..writeln(
        'This harness observes approved internal evidence buckets only. It does '
        'not score moves, classify moves, compute product metrics, call an '
        'engine, run Android, write files, or emit product-facing output.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalBucketExperimentHarnessReportVersion,
      'experimentId': experimentId,
      'harnessStatus': status.wire,
      'guardStatus': guardStatus.wire,
      'guardAllowed': guardAllowed,
      'requestedBucketCount': requestedBucketCount,
      'observedBucketCount': observedBucketCount,
      'observations': observations
          .map((observation) => observation.toJson())
          .toList(),
      'inactiveObservations': inactiveObservations
          .map((observation) => observation.toJson())
          .toList(),
      'guardPolicyViolations': guardPolicyViolations
          .map((violation) => violation.toJson())
          .toList(),
      'supportingCaseIds': supportingCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'unprovenAndroidCaseIds': unprovenAndroidCaseIds,
      'excludedScopeIds': excludedScopeIds,
      'readyEvidenceAreas': readyEvidenceAreas,
      'blockedEvidenceAreas': blockedEvidenceAreas,
      'partialWarnings': partialWarnings,
      'skippedBucketIds': skippedBucketIds
          .map((bucketId) => bucketId.wire)
          .toList(),
      'blockedBucketIds': blockedBucketIds
          .map((bucketId) => bucketId.wire)
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'nextRecommendation': nextRecommendation.wire,
      'developerOnly': developerOnly,
      'productOutputEmitted': productOutputEmitted,
      'classifierLabelsEmitted': classifierLabelsEmitted,
      'officialMetricsEmitted': officialMetricsEmitted,
      'cpLossComputed': cpLossComputed,
      'winProbabilityComputed': winProbabilityComputed,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class InternalBucketExperimentHarness {
  const InternalBucketExperimentHarness({
    this.guard = const InternalBucketExperimentGuard(),
  });

  final InternalBucketExperimentGuard guard;

  InternalBucketExperimentHarnessResult run(
    InternalBucketExperimentHarnessRequest request,
  ) {
    final guardResult =
        request.guardResult ?? guard.evaluate(request.experimentRequest);

    if (!request.strictGuardRequired) {
      return _blockedResult(
        request: request,
        guardResult: guardResult,
        status: InternalBucketExperimentHarnessStatus.invalidRequest,
        failures: const <String>[
          'strict guard approval is required before harness execution',
        ],
      );
    }

    if (!_guardApprovedForHarness(guardResult)) {
      final status =
          guardResult.overallStatus ==
              InternalBucketExperimentGuardStatus.invalidRequest
          ? InternalBucketExperimentHarnessStatus.invalidRequest
          : InternalBucketExperimentHarnessStatus.skippedByGuard;
      return _blockedResult(
        request: request,
        guardResult: guardResult,
        status: status,
      );
    }

    final inputs = _resolveInputs(request.experimentRequest);
    final provenAndroidIds = guardResult.provenAndroidCaseIds.toSet();
    final observations = <InternalBucketExperimentObservation>[];
    final inactive = <InternalBucketExperimentObservation>[];
    final skippedBucketIds = <InternalEvidenceBucketId>[];
    final supportingCaseIds = <String>{};
    final androidProofCaseIds = <String>{};
    final warnings = <String>{...guardResult.warnings};
    final partialWarnings = <String>{};

    for (final bucketId in guardResult.allowedBucketIds) {
      final bucket = inputs.buckets.bucket(bucketId);
      final supportCaseIds = request.includeSupportCases
          ? bucket.supportingCaseIds
          : const <String>[];
      final proofCaseIds = request.includeAndroidProofReferences
          ? _proofIds(bucket.supportingCaseIds, provenAndroidIds)
          : const <String>[];
      final warningReason =
          bucket.status == InternalEvidenceBucketStatus.partial
          ? 'partial bucket may be used only as warning evidence'
          : null;
      if (bucket.status == InternalEvidenceBucketStatus.partial) {
        partialWarnings.add('${bucket.id.wire}: $warningReason');
      }

      if (bucket.status == InternalEvidenceBucketStatus.partial &&
          !request.includePartialBuckets) {
        skippedBucketIds.add(bucket.id);
        warnings.add('${bucket.id.wire}: partial bucket skipped by request');
        inactive.add(
          InternalBucketExperimentObservation(
            bucketId: bucket.id,
            bucketStatus: bucket.status,
            observed: false,
            supportCaseIds: supportCaseIds,
            androidProofCaseIds: proofCaseIds,
            warningReason: warningReason,
            blockedReason: 'partial bucket skipped by harness option',
            evidenceGroup: _evidenceGroupFor(bucket.id),
          ),
        );
        continue;
      }

      observations.add(
        InternalBucketExperimentObservation(
          bucketId: bucket.id,
          bucketStatus: bucket.status,
          observed: true,
          supportCaseIds: List<String>.unmodifiable(supportCaseIds),
          androidProofCaseIds: List<String>.unmodifiable(proofCaseIds),
          warningReason: warningReason,
          evidenceGroup: _evidenceGroupFor(bucket.id),
        ),
      );
      supportingCaseIds.addAll(supportCaseIds);
      androidProofCaseIds.addAll(proofCaseIds);
    }

    inactive.addAll(_inactivePolicyObservations(inputs.buckets, request));

    final status =
        guardResult.overallStatus ==
                InternalBucketExperimentGuardStatus.allowedWithWarnings ||
            warnings.isNotEmpty ||
            partialWarnings.isNotEmpty ||
            skippedBucketIds.isNotEmpty
        ? InternalBucketExperimentHarnessStatus.completedWithWarnings
        : InternalBucketExperimentHarnessStatus.completedInternalOnly;
    final readyAreas = _readyEvidenceAreas(observations);
    final blockedAreas = _blockedEvidenceAreas(inactive, guardResult);
    return InternalBucketExperimentHarnessResult(
      experimentId: guardResult.experimentId,
      status: status,
      guardStatus: guardResult.overallStatus,
      guardAllowed: guardResult.allowed,
      requestedBucketCount: guardResult.requestedBucketCount,
      observations: List<InternalBucketExperimentObservation>.unmodifiable(
        observations..sort(_compareObservations),
      ),
      inactiveObservations:
          List<InternalBucketExperimentObservation>.unmodifiable(
            inactive..sort(_compareObservations),
          ),
      guardPolicyViolations: guardResult.policyViolations,
      supportingCaseIds: _sortedStrings(supportingCaseIds),
      androidProofCaseIds: _sortedStrings(androidProofCaseIds),
      unprovenAndroidCaseIds: guardResult.unprovenAndroidCaseIds,
      excludedScopeIds: guardResult.excludedScopeIds,
      readyEvidenceAreas: readyAreas,
      blockedEvidenceAreas: blockedAreas,
      partialWarnings: _sortedStrings(partialWarnings),
      skippedBucketIds: _sortedBucketIds(skippedBucketIds),
      blockedBucketIds: guardResult.blockedBucketIds,
      warnings: _sortedStrings(warnings),
      failures: guardResult.failures,
      nextRecommendation: readyAreas.isEmpty
          ? InternalBucketExperimentHarnessNextRecommendation
                .evidenceSupportFixes
          : InternalBucketExperimentHarnessNextRecommendation
                .futureInternalNonLabelAnalysis,
    );
  }
}

class _ResolvedHarnessInputs {
  const _ResolvedHarnessInputs({
    required this.readiness,
    required this.foundation,
    required this.contract,
    required this.buckets,
  });

  final GoldenClassifierReadinessResult readiness;
  final BasicClassifierFoundationDesignResult foundation;
  final BasicClassifierEvidenceContractPrototype contract;
  final InternalEvidenceBucketPrototype buckets;
}

_ResolvedHarnessInputs _resolveInputs(InternalBucketExperimentRequest request) {
  final readiness =
      request.readiness ??
      request.readinessGate.evaluate(
        GoldenClassifierReadinessRequest(
          cases: request.cases,
          androidProofEvidence: request.androidProofEvidence,
        ),
      );
  final foundation =
      request.foundationDesign ??
      request.foundationDesigner.evaluate(
        BasicClassifierFoundationDesignRequest(
          cases: request.cases,
          readiness: readiness,
          androidProofEvidence: request.androidProofEvidence,
        ),
      );
  final contract =
      request.contract ??
      request.contractBuilder.evaluate(
        BasicClassifierEvidenceContractRequest(
          cases: request.cases,
          foundationDesign: foundation,
          androidProofEvidence: request.androidProofEvidence,
        ),
      );
  final buckets =
      request.bucketPrototype ??
      request.bucketBuilder.evaluate(
        InternalEvidenceBucketRequest(
          cases: request.cases,
          contract: contract,
          foundationDesign: foundation,
          androidProofEvidence: request.androidProofEvidence,
        ),
      );
  return _ResolvedHarnessInputs(
    readiness: readiness,
    foundation: foundation,
    contract: contract,
    buckets: buckets,
  );
}

InternalBucketExperimentHarnessResult _blockedResult({
  required InternalBucketExperimentHarnessRequest request,
  required InternalBucketExperimentGuardResult guardResult,
  required InternalBucketExperimentHarnessStatus status,
  List<String> failures = const <String>[],
}) {
  final mergedFailures = <String>{...guardResult.failures, ...failures};
  return InternalBucketExperimentHarnessResult(
    experimentId: guardResult.experimentId,
    status: status,
    guardStatus: guardResult.overallStatus,
    guardAllowed: guardResult.allowed,
    requestedBucketCount: guardResult.requestedBucketCount,
    observations: const <InternalBucketExperimentObservation>[],
    inactiveObservations: const <InternalBucketExperimentObservation>[],
    guardPolicyViolations: guardResult.policyViolations,
    supportingCaseIds: const <String>[],
    androidProofCaseIds: const <String>[],
    unprovenAndroidCaseIds: guardResult.unprovenAndroidCaseIds,
    excludedScopeIds: guardResult.excludedScopeIds,
    readyEvidenceAreas: const <String>[],
    blockedEvidenceAreas: _sortedStrings(<String>[
      'quietPreparatoryEvidenceClassification',
      'productLabelOutputBlocked',
      'advancedLabelGateBlocked',
      'officialMetricsBlocked',
      'cpLossComputationBlocked',
      'winProbabilityComputationBlocked',
      ...guardResult.blockedBucketIds.map((bucketId) => bucketId.wire),
    ]),
    partialWarnings: guardResult.warnings,
    skippedBucketIds: const <InternalEvidenceBucketId>[],
    blockedBucketIds: guardResult.blockedBucketIds,
    warnings: guardResult.warnings,
    failures: _sortedStrings(mergedFailures),
    nextRecommendation:
        InternalBucketExperimentHarnessNextRecommendation.guardPolicyFixes,
  );
}

List<InternalBucketExperimentObservation> _inactivePolicyObservations(
  InternalEvidenceBucketPrototype buckets,
  InternalBucketExperimentHarnessRequest request,
) {
  final inactive = <InternalBucketExperimentObservation>[];
  for (final bucketId in const <InternalEvidenceBucketId>[
    InternalEvidenceBucketId.quietPreparatoryExcluded,
    InternalEvidenceBucketId.productLabelOutputBlocked,
    InternalEvidenceBucketId.advancedLabelGateBlocked,
    InternalEvidenceBucketId.officialMetricsBlocked,
    InternalEvidenceBucketId.cpLossComputationBlocked,
    InternalEvidenceBucketId.winProbabilityComputationBlocked,
  ]) {
    final bucket = buckets.bucket(bucketId);
    inactive.add(
      InternalBucketExperimentObservation(
        bucketId: bucket.id,
        bucketStatus: bucket.status,
        observed: false,
        supportCaseIds: request.includeSupportCases
            ? bucket.supportingCaseIds
            : const <String>[],
        androidProofCaseIds: const <String>[],
        blockedReason: _blockedReasonFor(bucket.id),
        evidenceGroup: _evidenceGroupFor(bucket.id),
        isQuietScope:
            bucket.id == InternalEvidenceBucketId.quietPreparatoryExcluded,
      ),
    );
  }
  return inactive;
}

String _evidenceGroupFor(InternalEvidenceBucketId bucketId) {
  return switch (bucketId) {
    InternalEvidenceBucketId.tacticalSupported =>
      BasicClassifierEvidenceGroup.tacticalEvidence.wire,
    InternalEvidenceBucketId.materialSwingSupported =>
      BasicClassifierEvidenceGroup.materialEvidence.wire,
    InternalEvidenceBucketId.forcingLineSupported =>
      BasicClassifierEvidenceGroup.forcingEvidence.wire,
    InternalEvidenceBucketId.kingSafetySupported =>
      BasicClassifierEvidenceGroup.kingSafetyEvidence.wire,
    InternalEvidenceBucketId.endgameConservativeSupported =>
      BasicClassifierDesignScope.endgameEvidenceDesign.wire,
    InternalEvidenceBucketId.safetySuppressionSupported ||
    InternalEvidenceBucketId.invalidFenSuppressed ||
    InternalEvidenceBucketId.openingSuppressed ||
    InternalEvidenceBucketId.forcedMoveSuppressed ||
    InternalEvidenceBucketId.budgetPressureVisible =>
      BasicClassifierEvidenceGroup.safetySuppressionEvidence.wire,
    InternalEvidenceBucketId.androidProofBacked => 'androidProofBacked',
    InternalEvidenceBucketId.candidateSpreadSupported ||
    InternalEvidenceBucketId.pvMultiPvSupported =>
      BasicClassifierEvidenceGroup.evaluationAvailability.wire,
    InternalEvidenceBucketId.quietPreparatoryExcluded =>
      BasicClassifierEvidenceGroup.quietPreparatoryEvidence.wire,
    InternalEvidenceBucketId.productLabelOutputBlocked ||
    InternalEvidenceBucketId.advancedLabelGateBlocked ||
    InternalEvidenceBucketId.officialMetricsBlocked ||
    InternalEvidenceBucketId.cpLossComputationBlocked ||
    InternalEvidenceBucketId.winProbabilityComputationBlocked =>
      BasicClassifierEvidenceGroup.futureProductInputs.wire,
  };
}

String _blockedReasonFor(InternalEvidenceBucketId bucketId) {
  return switch (bucketId) {
    InternalEvidenceBucketId.quietPreparatoryExcluded =>
      'quiet/preparatory scope remains excluded by negative guard',
    InternalEvidenceBucketId.productLabelOutputBlocked =>
      'product-facing output remains blocked',
    InternalEvidenceBucketId.advancedLabelGateBlocked =>
      'advanced candidate output remains blocked',
    InternalEvidenceBucketId.officialMetricsBlocked =>
      'official metric output remains blocked',
    InternalEvidenceBucketId.cpLossComputationBlocked =>
      'CP-loss computation is not implemented',
    InternalEvidenceBucketId.winProbabilityComputationBlocked =>
      'win-probability computation is not implemented',
    _ => 'inactive by policy',
  };
}

List<String> _proofIds(
  List<String> candidateIds,
  Set<String> provenAndroidIds,
) {
  return _sortedStrings(candidateIds.where(provenAndroidIds.contains));
}

List<String> _readyEvidenceAreas(
  List<InternalBucketExperimentObservation> observations,
) {
  return _sortedStrings(
    observations
        .where((observation) => observation.observed)
        .map((observation) => observation.evidenceGroup)
        .toSet(),
  );
}

List<String> _blockedEvidenceAreas(
  List<InternalBucketExperimentObservation> inactiveObservations,
  InternalBucketExperimentGuardResult guardResult,
) {
  return _sortedStrings(<String>[
    ...inactiveObservations.map((observation) => observation.bucketId.wire),
    ...guardResult.blockedBucketIds.map((bucketId) => bucketId.wire),
    ...guardResult.excludedScopeIds,
  ]);
}

bool _guardApprovedForHarness(InternalBucketExperimentGuardResult result) {
  return result.overallStatus ==
          InternalBucketExperimentGuardStatus.allowedInternalOnly ||
      result.overallStatus ==
          InternalBucketExperimentGuardStatus.allowedWithWarnings;
}

bool _isUnsafeGuardViolation(InternalBucketExperimentPolicyViolation item) {
  return const <String>{
    'androidProofClaimsDisabled',
    'advancedLabelOutputRequested',
    'cpLossComputationRequested',
    'directEngineAccessRequested',
    'officialMetricOutputRequested',
    'persistenceRequested',
    'productLabelOutputRequested',
    'quietScopeRequested',
    'uiOrBackendOutputRequested',
    'unprovenAndroidProofClaim',
    'winProbabilityComputationRequested',
  }.contains(item.id);
}

int _compareObservations(
  InternalBucketExperimentObservation a,
  InternalBucketExperimentObservation b,
) {
  return a.bucketId.index.compareTo(b.bucketId.index);
}

String _ids(List<String> values) => values.isEmpty ? '-' : values.join(', ');

String _bucketIds(List<InternalEvidenceBucketId> values) =>
    values.isEmpty ? '-' : values.map((value) => value.wire).join(', ');

String _cell(String value) => value.replaceAll('|', '/');

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toList()..sort((a, b) => a.index.compareTo(b.index));
}
