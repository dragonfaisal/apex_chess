import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgeImplementationDesignReportExitSuccess = 0;
const debugOnlyBridgeImplementationDesignReportExitUsage = 64;
const debugOnlyBridgeImplementationDesignReportExitBlockedStrict = 68;
const debugOnlyBridgeImplementationDesignReportExitUnsafePolicy = 69;

class DebugOnlyBridgeImplementationDesignReportCommandResult {
  const DebugOnlyBridgeImplementationDesignReportCommandResult({
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
  final DebugOnlyBridgeImplementationDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeImplementationDesignResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgeImplementationDesignReportCommandRequest {
  const DebugOnlyBridgeImplementationDesignReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgeImplementationDesignReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeImplementationDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgeImplementationDesignReportCommand(
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

DebugOnlyBridgeImplementationDesignReportCommandResult
runDebugOnlyBridgeImplementationDesignReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgeImplementationDesign design =
      const DebugOnlyBridgeImplementationDesign(),
  DebugOnlyBridgeImplementationDesignRequest? request,
}) {
  final commandRequest = validateDebugOnlyBridgeImplementationDesignReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return DebugOnlyBridgeImplementationDesignReportCommandResult(
      exitCode: debugOnlyBridgeImplementationDesignReportExitUsage,
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
    return DebugOnlyBridgeImplementationDesignReportCommandResult(
      exitCode: debugOnlyBridgeImplementationDesignReportExitSuccess,
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
      DebugOnlyBridgeImplementationDesignRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = design.evaluate(designRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgeImplementationDesignReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgeImplementationDesignReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugOnlyBridgeImplementationDesignValidator()
      .validateReportText(stdoutText);

  return DebugOnlyBridgeImplementationDesignReportCommandResult(
    exitCode: debugOnlyBridgeImplementationDesignReportExitCode(
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

DebugOnlyBridgeImplementationDesignReportCommandRequest
validateDebugOnlyBridgeImplementationDesignReportArgs(List<String> args) {
  var format = DebugOnlyBridgeImplementationDesignReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgeImplementationDesignReportCommandRequest.valid(
        format: DebugOnlyBridgeImplementationDesignReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
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
        return const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgeImplementationDesignReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgeImplementationDesignReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgeImplementationDesignReportExitCode(
  DebugOnlyBridgeImplementationDesignResult result,
  DebugOnlyBridgeImplementationDesignReportCommandRequest request, {
  List<DebugOnlyBridgeImplementationDesignFinding> reportFindings =
      const <DebugOnlyBridgeImplementationDesignFinding>[],
}) {
  if (result.hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugOnlyBridgeImplementationDesignReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugOnlyBridgeImplementationDesignReportExitBlockedStrict;
  }
  return debugOnlyBridgeImplementationDesignReportExitSuccess;
}

DebugOnlyBridgeImplementationDesignReportFormat? _formatByWire(String value) {
  for (final format in DebugOnlyBridgeImplementationDesignReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug-Only Bridge Implementation Design report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_only_bridge_implementation_design_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_implementation_design_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_implementation_design_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_implementation_design_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_implementation_design_report.dart --include-warnings',
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
