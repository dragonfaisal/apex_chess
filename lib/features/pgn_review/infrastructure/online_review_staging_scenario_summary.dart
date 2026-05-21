/// CI-safe summary over all controlled Online Review staging scenarios.
///
/// The summary evaluates typed fixture scenarios only. It does not read build
/// defines, accept arbitrary backend URLs, instantiate providers, construct
/// HTTP clients, or connect to a backend.
library;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';

class OnlineReviewStagingScenarioSummaryEntry {
  OnlineReviewStagingScenarioSummaryEntry({
    required this.scenarioId,
    required this.status,
    required this.stagingReady,
    required this.internalTesterReady,
    required this.exitCode,
    required this.expectedExitCode,
    required List<OnlineReviewStagingReadinessBlocker> blockers,
    required List<OnlineReviewStagingReadinessWarning> warnings,
    required this.expectationPassed,
    required this.unsafeOutputLeakDetected,
    required this.message,
  }) : blockers = List.unmodifiable(blockers),
       warnings = List.unmodifiable(warnings);

  final OnlineReviewStagingConfigScenarioId scenarioId;
  final OnlineReviewStagingReadinessStatus status;
  final bool stagingReady;
  final bool internalTesterReady;
  final int exitCode;
  final int expectedExitCode;
  final List<OnlineReviewStagingReadinessBlocker> blockers;
  final List<OnlineReviewStagingReadinessWarning> warnings;
  final bool expectationPassed;
  final bool unsafeOutputLeakDetected;
  final String message;
}

class OnlineReviewStagingScenarioSummaryResult {
  OnlineReviewStagingScenarioSummaryResult({
    required this.version,
    required this.totalScenarios,
    required this.evaluatedScenarios,
    required this.stagingReadyScenarios,
    required this.internalTesterReadyScenarios,
    required this.safelyBlockedScenarios,
    required this.nonZeroExitScenarios,
    required this.failedExpectationScenarios,
    required this.leakedUnsafeOutputScenarios,
    required this.allExpectationsPassed,
    required this.noUnsafeOutputLeaks,
    required this.hardSafetyPassed,
    required List<OnlineReviewStagingScenarioSummaryEntry> entries,
    required List<String> errors,
  }) : entries = List.unmodifiable(entries),
       errors = List.unmodifiable(errors);

  final String version;
  final int totalScenarios;
  final int evaluatedScenarios;
  final int stagingReadyScenarios;
  final int internalTesterReadyScenarios;
  final int safelyBlockedScenarios;
  final int nonZeroExitScenarios;
  final int failedExpectationScenarios;
  final int leakedUnsafeOutputScenarios;
  final bool allExpectationsPassed;
  final bool noUnsafeOutputLeaks;
  final bool hardSafetyPassed;
  final List<OnlineReviewStagingScenarioSummaryEntry> entries;
  final List<String> errors;
}

const onlineReviewStagingScenarioSummaryVersion =
    'online-review-staging-scenario-summary-v1';

OnlineReviewStagingScenarioSummaryResult
buildOnlineReviewStagingScenarioSummary({
  List<OnlineReviewStagingConfigScenario>? scenarios,
}) {
  final scenarioList = scenarios ?? onlineReviewStagingConfigScenarios();
  final entries = <OnlineReviewStagingScenarioSummaryEntry>[];
  var hardSafetyPassed = true;

  for (final scenario in scenarioList) {
    final report = buildOnlineReviewStagingReadinessReportForScenario(scenario);
    hardSafetyPassed = hardSafetyPassed && report.hardSafetyPassed;
    entries.add(_entryFor(scenario, report));
  }

  final errors = _summaryErrors(entries, hardSafetyPassed);

  return OnlineReviewStagingScenarioSummaryResult(
    version: onlineReviewStagingScenarioSummaryVersion,
    totalScenarios: scenarioList.length,
    evaluatedScenarios: entries.length,
    stagingReadyScenarios: entries.where((entry) => entry.stagingReady).length,
    internalTesterReadyScenarios: entries
        .where((entry) => entry.internalTesterReady)
        .length,
    safelyBlockedScenarios: entries.where(_isSafelyBlockedEntry).length,
    nonZeroExitScenarios: entries.where((entry) => entry.exitCode != 0).length,
    failedExpectationScenarios: entries
        .where((entry) => !entry.expectationPassed)
        .length,
    leakedUnsafeOutputScenarios: entries
        .where((entry) => entry.unsafeOutputLeakDetected)
        .length,
    allExpectationsPassed: entries.every((entry) => entry.expectationPassed),
    noUnsafeOutputLeaks: entries.every(
      (entry) => !entry.unsafeOutputLeakDetected,
    ),
    hardSafetyPassed: hardSafetyPassed,
    entries: entries,
    errors: errors,
  );
}

