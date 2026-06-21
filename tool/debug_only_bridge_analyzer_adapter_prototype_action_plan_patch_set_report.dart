import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_diagnostic_action_plan.dart';

const debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess = 0;
const debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult({
    required this.exitCode,
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    required this.stdoutText,
    required this.stderrText,
    this.result,
    this.commandFailure,
  });

  final int exitCode;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult? result;
  final String? commandFailure;
}

class _CommandRequest {
  const _CommandRequest.valid({
    required this.format,
    required this.section,
    required this.strict,
    required this.safeDemo,
    required this.includeWarnings,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const _CommandRequest.invalid(this.failure)
    : isValid = false,
      format =
          DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet patchSet =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet(),
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan
      actionPlan =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUsage,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: '',
      stderrText: _usage(request.failure),
      commandFailure: request.failure,
    );
  }
  if (request.showHelp) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final actionPlanResult = actionPlan.evaluate();
  final result = patchSet.evaluate(actionPlanResult: actionPlanResult);
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
        .markdown =>
      result.renderMarkdown(section: request.section),
    DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
        .json =>
      '${result.renderJson(section: request.section)}\n',
  };
  final reportFindings =
      const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetValidator()
          .validateReportText(stdoutText);
  final exitCode = _exitCode(
    result,
    request,
    hasTextLeak: reportFindings.isNotEmpty,
  );
  return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult(
    exitCode: exitCode,
    format: request.format,
    section: request.section,
    strict: request.strict,
    safeDemo: request.safeDemo,
    includeWarnings: request.includeWarnings,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

int _exitCode(
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUnsafePolicy;
  }
  if (request.strict && result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitBlockedStrict;
  }
  if (result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUnsafePolicy;
  }
  return debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection.all;
  var strict = false;
  var safeDemo = true;
  var includeWarnings = true;
  var formatSeen = false;
  var sectionSeen = false;
  var safeDemoSeen = false;
  var includeWarningsSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const _CommandRequest.invalid('helpCannotBeCombined');
      }
      return const _CommandRequest.valid(
        format:
            DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection
                .all,
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
    if (arg.startsWith(_sectionFlag)) {
      if (sectionSeen) return const _CommandRequest.invalid('duplicateSection');
      final parsed = _sectionByWire(arg.substring(_sectionFlag.length).trim());
      if (parsed == null) {
        return const _CommandRequest.invalid('unknownSection');
      }
      section = parsed;
      sectionSeen = true;
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
    section: section,
    strict: strict,
    safeDemo: safeDemo,
    includeWarnings: includeWarnings,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetSection
          .values) {
    if (section.wire == wire) return section;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|patches|support|warning|proof|guards|denied|blocked|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
