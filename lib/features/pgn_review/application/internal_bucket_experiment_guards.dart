/// Developer-only guards for future internal evidence-bucket experiments.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_classifier_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';

const internalBucketExperimentGuardsReportVersion =
    'internal-bucket-experiment-guards-v1';

enum InternalBucketExperimentGuardStatus {
  allowedInternalOnly('allowedInternalOnly'),
  allowedWithWarnings('allowedWithWarnings'),
  blockedByProductLabelPolicy('blockedByProductLabelPolicy'),
  blockedByAdvancedLabelPolicy('blockedByAdvancedLabelPolicy'),
  blockedByOfficialMetricPolicy('blockedByOfficialMetricPolicy'),
  blockedByComputationPolicy('blockedByComputationPolicy'),
  blockedByQuietScopeExclusion('blockedByQuietScopeExclusion'),
  blockedByEngineAccessPolicy('blockedByEngineAccessPolicy'),
  blockedByPersistencePolicy('blockedByPersistencePolicy'),
  blockedByUiOrBackendPolicy('blockedByUiOrBackendPolicy'),
  blockedByUnprovenAndroidProof('blockedByUnprovenAndroidProof'),
  blockedByUnsupportedBucket('blockedByUnsupportedBucket'),
  invalidRequest('invalidRequest');

  const InternalBucketExperimentGuardStatus(this.wire);

  final String wire;
}

enum InternalBucketExperimentViolationSeverity {
  warning('warning'),
  error('error');

  const InternalBucketExperimentViolationSeverity(this.wire);

  final String wire;
}

enum InternalBucketExperimentNextPhase {
  internalNonLabelExperimentHarness(
    'Phase 31E -- Internal Non-Label Bucket Experiment Harness',
  ),
  guardPolicyFixes('Phase 31E -- Guard Policy Fixes');

  const InternalBucketExperimentNextPhase(this.wire);

  final String wire;
}

enum InternalBucketExperimentGuardsReportFormat {
  markdown('markdown'),
  json('json');

  const InternalBucketExperimentGuardsReportFormat(this.wire);

  final String wire;
}

class InternalBucketExperimentRequest {
  const InternalBucketExperimentRequest({
    this.experimentId = 'safe-demo-internal-buckets',
    this.requestedBuckets = _safeDemoBucketIds,
    this.allowQuietPreparatoryScope = false,
    this.allowProductLabels = false,
    this.allowAdvancedLabels = false,
    this.allowOfficialMetrics = false,
    this.allowCpLossComputation = false,
    this.allowWinProbabilityComputation = false,
    this.allowAndroidProofClaims = true,
    this.allowDirectEngineAccess = false,
    this.allowPersistence = false,
    this.allowUiOutput = false,
    this.allowBackendOutput = false,
    this.claimedAndroidProofCaseIds = _phase30uCapturedAndroidProofCaseIds,
    this.requestedOutputFamilies = const <String>[],
    this.requestedEngineAccessApis = const <String>[],
    this.notes = const <String>[],
    this.cases = GoldenAnalysisCases.defaults,
    this.bucketPrototype,
    this.contract,
    this.foundationDesign,
    this.readiness,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.bucketBuilder = const InternalEvidenceBucketBuilder(),
    this.contractBuilder = const BasicClassifierEvidenceContractBuilder(),
    this.foundationDesigner = const BasicClassifierFoundationDesigner(),
    this.readinessGate = const GoldenClassifierReadinessGate(),
  });

  const InternalBucketExperimentRequest.safeDemo({
    this.experimentId = 'safe-demo-internal-buckets',
    this.cases = GoldenAnalysisCases.defaults,
    this.bucketPrototype,
    this.contract,
    this.foundationDesign,
    this.readiness,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.bucketBuilder = const InternalEvidenceBucketBuilder(),
    this.contractBuilder = const BasicClassifierEvidenceContractBuilder(),
    this.foundationDesigner = const BasicClassifierFoundationDesigner(),
    this.readinessGate = const GoldenClassifierReadinessGate(),
  }) : requestedBuckets = _safeDemoBucketIds,
       allowQuietPreparatoryScope = false,
       allowProductLabels = false,
       allowAdvancedLabels = false,
       allowOfficialMetrics = false,
       allowCpLossComputation = false,
       allowWinProbabilityComputation = false,
       allowAndroidProofClaims = true,
       allowDirectEngineAccess = false,
       allowPersistence = false,
       allowUiOutput = false,
       allowBackendOutput = false,
       claimedAndroidProofCaseIds = _phase30uCapturedAndroidProofCaseIds,
       requestedOutputFamilies = const <String>[],
       requestedEngineAccessApis = const <String>[],
       notes = const <String>[];

