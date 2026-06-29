import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection {
  all('all'),
  checks('checks'),
  decision('decision'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final ControlledAnalyzerAdapterRuntimeInputPreflightResult? result;
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
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight preflight =
      const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = preflight.evaluate();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
        .json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings =
      const ControlledAnalyzerAdapterRuntimeInputPreflightValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportCommandResult(
    exitCode: _exitCode(
      result,
      request,
      hasTextLeak: reportFindings.isNotEmpty,
    ),
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

String _renderMarkdown(
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
          .all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln('# Controlled Analyzer Adapter Runtime Input Preflight')
    ..writeln()
    ..writeln('- preflight status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34P: ${result.safeForPhase34P}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .checks:
      _writeChecks(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .decision:
      _writeDecision(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .blockedReasons:
      _writeBlockedReasons(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .denied:
      _writeDenied(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .proof:
      _writeProof(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .recommendation:
      _writeRecommendation(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .all:
      break;
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderJson(
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
          .all) {
    return result.renderJson();
  }
  final payload = <String, Object?>{
    'version':
        debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightVersion,
    'status': result.status.wire,
    'section': section.wire,
    'safeForPhase34P': result.safeForPhase34P,
    'nextRecommendation': result.nextRecommendation,
  };
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .checks:
      payload['checks'] = result.checks
          .map((check) => check.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .decision:
      payload['decision'] = result.decision.toJson();
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .blockedReasons:
      payload['blockedReasons'] = result.blockedReasons
          .map((reason) => reason.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .denied:
      payload['denied'] = <String, Object?>{
        'deniedFieldCount': result.deniedFieldCount,
        'deniedFieldIds': result.policy.deniedFieldIds,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .proof:
      payload['proof'] = <String, Object?>{
        'androidProofIds': result.input.androidProofIds,
        'ownerProofRequired': result.input.ownerProofRequired,
        'ownerProofQueueCount': result.ownerProofQueueCount,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .recommendation:
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34P': result.safeForPhase34P,
        'nextRecommendation': result.nextRecommendation,
        'findings': result.findings,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
        .all:
      break;
  }
  return const JsonEncoder.withIndent(' ').convert(payload);
}

void _writeChecks(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
) {
  buffer
    ..writeln('## Runtime Input Preflight Check Summary')
    ..writeln('| Check | Passed | Blocked reasons |')
    ..writeln('| --- | --- | --- |');
  for (final check in result.checks) {
    buffer.writeln(
      '| ${check.checkId} | ${check.passed} | ${_ids(check.blockedReasonIds)} |',
    );
  }
}

void _writeDecision(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
) {
  buffer
    ..writeln('## Runtime Input Preflight Decision Summary')
    ..writeln('- decision ID: ${result.decision.decisionId}')
    ..writeln('- seamProbePerformed: ${result.decision.seamProbePerformed}')
    ..writeln('- executionPerformed: ${result.decision.executionPerformed}')
    ..writeln('- executionAllowed: ${result.decision.executionAllowed}')
    ..writeln(
      '- runtimeExecutionApproved: ${result.decision.runtimeExecutionApproved}',
    )
    ..writeln(
      '- analyzerRuntimeInputApproved: ${result.decision.analyzerRuntimeInputApproved}',
    )
    ..writeln(
      '- analyzerRuntimeInputProduced: ${result.decision.analyzerRuntimeInputProduced}',
    )
    ..writeln(
      '- analyzerWiringAllowed: ${result.decision.analyzerWiringAllowed}',
    )
    ..writeln('- engineCallsAllowed: ${result.decision.engineCallsAllowed}')
    ..writeln('- schedulerAllowed: ${result.decision.schedulerAllowed}')
    ..writeln('- persistenceAllowed: ${result.decision.persistenceAllowed}')
    ..writeln('- productOutputAllowed: ${result.decision.productOutputAllowed}')
    ..writeln(
      '- productAdapterAllowed: ${result.decision.productAdapterAllowed}',
    )
    ..writeln(
      '- savedAnalysisAllowed: ${result.decision.savedAnalysisAllowed}',
    );
}

void _writeBlockedReasons(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
) {
  buffer
    ..writeln('## Blocked Reason Summary')
    ..writeln('| Reason | Surface | Blocked |')
    ..writeln('| --- | --- | --- |');
  for (final reason in result.blockedReasons) {
    buffer.writeln(
      '| ${reason.blockedReasonId} | ${reason.blockedSurface} | ${reason.blocked} |',
    );
  }
}

void _writeDenied(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
) {
  buffer
    ..writeln('## Denied Field Summary')
    ..writeln('- denied field count: ${result.deniedFieldCount}')
    ..writeln('- denied field IDs: ${_ids(result.policy.deniedFieldIds)}');
}

void _writeProof(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
) {
  buffer
    ..writeln('## Proof Boundary Summary')
    ..writeln('- android proof IDs: ${_ids(result.input.androidProofIds)}')
    ..writeln('- owner proof required: ${result.input.ownerProofRequired}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}');
}

void _writeRecommendation(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 34P: ${result.safeForPhase34P}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- findings: ${_ids(result.findings)}');
}

int _exitCode(
  ControlledAnalyzerAdapterRuntimeInputPreflightResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.seamProbePerformedCount > 0 ||
          result.runtimeExecutionCount > 0 ||
          result.runtimeExecutionApprovedCount > 0 ||
          result.analyzerRuntimeInputProducedCount > 0 ||
          result.analyzerRuntimeInputApprovedCount > 0 ||
          result.analyzerWiringCount > 0 ||
          result.executableRuntimeCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.productOutputCount > 0 ||
          result.productAdapterCount > 0 ||
          result.savedAnalysisIntegrationCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          !result.safeForPhase34P ||
          result.nextRecommendation !=
              'runControlledAnalyzerAdapterRuntimeInputPreflightDiagnostic')) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
          .all;
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
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightReportSection
          .values) {
    if (section.wire == wire) return section;
  }
  return null;
}

String _ids(Iterable<String> values) {
  final sorted =
      values.where((value) => value.trim().isNotEmpty).toSet().toList()..sort();
  return sorted.isEmpty ? '-' : sorted.join(', ');
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|checks|decision|blocked-reasons|denied|proof|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
