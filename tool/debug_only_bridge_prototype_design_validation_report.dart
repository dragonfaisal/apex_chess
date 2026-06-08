import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';

const debugOnlyBridgePrototypeDesignValidationReportExitSuccess = 0;
const debugOnlyBridgePrototypeDesignValidationReportExitUsage = 64;
const debugOnlyBridgePrototypeDesignValidationReportExitBlockedStrict = 68;
const debugOnlyBridgePrototypeDesignValidationReportExitUnsafePolicy = 69;

class DebugOnlyBridgePrototypeDesignValidationReportCommandResult {
  const DebugOnlyBridgePrototypeDesignValidationReportCommandResult({
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
  final DebugOnlyBridgePrototypeDesignValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgePrototypeDesignValidationResult? result;
  final String? commandFailure;
}

class DebugOnlyBridgePrototypeDesignValidationReportCommandRequest {
  const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = DebugOnlyBridgePrototypeDesignValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgePrototypeDesignValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runDebugOnlyBridgePrototypeDesignValidationReportCommand(
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

DebugOnlyBridgePrototypeDesignValidationReportCommandResult
runDebugOnlyBridgePrototypeDesignValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  DebugOnlyBridgePrototypeDesignValidation validation =
      const DebugOnlyBridgePrototypeDesignValidation(),
  DebugOnlyBridgePrototypeDesignValidationRequest? request,
}) {
  final commandRequest =
      validateDebugOnlyBridgePrototypeDesignValidationReportArgs(args);
  if (!commandRequest.isValid) {
    return DebugOnlyBridgePrototypeDesignValidationReportCommandResult(
      exitCode: debugOnlyBridgePrototypeDesignValidationReportExitUsage,
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
    return DebugOnlyBridgePrototypeDesignValidationReportCommandResult(
      exitCode: debugOnlyBridgePrototypeDesignValidationReportExitSuccess,
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
      DebugOnlyBridgePrototypeDesignValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    DebugOnlyBridgePrototypeDesignValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    DebugOnlyBridgePrototypeDesignValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgePrototypeDesignValidationValidator()
          .validateReportText(stdoutText);

  return DebugOnlyBridgePrototypeDesignValidationReportCommandResult(
    exitCode: debugOnlyBridgePrototypeDesignValidationReportExitCode(
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

DebugOnlyBridgePrototypeDesignValidationReportCommandRequest
validateDebugOnlyBridgePrototypeDesignValidationReportArgs(List<String> args) {
  var format = DebugOnlyBridgePrototypeDesignValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.valid(
        format: DebugOnlyBridgePrototypeDesignValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
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
        return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return DebugOnlyBridgePrototypeDesignValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int debugOnlyBridgePrototypeDesignValidationReportExitCode(
  DebugOnlyBridgePrototypeDesignValidationResult result,
  DebugOnlyBridgePrototypeDesignValidationReportCommandRequest request, {
  List<DebugOnlyBridgePrototypeDesignValidationFinding> reportFindings =
      const <DebugOnlyBridgePrototypeDesignValidationFinding>[],
}) {
  if (result.hasUnsafeDebugOnlyBridgePrototypeDesignValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return debugOnlyBridgePrototypeDesignValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return debugOnlyBridgePrototypeDesignValidationReportExitBlockedStrict;
  }
  return debugOnlyBridgePrototypeDesignValidationReportExitSuccess;
}

DebugOnlyBridgePrototypeDesignValidationReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in DebugOnlyBridgePrototypeDesignValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Debug-Only Bridge Prototype Design Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/debug_only_bridge_prototype_design_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_prototype_design_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_prototype_design_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_prototype_design_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/debug_only_bridge_prototype_design_validation_report.dart --include-warnings',
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
