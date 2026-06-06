import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';

const internalEvidenceAdapterPrototypeReviewReportExitSuccess = 0;
const internalEvidenceAdapterPrototypeReviewReportExitUsage = 64;
const internalEvidenceAdapterPrototypeReviewReportExitBlockedStrict = 68;
const internalEvidenceAdapterPrototypeReviewReportExitUnsafePolicy = 69;

class InternalEvidenceAdapterPrototypeReviewReportCommandResult {
  const InternalEvidenceAdapterPrototypeReviewReportCommandResult({
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
  final InternalEvidenceAdapterPrototypeReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final InternalEvidenceAdapterPrototypeReviewResult? result;
  final String? commandFailure;
}

class InternalEvidenceAdapterPrototypeReviewReportCommandRequest {
  const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = InternalEvidenceAdapterPrototypeReviewReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final InternalEvidenceAdapterPrototypeReviewReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runInternalEvidenceAdapterPrototypeReviewReportCommand(
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

InternalEvidenceAdapterPrototypeReviewReportCommandResult
runInternalEvidenceAdapterPrototypeReviewReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  InternalEvidenceAdapterPrototypeReview review =
      const InternalEvidenceAdapterPrototypeReview(),
  InternalEvidenceAdapterPrototypeReviewRequest? request,
}) {
  final commandRequest =
      validateInternalEvidenceAdapterPrototypeReviewReportArgs(args);
  if (!commandRequest.isValid) {
    return InternalEvidenceAdapterPrototypeReviewReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeReviewReportExitUsage,
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
    return InternalEvidenceAdapterPrototypeReviewReportCommandResult(
      exitCode: internalEvidenceAdapterPrototypeReviewReportExitSuccess,
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
      InternalEvidenceAdapterPrototypeReviewRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = review.evaluate(reviewRequest);
  final stdoutText = switch (commandRequest.format) {
    InternalEvidenceAdapterPrototypeReviewReportFormat.markdown =>
      result.renderMarkdownReport(),
    InternalEvidenceAdapterPrototypeReviewReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };
  final reportFindings = const InternalEvidenceAdapterPrototypeReviewValidator()
      .validateReportText(stdoutText);

  return InternalEvidenceAdapterPrototypeReviewReportCommandResult(
    exitCode: internalEvidenceAdapterPrototypeReviewReportExitCode(
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

InternalEvidenceAdapterPrototypeReviewReportCommandRequest
validateInternalEvidenceAdapterPrototypeReviewReportArgs(List<String> args) {
  var format = InternalEvidenceAdapterPrototypeReviewReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.valid(
        format: InternalEvidenceAdapterPrototypeReviewReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
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
        return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const InternalEvidenceAdapterPrototypeReviewReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return InternalEvidenceAdapterPrototypeReviewReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int internalEvidenceAdapterPrototypeReviewReportExitCode(
  InternalEvidenceAdapterPrototypeReviewResult result,
  InternalEvidenceAdapterPrototypeReviewReportCommandRequest request, {
  List<InternalEvidenceAdapterPrototypeReviewFinding> reportFindings =
      const <InternalEvidenceAdapterPrototypeReviewFinding>[],
}) {
  if (result.hasUnsafeAdapterReviewPolicyViolation ||
      reportFindings.any((finding) => finding.isCritical)) {
    return internalEvidenceAdapterPrototypeReviewReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return internalEvidenceAdapterPrototypeReviewReportExitBlockedStrict;
  }
  return internalEvidenceAdapterPrototypeReviewReportExitSuccess;
}

InternalEvidenceAdapterPrototypeReviewReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in InternalEvidenceAdapterPrototypeReviewReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Internal Evidence Adapter Prototype Review report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_review_report.dart',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_review_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_review_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_review_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/internal_evidence_adapter_prototype_review_report.dart --include-warnings',
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
