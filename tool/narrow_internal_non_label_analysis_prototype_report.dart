import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';

const narrowInternalNonLabelAnalysisPrototypeReportExitSuccess = 0;
const narrowInternalNonLabelAnalysisPrototypeReportExitUsage = 64;
const narrowInternalNonLabelAnalysisPrototypeReportExitBlockedStrict = 68;
const narrowInternalNonLabelAnalysisPrototypeReportExitUnsafePolicy = 69;

class NarrowInternalNonLabelAnalysisPrototypeReportCommandResult {
  const NarrowInternalNonLabelAnalysisPrototypeReportCommandResult({
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
  final NarrowInternalNonLabelAnalysisPrototypeReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final NarrowInternalNonLabelAnalysisPrototypeResult? result;
  final String? commandFailure;
}

class NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest {
  const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = NarrowInternalNonLabelAnalysisPrototypeReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final NarrowInternalNonLabelAnalysisPrototypeReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runNarrowInternalNonLabelAnalysisPrototypeReportCommand(
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

NarrowInternalNonLabelAnalysisPrototypeReportCommandResult
runNarrowInternalNonLabelAnalysisPrototypeReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  NarrowInternalNonLabelAnalysisPrototype prototype =
      const NarrowInternalNonLabelAnalysisPrototype(),
  NarrowInternalNonLabelAnalysisPrototypeRequest? request,
}) {
  final commandRequest =
      validateNarrowInternalNonLabelAnalysisPrototypeReportArgs(args);
  if (!commandRequest.isValid) {
    return NarrowInternalNonLabelAnalysisPrototypeReportCommandResult(
      exitCode: narrowInternalNonLabelAnalysisPrototypeReportExitUsage,
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
    return NarrowInternalNonLabelAnalysisPrototypeReportCommandResult(
      exitCode: narrowInternalNonLabelAnalysisPrototypeReportExitSuccess,
      format: commandRequest.format,
      strict: commandRequest.strict,
      safeDemo: commandRequest.safeDemo,
      includeWarnings: commandRequest.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final prototypeRequest =
      request ??
      NarrowInternalNonLabelAnalysisPrototypeRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = prototype.run(prototypeRequest);
  final stdoutText = switch (commandRequest.format) {
    NarrowInternalNonLabelAnalysisPrototypeReportFormat.markdown =>
      result.renderMarkdownReport(),
    NarrowInternalNonLabelAnalysisPrototypeReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return NarrowInternalNonLabelAnalysisPrototypeReportCommandResult(
    exitCode: narrowInternalNonLabelAnalysisPrototypeReportExitCode(
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

NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest
validateNarrowInternalNonLabelAnalysisPrototypeReportArgs(List<String> args) {
  var format = NarrowInternalNonLabelAnalysisPrototypeReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.valid(
        format: NarrowInternalNonLabelAnalysisPrototypeReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
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
        return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int narrowInternalNonLabelAnalysisPrototypeReportExitCode(
  NarrowInternalNonLabelAnalysisPrototypeResult result,
  NarrowInternalNonLabelAnalysisPrototypeReportCommandRequest request,
) {
  if (result.hasUnsafePrototypePolicyViolation) {
    return narrowInternalNonLabelAnalysisPrototypeReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return narrowInternalNonLabelAnalysisPrototypeReportExitBlockedStrict;
  }
  return narrowInternalNonLabelAnalysisPrototypeReportExitSuccess;
}

NarrowInternalNonLabelAnalysisPrototypeReportFormat? _formatByWire(
  String value,
) {
  for (final format
      in NarrowInternalNonLabelAnalysisPrototypeReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Narrow Internal Non-Label Analysis Prototype report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/narrow_internal_non_label_analysis_prototype_report.dart',
    )
    ..writeln(
      '  dart run tool/narrow_internal_non_label_analysis_prototype_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/narrow_internal_non_label_analysis_prototype_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/narrow_internal_non_label_analysis_prototype_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/narrow_internal_non_label_analysis_prototype_report.dart --include-warnings',
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
