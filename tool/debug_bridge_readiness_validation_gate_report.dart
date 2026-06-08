import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgeReadinessValidationGateReportExitSuccess = 0;
const debugBridgeReadinessValidationGateReportExitUsage = 64;
const debugBridgeReadinessValidationGateReportExitBlockedStrict = 68;
const debugBridgeReadinessValidationGateReportExitUnsafePolicy = 69;

class DebugBridgeReadinessValidationGateReportCommandResult {
  const DebugBridgeReadinessValidationGateReportCommandResult({
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
  final DebugBridgeReadinessValidationGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgeReadinessValidationGateResult? result;
  final String? commandFailure;
}

class DebugBridgeReadinessValidationGateReportCommandRequest {
  const DebugBridgeReadinessValidationGateReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugBridgeReadinessValidationGateReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgeReadinessValidationGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugBridgeReadinessValidationGateReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugBridgeReadinessValidationGateReportCommandResult
runDebugBridgeReadinessValidationGateReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgeReadinessValidationGate gate =
      const DebugBridgeReadinessValidationGate(),
  DebugBridgeReadinessValidationGateRequest? request,
}) {
  final commandRequest = validateDebugBridgeReadinessValidationGateReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return DebugBridgeReadinessValidationGateReportCommandResult(
      exitCode: debugBridgeReadinessValidationGateReportExitUsage,
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
    return DebugBridgeReadinessValidationGateReportCommandResult(
      exitCode: debugBridgeReadinessValidationGateReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final gateRequest =
      request ??
      DebugBridgeReadinessValidationGateRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = gate.evaluate(gateRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgeReadinessValidationGateReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgeReadinessValidationGateReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugBridgeReadinessValidationGateValidator()
      .validateReportText(stdoutText);

  return DebugBridgeReadinessValidationGateReportCommandResult(
    exitCode: debugBridgeReadinessValidationGateReportExitCode(
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

DebugBridgeReadinessValidationGateReportCommandRequest
validateDebugBridgeReadinessValidationGateReportArgs(List<String> args) {
  var format = DebugBridgeReadinessValidationGateReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgeReadinessValidationGateReportCommandRequest.valid(
        format: DebugBridgeReadinessValidationGateReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
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
        return const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgeReadinessValidationGateReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgeReadinessValidationGateReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgeReadinessValidationGateReportExitCode(
  DebugBridgeReadinessValidationGateResult result,
  DebugBridgeReadinessValidationGateReportCommandRequest request, {
  List<DebugBridgeReadinessValidationGateFinding> reportFindings =
      const <DebugBridgeReadinessValidationGateFinding>[],
}) {
  if (result.hasUnsafeDebugBridgeReadinessValidationGatePolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgeReadinessValidationGateReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgeReadinessValidationGateReportExitBlockedStrict;
  }
  return debugBridgeReadinessValidationGateReportExitSuccess;
}

DebugBridgeReadinessValidationGateReportFormat? _formatByWire(String value) {
  for (final format in DebugBridgeReadinessValidationGateReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Debug Bridge Readiness Validation Gate usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_bridge_readiness_validation_gate_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_validation_gate_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_validation_gate_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_validation_gate_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_readiness_validation_gate_report.dart --include-warnings',
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
