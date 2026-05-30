import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_evidence_triage.dart';

const goldenEvidenceTriageReportExitSuccess = 0;
const goldenEvidenceTriageReportExitUsage = 64;

class GoldenEvidenceTriageReportCommandResult {
  const GoldenEvidenceTriageReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.maxProofTargets,
    required this.includeProtected,
    required this.stdoutText,
    required this.stderrText,
    this.triage,
    this.commandFailure,
  });

  final int exitCode;
  final GoldenEvidenceTriageReportFormat format;
  final int maxProofTargets;
  final bool includeProtected;
  final String stdoutText;
  final String stderrText;
  final GoldenEvidenceTriageResult? triage;
  final String? commandFailure;
}

class GoldenEvidenceTriageReportCommandRequest {
  const GoldenEvidenceTriageReportCommandRequest.valid({
    required this.format,
    required this.maxProofTargets,
    required this.includeProtected,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const GoldenEvidenceTriageReportCommandRequest.invalid(this.failure)
    : isValid = false,
      format = GoldenEvidenceTriageReportFormat.markdown,
      maxProofTargets = 3,
      includeProtected = false,
      showHelp = false;

  final bool isValid;
  final String failure;
  final GoldenEvidenceTriageReportFormat format;
  final int maxProofTargets;
  final bool includeProtected;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runGoldenEvidenceTriageReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

GoldenEvidenceTriageReportCommandResult runGoldenEvidenceTriageReportCommand({
  required List<String> args,
  GoldenEvidenceTriageRunner runner = const GoldenEvidenceTriageRunner(),
}) {
  final request = validateGoldenEvidenceTriageReportArgs(args);
  if (!request.isValid) {
    return GoldenEvidenceTriageReportCommandResult(
      exitCode: goldenEvidenceTriageReportExitUsage,
      format: request.format,
      maxProofTargets: request.maxProofTargets,
      includeProtected: request.includeProtected,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return GoldenEvidenceTriageReportCommandResult(
      exitCode: goldenEvidenceTriageReportExitSuccess,
      format: request.format,
      maxProofTargets: request.maxProofTargets,
      includeProtected: request.includeProtected,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final triage = runner.run(
    GoldenEvidenceTriageRequest(
      maxProofTargets: request.maxProofTargets,
      includeProtected: request.includeProtected,
    ),
  );
  final stdoutText = switch (request.format) {
    GoldenEvidenceTriageReportFormat.markdown => triage.renderMarkdownReport(),
    GoldenEvidenceTriageReportFormat.json => '${triage.renderJsonReport()}\n',
  };

  return GoldenEvidenceTriageReportCommandResult(
    exitCode: goldenEvidenceTriageReportExitSuccess,
    format: request.format,
    maxProofTargets: request.maxProofTargets,
    includeProtected: request.includeProtected,
    stdoutText: stdoutText,
    stderrText: '',
    triage: triage,
  );
}

GoldenEvidenceTriageReportCommandRequest validateGoldenEvidenceTriageReportArgs(
  List<String> args,
) {
  var format = GoldenEvidenceTriageReportFormat.markdown;
  var maxProofTargets = 3;
  var includeProtected = false;
  var formatSeen = false;
  var maxProofTargetsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const GoldenEvidenceTriageReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const GoldenEvidenceTriageReportCommandRequest.valid(
        format: GoldenEvidenceTriageReportFormat.markdown,
        maxProofTargets: 3,
        includeProtected: false,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const GoldenEvidenceTriageReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const GoldenEvidenceTriageReportCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_maxProofTargetsFlag)) {
      if (maxProofTargetsSeen) {
        return const GoldenEvidenceTriageReportCommandRequest.invalid(
          'duplicateMaxProofTargets',
        );
      }
      final parsed = int.tryParse(
        arg.substring(_maxProofTargetsFlag.length).trim(),
      );
      if (parsed == null || parsed < 0) {
        return const GoldenEvidenceTriageReportCommandRequest.invalid(
          'invalidMaxProofTargets',
        );
      }
      maxProofTargets = parsed;
      maxProofTargetsSeen = true;
      continue;
    }
    if (arg == _includeProtectedFlag) {
      includeProtected = true;
      continue;
    }
    return const GoldenEvidenceTriageReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return GoldenEvidenceTriageReportCommandRequest.valid(
    format: format,
    maxProofTargets: maxProofTargets,
    includeProtected: includeProtected,
  );
}

GoldenEvidenceTriageReportFormat? _formatByWire(String value) {
  for (final format in GoldenEvidenceTriageReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Golden Evidence Triage report command usage error: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/golden_evidence_triage_report.dart')
    ..writeln(
      '  dart run tool/golden_evidence_triage_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/golden_evidence_triage_report.dart '
      '--max-proof-targets=3',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --max-proof-targets=<nonnegative integer>')
    ..writeln('  --include-protected');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _maxProofTargetsFlag = '--max-proof-targets=';
const _includeProtectedFlag = '--include-protected';
