import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';

const internalEvidenceSummaryLayerReportExitSuccess = 0;
const internalEvidenceSummaryLayerReportExitUsage = 64;
const internalEvidenceSummaryLayerReportExitBlockedStrict = 68;
const internalEvidenceSummaryLayerReportExitUnsafePolicy = 69;

class InternalEvidenceSummaryLayerReportCommandResult {
  const InternalEvidenceSummaryLayerReportCommandResult({
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
  final InternalEvidenceSummaryLayerReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceSummaryLayerResult? result;
  final String? commandFailure;
}

class InternalEvidenceSummaryLayerReportCommandRequest {
  const InternalEvidenceSummaryLayerReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceSummaryLayerReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalEvidenceSummaryLayerReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceSummaryLayerReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceSummaryLayerReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalEvidenceSummaryLayerReportCommandResult
runInternalEvidenceSummaryLayerReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceSummaryLayer summaryLayer =
      const InternalEvidenceSummaryLayer(),
  InternalEvidenceSummaryLayerRequest? request,
}) {
  final commandRequest = validateInternalEvidenceSummaryLayerReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalEvidenceSummaryLayerReportCommandResult(
      exitCode: internalEvidenceSummaryLayerReportExitUsage,
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
    return InternalEvidenceSummaryLayerReportCommandResult(
      exitCode: internalEvidenceSummaryLayerReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final summaryRequest =
      request ??
      InternalEvidenceSummaryLayerRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = summaryLayer.evaluate(summaryRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceSummaryLayerReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceSummaryLayerReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalEvidenceSummaryLayerReportCommandResult(
    exitCode: internalEvidenceSummaryLayerReportExitCode(
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

InternalEvidenceSummaryLayerReportCommandRequest
validateInternalEvidenceSummaryLayerReportArgs(List<String> args) {
  var format = InternalEvidenceSummaryLayerReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceSummaryLayerReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceSummaryLayerReportCommandRequest.valid(
        format: InternalEvidenceSummaryLayerReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceSummaryLayerReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceSummaryLayerReportCommandRequest.invalid(
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
        return const InternalEvidenceSummaryLayerReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalEvidenceSummaryLayerReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalEvidenceSummaryLayerReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceSummaryLayerReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalEvidenceSummaryLayerReportExitCode(
  InternalEvidenceSummaryLayerResult result,
  InternalEvidenceSummaryLayerReportCommandRequest request,
) {
  if (result.hasUnsafeSummaryPolicyViolation) {
    return internalEvidenceSummaryLayerReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceSummaryLayerReportExitBlockedStrict;
  }
  return internalEvidenceSummaryLayerReportExitSuccess;
}

InternalEvidenceSummaryLayerReportFormat? _formatByWire(String value) {
  for (final format in InternalEvidenceSummaryLayerReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Evidence Summary Layer report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_evidence_summary_layer_report.dart')
    ..writeln(
      '  dart run tool/internal_evidence_summary_layer_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_summary_layer_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_summary_layer_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_summary_layer_report.dart --include-warnings',
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
