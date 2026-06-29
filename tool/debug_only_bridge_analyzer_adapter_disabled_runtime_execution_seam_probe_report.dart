import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection {
  all('all'),
  request('request'),
  response('response'),
  attempt('attempt'),
  boundaries('boundaries'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult? result;
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
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe seamProbe =
      const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = seamProbe.evaluate();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
        .json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings =
      const DisabledAnalyzerAdapterRuntimeExecutionSeamProbeValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult(
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

int _exitCode(
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.seamProbePerformedCount > 0 ||
          result.runtimeExecutionCount > 0 ||
          result.runtimeExecutionApprovedCount > 0 ||
          result.analyzerRuntimeInputCount > 0 ||
          result.analyzerWiringCount > 0 ||
          result.executableRuntimeCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.productOutputCount > 0 ||
          result.productAdapterCount > 0 ||
          result.savedAnalysisIntegrationCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          result.seamProbeAttemptCount < 1 ||
          !result.safeForPhase34N ||
          result.nextRecommendation !=
              'runDisabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnostic')) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess;
}

String _renderMarkdown(
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
          .all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln('# Disabled Analyzer Adapter Runtime Execution Seam Probe')
    ..writeln()
    ..writeln('- seam probe status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34N: ${result.safeForPhase34N}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .request:
      buffer
        ..writeln('## Seam Probe Request Summary')
        ..writeln('- request ID: ${result.request.requestId}')
        ..writeln('- seamProbeRequested: ${result.request.seamProbeRequested}')
        ..writeln('- seamProbePerformed: ${result.request.seamProbePerformed}')
        ..writeln('- executionPerformed: ${result.request.executionPerformed}')
        ..writeln(
          '- analyzerRuntimeInputProduced: ${result.request.analyzerRuntimeInputProduced}',
        );
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .response:
      buffer
        ..writeln('## Seam Probe Response Summary')
        ..writeln('- response ID: ${result.response.responseId}')
        ..writeln('- response status: ${result.response.responseStatus}')
        ..writeln('- refused reason: ${result.response.refusedReason}')
        ..writeln(
          '- seamProbePerformed: ${result.response.seamProbePerformed}',
        );
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .attempt:
      buffer
        ..writeln('## Refused Seam Probe Attempt Summary')
        ..writeln('- attempt ID: ${result.attempt.attemptId}')
        ..writeln('- seamProbeRequested: ${result.attempt.seamProbeRequested}')
        ..writeln('- seamProbePerformed: ${result.attempt.seamProbePerformed}')
        ..writeln('- executionPerformed: ${result.attempt.executionPerformed}')
        ..writeln('- refused: ${result.attempt.refused}');
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .boundaries:
      _writeBoundaries(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .blockedReasons:
      _writeBlockedReasons(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .denied:
      buffer
        ..writeln('## Denied Field Summary')
        ..writeln('- denied field count: ${result.deniedFieldCount}')
        ..writeln('- denied field IDs: ${_ids(result.policy.deniedFieldIds)}')
        ..writeln(
          '- active denied field count: ${result.activeDeniedFieldCount}',
        );
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .proof:
      buffer
        ..writeln('## Proof Boundary Summary')
        ..writeln('- android proof IDs: ${_ids(result.input.androidProofIds)}')
        ..writeln('- owner proof required: ${result.input.ownerProofRequired}')
        ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}');
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .recommendation:
      buffer
        ..writeln('## Recommendation')
        ..writeln('- safe for Phase 34N: ${result.safeForPhase34N}')
        ..writeln('- next recommendation: ${result.nextRecommendation}')
        ..writeln('- findings: ${_ids(result.findings)}');
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .all:
      break;
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderJson(
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
  section,
) {
  final payload = result.toJson();
  payload['section'] = section.wire;
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
          .all) {
    return result.renderJson();
  }
  final scoped = <String, Object?>{
    'version': payload['version'],
    'status': payload['status'],
    'section': section.wire,
    'safeForPhase34N': payload['safeForPhase34N'],
    'nextRecommendation': payload['nextRecommendation'],
    'counts': payload['counts'],
  };
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .request:
      scoped['request'] = result.request.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .response:
      scoped['response'] = result.response.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .attempt:
      scoped['attempt'] = result.attempt.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .boundaries:
      scoped['boundaries'] = result.boundaries
          .map((boundary) => boundary.toJson())
          .toList();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .blockedReasons:
      scoped['blockedReasons'] = result.blockedReasons
          .map((reason) => reason.toJson())
          .toList();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .denied:
      scoped['deniedFieldIds'] = result.policy.deniedFieldIds;
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .proof:
      scoped['proof'] = <String, Object?>{
        'androidProofIds': result.input.androidProofIds,
        'ownerProofRequired': result.input.ownerProofRequired,
        'ownerProofQueueCount': result.ownerProofQueueCount,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .recommendation:
      scoped['recommendation'] = <String, Object?>{
        'safeForPhase34N': result.safeForPhase34N,
        'nextRecommendation': result.nextRecommendation,
        'findings': result.findings,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
        .all:
      break;
  }
  return const JsonEncoder.withIndent(' ').convert(scoped);
}

void _writeBoundaries(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
) {
  buffer
    ..writeln('## Boundary Summary')
    ..writeln('| Boundary | Target surface | Blocked |')
    ..writeln('| --- | --- | --- |');
  for (final boundary in result.boundaries) {
    buffer.writeln(
      '| ${boundary.boundaryId} | ${boundary.targetSurface} | ${boundary.blocked} |',
    );
  }
}

void _writeBlockedReasons(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult result,
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

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
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
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
          .values) {
    if (section.wire == wire) return section;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|request|response|attempt|boundaries|blocked-reasons|denied|proof|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

String _ids(Iterable<String> ids) {
  final values = ids.toList()..sort();
  return values.isEmpty ? '-' : values.join(', ');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
