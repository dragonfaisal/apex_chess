import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_scenario_summary.dart';

void main(List<String> args) {
  final request = _commandRequest(args);
  if (!request.isValid) {
    io.stderr.writeln('Unknown Online Review staging readiness argument.');
    io.stderr.writeln('Use no arguments, --all-scenarios, or --scenario=<id>.');
    io.exitCode = 64;
    return;
  }

  if (request.allScenarios) {
    final summary = buildOnlineReviewStagingScenarioSummary();
    io.stdout.write(renderOnlineReviewStagingScenarioSummaryMarkdown(summary));
    io.exitCode = onlineReviewStagingScenarioSummaryExitCode(summary);
    return;
  }

  final scenarioName = request.scenarioName;
  if (scenarioName == null) {
    final report = buildDefaultOnlineReviewStagingReadinessReport();
    io.stdout.write(renderOnlineReviewStagingReadinessReportMarkdown(report));
    io.exitCode = onlineReviewStagingReadinessReportExitCode(report);
    return;
  }

  final scenarioId = onlineReviewStagingConfigScenarioIdByName(scenarioName);
  if (scenarioId == null) {
    io.stderr.writeln('Unknown Online Review staging readiness scenario.');
    io.stderr.writeln('Use one of: $_scenarioNames.');
    io.exitCode = 64;
    return;
  }

  final scenario = scenarioById(scenarioId);
  final report = buildOnlineReviewStagingReadinessReportForScenario(scenario);
  io.stdout.write(
    renderOnlineReviewStagingReadinessReportMarkdown(
      report,
      scenarioId: scenario.id.name,
      scenarioDescription: scenario.description,
    ),
  );
  io.exitCode = onlineReviewStagingReadinessReportExitCode(report);
}

const _scenarioFlag = '--scenario=';
const _allScenariosFlag = '--all-scenarios';

class _CommandRequest {
  const _CommandRequest.defaultReport()
    : isValid = true,
      allScenarios = false,
      scenarioName = null;
  const _CommandRequest.allScenarios()
    : isValid = true,
      allScenarios = true,
      scenarioName = null;
  const _CommandRequest.invalid()
    : isValid = false,
      allScenarios = false,
      scenarioName = null;
  const _CommandRequest.scenario(this.scenarioName)
    : isValid = true,
      allScenarios = false;

  final bool isValid;
  final bool allScenarios;
  final String? scenarioName;
}

_CommandRequest _commandRequest(List<String> args) {
  if (args.isEmpty) {
    return const _CommandRequest.defaultReport();
  }
  if (args.length != 1) {
    return const _CommandRequest.invalid();
  }
  if (args.single == _allScenariosFlag) {
    return const _CommandRequest.allScenarios();
  }
  if (!args.single.startsWith(_scenarioFlag)) {
    return const _CommandRequest.invalid();
  }
  final value = args.single.substring(_scenarioFlag.length).trim();
  if (value.isEmpty) {
    return const _CommandRequest.invalid();
  }
  return _CommandRequest.scenario(value);
}

String get _scenarioNames {
  return OnlineReviewStagingConfigScenarioId.values
      .map((scenario) => scenario.name)
      .join(', ');
}
