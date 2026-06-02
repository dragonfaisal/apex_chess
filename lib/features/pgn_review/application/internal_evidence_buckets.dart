/// Developer-only internal evidence buckets for future non-label experiments.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';

const internalEvidenceBucketsReportVersion = 'internal-evidence-buckets-v1';

enum InternalEvidenceBucketPrototypeStatus {
  readyForInternalBucketPrototype('readyForInternalBucketPrototype'),
  blockedByValidation('blockedByValidation'),
  blockedByEvidence('blockedByEvidence');

  const InternalEvidenceBucketPrototypeStatus(this.wire);

  final String wire;
}

enum InternalEvidenceBucketId {
  tacticalSupported('tacticalSupported'),
  materialSwingSupported('materialSwingSupported'),
  forcingLineSupported('forcingLineSupported'),
  kingSafetySupported('kingSafetySupported'),
  endgameConservativeSupported('endgameConservativeSupported'),
  safetySuppressionSupported('safetySuppressionSupported'),
  invalidFenSuppressed('invalidFenSuppressed'),
  openingSuppressed('openingSuppressed'),
  forcedMoveSuppressed('forcedMoveSuppressed'),
  budgetPressureVisible('budgetPressureVisible'),
  androidProofBacked('androidProofBacked'),
  candidateSpreadSupported('candidateSpreadSupported'),
  pvMultiPvSupported('pvMultiPvSupported'),
  quietPreparatoryExcluded('quietPreparatoryExcluded'),
  productLabelOutputBlocked('productLabelOutputBlocked'),
  advancedLabelGateBlocked('advancedLabelGateBlocked'),
  officialMetricsBlocked('officialMetricsBlocked'),
  cpLossComputationBlocked('cpLossComputationBlocked'),
  winProbabilityComputationBlocked('winProbabilityComputationBlocked');

  const InternalEvidenceBucketId(this.wire);

  final String wire;
}

enum InternalEvidenceBucketStatus {
  supported('supported'),
  partial('partial'),
  excluded('excluded'),
  blockedByPolicy('blockedByPolicy'),
  futureOnly('futureOnly'),
  unsupported('unsupported'),
  invalid('invalid');

  const InternalEvidenceBucketStatus(this.wire);

  final String wire;
}

enum InternalEvidenceBucketNextPhase {
  internalNonLabelBucketExperimentGuards(
    'Phase 31D -- Internal Non-Label Bucket Experiment Guards',
  ),
  bucketEvidenceFixes('Phase 31D -- Bucket Evidence Fixes');

  const InternalEvidenceBucketNextPhase(this.wire);

  final String wire;
}

enum InternalEvidenceBucketsReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceBucketsReportFormat(this.wire);

  final String wire;
}

enum InternalEvidenceBucketValidationSeverity {
  warning('warning'),
  error('error');

  const InternalEvidenceBucketValidationSeverity(this.wire);

  final String wire;
}

class InternalEvidenceBucketRequest {
  const InternalEvidenceBucketRequest({
    this.cases = GoldenAnalysisCases.defaults,
    this.contract,
    this.foundationDesign,
    this.review,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.contractBuilder = const BasicClassifierEvidenceContractBuilder(),
    this.foundationDesigner = const BasicClassifierFoundationDesigner(),
    this.reviewRunner = const GoldenEvidenceReviewRunner(),
  });

  final List<GoldenAnalysisCase> cases;
  final BasicClassifierEvidenceContractPrototype? contract;
  final BasicClassifierFoundationDesignResult? foundationDesign;
  final GoldenEvidenceReviewResult? review;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final BasicClassifierEvidenceContractBuilder contractBuilder;
  final BasicClassifierFoundationDesigner foundationDesigner;
  final GoldenEvidenceReviewRunner reviewRunner;
}

class InternalEvidenceBucket {
  const InternalEvidenceBucket({
    required this.id,
    required this.status,
    required this.supportingCaseIds,
    required this.blockerCaseIds,
    required this.blockers,
    required this.recommendation,
  });

