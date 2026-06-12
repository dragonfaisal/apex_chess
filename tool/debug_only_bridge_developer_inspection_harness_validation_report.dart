import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess = 0;
const debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitUsage = 64;
const debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitBlockedStrict =
    68;
const debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitUnsafePolicy =
    69;

class DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult({
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
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest {
  const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat
          .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommand(
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

DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult
runDebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeDeveloperInspectionHarnessValidation validation =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidation(),
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest? request,
}) {
  final commandRequest =
      validateDebugOnlyBridgeDeveloperInspectionHarnessValidationReportArgs(
        args,
      );
  if (!commandRequest.isValid) {
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitUsage,
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
    return DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult(
      exitCode:
          debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final validationRequest =
      request ??
      DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult(
    exitCode: debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitCode(
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

DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest
validateDebugOnlyBridgeDeveloperInspectionHarnessValidationReportArgs(
  List<String> args,
) {
  var format =
      DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.valid(
        format: DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat
            .markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
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
        return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitCode(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationResult result,
  DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandRequest
  request, {
  List<DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>
      reportFindings =
      const <DebugOnlyBridgeDeveloperInspectionHarnessValidationFinding>[],
}) {
  final hasReportLeak = reportFindings.any((finding) => finding.isCritical);
  if (result
          .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation ||
      hasReportLeak) {
    return debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitUnsafePolicy;
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
          !result.safeForPhase33J)) {
    return debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitBlockedStrict;
  }
  return debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess;
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat? _formatByWire(
  String wire,
) {
  for (final format
      in DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_developer_inspection_harness_validation_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
