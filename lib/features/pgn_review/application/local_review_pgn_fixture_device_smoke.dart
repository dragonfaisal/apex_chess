/// Developer-only selected-deep device smoke over compact PGN fixtures.
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_pgn_fixture_profiles.dart';

const String localReviewPgnFixtureDeviceSmokeFlag =
    'APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE';

const String localReviewPgnFixtureDeviceSmokePerformanceFlag =
    'APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE_PERFORMANCE';

bool isLocalReviewPgnFixtureDeviceSmokeEnabled({
  String flagValue = const String.fromEnvironment(
    localReviewPgnFixtureDeviceSmokeFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

bool isLocalReviewPgnFixtureDeviceSmokePerformanceEnabled({
  String flagValue = const String.fromEnvironment(
    localReviewPgnFixtureDeviceSmokePerformanceFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

enum LocalReviewPgnFixtureDeviceSmokeStatus {
  skipped('skipped'),
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  partialFailure('partialFailure'),
  failed('failed'),
  rejected('rejected');

  const LocalReviewPgnFixtureDeviceSmokeStatus(this.wire);

  final String wire;
}

class LocalReviewPgnFixtureDeviceSmokeRequest {
  const LocalReviewPgnFixtureDeviceSmokeRequest({
    this.fixtureIds = defaultFixtureIds,
    this.mode = LocalReviewIntegrationMode.fastThenExecuteSelectedDeep,
    this.maxFixtures = 2,
    this.maxPositionsPerFixture = 14,
    this.maxTotalEngineCalls = 32,
    this.maxTotalElapsedBudgetMs = 30000,
    this.failFast = false,
    this.requestId,
    this.includePerformancePreset = false,
    this.notes = const <String>[],
  }) : assert(maxFixtures >= 0),
       assert(maxPositionsPerFixture >= 0),
       assert(maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs >= 0);

  static const defaultFixtureIds = <String>[
    'quiet-opening-pgn',
    'tactical-middlegame-pgn',
  ];

  final List<String> fixtureIds;
  final LocalReviewIntegrationMode mode;
  final int maxFixtures;
  final int maxPositionsPerFixture;
  final int maxTotalEngineCalls;
  final int maxTotalElapsedBudgetMs;
  final bool failFast;
  final String? requestId;
  final bool includePerformancePreset;
  final List<String> notes;

  List<LocalReviewPgnFixtureProfileRun> profileRuns() {
    final runs = <LocalReviewPgnFixtureProfileRun>[
      _profileRun(LocalReviewIntegrationBudgetPreset.balancedDefault),
    ];
    if (includePerformancePreset) {
      runs.add(
        _profileRun(LocalReviewIntegrationBudgetPreset.performanceMeasured),
      );
    }
    return List.unmodifiable(runs);
  }

  LocalReviewPgnFixtureProfileRun _profileRun(
    LocalReviewIntegrationBudgetPreset preset,
  ) {
    return LocalReviewPgnFixtureProfileRun(
      budgetPreset: preset,
      mode: mode,
      maxPositions: maxPositionsPerFixture,
      maxTotalEngineCalls: _minInt(
        maxTotalEngineCalls,
        preset.maxTotalEngineCalls,
      ),
      maxTotalElapsedBudgetMs: _minInt(
        maxTotalElapsedBudgetMs,
        preset.maxTotalElapsedBudgetMs,
      ),
    );
  }
}

class LocalReviewPgnFixtureDeviceSmokeSummary {
  const LocalReviewPgnFixtureDeviceSmokeSummary({
    required this.fixtureId,
    required this.category,
    required this.presetId,
    required this.mode,
    required this.mappedPositions,
    required this.candidates,
    required this.selectedDeep,
    required this.executedDeep,
    required this.selectedRatio,
    required this.fastCalls,
    required this.deepCalls,
    required this.totalCalls,
    required this.elapsedMs,
    required this.budgetPressure,
    required this.warnings,
    required this.failures,
    required this.topReasonCounts,
    required this.suppressionCounts,
  }) : assert(mappedPositions >= 0),
       assert(candidates >= 0),
       assert(selectedDeep >= 0),
       assert(executedDeep >= 0),
       assert(selectedRatio >= 0),
       assert(fastCalls >= 0),
       assert(deepCalls >= 0),
       assert(totalCalls >= 0),
       assert(elapsedMs >= 0);

  factory LocalReviewPgnFixtureDeviceSmokeSummary.fromProfileResult(
    LocalReviewProfileComparisonResult entry,
  ) {
    return LocalReviewPgnFixtureDeviceSmokeSummary(
      fixtureId: entry.fixtureId,
      category: entry.fixtureCategory,
      presetId: entry.presetId,
      mode: entry.mode,
      mappedPositions: entry.mappedPositions,
      candidates: entry.pureCandidateCount,
      selectedDeep: entry.selectedDeepCount,
      executedDeep: entry.executedDeepCount,
      selectedRatio: entry.selectedDeepRatio,
      fastCalls: entry.fastEngineCalls,
      deepCalls: entry.deepEngineCalls,
      totalCalls: entry.totalEngineCalls,
      elapsedMs: entry.elapsedMs,
      budgetPressure: entry.budgetPressure,
      warnings: entry.warnings,
      failures: entry.failures,
      topReasonCounts: entry.topReasonCounts,
      suppressionCounts: entry.suppressionCounts,
    );
  }

  final String fixtureId;
  final LocalReviewPgnFixtureCategory category;
  final LocalReviewIntegrationBudgetPresetId presetId;
  final LocalReviewIntegrationMode mode;
  final int mappedPositions;
  final int candidates;
  final int selectedDeep;
  final int executedDeep;
  final double selectedRatio;
  final int fastCalls;
  final int deepCalls;
  final int totalCalls;
  final int elapsedMs;
  final LocalReviewIntegrationBudgetPressureSummary budgetPressure;
  final List<String> warnings;
  final List<String> failures;
  final Map<DeepCandidateReasonCode, int> topReasonCounts;
  final Map<DeepCandidateReasonCode, int> suppressionCounts;

  bool get selectedEveryMappedPosition =>
      mappedPositions > 1 && selectedDeep >= mappedPositions;

  bool get hasTimeout =>
      budgetPressure.timeoutCount > 0 || _containsAny(warnings, 'timeout');

  bool get hasBudgetPressure => budgetPressure.hasPressure;

  String get runId => '${presetId.wire}:${mode.wire}';

  Map<String, Object?> toJson() {
    return {
      'fixtureId': fixtureId,
      'category': category.wire,
      'preset': presetId.wire,
      'mode': mode.wire,
      'mappedPositions': mappedPositions,
      'candidates': candidates,
      'selectedDeep': selectedDeep,
      'executedDeep': executedDeep,
      'selectedRatio': selectedRatio,
      'fastCalls': fastCalls,
      'deepCalls': deepCalls,
      'totalCalls': totalCalls,
      'elapsedMs': elapsedMs,
      'budgetPressure': budgetPressure.debugSummary,
      'warnings': warnings,
      'failures': failures,
      'topReasonCounts': _reasonMapToJson(topReasonCounts),
      'suppressionCounts': _reasonMapToJson(suppressionCounts),
    };
  }
}

class LocalReviewPgnFixtureDeviceSmokeResult {
  const LocalReviewPgnFixtureDeviceSmokeResult({
    required this.status,
    required this.platform,
    required this.deviceLabel,
    required this.abi,
    required this.engineIdentity,
    required this.stubIdentityDetected,
    required this.fixtureRunCount,
    required this.presetRunCount,
    required this.summaries,
    required this.warnings,
    required this.failures,
    required this.recommendation,
  }) : assert(fixtureRunCount >= 0),
       assert(presetRunCount >= 0);

  factory LocalReviewPgnFixtureDeviceSmokeResult.skipped({
    String? platform,
    String? deviceLabel,
    String? abi,
    String reason = 'device smoke flag was not enabled',
  }) {
    return LocalReviewPgnFixtureDeviceSmokeResult(
      status: LocalReviewPgnFixtureDeviceSmokeStatus.skipped,
      platform: platform ?? 'unknown',
      deviceLabel: deviceLabel ?? 'unknown',
      abi: abi ?? 'unknown',
      engineIdentity: null,
      stubIdentityDetected: false,
      fixtureRunCount: 0,
      presetRunCount: 0,
      summaries: const <LocalReviewPgnFixtureDeviceSmokeSummary>[],
      warnings: <String>[reason],
      failures: const <String>[],
      recommendation: 'connect an Android target and rerun the opt-in smoke',
    );
  }

  final LocalReviewPgnFixtureDeviceSmokeStatus status;
  final String platform;
  final String deviceLabel;
  final String abi;
  final String? engineIdentity;
  final bool stubIdentityDetected;
  final int fixtureRunCount;
  final int presetRunCount;
  final List<LocalReviewPgnFixtureDeviceSmokeSummary> summaries;
  final List<String> warnings;
  final List<String> failures;
  final String recommendation;

  int get mappedPositions =>
      summaries.fold(0, (total, summary) => total + summary.mappedPositions);

  int get pureCandidateCount =>
      summaries.fold(0, (total, summary) => total + summary.candidates);

  int get selectedDeepCount =>
      summaries.fold(0, (total, summary) => total + summary.selectedDeep);

  int get executedDeepCount =>
      summaries.fold(0, (total, summary) => total + summary.executedDeep);

  int get fastEngineCalls =>
      summaries.fold(0, (total, summary) => total + summary.fastCalls);

  int get deepEngineCalls =>
      summaries.fold(0, (total, summary) => total + summary.deepCalls);

  int get totalEngineCalls =>
      summaries.fold(0, (total, summary) => total + summary.totalCalls);

  int get elapsedMs =>
      summaries.fold(0, (total, summary) => total + summary.elapsedMs);

  int get timeoutCount => summaries.fold(
    0,
    (total, summary) => total + (summary.hasTimeout ? 1 : 0),
  );

  int get warningCount =>
      warnings.length +
      summaries.fold(0, (total, summary) => total + summary.warnings.length);

  int get failureCount =>
      failures.length +
      summaries.fold(0, (total, summary) => total + summary.failures.length);

  int get budgetPressureCount =>
      summaries.where((summary) => summary.hasBudgetPressure).length;

  double get selectedDeepRatio {
    if (mappedPositions == 0) return 0;
    return selectedDeepCount / mappedPositions;
  }

  Map<String, Object?> toJson() {
    return {
      'status': status.wire,
      'platform': platform,
      'deviceLabel': deviceLabel,
      'abi': abi,
      'engineIdentity': engineIdentity,
      'stubIdentityDetected': stubIdentityDetected,
      'fixtureRunCount': fixtureRunCount,
      'presetRunCount': presetRunCount,
      'mappedPositions': mappedPositions,
      'pureCandidateCount': pureCandidateCount,
      'selectedDeepCount': selectedDeepCount,
      'executedDeepCount': executedDeepCount,
      'selectedDeepRatio': selectedDeepRatio,
      'fastEngineCalls': fastEngineCalls,
      'deepEngineCalls': deepEngineCalls,
      'totalEngineCalls': totalEngineCalls,
      'elapsedMs': elapsedMs,
      'timeoutCount': timeoutCount,
      'warningCount': warningCount,
      'failureCount': failureCount,
      'budgetPressureCount': budgetPressureCount,
      'warnings': warnings,
      'failures': failures,
      'recommendation': recommendation,
      'summaries': summaries.map((summary) => summary.toJson()).toList(),
    };
  }

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdownReport() {
    final buffer = StringBuffer()
      ..writeln('# Local Review PGN Fixture Device Smoke')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- platform: $platform')
      ..writeln('- device: $deviceLabel')
      ..writeln('- ABI: $abi')
      ..writeln('- engine identity: ${engineIdentity ?? "unknown"}')
      ..writeln('- stub identity detected: $stubIdentityDetected')
      ..writeln('- fixture runs: $fixtureRunCount')
      ..writeln('- preset runs: $presetRunCount')
      ..writeln('- mapped positions: $mappedPositions')
      ..writeln('- candidates: $pureCandidateCount')
      ..writeln('- selected deep: $selectedDeepCount')
      ..writeln('- executed deep: $executedDeepCount')
      ..writeln('- selected deep ratio: ${_formatRatio(selectedDeepRatio)}')
      ..writeln('- fast engine calls: $fastEngineCalls')
      ..writeln('- deep engine calls: $deepEngineCalls')
      ..writeln('- total engine calls: $totalEngineCalls')
      ..writeln('- elapsed ms: $elapsedMs')
      ..writeln('- budget pressure rows: $budgetPressureCount')
      ..writeln('- timeouts: $timeoutCount')
      ..writeln('- warnings: $warningCount')
      ..writeln('- failures: $failureCount')
      ..writeln('- recommendation: $recommendation');

    if (summaries.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(
          '| Fixture | Preset | Mapped | Candidates | Selected | Executed | Ratio | Calls | Elapsed | Pressure |',
        )
        ..writeln(
          '| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |',
        );
      for (final summary in summaries) {
        buffer.writeln(
          '| ${summary.fixtureId} | ${summary.presetId.wire} | '
          '${summary.mappedPositions} | ${summary.candidates} | '
          '${summary.selectedDeep} | ${summary.executedDeep} | '
          '${_formatRatio(summary.selectedRatio)} | ${summary.totalCalls} | '
          '${summary.elapsedMs} | ${summary.hasBudgetPressure} |',
        );
      }
    }

    _writeLines(buffer, 'warnings', warnings);
    _writeLines(buffer, 'failures', failures);
    return buffer.toString().trimRight();
  }
}

class LocalReviewPgnFixtureDeviceSmokeCollector {
  const LocalReviewPgnFixtureDeviceSmokeCollector({
    required LocalReviewPgnFixtureProfileRunner runner,
    List<LocalReviewPgnIntegrationFixture> fixtures =
        LocalReviewPgnIntegrationFixtures.defaults,
  }) : _runner = runner,
       _fixtures = fixtures;

  final LocalReviewPgnFixtureProfileRunner _runner;
  final List<LocalReviewPgnIntegrationFixture> _fixtures;

  Future<LocalReviewPgnFixtureDeviceSmokeResult> run(
    LocalReviewPgnFixtureDeviceSmokeRequest request, {
    String platform = 'unknown',
    String deviceLabel = 'unknown',
    String abi = 'unknown',
    String? Function()? engineIdentityProvider,
  }) async {
    final selectedFixtures = _selectFixtures(request);
    final profileRuns = request.profileRuns();
    if (selectedFixtures.isEmpty || profileRuns.isEmpty) {
      return LocalReviewPgnFixtureDeviceSmokeResult(
        status: LocalReviewPgnFixtureDeviceSmokeStatus.rejected,
        platform: platform,
        deviceLabel: deviceLabel,
        abi: abi,
        engineIdentity: engineIdentityProvider?.call(),
        stubIdentityDetected: false,
        fixtureRunCount: 0,
        presetRunCount: profileRuns.length,
        summaries: const <LocalReviewPgnFixtureDeviceSmokeSummary>[],
        warnings: const <String>[],
        failures: const <String>['no selected fixtures or profile runs'],
        recommendation: 'provide compact PGN fixtures before running smoke',
      );
    }

    final comparison = await _runner.run(
      LocalReviewPgnFixtureComparisonRequest(
        fixtures: selectedFixtures,
        profileRuns: profileRuns,
        failFast: request.failFast,
        requestId: request.requestId,
      ),
    );
    final summaries = comparison.entries
        .map(LocalReviewPgnFixtureDeviceSmokeSummary.fromProfileResult)
        .toList(growable: false);
    final engineIdentity = engineIdentityProvider?.call();
    final warnings = <String>[
      ...request.notes,
      ...comparison.warnings,
      ..._warningGuardrails(request, summaries),
    ];
    final failures = <String>[
      ...comparison.failures,
      ..._failureGuardrails(request, summaries, engineIdentity),
    ];
    final stubIdentityDetected = _isStubIdentity(engineIdentity);
    final status = _statusFor(
      comparison: comparison,
      summaries: summaries,
      warnings: warnings,
      failures: failures,
      stubIdentityDetected: stubIdentityDetected,
    );

    return LocalReviewPgnFixtureDeviceSmokeResult(
      status: status,
      platform: platform,
      deviceLabel: deviceLabel,
      abi: abi,
      engineIdentity: engineIdentity,
      stubIdentityDetected: stubIdentityDetected,
      fixtureRunCount: selectedFixtures.length,
      presetRunCount: profileRuns.length,
      summaries: summaries,
      warnings: List<String>.unmodifiable(warnings),
      failures: List<String>.unmodifiable(failures),
      recommendation: _recommendationFor(status),
    );
  }

  List<LocalReviewPgnIntegrationFixture> _selectFixtures(
    LocalReviewPgnFixtureDeviceSmokeRequest request,
  ) {
    final requested = request.fixtureIds.toSet();
    final selected = [
      for (final fixture in _fixtures)
        if (requested.isEmpty || requested.contains(fixture.id)) fixture,
    ];
    return List.unmodifiable(selected.take(request.maxFixtures));
  }

  static List<String> _warningGuardrails(
    LocalReviewPgnFixtureDeviceSmokeRequest request,
    List<LocalReviewPgnFixtureDeviceSmokeSummary> summaries,
  ) {
    final out = <String>[];
    if (summaries.isEmpty) return out;
    if (summaries.every((summary) => summary.selectedDeep == 0)) {
      out.add('no selected-deep searches were planned or executed');
    }
    if (summaries.any((summary) => summary.hasBudgetPressure)) {
      out.add('budget pressure was reported by one or more fixture runs');
    }
    if (summaries.any((summary) => summary.hasTimeout)) {
      out.add('timeout warning was reported by one or more fixture runs');
    }
    final balanced = summaries.where(
      (summary) =>
          summary.presetId ==
          LocalReviewIntegrationBudgetPresetId.balancedDefault,
    );
    if (balanced.any((summary) => summary.selectedRatio >= 0.75)) {
      out.add('balancedDefault selected-deep ratio is high for smoke use');
    }
    if (summaries.fold(0, (total, summary) => total + summary.totalCalls) >
        request.maxTotalEngineCalls) {
      out.add('aggregate engine call count exceeded requested smoke cap');
    }
    return out;
  }

  static List<String> _failureGuardrails(
    LocalReviewPgnFixtureDeviceSmokeRequest request,
    List<LocalReviewPgnFixtureDeviceSmokeSummary> summaries,
    String? engineIdentity,
  ) {
    final out = <String>[];
    if (_isStubIdentity(engineIdentity)) {
      out.add('stub identity cannot be accepted as device smoke proof');
    }
    if (summaries.any((summary) => summary.selectedEveryMappedPosition)) {
      out.add('selected every mapped position for deep analysis');
    }
    final totalCalls = summaries.fold(
      0,
      (total, summary) => total + summary.totalCalls,
    );
    if (totalCalls > request.maxTotalEngineCalls) {
      out.add('total engine call cap exceeded');
    }
    return out;
  }

  static LocalReviewPgnFixtureDeviceSmokeStatus _statusFor({
    required LocalReviewPgnFixtureComparisonResult comparison,
    required List<LocalReviewPgnFixtureDeviceSmokeSummary> summaries,
    required List<String> warnings,
    required List<String> failures,
    required bool stubIdentityDetected,
  }) {
    if (summaries.isEmpty) {
      return LocalReviewPgnFixtureDeviceSmokeStatus.rejected;
    }
    if (failures.isNotEmpty || stubIdentityDetected) {
      final failedSummaries = summaries
          .where((summary) => summary.failures.isNotEmpty)
          .length;
      if (failedSummaries > 0 && failedSummaries < summaries.length) {
        return LocalReviewPgnFixtureDeviceSmokeStatus.partialFailure;
      }
      return LocalReviewPgnFixtureDeviceSmokeStatus.failed;
    }
    if (comparison.status == LocalReviewPgnFixtureComparisonStatus.failed) {
      return LocalReviewPgnFixtureDeviceSmokeStatus.failed;
    }
    if (warnings.isNotEmpty ||
        comparison.status ==
            LocalReviewPgnFixtureComparisonStatus.completedWithWarnings) {
      return LocalReviewPgnFixtureDeviceSmokeStatus.completedWithWarnings;
    }
    return LocalReviewPgnFixtureDeviceSmokeStatus.completed;
  }

  static String _recommendationFor(
    LocalReviewPgnFixtureDeviceSmokeStatus status,
  ) {
    return switch (status) {
      LocalReviewPgnFixtureDeviceSmokeStatus.completed =>
        'use device smoke facts to prepare a golden local analysis suite',
      LocalReviewPgnFixtureDeviceSmokeStatus.completedWithWarnings =>
        'review budget pressure and warning spikes before widening fixtures',
      LocalReviewPgnFixtureDeviceSmokeStatus.partialFailure ||
      LocalReviewPgnFixtureDeviceSmokeStatus.failed =>
        'fix selected-deep smoke blockers before the next review phase',
      LocalReviewPgnFixtureDeviceSmokeStatus.rejected =>
        'provide a valid fixture subset and explicit smoke budget',
      LocalReviewPgnFixtureDeviceSmokeStatus.skipped =>
        'rerun with the opt-in device smoke flag on Android',
    };
  }
}

Map<String, int> _reasonMapToJson(Map<DeepCandidateReasonCode, int> source) {
  return {for (final entry in source.entries) entry.key.wire: entry.value};
}

bool _containsAny(List<String> lines, String needle) {
  final lower = needle.toLowerCase();
  return lines.any((line) => line.toLowerCase().contains(lower));
}

bool _isStubIdentity(String? identity) {
  final lower = identity?.toLowerCase() ?? '';
  return lower.contains('apexchess-stub') || lower.contains('stub');
}

void _writeLines(StringBuffer buffer, String title, List<String> lines) {
  if (lines.isEmpty) return;
  buffer
    ..writeln()
    ..writeln('$title:');
  for (final line in lines.take(30)) {
    buffer.writeln('- $line');
  }
}

String _formatRatio(double value) => value.toStringAsFixed(2);

int _minInt(int a, int b) => a < b ? a : b;
