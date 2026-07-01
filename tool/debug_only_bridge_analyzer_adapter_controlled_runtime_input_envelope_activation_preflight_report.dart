import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight.dart';

const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitUsage =
    64;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection {
  all('all'),
  checks('checks'),
  decision('decision'),
  blockedReasons('blocked-reasons'),
  denied('denied'),
  proof('proof'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult?
  result;
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
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
              .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight
      preflight =
      const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflight(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitSuccess,
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
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
        .json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings =
      const ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightValidator()
          .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportCommandResult(
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
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
          .all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln(
      '# Controlled Analyzer Adapter Runtime Input Envelope Activation Preflight',
    )
    ..writeln()
    ..writeln('- preflight status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34T: ${result.safeForPhase34T}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .checks:
      _writeChecks(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .decision:
      _writeDecision(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .blockedReasons:
      _writeBlockedReasons(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .denied:
      _writeDenied(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .proof:
      _writeProof(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .recommendation:
      _writeRecommendation(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .all:
      break;
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderJson(
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
  DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
  section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
          .all) {
    return result.renderJson();
  }
  final payload = <String, Object?>{
    'version':
        debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightVersion,
    'status': result.status.wire,
    'section': section.wire,
    'safeForPhase34T': result.safeForPhase34T,
    'nextRecommendation': result.nextRecommendation,
  };
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .checks:
      payload['checks'] = result.checks
          .map((check) => check.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .decision:
      payload['decision'] = result.decision.toJson();
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .blockedReasons:
      payload['blockedReasons'] = result.blockedReasons
          .map((reason) => reason.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .denied:
      payload['denied'] = <String, Object?>{
        'deniedFieldCount': result.deniedFieldCount,
        'deniedFieldIds': result.policy.deniedFieldIds,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .proof:
      payload['proof'] = <String, Object?>{
        'androidProofIds': result.input.androidProofIds,
        'ownerProofRequired': result.input.ownerProofRequired,
        'ownerProofQueueCount': result.ownerProofQueueCount,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .recommendation:
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34T': result.safeForPhase34T,
        'nextRecommendation': result.nextRecommendation,
        'findings': result.findings,
      };
    case DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
        .all:
      break;
  }
  return const JsonEncoder.withIndent(' ').convert(payload);
}

void _writeChecks(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
) {
  buffer
    ..writeln('## Activation Preflight Check Summary')
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
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
) {
  buffer
    ..writeln('## Activation Decision Summary')
    ..writeln('- decision ID: ${result.decision.decisionId}')
    ..writeln('- envelopeDisabled: ${result.decision.envelopeDisabled}')
    ..writeln('- activationApproved: ${result.decision.activationApproved}')
    ..writeln('- activationPerformed: ${result.decision.activationPerformed}')
    ..writeln(
      '- activeRuntimeInputEnvelope: ${result.decision.activeRuntimeInputEnvelope}',
    )
    ..writeln('- playablePayloadCount: ${result.decision.playablePayloadCount}')
    ..writeln(
      '- analyzerRuntimeInputApproved: ${result.decision.analyzerRuntimeInputApproved}',
    )
    ..writeln(
      '- analyzerRuntimeInputProduced: ${result.decision.analyzerRuntimeInputProduced}',
    )
    ..writeln(
      '- runtimeExecutionApproved: ${result.decision.runtimeExecutionApproved}',
    )
    ..writeln('- executionPerformed: ${result.decision.executionPerformed}')
    ..writeln('- executionAllowed: ${result.decision.executionAllowed}')
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
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
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
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
) {
  buffer
    ..writeln('## Denied Field Summary')
    ..writeln('- denied field count: ${result.deniedFieldCount}')
    ..writeln('- active denied field count: ${result.activeDeniedFieldCount}')
    ..writeln('- denied field IDs: ${_ids(result.policy.deniedFieldIds)}');
}

void _writeProof(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
) {
  buffer
    ..writeln('## Proof Boundary Summary')
    ..writeln('- android proof IDs: ${_ids(result.input.androidProofIds)}')
    ..writeln('- owner proof required: ${result.input.ownerProofRequired}')
    ..writeln('- owner proof queue count: ${result.ownerProofQueueCount}');
}

void _writeRecommendation(
  StringBuffer buffer,
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 34T: ${result.safeForPhase34T}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- findings: ${_ids(result.findings)}');
}

int _exitCode(
  ControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
          result.disabledEnvelopeCount < 1 ||
          result.activationPreflightCount < 1 ||
          result.activationApprovedCount > 0 ||
          result.activationPerformedCount > 0 ||
          result.activeRuntimeInputEnvelopeCount > 0 ||
          result.playablePayloadCount > 0 ||
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
          result.activeDeniedFieldCount > 0 ||
          !result.safeForPhase34T ||
          result.nextRecommendation !=
              'runControlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnostic')) {
    return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
          .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
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
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightReportSection
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

String _usage(String reason) {
  return 'usage: dart run tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|checks|decision|blocked-reasons|denied|proof|recommendation]\nreason: $reason\n';
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
