import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_diagnostic_action_plan.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion =
    'debug-only-bridge-analyzer-adapter-prototype-diagnostic-command-v1';

const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection {
  all('all'),
  snapshot('snapshot'),
  packets('packets'),
  policy('policy'),
  records('records'),
  proof('proof'),
  boundaries('boundaries'),
  runtime('runtime'),
  recommendation('recommendation'),
  actionPlan('action-plan'),
  patches('patches'),
  metadataRefinement('metadata-refinement'),
  runtimePreparation('runtime-preparation'),
  disabledRuntimeSkeleton('disabled-runtime-skeleton'),
  runtimeExecutionPreflight('runtime-execution-preflight'),
  golden('golden');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus {
  prototypeDiagnosticCommandReadyWithWarnings(
    'prototypeDiagnosticCommandReadyWithWarnings',
  ),
  prototypeDiagnosticCommandReadyClean('prototypeDiagnosticCommandReadyClean'),
  blockedByUnsafeInspectionHarnessValidation(
    'blockedByUnsafeInspectionHarnessValidation',
  ),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidPrototypeDiagnosticCommand('invalidPrototypeDiagnosticCommand');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus(this.wire);

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus {
  selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyWithWarnings(
    'selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyWithWarnings',
  ),
  selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyClean(
    'selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyClean',
  ),
  blockedByUnsafeGoldenSelection('blockedByUnsafeGoldenSelection'),
  blockedByPolicyBoundary('blockedByPolicyBoundary'),
  invalidGoldenSelection('invalidGoldenSelection');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole {
  developerDiagnosticInputSupport('developerDiagnosticInputSupport'),
  contextOnly('contextOnly'),
  warningLimited('warningLimited'),
  proofBoundaryOnly('proofBoundaryOnly'),
  excludedNegativeGuard('excludedNegativeGuard');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRow {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRow({
    required this.caseId,
    required this.title,
    required this.sourcePhase,
    required this.selectedReason,
    required this.diagnosticRole,
    required this.supportAreaIds,
    required this.warningReasons,
    required this.proofLimitReasons,
    required this.androidProofIds,
    required this.ownerProofRequired,
    required this.activeDeniedFieldIds,
    required this.blockedBoundaryIds,
    required this.recommendation,
  });

  final String caseId;
  final String title;
  final String sourcePhase;
  final String selectedReason;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
  diagnosticRole;
  final List<String> supportAreaIds;
  final List<String> warningReasons;
  final List<String> proofLimitReasons;
  final List<String> androidProofIds;
  final bool ownerProofRequired;
  final List<String> activeDeniedFieldIds;
  final List<String> blockedBoundaryIds;
  final String recommendation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'caseId': caseId,
      'title': title,
      'sourcePhase': sourcePhase,
      'selectedReason': selectedReason,
      'diagnosticRole': diagnosticRole.wire,
      'supportAreaIds': supportAreaIds,
      'warningReasons': warningReasons,
      'proofLimitReasons': proofLimitReasons,
      'androidProofIds': androidProofIds,
      'ownerProofRequired': ownerProofRequired,
      'activeDeniedFieldIds': activeDeniedFieldIds,
      'blockedBoundaryIds': blockedBoundaryIds,
      'recommendation': recommendation,
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult({
    required this.selection,
    required this.rows,
    required this.sourceDiagnostic,
  }) : activeDeniedFieldCount = rows.fold<int>(
         0,
         (total, row) => total + row.activeDeniedFieldIds.length,
       ),
       unprovenAndroidProofCount = rows
           .where(
             (row) => row.androidProofIds.any(
               (caseId) => !_capturedAndroidProofIds.contains(caseId),
             ),
           )
           .length,
       phase32EProofClaimCount = rows
           .where((row) => row.androidProofIds.any(_phase32ECaseIds.contains))
           .length,
       quietPreparatoryPromotionCount = rows
           .where(
             (row) =>
                 row.diagnosticRole ==
                     DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
                         .developerDiagnosticInputSupport &&
                 (row.supportAreaIds.contains('quietMove') ||
                     row.supportAreaIds.contains('quietPreparatoryMove')),
           )
           .length,
       pvMultiPvPromotionCount = rows
           .where(
             (row) =>
                 row.caseId == _pvMultiPvBoundaryCaseId &&
                 row.diagnosticRole !=
                     DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
                         .proofBoundaryOnly,
           )
           .length,
       ownerProofQueueCount = rows
           .where((row) => row.ownerProofRequired)
           .length {
    final hasPolicyLeak =
        !sourceDiagnostic.safeForPhase33Z ||
        sourceDiagnostic.hasUnsafePolicyViolation ||
        activeDeniedFieldCount > 0 ||
        unprovenAndroidProofCount > 0 ||
        phase32EProofClaimCount > 0 ||
        quietPreparatoryPromotionCount > 0 ||
        pvMultiPvPromotionCount > 0 ||
        ownerProofQueueCount > 0;
    safeForPhase34A = !hasPolicyLeak;
    nextRecommendation = _phase34ARecommendation;
    productOutputCount = 0;
    labelLeakCount = 0;
    finalLabelLeakCount = 0;
    scoreLeakCount = 0;
    metricLeakCount = 0;
    cpLossLeakCount = 0;
    winProbabilityLeakCount = 0;
    moveRankingLeakCount = 0;
    thresholdLeakCount = 0;
    uiTargetCount = 0;
    backendTargetCount = 0;
    persistenceWriteCount = 0;
    engineCallCount = 0;
    schedulerExecutionCount = 0;
    analyzerWiringCount = 0;
    runtimeImplementationCount = 0;
    executablePrototypeCount = 0;
    productAdapterBehaviorCount = 0;
    savedAnalysisIntegrationCount = 0;
    stockfishCommandLeakCount = 0;
    rawUciLeakCount = 0;
    pvDumpLeakCount = 0;
    androidCollectorRequirementCount = 0;
    blockerCount = hasPolicyLeak ? 1 : 0;
    criticalCount = 0;
    unsafeCount = hasPolicyLeak ? 1 : 0;
    status = hasPolicyLeak
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus
              .blockedByUnsafeGoldenSelection
        : rows.any(
            (row) =>
                row.warningReasons.isNotEmpty ||
                row.proofLimitReasons.isNotEmpty,
          )
        ? DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus
              .selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyWithWarnings
        : DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus
              .selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyClean;
  }

  final String selection;
  final List<DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRow>
  rows;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult
  sourceDiagnostic;
  late final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus
  status;
  late final bool safeForPhase34A;
  late final String nextRecommendation;
  late final int blockerCount;
  late final int criticalCount;
  late final int unsafeCount;
  final int activeDeniedFieldCount;
  late final int productOutputCount;
  late final int labelLeakCount;
  late final int finalLabelLeakCount;
  late final int scoreLeakCount;
  late final int metricLeakCount;
  late final int cpLossLeakCount;
  late final int winProbabilityLeakCount;
  late final int moveRankingLeakCount;
  late final int thresholdLeakCount;
  late final int uiTargetCount;
  late final int backendTargetCount;
  late final int persistenceWriteCount;
  late final int engineCallCount;
  late final int schedulerExecutionCount;
  late final int analyzerWiringCount;
  late final int runtimeImplementationCount;
  late final int executablePrototypeCount;
  late final int productAdapterBehaviorCount;
  late final int savedAnalysisIntegrationCount;
  late final int stockfishCommandLeakCount;
  late final int rawUciLeakCount;
  late final int pvDumpLeakCount;
  late final int androidCollectorRequirementCount;
  final int unprovenAndroidProofCount;
  final int phase32EProofClaimCount;
  final int quietPreparatoryPromotionCount;
  final int pvMultiPvPromotionCount;
  final int ownerProofQueueCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase34A ||
      nextRecommendation != _phase34ARecommendation ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      unsafeCount > 0 ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      labelLeakCount > 0 ||
      finalLabelLeakCount > 0 ||
      scoreLeakCount > 0 ||
      metricLeakCount > 0 ||
      cpLossLeakCount > 0 ||
      winProbabilityLeakCount > 0 ||
      moveRankingLeakCount > 0 ||
      thresholdLeakCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      persistenceWriteCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      analyzerWiringCount > 0 ||
      runtimeImplementationCount > 0 ||
      executablePrototypeCount > 0 ||
      productAdapterBehaviorCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      stockfishCommandLeakCount > 0 ||
      rawUciLeakCount > 0 ||
      pvDumpLeakCount > 0 ||
      androidCollectorRequirementCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      phase32EProofClaimCount > 0 ||
      quietPreparatoryPromotionCount > 0 ||
      pvMultiPvPromotionCount > 0 ||
      ownerProofQueueCount > 0;

  bool get hasStrictBlocker => hasUnsafePolicyViolation;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'selection': selection,
      'status': status.wire,
      'safeForPhase34A': safeForPhase34A,
      'safeForNextStep': safeForPhase34A,
      'nextRecommendation': nextRecommendation,
      'counts': <String, Object?>{
        'selectedRowCount': rows.length,
        'blockerCount': blockerCount,
        'criticalCount': criticalCount,
        'unsafeCount': unsafeCount,
        'analyzerWiringCount': analyzerWiringCount,
        'runtimeImplementationCount': runtimeImplementationCount,
        'executablePrototypeCount': executablePrototypeCount,
        'engineCallCount': engineCallCount,
        'schedulerExecutionCount': schedulerExecutionCount,
        'persistenceWriteCount': persistenceWriteCount,
        'productOutputCount': productOutputCount,
        'activeDeniedFieldCount': activeDeniedFieldCount,
        'labelLeakCount': labelLeakCount,
        'finalLabelLeakCount': finalLabelLeakCount,
        'scoreLeakCount': scoreLeakCount,
        'metricLeakCount': metricLeakCount,
        'cpLossLeakCount': cpLossLeakCount,
        'winProbabilityLeakCount': winProbabilityLeakCount,
        'moveRankingLeakCount': moveRankingLeakCount,
        'thresholdLeakCount': thresholdLeakCount,
        'uiTargetCount': uiTargetCount,
        'backendTargetCount': backendTargetCount,
        'productAdapterBehaviorCount': productAdapterBehaviorCount,
        'savedAnalysisIntegrationCount': savedAnalysisIntegrationCount,
        'stockfishCommandLeakCount': stockfishCommandLeakCount,
        'rawUciLeakCount': rawUciLeakCount,
        'pvDumpLeakCount': pvDumpLeakCount,
        'androidCollectorRequirementCount': androidCollectorRequirementCount,
        'unprovenAndroidProofCount': unprovenAndroidProofCount,
        'phase32EProofClaimCount': phase32EProofClaimCount,
        'quietPreparatoryPromotionCount': quietPreparatoryPromotionCount,
        'pvMultiPvPromotionCount': pvMultiPvPromotionCount,
        'ownerProofQueueCount': ownerProofQueueCount,
      },
      'rows': rows.map((row) => row.toJson()).toList(growable: false),
    };
  }
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult({
    required this.exitCode,
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.goldenCaseSelection,
    this.patchDiagnosticMode,
    this.refinementDiagnosticMode,
    this.runtimePreparationDiagnosticMode,
    this.disabledRuntimeSkeletonDiagnosticMode,
    this.listGoldenCases = false,
    this.diagnosticResult,
    this.selectedGoldenDiagnostic,
    this.patchSetDiagnostic,
    this.metadataRefinement,
    this.metadataRefinementDiagnostic,
    this.runtimePreparation,
    this.runtimePreparationDiagnostic,
    this.disabledRuntimeSkeleton,
    this.disabledRuntimeSkeletonDiagnostic,
    this.runtimeExecutionPreflight,
    this.runtimeExecutionPreflightDiagnosticMode,
    this.runtimeExecutionPreflightDiagnostic,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final String? goldenCaseSelection;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode?
  patchDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode?
  refinementDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode?
  runtimePreparationDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode?
  disabledRuntimeSkeletonDiagnosticMode;
  final bool listGoldenCases;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult?
  diagnosticResult;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult?
  selectedGoldenDiagnostic;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult?
  patchSetDiagnostic;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult?
  metadataRefinement;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
  metadataRefinementDiagnostic;
  final ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparation;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
  runtimePreparationDiagnostic;
  final DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeleton;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
  disabledRuntimeSkeletonDiagnostic;
  final ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
  runtimeExecutionPreflight;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode?
  runtimeExecutionPreflightDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
  runtimeExecutionPreflightDiagnostic;
  final String? commandFailure;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.valid({
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.goldenCaseSelection,
    this.patchDiagnosticMode,
    this.refinementDiagnosticMode,
    this.runtimePreparationDiagnosticMode,
    this.disabledRuntimeSkeletonDiagnosticMode,
    this.runtimeExecutionPreflightDiagnosticMode,
    this.listGoldenCases = false,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown,
      section = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      goldenCaseSelection = null,
      patchDiagnosticMode = null,
      refinementDiagnosticMode = null,
      runtimePreparationDiagnosticMode = null,
      disabledRuntimeSkeletonDiagnosticMode = null,
      runtimeExecutionPreflightDiagnosticMode = null,
      listGoldenCases = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String? goldenCaseSelection;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode?
  patchDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode?
  refinementDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode?
  runtimePreparationDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode?
  disabledRuntimeSkeletonDiagnosticMode;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode?
  runtimeExecutionPreflightDiagnosticMode;
  final bool listGoldenCases;
  final bool showHelp;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult {
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult({
    required this.validationResult,
    required this.harnessResult,
  }) : status = _diagnosticStatus(validationResult, harnessResult),
       safeForPhase33Z =
           validationResult.safeForPhase33Y &&
           validationResult.phase33YRecommendation == _phase33YRequirement &&
           !validationResult.hasUnsafePolicyViolation &&
           harnessResult.safeForPhase33X &&
           harnessResult.phase33XRecommendation == _phase33XRequirement &&
           !harnessResult.hasUnsafePolicyViolation,
       nextRecommendation = _phase33ZRecommendation,
       unsafeCount =
           validationResult.unsafeCount +
           (harnessResult.unsafeCount > 0 ? 1 : 0),
       blockerCount =
           validationResult.blockerCount +
           (harnessResult.blockerCount > 0 ? 1 : 0),
       criticalCount =
           validationResult.criticalCount +
           (harnessResult.criticalCount > 0 ? 1 : 0),
       analyzerWiringCount =
           validationResult.analyzerWiringCount +
           harnessResult.analyzerWiringCount,
       runtimeImplementationCount =
           validationResult.runtimeImplementationCount +
           harnessResult.runtimeImplementationCount,
       executablePrototypeCount =
           validationResult.executablePrototypeCount +
           harnessResult.executablePrototypeCount,
       engineCallCount =
           validationResult.engineCallCount + harnessResult.engineCallCount,
       schedulerExecutionCount =
           validationResult.schedulerExecutionCount +
           harnessResult.schedulerExecutionCount,
       persistenceWriteCount =
           validationResult.persistenceWriteCount +
           harnessResult.persistenceWriteCount,
       productOutputCount =
           validationResult.productOutputCount +
           harnessResult.productOutputCount,
       activeDeniedFieldCount =
           validationResult.activeDeniedFieldCount +
           harnessResult.activeDeniedFieldCount,
       labelLeakCount =
           validationResult.labelLeakCount + harnessResult.labelLeakCount,
       finalLabelLeakCount =
           validationResult.finalLabelLeakCount +
           harnessResult.finalLabelLeakCount,
       scoreLeakCount =
           validationResult.scoreLeakCount + harnessResult.scoreLeakCount,
       metricLeakCount =
           validationResult.metricLeakCount + harnessResult.metricLeakCount,
       cpLossLeakCount =
           validationResult.cpLossLeakCount + harnessResult.cpLossLeakCount,
       winProbabilityLeakCount =
           validationResult.winProbabilityLeakCount +
           harnessResult.winProbabilityLeakCount,
       moveRankingLeakCount =
           validationResult.moveRankingLeakCount +
           harnessResult.moveRankingLeakCount,
       thresholdLeakCount =
           validationResult.thresholdLeakCount +
           harnessResult.thresholdLeakCount,
       uiTargetCount =
           validationResult.uiTargetCount + harnessResult.uiTargetCount,
       backendTargetCount =
           validationResult.backendTargetCount +
           harnessResult.backendTargetCount,
       stockfishCommandLeakCount =
           validationResult.stockfishCommandLeakCount +
           harnessResult.stockfishCommandLeakCount,
       rawUciLeakCount =
           validationResult.rawUciLeakCount + harnessResult.rawUciLeakCount,
       pvDumpLeakCount =
           validationResult.pvDumpLeakCount + harnessResult.pvDumpLeakCount,
       androidCollectorRequirementCount =
           validationResult.androidCollectorRequirementCount +
           harnessResult.androidCollectorRequirementCount,
       unprovenAndroidProofCount =
           validationResult.unprovenAndroidProofCount +
           harnessResult.unprovenAndroidProofCount,
       phase32EProofClaimCount =
           validationResult.phase32EProofClaimCount +
           harnessResult.phase32EProofClaimCount,
       productAdapterBehaviorCount =
           validationResult.productAdapterBehaviorCount +
           harnessResult.productAdapterBehaviorCount,
       savedAnalysisIntegrationCount =
           validationResult.savedAnalysisIntegrationCount +
           harnessResult.savedAnalysisIntegrationCount,
       ownerProofQueueCount =
           validationResult.ownerProofQueueCount +
           harnessResult.ownerProofQueueCount;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
  validationResult;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult harnessResult;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus status;
  final bool safeForPhase33Z;
  final String nextRecommendation;
  final int unsafeCount;
  final int blockerCount;
  final int criticalCount;
  final int analyzerWiringCount;
  final int runtimeImplementationCount;
  final int executablePrototypeCount;
  final int engineCallCount;
  final int schedulerExecutionCount;
  final int persistenceWriteCount;
  final int productOutputCount;
  final int activeDeniedFieldCount;
  final int labelLeakCount;
  final int finalLabelLeakCount;
  final int scoreLeakCount;
  final int metricLeakCount;
  final int cpLossLeakCount;
  final int winProbabilityLeakCount;
  final int moveRankingLeakCount;
  final int thresholdLeakCount;
  final int uiTargetCount;
  final int backendTargetCount;
  final int stockfishCommandLeakCount;
  final int rawUciLeakCount;
  final int pvDumpLeakCount;
  final int androidCollectorRequirementCount;
  final int unprovenAndroidProofCount;
  final int phase32EProofClaimCount;
  final int productAdapterBehaviorCount;
  final int savedAnalysisIntegrationCount;
  final int ownerProofQueueCount;

  bool get hasUnsafePolicyViolation =>
      !safeForPhase33Z ||
      validationResult.hasUnsafePolicyViolation ||
      harnessResult.hasUnsafePolicyViolation ||
      nextRecommendation != _phase33ZRecommendation ||
      unsafeCount > 0 ||
      blockerCount > 0 ||
      criticalCount > 0 ||
      activeDeniedFieldCount > 0 ||
      productOutputCount > 0 ||
      labelLeakCount > 0 ||
      finalLabelLeakCount > 0 ||
      scoreLeakCount > 0 ||
      metricLeakCount > 0 ||
      cpLossLeakCount > 0 ||
      winProbabilityLeakCount > 0 ||
      moveRankingLeakCount > 0 ||
      thresholdLeakCount > 0 ||
      uiTargetCount > 0 ||
      backendTargetCount > 0 ||
      persistenceWriteCount > 0 ||
      engineCallCount > 0 ||
      schedulerExecutionCount > 0 ||
      analyzerWiringCount > 0 ||
      runtimeImplementationCount > 0 ||
      executablePrototypeCount > 0 ||
      productAdapterBehaviorCount > 0 ||
      savedAnalysisIntegrationCount > 0 ||
      stockfishCommandLeakCount > 0 ||
      rawUciLeakCount > 0 ||
      pvDumpLeakCount > 0 ||
      androidCollectorRequirementCount > 0 ||
      unprovenAndroidProofCount > 0 ||
      phase32EProofClaimCount > 0 ||
      ownerProofQueueCount > 0;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand(
    args: args,
  );
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness harness =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness(),
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation
      validation =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation(),
}) {
  final request = validateDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticArgs(
    args,
  );
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      goldenCaseSelection: request.goldenCaseSelection,
      patchDiagnosticMode: request.patchDiagnosticMode,
      refinementDiagnosticMode: request.refinementDiagnosticMode,
      runtimePreparationDiagnosticMode:
          request.runtimePreparationDiagnosticMode,
      disabledRuntimeSkeletonDiagnosticMode:
          request.disabledRuntimeSkeletonDiagnosticMode,
      runtimeExecutionPreflightDiagnosticMode:
          request.runtimeExecutionPreflightDiagnosticMode,
      listGoldenCases: request.listGoldenCases,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      goldenCaseSelection: request.goldenCaseSelection,
      patchDiagnosticMode: request.patchDiagnosticMode,
      refinementDiagnosticMode: request.refinementDiagnosticMode,
      runtimePreparationDiagnosticMode:
          request.runtimePreparationDiagnosticMode,
      disabledRuntimeSkeletonDiagnosticMode:
          request.disabledRuntimeSkeletonDiagnosticMode,
      runtimeExecutionPreflightDiagnosticMode:
          request.runtimeExecutionPreflightDiagnosticMode,
      listGoldenCases: request.listGoldenCases,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  if (request.listGoldenCases) {
    final stdoutText = switch (request.format) {
      DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown =>
        _renderGoldenCaseListMarkdown(cases),
      DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.json =>
        '${_renderGoldenCaseListJson(cases)}\n',
    };
    final reportFindings =
        const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator()
            .validateReportText(stdoutText);
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
      exitCode: reportFindings.any(_isCriticalFinding)
          ? debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUnsafePolicy
          : debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      goldenCaseSelection: request.goldenCaseSelection,
      patchDiagnosticMode: request.patchDiagnosticMode,
      refinementDiagnosticMode: request.refinementDiagnosticMode,
      runtimePreparationDiagnosticMode:
          request.runtimePreparationDiagnosticMode,
      disabledRuntimeSkeletonDiagnosticMode:
          request.disabledRuntimeSkeletonDiagnosticMode,
      runtimeExecutionPreflightDiagnosticMode:
          request.runtimeExecutionPreflightDiagnosticMode,
      listGoldenCases: true,
      stdoutText: stdoutText,
      stderrText: '',
    );
  }

  final harnessResult = harness.inspectSafeDemo();
  final validationResult = validation.evaluate(harnessResult: harnessResult);
  final diagnostic = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult(
    validationResult: validationResult,
    harnessResult: harnessResult,
  );
  final selectedGoldenBuildResult = _buildSelectedGoldenDiagnosticIfRequested(
    request,
    cases,
    diagnostic,
  );
  if (selectedGoldenBuildResult.failure != null) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      goldenCaseSelection: request.goldenCaseSelection,
      patchDiagnosticMode: request.patchDiagnosticMode,
      refinementDiagnosticMode: request.refinementDiagnosticMode,
      runtimePreparationDiagnosticMode:
          request.runtimePreparationDiagnosticMode,
      disabledRuntimeSkeletonDiagnosticMode:
          request.disabledRuntimeSkeletonDiagnosticMode,
      runtimeExecutionPreflightDiagnosticMode:
          request.runtimeExecutionPreflightDiagnosticMode,
      listGoldenCases: request.listGoldenCases,
      stdoutText: '',
      stderrText: _usage(selectedGoldenBuildResult.failure!),
      commandFailure: selectedGoldenBuildResult.failure,
    );
  }
  final selectedGoldenDiagnostic = selectedGoldenBuildResult.result;
  final patchSetDiagnostic = request.patchDiagnosticMode == null
      ? null
      : const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic()
            .evaluate(mode: request.patchDiagnosticMode!);
  final metadataRefinement =
      _includeSection(
            request.section,
            DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
                .metadataRefinement,
          ) ||
          request.refinementDiagnosticMode != null
      ? const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
            .evaluate()
      : null;
  final metadataRefinementDiagnostic = request.refinementDiagnosticMode == null
      ? null
      : const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
            .evaluate(mode: request.refinementDiagnosticMode!);
  final includeRuntimeExecutionPreflight =
      _includeSection(
        request.section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .runtimeExecutionPreflight,
      ) ||
      request.runtimeExecutionPreflightDiagnosticMode != null;
  final includeDisabledRuntimeSkeleton =
      _includeSection(
        request.section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .disabledRuntimeSkeleton,
      ) ||
      request.disabledRuntimeSkeletonDiagnosticMode != null ||
      includeRuntimeExecutionPreflight;
  final includeRuntimePreparation =
      _includeSection(
        request.section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .runtimePreparation,
      ) ||
      request.runtimePreparationDiagnosticMode != null ||
      includeDisabledRuntimeSkeleton;
  final runtimePreparation = includeRuntimePreparation
      ? const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
            .evaluate()
      : null;
  final runtimePreparationDiagnostic =
      request.runtimePreparationDiagnosticMode == null &&
          !includeDisabledRuntimeSkeleton
      ? null
      : const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
            .evaluate(
              runtimePreparationResult: runtimePreparation,
              mode:
                  request.runtimePreparationDiagnosticMode ??
                  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                      .defaultMode,
            );
  final disabledRuntimeSkeleton = includeDisabledRuntimeSkeleton
      ? const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton().evaluate(
          runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
          runtimePreparationResult: runtimePreparation,
        )
      : null;
  final disabledRuntimeSkeletonDiagnostic =
      request.disabledRuntimeSkeletonDiagnosticMode == null &&
          !includeRuntimeExecutionPreflight
      ? null
      : const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
            .evaluate(
              skeletonResult: disabledRuntimeSkeleton,
              runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
              runtimePreparationResult: runtimePreparation,
              mode:
                  request.disabledRuntimeSkeletonDiagnosticMode ??
                  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
                      .defaultMode,
            );
  final runtimeExecutionPreflight = includeRuntimeExecutionPreflight
      ? const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
            .evaluate(
              disabledRuntimeSkeletonDiagnosticResult:
                  disabledRuntimeSkeletonDiagnostic,
              disabledRuntimeSkeletonResult: disabledRuntimeSkeleton,
              runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
              runtimePreparationResult: runtimePreparation,
            )
      : null;
  final runtimeExecutionPreflightDiagnostic =
      request.runtimeExecutionPreflightDiagnosticMode == null
      ? null
      : const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
            .evaluate(
              runtimeExecutionPreflightResult: runtimeExecutionPreflight,
              disabledRuntimeSkeletonDiagnosticResult:
                  disabledRuntimeSkeletonDiagnostic,
              disabledRuntimeSkeletonResult: disabledRuntimeSkeleton,
              runtimePreparationDiagnosticResult: runtimePreparationDiagnostic,
              runtimePreparationResult: runtimePreparation,
              mode: request.runtimeExecutionPreflightDiagnosticMode!,
            );
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown =>
      _renderMarkdown(
        diagnostic,
        request.section,
        selectedGoldenDiagnostic: selectedGoldenDiagnostic,
        patchSetDiagnostic: patchSetDiagnostic,
        metadataRefinement: metadataRefinement,
        metadataRefinementDiagnostic: metadataRefinementDiagnostic,
        runtimePreparation: runtimePreparation,
        runtimePreparationDiagnostic: runtimePreparationDiagnostic,
        disabledRuntimeSkeleton: disabledRuntimeSkeleton,
        disabledRuntimeSkeletonDiagnostic: disabledRuntimeSkeletonDiagnostic,
        runtimeExecutionPreflight: runtimeExecutionPreflight,
        runtimeExecutionPreflightDiagnostic:
            runtimeExecutionPreflightDiagnostic,
      ),
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.json =>
      '${_renderJson(diagnostic, request.section, selectedGoldenDiagnostic: selectedGoldenDiagnostic, patchSetDiagnostic: patchSetDiagnostic, metadataRefinement: metadataRefinement, metadataRefinementDiagnostic: metadataRefinementDiagnostic, runtimePreparation: runtimePreparation, runtimePreparationDiagnostic: runtimePreparationDiagnostic, disabledRuntimeSkeleton: disabledRuntimeSkeleton, disabledRuntimeSkeletonDiagnostic: disabledRuntimeSkeletonDiagnostic, runtimeExecutionPreflight: runtimeExecutionPreflight, runtimeExecutionPreflightDiagnostic: runtimeExecutionPreflightDiagnostic)}\n',
  };
  final reportFindings = <String>[
    ...const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator()
        .validateReportText(stdoutText),
    if (patchSetDiagnostic != null)
      ...const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator()
          .validateReportText(stdoutText),
    if (metadataRefinement != null)
      ...const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator()
          .validateReportText(stdoutText),
    if (metadataRefinementDiagnostic != null)
      ...const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator()
          .validateReportText(stdoutText),
    if (runtimePreparation != null)
      ...const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator()
          .validateReportText(stdoutText),
    if (runtimePreparationDiagnostic != null)
      ...const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticValidator()
          .validateReportText(stdoutText),
    if (disabledRuntimeSkeleton != null)
      ...const DisabledAnalyzerAdapterRuntimeSkeletonValidator()
          .validateReportText(stdoutText),
    if (disabledRuntimeSkeletonDiagnostic != null)
      ...const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticValidator()
          .validateReportText(stdoutText),
    if (runtimeExecutionPreflight != null)
      ...const ControlledAnalyzerAdapterRuntimeExecutionPreflightValidator()
          .validateReportText(stdoutText),
    if (runtimeExecutionPreflightDiagnostic != null)
      ...const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticValidator()
          .validateReportText(stdoutText),
  ];

  return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult(
    exitCode: debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitCode(
      diagnostic,
      request,
      reportFindings: reportFindings,
      selectedGoldenDiagnostic: selectedGoldenDiagnostic,
      patchSetDiagnostic: patchSetDiagnostic,
      metadataRefinement: metadataRefinement,
      metadataRefinementDiagnostic: metadataRefinementDiagnostic,
      runtimePreparation: runtimePreparation,
      runtimePreparationDiagnostic: runtimePreparationDiagnostic,
      disabledRuntimeSkeleton: disabledRuntimeSkeleton,
      disabledRuntimeSkeletonDiagnostic: disabledRuntimeSkeletonDiagnostic,
      runtimeExecutionPreflight: runtimeExecutionPreflight,
      runtimeExecutionPreflightDiagnostic: runtimeExecutionPreflightDiagnostic,
    ),
    format: request.format,
    section: request.section,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    goldenCaseSelection: request.goldenCaseSelection,
    patchDiagnosticMode: request.patchDiagnosticMode,
    refinementDiagnosticMode: request.refinementDiagnosticMode,
    runtimePreparationDiagnosticMode: request.runtimePreparationDiagnosticMode,
    disabledRuntimeSkeletonDiagnosticMode:
        request.disabledRuntimeSkeletonDiagnosticMode,
    runtimeExecutionPreflightDiagnosticMode:
        request.runtimeExecutionPreflightDiagnosticMode,
    runtimeExecutionPreflightDiagnostic: runtimeExecutionPreflightDiagnostic,
    listGoldenCases: request.listGoldenCases,
    stdoutText: stdoutText,
    stderrText: '',
    diagnosticResult: diagnostic,
    selectedGoldenDiagnostic: selectedGoldenDiagnostic,
    patchSetDiagnostic: patchSetDiagnostic,
    metadataRefinement: metadataRefinement,
    metadataRefinementDiagnostic: metadataRefinementDiagnostic,
    runtimePreparation: runtimePreparation,
    runtimePreparationDiagnostic: runtimePreparationDiagnostic,
    disabledRuntimeSkeleton: disabledRuntimeSkeleton,
    disabledRuntimeSkeletonDiagnostic: disabledRuntimeSkeletonDiagnostic,
    runtimeExecutionPreflight: runtimeExecutionPreflight,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest
validateDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticArgs(
  List<String> args,
) {
  var format = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown;
  var section = DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var sectionSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;
  var goldenCaseSelectionSeen = false;
  var patchDiagnosticSeen = false;
  var refinementDiagnosticSeen = false;
  var runtimePreparationDiagnosticSeen = false;
  var disabledRuntimeSkeletonDiagnosticSeen = false;
  var runtimeExecutionPreflightDiagnosticSeen = false;
  var listGoldenCasesSeen = false;
  String? goldenCaseSelection;
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode?
  patchDiagnosticMode;
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode?
  refinementDiagnosticMode;
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode?
  runtimePreparationDiagnosticMode;
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode?
  disabledRuntimeSkeletonDiagnosticMode;
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode?
  runtimeExecutionPreflightDiagnosticMode;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown,
        section: DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        goldenCaseSelection: null,
        patchDiagnosticMode: null,
        refinementDiagnosticMode: null,
        runtimePreparationDiagnosticMode: null,
        disabledRuntimeSkeletonDiagnosticMode: null,
        runtimeExecutionPreflightDiagnosticMode: null,
        listGoldenCases: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_sectionFlag)) {
      if (sectionSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateSection',
        );
      }
      final parsed = _sectionByWire(arg.substring(_sectionFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownSection',
        );
      }
      section = parsed;
      sectionSeen = true;
      continue;
    }
    if (arg.startsWith(_goldenCaseFlag)) {
      if (goldenCaseSelectionSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateGoldenCase',
        );
      }
      goldenCaseSelection = arg.substring(_goldenCaseFlag.length).trim();
      if (goldenCaseSelection.isEmpty) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'emptyGoldenCase',
        );
      }
      goldenCaseSelectionSeen = true;
      continue;
    }
    if (arg.startsWith(_patchDiagnosticFlag)) {
      if (patchDiagnosticSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicatePatchDiagnostic',
        );
      }
      final parsed = _patchDiagnosticModeByWire(
        arg.substring(_patchDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownPatchDiagnostic',
        );
      }
      patchDiagnosticMode = parsed;
      patchDiagnosticSeen = true;
      continue;
    }
    if (arg.startsWith(_refinementDiagnosticFlag)) {
      if (refinementDiagnosticSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateRefinementDiagnostic',
        );
      }
      final parsed = _refinementDiagnosticModeByWire(
        arg.substring(_refinementDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownRefinementDiagnostic',
        );
      }
      refinementDiagnosticMode = parsed;
      refinementDiagnosticSeen = true;
      continue;
    }
    if (arg.startsWith(_runtimePreparationDiagnosticFlag)) {
      if (runtimePreparationDiagnosticSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateRuntimePreparationDiagnostic',
        );
      }
      final parsed = _runtimePreparationDiagnosticModeByWire(
        arg.substring(_runtimePreparationDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownRuntimePreparationDiagnostic',
        );
      }
      runtimePreparationDiagnosticMode = parsed;
      runtimePreparationDiagnosticSeen = true;
      continue;
    }
    if (arg.startsWith(_disabledRuntimeSkeletonDiagnosticFlag)) {
      if (disabledRuntimeSkeletonDiagnosticSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateDisabledRuntimeSkeletonDiagnostic',
        );
      }
      final parsed = _disabledRuntimeSkeletonDiagnosticModeByWire(
        arg.substring(_disabledRuntimeSkeletonDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownDisabledRuntimeSkeletonDiagnostic',
        );
      }
      disabledRuntimeSkeletonDiagnosticMode = parsed;
      disabledRuntimeSkeletonDiagnosticSeen = true;
      continue;
    }
    if (arg.startsWith(_runtimeExecutionPreflightDiagnosticFlag)) {
      if (runtimeExecutionPreflightDiagnosticSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateRuntimeExecutionPreflightDiagnostic',
        );
      }
      final parsed = _runtimeExecutionPreflightDiagnosticModeByWire(
        arg.substring(_runtimeExecutionPreflightDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'unknownRuntimeExecutionPreflightDiagnostic',
        );
      }
      runtimeExecutionPreflightDiagnosticMode = parsed;
      runtimeExecutionPreflightDiagnosticSeen = true;
      continue;
    }
    if (arg == _listGoldenCasesFlag) {
      if (listGoldenCasesSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateListGoldenCases',
        );
      }
      listGoldenCasesSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    if (arg == _safeDemoFlag) {
      if (safeDemoSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
      'unknownFlag',
    );
  }

  if (listGoldenCasesSeen && goldenCaseSelectionSeen) {
    return const DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.invalid(
      'listGoldenCasesCannotBeCombinedWithGoldenCase',
    );
  }

  return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest.valid(
    format: format,
    section: section,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
    goldenCaseSelection: goldenCaseSelection,
    patchDiagnosticMode: patchDiagnosticMode,
    refinementDiagnosticMode: refinementDiagnosticMode,
    runtimePreparationDiagnosticMode: runtimePreparationDiagnosticMode,
    disabledRuntimeSkeletonDiagnosticMode:
        disabledRuntimeSkeletonDiagnosticMode,
    runtimeExecutionPreflightDiagnosticMode:
        runtimeExecutionPreflightDiagnosticMode,
    listGoldenCases: listGoldenCasesSeen,
  );
}

int debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest request, {
  List<String> reportFindings = const <String>[],
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult?
  selectedGoldenDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult?
  patchSetDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult?
  metadataRefinement,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
  metadataRefinementDiagnostic,
  ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparation,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
  runtimePreparationDiagnostic,
  DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeleton,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
  disabledRuntimeSkeletonDiagnostic,
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
  runtimeExecutionPreflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
  runtimeExecutionPreflightDiagnostic,
}) {
  final hasReportLeak = reportFindings.any(_isCriticalFinding);
  if (diagnostic.hasUnsafePolicyViolation ||
      hasReportLeak ||
      (selectedGoldenDiagnostic?.hasUnsafePolicyViolation ?? false) ||
      (patchSetDiagnostic?.hasUnsafePolicyViolation ?? false) ||
      (metadataRefinement?.hasUnsafePolicyViolation ?? false) ||
      (metadataRefinementDiagnostic?.hasUnsafePolicyViolation ?? false) ||
      (runtimePreparation?.hasUnsafePolicyViolation ?? false) ||
      (runtimePreparationDiagnostic?.hasUnsafePolicyViolation ?? false) ||
      (disabledRuntimeSkeleton?.hasUnsafePolicyViolation ?? false) ||
      (disabledRuntimeSkeletonDiagnostic?.hasUnsafePolicyViolation ?? false) ||
      (runtimeExecutionPreflight?.hasUnsafePolicyViolation ?? false) ||
      (runtimeExecutionPreflightDiagnostic?.hasUnsafePolicyViolation ??
          false)) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUnsafePolicy;
  }
  if (request.strict &&
      (diagnostic.blockerCount > 0 ||
          diagnostic.criticalCount > 0 ||
          diagnostic.unsafeCount > 0 ||
          diagnostic.activeDeniedFieldCount > 0 ||
          diagnostic.productOutputCount > 0 ||
          diagnostic.labelLeakCount > 0 ||
          diagnostic.finalLabelLeakCount > 0 ||
          diagnostic.scoreLeakCount > 0 ||
          diagnostic.metricLeakCount > 0 ||
          diagnostic.cpLossLeakCount > 0 ||
          diagnostic.winProbabilityLeakCount > 0 ||
          diagnostic.moveRankingLeakCount > 0 ||
          diagnostic.thresholdLeakCount > 0 ||
          diagnostic.uiTargetCount > 0 ||
          diagnostic.backendTargetCount > 0 ||
          diagnostic.persistenceWriteCount > 0 ||
          diagnostic.engineCallCount > 0 ||
          diagnostic.schedulerExecutionCount > 0 ||
          diagnostic.analyzerWiringCount > 0 ||
          diagnostic.runtimeImplementationCount > 0 ||
          diagnostic.executablePrototypeCount > 0 ||
          diagnostic.productAdapterBehaviorCount > 0 ||
          diagnostic.savedAnalysisIntegrationCount > 0 ||
          diagnostic.stockfishCommandLeakCount > 0 ||
          diagnostic.rawUciLeakCount > 0 ||
          diagnostic.pvDumpLeakCount > 0 ||
          diagnostic.androidCollectorRequirementCount > 0 ||
          diagnostic.unprovenAndroidProofCount > 0 ||
          diagnostic.phase32EProofClaimCount > 0 ||
          diagnostic.nextRecommendation != _phase33ZRecommendation ||
          !diagnostic.safeForPhase33Z ||
          (selectedGoldenDiagnostic?.hasStrictBlocker ?? false) ||
          (patchSetDiagnostic?.hasUnsafePolicyViolation ?? false) ||
          (metadataRefinement?.hasUnsafePolicyViolation ?? false) ||
          (metadataRefinementDiagnostic?.hasUnsafePolicyViolation ?? false) ||
          (runtimePreparation?.hasUnsafePolicyViolation ?? false) ||
          (runtimePreparationDiagnostic?.hasUnsafePolicyViolation ?? false) ||
          (disabledRuntimeSkeleton?.hasUnsafePolicyViolation ?? false) ||
          (disabledRuntimeSkeletonDiagnostic?.hasUnsafePolicyViolation ??
              false) ||
          (runtimeExecutionPreflight?.hasUnsafePolicyViolation ?? false) ||
          (runtimeExecutionPreflightDiagnostic?.hasUnsafePolicyViolation ??
              false))) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess;
}

