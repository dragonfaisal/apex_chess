import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyAdapterBridgeDesignValidationReportExitSuccess = 0;
const debugOnlyAdapterBridgeDesignValidationReportExitUsage = 64;
const debugOnlyAdapterBridgeDesignValidationReportExitBlockedStrict = 68;
const debugOnlyAdapterBridgeDesignValidationReportExitUnsafePolicy = 69;

class DebugOnlyAdapterBridgeDesignValidationReportCommandResult {
  const DebugOnlyAdapterBridgeDesignValidationReportCommandResult({
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
  final DebugOnlyAdapterBridgeDesignValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyAdapterBridgeDesignValidationResult? result;
  final String? commandFailure;
}

class DebugOnlyAdapterBridgeDesignValidationReportCommandRequest {
  const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyAdapterBridgeDesignValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyAdapterBridgeDesignValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyAdapterBridgeDesignValidationReportCommand(
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

DebugOnlyAdapterBridgeDesignValidationReportCommandResult
runDebugOnlyAdapterBridgeDesignValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyAdapterBridgeDesignValidation validation =
      const DebugOnlyAdapterBridgeDesignValidation(),
  DebugOnlyAdapterBridgeDesignValidationRequest? request,
}) {
  final commandRequest =
      validateDebugOnlyAdapterBridgeDesignValidationReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyAdapterBridgeDesignValidationReportCommandResult(
      exitCode: debugOnlyAdapterBridgeDesignValidationReportExitUsage,
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
    return DebugOnlyAdapterBridgeDesignValidationReportCommandResult(
      exitCode: debugOnlyAdapterBridgeDesignValidationReportExitSuccess,
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
      DebugOnlyAdapterBridgeDesignValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyAdapterBridgeDesignValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyAdapterBridgeDesignValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const DebugOnlyAdapterBridgeDesignValidationValidator()
      .validateReportText(stdoutText);

  return DebugOnlyAdapterBridgeDesignValidationReportCommandResult(
    exitCode: debugOnlyAdapterBridgeDesignValidationReportExitCode(
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

DebugOnlyAdapterBridgeDesignValidationReportCommandRequest
validateDebugOnlyAdapterBridgeDesignValidationReportArgs(List<String> args) {
  var format = DebugOnlyAdapterBridgeDesignValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.valid(
        format: DebugOnlyAdapterBridgeDesignValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
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
        return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyAdapterBridgeDesignValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyAdapterBridgeDesignValidationReportExitCode(
  DebugOnlyAdapterBridgeDesignValidationResult result,
  DebugOnlyAdapterBridgeDesignValidationReportCommandRequest request, {
  List<DebugOnlyAdapterBridgeDesignValidationFinding> reportFindings =
      const <DebugOnlyAdapterBridgeDesignValidationFinding>[],
}) {
  if (result.hasUnsafeDebugBridgeDesignValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugOnlyAdapterBridgeDesignValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugOnlyAdapterBridgeDesignValidationReportExitBlockedStrict;
  }
  return debugOnlyAdapterBridgeDesignValidationReportExitSuccess;
}

DebugOnlyAdapterBridgeDesignValidationReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in DebugOnlyAdapterBridgeDesignValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug-Only Adapter Bridge Design Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_only_adapter_bridge_design_validation_report.dart --include-warnings',
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