  final InternalEvidenceBucketId id;
  final InternalEvidenceBucketStatus status;
  final List<String> supportingCaseIds;
  final List<String> blockerCaseIds;
  final List<String> blockers;
  final String recommendation;

  bool get isSupported => status == InternalEvidenceBucketStatus.supported;

  bool get isPartial => status == InternalEvidenceBucketStatus.partial;

  bool get isExcluded => status == InternalEvidenceBucketStatus.excluded;

  bool get isBlocked => status == InternalEvidenceBucketStatus.blockedByPolicy;

  bool get isFutureOnly => status == InternalEvidenceBucketStatus.futureOnly;

  InternalEvidenceBucket copyWith({
    InternalEvidenceBucketId? id,
    InternalEvidenceBucketStatus? status,
    List<String>? supportingCaseIds,
    List<String>? blockerCaseIds,
    List<String>? blockers,
    String? recommendation,
  }) {
    return InternalEvidenceBucket(
      id: id ?? this.id,
      status: status ?? this.status,
      supportingCaseIds: supportingCaseIds ?? this.supportingCaseIds,
      blockerCaseIds: blockerCaseIds ?? this.blockerCaseIds,
      blockers: blockers ?? this.blockers,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'bucketId': id.wire,
      'status': status.wire,
      'supportingCaseIds': supportingCaseIds,
      'blockerCaseIds': blockerCaseIds,
      'blockers': blockers,
      'recommendation': recommendation,
    };
  }
}

class InternalEvidenceBucketValidationFinding {
  const InternalEvidenceBucketValidationFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.bucketId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceBucketValidationSeverity severity;
  final String message;
  final InternalEvidenceBucketId? bucketId;
  final String? caseId;

  bool get isError =>
      severity == InternalEvidenceBucketValidationSeverity.error;

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

class InternalEvidenceBucketPrototype {
  const InternalEvidenceBucketPrototype({
    required this.status,
    required this.contractStatus,
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
    required this.buckets,
    required this.emittedOutputFamilies,
    required this.validationFindings,
    required this.nextRecommendedPhase,
    required this.readyForPhase31D,
  });

  final InternalEvidenceBucketPrototypeStatus status;
  final BasicClassifierEvidenceContractStatus contractStatus;
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
  final List<InternalEvidenceBucket> buckets;
  final List<String> emittedOutputFamilies;
  final List<InternalEvidenceBucketValidationFinding> validationFindings;
  final InternalEvidenceBucketNextPhase nextRecommendedPhase;
  final bool readyForPhase31D;

  bool get hasValidationErrors =>
      validationFindings.any((finding) => finding.isError);

  bool get hasUnsafeBucketPolicyViolation {
    if (bucket(InternalEvidenceBucketId.quietPreparatoryExcluded).status !=
        InternalEvidenceBucketStatus.excluded) {
      return true;
    }
    for (final id in _policyBlockedBuckets) {
      if (bucket(id).status != InternalEvidenceBucketStatus.blockedByPolicy) {
        return true;
      }
    }
    for (final id in _futureComputationBuckets) {
      final status = bucket(id).status;
      if (status == InternalEvidenceBucketStatus.supported ||
          status == InternalEvidenceBucketStatus.partial) {
        return true;
      }
    }
    return emittedOutputFamilies.any(_isForbiddenEmittedOutput);
  }

  bool get isStrictlyBlocked =>
      hasValidationErrors ||
      status !=
          InternalEvidenceBucketPrototypeStatus.readyForInternalBucketPrototype;

  InternalEvidenceBucket bucket(InternalEvidenceBucketId id) {
    return buckets.singleWhere((bucket) => bucket.id == id);
  }

