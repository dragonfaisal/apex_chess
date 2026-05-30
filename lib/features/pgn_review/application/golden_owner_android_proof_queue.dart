/// Opt-in owner Android proof queue for golden evidence targets.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';

const goldenOwnerAndroidProofQueueFlag =
    'APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE';

const goldenOwnerAndroidProofQueuePerformanceFlag =
    'APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE_PERFORMANCE';

const goldenOwnerAndroidProofQueueCommand =
    'flutter test integration_test/golden_owner_android_proof_queue_test.dart '
    '-d <android-device-id> '
    '--dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE=true';

const goldenOwnerAndroidProofQueuePerformanceCommand =
    '$goldenOwnerAndroidProofQueueCommand '
    '--dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE_PERFORMANCE=true';

bool isGoldenOwnerAndroidProofQueueEnabled({
  String flagValue = const String.fromEnvironment(
    goldenOwnerAndroidProofQueueFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

bool isGoldenOwnerAndroidProofQueuePerformanceEnabled({
  String flagValue = const String.fromEnvironment(
    goldenOwnerAndroidProofQueuePerformanceFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

enum GoldenOwnerAndroidProofQueueStatus {
  skipped('skipped'),
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  partialFailure('partialFailure'),
  failed('failed'),
  rejected('rejected');

  const GoldenOwnerAndroidProofQueueStatus(this.wire);

  final String wire;
}

enum GoldenOwnerAndroidProofCaseStatus {
  proofCaptured('proofCaptured'),
  proofCapturedWithWarnings('proofCapturedWithWarnings'),
  proofIncomplete('proofIncomplete'),
  proofFailed('proofFailed'),
  proofSkipped('proofSkipped');

  const GoldenOwnerAndroidProofCaseStatus(this.wire);

  final String wire;
}

enum GoldenOwnerAndroidProofNextAction {
  updateGoldenEvidence('updateGoldenEvidence'),
  rerunWithPerformance('rerunWithPerformance'),
  addFakeEvidence('addFakeEvidence'),
  investigateEngineResult('investigateEngineResult'),
  keepQueued('keepQueued');

  const GoldenOwnerAndroidProofNextAction(this.wire);

  final String wire;
}

class GoldenOwnerAndroidProofQueueRequest {
  const GoldenOwnerAndroidProofQueueRequest({
    this.targetCaseIds,
    this.maxTargets = 3,
    this.budgetPreset = LocalReviewIntegrationBudgetPreset.balancedDefault,
    this.maxTotalEngineCalls = 24,
    this.maxTotalElapsedBudgetMs = 30000,
    this.failFast = false,
    this.requestId = 'golden-owner-android-proof-queue',
    this.includePerformance = false,
    this.notes = const <String>[],
  }) : assert(maxTargets >= 0),
       assert(maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs >= 0);

  final List<String>? targetCaseIds;
  final int maxTargets;
  final LocalReviewIntegrationBudgetPreset budgetPreset;
  final int maxTotalEngineCalls;
  final int maxTotalElapsedBudgetMs;
  final bool failFast;
  final String? requestId;
  final bool includePerformance;
  final List<String> notes;

  List<String> resolveTargetCaseIds({
    List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
    GoldenEvidenceTriageRunner triageRunner =
        const GoldenEvidenceTriageRunner(),
  }) {
    final explicit = targetCaseIds;
    if (explicit != null) {
      return List<String>.unmodifiable(explicit.take(maxTargets));
    }
    final triage = triageRunner.run(
      GoldenEvidenceTriageRequest(cases: cases, maxProofTargets: maxTargets),
    );
    return triage.recommendedOwnerRunProofQueue.targetCaseIds;
  }

  List<LocalReviewIntegrationBudgetPreset> budgetPresets() {
    final runs = <LocalReviewIntegrationBudgetPreset>[budgetPreset];
    if (includePerformance &&
        budgetPreset.id !=
            LocalReviewIntegrationBudgetPresetId.performanceMeasured) {
      runs.add(LocalReviewIntegrationBudgetPreset.performanceMeasured);
    }
    return List<LocalReviewIntegrationBudgetPreset>.unmodifiable(runs);
  }
}

class GoldenOwnerAndroidProofCaseSummary {
  const GoldenOwnerAndroidProofCaseSummary({
    required this.caseId,
    required this.title,
    required this.category,
    required this.motifs,
    required this.expectedEvidenceGroups,
    required this.presetId,
    required this.selectedDeepCount,
    required this.executedDeepCount,
    required this.pvPresent,
    required this.multiPvLineCount,
    required this.topReasonCodes,
    required this.suppressions,
    required this.elapsedMs,
    required this.fastEngineCalls,
    required this.deepEngineCalls,
    required this.engineCalls,
    required this.warnings,
    required this.failures,
    required this.status,
    required this.nextAction,
  }) : assert(selectedDeepCount >= 0),
       assert(executedDeepCount >= 0),
       assert(multiPvLineCount >= 0),
       assert(elapsedMs >= 0),
       assert(fastEngineCalls >= 0),
       assert(deepEngineCalls >= 0),
       assert(engineCalls >= 0);

  final String caseId;
  final String title;
  final String category;
  final List<String> motifs;
  final List<String> expectedEvidenceGroups;
  final LocalReviewIntegrationBudgetPresetId presetId;
  final int selectedDeepCount;
  final int executedDeepCount;
  final bool pvPresent;
  final int multiPvLineCount;
  final List<String> topReasonCodes;
  final List<String> suppressions;
  final int elapsedMs;
  final int fastEngineCalls;
  final int deepEngineCalls;
  final int engineCalls;
  final List<String> warnings;
  final List<String> failures;
  final GoldenOwnerAndroidProofCaseStatus status;
  final GoldenOwnerAndroidProofNextAction nextAction;

  bool get wasExecuted =>
      status != GoldenOwnerAndroidProofCaseStatus.proofSkipped;

  bool get hasWarningOrIncomplete =>
      warnings.isNotEmpty ||
      status == GoldenOwnerAndroidProofCaseStatus.proofIncomplete ||
      status == GoldenOwnerAndroidProofCaseStatus.proofCapturedWithWarnings ||
      status == GoldenOwnerAndroidProofCaseStatus.proofSkipped;

  bool get hasFailure =>
      failures.isNotEmpty ||
      status == GoldenOwnerAndroidProofCaseStatus.proofFailed;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'caseId': caseId,
      'title': title,
      'category': category,
      'motifs': motifs,
      'expectedEvidenceGroups': expectedEvidenceGroups,
      'preset': presetId.wire,
      'selectedDeepCount': selectedDeepCount,
      'executedDeepCount': executedDeepCount,
      'pvPresent': pvPresent,
      'multiPvLineCount': multiPvLineCount,
      'topReasonCodes': topReasonCodes,
      'suppressions': suppressions,
      'elapsedMs': elapsedMs,
      'fastEngineCalls': fastEngineCalls,
      'deepEngineCalls': deepEngineCalls,
      'engineCalls': engineCalls,
      'warningCount': warnings.length,
      'failureCount': failures.length,
      'warnings': warnings,
      'failures': failures,
      'proofStatus': status.wire,
      'nextAction': nextAction.wire,
    };
  }
}

class GoldenOwnerAndroidProofQueueResult {
  const GoldenOwnerAndroidProofQueueResult({
    required this.status,
    required this.platform,
    required this.deviceLabel,
    required this.abi,
    required this.engineIdentity,
    required this.stubIdentityDetected,
    required this.targetCaseIds,
    required this.summaries,
    required this.warnings,
    required this.failures,
    required this.developerRecommendation,
    required this.ownerCommandGuidance,
  });

  factory GoldenOwnerAndroidProofQueueResult.skipped({
    String platform = 'unknown',
    String deviceLabel = 'unknown',
    String abi = 'unknown',
    String reason = 'golden owner Android proof queue flag was not enabled',
  }) {
    return GoldenOwnerAndroidProofQueueResult(
      status: GoldenOwnerAndroidProofQueueStatus.skipped,
      platform: platform,
      deviceLabel: deviceLabel,
      abi: abi,
      engineIdentity: null,
      stubIdentityDetected: false,
      targetCaseIds: const <String>[],
      summaries: const <GoldenOwnerAndroidProofCaseSummary>[],
      warnings: <String>[reason],
      failures: const <String>[],
      developerRecommendation:
          'rerun with the opt-in golden owner Android proof flag',
      ownerCommandGuidance: goldenOwnerAndroidProofQueueCommand,
    );
  }

  final GoldenOwnerAndroidProofQueueStatus status;
  final String platform;
  final String deviceLabel;
  final String abi;
  final String? engineIdentity;
  final bool stubIdentityDetected;
  final List<String> targetCaseIds;
  final List<GoldenOwnerAndroidProofCaseSummary> summaries;
  final List<String> warnings;
  final List<String> failures;
  final String developerRecommendation;
  final String ownerCommandGuidance;

  int get targetCaseCount => targetCaseIds.length;

  int get executedTargetCount => summaries
      .where((summary) => summary.wasExecuted)
      .map((summary) => summary.caseId)
      .toSet()
      .length;

  int get selectedDeepCount =>
      summaries.fold(0, (total, summary) => total + summary.selectedDeepCount);

  int get executedDeepCount =>
      summaries.fold(0, (total, summary) => total + summary.executedDeepCount);

  int get fastEngineCalls =>
      summaries.fold(0, (total, summary) => total + summary.fastEngineCalls);

  int get deepEngineCalls =>
      summaries.fold(0, (total, summary) => total + summary.deepEngineCalls);

  int get totalEngineCalls =>
      summaries.fold(0, (total, summary) => total + summary.engineCalls);

  int get elapsedMs =>
      summaries.fold(0, (total, summary) => total + summary.elapsedMs);

  int get timeoutCount =>
      _countLines(warnings, 'timeout') +
      summaries.fold(
        0,
        (total, summary) => total + _countLines(summary.warnings, 'timeout'),
      );

  int get warningCount =>
      warnings.length +
      summaries.fold(0, (total, summary) => total + summary.warnings.length);

  int get failureCount =>
      failures.length +
      summaries.fold(0, (total, summary) => total + summary.failures.length);

  int get budgetPressureCount =>
      _countLines(warnings, 'budget pressure') +
      summaries.fold(
        0,
        (total, summary) =>
            total + _countLines(summary.warnings, 'budget pressure'),
      );

  int get missingPvCount => summaries
      .where(
        (summary) =>
            summary.executedDeepCount > 0 &&
            !summary.pvPresent &&
            summary.status != GoldenOwnerAndroidProofCaseStatus.proofSkipped,
      )
      .length;

  int get insufficientMultiPvCount => summaries
      .where(
        (summary) => summary.warnings.any(
          (warning) => warning.toLowerCase().contains('insufficient multipv'),
        ),
      )
      .length;

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'status': status.wire,
      'platform': platform,
      'deviceLabel': deviceLabel,
      'abi': abi,
      'engineIdentity': engineIdentity,
      'stubIdentityDetected': stubIdentityDetected,
      'targetCaseCount': targetCaseCount,
      'executedTargetCount': executedTargetCount,
      'selectedDeepCount': selectedDeepCount,
      'executedDeepCount': executedDeepCount,
      'fastEngineCalls': fastEngineCalls,
      'deepEngineCalls': deepEngineCalls,
      'totalEngineCalls': totalEngineCalls,
      'elapsedMs': elapsedMs,
      'timeoutCount': timeoutCount,
      'warningCount': warningCount,
      'failureCount': failureCount,
      'budgetPressureCount': budgetPressureCount,
      'missingPvCount': missingPvCount,
      'insufficientMultiPvCount': insufficientMultiPvCount,
      'targetCaseIds': targetCaseIds,
      'summaries': summaries.map((summary) => summary.toJson()).toList(),
      'warnings': warnings,
      'failures': failures,
      'developerRecommendation': developerRecommendation,
      'ownerCommandGuidance': ownerCommandGuidance,
      'developerOnly': true,
      'productClaims': false,
    };
  }

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Golden Owner Android Proof Queue')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- platform: $platform')
      ..writeln('- device: $deviceLabel')
      ..writeln('- ABI: $abi')
      ..writeln('- engine identity: ${engineIdentity ?? "unknown"}')
      ..writeln('- stub identity detected: $stubIdentityDetected')
      ..writeln('- target cases: $targetCaseCount')
      ..writeln('- executed targets: $executedTargetCount')
      ..writeln('- selected deep: $selectedDeepCount')
      ..writeln('- executed deep: $executedDeepCount')
      ..writeln('- fast engine calls: $fastEngineCalls')
      ..writeln('- deep engine calls: $deepEngineCalls')
      ..writeln('- total engine calls: $totalEngineCalls')
      ..writeln('- elapsed ms: $elapsedMs')
      ..writeln('- timeouts: $timeoutCount')
      ..writeln('- warnings: $warningCount')
      ..writeln('- failures: $failureCount')
      ..writeln('- budget pressure rows: $budgetPressureCount')
      ..writeln('- missing PV rows: $missingPvCount')
      ..writeln('- insufficient MultiPV rows: $insufficientMultiPvCount')
      ..writeln('- recommendation: $developerRecommendation');

    if (summaries.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Target Proof Summary')
        ..writeln(
          '| Case | Preset | Proof Status | Selected | Executed | PV | MultiPV | Calls | Next Action |',
        )
        ..writeln(
          '| --- | --- | --- | ---: | ---: | --- | ---: | ---: | --- |',
        );
      for (final summary in summaries) {
        buffer.writeln(
          '| ${_cell(summary.caseId)} | ${summary.presetId.wire} | '
          '${summary.status.wire} | ${summary.selectedDeepCount} | '
          '${summary.executedDeepCount} | '
          '${summary.pvPresent ? "yes" : "no"} | '
          '${summary.multiPvLineCount} | ${summary.engineCalls} | '
          '${summary.nextAction.wire} |',
        );
      }
    }

    _writeLines(buffer, 'Warnings', warnings);
    _writeLines(buffer, 'Failures', failures);

    buffer
      ..writeln()
      ..writeln('## Owner Command Guidance')
      ..writeln('```powershell')
      ..writeln(ownerCommandGuidance)
      ..writeln('```')
      ..writeln()
      ..writeln(
        'This proof queue is opt-in owner evidence output. It does not update '
        'golden cases automatically and does not create product claims.',
      );

    return buffer.toString().trimRight();
  }
}