String _renderMarkdown(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section, {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult?
  selectedGoldenDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult?
  patchSetDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult?
  metadataRefinement,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
  metadataRefinementDiagnostic,
  ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparation,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
  runtimePreparationDiagnostic,
  DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeleton,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
  disabledRuntimeSkeletonDiagnostic,
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
  runtimeExecutionPreflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
  runtimeExecutionPreflightDiagnostic,
}) {
  final buffer = StringBuffer()
    ..writeln('# Debug-Only Bridge Analyzer Adapter Prototype Diagnostic')
    ..writeln()
    ..writeln(
      '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion',
    )
    ..writeln('- diagnostic status: ${diagnostic.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 33Z: ${diagnostic.safeForPhase33Z}')
    ..writeln('- safe for next step: ${diagnostic.safeForPhase33Z}')
    ..writeln('- next recommendation: ${diagnostic.nextRecommendation}')
    ..writeln('- blocker count: ${diagnostic.blockerCount}')
    ..writeln('- critical count: ${diagnostic.criticalCount}')
    ..writeln('- unsafe count: ${diagnostic.unsafeCount}')
    ..writeln();

  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
  )) {
    _writeSourceChain(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.snapshot,
  )) {
    _writeSnapshot(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.packets,
  )) {
    _writePackets(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.policy,
  )) {
    _writePolicy(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.records,
  )) {
    _writeRecords(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.proof,
  )) {
    _writeProof(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.boundaries,
  )) {
    _writeBoundaries(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.runtime,
  )) {
    _writeRuntime(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.recommendation,
  )) {
    _writeRecommendation(buffer, diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.actionPlan,
  )) {
    _writeActionPlan(buffer);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.patches,
  )) {
    _writePatches(buffer);
  }
  if (metadataRefinement != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .metadataRefinement,
      )) {
    _writeMetadataRefinement(buffer, metadataRefinement);
  }
  if (selectedGoldenDiagnostic != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.golden,
      )) {
    _writeSelectedGoldenDiagnostic(buffer, selectedGoldenDiagnostic);
  }
  if (patchSetDiagnostic != null) {
    _writePatchSetDiagnostic(buffer, patchSetDiagnostic);
  }
  if (metadataRefinementDiagnostic != null) {
    _writeMetadataRefinementDiagnostic(buffer, metadataRefinementDiagnostic);
  }
  if (runtimePreparation != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .runtimePreparation,
      )) {
    _writeRuntimePreparation(buffer, runtimePreparation);
  }
  if (runtimePreparationDiagnostic != null) {
    _writeRuntimePreparationDiagnostic(buffer, runtimePreparationDiagnostic);
  }
  if (disabledRuntimeSkeleton != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .disabledRuntimeSkeleton,
      )) {
    _writeDisabledRuntimeSkeleton(buffer, disabledRuntimeSkeleton);
  }
  if (disabledRuntimeSkeletonDiagnostic != null) {
    _writeDisabledRuntimeSkeletonDiagnostic(
      buffer,
      disabledRuntimeSkeletonDiagnostic,
    );
  }
  if (runtimeExecutionPreflight != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .runtimeExecutionPreflight,
      )) {
    _writeRuntimeExecutionPreflight(buffer, runtimeExecutionPreflight);
  }
  if (runtimeExecutionPreflightDiagnostic != null) {
    _writeRuntimeExecutionPreflightDiagnostic(
      buffer,
      runtimeExecutionPreflightDiagnostic,
    );
  }
  return buffer.toString();
}

