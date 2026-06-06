/// Developer-only adapter contract design for internal evidence summaries.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh_review.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';

const internalEvidenceAdapterDesignReportVersion =
    'internal-evidence-adapter-design-v1';

enum InternalEvidenceAdapterDesignStatus {
  designReadyWithWarnings('designReadyWithWarnings'),
  designReadyClean('designReadyClean'),
  blockedByUnsafeSummary('blockedByUnsafeSummary'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalid('invalid');

  const InternalEvidenceAdapterDesignStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterInputStatus {
  coreAllowed('coreAllowed'),
  contextOnly('contextOnly'),
  blocked('blocked'),
  futureOnly('futureOnly'),
  invalid('invalid');

  const InternalEvidenceAdapterInputStatus(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterRecordStatus {
  coreAdapterReady('coreAdapterReady'),
  contextOnly('contextOnly'),
  blocked('blocked'),
  futureOnly('futureOnly'),
  unsafe('unsafe'),
  invalid('invalid');

  const InternalEvidenceAdapterRecordStatus(this.wire);

  final String wire;

  bool get isUnsafe =>
      this == InternalEvidenceAdapterRecordStatus.unsafe ||
      this == InternalEvidenceAdapterRecordStatus.invalid;
}

enum InternalEvidenceAdapterRole {
  coreEvidence('coreEvidence'),
  contextualConstraint('contextualConstraint'),
  blockedBoundary('blockedBoundary'),
  futureOnlyInput('futureOnlyInput');

  const InternalEvidenceAdapterRole(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterRecommendation {
  allowCoreAdapterDesign('allowCoreAdapterDesign'),
  allowContextOnly('allowContextOnly'),
  keepBlocked('keepBlocked'),
  keepFutureOnly('keepFutureOnly'),
  investigatePolicyLeak('investigatePolicyLeak'),
  blockUnsafeDesign('blockUnsafeDesign');

  const InternalEvidenceAdapterRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterPhase32NRecommendation {
  proceedToInternalEvidenceAdapterPrototype(
    'proceedToInternalEvidenceAdapterPrototype',
  ),
  proceedToAdapterDesignValidation('proceedToAdapterDesignValidation'),
  addMoreGoldenCoverageFirst('addMoreGoldenCoverageFirst'),
  runOwnerProofOnlyIfPvRequired('runOwnerProofOnlyIfPvRequired'),
  blockedByUnsafeAdapterDesign('blockedByUnsafeAdapterDesign');

  const InternalEvidenceAdapterPhase32NRecommendation(this.wire);

  final String wire;
}

enum InternalEvidenceAdapterValidationSeverity {
  warning('warning'),
  blocker('blocker'),
  critical('critical');

  const InternalEvidenceAdapterValidationSeverity(this.wire);

  final String wire;

  bool get blocksStrict =>
      this == InternalEvidenceAdapterValidationSeverity.blocker ||
      this == InternalEvidenceAdapterValidationSeverity.critical;
}

enum InternalEvidenceAdapterDesignReportFormat {
  markdown('markdown'),
  json('json');

  const InternalEvidenceAdapterDesignReportFormat(this.wire);

  final String wire;
}

class InternalEvidenceAdapterDesignRequest {
  const InternalEvidenceAdapterDesignRequest({
    this.summaryResult,
    this.readinessResult,
    this.reviewResult,
    this.summaryLayer = const InternalEvidenceSummaryLayer(),
    this.readinessGate = const RefreshedPacketEvidenceReadinessGate(),
    this.review = const InternalPacketEvidenceRefreshReview(),
    this.cases = GoldenAnalysisCases.defaults,
    this.androidProofEvidence = GoldenAndroidProofEvidence.phase30uS22Ultra,
    this.includeWarnings = true,
  });

  const InternalEvidenceAdapterDesignRequest.safeDemo({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    bool includeWarnings = true,
  }) : this(cases: cases, includeWarnings: includeWarnings);

  final InternalEvidenceSummaryLayerResult? summaryResult;
  final RefreshedPacketEvidenceReadinessGateResult? readinessResult;
  final InternalPacketEvidenceRefreshReviewResult? reviewResult;
  final InternalEvidenceSummaryLayer summaryLayer;
  final RefreshedPacketEvidenceReadinessGate readinessGate;
  final InternalPacketEvidenceRefreshReview review;
  final List<GoldenAnalysisCase> cases;
  final GoldenAndroidProofEvidence? androidProofEvidence;
  final bool includeWarnings;
}

class InternalEvidenceAdapterInputContractRecord {
  const InternalEvidenceAdapterInputContractRecord({
    required this.inputGroupId,
    required this.inputStatus,
    required this.allowedForAdapterCore,
    required this.allowedForAdapterContext,
    required this.blockedFromAdapter,
    required this.recordIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.futurePrerequisites,
    required this.blockedBoundaryIds,
    required this.reason,
  });

  final InternalEvidenceSummaryGroupId inputGroupId;
  final InternalEvidenceAdapterInputStatus inputStatus;
  final bool allowedForAdapterCore;
  final bool allowedForAdapterContext;
  final bool blockedFromAdapter;
  final List<String> recordIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> futurePrerequisites;
  final List<String> blockedBoundaryIds;
  final String reason;

  InternalEvidenceAdapterInputContractRecord copyWith({
    InternalEvidenceSummaryGroupId? inputGroupId,
    InternalEvidenceAdapterInputStatus? inputStatus,
    bool? allowedForAdapterCore,
    bool? allowedForAdapterContext,
    bool? blockedFromAdapter,
    List<String>? recordIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? futurePrerequisites,
    List<String>? blockedBoundaryIds,
    String? reason,
  }) {
    return InternalEvidenceAdapterInputContractRecord(
      inputGroupId: inputGroupId ?? this.inputGroupId,
      inputStatus: inputStatus ?? this.inputStatus,
      allowedForAdapterCore:
          allowedForAdapterCore ?? this.allowedForAdapterCore,
      allowedForAdapterContext:
          allowedForAdapterContext ?? this.allowedForAdapterContext,
      blockedFromAdapter: blockedFromAdapter ?? this.blockedFromAdapter,
      recordIds: recordIds ?? this.recordIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      futurePrerequisites: futurePrerequisites ?? this.futurePrerequisites,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      reason: reason ?? this.reason,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'inputGroupId': inputGroupId.wire,
      'inputStatus': inputStatus.wire,
      'allowedForAdapterCore': allowedForAdapterCore,
      'allowedForAdapterContext': allowedForAdapterContext,
      'blockedFromAdapter': blockedFromAdapter,
      'recordIds': recordIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'futurePrerequisites': futurePrerequisites,
      'blockedBoundaryIds': blockedBoundaryIds,
      'reason': reason,
    };
  }
}

class InternalEvidenceAdapterOutputContract {
  const InternalEvidenceAdapterOutputContract({
    required this.allowedOutputFieldIds,
    required this.contextOnlyOutputFieldIds,
    required this.blockedOutputFieldIds,
  });

  final List<String> allowedOutputFieldIds;
  final List<String> contextOnlyOutputFieldIds;
  final List<String> blockedOutputFieldIds;

  InternalEvidenceAdapterOutputContract copyWith({
    List<String>? allowedOutputFieldIds,
    List<String>? contextOnlyOutputFieldIds,
    List<String>? blockedOutputFieldIds,
  }) {
    return InternalEvidenceAdapterOutputContract(
      allowedOutputFieldIds:
          allowedOutputFieldIds ?? this.allowedOutputFieldIds,
      contextOnlyOutputFieldIds:
          contextOnlyOutputFieldIds ?? this.contextOnlyOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'allowedOutputFieldIds': allowedOutputFieldIds,
      'contextOnlyOutputFieldIds': contextOnlyOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
    };
  }
}

class InternalEvidenceAdapterDesignRecord {
  const InternalEvidenceAdapterDesignRecord({
    required this.adapterRecordId,
    required this.sourceSummaryGroupId,
    required this.designStatus,
    required this.adapterRole,
    required this.allowedInputRecordIds,
    required this.allowedOutputFieldIds,
    required this.blockedOutputFieldIds,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.evidenceAreaIds,
    required this.bucketIds,
    required this.warningReason,
    required this.proofLimitReason,
    required this.futurePrerequisite,
    required this.blockedReason,
    required this.safeForPrototype,
    required this.recommendation,
    this.quietScopeActive = false,
    this.productOutputAllowed = false,
    this.classifierOutputAllowed = false,
    this.officialMetricOutputAllowed = false,
    this.numericScoreOutputAllowed = false,
    this.moveRankingOutputAllowed = false,
    this.cpLossOutputAllowed = false,
    this.winProbabilityOutputAllowed = false,
    this.integrationOutputAllowed = false,
  });

  final String adapterRecordId;
  final InternalEvidenceSummaryGroupId sourceSummaryGroupId;
  final InternalEvidenceAdapterRecordStatus designStatus;
  final InternalEvidenceAdapterRole adapterRole;
  final List<String> allowedInputRecordIds;
  final List<String> allowedOutputFieldIds;
  final List<String> blockedOutputFieldIds;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<InternalEvidenceAreaId> evidenceAreaIds;
  final List<InternalEvidenceBucketId> bucketIds;
  final String warningReason;
  final String proofLimitReason;
  final String futurePrerequisite;
  final String blockedReason;
  final bool safeForPrototype;
  final InternalEvidenceAdapterRecommendation recommendation;
  final bool quietScopeActive;
  final bool productOutputAllowed;
  final bool classifierOutputAllowed;
  final bool officialMetricOutputAllowed;
  final bool numericScoreOutputAllowed;
  final bool moveRankingOutputAllowed;
  final bool cpLossOutputAllowed;
  final bool winProbabilityOutputAllowed;
  final bool integrationOutputAllowed;

  bool get hasUnsafeOutput {
    return quietScopeActive ||
        productOutputAllowed ||
        classifierOutputAllowed ||
        officialMetricOutputAllowed ||
        numericScoreOutputAllowed ||
        moveRankingOutputAllowed ||
        cpLossOutputAllowed ||
        winProbabilityOutputAllowed ||
        integrationOutputAllowed ||
        allowedOutputFieldIds.any(_isBlockedOutputFieldId);
  }

  InternalEvidenceAdapterDesignRecord copyWith({
    String? adapterRecordId,
    InternalEvidenceSummaryGroupId? sourceSummaryGroupId,
    InternalEvidenceAdapterRecordStatus? designStatus,
    InternalEvidenceAdapterRole? adapterRole,
    List<String>? allowedInputRecordIds,
    List<String>? allowedOutputFieldIds,
    List<String>? blockedOutputFieldIds,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<InternalEvidenceAreaId>? evidenceAreaIds,
    List<InternalEvidenceBucketId>? bucketIds,
    String? warningReason,
    String? proofLimitReason,
    String? futurePrerequisite,
    String? blockedReason,
    bool? safeForPrototype,
    InternalEvidenceAdapterRecommendation? recommendation,
    bool? quietScopeActive,
    bool? productOutputAllowed,
    bool? classifierOutputAllowed,
    bool? officialMetricOutputAllowed,
    bool? numericScoreOutputAllowed,
    bool? moveRankingOutputAllowed,
    bool? cpLossOutputAllowed,
    bool? winProbabilityOutputAllowed,
    bool? integrationOutputAllowed,
  }) {
    return InternalEvidenceAdapterDesignRecord(
      adapterRecordId: adapterRecordId ?? this.adapterRecordId,
      sourceSummaryGroupId: sourceSummaryGroupId ?? this.sourceSummaryGroupId,
      designStatus: designStatus ?? this.designStatus,
      adapterRole: adapterRole ?? this.adapterRole,
      allowedInputRecordIds:
          allowedInputRecordIds ?? this.allowedInputRecordIds,
      allowedOutputFieldIds:
          allowedOutputFieldIds ?? this.allowedOutputFieldIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      evidenceAreaIds: evidenceAreaIds ?? this.evidenceAreaIds,
      bucketIds: bucketIds ?? this.bucketIds,
      warningReason: warningReason ?? this.warningReason,
      proofLimitReason: proofLimitReason ?? this.proofLimitReason,
      futurePrerequisite: futurePrerequisite ?? this.futurePrerequisite,
      blockedReason: blockedReason ?? this.blockedReason,
      safeForPrototype: safeForPrototype ?? this.safeForPrototype,
      recommendation: recommendation ?? this.recommendation,
      quietScopeActive: quietScopeActive ?? this.quietScopeActive,
      productOutputAllowed: productOutputAllowed ?? this.productOutputAllowed,
      classifierOutputAllowed:
          classifierOutputAllowed ?? this.classifierOutputAllowed,
      officialMetricOutputAllowed:
          officialMetricOutputAllowed ?? this.officialMetricOutputAllowed,
      numericScoreOutputAllowed:
          numericScoreOutputAllowed ?? this.numericScoreOutputAllowed,
      moveRankingOutputAllowed:
          moveRankingOutputAllowed ?? this.moveRankingOutputAllowed,
      cpLossOutputAllowed: cpLossOutputAllowed ?? this.cpLossOutputAllowed,
      winProbabilityOutputAllowed:
          winProbabilityOutputAllowed ?? this.winProbabilityOutputAllowed,
      integrationOutputAllowed:
          integrationOutputAllowed ?? this.integrationOutputAllowed,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'adapterRecordId': adapterRecordId,
      'sourceSummaryGroupId': sourceSummaryGroupId.wire,
      'designStatus': designStatus.wire,
      'adapterRole': adapterRole.wire,
      'allowedInputRecordIds': allowedInputRecordIds,
      'allowedOutputFieldIds': allowedOutputFieldIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'evidenceAreaIds': evidenceAreaIds.map((id) => id.wire).toList(),
      'bucketIds': bucketIds.map((id) => id.wire).toList(),
      'warningReason': warningReason,
      'proofLimitReason': proofLimitReason,
      'futurePrerequisite': futurePrerequisite,
      'blockedReason': blockedReason,
      'safeForPrototype': safeForPrototype,
      'recommendation': recommendation.wire,
      'quietScopeActive': quietScopeActive,
      'productOutputAllowed': productOutputAllowed,
      'classifierOutputAllowed': classifierOutputAllowed,
      'officialMetricOutputAllowed': officialMetricOutputAllowed,
      'numericScoreOutputAllowed': numericScoreOutputAllowed,
      'moveRankingOutputAllowed': moveRankingOutputAllowed,
      'cpLossOutputAllowed': cpLossOutputAllowed,
      'winProbabilityOutputAllowed': winProbabilityOutputAllowed,
      'integrationOutputAllowed': integrationOutputAllowed,
    };
  }
}

class InternalEvidenceAdapterFinding {
  const InternalEvidenceAdapterFinding({
    required this.id,
    required this.severity,
    required this.message,
    this.adapterRecordId,
    this.groupId,
    this.fieldId,
    this.caseId,
  });

  final String id;
  final InternalEvidenceAdapterValidationSeverity severity;
  final String message;
  final String? adapterRecordId;
  final InternalEvidenceSummaryGroupId? groupId;
  final String? fieldId;
  final String? caseId;

  bool get blocksStrict => severity.blocksStrict;

  bool get isCritical =>
      severity == InternalEvidenceAdapterValidationSeverity.critical;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'severity': severity.wire,
      'message': message,
      if (adapterRecordId != null) 'adapterRecordId': adapterRecordId,
      if (groupId != null) 'groupId': groupId!.wire,
      if (fieldId != null) 'fieldId': fieldId,
      if (caseId != null) 'caseId': caseId,
    };
  }
}

class InternalEvidenceAdapterDesignResult {
  const InternalEvidenceAdapterDesignResult({
    required this.designStatus,
    required this.sourceSummaryStatus,
    required this.sourceReadinessStatus,
    required this.sourceReviewStatus,
    required this.inputContractRecords,
    required this.outputContract,
    required this.adapterRecords,
    required this.validationFindings,
    required this.warnings,
    required this.failures,
    required this.totalAdapterRecords,
    required this.coreAdapterRecordCount,
    required this.contextOnlyRecordCount,
    required this.blockedRecordCount,
    required this.futureOnlyRecordCount,
    required this.unsafeCount,
    required this.criticalCount,
    required this.ownerProofQueueCount,
    required this.supportCaseIds,
    required this.newlyAddedSupportCaseIds,
    required this.androidProofCaseIds,
    required this.blockedOutputFieldIds,
    required this.safeForPhase32N,
    required this.phase32NRecommendation,
    this.developerOnly = true,
    this.productOutputFieldsAllowed = false,
    this.classifierOutputFieldsAllowed = false,
    this.finalMoveLabelOutputAllowed = false,
    this.officialMetricOutputFieldsAllowed = false,
    this.cpLossOutputAllowed = false,
    this.winProbabilityOutputAllowed = false,
    this.numericMoveScoreOutputAllowed = false,
    this.moveRankingOutputAllowed = false,
    this.quietPreparatoryScopeActivated = false,
    this.directEngineAccessUsed = false,
    this.uiOutputUsed = false,
    this.backendOutputUsed = false,
    this.persistenceUsed = false,
  });

  final InternalEvidenceAdapterDesignStatus designStatus;
  final InternalEvidenceSummaryLayerStatus sourceSummaryStatus;
  final RefreshedPacketEvidenceReadinessStatus sourceReadinessStatus;
  final InternalPacketEvidenceRefreshReviewStatus sourceReviewStatus;
  final List<InternalEvidenceAdapterInputContractRecord> inputContractRecords;
  final InternalEvidenceAdapterOutputContract outputContract;
  final List<InternalEvidenceAdapterDesignRecord> adapterRecords;
  final List<InternalEvidenceAdapterFinding> validationFindings;
  final List<String> warnings;
  final List<String> failures;
  final int totalAdapterRecords;
  final int coreAdapterRecordCount;
  final int contextOnlyRecordCount;
  final int blockedRecordCount;
  final int futureOnlyRecordCount;
  final int unsafeCount;
  final int criticalCount;
  final int ownerProofQueueCount;
  final List<String> supportCaseIds;
  final List<String> newlyAddedSupportCaseIds;
  final List<String> androidProofCaseIds;
  final List<String> blockedOutputFieldIds;
  final bool safeForPhase32N;
  final InternalEvidenceAdapterPhase32NRecommendation phase32NRecommendation;
  final bool developerOnly;
  final bool productOutputFieldsAllowed;
  final bool classifierOutputFieldsAllowed;
  final bool finalMoveLabelOutputAllowed;
  final bool officialMetricOutputFieldsAllowed;
  final bool cpLossOutputAllowed;
  final bool winProbabilityOutputAllowed;
  final bool numericMoveScoreOutputAllowed;
  final bool moveRankingOutputAllowed;
  final bool quietPreparatoryScopeActivated;
  final bool directEngineAccessUsed;
  final bool uiOutputUsed;
  final bool backendOutputUsed;
  final bool persistenceUsed;

  bool get isStrictlyBlocked =>
      designStatus ==
          InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary ||
      designStatus ==
          InternalEvidenceAdapterDesignStatus.blockedByPolicyBoundary ||
      designStatus == InternalEvidenceAdapterDesignStatus.invalid ||
      !safeForPhase32N ||
      unsafeCount > 0 ||
      criticalCount > 0 ||
      validationFindings.any((finding) => finding.blocksStrict);

  bool get hasUnsafeAdapterDesignPolicyViolation {
    return unsafeCount > 0 ||
        criticalCount > 0 ||
        validationFindings.any((finding) => finding.isCritical) ||
        adapterRecords.any(
          (record) => record.designStatus.isUnsafe || record.hasUnsafeOutput,
        ) ||
        _activeOutputFieldIds.any(_isBlockedOutputFieldId) ||
        productOutputFieldsAllowed ||
        classifierOutputFieldsAllowed ||
        finalMoveLabelOutputAllowed ||
        officialMetricOutputFieldsAllowed ||
        cpLossOutputAllowed ||
        winProbabilityOutputAllowed ||
        numericMoveScoreOutputAllowed ||
        moveRankingOutputAllowed ||
        quietPreparatoryScopeActivated ||
        directEngineAccessUsed ||
        uiOutputUsed ||
        backendOutputUsed ||
        persistenceUsed;
  }

  List<String> get _activeOutputFieldIds {
    return _sortedStrings(<String>[
      ...outputContract.allowedOutputFieldIds,
      ...outputContract.contextOnlyOutputFieldIds,
      ...adapterRecords.expand((record) => record.allowedOutputFieldIds),
    ]);
  }

  InternalEvidenceAdapterInputContractRecord inputContract(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return inputContractRecords.singleWhere(
      (record) => record.inputGroupId == groupId,
    );
  }

  InternalEvidenceAdapterDesignRecord adapterRecord(
    InternalEvidenceSummaryGroupId groupId,
  ) {
    return adapterRecords.singleWhere(
      (record) => record.sourceSummaryGroupId == groupId,
    );
  }

  List<InternalEvidenceAdapterDesignRecord> get coreAdapterRecords =>
      adapterRecords
          .where(
            (record) =>
                record.adapterRole == InternalEvidenceAdapterRole.coreEvidence,
          )
          .toList(growable: false);

  List<InternalEvidenceAdapterDesignRecord> get contextOnlyRecords =>
      adapterRecords
          .where(
            (record) =>
                record.adapterRole ==
                InternalEvidenceAdapterRole.contextualConstraint,
          )
          .toList(growable: false);

  List<InternalEvidenceAdapterDesignRecord> get blockedOrFutureRecords =>
      adapterRecords
          .where(
            (record) =>
                record.adapterRole ==
                    InternalEvidenceAdapterRole.blockedBoundary ||
                record.adapterRole ==
                    InternalEvidenceAdapterRole.futureOnlyInput,
          )
          .toList(growable: false);

  InternalEvidenceAdapterDesignResult copyWith({
    InternalEvidenceAdapterDesignStatus? designStatus,
    InternalEvidenceSummaryLayerStatus? sourceSummaryStatus,
    RefreshedPacketEvidenceReadinessStatus? sourceReadinessStatus,
    InternalPacketEvidenceRefreshReviewStatus? sourceReviewStatus,
    List<InternalEvidenceAdapterInputContractRecord>? inputContractRecords,
    InternalEvidenceAdapterOutputContract? outputContract,
    List<InternalEvidenceAdapterDesignRecord>? adapterRecords,
    List<InternalEvidenceAdapterFinding>? validationFindings,
    List<String>? warnings,
    List<String>? failures,
    int? totalAdapterRecords,
    int? coreAdapterRecordCount,
    int? contextOnlyRecordCount,
    int? blockedRecordCount,
    int? futureOnlyRecordCount,
    int? unsafeCount,
    int? criticalCount,
    int? ownerProofQueueCount,
    List<String>? supportCaseIds,
    List<String>? newlyAddedSupportCaseIds,
    List<String>? androidProofCaseIds,
    List<String>? blockedOutputFieldIds,
    bool? safeForPhase32N,
    InternalEvidenceAdapterPhase32NRecommendation? phase32NRecommendation,
    bool? developerOnly,
    bool? productOutputFieldsAllowed,
    bool? classifierOutputFieldsAllowed,
    bool? finalMoveLabelOutputAllowed,
    bool? officialMetricOutputFieldsAllowed,
    bool? cpLossOutputAllowed,
    bool? winProbabilityOutputAllowed,
    bool? numericMoveScoreOutputAllowed,
    bool? moveRankingOutputAllowed,
    bool? quietPreparatoryScopeActivated,
    bool? directEngineAccessUsed,
    bool? uiOutputUsed,
    bool? backendOutputUsed,
    bool? persistenceUsed,
  }) {
    return InternalEvidenceAdapterDesignResult(
      designStatus: designStatus ?? this.designStatus,
      sourceSummaryStatus: sourceSummaryStatus ?? this.sourceSummaryStatus,
      sourceReadinessStatus:
          sourceReadinessStatus ?? this.sourceReadinessStatus,
      sourceReviewStatus: sourceReviewStatus ?? this.sourceReviewStatus,
      inputContractRecords: inputContractRecords ?? this.inputContractRecords,
      outputContract: outputContract ?? this.outputContract,
      adapterRecords: adapterRecords ?? this.adapterRecords,
      validationFindings: validationFindings ?? this.validationFindings,
      warnings: warnings ?? this.warnings,
      failures: failures ?? this.failures,
      totalAdapterRecords: totalAdapterRecords ?? this.totalAdapterRecords,
      coreAdapterRecordCount:
          coreAdapterRecordCount ?? this.coreAdapterRecordCount,
      contextOnlyRecordCount:
          contextOnlyRecordCount ?? this.contextOnlyRecordCount,
      blockedRecordCount: blockedRecordCount ?? this.blockedRecordCount,
      futureOnlyRecordCount:
          futureOnlyRecordCount ?? this.futureOnlyRecordCount,
      unsafeCount: unsafeCount ?? this.unsafeCount,
      criticalCount: criticalCount ?? this.criticalCount,
      ownerProofQueueCount: ownerProofQueueCount ?? this.ownerProofQueueCount,
      supportCaseIds: supportCaseIds ?? this.supportCaseIds,
      newlyAddedSupportCaseIds:
          newlyAddedSupportCaseIds ?? this.newlyAddedSupportCaseIds,
      androidProofCaseIds: androidProofCaseIds ?? this.androidProofCaseIds,
      blockedOutputFieldIds:
          blockedOutputFieldIds ?? this.blockedOutputFieldIds,
      safeForPhase32N: safeForPhase32N ?? this.safeForPhase32N,
      phase32NRecommendation:
          phase32NRecommendation ?? this.phase32NRecommendation,
      developerOnly: developerOnly ?? this.developerOnly,
      productOutputFieldsAllowed:
          productOutputFieldsAllowed ?? this.productOutputFieldsAllowed,
      classifierOutputFieldsAllowed:
          classifierOutputFieldsAllowed ?? this.classifierOutputFieldsAllowed,
      finalMoveLabelOutputAllowed:
          finalMoveLabelOutputAllowed ?? this.finalMoveLabelOutputAllowed,
      officialMetricOutputFieldsAllowed:
          officialMetricOutputFieldsAllowed ??
          this.officialMetricOutputFieldsAllowed,
      cpLossOutputAllowed: cpLossOutputAllowed ?? this.cpLossOutputAllowed,
      winProbabilityOutputAllowed:
          winProbabilityOutputAllowed ?? this.winProbabilityOutputAllowed,
      numericMoveScoreOutputAllowed:
          numericMoveScoreOutputAllowed ?? this.numericMoveScoreOutputAllowed,
      moveRankingOutputAllowed:
          moveRankingOutputAllowed ?? this.moveRankingOutputAllowed,
      quietPreparatoryScopeActivated:
          quietPreparatoryScopeActivated ?? this.quietPreparatoryScopeActivated,
      directEngineAccessUsed:
          directEngineAccessUsed ?? this.directEngineAccessUsed,
      uiOutputUsed: uiOutputUsed ?? this.uiOutputUsed,
      backendOutputUsed: backendOutputUsed ?? this.backendOutputUsed,
      persistenceUsed: persistenceUsed ?? this.persistenceUsed,
    );
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Internal Evidence Adapter Design')
      ..writeln()
      ..writeln('- version: $internalEvidenceAdapterDesignReportVersion')
      ..writeln('- adapter design status: ${designStatus.wire}')
      ..writeln('- source summary status: ${sourceSummaryStatus.wire}')
      ..writeln('- source readiness status: ${sourceReadinessStatus.wire}')
      ..writeln('- source review status: ${sourceReviewStatus.wire}')
      ..writeln('- total adapter records: $totalAdapterRecords')
      ..writeln('- core adapter record count: $coreAdapterRecordCount')
      ..writeln('- context-only record count: $contextOnlyRecordCount')
      ..writeln('- blocked record count: $blockedRecordCount')
      ..writeln('- future-only record count: $futureOnlyRecordCount')
      ..writeln('- owner proof queue count: $ownerProofQueueCount')
      ..writeln('- unsafe count: $unsafeCount')
      ..writeln('- critical count: $criticalCount')
      ..writeln('- safe for Phase 32N: $safeForPhase32N')
      ..writeln('- Phase 32N recommendation: ${phase32NRecommendation.wire}')
      ..writeln()
      ..writeln('## Adapter Design Policy')
      ..writeln(
        '- this layer designs an internal-only adapter contract over the Phase 32L summary',
      )
      ..writeln(
        '- core inputs are limited to allowed and improved support summaries; constrained summaries remain context-only',
      )
      ..writeln(
        '- blocked and future-only summaries remain inactive, and blocked output field IDs are contract denials only',
      )
      ..writeln()
      ..writeln('## Input Contract Table')
      ..writeln(
        '| Input Group | Status | Core | Context | Blocked | Records | Support Cases | New Phase 32E Support | Android Proof | Reason |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final input in inputContractRecords) {
      buffer.writeln(
        '| ${input.inputGroupId.wire} | ${input.inputStatus.wire} | '
        '${input.allowedForAdapterCore} | ${input.allowedForAdapterContext} | '
        '${input.blockedFromAdapter} | ${_ids(input.recordIds)} | '
        '${_ids(input.supportCaseIds)} | '
        '${_ids(input.newlyAddedSupportCaseIds)} | '
        '${_ids(input.androidProofCaseIds)} | ${_cell(input.reason)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Output Contract Table')
      ..writeln('| Contract | Field IDs |')
      ..writeln('| --- | --- |')
      ..writeln(
        '| allowed internal output fields | ${_ids(outputContract.allowedOutputFieldIds)} |',
      )
      ..writeln(
        '| context-only output fields | ${_ids(outputContract.contextOnlyOutputFieldIds)} |',
      )
      ..writeln(
        '| blocked output fields | ${_ids(outputContract.blockedOutputFieldIds)} |',
      )
      ..writeln()
      ..writeln('## Adapter Design Record Table')
      ..writeln(
        '| Adapter Record | Source Group | Role | Status | Inputs | Active Output Fields | Blocked Output Fields | Support Cases | New Phase 32E Support | Android Proof | Safe | Recommendation |',
      )
      ..writeln(
        '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
      );
    for (final record in adapterRecords) {
      buffer.writeln(
        '| ${_cell(record.adapterRecordId)} | '
        '${record.sourceSummaryGroupId.wire} | ${record.adapterRole.wire} | '
        '${record.designStatus.wire} | ${_ids(record.allowedInputRecordIds)} | '
        '${_ids(record.allowedOutputFieldIds)} | '
        '${_ids(record.blockedOutputFieldIds)} | '
        '${_ids(record.supportCaseIds)} | '
        '${_ids(record.newlyAddedSupportCaseIds)} | '
        '${_ids(record.androidProofCaseIds)} | '
        '${record.safeForPrototype} | ${record.recommendation.wire} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('## Core Adapter Records')
      ..writeln('- ${_adapterRecordIds(coreAdapterRecords)}')
      ..writeln()
      ..writeln('## Context-Only Records')
      ..writeln('- ${_adapterRecordIds(contextOnlyRecords)}')
      ..writeln()
      ..writeln('## Blocked And Future-Only Records')
      ..writeln('- ${_adapterRecordIds(blockedOrFutureRecords)}')
      ..writeln()
      ..writeln('## Blocked Output Fields')
      ..writeln('- ${_ids(blockedOutputFieldIds)}')
      ..writeln()
      ..writeln('## Android Proof IDs')
      ..writeln('- ${_ids(androidProofCaseIds)}')
      ..writeln()
      ..writeln('## Owner Proof Status')
      ..writeln(
        ownerProofQueueCount == 0
            ? '- empty'
            : '- opt-in proof requires explicit PV/MultiPV reason',
      )
      ..writeln()
      ..writeln('## Validation Findings');
    if (validationFindings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final finding in validationFindings) {
        buffer.writeln(
          '- ${finding.severity.wire}: ${finding.id} -- ${finding.message}',
        );
      }
    }
    buffer
      ..writeln()
      ..writeln('## Warnings');
    if (warnings.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final warning in warnings) {
        buffer.writeln('- ${_cell(warning)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Failures');
    if (failures.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final failure in failures) {
        buffer.writeln('- ${_cell(failure)}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Phase 32N Recommendation')
      ..writeln(phase32NRecommendation.wire)
      ..writeln()
      ..writeln(
        'This adapter design is internal-only. It does not emit active product labels, compute values, rank moves, call the engine, run Android, integrate with product surfaces, or write files.',
      );
    return buffer.toString();
  }

  String renderJsonReport() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': internalEvidenceAdapterDesignReportVersion,
      'designStatus': designStatus.wire,
      'sourceSummaryStatus': sourceSummaryStatus.wire,
      'sourceReadinessStatus': sourceReadinessStatus.wire,
      'sourceReviewStatus': sourceReviewStatus.wire,
      'totalAdapterRecords': totalAdapterRecords,
      'coreAdapterRecordCount': coreAdapterRecordCount,
      'contextOnlyRecordCount': contextOnlyRecordCount,
      'blockedRecordCount': blockedRecordCount,
      'futureOnlyRecordCount': futureOnlyRecordCount,
      'unsafeCount': unsafeCount,
      'criticalCount': criticalCount,
      'ownerProofQueueCount': ownerProofQueueCount,
      'supportCaseIds': supportCaseIds,
      'newlyAddedSupportCaseIds': newlyAddedSupportCaseIds,
      'androidProofCaseIds': androidProofCaseIds,
      'blockedOutputFieldIds': blockedOutputFieldIds,
      'safeForPhase32N': safeForPhase32N,
      'phase32NRecommendation': phase32NRecommendation.wire,
      'inputContractRecords': inputContractRecords
          .map((record) => record.toJson())
          .toList(),
      'outputContract': outputContract.toJson(),
      'adapterRecords': adapterRecords
          .map((record) => record.toJson())
          .toList(),
      'validationFindings': validationFindings
          .map((finding) => finding.toJson())
          .toList(),
      'warnings': warnings,
      'failures': failures,
      'developerOnly': developerOnly,
      'productOutputFieldsAllowed': productOutputFieldsAllowed,
      'classifierOutputFieldsAllowed': classifierOutputFieldsAllowed,
      'finalMoveLabelOutputAllowed': finalMoveLabelOutputAllowed,
      'officialMetricOutputFieldsAllowed': officialMetricOutputFieldsAllowed,
      'cpLossOutputAllowed': cpLossOutputAllowed,
      'winProbabilityOutputAllowed': winProbabilityOutputAllowed,
      'numericMoveScoreOutputAllowed': numericMoveScoreOutputAllowed,
      'moveRankingOutputAllowed': moveRankingOutputAllowed,
      'quietPreparatoryScopeActivated': quietPreparatoryScopeActivated,
      'directEngineAccessUsed': directEngineAccessUsed,
      'uiOutputUsed': uiOutputUsed,
      'backendOutputUsed': backendOutputUsed,
      'persistenceUsed': persistenceUsed,
    };
  }
}

class InternalEvidenceAdapterDesign {
  const InternalEvidenceAdapterDesign({
    this.validator = const InternalEvidenceAdapterDesignValidator(),
  });

  final InternalEvidenceAdapterDesignValidator validator;

  InternalEvidenceAdapterDesignResult evaluate([
    InternalEvidenceAdapterDesignRequest request =
        const InternalEvidenceAdapterDesignRequest(),
  ]) {
    final summaryResult =
        request.summaryResult ??
        request.summaryLayer.evaluate(
          InternalEvidenceSummaryLayerRequest(
            readinessResult: request.readinessResult,
            reviewResult: request.reviewResult,
            readinessGate: request.readinessGate,
            review: request.review,
            cases: request.cases,
            androidProofEvidence: request.androidProofEvidence,
            includeWarnings: request.includeWarnings,
          ),
        );
    final canDesign =
        summaryResult.safeForPhase32M &&
        !summaryResult.isStrictlyBlocked &&
        !summaryResult.hasUnsafeSummaryPolicyViolation;
    final outputContract = _defaultOutputContract();
    final inputRecords = canDesign
        ? _inputContractRecordsFrom(summaryResult.groups)
        : const <InternalEvidenceAdapterInputContractRecord>[];
    final adapterRecords = canDesign
        ? _adapterRecordsFrom(summaryResult.groups, outputContract)
        : const <InternalEvidenceAdapterDesignRecord>[];
    final base = _resultFromContracts(
      summaryResult: summaryResult,
      inputRecords: inputRecords,
      outputContract: outputContract,
      adapterRecords: adapterRecords,
      validationFindings: const <InternalEvidenceAdapterFinding>[],
    );
    final findings = validator.validate(
      base,
      cases: request.cases,
      androidProofEvidence: request.androidProofEvidence,
    );
    return _resultFromContracts(
      summaryResult: summaryResult,
      inputRecords: inputRecords,
      outputContract: outputContract,
      adapterRecords: adapterRecords,
      validationFindings: findings,
    );
  }
}

class InternalEvidenceAdapterDesignValidator {
  const InternalEvidenceAdapterDesignValidator();

  List<InternalEvidenceAdapterFinding> validate(
    InternalEvidenceAdapterDesignResult result, {
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenAndroidProofEvidence? androidProofEvidence =
        GoldenAndroidProofEvidence.phase30uS22Ultra,
  }) {
    final findings = <InternalEvidenceAdapterFinding>[];
    final provenAndroidIds = _provenAndroidProofIds(androidProofEvidence);
    void add({
      required String id,
      required InternalEvidenceAdapterValidationSeverity severity,
      required String message,
      String? adapterRecordId,
      InternalEvidenceSummaryGroupId? groupId,
      String? fieldId,
      String? caseId,
    }) {
      findings.add(
        InternalEvidenceAdapterFinding(
          id: id,
          severity: severity,
          message: message,
          adapterRecordId: adapterRecordId,
          groupId: groupId,
          fieldId: fieldId,
          caseId: caseId,
        ),
      );
    }

    if (result.safeForPhase32N &&
        (result.sourceSummaryStatus ==
                InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness ||
            result.unsafeCount > 0 ||
            result.adapterRecords.any(
              (record) => record.designStatus.isUnsafe,
            ))) {
      add(
        id: 'unsafeSummaryMarkedDesignReady',
        severity: InternalEvidenceAdapterValidationSeverity.critical,
        message: 'unsafe summary cannot be marked adapter-design ready',
      );
    }

    if (result.ownerProofQueueCount > 0 && !_hasExplicitPvProofReason(result)) {
      add(
        id: 'ownerProofRequiredWithoutPvReason',
        severity: InternalEvidenceAdapterValidationSeverity.blocker,
        message: 'owner proof requires explicit PV/MultiPV reason',
      );
    }

    for (final fieldId in result.outputContract.allowedOutputFieldIds) {
      _checkAllowedField(add, fieldId);
    }
    for (final fieldId in result.outputContract.contextOnlyOutputFieldIds) {
      _checkAllowedField(add, fieldId);
    }

    for (final input in result.inputContractRecords) {
      if (_contextOnlyGroupIds.contains(input.inputGroupId) &&
          input.allowedForAdapterCore) {
        add(
          id: 'constrainedGroupPromotedToCoreOutput',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: '${input.inputGroupId.wire} must remain context-only',
          groupId: input.inputGroupId,
        );
      }
      if (_blockedGroupIds.contains(input.inputGroupId) &&
          !input.blockedFromAdapter) {
        add(
          id: 'blockedGroupMadeActive',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: '${input.inputGroupId.wire} must remain blocked',
          groupId: input.inputGroupId,
        );
      }
      if (input.inputGroupId ==
              InternalEvidenceSummaryGroupId.futureOnlySummary &&
          !input.blockedFromAdapter) {
        add(
          id: 'futureOnlyGroupMadeActive',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: 'future-only summary must remain inactive',
          groupId: input.inputGroupId,
        );
      }
    }

    for (final record in result.adapterRecords) {
      for (final fieldId in record.allowedOutputFieldIds) {
        _checkAllowedField(
          add,
          fieldId,
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
      if (_contextOnlyGroupIds.contains(record.sourceSummaryGroupId) &&
          record.adapterRole == InternalEvidenceAdapterRole.coreEvidence) {
        add(
          id: 'constrainedGroupPromotedToCoreOutput',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: '${record.sourceSummaryGroupId.wire} cannot be core output',
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
      if (_blockedGroupIds.contains(record.sourceSummaryGroupId) &&
          record.adapterRole != InternalEvidenceAdapterRole.blockedBoundary) {
        add(
          id: 'blockedGroupMadeActive',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: '${record.sourceSummaryGroupId.wire} must stay blocked',
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
      if (record.sourceSummaryGroupId ==
              InternalEvidenceSummaryGroupId.futureOnlySummary &&
          record.adapterRole != InternalEvidenceAdapterRole.futureOnlyInput) {
        add(
          id: 'futureOnlyGroupMadeActive',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: 'future-only summary must stay future-only',
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
      if (record.quietScopeActive) {
        add(
          id: 'quietPreparatoryScopeActivated',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: 'quiet/preparatory scope must remain excluded',
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
      if (record.hasUnsafeOutput) {
        add(
          id: 'adapterRecordBoundaryPolicyViolation',
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message:
              '${record.adapterRecordId} crossed a blocked output boundary',
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
      for (final caseId in record.androidProofCaseIds) {
        _checkAndroidProofCase(
          add,
          caseId,
          provenAndroidIds,
          adapterRecordId: record.adapterRecordId,
          groupId: record.sourceSummaryGroupId,
        );
      }
    }

    for (final caseId in result.androidProofCaseIds) {
      _checkAndroidProofCase(add, caseId, provenAndroidIds);
    }

    if (result.productOutputFieldsAllowed ||
        result.classifierOutputFieldsAllowed ||
        result.finalMoveLabelOutputAllowed ||
        result.officialMetricOutputFieldsAllowed ||
        result.cpLossOutputAllowed ||
        result.winProbabilityOutputAllowed ||
        result.numericMoveScoreOutputAllowed ||
        result.moveRankingOutputAllowed ||
        result.quietPreparatoryScopeActivated ||
        result.directEngineAccessUsed ||
        result.uiOutputUsed ||
        result.backendOutputUsed ||
        result.persistenceUsed) {
      add(
        id: 'adapterBoundaryPolicyViolation',
        severity: InternalEvidenceAdapterValidationSeverity.critical,
        message: 'adapter design crossed a blocked output boundary',
      );
    }

    return findings..sort(_compareFindings);
  }

  List<InternalEvidenceAdapterFinding> validateReportText(String reportText) {
    final findings = <InternalEvidenceAdapterFinding>[];
    void reportError(String id, String message) {
      findings.add(
        InternalEvidenceAdapterFinding(
          id: id,
          severity: InternalEvidenceAdapterValidationSeverity.critical,
          message: message,
        ),
      );
    }

    final lower = reportText.toLowerCase();
    if (lower.contains('uciok') ||
        lower.contains('readyok') ||
        lower.contains('info depth') ||
        lower.contains('bestmove e2e4')) {
      reportError('rawUciReportText', 'report contains raw UCI text');
    }
    if (reportText.contains(' pv ') ||
        reportText.contains('pvMoves') ||
        reportText.contains('e2e4 e7e5')) {
      reportError('pvDumpReportText', 'report contains PV dump text');
    }
    if (lower.contains('active output fields: productlabel') ||
        lower.contains('allowed output fields: productlabel') ||
        lower.contains('active output fields: finalmovelabel') ||
        lower.contains('allowed output fields: finalmovelabel')) {
      reportError(
        'activeLabelReportText',
        'report contains active label output text',
      );
    }
    if (reportText.contains('numeric move score:') ||
        reportText.contains('scoreValue') ||
        reportText.contains('moveScore')) {
      reportError(
        'numericMoveValueReportText',
        'report contains numeric move value text',
      );
    }
    if (reportText.contains('rankedMoves') ||
        reportText.contains('moveRanking active')) {
      reportError(
        'moveOrderingReportText',
        'report contains active move ordering text',
      );
    }
    return findings..sort(_compareFindings);
  }
}

List<InternalEvidenceAdapterInputContractRecord> _inputContractRecordsFrom(
  List<InternalEvidenceSummaryGroup> groups,
) {
  return groups.map(_inputContractFromGroup).toList(growable: false);
}

InternalEvidenceAdapterInputContractRecord _inputContractFromGroup(
  InternalEvidenceSummaryGroup group,
) {
  final status = _inputStatusFor(group.groupId);
  final coreAllowed = status == InternalEvidenceAdapterInputStatus.coreAllowed;
  final contextOnly = status == InternalEvidenceAdapterInputStatus.contextOnly;
  final blocked =
      status == InternalEvidenceAdapterInputStatus.blocked ||
      status == InternalEvidenceAdapterInputStatus.futureOnly;
  return InternalEvidenceAdapterInputContractRecord(
    inputGroupId: group.groupId,
    inputStatus: status,
    allowedForAdapterCore: coreAllowed,
    allowedForAdapterContext: contextOnly,
    blockedFromAdapter: blocked,
    recordIds: _sortedStrings(group.recordIds),
    supportCaseIds: _sortedStrings(group.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(group.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(group.androidProofCaseIds),
    warningReasons: _sortedStrings(group.warningReasons),
    proofLimitReasons: _sortedStrings(group.proofLimitReasons),
    futurePrerequisites: _sortedStrings(group.futurePrerequisites),
    blockedBoundaryIds: _sortedStrings(group.blockedBoundaryIds),
    reason: _inputReasonFor(status),
  );
}

List<InternalEvidenceAdapterDesignRecord> _adapterRecordsFrom(
  List<InternalEvidenceSummaryGroup> groups,
  InternalEvidenceAdapterOutputContract outputContract,
) {
  return groups
      .map((group) => _adapterRecordFromGroup(group, outputContract))
      .toList(growable: false);
}

InternalEvidenceAdapterDesignRecord _adapterRecordFromGroup(
  InternalEvidenceSummaryGroup group,
  InternalEvidenceAdapterOutputContract outputContract,
) {
  final role = _roleFor(group.groupId);
  final status = _recordStatusFor(role, group);
  final allowedOutputFields = switch (role) {
    InternalEvidenceAdapterRole.coreEvidence =>
      outputContract.allowedOutputFieldIds,
    InternalEvidenceAdapterRole.contextualConstraint => _sortedStrings(<String>[
      ...outputContract.contextOnlyOutputFieldIds,
      'internalWarnings',
      'internalConstraints',
      'futurePrerequisites',
    ]),
    InternalEvidenceAdapterRole.blockedBoundary ||
    InternalEvidenceAdapterRole.futureOnlyInput => const <String>[],
  };
  return InternalEvidenceAdapterDesignRecord(
    adapterRecordId: 'adapter-${group.groupId.wire}',
    sourceSummaryGroupId: group.groupId,
    designStatus: status,
    adapterRole: role,
    allowedInputRecordIds:
        role == InternalEvidenceAdapterRole.blockedBoundary ||
            role == InternalEvidenceAdapterRole.futureOnlyInput
        ? const <String>[]
        : _sortedStrings(group.recordIds),
    allowedOutputFieldIds: _sortedStrings(allowedOutputFields),
    blockedOutputFieldIds: _blockedOutputFieldIds,
    supportCaseIds: _sortedStrings(group.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(group.newlyAddedSupportCaseIds),
    androidProofCaseIds: _sortedStrings(group.androidProofCaseIds),
    evidenceAreaIds: _sortedAreaIds(group.evidenceAreaIds),
    bucketIds: _sortedBucketIds(group.bucketIds),
    warningReason: _joinReasons(group.warningReasons),
    proofLimitReason: _joinReasons(group.proofLimitReasons),
    futurePrerequisite: _joinReasons(group.futurePrerequisites),
    blockedReason: _joinReasons(group.blockedBoundaryIds),
    safeForPrototype:
        group.safeForNextInternalLayer &&
        !group.hasUnsafeOutput &&
        status != InternalEvidenceAdapterRecordStatus.unsafe &&
        status != InternalEvidenceAdapterRecordStatus.invalid,
    recommendation: _recommendationFor(role, group),
    quietScopeActive: group.quietScopeActive,
    productOutputAllowed: group.isProductOutput,
    classifierOutputAllowed: group.isClassifierLabel,
    officialMetricOutputAllowed: group.isOfficialMetric,
    numericScoreOutputAllowed: group.hasNumericValue,
    moveRankingOutputAllowed: group.ordersMoves,
    cpLossOutputAllowed: group.cpLossComputationImplemented,
    winProbabilityOutputAllowed: group.winProbabilityComputationImplemented,
  );
}

InternalEvidenceAdapterDesignResult _resultFromContracts({
  required InternalEvidenceSummaryLayerResult summaryResult,
  required List<InternalEvidenceAdapterInputContractRecord> inputRecords,
  required InternalEvidenceAdapterOutputContract outputContract,
  required List<InternalEvidenceAdapterDesignRecord> adapterRecords,
  required List<InternalEvidenceAdapterFinding> validationFindings,
}) {
  final recordUnsafeCount = adapterRecords
      .where((record) => record.designStatus.isUnsafe || record.hasUnsafeOutput)
      .length;
  final unsafeCount = summaryResult.unsafeCount + recordUnsafeCount;
  final criticalCount =
      summaryResult.criticalCount +
      validationFindings.where((finding) => finding.isCritical).length;
  final base = InternalEvidenceAdapterDesignResult(
    designStatus: InternalEvidenceAdapterDesignStatus.invalid,
    sourceSummaryStatus: summaryResult.summaryStatus,
    sourceReadinessStatus: summaryResult.sourceReadinessStatus,
    sourceReviewStatus: summaryResult.sourceReviewStatus,
    inputContractRecords: inputRecords,
    outputContract: outputContract,
    adapterRecords: adapterRecords,
    validationFindings: validationFindings,
    warnings: _sortedStrings(<String>[
      ...summaryResult.warnings,
      if (adapterRecords.any(
        (record) =>
            record.adapterRole ==
            InternalEvidenceAdapterRole.contextualConstraint,
      ))
        'context-only adapter records remain outside core output',
      if (outputContract.blockedOutputFieldIds.isNotEmpty)
        'blocked output fields remain explicit contract denials',
    ]),
    failures: _sortedStrings(<String>[
      ...summaryResult.failures,
      ...validationFindings.map((finding) => finding.message),
    ]),
    totalAdapterRecords: adapterRecords.length,
    coreAdapterRecordCount: adapterRecords
        .where(
          (record) =>
              record.adapterRole == InternalEvidenceAdapterRole.coreEvidence,
        )
        .length,
    contextOnlyRecordCount: adapterRecords
        .where(
          (record) =>
              record.adapterRole ==
              InternalEvidenceAdapterRole.contextualConstraint,
        )
        .length,
    blockedRecordCount: adapterRecords
        .where(
          (record) =>
              record.adapterRole == InternalEvidenceAdapterRole.blockedBoundary,
        )
        .length,
    futureOnlyRecordCount: adapterRecords
        .where(
          (record) =>
              record.adapterRole == InternalEvidenceAdapterRole.futureOnlyInput,
        )
        .length,
    unsafeCount: unsafeCount,
    criticalCount: criticalCount,
    ownerProofQueueCount: summaryResult.ownerProofQueueCount,
    supportCaseIds: _sortedStrings(summaryResult.supportCaseIds),
    newlyAddedSupportCaseIds: _sortedStrings(
      summaryResult.newlyAddedSupportCaseIds,
    ),
    androidProofCaseIds: _sortedStrings(summaryResult.androidProofCaseIds),
    blockedOutputFieldIds: _sortedStrings(outputContract.blockedOutputFieldIds),
    safeForPhase32N: false,
    phase32NRecommendation: InternalEvidenceAdapterPhase32NRecommendation
        .addMoreGoldenCoverageFirst,
    productOutputFieldsAllowed: summaryResult.productLabelsEmitted,
    classifierOutputFieldsAllowed:
        summaryResult.classifierLabelsEmitted ||
        summaryResult.advancedLabelsEmitted,
    finalMoveLabelOutputAllowed: summaryResult.finalMoveLabelsEmitted,
    officialMetricOutputFieldsAllowed: summaryResult.officialMetricsAllowed,
    cpLossOutputAllowed: summaryResult.cpLossComputationImplemented,
    winProbabilityOutputAllowed:
        summaryResult.winProbabilityComputationImplemented,
    numericMoveScoreOutputAllowed: summaryResult.numericMoveValuesComputed,
    moveRankingOutputAllowed: summaryResult.moveOrderingComputed,
    quietPreparatoryScopeActivated:
        summaryResult.quietPreparatoryScopeActivated,
    directEngineAccessUsed: summaryResult.directEngineAccessUsed,
    uiOutputUsed: summaryResult.uiOutputUsed,
    backendOutputUsed: summaryResult.backendOutputUsed,
    persistenceUsed: summaryResult.persistenceUsed,
  );
  final status = _designStatusFor(base, summaryResult: summaryResult);
  final safeForPhase32N =
      (status == InternalEvidenceAdapterDesignStatus.designReadyWithWarnings ||
          status == InternalEvidenceAdapterDesignStatus.designReadyClean) &&
      summaryResult.safeForPhase32M &&
      !summaryResult.isStrictlyBlocked &&
      !summaryResult.hasUnsafeSummaryPolicyViolation &&
      unsafeCount == 0 &&
      criticalCount == 0 &&
      !validationFindings.any((finding) => finding.blocksStrict) &&
      adapterRecords.every((record) => record.safeForPrototype);
  return base.copyWith(
    designStatus: status,
    safeForPhase32N: safeForPhase32N,
    phase32NRecommendation: _phase32NRecommendationFor(
      status: status,
      safeForPhase32N: safeForPhase32N,
      ownerProofQueueCount: summaryResult.ownerProofQueueCount,
      contextOnlyRecordCount: base.contextOnlyRecordCount,
    ),
  );
}

InternalEvidenceAdapterDesignStatus _designStatusFor(
  InternalEvidenceAdapterDesignResult result, {
  required InternalEvidenceSummaryLayerResult summaryResult,
}) {
  if (summaryResult.summaryStatus ==
          InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness ||
      summaryResult.unsafeCount > 0 ||
      result.unsafeCount > 0 ||
      result.criticalCount > 0 ||
      result.validationFindings.any((finding) => finding.isCritical)) {
    return InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary;
  }
  if (result.productOutputFieldsAllowed ||
      result.classifierOutputFieldsAllowed ||
      result.finalMoveLabelOutputAllowed ||
      result.officialMetricOutputFieldsAllowed ||
      result.cpLossOutputAllowed ||
      result.winProbabilityOutputAllowed ||
      result.numericMoveScoreOutputAllowed ||
      result.moveRankingOutputAllowed ||
      result.quietPreparatoryScopeActivated ||
      result.directEngineAccessUsed ||
      result.uiOutputUsed ||
      result.backendOutputUsed ||
      result.persistenceUsed ||
      result.outputContract.allowedOutputFieldIds.any(
        _isBlockedOutputFieldId,
      ) ||
      result.outputContract.contextOnlyOutputFieldIds.any(
        _isBlockedOutputFieldId,
      )) {
    return InternalEvidenceAdapterDesignStatus.blockedByPolicyBoundary;
  }
  if (!summaryResult.safeForPhase32M ||
      summaryResult.isStrictlyBlocked ||
      result.validationFindings.any((finding) => finding.blocksStrict)) {
    return InternalEvidenceAdapterDesignStatus.invalid;
  }
  if (result.adapterRecords.isEmpty) {
    return InternalEvidenceAdapterDesignStatus.invalid;
  }
  if (result.contextOnlyRecordCount > 0 || summaryResult.warnings.isNotEmpty) {
    return InternalEvidenceAdapterDesignStatus.designReadyWithWarnings;
  }
  return InternalEvidenceAdapterDesignStatus.designReadyClean;
}

InternalEvidenceAdapterPhase32NRecommendation _phase32NRecommendationFor({
  required InternalEvidenceAdapterDesignStatus status,
  required bool safeForPhase32N,
  required int ownerProofQueueCount,
  required int contextOnlyRecordCount,
}) {
  if (status == InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary ||
      status == InternalEvidenceAdapterDesignStatus.blockedByPolicyBoundary) {
    return InternalEvidenceAdapterPhase32NRecommendation
        .blockedByUnsafeAdapterDesign;
  }
  if (ownerProofQueueCount > 0) {
    return InternalEvidenceAdapterPhase32NRecommendation
        .runOwnerProofOnlyIfPvRequired;
  }
  if (!safeForPhase32N) {
    return InternalEvidenceAdapterPhase32NRecommendation
        .addMoreGoldenCoverageFirst;
  }
  if (contextOnlyRecordCount > 0) {
    return InternalEvidenceAdapterPhase32NRecommendation
        .proceedToInternalEvidenceAdapterPrototype;
  }
  return InternalEvidenceAdapterPhase32NRecommendation
      .proceedToAdapterDesignValidation;
}

InternalEvidenceAdapterInputStatus _inputStatusFor(
  InternalEvidenceSummaryGroupId groupId,
) {
  return switch (groupId) {
    InternalEvidenceSummaryGroupId.allowedEvidenceSummary ||
    InternalEvidenceSummaryGroupId.improvedSupportSummary =>
      InternalEvidenceAdapterInputStatus.coreAllowed,
    InternalEvidenceSummaryGroupId.constrainedWatchListSummary ||
    InternalEvidenceSummaryGroupId.proofLimitedSummary ||
    InternalEvidenceSummaryGroupId.warningLimitedSummary =>
      InternalEvidenceAdapterInputStatus.contextOnly,
    InternalEvidenceSummaryGroupId.blockedBoundarySummary =>
      InternalEvidenceAdapterInputStatus.blocked,
    InternalEvidenceSummaryGroupId.futureOnlySummary =>
      InternalEvidenceAdapterInputStatus.futureOnly,
  };
}

String _inputReasonFor(InternalEvidenceAdapterInputStatus status) {
  return switch (status) {
    InternalEvidenceAdapterInputStatus.coreAllowed =>
      'summary group is allowed for internal adapter core',
    InternalEvidenceAdapterInputStatus.contextOnly =>
      'summary group is constrained and may flow as internal context only',
    InternalEvidenceAdapterInputStatus.blocked =>
      'summary group is blocked and inactive for the adapter',
    InternalEvidenceAdapterInputStatus.futureOnly =>
      'summary group is future-only and inactive for the adapter',
    InternalEvidenceAdapterInputStatus.invalid =>
      'summary group is invalid for the adapter',
  };
}

InternalEvidenceAdapterRole _roleFor(InternalEvidenceSummaryGroupId groupId) {
  return switch (groupId) {
    InternalEvidenceSummaryGroupId.allowedEvidenceSummary ||
    InternalEvidenceSummaryGroupId.improvedSupportSummary =>
      InternalEvidenceAdapterRole.coreEvidence,
    InternalEvidenceSummaryGroupId.constrainedWatchListSummary ||
    InternalEvidenceSummaryGroupId.proofLimitedSummary ||
    InternalEvidenceSummaryGroupId.warningLimitedSummary =>
      InternalEvidenceAdapterRole.contextualConstraint,
    InternalEvidenceSummaryGroupId.blockedBoundarySummary =>
      InternalEvidenceAdapterRole.blockedBoundary,
    InternalEvidenceSummaryGroupId.futureOnlySummary =>
      InternalEvidenceAdapterRole.futureOnlyInput,
  };
}

InternalEvidenceAdapterRecordStatus _recordStatusFor(
  InternalEvidenceAdapterRole role,
  InternalEvidenceSummaryGroup group,
) {
  if (group.groupStatus.isUnsafe || group.hasUnsafeOutput) {
    return InternalEvidenceAdapterRecordStatus.unsafe;
  }
  return switch (role) {
    InternalEvidenceAdapterRole.coreEvidence =>
      InternalEvidenceAdapterRecordStatus.coreAdapterReady,
    InternalEvidenceAdapterRole.contextualConstraint =>
      InternalEvidenceAdapterRecordStatus.contextOnly,
    InternalEvidenceAdapterRole.blockedBoundary =>
      InternalEvidenceAdapterRecordStatus.blocked,
    InternalEvidenceAdapterRole.futureOnlyInput =>
      InternalEvidenceAdapterRecordStatus.futureOnly,
  };
}

InternalEvidenceAdapterRecommendation _recommendationFor(
  InternalEvidenceAdapterRole role,
  InternalEvidenceSummaryGroup group,
) {
  if (group.groupStatus.isUnsafe || group.hasUnsafeOutput) {
    return InternalEvidenceAdapterRecommendation.blockUnsafeDesign;
  }
  return switch (role) {
    InternalEvidenceAdapterRole.coreEvidence =>
      InternalEvidenceAdapterRecommendation.allowCoreAdapterDesign,
    InternalEvidenceAdapterRole.contextualConstraint =>
      InternalEvidenceAdapterRecommendation.allowContextOnly,
    InternalEvidenceAdapterRole.blockedBoundary =>
      InternalEvidenceAdapterRecommendation.keepBlocked,
    InternalEvidenceAdapterRole.futureOnlyInput =>
      InternalEvidenceAdapterRecommendation.keepFutureOnly,
  };
}

InternalEvidenceAdapterOutputContract _defaultOutputContract() {
  return const InternalEvidenceAdapterOutputContract(
    allowedOutputFieldIds: <String>[
      'adapterPacketId',
      'sourceSummaryGroupIds',
      'allowedEvidenceRecordIds',
      'supportCaseIds',
      'newlyAddedSupportCaseIds',
      'evidenceAreaIds',
      'bucketIds',
      'qualitativeConfidence',
      'internalWarnings',
      'internalConstraints',
      'futurePrerequisites',
    ],
    contextOnlyOutputFieldIds: <String>[
      'androidProofCaseIds',
      'proofLimitReason',
      'watchListReason',
      'warningLimitedReason',
    ],
    blockedOutputFieldIds: _blockedOutputFieldIds,
  );
}

void _checkAllowedField(
  void Function({
    required String id,
    required InternalEvidenceAdapterValidationSeverity severity,
    required String message,
    String? adapterRecordId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String fieldId, {
  String? adapterRecordId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_isBlockedOutputFieldId(fieldId)) return;
  add(
    id: 'blockedOutputFieldAllowed',
    severity: InternalEvidenceAdapterValidationSeverity.critical,
    message: '$fieldId cannot be an active adapter output field',
    adapterRecordId: adapterRecordId,
    groupId: groupId,
    fieldId: fieldId,
  );
  if (fieldId == 'productLabel') {
    add(
      id: 'productOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'product label output field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'finalMoveLabel' ||
      fieldId == 'brilliantGreatMissStyleLabels' ||
      fieldId == 'bestGoodInaccuracyMistakeBlunderStyleLabels') {
    add(
      id: 'classifierLabelOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'classifier or final label field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'numericMoveScore') {
    add(
      id: 'numericScoreOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'numeric move score field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'moveRanking') {
    add(
      id: 'moveRankingOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'move ranking field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'officialAccuracy' || fieldId == 'acpl') {
    add(
      id: 'officialMetricOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'official metric field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'cpLoss' || fieldId == 'winProbability') {
    add(
      id: 'futureMetricOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'future metric field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
  if (fieldId == 'uiOutputFields' ||
      fieldId == 'backendPersistenceFields' ||
      fieldId == 'directEngineCallFields') {
    add(
      id: 'integrationOutputFieldAllowed',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'integration output field cannot be active',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      fieldId: fieldId,
    );
  }
}

void _checkAndroidProofCase(
  void Function({
    required String id,
    required InternalEvidenceAdapterValidationSeverity severity,
    required String message,
    String? adapterRecordId,
    InternalEvidenceSummaryGroupId? groupId,
    String? fieldId,
    String? caseId,
  })
  add,
  String caseId,
  Set<String> provenAndroidIds, {
  String? adapterRecordId,
  InternalEvidenceSummaryGroupId? groupId,
}) {
  if (!_capturedAndroidProofIds.contains(caseId) ||
      !provenAndroidIds.contains(caseId)) {
    add(
      id: 'unprovenAndroidProofClaim',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'adapter design cited unproven Android proof',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      caseId: caseId,
    );
  }
  if (_phase32ECaseIds.contains(caseId)) {
    add(
      id: 'phase32ECaseClaimedCapturedProof',
      severity: InternalEvidenceAdapterValidationSeverity.critical,
      message: 'Phase 32E case cannot be captured Android proof',
      adapterRecordId: adapterRecordId,
      groupId: groupId,
      caseId: caseId,
    );
  }
}

bool _hasExplicitPvProofReason(InternalEvidenceAdapterDesignResult result) {
  final reasons = <String>[
    ...result.inputContractRecords.expand((record) => record.proofLimitReasons),
    ...result.inputContractRecords.expand((record) => record.warningReasons),
    ...result.inputContractRecords.expand(
      (record) => record.futurePrerequisites,
    ),
    ...result.adapterRecords.map((record) => record.proofLimitReason),
    ...result.adapterRecords.map((record) => record.warningReason),
    ...result.adapterRecords.map((record) => record.futurePrerequisite),
  ].join(' ').toLowerCase();
  return reasons.contains('pv') || reasons.contains('multipv');
}

Set<String> _provenAndroidProofIds(
  GoldenAndroidProofEvidence? androidProofEvidence,
) {
  final proofIds = androidProofEvidence?.targetCaseIds ?? const <String>[];
  return proofIds
      .where(
        (caseId) =>
            _capturedAndroidProofIds.contains(caseId) &&
            (androidProofEvidence?.isRealDeviceProofCapturedFor(
                  caseId,
                  minMultiPvLineCount: 1,
                  requirePv: true,
                ) ??
                false),
      )
      .toSet();
}

String _joinReasons(Iterable<String> values) {
  return _sortedStrings(values).join('; ');
}

String _adapterRecordIds(
  Iterable<InternalEvidenceAdapterDesignRecord> records,
) {
  return _ids(records.map((record) => record.adapterRecordId));
}

String _cell(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? '-' : normalized.replaceAll('|', '/');
}

String _ids(Iterable<String> values) {
  final ids = _sortedStrings(values);
  return ids.isEmpty ? '-' : ids.join(', ');
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.where((value) => value.isNotEmpty).toSet().toList()..sort();
}

List<InternalEvidenceAreaId> _sortedAreaIds(
  Iterable<InternalEvidenceAreaId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

List<InternalEvidenceBucketId> _sortedBucketIds(
  Iterable<InternalEvidenceBucketId> values,
) {
  return values.toSet().toList()..sort((a, b) => a.index.compareTo(b.index));
}

int _compareFindings(
  InternalEvidenceAdapterFinding a,
  InternalEvidenceAdapterFinding b,
) {
  final severityCompare = b.severity.index.compareTo(a.severity.index);
  if (severityCompare != 0) return severityCompare;
  final idCompare = a.id.compareTo(b.id);
  if (idCompare != 0) return idCompare;
  final recordCompare = (a.adapterRecordId ?? '').compareTo(
    b.adapterRecordId ?? '',
  );
  if (recordCompare != 0) return recordCompare;
  final groupCompare = (a.groupId?.wire ?? '').compareTo(b.groupId?.wire ?? '');
  if (groupCompare != 0) return groupCompare;
  final fieldCompare = (a.fieldId ?? '').compareTo(b.fieldId ?? '');
  if (fieldCompare != 0) return fieldCompare;
  return (a.caseId ?? '').compareTo(b.caseId ?? '');
}

bool _isBlockedOutputFieldId(String value) {
  return _blockedOutputFieldIds.contains(value);
}

const _contextOnlyGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
  InternalEvidenceSummaryGroupId.proofLimitedSummary,
  InternalEvidenceSummaryGroupId.warningLimitedSummary,
};

const _blockedGroupIds = <InternalEvidenceSummaryGroupId>{
  InternalEvidenceSummaryGroupId.blockedBoundarySummary,
};

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  'pv-multipv-support-boundary-32e',
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _blockedOutputFieldIds = <String>[
  'productLabel',
  'finalMoveLabel',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'numericMoveScore',
  'officialAccuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];