class GoldenOwnerAndroidProofQueueCollector {
  const GoldenOwnerAndroidProofQueueCollector({
    required LocalReviewIntegrationExperiment integration,
    this.triageRunner = const GoldenEvidenceTriageRunner(),
    this.cases = GoldenAnalysisCases.defaults,
    this.motifEvidencePolicy = const GoldenMotifEvidencePolicy(),
  }) : _integration = integration;

  final LocalReviewIntegrationExperiment _integration;
  final GoldenEvidenceTriageRunner triageRunner;
  final List<GoldenAnalysisCase> cases;
  final GoldenMotifEvidencePolicy motifEvidencePolicy;

  Future<GoldenOwnerAndroidProofQueueResult> run(
    GoldenOwnerAndroidProofQueueRequest request, {
    String platform = 'unknown',
    String deviceLabel = 'unknown',
    String abi = 'unknown',
    String? Function()? engineIdentityProvider,
  }) async {
    final stopwatch = Stopwatch()..start();
    final targetIds = request.resolveTargetCaseIds(
      cases: cases,
      triageRunner: triageRunner,
    );
    final caseById = <String, GoldenAnalysisCase>{
      for (final item in cases) item.id: item,
    };
    final summaries = <GoldenOwnerAndroidProofCaseSummary>[];
    final warnings = <String>[...request.notes];
    final failures = <String>[];

    if (targetIds.isEmpty) {
      return GoldenOwnerAndroidProofQueueResult(
        status: GoldenOwnerAndroidProofQueueStatus.rejected,
        platform: platform,
        deviceLabel: deviceLabel,
        abi: abi,
        engineIdentity: engineIdentityProvider?.call(),
        stubIdentityDetected: false,
        targetCaseIds: const <String>[],
        summaries: const <GoldenOwnerAndroidProofCaseSummary>[],
        warnings: warnings,
        failures: const <String>['no proof targets were selected'],
        developerRecommendation:
            'review triage output before running owner Android proof',
        ownerCommandGuidance: _commandGuidance(request),
      );
    }

    for (final preset in request.budgetPresets()) {
      for (final caseId in targetIds) {
        final remainingCalls =
            request.maxTotalEngineCalls - _engineCalls(summaries);
        final remainingMs =
            request.maxTotalElapsedBudgetMs - stopwatch.elapsedMilliseconds;
        final item = caseById[caseId];
        if (item == null) {
          summaries.add(
            _skippedSummary(
              caseId: caseId,
              title: 'unknown target',
              category: 'unknown',
              motifs: const <String>[],
              expectedEvidenceGroups: const <String>[],
              preset: preset,
              reason: 'target case was not found in the golden suite',
            ),
          );
          continue;
        }
        if (item.inputs.isEmpty) {
          summaries.add(
            _skippedSummary(
              caseId: item.id,
              title: item.title,
              category: item.category.wire,
              motifs: _motifs(item),
              expectedEvidenceGroups: _expectedEvidenceGroups(item),
              preset: preset,
              reason: 'case has no scheduler-ready inputs for owner proof',
            ),
          );
          continue;
        }
        if (remainingCalls <= 0 || remainingMs <= 0) {
          summaries.add(
            _skippedSummary(
              caseId: item.id,
              title: item.title,
              category: item.category.wire,
              motifs: _motifs(item),
              expectedEvidenceGroups: _expectedEvidenceGroups(item),
              preset: preset,
              reason: 'proof cap reached before case execution',
            ),
          );
          warnings.add('proof cap reached before ${item.id}');
          continue;
        }

        final result = await _integration.run(
          LocalReviewIntegrationExperimentRequest.fromSchedulerInputs(
            positions: item.inputs,
            budgetPreset: preset,
            mode: LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
            maxPositions: item.inputs.length,
            maxDeepCandidates:
                item.expected.maxDeepCandidates ?? preset.maxDeepCandidates,
            maxDeepEngineCalls: _minInt(
              remainingCalls,
              preset.maxDeepEngineCalls,
            ),
            maxTotalEngineCalls: _minInt(
              remainingCalls,
              preset.maxTotalEngineCalls,
            ),
            maxTotalElapsedBudgetMs: _minInt(
              remainingMs,
              preset.maxTotalElapsedBudgetMs,
            ),
            failFast: request.failFast,
            requestId: _runId(request.requestId, item.id, preset.id.wire),
          ),
        );
        summaries.add(_summaryFor(item, preset, request, result));

        if (_engineCalls(summaries) > request.maxTotalEngineCalls) {
          failures.add('total engine call cap exceeded');
          if (request.failFast) break;
        }
      }
      if (request.failFast && failures.isNotEmpty) break;
    }

    stopwatch.stop();
    final engineIdentity = engineIdentityProvider?.call();
    final stubIdentityDetected = _isStubIdentity(engineIdentity);
    if (stubIdentityDetected) {
      failures.add('stub identity cannot be accepted as golden proof');
    }
    warnings.addAll(_aggregateWarnings(request, summaries));
    failures.addAll(_aggregateFailures(summaries));

    final status = _statusFor(
      summaries: summaries,
      warnings: warnings,
      failures: failures,
      stubIdentityDetected: stubIdentityDetected,
    );

    return GoldenOwnerAndroidProofQueueResult(
      status: status,
      platform: platform,
      deviceLabel: deviceLabel,
      abi: abi,
      engineIdentity: engineIdentity,
      stubIdentityDetected: stubIdentityDetected,
      targetCaseIds: List<String>.unmodifiable(targetIds),
      summaries: List<GoldenOwnerAndroidProofCaseSummary>.unmodifiable(
        summaries,
      ),
      warnings: List<String>.unmodifiable(_sortedStrings(warnings)),
      failures: List<String>.unmodifiable(_sortedStrings(failures)),
      developerRecommendation: _recommendationFor(status),
      ownerCommandGuidance: _commandGuidance(request),
    );
  }

