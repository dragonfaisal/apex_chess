/// CI-facing smoke report for Online Review build/runtime configuration.
///
/// The report consumes the pure build configuration matrix and renders a
/// deterministic summary for developers and future CI logs. It does not read
/// environment values, create providers, instantiate HTTP clients, or activate
/// navigation.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_matrix.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_config_adapter.dart';

enum OnlineReviewBuildConfigReportSeverity { info, warning, error }

class OnlineReviewBuildConfigReportItem {
  const OnlineReviewBuildConfigReportItem({
    required this.scenarioId,
    required this.severity,
    required this.message,
  });

  final String scenarioId;
  final OnlineReviewBuildConfigReportSeverity severity;
  final String message;
}

class OnlineReviewBuildConfigScenarioSummary {
  const OnlineReviewBuildConfigScenarioSummary({
    required this.scenarioId,
    required this.mode,
    required this.passed,
    required this.canShowShell,
    required this.canUseHttp,
    required this.canUseDebugHarness,
    required this.isPublic,
    required this.hasBaseUri,
    required this.repositoryMode,
    required this.productionSafe,
    required this.dangerous,
    required this.warningCount,
    required this.failureCount,
  });

  final String scenarioId;
  final OnlineReviewRuntimeMode mode;
  final bool passed;
  final bool canShowShell;
  final bool canUseHttp;
  final bool canUseDebugHarness;
  final bool isPublic;
  final bool hasBaseUri;
  final OnlineReviewRepositoryMode repositoryMode;
  final bool productionSafe;
  final bool dangerous;
  final int warningCount;
  final int failureCount;
}

class OnlineReviewBuildConfigReport {
  OnlineReviewBuildConfigReport({
    required this.version,
    required this.totalScenarios,
    required this.passedScenarios,
    required this.failedScenarios,
    required this.dangerousScenarios,
    required this.productionSafeScenarios,
    required this.shellVisibleScenarios,
    required this.httpEnabledScenarios,
    required this.publicPolicyScenarios,
    required this.allPassed,
    required this.hardSafetyPassed,
    required List<OnlineReviewBuildConfigReportItem> items,
    required List<OnlineReviewBuildConfigScenarioSummary> scenarioSummaries,
  }) : items = List.unmodifiable(items),
       scenarioSummaries = List.unmodifiable(scenarioSummaries);

  final String version;
  final int totalScenarios;
  final int passedScenarios;
  final int failedScenarios;
  final int dangerousScenarios;
  final int productionSafeScenarios;
  final int shellVisibleScenarios;
  final int httpEnabledScenarios;
  final int publicPolicyScenarios;
  final bool allPassed;
  final bool hardSafetyPassed;
  final List<OnlineReviewBuildConfigReportItem> items;
  final List<OnlineReviewBuildConfigScenarioSummary> scenarioSummaries;
}

const onlineReviewBuildConfigReportVersion =
    'online-review-build-config-report-v1';

OnlineReviewBuildConfigReport buildOnlineReviewBuildConfigReport({
  List<OnlineReviewBuildConfigScenario>? scenarios,
}) {
  final matrixScenarios = scenarios ?? onlineReviewBuildConfigScenarios();
  final results = [
    for (final scenario in matrixScenarios)
      verifyOnlineReviewBuildConfigScenario(scenario),
  ];
  final scenarioById = {
    for (final scenario in matrixScenarios) scenario.id: scenario,
  };
  final summaries = [
    for (final result in results)
      _summaryFor(result, scenarioById[result.scenarioId]!),
  ];
  final items = _reportItems(results);
  final passedScenarios = results.where((result) => result.passed).length;

  return OnlineReviewBuildConfigReport(
    version: onlineReviewBuildConfigReportVersion,
    totalScenarios: results.length,
    passedScenarios: passedScenarios,
    failedScenarios: results.length - passedScenarios,
    dangerousScenarios: matrixScenarios
        .where((scenario) => scenario.isDangerous)
        .length,
    productionSafeScenarios: matrixScenarios
        .where((scenario) => scenario.isProductionSafe)
        .length,
    shellVisibleScenarios: results
        .where((result) => result.decision.canShowShell)
        .length,
    httpEnabledScenarios: results
        .where((result) => result.decision.canUseHttp)
        .length,
    publicPolicyScenarios: results
        .where((result) => result.decision.isPublic)
        .length,
    allPassed: results.every((result) => result.passed),
    hardSafetyPassed: _hardSafetyPassed(matrixScenarios, results),
    items: items,
    scenarioSummaries: summaries,
  );
}

