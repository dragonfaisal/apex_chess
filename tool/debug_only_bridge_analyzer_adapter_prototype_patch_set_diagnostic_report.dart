import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.patchDiagnosticMode,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
  patchDiagnosticMode;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult? result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.patchDiagnosticMode,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
              .markdown,
      patchDiagnosticMode =
          DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
              .defaultMode,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
  patchDiagnosticMode;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic diagnostic =
      const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitUsage,
      format: request.format,
      patchDiagnosticMode: request.patchDiagnosticMode,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitSuccess,
      format: request.format,
      patchDiagnosticMode: request.patchDiagnosticMode,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = diagnostic.evaluate(mode: request.patchDiagnosticMode);
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
        .json =>
      '${result.renderJson()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: reportFindings.isNotEmpty,
  );
  return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportCommandResult(
    exitCode: exitCode,
    format: request.format,
    patchDiagnosticMode: request.patchDiagnosticMode,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitBlockedStrict;
  }
  if (result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitUnsafePolicy;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
          .markdown;
  var mode =
      DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.defaultMode;
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
            DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
                .markdown,
        patchDiagnosticMode:
            DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
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
    if (arg.startsWith(_patchDiagnosticFlag)) {
      if (modeSeen) {
        return const _CommandRequest.invalid('duplicatePatchDiagnostic');
      }
      final parsed = _modeByWire(
        arg.substring(_patchDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const _CommandRequest.invalid('unknownPatchDiagnostic');
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
    patchDiagnosticMode: mode,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode? _modeByWire(
  String wire,
) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode.values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--patch-diagnostic=default|all-safe|support|warning|proof|guards|denied|blocked|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --patch-diagnostic=default',
  ].join('\n');
}

const _formatFlag = '--format=';
const _patchDiagnosticFlag = '--patch-diagnostic=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