  GoldenOwnerAndroidProofCaseSummary _summaryFor(
    GoldenAnalysisCase item,
    LocalReviewIntegrationBudgetPreset preset,
    GoldenOwnerAndroidProofQueueRequest request,
    LocalReviewIntegrationExperimentResult result,
  ) {
    final primary = result.executionResult ?? result.purePlanResult;
    final pvPresent = _deepPvPresent(primary.deepExecutionResults);
    final multiPvLineCount = _maxDeepMultiPvLineCount(
      primary.deepExecutionResults,
    );
    final warnings = <String>[
      ...result.warnings,
      ..._caseWarnings(item, request, result, pvPresent, multiPvLineCount),
    ];
    final failures = <String>[
      ...result.failures,
      if (result.status == LocalReviewIntegrationStatus.failed)
        'local integration failed',
      if (result.status == LocalReviewIntegrationStatus.rejected)
        'local integration rejected the case',
    ];
    final status = _caseStatusFor(
      item: item,
      result: result,
      pvPresent: pvPresent,
      multiPvLineCount: multiPvLineCount,
      warnings: warnings,
      failures: failures,
    );
    return GoldenOwnerAndroidProofCaseSummary(
      caseId: item.id,
      title: item.title,
      category: item.category.wire,
      motifs: _motifs(item),
      expectedEvidenceGroups: _expectedEvidenceGroups(item),
      presetId: preset.id,
      selectedDeepCount: result.selectedDeepCount,
      executedDeepCount: result.executedDeepCount,
      pvPresent: pvPresent,
      multiPvLineCount: multiPvLineCount,
      topReasonCodes: _reasonWires(primary.selectedCandidates),
      suppressions: _suppressionWires(primary.suppressions),
      elapsedMs: result.totalElapsedMs,
      fastEngineCalls: result.fastEngineCalls,
      deepEngineCalls: result.deepEngineCalls,
      engineCalls: result.totalEngineCalls,
      warnings: List<String>.unmodifiable(_sortedStrings(warnings)),
      failures: List<String>.unmodifiable(_sortedStrings(failures)),
      status: status,
      nextAction: _nextActionFor(status, request),
    );
  }

