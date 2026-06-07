import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgeDesignReadinessGateReportExitSuccess = 0;
const debugBridgeDesignReadinessGateReportExitUsage = 64;
const debugBridgeDesignReadinessGateReportExitBlockedStrict = 68;
const debugBridgeDesignReadinessGateReportExitUnsafePolicy = 69;

class DebugBridgeDesignReadinessGateReportCommandResult {
  const DebugBridgeDesignReadinessGateReportCommandResult({
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
  final DebugBridgeDesignReadinessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgeDesignReadinessGateResult? result;
  final String? commandFailure;
}

class DebugBridgeDesignReadinessGateReportCommandRequest {
  const DebugBridgeDesignReadinessGateReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = DebugBridgeDesignReadinessReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgeDesignReadinessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugBridgeDesignReadinessGateReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugBridgeDesignReadinessGateReportCommandResult
runDebugBridgeDesignReadinessGateReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgeDesignReadinessGate readinessGate =
      const DebugBridgeDesignReadinessGate(),
  DebugBridgeDesignReadinessGateRequest? request,
}) {
  final commandRequest = validateDebugBridgeDesignReadinessGateReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugBridgeDesignReadinessGateReportCommandResult(
      exitCode: debugBridgeDesignReadinessGateReportExitUsage,
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
    return DebugBridgeDesignReadinessGateReportCommandResult(
      exitCode: debugBridgeDesignReadinessGateReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final readinessRequest =
      request ??
      DebugBridgeDesignReadinessGateRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = readinessGate.evaluate(readinessRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgeDesignReadinessReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgeDesignReadinessReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugBridgeDesignReadinessGateValidator()
      .validateReportText(stdoutText);

  return DebugBridgeDesignReadinessGateReportCommandResult(
    exitCode: debugBridgeDesignReadinessGateReportExitCode(
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

DebugBridgeDesignReadinessGateReportCommandRequest
validateDebugBridgeDesignReadinessGateReportArgs(List<String> args) {
  var format = DebugBridgeDesignReadinessReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgeDesignReadinessGateReportCommandRequest.valid(
        format: DebugBridgeDesignReadinessReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(
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
        return const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgeDesignReadinessGateReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgeDesignReadinessGateReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgeDesignReadinessGateReportExitCode(
  DebugBridgeDesignReadinessGateResult result,
  DebugBridgeDesignReadinessGateReportCommandRequest request, {
  List<DebugBridgeDesignReadinessFinding> reportFindings =
      const <DebugBridgeDesignReadinessFinding>[],
}) {
  if (result.hasUnsafeDebugBridgeReadinessPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgeDesignReadinessGateReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgeDesignReadinessGateReportExitBlockedStrict;
  }
  return debugBridgeDesignReadinessGateReportExitSuccess;
}

DebugBridgeDesignReadinessReportFormat? _formatByWire(String value) {
  for (final format in DebugBridgeDesignReadinessReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Debug Bridge Design Readiness Gate report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/debug_bridge_design_readiness_gate_report.dart')
    ..writeln(
      '  dart run tool/debug_bridge_design_readiness_gate_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_design_readiness_gate_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_design_readiness_gate_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_design_readiness_gate_report.dart --include-warnings',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --safe-demo')
    ..writeln('  --include-warnings');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