  final String experimentId;
  final List<InternalEvidenceBucketId> requestedBuckets;
  final bool allowQuietPreparatoryScope;
  final bool allowProductLabels;
  final bool allowAdvancedLabels;
  final bool allowOfficialMetrics;
  final bool allowCpLossComputation;
  final bool allowWinProbabilityComputation;
  final bool allowAndroidProofClaims;
  final bool allowDirectEngineAccess;
  final bool allowPersistence;
  final bool allowUiOutput;
  final bool allowBackendOutput;
  final List<String> claimedAndroidProofCaseIds;
  final List<String> requestedOutputFamilies;
  final List<String> requestedEngineAccessApis;
  final List<String> notes;
  final List<GoldenAnalysisCase> cases;
  final InternalEvidenceBucketPrototype? bucketPrototype;
  final BasicClassifierEvidenceContractPrototype? contract;
  final BasicClassifierFoundationDesignResult? foundationDesign;
  final GoldenClassifierReadinessResult? readiness;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final InternalEvidenceBucketBuilder bucketBuilder;
  final BasicClassifierEvidenceContractBuilder contractBuilder;
  final BasicClassifierFoundationDesigner foundationDesigner;
  final GoldenClassifierReadinessGate readinessGate;
}

class InternalBucketExperimentPolicyViolation {
  const InternalBucketExperimentPolicyViolation({
    required this.id,
    required this.severity,
    required this.message,
    this.bucketId,
    this.caseId,
  });

  final String id;
  final InternalBucketExperimentViolationSeverity severity;
  final String message;
  final InternalEvidenceBucketId? bucketId;
  final String? caseId;

  bool get isError =>
      severity == InternalBucketExperimentViolationSeverity.error;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (bucketId != null) 'bucketId': bucketId!.wire,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalBucketExperimentGuardResult {
  const InternalBucketExperimentGuardResult({
    required this.experimentId,
    required this.overallStatus,
    required this.allowed,
    required this.requestedBucketCount,
    required this.allowedBucketIds,
    required this.warningBucketIds,
    required this.blockedBucketIds,
    required this.policyViolations,
    required this.supportingCaseIds,
    required this.excludedScopeIds,
    required this.provenAndroidCaseIds,
    required this.unprovenAndroidCaseIds,
    required this.warnings,
    required this.failures,
    required this.bucketPrototypeStatus,
    required this.contractStatus,
    required this.foundationStatus,
    required this.readinessStatus,
    required this.nextRecommendation,
  });

  final String experimentId;
  final InternalBucketExperimentGuardStatus overallStatus;
  final bool allowed;
  final int requestedBucketCount;
  final List<InternalEvidenceBucketId> allowedBucketIds;
  final List<InternalEvidenceBucketId> warningBucketIds;
  final List<InternalEvidenceBucketId> blockedBucketIds;
  final List<InternalBucketExperimentPolicyViolation> policyViolations;
  final List<String> supportingCaseIds;
  final List<String> excludedScopeIds;
  final List<String> provenAndroidCaseIds;
  final List<String> unprovenAndroidCaseIds;
  final List<String> warnings;
  final List<String> failures;
  final InternalEvidenceBucketPrototypeStatus bucketPrototypeStatus;
  final BasicClassifierEvidenceContractStatus contractStatus;
  final BasicClassifierFoundationStatus foundationStatus;
  final GoldenClassifierReadinessStatus readinessStatus;
  final InternalBucketExperimentNextPhase nextRecommendation;

  bool get hasErrors => policyViolations.any((violation) => violation.isError);

  bool get hasUnsafeExperimentPolicyViolation {
    return hasErrors;
  }

  bool get isStrictlyBlocked => hasErrors || !allowed;

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Bucket Experiment Guards')
      ..writeln()
      ..writeln('- version: $internalBucketExperimentGuardsReportVersion')
      ..writeln('- experiment ID: $experimentId')
      ..writeln('- status: ${overallStatus.wire}')
      ..writeln('- allowed: $allowed')
      ..writeln('- developer only: true')
      ..writeln('- classifier work: false')
      ..writeln()
      ..writeln('## Inputs')
      ..writeln('- bucket prototype status: ${bucketPrototypeStatus.wire}')
      ..writeln('- contract status: ${contractStatus.wire}')
      ..writeln('- foundation status: ${foundationStatus.wire}')
      ..writeln('- readiness status: ${readinessStatus.wire}')
      ..writeln('- requested bucket count: $requestedBucketCount')
      ..writeln()
      ..writeln('## Bucket Decisions')
      ..writeln('- allowed buckets: ${_bucketIds(allowedBucketIds)}')
      ..writeln('- warning buckets: ${_bucketIds(warningBucketIds)}')
      ..writeln('- blocked buckets: ${_bucketIds(blockedBucketIds)}')
      ..writeln('- supporting case IDs: ${_ids(supportingCaseIds)}')
      ..writeln()
      ..writeln('## Policy Violations');
    if (policyViolations.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final violation in policyViolations) {
        buffer.writeln(
          '- ${violation.severity.wire}: ${violation.id}: '
          '${violation.message}',
        );
      }
    }