  List<String> _expectedEvidenceGroups(GoldenAnalysisCase item) {
    final requirement = motifEvidencePolicy.requirementsFor(item.motifTags);
    final evidence = requirement.evidence.merge(
      item.expected.evidence.tactical,
    );
    return evidence.evidenceGroups.map((group) => group.wire).toList()..sort();
  }
}

GoldenOwnerAndroidProofCaseSummary _skippedSummary({
  required String caseId,
  required String title,
  required String category,
  required List<String> motifs,
  required List<String> expectedEvidenceGroups,
  required LocalReviewIntegrationBudgetPreset preset,
  required String reason,
}) {
  return GoldenOwnerAndroidProofCaseSummary(
    caseId: caseId,
    title: title,
    category: category,
    motifs: motifs,
    expectedEvidenceGroups: expectedEvidenceGroups,
    presetId: preset.id,
    selectedDeepCount: 0,
    executedDeepCount: 0,
    pvPresent: false,
    multiPvLineCount: 0,
    topReasonCodes: const <String>[],
    suppressions: const <String>[],
    elapsedMs: 0,
    fastEngineCalls: 0,
    deepEngineCalls: 0,
    engineCalls: 0,
    warnings: <String>[reason],
    failures: const <String>[],
    status: GoldenOwnerAndroidProofCaseStatus.proofSkipped,
    nextAction: GoldenOwnerAndroidProofNextAction.keepQueued,
  );
}

