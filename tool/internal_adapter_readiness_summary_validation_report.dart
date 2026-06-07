import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';

const internalAdapterReadinessSummaryValidationReportExitSuccess = 0;
const internalAdapterReadinessSummaryValidationReportExitUsage = 64;
const internalAdapterReadinessSummaryValidationReportExitBlockedStrict = 68;
const internalAdapterReadinessSummaryValidationReportExitUnsafePolicy = 69;

class InternalAdapterReadinessSummaryValidationReportCommandResult {
  const InternalAdapterReadinessSummaryValidationReportCommandResult({
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
  final InternalAdapterReadinessSummaryValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalAdapterReadinessSummaryValidationResult? result;
  final String? commandFailure;
}

class InternalAdapterReadinessSummaryValidationReportCommandRequest {
  const InternalAdapterReadinessSummaryValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalAdapterReadinessSummaryValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalAdapterReadinessSummaryValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalAdapterReadinessSummaryValidationReportCommand(
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

InternalAdapterReadinessSummaryValidationReportCommandResult
runInternalAdapterReadinessSummaryValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalAdapterReadinessSummaryValidation validation =
      const InternalAdapterReadinessSummaryValidation(),
  InternalAdapterReadinessSummaryValidationRequest? request,
}) {
  final commandRequest =
      validateInternalAdapterReadinessSummaryValidationReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalAdapterReadinessSummaryValidationReportCommandResult(
      exitCode: internalAdapterReadinessSummaryValidationReportExitUsage,
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
    return InternalAdapterReadinessSummaryValidationReportCommandResult(
      exitCode: internalAdapterReadinessSummaryValidationReportExitSuccess,
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
      InternalAdapterReadinessSummaryValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalAdapterReadinessSummaryValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalAdapterReadinessSummaryValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings =
      const InternalAdapterReadinessSummaryValidationValidator()
          .validateReportText(stdoutText);

  return InternalAdapterReadinessSummaryValidationReportCommandResult(
    exitCode: internalAdapterReadinessSummaryValidationReportExitCode(
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

InternalAdapterReadinessSummaryValidationReportCommandRequest
validateInternalAdapterReadinessSummaryValidationReportArgs(List<String> args) {
  var format = InternalAdapterReadinessSummaryValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalAdapterReadinessSummaryValidationReportCommandRequest.valid(
        format: InternalAdapterReadinessSummaryValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
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
        return const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalAdapterReadinessSummaryValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalAdapterReadinessSummaryValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalAdapterReadinessSummaryValidationReportExitCode(
  InternalAdapterReadinessSummaryValidationResult result,
  InternalAdapterReadinessSummaryValidationReportCommandRequest request, {
  List<InternalAdapterReadinessSummaryValidationFinding> reportFindings =
      const <InternalAdapterReadinessSummaryValidationFinding>[],
}) {
  if (result.hasUnsafeAdapterSummaryValidationPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return internalAdapterReadinessSummaryValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalAdapterReadinessSummaryValidationReportExitBlockedStrict;
  }
  return internalAdapterReadinessSummaryValidationReportExitSuccess;
}

InternalAdapterReadinessSummaryValidationReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in InternalAdapterReadinessSummaryValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Adapter Readiness Summary Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_adapter_readiness_summary_validation_report.dart --include-warnings',
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
