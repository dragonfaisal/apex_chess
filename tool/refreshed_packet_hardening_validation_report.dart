import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';

const refreshedPacketHardeningValidationReportExitSuccess = 0;
const refreshedPacketHardeningValidationReportExitUsage = 64;
const refreshedPacketHardeningValidationReportExitBlockedStrict = 68;
const refreshedPacketHardeningValidationReportExitUnsafePolicy = 69;

class RefreshedPacketHardeningValidationReportCommandResult {
  const RefreshedPacketHardeningValidationReportCommandResult({
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
  final RefreshedPacketHardeningValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final RefreshedPacketHardeningValidationResult? result;
  final String? commandFailure;
}

class RefreshedPacketHardeningValidationReportCommandRequest {
  const RefreshedPacketHardeningValidationReportCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
    this.failure,
  ) : isValid = false,
      format = RefreshedPacketHardeningValidationReportFormat.markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final RefreshedPacketHardeningValidationReportFormat format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result = runRefreshedPacketHardeningValidationReportCommand(args: args);
  if (result.stdoutText.isNotEmpty) {
    io.stdout.write(result.stdoutText);
  }
  if (result.stderrText.isNotEmpty) {
    io.stderr.write(result.stderrText);
  }
  io.exitCode = result.exitCode;
}

RefreshedPacketHardeningValidationReportCommandResult
runRefreshedPacketHardeningValidationReportCommand({
  required List<String> args,
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
  RefreshedPacketHardeningValidation validation =
      const RefreshedPacketHardeningValidation(),
  RefreshedPacketHardeningValidationRequest? request,
}) {
  final commandRequest = validateRefreshedPacketHardeningValidationReportArgs(
    args,
  );
  if (!commandRequest.isValid) {
    return RefreshedPacketHardeningValidationReportCommandResult(
      exitCode: refreshedPacketHardeningValidationReportExitUsage,
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
    return RefreshedPacketHardeningValidationReportCommandResult(
      exitCode: refreshedPacketHardeningValidationReportExitSuccess,
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
      RefreshedPacketHardeningValidationRequest.safeDemo(
        cases: cases,
        includeWarnings: commandRequest.includeWarnings,
      );
  final result = validation.evaluate(validationRequest);
  final stdoutText = switch (commandRequest.format) {
    RefreshedPacketHardeningValidationReportFormat.markdown =>
      result.renderMarkdownReport(),
    RefreshedPacketHardeningValidationReportFormat.json =>
      '${result.renderJsonReport()}\n',
  };

  return RefreshedPacketHardeningValidationReportCommandResult(
    exitCode: refreshedPacketHardeningValidationReportExitCode(
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

RefreshedPacketHardeningValidationReportCommandRequest
validateRefreshedPacketHardeningValidationReportArgs(List<String> args) {
  var format = RefreshedPacketHardeningValidationReportFormat.markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return const RefreshedPacketHardeningValidationReportCommandRequest.valid(
        format: RefreshedPacketHardeningValidationReportFormat.markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
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
        return const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
          'duplicateSafeDemo',
        );
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
          'duplicateIncludeWarnings',
        );
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const RefreshedPacketHardeningValidationReportCommandRequest.invalid(
      'unknownFlag',
    );
  }

  return RefreshedPacketHardeningValidationReportCommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

int refreshedPacketHardeningValidationReportExitCode(
  RefreshedPacketHardeningValidationResult result,
  RefreshedPacketHardeningValidationReportCommandRequest request,
) {
  if (result.hasUnsafeValidationPolicyViolation) {
    return refreshedPacketHardeningValidationReportExitUnsafePolicy;
  }
  if (request.strict && result.isStrictlyBlocked) {
    return refreshedPacketHardeningValidationReportExitBlockedStrict;
  }
  return refreshedPacketHardeningValidationReportExitSuccess;
}

RefreshedPacketHardeningValidationReportFormat? _formatByWire(String value) {
  for (final format in RefreshedPacketHardeningValidationReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln(
      'Refreshed Packet Hardening Validation report usage error: $failure',
    )
    ..writeln()
    ..writeln('Usage:')
    ..writeln(
      '  dart run tool/refreshed_packet_hardening_validation_report.dart',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_hardening_validation_report.dart --format=json',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_hardening_validation_report.dart --strict',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_hardening_validation_report.dart --safe-demo',
    )
    ..writeln(
      '  dart run tool/refreshed_packet_hardening_validation_report.dart --include-warnings',
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
