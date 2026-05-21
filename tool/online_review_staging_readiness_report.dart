import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';

void main(List<String> args) {
  final scenarioArg = _scenarioArgument(args);
  if (!scenarioArg.isValid) {
    io.stderr.writeln('Unknown Online Review staging readiness argument.');
    io.stderr.writeln('Use --scenario=<id> with one of: $_scenarioNames.');
    io.exitCode = 64;
    return;
  }

  final scenarioName = scenarioArg.scenarioName;
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

class _ScenarioArgument {
  const _ScenarioArgument.defaultReport() : isValid = true, scenarioName = null;
  const _ScenarioArgument.invalid() : isValid = false, scenarioName = null;
  const _ScenarioArgument.scenario(this.scenarioName) : isValid = true;

  final bool isValid;
  final String? scenarioName;
}

_ScenarioArgument _scenarioArgument(List<String> args) {
  if (args.isEmpty) {
    return const _ScenarioArgument.defaultReport();
  }
  if (args.length != 1 || !args.single.startsWith(_scenarioFlag)) {
    return const _ScenarioArgument.invalid();
  }
  final value = args.single.substring(_scenarioFlag.length).trim();
  if (value.isEmpty) {
    return const _ScenarioArgument.invalid();
  }
  return _ScenarioArgument.scenario(value);
}

String get _scenarioNames {
  return OnlineReviewStagingConfigScenarioId.values
      .map((scenario) => scenario.name)
      .join(', ');
}