String _renderJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section, {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult?
  selectedGoldenDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult?
  patchSetDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult?
  metadataRefinement,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
  metadataRefinementDiagnostic,
  ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparation,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
  runtimePreparationDiagnostic,
  DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeleton,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
  disabledRuntimeSkeletonDiagnostic,
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
  runtimeExecutionPreflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
  runtimeExecutionPreflightDiagnostic,
}) {
  return const JsonEncoder.withIndent(' ').convert(
    _jsonPayload(
      diagnostic,
      section,
      selectedGoldenDiagnostic: selectedGoldenDiagnostic,
      patchSetDiagnostic: patchSetDiagnostic,
      metadataRefinement: metadataRefinement,
      metadataRefinementDiagnostic: metadataRefinementDiagnostic,
      runtimePreparation: runtimePreparation,
      runtimePreparationDiagnostic: runtimePreparationDiagnostic,
      disabledRuntimeSkeleton: disabledRuntimeSkeleton,
      disabledRuntimeSkeletonDiagnostic: disabledRuntimeSkeletonDiagnostic,
      runtimeExecutionPreflight: runtimeExecutionPreflight,
      runtimeExecutionPreflightDiagnostic: runtimeExecutionPreflightDiagnostic,
    ),
  );
}

Map<String, Object?> _jsonPayload(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection section, {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult?
  selectedGoldenDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult?
  patchSetDiagnostic,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult?
  metadataRefinement,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
  metadataRefinementDiagnostic,
  ControlledAnalyzerAdapterRuntimePreparationResult? runtimePreparation,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult?
  runtimePreparationDiagnostic,
  DisabledAnalyzerAdapterRuntimeSkeletonResult? disabledRuntimeSkeleton,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult?
  disabledRuntimeSkeletonDiagnostic,
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult?
  runtimeExecutionPreflight,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult?
  runtimeExecutionPreflightDiagnostic,
}) {
  final payload = <String, Object?>{
    'version': debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion,
    'diagnosticStatus': diagnostic.status.wire,
    'section': section.wire,
    'safeForPhase33Z': diagnostic.safeForPhase33Z,
    'safeForNextStep': diagnostic.safeForPhase33Z,
    'nextRecommendation': diagnostic.nextRecommendation,
    'counts': _countsJson(diagnostic),
  };
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
  )) {
    payload['sourcePhaseChain'] = _sourceChainJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.snapshot,
  )) {
    payload['snapshot'] = _snapshotJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.packets,
  )) {
    payload['packets'] = _packetsJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.policy,
  )) {
    payload['policy'] = _policyJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.records,
  )) {
    payload['records'] = _recordsJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.proof,
  )) {
    payload['proof'] = _proofJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.boundaries,
  )) {
    payload['boundaries'] = _boundariesJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.runtime,
  )) {
    payload['runtime'] = _runtimeJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.recommendation,
  )) {
    payload['next'] = _recommendationJson(diagnostic);
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.actionPlan,
  )) {
    payload['actionPlan'] = _actionPlanJson();
  }
  if (_includeSection(
    section,
    DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.patches,
  )) {
    payload['patches'] = _patchSetJson();
  }
  if (metadataRefinement != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .metadataRefinement,
      )) {
    payload['metadataRefinement'] = _metadataRefinementJson(metadataRefinement);
  }
  if (selectedGoldenDiagnostic != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.golden,
      )) {
    payload['selectedGoldenDiagnostic'] = selectedGoldenDiagnostic.toJson();
  }
  if (patchSetDiagnostic != null) {
    payload['patchSetDiagnostic'] = patchSetDiagnostic.toJson();
  }
  if (metadataRefinementDiagnostic != null) {
    payload['metadataRefinementDiagnostic'] = metadataRefinementDiagnostic
        .toJson();
  }
  if (runtimePreparation != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .runtimePreparation,
      )) {
    payload['runtimePreparation'] = runtimePreparation.toJson();
  }
  if (runtimePreparationDiagnostic != null) {
    payload['runtimePreparationDiagnostic'] = runtimePreparationDiagnostic
        .toJson();
  }
  if (disabledRuntimeSkeleton != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .disabledRuntimeSkeleton,
      )) {
    payload['disabledRuntimeSkeleton'] = disabledRuntimeSkeleton.toJson();
  }
  if (disabledRuntimeSkeletonDiagnostic != null) {
    payload['disabledRuntimeSkeletonDiagnostic'] =
        disabledRuntimeSkeletonDiagnostic.toJson();
  }
  if (runtimeExecutionPreflight != null &&
      _includeSection(
        section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection
            .runtimeExecutionPreflight,
      )) {
    payload['runtimeExecutionPreflight'] = runtimeExecutionPreflight.toJson();
  }
  if (runtimeExecutionPreflightDiagnostic != null) {
    payload['runtimeExecutionPreflightDiagnostic'] =
        runtimeExecutionPreflightDiagnostic.toJson();
  }
  return payload;
}

void _writeSourceChain(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Source Phase Chain')
    ..writeln(
      '- 33U skeleton: ${diagnostic.harnessResult.sourceSkeletonStatus.wire}',
    )
    ..writeln(
      '- 33V skeleton validation: ${diagnostic.harnessResult.sourceValidationStatus.wire}',
    )
    ..writeln(
      '- 33W inspection harness: ${diagnostic.harnessResult.status.wire}',
    )
    ..writeln(
      '- 33X inspection harness validation: ${diagnostic.validationResult.status.wire}',
    )
    ..writeln();
}

void _writeSnapshot(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  buffer
    ..writeln('## Inspection Snapshot Summary')
    ..writeln('- snapshot ID: ${snapshot.snapshotId}')
    ..writeln('- input packet ID: ${snapshot.inputPacketId}')
    ..writeln('- context packet ID: ${snapshot.contextPacketId}')
    ..writeln('- skeleton version: ${snapshot.skeletonVersion}')
    ..writeln('- developer-only: ${snapshot.developerOnly}')
    ..writeln('- in-memory only: ${snapshot.inMemoryOnly}')
    ..writeln('- analyzer unwired: ${snapshot.analyzerUnwired}')
    ..writeln(
      '- safe for developer inspection: ${snapshot.safeForDeveloperInspection}',
    )
    ..writeln('- warning summary: ${_ids(snapshot.warningReasons)}')
    ..writeln(
      '- future prerequisites: ${_ids(_futurePrerequisites(diagnostic))}',
    )
    ..writeln();
}

void _writePackets(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  buffer
    ..writeln('## Packet Summary')
    ..writeln('- input packet ID: ${snapshot.inputPacketId}')
    ..writeln('- context packet ID: ${snapshot.contextPacketId}')
    ..writeln(
      '- input packet validations: ${diagnostic.harnessResult.inputPacketInspectionCount}',
    )
    ..writeln(
      '- context packet validations: ${diagnostic.harnessResult.contextPacketInspectionCount}',
    )
    ..writeln('- packet summary: ${_mapSummary(snapshot.packetSummary)}')
    ..writeln();
}

void _writePolicy(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final policy = diagnostic.harnessResult.snapshot.policySummary;
  buffer
    ..writeln('## Policy Flag Summary')
    ..writeln('- unsafe policy allowance: ${policy['hasUnsafeAllowance']}')
    ..writeln('- product output allowed: ${policy['allowsProductOutput']}')
    ..writeln('- analyzer wiring allowed: ${policy['allowsAnalyzerWiring']}')
    ..writeln(
      '- runtime implementation allowed: ${policy['allowsRuntimeImplementation']}',
    )
    ..writeln(
      '- executable prototype allowed: ${policy['allowsExecutablePrototype']}',
    )
    ..writeln('- engine calls allowed: ${policy['allowsEngineCalls']}')
    ..writeln(
      '- scheduler execution allowed: ${policy['allowsSchedulerExecution']}',
    )
    ..writeln(
      '- persistence writes allowed: ${policy['allowsPersistenceWrites']}',
    )
    ..writeln('- UI targets allowed: ${policy['allowsUiTargets']}')
    ..writeln('- backend targets allowed: ${policy['allowsBackendTargets']}')
    ..writeln('- product adapter allowed: ${policy['allowsProductAdapter']}')
    ..writeln(
      '- saved analysis integration allowed: ${policy['allowsSavedAnalysisIntegration']}',
    )
    ..writeln(
      '- classifier labels allowed: ${policy['allowsClassifierLabels']}',
    )
    ..writeln('- final labels allowed: ${policy['allowsFinalLabels']}')
    ..writeln('- numeric scores allowed: ${policy['allowsNumericScores']}')
    ..writeln('- aggregate scores allowed: ${policy['allowsAggregateScores']}')
    ..writeln('- official metrics allowed: ${policy['allowsOfficialMetrics']}')
    ..writeln('- CP-loss allowed: ${policy['allowsCpLoss']}')
    ..writeln('- win probability allowed: ${policy['allowsWinProbability']}')
    ..writeln('- move ranking allowed: ${policy['allowsMoveRanking']}')
    ..writeln(
      '- Stockfish command allowed: ${policy['allowsStockfishCommand']}',
    )
    ..writeln('- raw UCI allowed: ${policy['allowsRawUci']}')
    ..writeln('- PV dump allowed: ${policy['allowsPvDump']}')
    ..writeln();
}