GoldenOwnerAndroidProofCaseStatus _caseStatusFor({
  required GoldenAnalysisCase item,
  required LocalReviewIntegrationExperimentResult result,
  required bool pvPresent,
  required int multiPvLineCount,
  required List<String> warnings,
  required List<String> failures,
}) {
  if (failures.isNotEmpty ||
      result.status == LocalReviewIntegrationStatus.failed ||
      result.status == LocalReviewIntegrationStatus.partialFailure ||
      result.status == LocalReviewIntegrationStatus.rejected) {
    return GoldenOwnerAndroidProofCaseStatus.proofFailed;
  }
  final expectsSelected = _expectsSelectedDeep(item);
  if (expectsSelected && result.selectedDeepCount == 0) {
    return GoldenOwnerAndroidProofCaseStatus.proofIncomplete;
  }
  if (expectsSelected && result.executedDeepCount == 0) {
    return GoldenOwnerAndroidProofCaseStatus.proofIncomplete;
  }
  if (item.expected.evidence.pvShouldBeNonEmpty && !pvPresent) {
    return GoldenOwnerAndroidProofCaseStatus.proofIncomplete;
  }
  final minMultiPv = item.expected.evidence.minMultiPvIfSelected;
  if (minMultiPv != null &&
      result.executedDeepCount > 0 &&
      multiPvLineCount < minMultiPv) {
    return GoldenOwnerAndroidProofCaseStatus.proofIncomplete;
  }
  if (warnings.isNotEmpty ||
      result.status == LocalReviewIntegrationStatus.completedWithWarnings) {
    return GoldenOwnerAndroidProofCaseStatus.proofCapturedWithWarnings;
  }
  return GoldenOwnerAndroidProofCaseStatus.proofCaptured;
}

