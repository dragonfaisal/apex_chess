import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess = 0;
const debugOnlyBridgeDeveloperInspectionHarnessReportExitUsage = 64;
const debugOnlyBridgeDeveloperInspectionHarnessReportExitBlockedStrict = 68;
const debugOnlyBridgeDeveloperInspectionHarnessReportExitUnsafePolicy = 69;

class DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult {
  const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeDeveloperInspectionHarnessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeDeveloperInspectionHarnessResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest {
  const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeDeveloperInspectionHarnessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeDeveloperInspectionHarnessReportCommand(
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

DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult
runDebugOnlyBridgeDeveloperInspectionHarnessReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeDeveloperInspectionHarness harness =
      const DebugOnlyBridgeDeveloperInspectionHarness(),
  DebugOnlyBridgeDeveloperInspectionHarnessRequest? request,
}) {
  final commandRequest =
      validateDebugOnlyBridgeDeveloperInspectionHarnessReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult(
      exitCode: debugOnlyBridgeDeveloperInspectionHarnessReportExitUsage,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: '',
      stderrText: _usage(commandRequest.failure),
      commandFailure: commandRequest.failure,
    );
  }
  if (commandRequest.showHelp) {
    return DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult(
      exitCode: debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final harnessRequest =
      request ??
      DebugOnlyBridgeDeveloperInspectionHarnessRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = harness.evaluate(harnessRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult(
    exitCode: debugOnlyBridgeDeveloperInspectionHarnessReportExitCode(
      result,
      commandRequest,
      reportFindings: reportFindings,
    ),
    format: commandRequest.format,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    includeWarnings: commandRequest.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest
validateDebugOnlyBridgeDeveloperInspectionHarnessReportArgs(List<String> args) {
  var format = DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.valid(
        format: DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    if (arg == _safeDemoFlag) {
      if (safeDemoSeen) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeDeveloperInspectionHarnessReportExitCode(
  DebugOnlyBridgeDeveloperInspectionHarnessResult result,
  DebugOnlyBridgeDeveloperInspectionHarnessReportCommandRequest request, {
  List<DebugOnlyBridgeDeveloperInspectionHarnessFinding> reportFindings =
      const <DebugOnlyBridgeDeveloperInspectionHarnessFinding>[],
}) {
  final hasReportLeak = reportFindings.any((finding) => finding.isCritical);
  if (result
          .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessPolicyViolation ||
      hasReportLeak) {
    return debugOnlyBridgeDeveloperInspectionHarnessReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          result.productOutputCount > 0 ||
          result.labelLeakCount > 0 ||
          result.scoreLeakCount > 0 ||
          result.metricLeakCount > 0 ||
          result.cpLossLeakCount > 0 ||
          result.winProbabilityLeakCount > 0 ||
          result.uiTargetCount > 0 ||
          result.backendTargetCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.stockfishCommandLeakCount > 0 ||
          result.rawUciLeakCount > 0 ||
          result.pvDumpLeakCount > 0 ||
          result.runtimeEnabledCount > 0 ||
          !result.safeForPhase33I)) {
    return debugOnlyBridgeDeveloperInspectionHarnessReportExitBlockedStrict;
  }
  return debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess;
}

DebugOnlyBridgeDeveloperInspectionHarnessReportFormat? _formatByWire(
  String wire,
) {
  for (final format
      in DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_developer_inspection_harness_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
