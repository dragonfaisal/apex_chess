import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.refinementDiagnosticMode,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
  refinementDiagnosticMode;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult?
  result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.refinementDiagnosticMode,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
              .markdown,
      refinementDiagnosticMode =
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
              .defaultMode,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
  refinementDiagnosticMode;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic
      diagnostic =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUsage,
      format: request.format,
      refinementDiagnosticMode: request.refinementDiagnosticMode,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess,
      format: request.format,
      refinementDiagnosticMode: request.refinementDiagnosticMode,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = diagnostic.evaluate(mode: request.refinementDiagnosticMode);
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
        .markdown =>
      result.renderMarkdown(),
    DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
        .json =>
      '${result.renderJson()}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult(
    exitCode: _exitCode(
      result,
      request,
      hasTextLeak: reportFindings.isNotEmpty,
    ),
    format: request.format,
    refinementDiagnosticMode: request.refinementDiagnosticMode,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticResult
  result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitBlockedStrict;
  }
  if (result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUnsafePolicy;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
          .markdown;
  var mode =
      DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
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
            DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
                .markdown,
        refinementDiagnosticMode:
            DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
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
    if (arg.startsWith(_refinementDiagnosticFlag)) {
      if (modeSeen) {
        return const _CommandRequest.invalid('duplicateRefinementDiagnostic');
      }
      final parsed = _modeByWire(
        arg.substring(_refinementDiagnosticFlag.length).trim(),
      );
      if (parsed == null) {
        return const _CommandRequest.invalid('unknownRefinementDiagnostic');
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
    refinementDiagnosticMode: mode,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode?
_modeByWire(String wire) {
  for (final mode
      in DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
          .values) {
    if (mode.wire == wire) return mode;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--refinement-diagnostic=default|all-safe|support|warning|proof|guards|denied|blocked|surfaces|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --refinement-diagnostic=default',
  ].join('\n');
}

const _formatFlag = '--format=';
const _refinementDiagnosticFlag = '--refinement-diagnostic=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
