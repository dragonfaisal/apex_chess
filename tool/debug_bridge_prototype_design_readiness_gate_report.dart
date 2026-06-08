import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugBridgePrototypeDesignReadinessGateReportExitSuccess = 0;
const debugBridgePrototypeDesignReadinessGateReportExitUsage = 64;
const debugBridgePrototypeDesignReadinessGateReportExitBlockedStrict = 68;
const debugBridgePrototypeDesignReadinessGateReportExitUnsafePolicy = 69;

class DebugBridgePrototypeDesignReadinessGateReportCommandResult {
  const DebugBridgePrototypeDesignReadinessGateReportCommandResult({
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
  final DebugBridgePrototypeDesignReadinessGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugBridgePrototypeDesignReadinessGateResult? result;
  final String? commandFailure;
}

class DebugBridgePrototypeDesignReadinessGateReportCommandRequest {
  const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugBridgePrototypeDesignReadinessGateReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugBridgePrototypeDesignReadinessGateReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugBridgePrototypeDesignReadinessGateReportCommand(
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

DebugBridgePrototypeDesignReadinessGateReportCommandResult
runDebugBridgePrototypeDesignReadinessGateReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugBridgePrototypeDesignReadinessGate gate =
      const DebugBridgePrototypeDesignReadinessGate(),
  DebugBridgePrototypeDesignReadinessGateRequest? request,
}) {
  final commandRequest =
      validateDebugBridgePrototypeDesignReadinessGateReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugBridgePrototypeDesignReadinessGateReportCommandResult(
      exitCode: debugBridgePrototypeDesignReadinessGateReportExitUsage,
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
    return DebugBridgePrototypeDesignReadinessGateReportCommandResult(
      exitCode: debugBridgePrototypeDesignReadinessGateReportExitSuccess,
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
      DebugBridgePrototypeDesignReadinessGateRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = gate.evaluate(gateRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugBridgePrototypeDesignReadinessGateReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugBridgePrototypeDesignReadinessGateReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugBridgePrototypeDesignReadinessGateValidator()
          .validateReportText(stdoutText);

  return DebugBridgePrototypeDesignReadinessGateReportCommandResult(
    exitCode: debugBridgePrototypeDesignReadinessGateReportExitCode(
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

DebugBridgePrototypeDesignReadinessGateReportCommandRequest
validateDebugBridgePrototypeDesignReadinessGateReportArgs(List<String> args) {
  var format = DebugBridgePrototypeDesignReadinessGateReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.valid(
        format: DebugBridgePrototypeDesignReadinessGateReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
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
        return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugBridgePrototypeDesignReadinessGateReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugBridgePrototypeDesignReadinessGateReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugBridgePrototypeDesignReadinessGateReportExitCode(
  DebugBridgePrototypeDesignReadinessGateResult result,
  DebugBridgePrototypeDesignReadinessGateReportCommandRequest request, {
  List<DebugBridgePrototypeDesignReadinessGateFinding> reportFindings =
      const <DebugBridgePrototypeDesignReadinessGateFinding>[],
}) {
  if (result.hasUnsafePrototypeDesignReadinessGatePolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugBridgePrototypeDesignReadinessGateReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugBridgePrototypeDesignReadinessGateReportExitBlockedStrict;
  }
  return debugBridgePrototypeDesignReadinessGateReportExitSuccess;
}

DebugBridgePrototypeDesignReadinessGateReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in DebugBridgePrototypeDesignReadinessGateReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug Bridge Prototype Design Readiness Gate report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_gate_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_gate_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_gate_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_gate_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_bridge_prototype_design_readiness_gate_report.dart --include-warnings',
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