    buffer
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
      ..writeln()
      ..writeln('## Android Proof Claim Check')
      ..writeln('- proven case IDs: ${_ids(provenAndroidCaseIds)}')
      ..writeln('- unproven case IDs: ${_ids(unprovenAndroidCaseIds)}')
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
      ..writeln('## Next Recommended Phase')
      ..writeln(nextRecommendation.wire)
      ..writeln()
      ..writeln(
        'This report evaluates developer-only experiment safety. It does not '
        'score moves, classify moves, compute product metrics, change product '
        'review output, run engines, or emit user-facing output.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalBucketExperimentGuardsReportVersion,
      'experimentId': experimentId,
      'status': overallStatus.wire,
      'allowed': allowed,
      'requestedBucketCount': requestedBucketCount,
      'allowedBucketIds': allowedBucketIds
          .map((bucketId) => bucketId.wire)
          .toList(),
      'warningBucketIds': warningBucketIds
          .map((bucketId) => bucketId.wire)
          .toList(),
      'blockedBucketIds': blockedBucketIds
          .map((bucketId) => bucketId.wire)
          .toList(),
      'policyViolations': policyViolations
          .map((violation) => violation.toJson())
          .toList(),
      'supportingCaseIds': supportingCaseIds,
      'excludedScopeIds': excludedScopeIds,
      'provenAndroidCaseIds': provenAndroidCaseIds,
      'unprovenAndroidCaseIds': unprovenAndroidCaseIds,
      'warnings': warnings,
      'failures': failures,
      'bucketPrototypeStatus': bucketPrototypeStatus.wire,
      'contractStatus': contractStatus.wire,
      'foundationStatus': foundationStatus.wire,
      'readinessStatus': readinessStatus.wire,
      'nextRecommendation': nextRecommendation.wire,
      'developerOnly': true,
      'classifierWork': false,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}

class InternalBucketExperimentGuard {
  const InternalBucketExperimentGuard({
    this.policy = const InternalBucketExperimentPolicy(),
  });

  final InternalBucketExperimentPolicy policy;

  InternalBucketExperimentGuardResult evaluate(
    InternalBucketExperimentRequest request,
  ) {
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

    return policy.evaluate(
      request: request,
      buckets: buckets,
      contract: contract,
      foundation: foundation,
      readiness: readiness,
      androidProofEvidence: request.androidProofEvidence,
    );
  }
}

class InternalBucketExperimentPolicy {
  const InternalBucketExperimentPolicy();

