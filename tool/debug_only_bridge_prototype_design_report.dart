import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgePrototypeDesignReportExitSuccess = 0;
const debugOnlyBridgePrototypeDesignReportExitUsage = 64;
const debugOnlyBridgePrototypeDesignReportExitBlockedStrict = 68;
const debugOnlyBridgePrototypeDesignReportExitUnsafePolicy = 69;

class DebugOnlyBridgePrototypeDesignReportCommandResult {
  const DebugOnlyBridgePrototypeDesignReportCommandResult({
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
  final DebugOnlyBridgePrototypeDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgePrototypeDesignResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgePrototypeDesignReportCommandRequest {
  const DebugOnlyBridgePrototypeDesignReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = DebugOnlyBridgePrototypeDesignReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgePrototypeDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgePrototypeDesignReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugOnlyBridgePrototypeDesignReportCommandResult
runDebugOnlyBridgePrototypeDesignReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgePrototypeDesign design =
      const DebugOnlyBridgePrototypeDesign(),
  DebugOnlyBridgePrototypeDesignRequest? request,
}) {
  final commandRequest = validateDebugOnlyBridgePrototypeDesignReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyBridgePrototypeDesignReportCommandResult(
      exitCode: debugOnlyBridgePrototypeDesignReportExitUsage,
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
    return DebugOnlyBridgePrototypeDesignReportCommandResult(
      exitCode: debugOnlyBridgePrototypeDesignReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final designRequest =
      request ??
      DebugOnlyBridgePrototypeDesignRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = design.evaluate(designRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgePrototypeDesignReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgePrototypeDesignReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugOnlyBridgePrototypeDesignValidator()
      .validateReportText(stdoutText);

  return DebugOnlyBridgePrototypeDesignReportCommandResult(
    exitCode: debugOnlyBridgePrototypeDesignReportExitCode(
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

DebugOnlyBridgePrototypeDesignReportCommandRequest
validateDebugOnlyBridgePrototypeDesignReportArgs(List<String> args) {
  var format = DebugOnlyBridgePrototypeDesignReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgePrototypeDesignReportCommandRequest.valid(
        format: DebugOnlyBridgePrototypeDesignReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(
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
        return const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgePrototypeDesignReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgePrototypeDesignReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgePrototypeDesignReportExitCode(
  DebugOnlyBridgePrototypeDesignResult result,
  DebugOnlyBridgePrototypeDesignReportCommandRequest request, {
  List<DebugOnlyBridgePrototypeDesignFinding> reportFindings =
      const <DebugOnlyBridgePrototypeDesignFinding>[],
}) {
  final hasReportCritical = reportFindings.any(
    (finding) => finding.severity.isCritical,
  );
  if (hasReportCritical ||
      result.hasUnsafeDebugOnlyBridgePrototypeDesignPolicyViolation) {
    return debugOnlyBridgePrototypeDesignReportExitUnsafePolicy;
  }
  if (!request.strict) {
    return debugOnlyBridgePrototypeDesignReportExitSuccess;
  }
  if (result.isStrictlyBlocked) {
    return debugOnlyBridgePrototypeDesignReportExitBlockedStrict;
  }
  return debugOnlyBridgePrototypeDesignReportExitSuccess;
}

DebugOnlyBridgePrototypeDesignReportFormat? _formatByWire(String wire) {
  for (final format in DebugOnlyBridgePrototypeDesignReportFormat.values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    'Debug-Only Bridge Prototype Design report',
    if (failure.isNotEmpty) 'failure: $failure',
    'usage: dart run tool/debug_only_bridge_prototype_design_report.dart '
        '[--format=markdown|--format=json] [--strict] [--safe-demo] '
        '[--include-warnings]',
    '',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