GoldenOwnerAndroidProofNextAction _nextActionFor(
  GoldenOwnerAndroidProofCaseStatus status,
  GoldenOwnerAndroidProofQueueRequest request,
) {
  return switch (status) {
    GoldenOwnerAndroidProofCaseStatus.proofCaptured =>
      GoldenOwnerAndroidProofNextAction.updateGoldenEvidence,
    GoldenOwnerAndroidProofCaseStatus.proofCapturedWithWarnings =>
      GoldenOwnerAndroidProofNextAction.updateGoldenEvidence,
    GoldenOwnerAndroidProofCaseStatus.proofIncomplete =>
      request.includePerformance
          ? GoldenOwnerAndroidProofNextAction.keepQueued
          : GoldenOwnerAndroidProofNextAction.rerunWithPerformance,
    GoldenOwnerAndroidProofCaseStatus.proofFailed =>
      GoldenOwnerAndroidProofNextAction.investigateEngineResult,
    GoldenOwnerAndroidProofCaseStatus.proofSkipped =>
      GoldenOwnerAndroidProofNextAction.keepQueued,
  };
}

List<String> _caseWarnings(
  GoldenAnalysisCase item,
  GoldenOwnerAndroidProofQueueRequest request,
  LocalReviewIntegrationExperimentResult result,
  bool pvPresent,
  int multiPvLineCount,
) {
  final out = <String>[];
  if (result.budgetPressure.hasPressure) {
    out.add('budget pressure surfaced during proof run');
  }
  if (_expectsSelectedDeep(item) && result.selectedDeepCount == 0) {
    out.add('selected-deep evidence was expected but not selected');
  }
  if (_expectsSelectedDeep(item) &&
      result.selectedDeepCount > 0 &&
      result.executedDeepCount == 0) {
    out.add('selected-deep target was not executed');
  }
  if (item.expected.evidence.pvShouldBeNonEmpty && !pvPresent) {
    out.add('selected-deep evidence did not include PV presence');
  }
  final minMultiPv = item.expected.evidence.minMultiPvIfSelected;
  if (minMultiPv != null &&
      result.executedDeepCount > 0 &&
      multiPvLineCount < minMultiPv) {
    out.add(
      'insufficient MultiPV evidence: expected at least $minMultiPv line(s)',
    );
  }
  if (!request.includePerformance &&
      result.selectedDeepCount == 0 &&
      item.expected.expects(
        GoldenExpectedBehaviorCode.shouldSelectDeepUnderPerformance,
      )) {
    out.add('performance proof was not enabled for this run');
  }
  return out;
}