  InternalBucketExperimentGuardResult evaluate({
    required InternalBucketExperimentRequest request,
    required InternalEvidenceBucketPrototype buckets,
    required BasicClassifierEvidenceContractPrototype contract,
    required BasicClassifierFoundationDesignResult foundation,
    required GoldenClassifierReadinessResult readiness,
    required GoldenAndroidProofEvidence? androidProofEvidence,
  }) {
    final violations = <InternalBucketExperimentPolicyViolation>[];
    final allowedBucketIds = <InternalEvidenceBucketId>[];
    final warningBucketIds = <InternalEvidenceBucketId>[];
    final blockedBucketIds = <InternalEvidenceBucketId>[];
    final supportingCaseIds = <String>{};
    final warnings = <String>[];
    final failures = <String>[];
    final requestedBuckets = request.requestedBuckets.toSet();

    void addViolation({
      required String id,
      required InternalBucketExperimentViolationSeverity severity,
      required String message,
      InternalEvidenceBucketId? bucketId,
      String? caseId,
    }) {
      violations.add(
        InternalBucketExperimentPolicyViolation(
          id: id,
          severity: severity,
          message: message,
          bucketId: bucketId,
          caseId: caseId,
        ),
      );
      if (severity == InternalBucketExperimentViolationSeverity.warning) {
        warnings.add(message);
      } else {
        failures.add(message);
      }
    }

    if (request.experimentId.trim().isEmpty) {
      addViolation(
        id: 'invalidExperimentId',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'experiment ID must be non-empty',
      );
    }
    if (requestedBuckets.isEmpty) {
      addViolation(
        id: 'emptyBucketRequest',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'at least one internal bucket must be requested',
      );
    }

    for (final bucketId in requestedBuckets) {
      final bucket = buckets.bucket(bucketId);
      switch (bucket.status) {
        case InternalEvidenceBucketStatus.supported:
          if (_blockedBucketIds.contains(bucketId)) {
            blockedBucketIds.add(bucketId);
            addViolation(
              id: 'blockedBucketRequested',
              severity: InternalBucketExperimentViolationSeverity.error,
              message: 'policy-blocked bucket cannot be consumed',
              bucketId: bucketId,
            );
          } else {
            allowedBucketIds.add(bucketId);
            supportingCaseIds.addAll(bucket.supportingCaseIds);
          }
        case InternalEvidenceBucketStatus.partial:
          if (_blockedBucketIds.contains(bucketId)) {
            blockedBucketIds.add(bucketId);
            addViolation(
              id: 'blockedBucketRequested',
              severity: InternalBucketExperimentViolationSeverity.error,
              message: 'policy-blocked bucket cannot be consumed',
              bucketId: bucketId,
            );
          } else {
            allowedBucketIds.add(bucketId);
            warningBucketIds.add(bucketId);
            supportingCaseIds.addAll(bucket.supportingCaseIds);
            addViolation(
              id: 'partialBucketRequested',
              severity: InternalBucketExperimentViolationSeverity.warning,
              message: 'partial bucket may be used only as warning evidence',
              bucketId: bucketId,
            );
          }
        case InternalEvidenceBucketStatus.excluded:
          blockedBucketIds.add(bucketId);
          addViolation(
            id: 'excludedBucketRequested',
            severity: InternalBucketExperimentViolationSeverity.error,
            message: 'excluded bucket cannot be consumed',
            bucketId: bucketId,
          );
        case InternalEvidenceBucketStatus.blockedByPolicy:
          blockedBucketIds.add(bucketId);
          addViolation(
            id: 'blockedBucketRequested',
            severity: InternalBucketExperimentViolationSeverity.error,
            message: 'policy-blocked bucket cannot be consumed',
            bucketId: bucketId,
          );
        case InternalEvidenceBucketStatus.futureOnly:
          blockedBucketIds.add(bucketId);
          addViolation(
            id: 'futureOnlyBucketRequested',
            severity: InternalBucketExperimentViolationSeverity.error,
            message:
                'future-only bucket cannot be consumed as present evidence',
            bucketId: bucketId,
          );
        case InternalEvidenceBucketStatus.unsupported:
        case InternalEvidenceBucketStatus.invalid:
          blockedBucketIds.add(bucketId);
          addViolation(
            id: 'unsupportedBucketRequested',
            severity: InternalBucketExperimentViolationSeverity.error,
            message: 'unsupported bucket blocks the request',
            bucketId: bucketId,
          );
      }
    }

    if (request.allowQuietPreparatoryScope ||
        requestedBuckets.contains(
          InternalEvidenceBucketId.quietPreparatoryExcluded,
        )) {
      addViolation(
        id: 'quietScopeRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'quiet/preparatory scope remains excluded',
        bucketId: InternalEvidenceBucketId.quietPreparatoryExcluded,
      );
    }

    if (request.allowProductLabels ||
        request.requestedOutputFamilies.any(_isProductLabelOutputFamily)) {
      addViolation(
        id: 'productLabelOutputRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'product move-quality output request is blocked',
      );
    }
    if (request.allowAdvancedLabels ||
        request.requestedOutputFamilies.any(_isAdvancedLabelOutputFamily)) {
      addViolation(
        id: 'advancedLabelOutputRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'advanced candidate output request is blocked',
      );
    }
    if (request.allowOfficialMetrics ||
        request.requestedOutputFamilies.any(_isOfficialMetricOutputFamily)) {
      addViolation(
        id: 'officialMetricOutputRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'official metric output request is blocked',
      );
    }
    if (request.allowCpLossComputation) {
      addViolation(
        id: 'cpLossComputationRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'CP-loss computation request is blocked',
        bucketId: InternalEvidenceBucketId.cpLossComputationBlocked,
      );
    }
    if (request.allowWinProbabilityComputation) {
      addViolation(
        id: 'winProbabilityComputationRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'win-probability computation request is blocked',
        bucketId: InternalEvidenceBucketId.winProbabilityComputationBlocked,
      );
    }
    if (request.allowDirectEngineAccess ||
        request.requestedEngineAccessApis.isNotEmpty) {
      addViolation(
        id: 'directEngineAccessRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'direct engine access is blocked by policy',
      );
    }
    if (request.allowPersistence) {
      addViolation(
        id: 'persistenceRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'persistence, cache, and database access are blocked',
      );
    }
    if (request.allowUiOutput || request.allowBackendOutput) {
      addViolation(
        id: 'uiOrBackendOutputRequested',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'UI and backend output are blocked',
      );
    }

    final provenAndroidCaseIds = _provenAndroidCaseIds(
      androidProofEvidence,
      buckets,
    );
    final claimedAndroidCaseIds = request.claimedAndroidProofCaseIds.toSet();
    final unprovenAndroidCaseIds = _sortedStrings(
      claimedAndroidCaseIds.where(
        (caseId) => !provenAndroidCaseIds.contains(caseId),
      ),
    );
    if (!request.allowAndroidProofClaims && claimedAndroidCaseIds.isNotEmpty) {
      addViolation(
        id: 'androidProofClaimsDisabled',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'Android proof claims are disabled for this request',
      );
    }
    for (final caseId in unprovenAndroidCaseIds) {
      addViolation(
        id: 'unprovenAndroidProofClaim',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'Android proof claim is not backed by captured proof',
        bucketId: InternalEvidenceBucketId.androidProofBacked,
        caseId: caseId,
      );
    }

    for (final finding in buckets.validationFindings.where(
      (item) => item.isError,
    )) {
      addViolation(
        id: 'bucketPrototypeValidationError',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'bucket prototype validation must be clean',
        bucketId: finding.bucketId,
        caseId: finding.caseId,
      );
    }
    if (contract.hasUnsafeOutputPolicyViolation ||
        foundation.hasUnsafeOutputPolicyViolation ||
        readiness.hasUnsafeReadinessClaim) {
      addViolation(
        id: 'upstreamUnsafePolicy',
        severity: InternalBucketExperimentViolationSeverity.error,
        message: 'upstream evidence policy is unsafe',
      );
    }

    final sortedViolations = violations..sort(_compareViolations);
    final sortedWarnings = _sortedStrings(warnings);
    final sortedFailures = _sortedStrings(failures);
    final status = _statusFor(
      request: request,
      requestedBuckets: requestedBuckets,
      violations: sortedViolations,
      warningBucketIds: warningBucketIds,
      unprovenAndroidCaseIds: unprovenAndroidCaseIds,
    );
    final allowed =
        status == InternalBucketExperimentGuardStatus.allowedInternalOnly ||
        status == InternalBucketExperimentGuardStatus.allowedWithWarnings;

    return InternalBucketExperimentGuardResult(
      experimentId: request.experimentId,
      overallStatus: status,
      allowed: allowed,
      requestedBucketCount: requestedBuckets.length,
      allowedBucketIds: _sortedBucketIds(allowedBucketIds),
      warningBucketIds: _sortedBucketIds(warningBucketIds),
      blockedBucketIds: _sortedBucketIds(blockedBucketIds),
      policyViolations:
          List<InternalBucketExperimentPolicyViolation>.unmodifiable(
            sortedViolations,
          ),
      supportingCaseIds: _sortedStrings(supportingCaseIds),
      excludedScopeIds: _excludedScopeIds(buckets),
      provenAndroidCaseIds: _sortedStrings(provenAndroidCaseIds),
      unprovenAndroidCaseIds: unprovenAndroidCaseIds,
      warnings: sortedWarnings,
      failures: sortedFailures,
      bucketPrototypeStatus: buckets.status,
      contractStatus: contract.status,
      foundationStatus: foundation.status,
      readinessStatus: readiness.status,
      nextRecommendation: allowed
          ? InternalBucketExperimentNextPhase.internalNonLabelExperimentHarness
          : InternalBucketExperimentNextPhase.guardPolicyFixes,
    );
  }
}

InternalBucketExperimentGuardStatus _statusFor({
  required InternalBucketExperimentRequest request,
  required Set<InternalEvidenceBucketId> requestedBuckets,
  required List<InternalBucketExperimentPolicyViolation> violations,
  required List<InternalEvidenceBucketId> warningBucketIds,
  required List<String> unprovenAndroidCaseIds,
}) {
  if (request.experimentId.trim().isEmpty || requestedBuckets.isEmpty) {
    return InternalBucketExperimentGuardStatus.invalidRequest;
  }
  if (violations.any((item) => item.id == 'productLabelOutputRequested')) {
    return InternalBucketExperimentGuardStatus.blockedByProductLabelPolicy;
  }
  if (violations.any((item) => item.id == 'advancedLabelOutputRequested')) {
    return InternalBucketExperimentGuardStatus.blockedByAdvancedLabelPolicy;
  }
  if (violations.any((item) => item.id == 'officialMetricOutputRequested')) {
    return InternalBucketExperimentGuardStatus.blockedByOfficialMetricPolicy;
  }
  if (violations.any(
    (item) =>
        item.id == 'cpLossComputationRequested' ||
        item.id == 'winProbabilityComputationRequested',
  )) {
    return InternalBucketExperimentGuardStatus.blockedByComputationPolicy;
  }
  if (violations.any(
    (item) =>
        item.id == 'quietScopeRequested' ||
        item.id == 'excludedBucketRequested',
  )) {
    return InternalBucketExperimentGuardStatus.blockedByQuietScopeExclusion;
  }
  if (violations.any((item) => item.id == 'directEngineAccessRequested')) {
    return InternalBucketExperimentGuardStatus.blockedByEngineAccessPolicy;
  }
  if (violations.any((item) => item.id == 'persistenceRequested')) {
    return InternalBucketExperimentGuardStatus.blockedByPersistencePolicy;
  }
  if (violations.any((item) => item.id == 'uiOrBackendOutputRequested')) {
    return InternalBucketExperimentGuardStatus.blockedByUiOrBackendPolicy;
  }
  if (unprovenAndroidCaseIds.isNotEmpty ||
      violations.any((item) => item.id == 'androidProofClaimsDisabled')) {
    return InternalBucketExperimentGuardStatus.blockedByUnprovenAndroidProof;
  }
  if (violations.any(
    (item) =>
        item.id == 'blockedBucketRequested' ||
        item.id == 'futureOnlyBucketRequested' ||
        item.id == 'unsupportedBucketRequested' ||
        item.id == 'bucketPrototypeValidationError' ||
        item.id == 'upstreamUnsafePolicy',
  )) {
    return InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket;
  }
  if (warningBucketIds.isNotEmpty ||
      violations.any(
        (item) =>
            item.severity == InternalBucketExperimentViolationSeverity.warning,
      )) {
    return InternalBucketExperimentGuardStatus.allowedWithWarnings;
  }
  return InternalBucketExperimentGuardStatus.allowedInternalOnly;
}

Set<String> _provenAndroidCaseIds(
  GoldenAndroidProofEvidence? proof,
  InternalEvidenceBucketPrototype buckets,
) {
  if (proof == null ||
      proof.stubIdentityDetected ||
      proof.platform != 'android' ||
      proof.abi != 'arm64-v8a' ||
      proof.engineIdentity.trim().isEmpty) {
    return const <String>{};
  }
  return buckets
      .bucket(InternalEvidenceBucketId.androidProofBacked)
      .supportingCaseIds
      .where(
        (caseId) => proof.isRealDeviceProofCapturedFor(
          caseId,
          requirePv: true,
          minMultiPvLineCount: 1,
        ),
      )
      .toSet();
}

List<String> _excludedScopeIds(InternalEvidenceBucketPrototype buckets) {
  return _sortedStrings(<String>[
    if (buckets.negativeGuardCaseIds.isNotEmpty)
      'quietPreparatoryEvidenceClassification',
    ...buckets.negativeGuardCaseIds,
  ]);
}

bool _isProductLabelOutputFamily(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('productlabel') ||
      normalized.contains('movequality') ||
      normalized.contains('finalmove') ||
      normalized.contains('best') ||
      normalized.contains('good') ||
      normalized.contains('inaccuracy') ||
      normalized.contains('mistake') ||
      normalized.contains('blunder');
}

bool _isAdvancedLabelOutputFamily(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('advancedcandidate') ||
      normalized.contains('brilliant') ||
      normalized.contains('great') ||
      normalized.contains('miss');
}

bool _isOfficialMetricOutputFamily(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('officialmetric') ||
      normalized.contains('accuracy') ||
      normalized.contains('acpl');
}

int _compareViolations(
  InternalBucketExperimentPolicyViolation a,
  InternalBucketExperimentPolicyViolation b,
) {
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final bucketCompare = (a.bucketId?.wire ?? '').compareTo(
    b.bucketId?.wire ?? '',
  );
  if (bucketCompare != 0) return bucketCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

String _ids(List<String> values) => values.isEmpty ? '-' : values.join(', ');

String _bucketIds(List<InternalEvidenceBucketId> values) =>
    values.isEmpty ? '-' : values.map((value) => value.wire).join(', ');

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList()..sort();
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toList()..sort((a, b) => a.index.compareTo(b.index));
}

const _phase30uCapturedAndroidProofCaseIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _safeDemoBucketIds = <InternalEvidenceBucketId>[
  InternalEvidenceBucketId.tacticalSupported,
  InternalEvidenceBucketId.materialSwingSupported,
  InternalEvidenceBucketId.forcingLineSupported,
  InternalEvidenceBucketId.kingSafetySupported,
  InternalEvidenceBucketId.endgameConservativeSupported,
  InternalEvidenceBucketId.safetySuppressionSupported,
  InternalEvidenceBucketId.invalidFenSuppressed,
  InternalEvidenceBucketId.openingSuppressed,
  InternalEvidenceBucketId.forcedMoveSuppressed,
  InternalEvidenceBucketId.budgetPressureVisible,
  InternalEvidenceBucketId.androidProofBacked,
  InternalEvidenceBucketId.candidateSpreadSupported,
  InternalEvidenceBucketId.pvMultiPvSupported,
];

const _blockedBucketIds = <InternalEvidenceBucketId>{
  InternalEvidenceBucketId.quietPreparatoryExcluded,
  InternalEvidenceBucketId.productLabelOutputBlocked,
  InternalEvidenceBucketId.advancedLabelGateBlocked,
  InternalEvidenceBucketId.officialMetricsBlocked,
  InternalEvidenceBucketId.cpLossComputationBlocked,
  InternalEvidenceBucketId.winProbabilityComputationBlocked,
};
