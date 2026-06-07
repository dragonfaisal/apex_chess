import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyAdapterBridgeDesignReportExitSuccess = 0;
const debugOnlyAdapterBridgeDesignReportExitUsage = 64;
const debugOnlyAdapterBridgeDesignReportExitBlockedStrict = 68;
const debugOnlyAdapterBridgeDesignReportExitUnsafePolicy = 69;

class DebugOnlyAdapterBridgeDesignReportCommandResult {
  const DebugOnlyAdapterBridgeDesignReportCommandResult({
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
  final DebugOnlyAdapterBridgeDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyAdapterBridgeDesignResult? result;
  final String? commandFailure;
}

class DebugOnlyAdapterBridgeDesignReportCommandRequest {
  const DebugOnlyAdapterBridgeDesignReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = DebugOnlyAdapterBridgeDesignReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyAdapterBridgeDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyAdapterBridgeDesignReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

DebugOnlyAdapterBridgeDesignReportCommandResult
runDebugOnlyAdapterBridgeDesignReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyAdapterBridgeDesign design = const DebugOnlyAdapterBridgeDesign(),
  DebugOnlyAdapterBridgeDesignRequest? request,
}) {
  final commandRequest = validateDebugOnlyAdapterBridgeDesignReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyAdapterBridgeDesignReportCommandResult(
      exitCode: debugOnlyAdapterBridgeDesignReportExitUsage,
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
    return DebugOnlyAdapterBridgeDesignReportCommandResult(
      exitCode: debugOnlyAdapterBridgeDesignReportExitSuccess,
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
      DebugOnlyAdapterBridgeDesignRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = design.evaluate(designRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyAdapterBridgeDesignReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyAdapterBridgeDesignReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugOnlyAdapterBridgeDesignValidator()
      .validateReportText(stdoutText);

  return DebugOnlyAdapterBridgeDesignReportCommandResult(
    exitCode: debugOnlyAdapterBridgeDesignReportExitCode(
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

DebugOnlyAdapterBridgeDesignReportCommandRequest
validateDebugOnlyAdapterBridgeDesignReportArgs(List<String> args) {
  var format = DebugOnlyAdapterBridgeDesignReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyAdapterBridgeDesignReportCommandRequest.valid(
        format: DebugOnlyAdapterBridgeDesignReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(
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
        return const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyAdapterBridgeDesignReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyAdapterBridgeDesignReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyAdapterBridgeDesignReportExitCode(
  DebugOnlyAdapterBridgeDesignResult result,
  DebugOnlyAdapterBridgeDesignReportCommandRequest request, {
  List<DebugOnlyAdapterBridgeDesignFinding> reportFindings =
      const <DebugOnlyAdapterBridgeDesignFinding>[],
}) {
  if (result.hasUnsafeDebugBridgeDesignPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugOnlyAdapterBridgeDesignReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugOnlyAdapterBridgeDesignReportExitBlockedStrict;
  }
  return debugOnlyAdapterBridgeDesignReportExitSuccess;
}

DebugOnlyAdapterBridgeDesignReportFormat? _formatByWire(String value) {
  for (final format in DebugOnlyAdapterBridgeDesignReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Debug-Only Adapter Bridge Design report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/debug_only_adapter_bridge_design_report.dart')
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_report.dart --include-warnings',
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
