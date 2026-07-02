import 'dart:io' as io;

import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval_bridge.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

const localRawEngineEvalBridgeExitSuccess = 0;
const localRawEngineEvalBridgeExitUsage = 64;
const localRawEngineEvalBridgeExitBlockedStrict = 68;

enum LocalRawEngineEvalBridgeReportFormat {
  markdown('markdown'),
  json('json');

  const LocalRawEngineEvalBridgeReportFormat(this.wire);

  final String wire;
}

class LocalRawEngineEvalBridgeCommandRequest {
  const LocalRawEngineEvalBridgeCommandRequest.valid({
    required this.format,
    required this.strict,
    required this.depth,
    required this.timeout,
    this.showHelp = false,
  }) : isValid = true,
       failure = '';

  const LocalRawEngineEvalBridgeCommandRequest.invalid(this.failure)
    : isValid = false,
      format = LocalRawEngineEvalBridgeReportFormat.markdown,
      strict = false,
      depth = localRawEngineEvalBridgeDepth,
      timeout = defaultLocalSearchEvalProbeTimeout,
      showHelp = false;

  final bool isValid;
  final String failure;
  final LocalRawEngineEvalBridgeReportFormat format;
  final bool strict;
  final int depth;
  final Duration timeout;
  final bool showHelp;
}

class LocalRawEngineEvalBridgeCommandResult {
  const LocalRawEngineEvalBridgeCommandResult({
    required this.exitCode,
    required this.stdoutText,
    required this.stderrText,
    this.result,
  });

  final int exitCode;
  final String stdoutText;
  final String stderrText;
  final LocalRawEngineEval? result;
}

Future<void> main(List<String> args) async {
  final result = await runLocalRawEngineEvalBridgeCommand(args: args);
  if (result.stdoutText.isNotEmpty) io.stdout.write(result.stdoutText);
  if (result.stderrText.isNotEmpty) io.stderr.write(result.stderrText);
  io.exitCode = result.exitCode;
}

Future<LocalRawEngineEvalBridgeCommandResult>
runLocalRawEngineEvalBridgeCommand({
  required List<String> args,
  LocalRawEngineEvalBridge? bridge,
}) async {
  final request = validateLocalRawEngineEvalBridgeArgs(args);
  if (!request.isValid) {
    return LocalRawEngineEvalBridgeCommandResult(
      exitCode: localRawEngineEvalBridgeExitUsage,
      stdoutText: '',
      stderrText: _usage(request.failure),
    );
  }
  if (request.showHelp) {
    return LocalRawEngineEvalBridgeCommandResult(
      exitCode: localRawEngineEvalBridgeExitSuccess,
      stdoutText: _usage('help'),
      stderrText: '',
    );
  }

  final result = await (bridge ?? LocalRawEngineEvalBridge()).evaluate(
    requestedDepth: request.depth,
    timeout: request.timeout,
  );
  final stdoutText = switch (request.format) {
    LocalRawEngineEvalBridgeReportFormat.markdown => result.renderMarkdown(),
    LocalRawEngineEvalBridgeReportFormat.json => '${result.renderJson()}\n',
  };
  final blocked = request.strict && !result.safeForPhase35F;

  return LocalRawEngineEvalBridgeCommandResult(
    exitCode: blocked
        ? localRawEngineEvalBridgeExitBlockedStrict
        : localRawEngineEvalBridgeExitSuccess,
    stdoutText: stdoutText,
    stderrText: '',
    result: result,
  );
}

LocalRawEngineEvalBridgeCommandRequest validateLocalRawEngineEvalBridgeArgs(
  List<String> args,
) {
  var format = LocalRawEngineEvalBridgeReportFormat.markdown;
  var strict = false;
  var depth = localRawEngineEvalBridgeDepth;
  var timeout = defaultLocalSearchEvalProbeTimeout;
  var formatSeen = false;
  var depthSeen = false;
  var timeoutSeen = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      if (args.length != 1) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'helpCannotBeCombined',
        );
      }
      return LocalRawEngineEvalBridgeCommandRequest.valid(
        format: LocalRawEngineEvalBridgeReportFormat.markdown,
        strict: false,
        depth: depth,
        timeout: timeout,
        showHelp: true,
      );
    }
    if (arg.startsWith(_formatFlag)) {
      if (formatSeen) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'duplicateFormat',
        );
      }
      final parsed = _formatByWire(arg.substring(_formatFlag.length).trim());
      if (parsed == null) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'unknownFormat',
        );
      }
      format = parsed;
      formatSeen = true;
      continue;
    }
    if (arg.startsWith(_depthFlag)) {
      if (depthSeen) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'duplicateDepth',
        );
      }
      final parsed = int.tryParse(arg.substring(_depthFlag.length).trim());
      if (parsed != localRawEngineEvalBridgeDepth) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'unsupportedDepthPhase35ERequiresDepth1',
        );
      }
      depth = parsed!;
      depthSeen = true;
      continue;
    }
    if (arg.startsWith(_timeoutFlag)) {
      if (timeoutSeen) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'duplicateTimeout',
        );
      }
      final parsed = int.tryParse(arg.substring(_timeoutFlag.length).trim());
      if (parsed == null || parsed <= 0 || parsed > 30000) {
        return const LocalRawEngineEvalBridgeCommandRequest.invalid(
          'invalidTimeout',
        );
      }
      timeout = Duration(milliseconds: parsed);
      timeoutSeen = true;
      continue;
    }
    if (arg == _strictFlag) {
      strict = true;
      continue;
    }
    return const LocalRawEngineEvalBridgeCommandRequest.invalid('unknownFlag');
  }

  return LocalRawEngineEvalBridgeCommandRequest.valid(
    format: format,
    strict: strict,
    depth: depth,
    timeout: timeout,
  );
}

LocalRawEngineEvalBridgeReportFormat? _formatByWire(String value) {
  for (final format in LocalRawEngineEvalBridgeReportFormat.values) {
    if (format.wire == value) return format;
  }
  return null;
}

String _usage(String failure) {
  final buffer = StringBuffer()
    ..writeln('Apex local raw engine eval bridge usage: $failure')
    ..writeln()
    ..writeln('Usage:')
    ..writeln('  dart run tool/local_raw_engine_eval_bridge_report.dart')
    ..writeln(
      '  dart run tool/local_raw_engine_eval_bridge_report.dart --format=markdown --strict',
    )
    ..writeln(
      '  dart run tool/local_raw_engine_eval_bridge_report.dart --format=json --strict',
    )
    ..writeln(
      '  dart run tool/local_raw_engine_eval_bridge_report.dart --depth=1',
    )
    ..writeln(
      '  dart run tool/local_raw_engine_eval_bridge_report.dart --timeout-ms=5000',
    )
    ..writeln()
    ..writeln('Supported formats:')
    ..writeln('  markdown, json')
    ..writeln('Options:')
    ..writeln('  --strict')
    ..writeln('  --depth=1')
    ..writeln('  --timeout-ms=<1..30000>')
    ..writeln()
    ..writeln('Safety:')
    ..writeln('  Phase 35E uses only the controlled start-position FEN and')
    ..writeln('  depth 1. It returns raw engine evidence only: no Win%,')
    ..writeln('  CP-loss, perspective normalization, classifier labels, saved')
    ..writeln('  analysis, scheduler execution, product UI, or backend work.');
  return buffer.toString();
}

const _formatFlag = '--format=';
const _depthFlag = '--depth=';
const _timeoutFlag = '--timeout-ms=';
const _strictFlag = '--strict';