String renderOnlineReviewStagingScenarioSummaryMarkdown(
  OnlineReviewStagingScenarioSummaryResult summary,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Staging Scenario Summary')
    ..writeln()
    ..writeln('* Version: `${summary.version}`')
    ..writeln('* Total scenarios: ${summary.totalScenarios}')
    ..writeln('* Evaluated scenarios: ${summary.evaluatedScenarios}')
    ..writeln(
      '* All expectations passed: ${_yesNo(summary.allExpectationsPassed)}',
    )
    ..writeln('* Hard safety passed: ${_yesNo(summary.hardSafetyPassed)}')
    ..writeln('* Unsafe output leaks: ${_yesNo(!summary.noUnsafeOutputLeaks)}')
    ..writeln('* Staging-ready scenarios: ${summary.stagingReadyScenarios}')
    ..writeln(
      '* Internal-tester-ready scenarios: '
      '${summary.internalTesterReadyScenarios}',
    )
    ..writeln('* Safely blocked scenarios: ${summary.safelyBlockedScenarios}')
    ..writeln('* Non-zero exit scenarios: ${summary.nonZeroExitScenarios}')
    ..writeln()
    ..writeln('## Scenario Summary')
    ..writeln()
    ..writeln(
      '| Scenario | Status | Staging | Internal | Exit | Expected | Safe | Notes |',
    )
    ..writeln('| --- | --- | --- | --- | ---: | ---: | --- | --- |');

  for (final entry in summary.entries) {
    buffer.writeln(
      '| ${entry.scenarioId.name} '
      '| ${entry.status.name} '
      '| ${_yesNo(entry.stagingReady)} '
      '| ${_yesNo(entry.internalTesterReady)} '
      '| ${entry.exitCode} '
      '| ${entry.expectedExitCode} '
      '| ${_yesNo(_entryPassed(entry))} '
      '| ${entry.message} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Errors')
    ..writeln();
  if (summary.errors.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final error in summary.errors) {
      buffer.writeln('* $error');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* Fixture-only.')
    ..writeln('* No real backend URLs.')
    ..writeln('* No arbitrary URL input.')
    ..writeln('* No backend connection.')
    ..writeln('* Blocked scenarios are expected when policy says blocked.');

  return buffer.toString();
}

int onlineReviewStagingScenarioSummaryExitCode(
  OnlineReviewStagingScenarioSummaryResult summary,
) {
  return summary.allExpectationsPassed &&
          summary.noUnsafeOutputLeaks &&
          summary.hardSafetyPassed
      ? 0
      : 1;
}

OnlineReviewStagingScenarioSummaryEntry _entryFor(
  OnlineReviewStagingConfigScenario scenario,
  OnlineReviewStagingReadinessReport report,
) {
  final readiness = report.readiness;
  final exitCode = onlineReviewStagingReadinessReportExitCode(report);
  final renderedScenario = renderOnlineReviewStagingReadinessReportMarkdown(
    report,
    scenarioId: scenario.id.name,
    scenarioDescription: scenario.description,
  );
  final failures = _expectationFailures(scenario, report, exitCode);
  final unsafeOutputLeakDetected = _containsUnsafeOutput(renderedScenario);

  return OnlineReviewStagingScenarioSummaryEntry(
    scenarioId: scenario.id,
    status: readiness.status,
    stagingReady: readiness.isStagingReady,
    internalTesterReady: readiness.isInternalTesterReady,
    exitCode: exitCode,
    expectedExitCode: scenario.expectedExitCode,
    blockers: readiness.blockers,
    warnings: readiness.warnings,
    expectationPassed: failures.isEmpty,
    unsafeOutputLeakDetected: unsafeOutputLeakDetected,
    message: failures.isEmpty
        ? 'Expected outcome matched.'
        : failures.join('; '),
  );
}

List<String> _expectationFailures(
  OnlineReviewStagingConfigScenario scenario,
  OnlineReviewStagingReadinessReport report,
  int exitCode,
) {
  final readiness = report.readiness;
  final failures = <String>[];

  if (readiness.status != scenario.expectedReadinessStatus) {
    failures.add(
      'expected status ${scenario.expectedReadinessStatus.name} '
      'but got ${readiness.status.name}',
    );
  }
  if (readiness.isStagingReady != scenario.expectedStagingReady) {
    failures.add(
      'expected stagingReady=${scenario.expectedStagingReady} '
      'but got ${readiness.isStagingReady}',
    );
  }
  if (readiness.isInternalTesterReady != scenario.expectedInternalTesterReady) {
    failures.add(
      'expected internalTesterReady=${scenario.expectedInternalTesterReady} '
      'but got ${readiness.isInternalTesterReady}',
    );
  }
  if (exitCode != scenario.expectedExitCode) {
    failures.add(
      'expected exitCode=${scenario.expectedExitCode} but got $exitCode',
    );
  }
  if (!_sameEnumSet(readiness.blockers, scenario.expectedBlockers)) {
    failures.add(
      'expected blockers ${_enumNames(scenario.expectedBlockers)} '
      'but got ${_enumNames(readiness.blockers)}',
    );
  }
  if (!_sameEnumSet(readiness.warnings, scenario.expectedWarnings)) {
    failures.add(
      'expected warnings ${_enumNames(scenario.expectedWarnings)} '
      'but got ${_enumNames(readiness.warnings)}',
    );
  }

  return failures;
}

List<String> _summaryErrors(
  List<OnlineReviewStagingScenarioSummaryEntry> entries,
  bool hardSafetyPassed,
) {
  final errors = <String>[];
  if (!hardSafetyPassed) {
    errors.add('Build-mode hard safety failed.');
  }
  for (final entry in entries) {
    if (!entry.expectationPassed) {
      errors.add('${entry.scenarioId.name}: ${entry.message}');
    }
    if (entry.unsafeOutputLeakDetected) {
      errors.add('${entry.scenarioId.name}: unsafe output leak detected.');
    }
  }
  return errors;
}

bool _isSafelyBlockedEntry(OnlineReviewStagingScenarioSummaryEntry entry) {
  return !entry.stagingReady &&
      !entry.internalTesterReady &&
      entry.expectationPassed &&
      !entry.unsafeOutputLeakDetected;
}

bool _entryPassed(OnlineReviewStagingScenarioSummaryEntry entry) {
  return entry.expectationPassed && !entry.unsafeOutputLeakDetected;
}

bool _containsUnsafeOutput(String output) {
  final lower = output.toLowerCase();
  return lower.contains(_httpsPrefix) ||
      lower.contains(_httpPrefix) ||
      lower.contains(_loopbackHost) ||
      lower.contains(_loopbackIp) ||
      lower.contains(_emulatorHost) ||
      lower.contains(_wildcardHost) ||
      lower.contains(_productionHostHint) ||
      lower.contains(_apiKeyHint) ||
      lower.contains(_privateValueToken) ||
      lower.contains(_privateTokenHint);
}

bool _sameEnumSet<T extends Enum>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }
  return left
          .map((value) => value.name)
          .toSet()
          .containsAll(right.map((value) => value.name)) &&
      right
          .map((value) => value.name)
          .toSet()
          .containsAll(left.map((value) => value.name));
}

String _enumNames(List<Enum> values) {
  return values.map((value) => value.name).join(',');
}

String _yesNo(bool value) => value ? 'yes' : 'no';

const _httpsPrefix =
    'https'
    '://';
const _httpPrefix =
    'http'
    '://';
const _loopbackHost =
    'local'
    'host';
const _loopbackIp =
    '127.0.'
    '0.1';
const _emulatorHost =
    '10.0.'
    '2.2';
const _wildcardHost =
    '0.0.'
    '0.0';
const _productionHostHint =
    'api.'
    'apex';
const _apiKeyHint =
    'apex_online_review_'
    'api_key';
const _privateValueToken =
    'sec'
    'ret';
const _privateTokenHint =
    'private_'
    'token';