void _writeRecords(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final summary =
      diagnostic.harnessResult.snapshot.recordRoleSummary.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
  buffer
    ..writeln('## Record Role Summary')
    ..writeln('| Role | Count |')
    ..writeln('| --- | --- |');
  for (final entry in summary) {
    buffer.writeln('| ${entry.key} | ${entry.value} |');
  }
  buffer
    ..writeln()
    ..writeln('## Inspection Validation Rows')
    ..writeln('| Row | Role | Status | Findings |')
    ..writeln('| --- | --- | --- | --- |');
  for (final row in diagnostic.validationResult.validationRows) {
    buffer.writeln(
      '| ${row.validationRowId} | ${row.validationRole.wire} | '
      '${row.status.wire} | ${_ids(row.findings)} |',
    );
  }
  buffer.writeln();
}

void _writeProof(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Android Proof Boundary Summary')
    ..writeln(
      '- captured proof IDs: ${_ids(diagnostic.harnessResult.snapshot.androidProofCaseIds)}',
    )
    ..writeln(
      '- unproven Android proof count: ${diagnostic.unprovenAndroidProofCount}',
    )
    ..writeln(
      '- Phase 32E proof claim count: ${diagnostic.phase32EProofClaimCount}',
    )
    ..writeln()
    ..writeln('## Owner Proof Summary')
    ..writeln('- owner proof queue count: ${diagnostic.ownerProofQueueCount}')
    ..writeln();
}

void _writeBoundaries(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  buffer
    ..writeln('## Allowed/Denied Field Summary')
    ..writeln('- allowed fields: ${_ids(snapshot.allowedFieldIds)}')
    ..writeln('- denied fields: ${_ids(snapshot.deniedFieldIds)}')
    ..writeln(
      '- active denied field count: ${diagnostic.activeDeniedFieldCount}',
    )
    ..writeln('- product output count: ${diagnostic.productOutputCount}')
    ..writeln('- label leak count: ${diagnostic.labelLeakCount}')
    ..writeln('- final label leak count: ${diagnostic.finalLabelLeakCount}')
    ..writeln('- score leak count: ${diagnostic.scoreLeakCount}')
    ..writeln('- metric leak count: ${diagnostic.metricLeakCount}')
    ..writeln('- CP-loss leak count: ${diagnostic.cpLossLeakCount}')
    ..writeln(
      '- win probability leak count: ${diagnostic.winProbabilityLeakCount}',
    )
    ..writeln('- move ranking leak count: ${diagnostic.moveRankingLeakCount}')
    ..writeln('- threshold leak count: ${diagnostic.thresholdLeakCount}')
    ..writeln(
      '- Stockfish/raw UCI/PV dump denied: ${diagnostic.stockfishCommandLeakCount == 0 && diagnostic.rawUciLeakCount == 0 && diagnostic.pvDumpLeakCount == 0}',
    )
    ..writeln('- blocked boundaries: ${_ids(snapshot.blockedBoundaryIds)}')
    ..writeln();
}

void _writeRuntime(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Runtime/Analyzer/Engine/Scheduler/Product Blocked Summary')
    ..writeln('- analyzer wiring count: ${diagnostic.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${diagnostic.runtimeImplementationCount}',
    )
    ..writeln(
      '- executable prototype count: ${diagnostic.executablePrototypeCount}',
    )
    ..writeln('- engine call count: ${diagnostic.engineCallCount}')
    ..writeln(
      '- scheduler execution count: ${diagnostic.schedulerExecutionCount}',
    )
    ..writeln('- persistence write count: ${diagnostic.persistenceWriteCount}')
    ..writeln(
      '- product adapter behavior count: ${diagnostic.productAdapterBehaviorCount}',
    )
    ..writeln(
      '- saved analysis integration count: ${diagnostic.savedAnalysisIntegrationCount}',
    )
    ..writeln();
}

void _writeRecommendation(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 33Z: ${diagnostic.safeForPhase33Z}')
    ..writeln('- safe for next step: ${diagnostic.safeForPhase33Z}')
    ..writeln('- next recommendation: ${diagnostic.nextRecommendation}')
    ..writeln('- warnings: ${_ids(_warnings(diagnostic))}')
    ..writeln(
      '- future prerequisites: ${_ids(_futurePrerequisites(diagnostic))}',
    )
    ..writeln();
}

Map<String, Object?> _sourceChainJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'phase33U': diagnostic.harnessResult.sourceSkeletonStatus.wire,
    'phase33V': diagnostic.harnessResult.sourceValidationStatus.wire,
    'phase33W': diagnostic.harnessResult.status.wire,
    'phase33X': diagnostic.validationResult.status.wire,
  };
}

Map<String, Object?> _snapshotJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  return <String, Object?>{
    'snapshotId': snapshot.snapshotId,
    'inputPacketId': snapshot.inputPacketId,
    'contextPacketId': snapshot.contextPacketId,
    'skeletonVersion': snapshot.skeletonVersion,
    'developerOnly': snapshot.developerOnly,
    'inMemoryOnly': snapshot.inMemoryOnly,
    'analyzerUnwired': snapshot.analyzerUnwired,
    'safeForDeveloperInspection': snapshot.safeForDeveloperInspection,
    'warningSummary': snapshot.warningReasons,
    'futurePrerequisites': _futurePrerequisites(diagnostic),
  };
}

Map<String, Object?> _packetsJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  return <String, Object?>{
    'inputPacketId': snapshot.inputPacketId,
    'contextPacketId': snapshot.contextPacketId,
    'inputPacketInspectionCount':
        diagnostic.harnessResult.inputPacketInspectionCount,
    'contextPacketInspectionCount':
        diagnostic.harnessResult.contextPacketInspectionCount,
    'packetSummary': snapshot.packetSummary,
  };
}

Map<String, Object?> _policyJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return Map<String, Object?>.from(
    diagnostic.harnessResult.snapshot.policySummary,
  );
}

Map<String, Object?> _recordsJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'recordRoleSummary': diagnostic.harnessResult.snapshot.recordRoleSummary,
    'validationRows': diagnostic.validationResult.validationRows
        .map(
          (row) => <String, Object?>{
            'validationRowId': row.validationRowId,
            'validationRole': row.validationRole.wire,
            'status': row.status.wire,
            'findings': row.findings,
          },
        )
        .toList(growable: false),
  };
}

Map<String, Object?> _proofJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'capturedProofIds': diagnostic.harnessResult.snapshot.androidProofCaseIds,
    'unprovenAndroidProofCount': diagnostic.unprovenAndroidProofCount,
    'phase32EProofClaimCount': diagnostic.phase32EProofClaimCount,
    'ownerProofQueueCount': diagnostic.ownerProofQueueCount,
  };
}

Map<String, Object?> _boundariesJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  final snapshot = diagnostic.harnessResult.snapshot;
  return <String, Object?>{
    'allowedFieldIds': snapshot.allowedFieldIds,
    'deniedFieldIds': snapshot.deniedFieldIds,
    'activeDeniedFieldCount': diagnostic.activeDeniedFieldCount,
    'productOutputCount': diagnostic.productOutputCount,
    'labelLeakCount': diagnostic.labelLeakCount,
    'finalLabelLeakCount': diagnostic.finalLabelLeakCount,
    'scoreLeakCount': diagnostic.scoreLeakCount,
    'metricLeakCount': diagnostic.metricLeakCount,
    'cpLossLeakCount': diagnostic.cpLossLeakCount,
    'winProbabilityLeakCount': diagnostic.winProbabilityLeakCount,
    'moveRankingLeakCount': diagnostic.moveRankingLeakCount,
    'thresholdLeakCount': diagnostic.thresholdLeakCount,
    'stockfishRawUciPvDumpDenied':
        diagnostic.stockfishCommandLeakCount == 0 &&
        diagnostic.rawUciLeakCount == 0 &&
        diagnostic.pvDumpLeakCount == 0,
    'blockedBoundaryIds': snapshot.blockedBoundaryIds,
  };
}

Map<String, Object?> _runtimeJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'analyzerWiringCount': diagnostic.analyzerWiringCount,
    'runtimeImplementationCount': diagnostic.runtimeImplementationCount,
    'executablePrototypeCount': diagnostic.executablePrototypeCount,
    'engineCallCount': diagnostic.engineCallCount,
    'schedulerExecutionCount': diagnostic.schedulerExecutionCount,
    'persistenceWriteCount': diagnostic.persistenceWriteCount,
    'productAdapterBehaviorCount': diagnostic.productAdapterBehaviorCount,
    'savedAnalysisIntegrationCount': diagnostic.savedAnalysisIntegrationCount,
  };
}

Map<String, Object?> _recommendationJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'safeForPhase33Z': diagnostic.safeForPhase33Z,
    'safeForNextStep': diagnostic.safeForPhase33Z,
    'nextRecommendation': diagnostic.nextRecommendation,
    'warnings': _warnings(diagnostic),
    'futurePrerequisites': _futurePrerequisites(diagnostic),
  };
}

Map<String, Object?> _countsJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return <String, Object?>{
    'blockerCount': diagnostic.blockerCount,
    'criticalCount': diagnostic.criticalCount,
    'unsafeCount': diagnostic.unsafeCount,
    'analyzerWiringCount': diagnostic.analyzerWiringCount,
    'runtimeImplementationCount': diagnostic.runtimeImplementationCount,
    'executablePrototypeCount': diagnostic.executablePrototypeCount,
    'engineCallCount': diagnostic.engineCallCount,
    'schedulerExecutionCount': diagnostic.schedulerExecutionCount,
    'persistenceWriteCount': diagnostic.persistenceWriteCount,
    'productOutputCount': diagnostic.productOutputCount,
    'activeDeniedFieldCount': diagnostic.activeDeniedFieldCount,
    'labelLeakCount': diagnostic.labelLeakCount,
    'finalLabelLeakCount': diagnostic.finalLabelLeakCount,
    'scoreLeakCount': diagnostic.scoreLeakCount,
    'metricLeakCount': diagnostic.metricLeakCount,
    'cpLossLeakCount': diagnostic.cpLossLeakCount,
    'winProbabilityLeakCount': diagnostic.winProbabilityLeakCount,
    'moveRankingLeakCount': diagnostic.moveRankingLeakCount,
    'thresholdLeakCount': diagnostic.thresholdLeakCount,
    'uiTargetCount': diagnostic.uiTargetCount,
    'backendTargetCount': diagnostic.backendTargetCount,
    'stockfishCommandLeakCount': diagnostic.stockfishCommandLeakCount,
    'rawUciLeakCount': diagnostic.rawUciLeakCount,
    'pvDumpLeakCount': diagnostic.pvDumpLeakCount,
    'androidCollectorRequirementCount':
        diagnostic.androidCollectorRequirementCount,
    'unprovenAndroidProofCount': diagnostic.unprovenAndroidProofCount,
    'phase32EProofClaimCount': diagnostic.phase32EProofClaimCount,
    'ownerProofQueueCount': diagnostic.ownerProofQueueCount,
  };
}

void _writeSelectedGoldenDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult result,
) {
  buffer
    ..writeln('## Selected Golden Analyzer Adapter Prototype Diagnostic')
    ..writeln('- selection: ${result.selection}')
    ..writeln('- selected Golden status: ${result.status.wire}')
    ..writeln('- safe for Phase 34A: ${result.safeForPhase34A}')
    ..writeln('- safe for next step: ${result.safeForPhase34A}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- selected row count: ${result.rows.length}')
    ..writeln('- blocker count: ${result.blockerCount}')
    ..writeln('- critical count: ${result.criticalCount}')
    ..writeln('- unsafe count: ${result.unsafeCount}')
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${result.runtimeImplementationCount}',
    )
    ..writeln(
      '- executable prototype count: ${result.executablePrototypeCount}',
    )
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln(
      '- Phase 32E proof claim count: ${result.phase32EProofClaimCount}',
    )
    ..writeln(
      '- unproven Android proof count: ${result.unprovenAndroidProofCount}',
    )
    ..writeln(
      '- quiet/preparatory promotion count: ${result.quietPreparatoryPromotionCount}',
    )
    ..writeln('- PV/MultiPV promotion count: ${result.pvMultiPvPromotionCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln()
    ..writeln(
      '| Case ID | Title | Source phase | Role | Reason | Support areas | Warnings | Proof limits | Android proof IDs | Owner proof | Active denied fields | Blocked boundaries | Recommendation |',
    )
    ..writeln(
      '| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |',
    );
  for (final row in result.rows) {
    buffer.writeln(
      '| ${row.caseId} | ${row.title} | ${row.sourcePhase} | '
      '${row.diagnosticRole.wire} | ${row.selectedReason} | '
      '${_ids(row.supportAreaIds)} | ${_ids(row.warningReasons)} | '
      '${_ids(row.proofLimitReasons)} | ${_ids(row.androidProofIds)} | '
      '${row.ownerProofRequired} | ${_ids(row.activeDeniedFieldIds)} | '
      '${_ids(row.blockedBoundaryIds)} | ${row.recommendation} |',
    );
  }
  buffer.writeln();
}

void _writeActionPlan(StringBuffer buffer) {
  final result =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
          .evaluate();
  buffer
    ..writeln('## Action Plan Metadata Summary')
    ..writeln('- action plan status: ${result.status.wire}')
    ..writeln('- safe for Phase 34C: ${result.safeForPhase34C}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total actions: ${result.totalActions}')
    ..writeln(
      '- safe internal support actions: ${result.safeInternalSupportActionCount}',
    )
    ..writeln(
      '- warning-limited follow-up actions: ${result.warningLimitedFollowupActionCount}',
    )
    ..writeln('- proof boundary actions: ${result.proofBoundaryActionCount}')
    ..writeln('- excluded guard actions: ${result.excludedGuardActionCount}')
    ..writeln(
      '- denied-field protection actions: ${result.deniedFieldProtectionActionCount}',
    )
    ..writeln(
      '- blocked integration actions: ${result.blockedIntegrationActionCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${result.runtimeImplementationCount}',
    )
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln();
}

