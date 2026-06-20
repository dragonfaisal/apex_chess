import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult? result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
              .markdown,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
  format;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness harness =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitUsage,
      format: request.format,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitSuccess,
      format: request.format,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = harness.inspectSafeDemo();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat.json =>
      '${result.renderJson()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: reportFindings.isNotEmpty,
  );

  return DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult(
    exitCode: exitCode,
    format: request.format,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
          .markdown;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const _CommandRequest.invalid('helpCannotBeCombined');
      }
      return const _CommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
                .markdown,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const _CommandRequest.invalid('duplicateFormat');
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) return const _CommandRequest.invalid('unknownFormat');
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
        return const _CommandRequest.invalid('duplicateSafeDemo');
      }
      safeDemo = true;
      safeDemoSeen = true;
      continue;
    }
    if (arg == _includeWarningsFlag) {
      if (includeWarningsSeen) {
        return const _CommandRequest.invalid('duplicateIncludeWarnings');
      }
      includeWarnings = true;
      includeWarningsSeen = true;
      continue;
    }
    return const _CommandRequest.invalid('unknownFlag');
  }

  return _CommandRequest.valid(
    format: format,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings]',
    'defaults: --format=markdown --safe-demo --include-warnings',
  ].join('\n');
}

const _formatFlag = '--format=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
