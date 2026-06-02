import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';

const internalNonLabelScoringDesignReportExitSuccess = 0;
const internalNonLabelScoringDesignReportExitUsage = 64;
const internalNonLabelScoringDesignReportExitBlockedStrict = 68;
const internalNonLabelScoringDesignReportExitUnsafePolicy = 69;

class InternalNonLabelScoringDesignReportCommandResult {
  const InternalNonLabelScoringDesignReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final InternalNonLabelScoringDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final String stdoutText;
  final String stderrText;
  final InternalNonLabelScoringDesignResult? result;
  final String? commandFailure;
}

class InternalNonLabelScoringDesignReportCommandRequest {
  const InternalNonLabelScoringDesignReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includePartial,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalNonLabelScoringDesignReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = InternalNonLabelScoringDesignReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includePartial = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalNonLabelScoringDesignReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includePartial;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalNonLabelScoringDesignReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

InternalNonLabelScoringDesignReportCommandResult
runInternalNonLabelScoringDesignReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalNonLabelScoringDesign design = const InternalNonLabelScoringDesign(),
  InternalNonLabelScoringDesignRequest? request,
}) {
  final commandRequest = validateInternalNonLabelScoringDesignReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalNonLabelScoringDesignReportCommandResult(
      exitCode: internalNonLabelScoringDesignReportExitUsage,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: '',
      stderrText: _usage(commandRequest.failure),
      commandFailure: commandRequest.failure,
    );
  }
  if (commandRequest.showHelp) {
    return InternalNonLabelScoringDesignReportCommandResult(
      exitCode: internalNonLabelScoringDesignReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includePartial: commandRequest.includePartial,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final designRequest =
      request ??
      InternalNonLabelScoringDesignRequest(
        cases: cases,
        matrixRequest: InternalEvidenceAreaCoverageMatrixRequest(
          cases: cases,
          harnessRequest: InternalBucketExperimentHarnessRequest.safeDemo(
            cases: cases,
            includePartialBuckets: commandRequest.includePartial,
          ),
        ),
      );
  final result = design.evaluate(designRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalNonLabelScoringDesignReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalNonLabelScoringDesignReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return InternalNonLabelScoringDesignReportCommandResult(
    exitCode: internalNonLabelScoringDesignReportExitCode(
      result,
      commandRequest,
    ),
    format: commandRequest.format,
    strict: commandRequest.strict,
    safeDemo: commandRequest.safeDemo,
    includePartial: commandRequest.includePartial,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

InternalNonLabelScoringDesignReportCommandRequest
validateInternalNonLabelScoringDesignReportArgs(List<String> args) {
  var format = InternalNonLabelScoringDesignReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includePartial = false;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includePartialSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalNonLabelScoringDesignReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalNonLabelScoringDesignReportCommandRequest.valid(
        format: InternalNonLabelScoringDesignReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includePartial: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalNonLabelScoringDesignReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalNonLabelScoringDesignReportCommandRequest.invalid(
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
        return const InternalNonLabelScoringDesignReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includePartialFlag) {
      if (includePartialSeen) {
        return const InternalNonLabelScoringDesignReportCommandRequest.invalid(
          'duplicateIncludePartial',
        );
      }
      includePartial = true;
      includePartialSeen = true;
      continue;
    }
    return const InternalNonLabelScoringDesignReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalNonLabelScoringDesignReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includePartial: includePartial,
  );
}

int internalNonLabelScoringDesignReportExitCode(
  InternalNonLabelScoringDesignResult result,
  InternalNonLabelScoringDesignReportCommandRequest request,
) {
  if (result.hasUnsafeScoringDesignPolicyViolation) {
    return internalNonLabelScoringDesignReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalNonLabelScoringDesignReportExitBlockedStrict;
  }
  return internalNonLabelScoringDesignReportExitSuccess;
}

InternalNonLabelScoringDesignReportFormat? _formatByWire(String value) {
  for (final format in InternalNonLabelScoringDesignReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Internal Non-Label Scoring Design report usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/internal_non_label_scoring_design_report.dart')
    ..writeln(
      '  dart run tool/internal_non_label_scoring_design_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_non_label_scoring_design_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_non_label_scoring_design_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_non_label_scoring_design_report.dart --include-partial',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --safe-demo')
    ..writeln('  --include-partial');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includePartialFlag = '--include-partial';