List<String> _aggregateWarnings(
  GoldenOwnerAndroidProofQueueRequest request,
  List<GoldenOwnerAndroidProofCaseSummary> summaries,
) {
  final out = <String>[];
  if (summaries.any(
    (summary) =>
        summary.status == GoldenOwnerAndroidProofCaseStatus.proofSkipped,
  )) {
    out.add('one or more proof targets were skipped');
  }
  if (summaries.any(
    (summary) =>
        summary.status == GoldenOwnerAndroidProofCaseStatus.proofIncomplete,
  )) {
    out.add('one or more proof targets remain incomplete');
  }
  if (_engineCalls(summaries) >= request.maxTotalEngineCalls) {
    out.add('aggregate engine call cap was reached');
  }
  return out;
}

List<String> _aggregateFailures(
  List<GoldenOwnerAndroidProofCaseSummary> summaries,
) {
  final out = <String>[];
  for (final summary in summaries) {
    if (summary.status == GoldenOwnerAndroidProofCaseStatus.proofFailed) {
      out.add('${summary.caseId}: proof failed');
    }
  }
  return out;
}

GoldenOwnerAndroidProofQueueStatus _statusFor({
  required List<GoldenOwnerAndroidProofCaseSummary> summaries,
  required List<String> warnings,
  required List<String> failures,
  required bool stubIdentityDetected,
}) {
  if (summaries.isEmpty) return GoldenOwnerAndroidProofQueueStatus.rejected;
  if (failures.isNotEmpty || stubIdentityDetected) {
    final failed = summaries
        .where(
          (summary) =>
              summary.status == GoldenOwnerAndroidProofCaseStatus.proofFailed,
        )
        .length;
    if (failed > 0 && failed < summaries.length) {
      return GoldenOwnerAndroidProofQueueStatus.partialFailure;
    }
    return GoldenOwnerAndroidProofQueueStatus.failed;
  }
  if (warnings.isNotEmpty ||
      summaries.any((summary) => summary.hasWarningOrIncomplete)) {
    return GoldenOwnerAndroidProofQueueStatus.completedWithWarnings;
  }
  return GoldenOwnerAndroidProofQueueStatus.completed;
}

String _recommendationFor(GoldenOwnerAndroidProofQueueStatus status) {
  return switch (status) {
    GoldenOwnerAndroidProofQueueStatus.completed =>
      'update golden evidence records from captured owner proof',
    GoldenOwnerAndroidProofQueueStatus.completedWithWarnings =>
      'review incomplete or warning rows before updating golden evidence',
    GoldenOwnerAndroidProofQueueStatus.partialFailure ||
    GoldenOwnerAndroidProofQueueStatus.failed =>
      'investigate proof failures before changing golden evidence',
    GoldenOwnerAndroidProofQueueStatus.rejected =>
      'select valid triage proof targets before running owner proof',
    GoldenOwnerAndroidProofQueueStatus.skipped =>
      'rerun with the opt-in golden owner Android proof flag',
  };
}

