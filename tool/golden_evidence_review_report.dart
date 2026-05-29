import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review.dart';
import 'package:apex_chess/features/pgn_review/application/golden_evidence_review_report.dart';

const goldenEvidenceReviewReportExitSuccess = 0;
const goldenEvidenceReviewReportExitUsage = 64;
const goldenEvidenceReviewReportExitIncomplete = 65;
const goldenEvidenceReviewReportExitRealDeviceNeeded = 66;
const goldenEvidenceReviewReportExitMismatch = 67;

class GoldenEvidenceReviewReportCommandResult {
  const GoldenEvidenceReviewReportCommandResult({
    required this.exitCode,
    required this.mode,
    required this.format,
    required this.stdoutText,
    required this.stderrText,
    this.review,
    this.commandFailure,
  });

  final int exitCode;
  final GoldenEvidenceReviewMode mode;
  final GoldenEvidenceReviewReportFormat format;
  final String stdoutText;
  final String stderrText;
  final GoldenEvidenceReviewResult? review;
  final String? commandFailure;
}

class GoldenEvidenceReviewReportCommandRequest {
  const GoldenEvidenceReviewReportCommandRequest.valid({
    required this.mode,
    required this.format,
    required this.failOnMismatch,
    required this.failOnIncomplete,
    required this.failOnRealDeviceNeeded,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const GoldenEvidenceReviewReportCommandRequest.invalid(this.failure)
    : isValid = false,
      mode = GoldenEvidenceReviewMode.fakeEvidence,
      format = GoldenEvidenceReviewReportFormat.markdown,
      failOnMismatch = false,
      failOnIncomplete = false,
      failOnRealDeviceNeeded = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final GoldenEvidenceReviewMode mode;
  final GoldenEvidenceReviewReportFormat format;
  final bool failOnMismatch;
  final bool failOnIncomplete;
  final bool failOnRealDeviceNeeded;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runGoldenEvidenceReviewReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

GoldenEvidenceReviewReportCommandResult runGoldenEvidenceReviewReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  GoldenEvidenceReviewRunner runner = const GoldenEvidenceReviewRunner(),
}) {
  final request = validateGoldenEvidenceReviewReportArgs(args);
  if (!request.isValid) {
    return GoldenEvidenceReviewReportCommandResult(
      exitCode: goldenEvidenceReviewReportExitUsage,
      mode: request.mode,
      format: request.format,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return GoldenEvidenceReviewReportCommandResult(
      exitCode: goldenEvidenceReviewReportExitSuccess,
      mode: request.mode,
      format: request.format,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final review = runner.review(
    GoldenEvidenceReviewRequest(
      cases: cases,
      mode: request.mode,
      requireAllEvidence:
          request.failOnIncomplete || request.failOnRealDeviceNeeded,
    ),
  );
  final stdoutText = switch (request.format) {
    GoldenEvidenceReviewReportFormat.markdown =>
      renderGoldenEvidenceReviewReportMarkdown(review, mode: request.mode),
    GoldenEvidenceReviewReportFormat.json =>
      '${renderGoldenEvidenceReviewReportJson(review, mode: request.mode)}\n',
  };

  return GoldenEvidenceReviewReportCommandResult(
    exitCode: goldenEvidenceReviewReportExitCode(review, request),
    mode: request.mode,
    format: request.format,
    stdoutText: stdoutText,
    stderrText: '',
    review: review,
  );
}

GoldenEvidenceReviewReportCommandRequest validateGoldenEvidenceReviewReportArgs(
  List<String> args,
) {
  var mode = GoldenEvidenceReviewMode.fakeEvidence;
  var format = GoldenEvidenceReviewReportFormat.markdown;
  var failOnMismatch = false;
  var failOnIncomplete = false;
  var failOnRealDeviceNeeded = false;
  var modeSeen = false;
  var formatSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const GoldenEvidenceReviewReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const GoldenEvidenceReviewReportCommandRequest.valid(
        mode: GoldenEvidenceReviewMode.fakeEvidence,
        format: GoldenEvidenceReviewReportFormat.markdown,
        failOnMismatch: false,
        failOnIncomplete: false,
        failOnRealDeviceNeeded: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_modeFlag)) {
      if (modeSeen) {
        return const GoldenEvidenceReviewReportCommandRequest.invalid(
          'duplicateMode',
        );
      }
      final parsed = _modeByWire(arg.substring(_modeFlag.length).trim());
      if (parsed == null) {
        return const GoldenEvidenceReviewReportCommandRequest.invalid(
          'unknownMode',
        );
      }
      mode = parsed;
      modeSeen = true;
      continue;
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const GoldenEvidenceReviewReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const GoldenEvidenceReviewReportCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg == _failOnMismatchFlag) {
      failOnMismatch = true;
      continue;
    }
    if (arg == _failOnIncompleteFlag) {
      failOnIncomplete = true;
      continue;
    }
    if (arg == _failOnRealDeviceNeededFlag) {
      failOnRealDeviceNeeded = true;
      continue;
    }
    return const GoldenEvidenceReviewReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return GoldenEvidenceReviewReportCommandRequest.valid(
    mode: mode,
    format: format,
    failOnMismatch: failOnMismatch,
    failOnIncomplete: failOnIncomplete,
    failOnRealDeviceNeeded: failOnRealDeviceNeeded,
  );
}

int goldenEvidenceReviewReportExitCode(
  GoldenEvidenceReviewResult review,
  GoldenEvidenceReviewReportCommandRequest request,
) {
  if (request.failOnIncomplete && review.incomplete > 0) {
    return goldenEvidenceReviewReportExitIncomplete;
  }
  if (request.failOnRealDeviceNeeded &&
      review.needsRealDeviceEvidenceCount > 0) {
    return goldenEvidenceReviewReportExitRealDeviceNeeded;
  }
  if (request.failOnMismatch &&
      (review.failed > 0 ||
          review.behaviorMismatches > 0 ||
          review.budgetMismatches > 0 ||
          review.blockedUnsafeClaims > 0)) {
    return goldenEvidenceReviewReportExitMismatch;
  }
  return goldenEvidenceReviewReportExitSuccess;
}

GoldenEvidenceReviewMode? _modeByWire(String value) {
  for (final mode in GoldenEvidenceReviewMode.values) {
    if (mode.wire == value) return mode;
  }
  return null;
}

GoldenEvidenceReviewReportFormat? _formatByWire(String value) {
  for (final format in GoldenEvidenceReviewReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Golden Evidence Review report command usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/golden_evidence_review_report.dart')
    ..writeln(
      '  dart run tool/golden_evidence_review_report.dart '
      '--mode=metadataOnly',
    )
    ..writeln(
      '  dart run tool/golden_evidence_review_report.dart --format=json',
    )
    ..writeln()
    ..writeln('Supported modes:')
    ..writeln(
      '  metadataOnly, planOnly, fakeEvidence, '
      'realDeviceEvidenceReferenceOnly',
    )
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Strict flags:')
    ..writeln('  --fail-on-mismatch')
    ..writeln('  --fail-on-incomplete')
    ..writeln('  --fail-on-real-device-needed');
  return buffer.toString();
}

const _modeFlag = '--mode=';
const _formatFlag = '--format=';
const _failOnMismatchFlag = '--fail-on-mismatch';
const _failOnIncompleteFlag = '--fail-on-incomplete';
const _failOnRealDeviceNeededFlag = '--fail-on-real-device-needed';
