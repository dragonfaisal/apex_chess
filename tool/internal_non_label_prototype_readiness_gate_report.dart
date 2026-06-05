import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';

const internalNonLabelPrototypeReadinessGateReportExitSuccess = 0;
const internalNonLabelPrototypeReadinessGateReportExitUsage = 64;
const internalNonLabelPrototypeReadinessGateReportExitBlockedStrict = 68;
const internalNonLabelPrototypeReadinessGateReportExitUnsafePolicy = 69;

class InternalNonLabelPrototypeReadinessGateReportCommandResult {
  const InternalNonLabelPrototypeReadinessGateReportCommandResult({
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
  final InternalNonLabelPrototypeReadinessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalNonLabelPrototypeReadinessResult? result;
  final String? commandFailure;
}

class InternalNonLabelPrototypeReadinessGateReportCommandRequest {
  const InternalNonLabelPrototypeReadinessGateReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalNonLabelPrototypeReadinessReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalNonLabelPrototypeReadinessReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalNonLabelPrototypeReadinessGateReportCommand(
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

InternalNonLabelPrototypeReadinessGateReportCommandResult
runInternalNonLabelPrototypeReadinessGateReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalNonLabelPrototypeReadinessGate gate =
      const InternalNonLabelPrototypeReadinessGate(),
  InternalNonLabelPrototypeReadinessGateRequest? request,
}) {
  final commandRequest =
      validateInternalNonLabelPrototypeReadinessGateReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalNonLabelPrototypeReadinessGateReportCommandResult(
      exitCode: internalNonLabelPrototypeReadinessGateReportExitUsage,
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
    return InternalNonLabelPrototypeReadinessGateReportCommandResult(
      exitCode: internalNonLabelPrototypeReadinessGateReportExitSuccess,
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
      InternalNonLabelPrototypeReadinessGateRequest.safeDemo(cases: cases);
  final result = gate.evaluate(gateRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalNonLabelPrototypeReadinessReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalNonLabelPrototypeReadinessReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalNonLabelPrototypeReadinessGateReportCommandResult(
    exitCode: internalNonLabelPrototypeReadinessGateReportExitCode(
      result,
      commandRequest,
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

InternalNonLabelPrototypeReadinessGateReportCommandRequest
validateInternalNonLabelPrototypeReadinessGateReportArgs(List<String> args) {
  var format = InternalNonLabelPrototypeReadinessReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.valid(
        format: InternalNonLabelPrototypeReadinessReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
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
        return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalNonLabelPrototypeReadinessGateReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalNonLabelPrototypeReadinessGateReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalNonLabelPrototypeReadinessGateReportExitCode(
  InternalNonLabelPrototypeReadinessResult result,
  InternalNonLabelPrototypeReadinessGateReportCommandRequest request,
) {
  if (result.hasUnsafeReadinessPolicyViolation) {
    return internalNonLabelPrototypeReadinessGateReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalNonLabelPrototypeReadinessGateReportExitBlockedStrict;
  }
  return internalNonLabelPrototypeReadinessGateReportExitSuccess;
}

InternalNonLabelPrototypeReadinessReportFormat? _formatByWire(String value) {
  for (final format in InternalNonLabelPrototypeReadinessReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Non-Label Prototype Readiness Gate report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_non_label_prototype_readiness_gate_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_non_label_prototype_readiness_gate_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_non_label_prototype_readiness_gate_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_non_label_prototype_readiness_gate_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_non_label_prototype_readiness_gate_report.dart --include-warnings',
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