String _commandGuidance(GoldenOwnerAndroidProofQueueRequest request) {
  return request.includePerformance
      ? goldenOwnerAndroidProofQueuePerformanceCommand
      : goldenOwnerAndroidProofQueueCommand;
}

bool _expectsSelectedDeep(GoldenAnalysisCase item) {
  return item.expected.expects(
        GoldenExpectedBehaviorCode.shouldSelectDeepUnderBalanced,
      ) ||
      item.expected.expects(
        GoldenExpectedBehaviorCode.shouldSelectDeepUnderPerformance,
      ) ||
      item.expected.evidence.pvShouldBeNonEmpty ||
      item.expected.evidence.minMultiPvIfSelected != null;
}

bool _deepPvPresent(LocalReviewOrchestrationExperimentResult? deepRun) {
  final results = deepRun?.measuredResult.positionResults;
  if (results == null) return false;
  for (final result in results) {
    if (_snapshotHasPv(result.deepSnapshot)) return true;
  }
  return false;
}

int _maxDeepMultiPvLineCount(
  LocalReviewOrchestrationExperimentResult? deepRun,
) {
  final results = deepRun?.measuredResult.positionResults;
  if (results == null) return 0;
  var max = 0;
  for (final result in results) {
    max = _maxInt(max, _snapshotLineCount(result.deepSnapshot));
  }
  return max;
}

bool _snapshotHasPv(Object? snapshot) {
  if (snapshot == null) return false;
  final dynamic value = snapshot;
  final pvMoves = value.pvMoves as List<dynamic>;
  final engineLines = value.engineLines as List<dynamic>;
  return pvMoves.isNotEmpty ||
      engineLines.any((line) => (line.pvMoves as List<dynamic>).isNotEmpty);
}

int _snapshotLineCount(Object? snapshot) {
  if (snapshot == null) return 0;
  final dynamic value = snapshot;
  final engineLines = value.engineLines as List<dynamic>;
  return engineLines.length;
}

List<String> _reasonWires(List<DeepReanalysisCandidate> candidates) {
  final counts = <DeepCandidateReasonCode, int>{};
  for (final candidate in candidates) {
    for (final reason in candidate.reasonCodes) {
      if (reason == DeepCandidateReasonCode.budgetAllows) continue;
      counts[reason] = (counts[reason] ?? 0) + 1;
    }
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.wire.compareTo(b.key.wire);
    });
  return [
    for (final entry in entries.take(6)) '${entry.key.wire}:${entry.value}',
  ];
}

List<String> _suppressionWires(List<DeepCandidateSuppression> suppressions) {
  final counts = <DeepCandidateReasonCode, int>{};
  for (final suppression in suppressions) {
    counts[suppression.reasonCode] = (counts[suppression.reasonCode] ?? 0) + 1;
  }
  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      return a.key.wire.compareTo(b.key.wire);
    });
  return [
    for (final entry in entries.take(6)) '${entry.key.wire}:${entry.value}',
  ];
}

List<String> _motifs(GoldenAnalysisCase item) =>
    item.motifTags.map((motif) => motif.wire).toList()..sort();

int _engineCalls(List<GoldenOwnerAndroidProofCaseSummary> summaries) =>
    summaries.fold(0, (total, summary) => total + summary.engineCalls);

int _countLines(List<String> lines, String needle) {
  final lower = needle.toLowerCase();
  return lines.where((line) => line.toLowerCase().contains(lower)).length;
}

bool _isStubIdentity(String? identity) {
  final lower = identity?.toLowerCase() ?? '';
  return lower.contains('apexchess-stub') || lower.contains('stub');
}

String _runId(String? requestId, String caseId, String presetId) {
  final prefix = requestId ?? 'golden-owner-proof';
  return '$prefix:$caseId:$presetId';
}

List<String> _sortedStrings(List<String> values) {
  final out = values.toList();
  out.sort();
  return out;
}

void _writeLines(StringBuffer buffer, String title, List<String> lines) {
  if (lines.isEmpty) return;
  buffer
    ..writeln()
    ..writeln('## $title');
  for (final line in lines.take(30)) {
    buffer.writeln('- $line');
  }
}

String _cell(String value) => value.replaceAll('|', '/');

int _minInt(int a, int b) => a < b ? a : b;

int _maxInt(int a, int b) => a > b ? a : b;
