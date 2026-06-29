import 'dart:convert';
import 'dart:io' as io;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';

const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess =
    0;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitUsage = 64;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitBlockedStrict =
    68;
const debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitUnsafePolicy =
    69;

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat {
  markdown('markdown'),
  json('json');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat(
    this.wire,
  );

  final String wire;
}

enum DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection {
  all('all'),
  request('request'),
  response('response'),
  attempt('attempt'),
  policy('policy'),
  blockedSeams('blocked-seams'),
  denied('denied'),
  recommendation('recommendation');

  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection(
    this.wire,
  );

  final String wire;
}

class DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult {
  const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult({
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
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final String stdoutText;
  final String stderrText;
  final DisabledAnalyzerAdapterRuntimeSkeletonResult? result;
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
      format = DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
          .markdown,
      section =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
              .all,
      strict = false,
      safeDemo = true,
      includeWarnings = true,
      showHelp = false;

  final bool isValid;
  final String failure;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
  format;
  final DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
  section;
  final bool strict;
  final bool safeDemo;
  final bool includeWarnings;
  final bool showHelp;
}

void main(List<String> args) {
  final result =
      runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommand(
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult
runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommand({
  required List<String> args,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton skeleton =
      const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton(),
}) {
  final request = _parseArgs(args);
  if (!request.isValid) {
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitUsage,
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
    return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult(
      exitCode:
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess,
      format: request.format,
      section: request.section,
      strict: request.strict,
      safeDemo: request.safeDemo,
      includeWarnings: request.includeWarnings,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = skeleton.evaluate();
  final stdoutText = switch (request.format) {
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
        .markdown =>
      _renderMarkdown(result, request.section),
    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat.json =>
      '${_renderJson(result, request.section)}\n',
  };
  final reportFindings = const DisabledAnalyzerAdapterRuntimeSkeletonValidator()
      .validateReportText(stdoutText);
  return DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult(
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
  DisabledAnalyzerAdapterRuntimeSkeletonResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection.all) {
    return result.renderMarkdown();
  }
  final buffer = StringBuffer()
    ..writeln('# Disabled Analyzer Adapter Runtime Skeleton')
    ..writeln()
    ..writeln('- skeleton status: ${result.status.wire}')
    ..writeln('- selected section: ${section.wire}')
    ..writeln('- safe for Phase 34J: ${result.safeForPhase34J}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln();
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .request:
      buffer
        ..writeln('## Request Envelope Summary')
        ..writeln('- request envelope ID: ${result.request.requestEnvelopeId}')
        ..writeln('- executionAllowed: ${result.request.executionAllowed}')
        ..writeln(
          '- analyzerWiringAllowed: ${result.request.analyzerWiringAllowed}',
        )
        ..writeln('- engineCallsAllowed: ${result.request.engineCallsAllowed}');
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .response:
      buffer
        ..writeln('## Response Envelope Summary')
        ..writeln(
          '- response envelope ID: ${result.response.responseEnvelopeId}',
        )
        ..writeln(
          '- execution refused reason: ${result.response.executionRefusedReason}',
        )
        ..writeln('- executionAllowed: ${result.response.executionAllowed}');
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .attempt:
      buffer
        ..writeln('## Disabled Execution Attempt Summary')
        ..writeln('- attempt ID: ${result.executionAttempt.executionAttemptId}')
        ..writeln(
          '- execution performed: ${result.executionAttempt.executionPerformed}',
        )
        ..writeln(
          '- execution refused: ${result.executionAttempt.executionRefused}',
        );
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .policy:
      _writePolicy(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .blockedSeams:
      buffer
        ..writeln('## Blocked Seam Summary')
        ..writeln('| Seam | Target surface | Blocked |')
        ..writeln('| --- | --- | --- |');
      for (final seam in result.blockedSeams) {
        buffer.writeln(
          '| ${seam.blockedSeamId} | ${seam.targetSurface} | ${seam.blocked} |',
        );
      }
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .denied:
      buffer
        ..writeln('## Denied Field Summary')
        ..writeln('- denied field count: ${result.deniedFieldCount}')
        ..writeln('- denied field IDs: ${_ids(result.policy.deniedFieldIds)}');
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .recommendation:
      _writeRecommendation(buffer, result);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection.all:
      break;
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderJson(
  DisabledAnalyzerAdapterRuntimeSkeletonResult result,
  DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection section,
) {
  if (section ==
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection.all) {
    return result.renderJson();
  }
  final payload = <String, Object?>{
    'version': debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonVersion,
    'status': result.status.wire,
    'section': section.wire,
    'safeForPhase34J': result.safeForPhase34J,
    'nextRecommendation': result.nextRecommendation,
  };
  switch (section) {
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .request:
      payload['request'] = result.request.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .response:
      payload['response'] = result.response.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .attempt:
      payload['executionAttempt'] = result.executionAttempt.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .policy:
      payload['policy'] = result.policy.toJson();
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .blockedSeams:
      payload['blockedSeams'] = result.blockedSeams
          .map((seam) => seam.toJson())
          .toList(growable: false);
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .denied:
      payload['denied'] = <String, Object?>{
        'deniedFieldCount': result.deniedFieldCount,
        'deniedFieldIds': result.policy.deniedFieldIds,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
        .recommendation:
      payload['recommendation'] = <String, Object?>{
        'safeForPhase34J': result.safeForPhase34J,
        'nextRecommendation': result.nextRecommendation,
        'findings': result.findings,
      };
    case DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection.all:
      break;
  }
  return const JsonEncoder.withIndent(' ').convert(payload);
}

void _writePolicy(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeSkeletonResult result,
) {
  buffer
    ..writeln('## Disabled Runtime Policy')
    ..writeln('- executionAllowed: ${result.policy.executionAllowed}')
    ..writeln('- analyzerWiringAllowed: ${result.policy.analyzerWiringAllowed}')
    ..writeln('- engineCallsAllowed: ${result.policy.engineCallsAllowed}')
    ..writeln('- schedulerAllowed: ${result.policy.schedulerAllowed}')
    ..writeln('- persistenceAllowed: ${result.policy.persistenceAllowed}')
    ..writeln('- productOutputAllowed: ${result.policy.productOutputAllowed}')
    ..writeln('- productAdapterAllowed: ${result.policy.productAdapterAllowed}')
    ..writeln('- savedAnalysisAllowed: ${result.policy.savedAnalysisAllowed}');
}

void _writeRecommendation(
  StringBuffer buffer,
  DisabledAnalyzerAdapterRuntimeSkeletonResult result,
) {
  buffer
    ..writeln('## Recommendation')
    ..writeln('- safe for Phase 34J: ${result.safeForPhase34J}')
    ..writeln('- next recommendation: ${result.nextRecommendation}')
    ..writeln('- findings: ${_ids(result.findings)}');
}

int _exitCode(
  DisabledAnalyzerAdapterRuntimeSkeletonResult result,
  _CommandRequest request, {
  required bool hasTextLeak,
}) {
  if (hasTextLeak || result.hasUnsafePolicyViolation) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitUnsafePolicy;
  }
  if (request.strict &&
      (result.blockerCount > 0 ||
          result.criticalCount > 0 ||
          result.unsafeCount > 0 ||
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
          !result.safeForPhase34J ||
          result.nextRecommendation !=
              'runDisabledAnalyzerAdapterRuntimeSkeletonDiagnostic')) {
    return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitBlockedStrict;
  }
  return debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess;
}

_CommandRequest _parseArgs(List<String> args) {
  var format = DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
      .markdown;
  var section =
      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection.all;
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
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
                .markdown,
        section:
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat?
_formatByWire(String wire) {
  for (final format
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportFormat
          .values) {
    if (format.wire == wire) return format;
  }
  return null;
}

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection?
_sectionByWire(String wire) {
  for (final section
      in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportSection
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
    'usage: dart run tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_report.dart [--format=markdown|json] [--strict] [--safe-demo] [--include-warnings] [--section=all|request|response|attempt|policy|blocked-seams|denied|recommendation]',
    'defaults: --format=markdown --safe-demo --include-warnings --section=all',
  ].join('\n');
}

const _formatFlag = '--format=';
const _sectionFlag = '--section=';
const _strictFlag = '--strict';
const _safeDemoFlag = '--safe-demo';
const _includeWarningsFlag = '--include-warnings';