void _writePatches(StringBuffer buffer) {
  final result =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
          .evaluate();
  buffer
    ..writeln('## Action Plan Patch Set Metadata Summary')
    ..writeln('- patch set status: ${result.status.wire}')
    ..writeln('- safe for Phase 34D: ${result.safeForPhase34D}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total patch records: ${result.totalPatchRecords}')
    ..writeln(
      '- support traceability patches: ${result.supportTraceabilityPatchCount}',
    )
    ..writeln(
      '- warning follow-up marker patches: ${result.warningFollowupMarkerPatchCount}',
    )
    ..writeln(
      '- proof boundary marker patches: ${result.proofBoundaryMarkerPatchCount}',
    )
    ..writeln(
      '- excluded guard preservation patches: ${result.excludedGuardPreservationPatchCount}',
    )
    ..writeln(
      '- denied-field protection patches: ${result.deniedFieldProtectionPatchCount}',
    )
    ..writeln(
      '- blocked integration sentinel patches: ${result.blockedIntegrationSentinelPatchCount}',
    )
    ..writeln(
      '- Phase 34D practical diagnostic requirement patches: ${result.phase34DPracticalDiagnosticRequirementPatchCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${result.runtimeImplementationCount}',
    )
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln();
}

void _writeMetadataRefinement(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult result,
) {
  buffer
    ..writeln('## Metadata Refinement Summary')
    ..writeln('- metadata refinement status: ${result.status.wire}')
    ..writeln('- source diagnostic status: ${result.sourceDiagnosticStatus}')
    ..writeln('- source patch set status: ${result.sourcePatchSetStatus}')
    ..writeln('- safe for Phase 34F: ${result.safeForPhase34F}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln(
      '- source chain: Phase 34B action plan -> Phase 34C patch set -> Phase 34D patch-set diagnostic -> Phase 34E metadata refinement',
    )
    ..writeln('- total refinements: ${result.totalRefinementRecords}')
    ..writeln(
      '- support reason refinements: ${result.supportTraceabilityMetadataRefinementCount}',
    )
    ..writeln(
      '- warning reason refinements: ${result.warningReasonMetadataRefinementCount}',
    )
    ..writeln(
      '- proof-boundary refinements: ${result.proofBoundaryMetadataRefinementCount}',
    )
    ..writeln(
      '- excluded guard refinements: ${result.excludedGuardMetadataRefinementCount}',
    )
    ..writeln(
      '- denied-field refinements: ${result.deniedFieldMetadataRefinementCount}',
    )
    ..writeln(
      '- blocked integration refinements: ${result.blockedIntegrationMetadataRefinementCount}',
    )
    ..writeln(
      '- target surface refinements: ${result.targetSurfaceMetadataRefinementCount}',
    )
    ..writeln(
      '- diagnostic summary refinements: ${result.diagnosticSummaryMetadataRefinementCount}',
    )
    ..writeln(
      '- Phase 34F diagnostic requirement refinements: ${result.phase34FDiagnosticRequirementRefinementCount}',
    )
    ..writeln(
      '- target surfaces: ${_mapSummary(Map<String, Object?>.from(result.targetSurfaceCounts))}',
    )
    ..writeln(
      '- allowed target surfaces: ${_ids(result.allowedTargetSurfaces)}',
    )
    ..writeln(
      '- forbidden target surfaces blocked: ${_ids(result.forbiddenTargetSurfaces)}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${result.runtimeImplementationCount}',
    )
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln();
}

void _writeMetadataRefinementDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult
  result,
) {
  buffer
    ..writeln('## Metadata Refinement Diagnostic Run')
    ..writeln('- refinement diagnostic status: ${result.status.wire}')
    ..writeln('- refinement diagnostic mode: ${result.mode.wire}')
    ..writeln(
      '- source metadata refinement status: ${result.sourceMetadataRefinementStatus}',
    )
    ..writeln('- source diagnostic status: ${result.sourceDiagnosticStatus}')
    ..writeln('- source patch set status: ${result.sourcePatchSetStatus}')
    ..writeln('- safe for Phase 34G: ${result.safeForPhase34G}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total diagnostic rows: ${result.totalDiagnosticRows}')
    ..writeln('- support diagnostic rows: ${result.supportDiagnosticRowCount}')
    ..writeln('- warning diagnostic rows: ${result.warningDiagnosticRowCount}')
    ..writeln('- proof diagnostic rows: ${result.proofDiagnosticRowCount}')
    ..writeln('- guard diagnostic rows: ${result.guardDiagnosticRowCount}')
    ..writeln('- denied diagnostic rows: ${result.deniedDiagnosticRowCount}')
    ..writeln('- blocked diagnostic rows: ${result.blockedDiagnosticRowCount}')
    ..writeln('- surface diagnostic rows: ${result.surfaceDiagnosticRowCount}')
    ..writeln(
      '- recommendation diagnostic rows: ${result.recommendationDiagnosticRowCount}',
    )
    ..writeln(
      '- target surfaces: ${_mapSummary(Map<String, Object?>.from(result.targetSurfaceCounts))}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${result.runtimeImplementationCount}',
    )
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln();
}

void _writeRuntimePreparation(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimePreparationResult result,
) {
  buffer
    ..writeln('## Controlled Runtime Preparation')
    ..writeln('- preparation status: ${result.status.wire}')
    ..writeln(
      '- source metadata refinement diagnostic status: ${result.sourceMetadataRefinementDiagnosticStatus}',
    )
    ..writeln('- safe for Phase 34H: ${result.safeForPhase34H}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- executionAllowed: ${result.policy.executionAllowed}')
    ..writeln('- analyzerWiringAllowed: ${result.policy.analyzerWiringAllowed}')
    ..writeln('- engineCallsAllowed: ${result.policy.engineCallsAllowed}')
    ..writeln('- schedulerAllowed: ${result.policy.schedulerAllowed}')
    ..writeln('- persistenceAllowed: ${result.policy.persistenceAllowed}')
    ..writeln('- productOutputAllowed: ${result.policy.productOutputAllowed}')
    ..writeln('- productAdapterAllowed: ${result.policy.productAdapterAllowed}')
    ..writeln('- savedAnalysisAllowed: ${result.policy.savedAnalysisAllowed}')
    ..writeln('- precondition count: ${result.totalPreconditions}')
    ..writeln('- envelope count: ${result.totalEnvelopes}')
    ..writeln('- blocked seam count: ${result.totalBlockedSeams}')
    ..writeln('- denied field count: ${result.deniedFieldCount}')
    ..writeln('- source diagnostics: ${_ids(result.input.sourceDiagnosticIds)}')
    ..writeln('- source cases: ${_ids(result.input.sourceCaseIds)}')
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln();
}

