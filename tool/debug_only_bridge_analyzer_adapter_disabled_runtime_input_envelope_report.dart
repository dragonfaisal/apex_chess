import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection {
  all('all'),
  slots('slots'),
  boundaries('boundaries'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DisabledAnalyzerAdapterRuntimeInputEnvelopeResult? result;
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
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope envelope =
      const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelope(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = envelope.evaluate();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
        .json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings =
      const DisabledAnalyzerAdapterRuntimeInputEnvelopeValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult(
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
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
          .all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln('# Disabled Analyzer Adapter Runtime Input Envelope')
    ..writeln()
    ..writeln('- envelope status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34R: ${result.safeForPhase34R}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .slots:
      _writeSlots(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .boundaries:
      _writeBoundaries(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .blockedReasons:
      _writeBlockedReasons(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .denied:
      _writeDenied(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .proof:
      _writeProof(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .recommendation:
      _writeRecommendation(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
        .all:
      break;
  }
  return buffer.toString();
}

String _renderJson(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
  section,
) {
  final payload = result.toJson();
  payload['selectedSection'] = section.wire;
  return const JsonEncoder.withIndent(' ').convert(payload);
}

void _writeSlots(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
) {
  buffer
    ..writeln('## Slot Summary')
    ..writeln('| Slot | Status | Disabled | Blocked | Active payload |')
    ..writeln('| --- | --- | --- | --- | --- |');
  for (final slot in result.slots) {
    buffer.writeln(
      '| ${slot.slotId} | ${slot.slotStatus} | ${slot.disabled} | ${slot.blocked} | ${slot.activePayloadPresent} |',
    );
  }
  buffer.writeln();
}

void _writeBoundaries(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
) {
  buffer
    ..writeln('## Boundary Summary')
    ..writeln('| Boundary | Surface | Blocked |')
    ..writeln('| --- | --- | --- |');
  for (final boundary in result.boundaries) {
    buffer.writeln(
      '| ${boundary.boundaryId} | ${boundary.boundarySurface} | ${boundary.blocked} |',
    );
  }
  buffer.writeln();
}

void _writeBlockedReasons(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
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
  buffer.writeln();
}

void _writeDenied(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
) {
  buffer
    ..writeln('## Denied Field Summary')
    ..writeln('- denied field count: ${result.policy.deniedFieldIds.length}')
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln(
      '- active runtime input envelope count: ${result.activeRuntimeInputEnvelopeCount}',
    )
    ..writeln(
      '- analyzer runtime input approved count: ${result.analyzerRuntimeInputApprovedCount}',
    )
    ..writeln(
      '- analyzer runtime input produced count: ${result.analyzerRuntimeInputProducedCount}',
    )
    ..writeln('- runtime execution count: ${result.runtimeExecutionCount}')
    ..writeln();
}

void _writeProof(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
) {
  buffer
    ..writeln('## Proof Boundary Summary')
    ..writeln('- android proof IDs: ${_ids(result.input.androidProofIds)}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}')
    ..writeln(
      '- Phase 32E proof claim count: ${result.phase32EProofClaimCount}',
    )
    ..writeln();
}

void _writeRecommendation(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safeForPhase34R: ${result.safeForPhase34R}')
    ..writeln('- nextRecommendation: ${result.nextRecommendation}')
    ..writeln();
}

int _exitCode(
  DisabledAnalyzerAdapterRuntimeInputEnvelopeResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.disabledEnvelopeCount < 1 ||
          result.activeRuntimeInputEnvelopeCount > 0 ||
          result.analyzerRuntimeInputApprovedCount > 0 ||
          result.analyzerRuntimeInputProducedCount > 0 ||
          result.runtimeExecutionApprovedCount > 0 ||
          result.runtimeExecutionCount > 0 ||
          result.analyzerWiringCount > 0 ||
          result.executableRuntimeCount > 0 ||
          result.engineCallCount > 0 ||
          result.schedulerExecutionCount > 0 ||
          result.persistenceWriteCount > 0 ||
          result.productOutputCount > 0 ||
          result.productAdapterCount > 0 ||
          result.savedAnalysisIntegrationCount > 0 ||
          result.activePayloadSlotCount > 0 ||
          result.activeDeniedFieldCount > 0 ||
          !result.safeForPhase34R ||
          result.nextRecommendation !=
              'runDisabledAnalyzerAdapterRuntimeInputEnvelopeDiagnostic')) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
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
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
          .values) {
    if (section.wire == wire) return section;
  }
  return null;
}

String _usage(String failure) {
  return [
    if (failure.isNotEmpty && failure != 'help') 'error: $failure',
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|slots|boundaries|blocked-reasons|denied|proof|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

String _ids(Iterable<String> ids) {
  final values = ids.toSet().toList()..sort();
  return values.isEmpty ? 'none' : values.join(', ');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
