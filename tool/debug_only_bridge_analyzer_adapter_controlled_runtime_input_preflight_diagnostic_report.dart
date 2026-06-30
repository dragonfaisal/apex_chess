import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.mode,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
  mode;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult?
  result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.mode,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
              .markdown,
      mode =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
              .defaultMode,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
  mode;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic
      diagnostic =
      const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitUsage,
      format: request.format,
      mode: request.mode,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess,
      format: request.format,
      mode: request.mode,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = diagnostic.evaluate(mode: request.mode);
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
        .json =>
      '${result.renderJson()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult(
    exitCode: _exitCode(
      result,
      request,
      hasTextLeak: reportFindings.isNotEmpty,
    ),
    format: request.format,
    mode: request.mode,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticResult
  result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.seamProbePerformedCount > 0 ||
          result.runtimeExecutionCount > 0 ||
          result.runtimeExecutionApprovedCount > 0 ||
          result.analyzerRuntimeInputApprovedCount > 0 ||
          result.analyzerRuntimeInputProducedCount > 0 ||
          result.analyzerWiringCount > 0 ||
          result.executableRuntimeCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.productOutputCount > 0 ||
          result.productAdapterCount > 0 ||
          result.savedAnalysisIntegrationCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          !result.safeForPhase34Q ||
          result.nextRecommendation !=
              'implementDisabledAnalyzerAdapterRuntimeInputEnvelopePatch')) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
          .markdown;
  var mode =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
          .defaultMode;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var modeSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const _CommandRequest.invalid('helpCannotBeCombined');
      }
      return const _CommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
                .markdown,
        mode:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
                .defaultMode,
        strict: false,
        safeDemo: true,
        includeWarnings: true,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) return const _CommandRequest.invalid('duplicateFormat');
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) return const _CommandRequest.invalid('unknownFormat');
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_diagnosticFlag)) {
      if (modeSeen) {
        return const _CommandRequest.invalid(
          'duplicateRuntimeInputPreflightDiagnostic',
        );
      }
      final parsed = _modeByWire(arg.substring(_diagnosticFlag.length).trim());
      if (parsed == null) {
        return const _CommandRequest.invalid(
          'unknownRuntimeInputPreflightDiagnosticMode',
        );
      }
      mode = parsed;
      modeSeen = true;
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
    mode: mode,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode?
_modeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
          .values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--runtime-input-preflight-diagnostic=default|all-safe|checks|decision|blocked-reasons|denied|proof|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --runtime-input-preflight-diagnostic=default',
  ].join('\n');
}

const _formatFlag = '--format=';
const _diagnosticFlag = '--runtime-input-preflight-diagnostic=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