void _writeRuntimePreparationDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult
  result,
) {
  buffer
    ..writeln('## Controlled Runtime Preparation Diagnostic Run')
    ..writeln('- diagnostic status: ${result.status.wire}')
    ..writeln('- runtime preparation diagnostic mode: ${result.mode.wire}')
    ..writeln('- source preparation status: ${result.sourcePreparationStatus}')
    ..writeln(
      '- source metadata refinement diagnostic status: ${result.sourceMetadataRefinementDiagnosticStatus}',
    )
    ..writeln('- safe for Phase 34I: ${result.safeForPhase34I}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total diagnostic rows: ${result.totalDiagnosticRows}')
    ..writeln(
      '- envelope diagnostic rows: ${result.envelopeDiagnosticRowCount}',
    )
    ..writeln(
      '- precondition diagnostic rows: ${result.preconditionDiagnosticRowCount}',
    )
    ..writeln('- policy diagnostic rows: ${result.policyDiagnosticRowCount}')
    ..writeln(
      '- blocked seam diagnostic rows: ${result.blockedSeamDiagnosticRowCount}',
    )
    ..writeln('- denied diagnostic rows: ${result.deniedDiagnosticRowCount}')
    ..writeln('- proof diagnostic rows: ${result.proofDiagnosticRowCount}')
    ..writeln(
      '- recommendation diagnostic rows: ${result.recommendationDiagnosticRowCount}',
    )
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln('- executable runtime count: ${result.executableRuntimeCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- product adapter count: ${result.productAdapterCount}')
    ..writeln(
      '- saved analysis integration count: ${result.savedAnalysisIntegrationCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln();
}

void _writeDisabledRuntimeSkeleton(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeSkeletonResult result,
) {
  buffer
    ..writeln('## Disabled Analyzer Adapter Runtime Skeleton')
    ..writeln('- skeleton status: ${result.status.wire}')
    ..writeln('- source diagnostic status: ${result.sourceDiagnosticStatus}')
    ..writeln('- source preparation status: ${result.sourcePreparationStatus}')
    ..writeln('- safe for Phase 34J: ${result.safeForPhase34J}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- request envelope ID: ${result.request.requestEnvelopeId}')
    ..writeln('- response envelope ID: ${result.response.responseEnvelopeId}')
    ..writeln(
      '- execution attempt ID: ${result.executionAttempt.executionAttemptId}',
    )
    ..writeln(
      '- execution refused reason: ${result.executionAttempt.executionRefusedReason}',
    )
    ..writeln('- executionAllowed: ${result.policy.executionAllowed}')
    ..writeln('- analyzerWiringAllowed: ${result.policy.analyzerWiringAllowed}')
    ..writeln('- engineCallsAllowed: ${result.policy.engineCallsAllowed}')
    ..writeln('- schedulerAllowed: ${result.policy.schedulerAllowed}')
    ..writeln('- persistenceAllowed: ${result.policy.persistenceAllowed}')
    ..writeln('- productOutputAllowed: ${result.policy.productOutputAllowed}')
    ..writeln('- productAdapterAllowed: ${result.policy.productAdapterAllowed}')
    ..writeln('- savedAnalysisAllowed: ${result.policy.savedAnalysisAllowed}')
    ..writeln('- blocked seam count: ${result.totalBlockedSeams}')
    ..writeln('- denied field count: ${result.deniedFieldCount}')
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln('- executable runtime count: ${result.executableRuntimeCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- product adapter count: ${result.productAdapterCount}')
    ..writeln(
      '- saved analysis integration count: ${result.savedAnalysisIntegrationCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln();
}

void _writeDisabledRuntimeSkeletonDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult result,
) {
  buffer
    ..writeln('## Disabled Runtime Skeleton Diagnostic Run')
    ..writeln('- diagnostic status: ${result.status.wire}')
    ..writeln(
      '- disabled runtime skeleton diagnostic mode: ${result.mode.wire}',
    )
    ..writeln('- source skeleton status: ${result.sourceSkeletonStatus}')
    ..writeln(
      '- source runtime-preparation diagnostic status: ${result.sourceRuntimePreparationDiagnosticStatus}',
    )
    ..writeln('- safe for Phase 34K: ${result.safeForPhase34K}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total diagnostic rows: ${result.totalDiagnosticRows}')
    ..writeln('- request rows: ${result.requestDiagnosticRowCount}')
    ..writeln('- response rows: ${result.responseDiagnosticRowCount}')
    ..writeln('- attempt rows: ${result.attemptDiagnosticRowCount}')
    ..writeln('- policy rows: ${result.policyDiagnosticRowCount}')
    ..writeln('- blocked seam rows: ${result.blockedSeamDiagnosticRowCount}')
    ..writeln('- denied rows: ${result.deniedDiagnosticRowCount}')
    ..writeln('- proof rows: ${result.proofDiagnosticRowCount}')
    ..writeln(
      '- recommendation rows: ${result.recommendationDiagnosticRowCount}',
    )
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln('- executable runtime count: ${result.executableRuntimeCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- product adapter count: ${result.productAdapterCount}')
    ..writeln(
      '- saved analysis integration count: ${result.savedAnalysisIntegrationCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln()
    ..writeln(
      '| Row | Request | Response | Attempted | Performed | Refused reason | Findings |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final row in result.rows) {
    buffer.writeln(
      '| ${row.diagnosticRowId} | ${row.requestEnvelopeId} | ${row.responseEnvelopeId} | ${row.executionAttempted} | ${row.executionPerformed} | ${row.executionRefusedReason} | ${_ids(row.findings)} |',
    );
  }
  buffer.writeln();
}

void _writeRuntimeExecutionPreflight(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeExecutionPreflightResult result,
) {
  buffer
    ..writeln('## Controlled Runtime Execution Preflight')
    ..writeln('- preflight status: ${result.status.wire}')
    ..writeln('- source diagnostic status: ${result.sourceDiagnosticStatus}')
    ..writeln('- source skeleton status: ${result.sourceSkeletonStatus}')
    ..writeln(
      '- source runtime-preparation diagnostic status: ${result.sourceRuntimePreparationDiagnosticStatus}',
    )
    ..writeln('- safe for Phase 34L: ${result.safeForPhase34L}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total checks: ${result.totalChecks}')
    ..writeln('- passed checks: ${result.passedCheckCount}')
    ..writeln('- blocked reason count: ${result.blockedReasonCount}')
    ..writeln('- denied field count: ${result.deniedFieldCount}')
    ..writeln('- executionAllowed: ${result.decision.executionAllowed}')
    ..writeln(
      '- runtimeExecutionApproved: ${result.decision.runtimeExecutionApproved}',
    )
    ..writeln(
      '- analyzerWiringAllowed: ${result.decision.analyzerWiringAllowed}',
    )
    ..writeln('- engineCallsAllowed: ${result.decision.engineCallsAllowed}')
    ..writeln('- schedulerAllowed: ${result.decision.schedulerAllowed}')
    ..writeln('- persistenceAllowed: ${result.decision.persistenceAllowed}')
    ..writeln('- productOutputAllowed: ${result.decision.productOutputAllowed}')
    ..writeln(
      '- productAdapterAllowed: ${result.decision.productAdapterAllowed}',
    )
    ..writeln('- savedAnalysisAllowed: ${result.decision.savedAnalysisAllowed}')
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln('- executable runtime count: ${result.executableRuntimeCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- product adapter count: ${result.productAdapterCount}')
    ..writeln(
      '- saved analysis integration count: ${result.savedAnalysisIntegrationCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln()
    ..writeln('| Check | Passed | Blocked reasons |')
    ..writeln('| --- | --- | --- |');
  for (final check in result.checks) {
    buffer.writeln(
      '| ${check.checkId} | ${check.passed} | ${_ids(check.blockedReasonIds)} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('| Blocked reason | Surface | Blocked |')
    ..writeln('| --- | --- | --- |');
  for (final reason in result.blockedReasons) {
    buffer.writeln(
      '| ${reason.blockedReasonId} | ${reason.blockedSurface} | ${reason.blocked} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('- android proof IDs: ${_ids(result.input.androidProofIds)}')
    ..writeln('- denied field IDs: ${_ids(result.policy.deniedFieldIds)}')
    ..writeln('- findings: ${_ids(result.findings)}')
    ..writeln();
}

void _writeRuntimeExecutionPreflightDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult
  result,
) {
  buffer
    ..writeln('## Runtime Execution Preflight Diagnostic Run')
    ..writeln('- diagnostic status: ${result.status.wire}')
    ..writeln(
      '- runtime execution preflight diagnostic mode: ${result.mode.wire}',
    )
    ..writeln('- source preflight status: ${result.sourcePreflightStatus}')
    ..writeln(
      '- source disabled runtime skeleton diagnostic status: ${result.sourceDisabledRuntimeSkeletonDiagnosticStatus}',
    )
    ..writeln('- safe for Phase 34M: ${result.safeForPhase34M}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total diagnostic rows: ${result.totalDiagnosticRows}')
    ..writeln('- check rows: ${result.checkDiagnosticRowCount}')
    ..writeln('- decision rows: ${result.decisionDiagnosticRowCount}')
    ..writeln(
      '- blocked reason rows: ${result.blockedReasonDiagnosticRowCount}',
    )
    ..writeln('- denied rows: ${result.deniedDiagnosticRowCount}')
    ..writeln('- proof rows: ${result.proofDiagnosticRowCount}')
    ..writeln(
      '- recommendation rows: ${result.recommendationDiagnosticRowCount}',
    )
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln(
      '- runtime execution approved count: ${result.runtimeExecutionApprovedCount}',
    )
    ..writeln('- executable runtime count: ${result.executableRuntimeCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- persistence write count: ${result.persistenceWriteCount}')
    ..writeln('- product output count: ${result.productOutputCount}')
    ..writeln('- product adapter count: ${result.productAdapterCount}')
    ..writeln(
      '- saved analysis integration count: ${result.savedAnalysisIntegrationCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln()
    ..writeln(
      '| Row | Mode | Execution | Approved | Analyzer wiring | Engine calls | Scheduler | Findings |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
  for (final row in result.rows) {
    buffer.writeln(
      '| ${row.diagnosticRowId} | ${row.diagnosticMode} | ${row.executionAllowed} | ${row.runtimeExecutionApproved} | ${row.analyzerWiringAllowed} | ${row.engineCallsAllowed} | ${row.schedulerAllowed} | ${_ids(row.findings)} |',
    );
  }
  buffer.writeln();
}

void _writePatchSetDiagnostic(
  StringBuffer buffer,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult result,
) {
  buffer
    ..writeln('## Patch Set Diagnostic Run')
    ..writeln('- patch diagnostic status: ${result.status.wire}')
    ..writeln('- patch diagnostic mode: ${result.mode.wire}')
    ..writeln(
      '- Phase 34B action plan status: ${result.sourceActionPlanStatus}',
    )
    ..writeln('- Phase 34C patch set status: ${result.sourcePatchSetStatus}')
    ..writeln('- safe for Phase 34E: ${result.safeForPhase34E}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- total diagnostic rows: ${result.totalDiagnosticRows}')
    ..writeln(
      '- support traceability rows: ${result.supportTraceabilityRowCount}',
    )
    ..writeln('- warning marker rows: ${result.warningFollowupMarkerRowCount}')
    ..writeln(
      '- proof-boundary marker rows: ${result.proofBoundaryMarkerRowCount}',
    )
    ..writeln(
      '- excluded guard rows: ${result.excludedGuardPreservationRowCount}',
    )
    ..writeln(
      '- denied-field protection rows: ${result.deniedFieldProtectionRowCount}',
    )
    ..writeln(
      '- blocked integration sentinel rows: ${result.blockedIntegrationSentinelRowCount}',
    )
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- analyzer wiring count: ${result.analyzerWiringCount}')
    ..writeln(
      '- runtime implementation count: ${result.runtimeImplementationCount}',
    )
    ..writeln('- engine call count: ${result.engineCallCount}')
    ..writeln('- scheduler execution count: ${result.schedulerExecutionCount}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln()
    ..writeln(
      '| Row | Patch | Group | Type | Target surface | Metadata-only | Findings |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final row in result.rows) {
    buffer.writeln(
      '| ${row.diagnosticRowId} | ${row.patchId} | ${row.patchGroup} | ${row.patchType} | ${row.targetSurface} | ${row.appliedAsMetadataOnly} | ${_ids(row.findings)} |',
    );
  }
  buffer.writeln();
}

Map<String, Object?> _actionPlanJson() {
  final result =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
          .evaluate();
  return <String, Object?>{
    'status': result.status.wire,
    'safeForPhase34C': result.safeForPhase34C,
    'nextRecommendation': result.nextRecommendation,
    'counts': <String, Object?>{
      'totalActions': result.totalActions,
      'safeInternalSupportActionCount': result.safeInternalSupportActionCount,
      'warningLimitedFollowupActionCount':
          result.warningLimitedFollowupActionCount,
      'proofBoundaryActionCount': result.proofBoundaryActionCount,
      'excludedGuardActionCount': result.excludedGuardActionCount,
      'deniedFieldProtectionActionCount':
          result.deniedFieldProtectionActionCount,
      'blockedIntegrationActionCount': result.blockedIntegrationActionCount,
      'activeDeniedFieldCount': result.activeDeniedFieldCount,
      'analyzerWiringCount': result.analyzerWiringCount,
      'runtimeImplementationCount': result.runtimeImplementationCount,
      'engineCallCount': result.engineCallCount,
      'schedulerExecutionCount': result.schedulerExecutionCount,
    },
  };
}

Map<String, Object?> _patchSetJson() {
  final result =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
          .evaluate();
  return <String, Object?>{
    'status': result.status.wire,
    'safeForPhase34D': result.safeForPhase34D,
    'nextRecommendation': result.nextRecommendation,
    'counts': <String, Object?>{
      'totalPatchRecords': result.totalPatchRecords,
      'supportTraceabilityPatchCount': result.supportTraceabilityPatchCount,
      'warningFollowupMarkerPatchCount': result.warningFollowupMarkerPatchCount,
      'proofBoundaryMarkerPatchCount': result.proofBoundaryMarkerPatchCount,
      'excludedGuardPreservationPatchCount':
          result.excludedGuardPreservationPatchCount,
      'deniedFieldProtectionPatchCount': result.deniedFieldProtectionPatchCount,
      'blockedIntegrationSentinelPatchCount':
          result.blockedIntegrationSentinelPatchCount,
      'phase34DPracticalDiagnosticRequirementPatchCount':
          result.phase34DPracticalDiagnosticRequirementPatchCount,
      'activeDeniedFieldCount': result.activeDeniedFieldCount,
      'analyzerWiringCount': result.analyzerWiringCount,
      'runtimeImplementationCount': result.runtimeImplementationCount,
      'engineCallCount': result.engineCallCount,
      'schedulerExecutionCount': result.schedulerExecutionCount,
    },
  };
}

Map<String, Object?> _metadataRefinementJson(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult result,
) {
  return <String, Object?>{
    'status': result.status.wire,
    'sourceDiagnosticStatus': result.sourceDiagnosticStatus,
    'sourcePatchSetStatus': result.sourcePatchSetStatus,
    'safeForPhase34F': result.safeForPhase34F,
    'nextRecommendation': result.nextRecommendation,
    'sourcePhaseChain': const <String>[
      'Phase 34B action plan',
      'Phase 34C patch set',
      'Phase 34D patch-set diagnostic',
      'Phase 34E metadata refinement',
    ],
    'targetSurfaceCounts': result.targetSurfaceCounts,
    'allowedTargetSurfaces': result.allowedTargetSurfaces,
    'forbiddenTargetSurfaces': result.forbiddenTargetSurfaces,
    'counts': <String, Object?>{
      'totalRefinementRecords': result.totalRefinementRecords,
      'supportTraceabilityMetadataRefinementCount':
          result.supportTraceabilityMetadataRefinementCount,
      'warningReasonMetadataRefinementCount':
          result.warningReasonMetadataRefinementCount,
      'proofBoundaryMetadataRefinementCount':
          result.proofBoundaryMetadataRefinementCount,
      'excludedGuardMetadataRefinementCount':
          result.excludedGuardMetadataRefinementCount,
      'deniedFieldMetadataRefinementCount':
          result.deniedFieldMetadataRefinementCount,
      'blockedIntegrationMetadataRefinementCount':
          result.blockedIntegrationMetadataRefinementCount,
      'targetSurfaceMetadataRefinementCount':
          result.targetSurfaceMetadataRefinementCount,
      'diagnosticSummaryMetadataRefinementCount':
          result.diagnosticSummaryMetadataRefinementCount,
      'phase34FDiagnosticRequirementRefinementCount':
          result.phase34FDiagnosticRequirementRefinementCount,
      'unsafeCount': result.unsafeCount,
      'blockerCount': result.blockerCount,
      'criticalCount': result.criticalCount,
      'activeDeniedFieldCount': result.activeDeniedFieldCount,
      'analyzerWiringCount': result.analyzerWiringCount,
      'runtimeImplementationCount': result.runtimeImplementationCount,
      'engineCallCount': result.engineCallCount,
      'schedulerExecutionCount': result.schedulerExecutionCount,
      'productOutputCount': result.productOutputCount,
      'ownerProofQueueCount': result.ownerProofQueueCount,
    },
  };
}

String _renderGoldenCaseListMarkdown(List<GoldenAnalysisCase> cases) {
  final sorted = cases.toList()..sort((a, b) => a.id.compareTo(b.id));
  final buffer = StringBuffer()
    ..writeln(
      '# Debug-Only Bridge Analyzer Adapter Prototype Golden Case Selection',
    )
    ..writeln()
    ..writeln(
      '- version: $debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion',
    )
    ..writeln('- default selection: $_defaultSelectedGoldenSelection')
    ..writeln('- expanded selection: $_allSafeSelectedGoldenSelection')
    ..writeln('- next recommendation: $_phase34ARecommendation')
    ..writeln()
    ..writeln(
      '| Case ID | Title | Category | Source phase | Default | All safe |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- |');
  for (final item in sorted) {
    buffer.writeln(
      '| ${item.id} | ${item.title} | ${item.category.wire} | '
      '${_sourcePhaseForCase(item)} | '
      '${_defaultSelectedGoldenCaseIds.contains(item.id)} | '
      '${_allSafeSelectedGoldenCaseIds.contains(item.id)} |',
    );
  }
  return buffer.toString();
}

String _renderGoldenCaseListJson(List<GoldenAnalysisCase> cases) {
  final sorted = cases.toList()..sort((a, b) => a.id.compareTo(b.id));
  return const JsonEncoder.withIndent(' ').convert(<String, Object?>{
    'version': debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion,
    'defaultSelection': _defaultSelectedGoldenSelection,
    'expandedSelection': _allSafeSelectedGoldenSelection,
    'nextRecommendation': _phase34ARecommendation,
    'cases': sorted
        .map(
          (item) => <String, Object?>{
            'caseId': item.id,
            'title': item.title,
            'category': item.category.wire,
            'sourcePhase': _sourcePhaseForCase(item),
            'includedInDefaultSelection': _defaultSelectedGoldenCaseIds
                .contains(item.id),
            'includedInAllSafeSelection': _allSafeSelectedGoldenCaseIds
                .contains(item.id),
          },
        )
        .toList(growable: false),
  });
}

class _SelectedGoldenDiagnosticBuildResult {
  const _SelectedGoldenDiagnosticBuildResult.result(this.result)
    : failure = null;

  const _SelectedGoldenDiagnosticBuildResult.failure(this.failure)
    : result = null;

  final DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult?
  result;
  final String? failure;
}

_SelectedGoldenDiagnosticBuildResult _buildSelectedGoldenDiagnosticIfRequested(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandRequest request,
  List<GoldenAnalysisCase> cases,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult sourceDiagnostic,
) {
  if (request.goldenCaseSelection == null &&
      request.section !=
          DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.golden) {
    return const _SelectedGoldenDiagnosticBuildResult.result(null);
  }

  final selection =
      request.goldenCaseSelection ?? _defaultSelectedGoldenSelection;
  final ids = _resolveSelectedGoldenCaseIds(selection, cases);
  if (ids == null) {
    return const _SelectedGoldenDiagnosticBuildResult.failure(
      'unknownGoldenCase',
    );
  }
  final byId = {for (final item in cases) item.id: item};
  if (ids.any((id) => !byId.containsKey(id))) {
    return const _SelectedGoldenDiagnosticBuildResult.failure(
      'configuredGoldenCaseMissing',
    );
  }

  final rows = ids
      .map((id) => _selectedGoldenRowForCase(byId[id]!))
      .toList(growable: false);
  return _SelectedGoldenDiagnosticBuildResult.result(
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticResult(
      selection: selection,
      rows: rows,
      sourceDiagnostic: sourceDiagnostic,
    ),
  );
}

List<String>? _resolveSelectedGoldenCaseIds(
  String selection,
  List<GoldenAnalysisCase> cases,
) {
  if (selection == _defaultSelectedGoldenSelection) {
    return _defaultSelectedGoldenCaseIds;
  }
  if (selection == _allSafeSelectedGoldenSelection) {
    return _allSafeSelectedGoldenCaseIds;
  }
  if (cases.any((item) => item.id == selection)) {
    return <String>[selection];
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRow
_selectedGoldenRowForCase(GoldenAnalysisCase item) {
  final role = _selectedGoldenRoleForCase(item);
  final supportAreaIds = _supportAreaIdsForCase(item);
  final proofLimitReasons = <String>[
    if (_phase32ECaseIds.contains(item.id)) 'phase32ECaseIsNotCapturedProof',
    if (item.id == _pvMultiPvBoundaryCaseId)
      'pvMultiPvBoundaryWatchListOnlyNoOwnerProof',
    if (role ==
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .excludedNegativeGuard)
      'quietPreparatoryExcludedFromActiveDiagnosticInput',
  ];
  final warningReasons = <String>[
    'developerOnlySelectedGoldenAnalyzerAdapterPrototypeDiagnosticNoEngineExecution',
    if (role ==
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .warningLimited)
      'diagnosticCoverageIsWarningLimited',
    if (role ==
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .proofBoundaryOnly)
      'proofBoundaryOnlyNoCapturedAndroidProofClaim',
    if (role ==
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .excludedNegativeGuard)
      'negativeGuardOnlyNotDiagnosticInputSupport',
  ];
  final androidProofIds =
      _capturedAndroidProofIds.contains(item.id) &&
          !_phase32ECaseIds.contains(item.id)
      ? <String>[item.id]
      : const <String>[];

  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRow(
    caseId: item.id,
    title: item.title,
    sourcePhase: _sourcePhaseForCase(item),
    selectedReason: _selectedReasonForCase(item),
    diagnosticRole: role,
    supportAreaIds: supportAreaIds,
    warningReasons: warningReasons,
    proofLimitReasons: proofLimitReasons,
    androidProofIds: androidProofIds,
    ownerProofRequired: false,
    activeDeniedFieldIds: const <String>[],
    blockedBoundaryIds: _blockedBoundaryIdsForCase(item, role),
    recommendation: _phase34ARecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
_selectedGoldenRoleForCase(GoldenAnalysisCase item) {
  if (_isQuietPreparatoryCase(item)) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
        .excludedNegativeGuard;
  }
  if (item.id == _pvMultiPvBoundaryCaseId) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
        .proofBoundaryOnly;
  }
  if (_phase32ECaseIds.contains(item.id) ||
      item.category == GoldenAnalysisCategory.budgetPressure) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
        .warningLimited;
  }
  if (item.category == GoldenAnalysisCategory.endgamePrecision ||
      item.category == GoldenAnalysisCategory.openingKnownSkip ||
      item.category == GoldenAnalysisCategory.forcedMoveSkip) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
        .contextOnly;
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
      .developerDiagnosticInputSupport;
}

List<String> _supportAreaIdsForCase(GoldenAnalysisCase item) {
  return <String>{
    item.category.wire,
    item.sourceType.wire,
    item.evidenceIntent.wire,
    ...item.motifTags.map((tag) => tag.wire),
    if (_phase32ECaseIds.contains(item.id)) 'phase32E',
    if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvBoundary',
    if (_capturedAndroidProofIds.contains(item.id)) 'capturedAndroidProof',
  }.where((value) => value.trim().isNotEmpty).toList()..sort();
}

List<String> _blockedBoundaryIdsForCase(
  GoldenAnalysisCase item,
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole role,
) {
  return <String>{
    ..._selectedGoldenAlwaysBlockedBoundaryIds,
    if (_phase32ECaseIds.contains(item.id)) 'phase32ECapturedAndroidProofClaim',
    if (item.id == _pvMultiPvBoundaryCaseId) 'pvMultiPvOwnerProofEscalation',
    if (role ==
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .excludedNegativeGuard)
      'quietPreparatoryDiagnosticInputPromotion',
  }.toList()..sort();
}

String _selectedReasonForCase(GoldenAnalysisCase item) {
  return _selectedReasonByCaseId[item.id] ??
      switch (_selectedGoldenRoleForCase(item)) {
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .excludedNegativeGuard =>
          'quiet/preparatory negative guard remains excluded from active diagnostic input',
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .proofBoundaryOnly =>
          'PV/MultiPV boundary watch-list evidence only',
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .warningLimited =>
          'warning-limited selected Golden diagnostic coverage',
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .contextOnly =>
          'context-only selected Golden diagnostic coverage',
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .developerDiagnosticInputSupport =>
          'developer-only analyzer adapter prototype diagnostic support coverage',
      };
}

String _sourcePhaseForCase(GoldenAnalysisCase item) {
  if (_phase32ECaseIds.contains(item.id) ||
      item.notes.any((note) => note.contains('Phase 32E'))) {
    return 'Phase 32E';
  }
  if (item.notes.any((note) => note.contains('Phase 30W'))) {
    return 'Phase 30W';
  }
  return 'existing';
}

bool _isQuietPreparatoryCase(GoldenAnalysisCase item) {
  return item.category == GoldenAnalysisCategory.quietPreparatoryMove ||
      item.motifTags.any(
        (tag) =>
            tag == GoldenMotifTag.quietMove ||
            tag == GoldenMotifTag.quietPreparatoryMove,
      );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus _diagnosticStatus(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
  validation,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult harness,
) {
  final sourceSafe =
      validation.safeForPhase33Y &&
      validation.phase33YRecommendation == _phase33YRequirement &&
      !validation.hasUnsafePolicyViolation &&
      harness.safeForPhase33X &&
      harness.phase33XRecommendation == _phase33XRequirement &&
      !harness.hasUnsafePolicyViolation;
  if (!sourceSafe) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .blockedByUnsafeInspectionHarnessValidation;
  }
  if (_phase33ZRecommendation.isEmpty) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .invalidPrototypeDiagnosticCommand;
  }
  if (validation.unsafeCount > 0 || harness.unsafeCount > 0) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .blockedByPolicyBoundary;
  }
  if (validation.warningCheckCount > 0 ||
      harness.status ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .prototypeInspectionReadyWithWarnings) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
        .prototypeDiagnosticCommandReadyWithWarnings;
  }
  return DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
      .prototypeDiagnosticCommandReadyClean;
}

bool _includeSection(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection selected,
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection target,
) {
  return selected ==
          DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all ||
      selected == target;
}

List<String> _warnings(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return _sorted(<String>[
    ...diagnostic.harnessResult.snapshot.warningReasons,
    ...diagnostic.validationResult.validationRows.expand(
      (row) => row.warningReasons,
    ),
  ]);
}

List<String> _futurePrerequisites(
  DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticResult diagnostic,
) {
  return _sorted(
    diagnostic.validationResult.validationRows
        .where(
          (row) =>
              row.validationRole ==
              DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                  .futureRequirementValidation,
        )
        .expand((row) => row.allowedFieldIds),
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat? _formatByWire(
  String wire,
) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection? _sectionByWire(
  String wire,
) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.values) {
    if (section.wire == wire) return section;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode?
_patchDiagnosticModeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode?
_refinementDiagnosticModeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
          .values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode?
_runtimePreparationDiagnosticModeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
          .values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode?
_disabledRuntimeSkeletonDiagnosticModeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
          .values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode?
_runtimeExecutionPreflightDiagnosticModeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
          .values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

bool _isCriticalFinding(String finding) =>
    finding.startsWith('reportTextLeak:');

String _ids(Iterable<String> values) {
  final sorted = _sorted(values);
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _mapSummary(Map<String, Object?> values) {
  if (values.isEmpty) return '-';
  final entries = values.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
}

List<String> _sorted(Iterable<String> values) {
  return values.where((value) => value.trim().isNotEmpty).toSet().toList()
    ..sort();
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|snapshot|packets|policy|records|proof|boundaries|runtime|recommendation|action-plan|patches|metadata-refinement|runtime-preparation|disabled-runtime-skeleton|runtime-execution-preflight|golden] [--patch-diagnostic=default|all-safe|support|warning|proof|guards|denied|blocked|recommendation] [--refinement-diagnostic=default|all-safe|support|warning|proof|guards|denied|blocked|surfaces|recommendation] [--runtime-preparation-diagnostic=default|all-safe|envelopes|preconditions|policy|blocked-seams|denied|proof|recommendation] [--disabled-runtime-skeleton-diagnostic=default|all-safe|request|response|attempt|policy|blocked-seams|denied|proof|recommendation] [--runtime-execution-preflight-diagnostic=default|all-safe|checks|decision|blocked-reasons|denied|proof|recommendation] [--golden-case=<caseId>|default-selected|all-safe-selected] [--list-golden-cases]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _goldenCaseFlag = '--golden-case=';
const _patchDiagnosticFlag = '--patch-diagnostic=';
const _refinementDiagnosticFlag = '--refinement-diagnostic=';
const _runtimePreparationDiagnosticFlag = '--runtime-preparation-diagnostic=';
const _disabledRuntimeSkeletonDiagnosticFlag =
    '--disabled-runtime-skeleton-diagnostic=';
const _runtimeExecutionPreflightDiagnosticFlag =
    '--runtime-execution-preflight-diagnostic=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
const _listGoldenCasesFlag = '--list-golden-cases';

const _phase33XRequirement =
    'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness';
const _phase33YRequirement =
    'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand';
const _phase33ZRecommendation =
    'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun';
const _phase34ARecommendation =
    'validateSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun';

const _defaultSelectedGoldenSelection = 'default-selected';
const _allSafeSelectedGoldenSelection = 'all-safe-selected';
const _pvMultiPvBoundaryCaseId = 'pv-multipv-support-boundary-32e';

const _defaultSelectedGoldenCaseIds = <String>[
  'queen-win-major-swing',
  'forcing-line-variation-hard-case',
  'sacrifice-compensation-hard-case',
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
  'quiet-preparatory-hard-case',
];

const _allSafeSelectedGoldenCaseIds = <String>[
  ..._defaultSelectedGoldenCaseIds,
  'simple-tactical-capture-check',
  'mate-threat-fast-evidence',
  'material-sacrifice-compensation',
  'king-safety-mating-net-hard-case',
  'technical-endgame-conservative',
  'budget-pressure-candidates',
  'quiet-preparatory-uncertain',
  'suppression-forced-only-legal-32e',
];

const _phase32ECaseIds = <String>{
  'king-safety-mating-net-pressure-32e',
  'endgame-precision-candidate-spread-32e',
  'suppression-forced-only-legal-32e',
  'budget-pressure-wide-candidate-32e',
  _pvMultiPvBoundaryCaseId,
};

const _capturedAndroidProofIds = <String>{
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
};

const _selectedGoldenAlwaysBlockedBoundaryIds = <String>{
  'androidCollectorExecution',
  'analyzerWiring',
  'backendTarget',
  'classifierLabels',
  'cpLoss',
  'directEngineCall',
  'engineResults',
  'executablePrototypeBehavior',
  'finalMoveLabels',
  'moveRanking',
  'numericMoveScores',
  'officialMetrics',
  'persistenceWrite',
  'productAdapterBehavior',
  'productOutput',
  'pvDump',
  'rawUci',
  'runtimeImplementation',
  'savedAnalysisIntegration',
  'schedulerExecution',
  'stockfishCommand',
  'thresholds',
  'uiTarget',
  'winProbability',
};

const _selectedReasonByCaseId = <String, String>{
  'queen-win-major-swing':
      'tactical/material swing case inspected as safe developer diagnostic support',
  'forcing-line-variation-hard-case':
      'forcing-line case inspected as safe developer diagnostic support',
  'sacrifice-compensation-hard-case':
      'candidate-spread material case inspected as safe developer diagnostic support',
  'king-safety-mating-net-pressure-32e':
      'Phase 32E king-safety and mating-net case kept warning-limited without captured proof claim',
  'endgame-precision-candidate-spread-32e':
      'Phase 32E endgame candidate-spread case kept warning-limited',
  'budget-pressure-wide-candidate-32e':
      'Phase 32E budget-pressure case kept warning-limited',
  _pvMultiPvBoundaryCaseId:
      'Phase 32E PV/MultiPV case kept proof-boundary and watch-list only',
  'quiet-preparatory-hard-case':
      'quiet/preparatory negative guard inspected only as excluded guard',
  'simple-tactical-capture-check':
      'tactical capture/check case inspected with captured Android proof boundary preserved',
  'mate-threat-fast-evidence':
      'mate-threat fast-evidence case inspected with captured Android proof boundary preserved',
  'material-sacrifice-compensation':
      'material compensation case inspected as safe developer diagnostic support',
  'king-safety-mating-net-hard-case':
      'king-safety hard case inspected as safe developer diagnostic support',
  'technical-endgame-conservative':
      'technical endgame case kept context-only for conservative inspection',
  'budget-pressure-candidates': 'budget-pressure case kept warning-limited',
  'quiet-preparatory-uncertain':
      'quiet/preparatory uncertain negative guard inspected only as excluded guard',
  'suppression-forced-only-legal-32e':
      'Phase 32E forced-only suppression case kept warning-limited',
};
