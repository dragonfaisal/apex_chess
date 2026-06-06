import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';

const targetedGoldenCoverageImpactReviewReportExitSuccess = 0;
const targetedGoldenCoverageImpactReviewReportExitUsage = 64;
const targetedGoldenCoverageImpactReviewReportExitBlockedStrict = 68;
const targetedGoldenCoverageImpactReviewReportExitUnsafePolicy = 69;

class TargetedGoldenCoverageImpactReviewReportCommandResult {
  const TargetedGoldenCoverageImpactReviewReportCommandResult({
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
  final TargetedGoldenCoverageImpactReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final TargetedGoldenCoverageImpactReviewResult? result;
  final String? commandFailure;
}

class TargetedGoldenCoverageImpactReviewReportCommandRequest {
  const TargetedGoldenCoverageImpactReviewReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = TargetedGoldenCoverageImpactReviewReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final TargetedGoldenCoverageImpactReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runTargetedGoldenCoverageImpactReviewReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

TargetedGoldenCoverageImpactReviewReportCommandResult
runTargetedGoldenCoverageImpactReviewReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  TargetedGoldenCoverageImpactReview review =
      const TargetedGoldenCoverageImpactReview(),
  TargetedGoldenCoverageImpactReviewRequest? request,
}) {
  final commandRequest = validateTargetedGoldenCoverageImpactReviewReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return TargetedGoldenCoverageImpactReviewReportCommandResult(
      exitCode: targetedGoldenCoverageImpactReviewReportExitUsage,
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
    return TargetedGoldenCoverageImpactReviewReportCommandResult(
      exitCode: targetedGoldenCoverageImpactReviewReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final reviewRequest =
      request ??
      TargetedGoldenCoverageImpactReviewRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = review.evaluate(reviewRequest);
  final stdoutText = switch (commandRequest.format) {
    TargetedGoldenCoverageImpactReviewReportFormat.markdown =>
      result.renderMarkdownReport(),
    TargetedGoldenCoverageImpactReviewReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return TargetedGoldenCoverageImpactReviewReportCommandResult(
    exitCode: targetedGoldenCoverageImpactReviewReportExitCode(
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

TargetedGoldenCoverageImpactReviewReportCommandRequest
validateTargetedGoldenCoverageImpactReviewReportArgs(List<String> args) {
  var format = TargetedGoldenCoverageImpactReviewReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const TargetedGoldenCoverageImpactReviewReportCommandRequest.valid(
        format: TargetedGoldenCoverageImpactReviewReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
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
        return const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const TargetedGoldenCoverageImpactReviewReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return TargetedGoldenCoverageImpactReviewReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int targetedGoldenCoverageImpactReviewReportExitCode(
  TargetedGoldenCoverageImpactReviewResult result,
  TargetedGoldenCoverageImpactReviewReportCommandRequest request,
) {
  if (result.hasUnsafeImpactPolicyViolation) {
    return targetedGoldenCoverageImpactReviewReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return targetedGoldenCoverageImpactReviewReportExitBlockedStrict;
  }
  return targetedGoldenCoverageImpactReviewReportExitSuccess;
}

TargetedGoldenCoverageImpactReviewReportFormat? _formatByWire(String value) {
  for (final format in TargetedGoldenCoverageImpactReviewReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Targeted Golden Coverage Impact Review report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/targeted_golden_coverage_impact_review_report.dart',
    )
    ..writeln(
      '  dart run tool/targeted_golden_coverage_impact_review_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/targeted_golden_coverage_impact_review_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/targeted_golden_coverage_impact_review_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/targeted_golden_coverage_impact_review_report.dart --include-warnings',
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