  InternalEvidenceBucketPrototype copyWith({
    InternalEvidenceBucketPrototypeStatus? status,
    List<InternalEvidenceBucket>? buckets,
    List<String>? emittedOutputFamilies,
    List<InternalEvidenceBucketValidationFinding>? validationFindings,
    InternalEvidenceBucketNextPhase? nextRecommendedPhase,
    bool? readyForPhase31D,
  }) {
    return InternalEvidenceBucketPrototype(
      status: status ?? this.status,
      contractStatus: contractStatus,
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
      buckets: buckets ?? this.buckets,
      emittedOutputFamilies:
          emittedOutputFamilies ?? this.emittedOutputFamilies,
      validationFindings: validationFindings ?? this.validationFindings,
      nextRecommendedPhase: nextRecommendedPhase ?? this.nextRecommendedPhase,
      readyForPhase31D: readyForPhase31D ?? this.readyForPhase31D,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Evidence Buckets Prototype')
      ..writeln()
      ..writeln('- version: $internalEvidenceBucketsReportVersion')
      ..writeln('- status: ${status.wire}')
      ..writeln('- contract status: ${contractStatus.wire}')
      ..writeln('- foundation status: ${foundationStatus.wire}')
      ..writeln('- developer only: true')
      ..writeln('- classifier work: false')
      ..writeln('- ready for Phase 31D: $readyForPhase31D')
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
      ..writeln('## Bucket Table')
      ..writeln('| Bucket | Status | Support | Blockers | Recommendation |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final bucket in buckets) {
      buffer.writeln(
        '| ${bucket.id.wire} | ${bucket.status.wire} | '
        '${_ids(bucket.supportingCaseIds)} | ${_ids(bucket.blockers)} | '
        '${bucket.recommendation} |',
      );
    }

    _writeBucketSection(
      buffer,
      'Supported Buckets',
      buckets.where((bucket) => bucket.isSupported),
    );
    _writeBucketSection(
      buffer,
      'Partial Buckets',
      buckets.where((bucket) => bucket.isPartial),
    );
    _writeBucketSection(
      buffer,
      'Excluded Buckets',
      buckets.where((bucket) => bucket.isExcluded),
    );
    _writeBucketSection(
      buffer,
      'Blocked Buckets',
      buckets.where((bucket) => bucket.isBlocked),
    );
    _writeBucketSection(
      buffer,
      'Future-Only Buckets',
      buckets.where((bucket) => bucket.isFutureOnly),
    );

    buffer
      ..writeln()
      ..writeln('## Support Mapping');
    for (final bucket in buckets) {
      buffer.writeln('- ${bucket.id.wire}: ${_ids(bucket.supportingCaseIds)}');
    }

    buffer
      ..writeln()
      ..writeln('## Android Proof Backing')
      ..writeln('- case IDs: ${_ids(capturedAndroidProofCaseIds)}')
      ..writeln()
      ..writeln('## Quiet Preparatory Exclusion')
      ..writeln('- negative guard case IDs: ${_ids(negativeGuardCaseIds)}')
      ..writeln(
        '- protected quiet evidence remains support only: '
        '${_ids(bucket(InternalEvidenceBucketId.quietPreparatoryExcluded).supportingCaseIds)}',
      )
      ..writeln()
      ..writeln('## Product And Metric Blocks')
      ..writeln(
        '- product output bucket: ${bucket(InternalEvidenceBucketId.productLabelOutputBlocked).status.wire}',
      )
      ..writeln(
        '- advanced gate bucket: ${bucket(InternalEvidenceBucketId.advancedLabelGateBlocked).status.wire}',
      )
      ..writeln(
        '- official metric bucket: ${bucket(InternalEvidenceBucketId.officialMetricsBlocked).status.wire}',
      )
      ..writeln(
        '- CP-loss bucket: ${bucket(InternalEvidenceBucketId.cpLossComputationBlocked).status.wire}',
      )
      ..writeln(
        '- win-probability bucket: ${bucket(InternalEvidenceBucketId.winProbabilityComputationBlocked).status.wire}',
      )
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
        'This report defines developer-only internal evidence buckets. It does '
        'not score moves, classify moves, compute product metrics, change '
        'product review output, or emit user-facing output.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    final payload = <String, Object?>{
      'version': internalEvidenceBucketsReportVersion,
      'status': status.wire,
      'contractStatus': contractStatus.wire,
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
      'readyForPhase31D': readyForPhase31D,
      'buckets': buckets.map((bucket) => bucket.toJson()).toList(),
      'negativeGuardCaseIds': negativeGuardCaseIds,
      'capturedAndroidProofCaseIds': capturedAndroidProofCaseIds,
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
}

class InternalEvidenceBucketBuilder {
  const InternalEvidenceBucketBuilder({
    this.validator = const InternalEvidenceBucketValidator(),
  });

  final InternalEvidenceBucketValidator validator;

  InternalEvidenceBucketPrototype evaluate(
    InternalEvidenceBucketRequest request,
  ) {
    final foundation =
        request.foundationDesign ??
        request.foundationDesigner.evaluate(
          BasicClassifierFoundationDesignRequest(
            cases: request.cases,
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

    final buckets = _buckets(
      contract: contract,
      foundation: foundation,
      review: review,
    );
    final base = InternalEvidenceBucketPrototype(
      status: _statusFor(
        contract,
        foundation,
        const <InternalEvidenceBucketValidationFinding>[],
      ),
      contractStatus: contract.status,
      foundationStatus: foundation.status,
      totalCaseCount: contract.totalCaseCount,
      protectedCount: contract.protectedCount,
      negativeGuardCount: contract.negativeGuardCount,
      incompleteCount: contract.incompleteCount,
      realDeviceNeededCount: contract.realDeviceNeededCount,
      ownerProofQueueCount: contract.ownerProofQueueCount,
      capturedAndroidProofCount: contract.capturedAndroidProofCount,
      negativeGuardCaseIds: contract.negativeGuardCaseIds,
      capturedAndroidProofCaseIds: contract.capturedAndroidProofCaseIds,
      buckets: List<InternalEvidenceBucket>.unmodifiable(buckets),
      emittedOutputFamilies: const <String>[],
      validationFindings: const <InternalEvidenceBucketValidationFinding>[],
      nextRecommendedPhase: InternalEvidenceBucketNextPhase
          .internalNonLabelBucketExperimentGuards,
      readyForPhase31D: _readyForPhase31D(contract, buckets),
    );
    final findings = validator.validate(base);
    return base.copyWith(
      status: _statusFor(contract, foundation, findings),
      validationFindings: findings,
      nextRecommendedPhase: findings.any((finding) => finding.isError)
          ? InternalEvidenceBucketNextPhase.bucketEvidenceFixes
          : InternalEvidenceBucketNextPhase
                .internalNonLabelBucketExperimentGuards,
      readyForPhase31D:
          _readyForPhase31D(contract, buckets) &&
          !findings.any((finding) => finding.isError),
    );
  }
}

class InternalEvidenceBucketValidator {
  const InternalEvidenceBucketValidator();

  List<InternalEvidenceBucketValidationFinding> validate(
    InternalEvidenceBucketPrototype prototype,
  ) {
    final findings = <InternalEvidenceBucketValidationFinding>[];

    void error({
      required String id,
      required String message,
      InternalEvidenceBucketId? bucketId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceBucketValidationFinding(
          id: id,
          severity: InternalEvidenceBucketValidationSeverity.error,
          message: message,
          bucketId: bucketId,
          caseId: caseId,
        ),
      );
    }

    for (final bucket in prototype.buckets) {
      if (bucket.status == InternalEvidenceBucketStatus.supported &&
          bucket.supportingCaseIds.isEmpty) {
        error(
          id: 'supportedBucketWithoutCases',
          message: '${bucket.id.wire} cannot be supported without cases',
          bucketId: bucket.id,
        );
      }
    }

    for (final id in _policyBlockedBuckets) {
      final bucket = prototype.bucket(id);
      if (bucket.status != InternalEvidenceBucketStatus.blockedByPolicy) {
        error(
          id: 'policyBlockedBucketAllowed',
          message: '${id.wire} must stay blocked by policy',
          bucketId: id,
        );
      }
    }

    final quiet = prototype.bucket(
      InternalEvidenceBucketId.quietPreparatoryExcluded,
    );
    if (quiet.status != InternalEvidenceBucketStatus.excluded) {
      error(
        id: 'quietBucketNotExcluded',
        message: 'quiet/preparatory bucket must remain excluded',
        bucketId: quiet.id,
      );
    }

    for (final id in _futureComputationBuckets) {
      final status = prototype.bucket(id).status;
      if (status == InternalEvidenceBucketStatus.supported ||
          status == InternalEvidenceBucketStatus.partial) {
        error(
          id: 'futureComputationAllowed',
          message: '${id.wire} must not be available in this phase',
          bucketId: id,
        );
      }
    }

    final proven = prototype.capturedAndroidProofCaseIds.toSet();
    for (final caseId
        in prototype
            .bucket(InternalEvidenceBucketId.androidProofBacked)
            .supportingCaseIds) {
      if (!proven.contains(caseId)) {
        error(
          id: 'unprovenAndroidProofBucketCase',
          message: 'androidProofBacked cannot cite unproven cases',
          bucketId: InternalEvidenceBucketId.androidProofBacked,
          caseId: caseId,
        );
      }
    }

    for (final output in prototype.emittedOutputFamilies) {
      if (_isForbiddenEmittedOutput(output)) {
        error(
          id: 'forbiddenOutputEmitted',
          message: 'forbidden output family emitted: $output',
        );
      }
    }

    return findings..sort((a, b) {
      final idCompare = a.id.compareTo(b.id);
      if (idCompare != 0) return idCompare;
      return (a.bucketId?.wire ?? '').compareTo(b.bucketId?.wire ?? '');
    });
  }
}

List<InternalEvidenceBucket> _buckets({
  required BasicClassifierEvidenceContractPrototype contract,
  required BasicClassifierFoundationDesignResult foundation,
  required GoldenEvidenceReviewResult review,
}) {
  final reviewedCaseIds = review.caseReviews
      .map((caseReview) => caseReview.caseId)
      .toSet();
  List<String> reviewedSupport(List<String> support) {
    return _sortedStrings(support.where(reviewedCaseIds.contains));
  }

  InternalEvidenceBucket supported(
    InternalEvidenceBucketId id,
    List<String> support,
    String recommendation, {
    InternalEvidenceBucketStatus emptyStatus =
        InternalEvidenceBucketStatus.partial,
  }) {
    final filteredSupport = reviewedSupport(support);
    return InternalEvidenceBucket(
      id: id,
      status: filteredSupport.isEmpty
          ? emptyStatus
          : InternalEvidenceBucketStatus.supported,
      supportingCaseIds: filteredSupport,
      blockerCaseIds: const <String>[],
      blockers: const <String>[],
      recommendation: recommendation,
    );
  }

  InternalEvidenceBucket blocked(
    InternalEvidenceBucketId id,
    String recommendation,
  ) {
    return InternalEvidenceBucket(
      id: id,
      status: InternalEvidenceBucketStatus.blockedByPolicy,
      supportingCaseIds: const <String>[],
      blockerCaseIds: const <String>[],
      blockers: const <String>['blocked by policy'],
      recommendation: recommendation,
    );
  }

  InternalEvidenceBucket futureOnly(
    InternalEvidenceBucketId id,
    String recommendation,
  ) {
    return InternalEvidenceBucket(
      id: id,
      status: InternalEvidenceBucketStatus.futureOnly,
      supportingCaseIds: const <String>[],
      blockerCaseIds: const <String>[],
      blockers: const <String>['future-only evidence input'],
      recommendation: recommendation,
    );
  }

  final buckets = <InternalEvidenceBucket>[
    supported(
      InternalEvidenceBucketId.tacticalSupported,
      contract
          .group(BasicClassifierEvidenceGroup.tacticalEvidence)
          .supportingCaseIds,
      'Use only as internal tactical evidence for future non-label experiments.',
    ),
    supported(
      InternalEvidenceBucketId.materialSwingSupported,
      contract
          .group(BasicClassifierEvidenceGroup.materialEvidence)
          .supportingCaseIds,
      'Use only as internal material-swing evidence.',
    ),
    supported(
      InternalEvidenceBucketId.forcingLineSupported,
      contract
          .group(BasicClassifierEvidenceGroup.forcingEvidence)
          .supportingCaseIds,
      'Use only as internal forcing-line evidence.',
    ),
    supported(
      InternalEvidenceBucketId.kingSafetySupported,
      contract
          .group(BasicClassifierEvidenceGroup.kingSafetyEvidence)
          .supportingCaseIds,
      'Use only as internal king-safety evidence.',
    ),
    supported(
      InternalEvidenceBucketId.endgameConservativeSupported,
      foundation
          .scope(BasicClassifierDesignScope.endgameEvidenceDesign)
          .supportingCaseIds,
      'Keep endgame evidence conservative and developer-only.',
    ),
    supported(
      InternalEvidenceBucketId.safetySuppressionSupported,
      _supportFromFields(contract, const <BasicClassifierContractField>[
        BasicClassifierContractField.invalidFenSuppressionAvailable,
        BasicClassifierContractField.openingSuppressionAvailable,
        BasicClassifierContractField.forcedMoveSuppressionAvailable,
        BasicClassifierContractField.budgetPressureAvailable,
      ]),
      'Use only as internal safety and suppression evidence.',
    ),
    supported(
      InternalEvidenceBucketId.invalidFenSuppressed,
      contract
          .field(BasicClassifierContractField.invalidFenSuppressionAvailable)
          .supportingCaseIds,
      'Invalid position text remains suppressed before bucket work.',
    ),
    supported(
      InternalEvidenceBucketId.openingSuppressed,
      contract
          .field(BasicClassifierContractField.openingSuppressionAvailable)
          .supportingCaseIds,
      'Opening-known quiet positions remain suppressed from deep work.',
    ),
    supported(
      InternalEvidenceBucketId.forcedMoveSuppressed,
      contract
          .field(BasicClassifierContractField.forcedMoveSuppressionAvailable)
          .supportingCaseIds,
      'Forced moves remain suppression evidence only.',
    ),
    supported(
      InternalEvidenceBucketId.budgetPressureVisible,
      contract
          .field(BasicClassifierContractField.budgetPressureAvailable)
          .supportingCaseIds,
      'Budget pressure remains visible as internal evidence.',
    ),
    supported(
      InternalEvidenceBucketId.androidProofBacked,
      contract.capturedAndroidProofCaseIds,
      'Use only for cases with captured Android proof evidence.',
    ),
    supported(
      InternalEvidenceBucketId.candidateSpreadSupported,
      contract
          .field(BasicClassifierContractField.candidateSpreadAvailable)
          .supportingCaseIds,
      'Candidate spread is internal evidence only.',
    ),
    supported(
      InternalEvidenceBucketId.pvMultiPvSupported,
      _supportFromFields(contract, const <BasicClassifierContractField>[
        BasicClassifierContractField.pvAvailable,
        BasicClassifierContractField.multiPvAvailable,
      ]),
      'PV and MultiPV support is limited to preserved proof-backed cases.',
    ),
    InternalEvidenceBucket(
      id: InternalEvidenceBucketId.quietPreparatoryExcluded,
      status: InternalEvidenceBucketStatus.excluded,
      supportingCaseIds: contract
          .group(BasicClassifierEvidenceGroup.quietPreparatoryEvidence)
          .supportingCaseIds,
      blockerCaseIds: contract.negativeGuardCaseIds,
      blockers: const <String>['quiet/preparatory excluded by negative guard'],
      recommendation:
          'Keep quiet/preparatory evidence excluded from bucket experiments.',
    ),
    blocked(
      InternalEvidenceBucketId.productLabelOutputBlocked,
      'Product output remains blocked.',
    ),
    blocked(
      InternalEvidenceBucketId.advancedLabelGateBlocked,
      'Advanced gates remain blocked.',
    ),
    blocked(
      InternalEvidenceBucketId.officialMetricsBlocked,
      'Official metrics remain blocked.',
    ),
    futureOnly(
      InternalEvidenceBucketId.cpLossComputationBlocked,
      'CP-loss computation is not implemented in this bucket phase.',
    ),
    futureOnly(
      InternalEvidenceBucketId.winProbabilityComputationBlocked,
      'Win-probability computation is not implemented in this bucket phase.',
    ),
  ];
  return List<InternalEvidenceBucket>.unmodifiable(
    buckets..sort((a, b) => a.id.index.compareTo(b.id.index)),
  );
}

InternalEvidenceBucketPrototypeStatus _statusFor(
  BasicClassifierEvidenceContractPrototype contract,
  BasicClassifierFoundationDesignResult foundation,
  List<InternalEvidenceBucketValidationFinding> findings,
) {
  if (findings.any((finding) => finding.isError)) {
    return InternalEvidenceBucketPrototypeStatus.blockedByValidation;
  }
  if (contract.status !=
          BasicClassifierEvidenceContractStatus
              .readyForDeveloperEvidencePrototype ||
      foundation.realDeviceNeededCount > 0 ||
      foundation.ownerProofQueueCount > 0 ||
      foundation.incompleteCount > 0) {
    return InternalEvidenceBucketPrototypeStatus.blockedByEvidence;
  }
  return InternalEvidenceBucketPrototypeStatus.readyForInternalBucketPrototype;
}

bool _readyForPhase31D(
  BasicClassifierEvidenceContractPrototype contract,
  List<InternalEvidenceBucket> buckets,
) {
  if (!contract.readyForPhase31C ||
      contract.hasUnsafeOutputPolicyViolation ||
      contract.hasValidationErrors) {
    return false;
  }
  final byId = {for (final bucket in buckets) bucket.id: bucket};
  return _supportedDefaultBuckets.every(
        (id) => byId[id]?.status == InternalEvidenceBucketStatus.supported,
      ) &&
      byId[InternalEvidenceBucketId.quietPreparatoryExcluded]?.status ==
          InternalEvidenceBucketStatus.excluded &&
      _policyBlockedBuckets.every(
        (id) =>
            byId[id]?.status == InternalEvidenceBucketStatus.blockedByPolicy,
      ) &&
      _futureComputationBuckets.every(
        (id) => byId[id]?.status == InternalEvidenceBucketStatus.futureOnly,
      );
}

List<String> _supportFromFields(
  BasicClassifierEvidenceContractPrototype contract,
  List<BasicClassifierContractField> fields,
) {
  final support = <String>{};
  for (final field in fields) {
    support.addAll(contract.field(field).supportingCaseIds);
  }
  return _sortedStrings(support);
}

void _writeBucketSection(
  StringBuffer buffer,
  String title,
  Iterable<InternalEvidenceBucket> buckets,
) {
  final rows = buckets.toList(growable: false);
  buffer
    ..writeln()
    ..writeln('## $title');
  if (rows.isEmpty) {
    buffer.writeln('- none');
    return;
  }
  for (final bucket in rows) {
    buffer.writeln('- ${bucket.id.wire}: ${_ids(bucket.supportingCaseIds)}');
  }
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

const _supportedDefaultBuckets = <InternalEvidenceBucketId>{
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
};

const _policyBlockedBuckets = <InternalEvidenceBucketId>{
  InternalEvidenceBucketId.productLabelOutputBlocked,
  InternalEvidenceBucketId.advancedLabelGateBlocked,
  InternalEvidenceBucketId.officialMetricsBlocked,
};

const _futureComputationBuckets = <InternalEvidenceBucketId>{
  InternalEvidenceBucketId.cpLossComputationBlocked,
  InternalEvidenceBucketId.winProbabilityComputationBlocked,
};