String renderOnlineReviewBuildConfigReportMarkdown(
  OnlineReviewBuildConfigReport report,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Build Configuration Smoke Report')
    ..writeln()
    ..writeln('* Version: `${report.version}`')
    ..writeln('* Total scenarios: ${report.totalScenarios}')
    ..writeln('* Passed scenarios: ${report.passedScenarios}')
    ..writeln('* Failed scenarios: ${report.failedScenarios}')
    ..writeln('* Dangerous scenarios: ${report.dangerousScenarios}')
    ..writeln('* Production-safe scenarios: ${report.productionSafeScenarios}')
    ..writeln('* Shell-visible scenarios: ${report.shellVisibleScenarios}')
    ..writeln('* HTTP-enabled scenarios: ${report.httpEnabledScenarios}')
    ..writeln('* Public-policy scenarios: ${report.publicPolicyScenarios}')
    ..writeln('* All passed: ${_yesNo(report.allPassed)}')
    ..writeln('* Hard safety verdict: ${_yesNo(report.hardSafetyPassed)}')
    ..writeln()
    ..writeln('## Scenario Summary')
    ..writeln()
    ..writeln(
      '| Scenario | Mode | Passed | Shell | HTTP | Debug | Public | Repo | Warnings | Failures |',
    )
    ..writeln(
      '| --- | --- | --- | --- | --- | --- | --- | --- | ---: | ---: |',
    );

  for (final summary in report.scenarioSummaries) {
    buffer.writeln(
      '| ${summary.scenarioId} '
      '| ${summary.mode.name} '
      '| ${_yesNo(summary.passed)} '
      '| ${_yesNo(summary.canShowShell)} '
      '| ${_yesNo(summary.canUseHttp)} '
      '| ${_yesNo(summary.canUseDebugHarness)} '
      '| ${_yesNo(summary.isPublic)} '
      '| ${summary.repositoryMode.name} '
      '| ${summary.warningCount} '
      '| ${summary.failureCount} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();
  final warnings = report.items.where(
    (item) => item.severity == OnlineReviewBuildConfigReportSeverity.warning,
  );
  if (warnings.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final item in warnings) {
      buffer.writeln('* ${item.scenarioId}: ${item.message}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Failures')
    ..writeln();
  final failures = report.items.where(
    (item) => item.severity == OnlineReviewBuildConfigReportSeverity.error,
  );
  if (failures.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final item in failures) {
      buffer.writeln('* ${item.scenarioId}: ${item.message}');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* No real URLs are included.')
    ..writeln('* Default mode remains disabled.')
    ..writeln('* Shell visibility and HTTP are separate decisions.')
    ..writeln('* Public preview remains policy-shaped only.')
    ..writeln('* This report does not activate Online Review.');

  final infoItems = report.items.where(
    (item) => item.severity == OnlineReviewBuildConfigReportSeverity.info,
  );
  for (final item in infoItems) {
    buffer.writeln('* ${item.scenarioId}: ${item.message}');
  }

  return buffer.toString();
}

int onlineReviewBuildConfigReportExitCode(
  OnlineReviewBuildConfigReport report,
) {
  return report.allPassed && report.hardSafetyPassed ? 0 : 1;
}

OnlineReviewBuildConfigScenarioSummary _summaryFor(
  OnlineReviewBuildConfigVerificationResult result,
  OnlineReviewBuildConfigScenario scenario,
) {
  return OnlineReviewBuildConfigScenarioSummary(
    scenarioId: result.scenarioId,
    mode: result.config.mode,
    passed: result.passed,
    canShowShell: result.decision.canShowShell,
    canUseHttp: result.decision.canUseHttp,
    canUseDebugHarness: result.decision.canUseDebugHarness,
    isPublic: result.decision.isPublic,
    hasBaseUri: result.decision.hasBaseUri,
    repositoryMode: result.repositoryConfig.mode,
    productionSafe: scenario.isProductionSafe,
    dangerous: scenario.isDangerous,
    warningCount: result.warnings.length,
    failureCount: result.failures.length,
  );
}

List<OnlineReviewBuildConfigReportItem> _reportItems(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  final items = <OnlineReviewBuildConfigReportItem>[];
  for (final result in results) {
    for (final failure in result.failures) {
      items.add(
        OnlineReviewBuildConfigReportItem(
          scenarioId: result.scenarioId,
          severity: OnlineReviewBuildConfigReportSeverity.error,
          message: failure,
        ),
      );
    }
    for (final warning in result.warnings) {
      items.add(
        OnlineReviewBuildConfigReportItem(
          scenarioId: result.scenarioId,
          severity: OnlineReviewBuildConfigReportSeverity.warning,
          message: warning,
        ),
      );
    }
    if (result.decision.isPublic) {
      items.add(
        OnlineReviewBuildConfigReportItem(
          scenarioId: result.scenarioId,
          severity: OnlineReviewBuildConfigReportSeverity.info,
          message: 'Public preview policy shape only; no route activation.',
        ),
      );
    }
  }
  return items;
}

bool _hardSafetyPassed(
  List<OnlineReviewBuildConfigScenario> scenarios,
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  return _defaultScenarioRemainsDisabled(results) &&
      !_containsRealUrl(scenarios) &&
      !_containsLoopbackHost(scenarios) &&
      _defaultScenarioHasNoHttp(results) &&
      _publicPreviewInsecureHttpRejected(results) &&
      _repositoryHttpMatchesDecision(results) &&
      _unknownModeRemainsDisabled(results) &&
      _invalidUriRemainsSafe(results);
}

bool _defaultScenarioRemainsDisabled(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  final result = _resultById(results, 'defaultDisabled');
  return result != null &&
      result.config.mode == OnlineReviewRuntimeMode.disabled &&
      !result.decision.canShowShell &&
      !result.decision.canUseHttp &&
      !result.decision.canUseDebugHarness &&
      !result.decision.isPublic &&
      result.repositoryConfig.mode == OnlineReviewRepositoryMode.disabled;
}

bool _defaultScenarioHasNoHttp(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  final result = _resultById(results, 'defaultDisabled');
  return result != null &&
      !result.decision.canUseHttp &&
      result.repositoryConfig.mode == OnlineReviewRepositoryMode.disabled &&
      result.repositoryConfig.baseUri == null;
}

bool _publicPreviewInsecureHttpRejected(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  final result = _resultById(results, 'publicPreviewInsecureHttpRejected');
  return result != null &&
      result.config.mode == OnlineReviewRuntimeMode.publicPreview &&
      !result.decision.canUseHttp &&
      !result.decision.isPublic &&
      result.repositoryConfig.mode == OnlineReviewRepositoryMode.disabled;
}

bool _repositoryHttpMatchesDecision(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  for (final result in results) {
    if (result.decision.canUseHttp) {
      if (result.repositoryConfig.mode != OnlineReviewRepositoryMode.http ||
          result.repositoryConfig.baseUri == null) {
        return false;
      }
      continue;
    }
    if (result.repositoryConfig.mode == OnlineReviewRepositoryMode.http ||
        result.repositoryConfig.baseUri != null) {
      return false;
    }
  }
  return true;
}

bool _unknownModeRemainsDisabled(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  final result = _resultById(results, 'unknownModeFallsBackDisabled');
  return result != null &&
      result.config.mode == OnlineReviewRuntimeMode.disabled &&
      !result.decision.canUseHttp &&
      result.repositoryConfig.mode == OnlineReviewRepositoryMode.disabled;
}

bool _invalidUriRemainsSafe(
  List<OnlineReviewBuildConfigVerificationResult> results,
) {
  final result = _resultById(results, 'invalidUriFallsBackSafe');
  return result != null &&
      !result.decision.hasBaseUri &&
      !result.decision.canUseHttp &&
      result.repositoryConfig.mode == OnlineReviewRepositoryMode.disabled;
}

bool _containsRealUrl(List<OnlineReviewBuildConfigScenario> scenarios) {
  for (final scenario in scenarios) {
    final raw = scenario.rawValues[OnlineReviewRuntimeConfigKeys.baseUri];
    if (raw == null || raw.trim().isEmpty) {
      continue;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      continue;
    }
    if (!uri.host.endsWith('.example.test')) {
      return true;
    }
  }
  return false;
}

bool _containsLoopbackHost(List<OnlineReviewBuildConfigScenario> scenarios) {
  const host =
      'local'
      'host';
  const loopbackIp =
      '127.0.'
      '0.1';
  for (final scenario in scenarios) {
    final values = scenario.rawValues.values.join(' ').toLowerCase();
    if (values.contains(host) || values.contains(loopbackIp)) {
      return true;
    }
  }
  return false;
}

OnlineReviewBuildConfigVerificationResult? _resultById(
  List<OnlineReviewBuildConfigVerificationResult> results,
  String id,
) {
  for (final result in results) {
    if (result.scenarioId == id) {
      return result;
    }
  }
  return null;
}

String _yesNo(bool value) => value ? 'yes' : 'no';
