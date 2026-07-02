import 'dart:async';
import 'dart:convert';

import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/stockfish/stockfish_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';

const localUciHandshakeProbeNextRecommendation =
    'implementControlledFenPositionInputProbe';
const localUciHandshakeProbeBlockedRecommendation =
    'runAndroidLocalUciHandshakeProof';
const localUciHandshakeProbeAndroidFailureRecommendation =
    'fixAndroidLocalUciHandshakePath';

const defaultLocalUciHandshakeProbeTimeout = Duration(milliseconds: 2500);

class LocalUciHandshakeProbeResult {
  const LocalUciHandshakeProbeResult({
    required this.attemptedHandshake,
    required this.engineLaunchAttempted,
    required this.nativeBridgePathUsed,
    required this.processPathUsed,
    required this.uciCommandSent,
    required this.isReadyCommandSent,
    required this.uciOkReceived,
    required this.readyOkReceived,
    required this.timedOut,
    required this.failedToLaunch,
    required this.failureMessage,
    required this.rawOutputLineCount,
    required this.sanitizedOutputPreview,
    required this.unsafeOutputSuppressed,
    required this.handshakeSucceeded,
    required this.safeForPhase35C,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final bool attemptedHandshake;
  final bool engineLaunchAttempted;
  final String? nativeBridgePathUsed;
  final String? processPathUsed;
  final bool uciCommandSent;
  final bool isReadyCommandSent;
  final bool uciOkReceived;
  final bool readyOkReceived;
  final bool timedOut;
  final bool failedToLaunch;
  final String? failureMessage;
  final int rawOutputLineCount;
  final List<String> sanitizedOutputPreview;
  final bool unsafeOutputSuppressed;
  final bool handshakeSucceeded;
  final bool safeForPhase35C;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  String? get blockedReason {
    if (safeForPhase35C) return null;
    if (failureMessage != null && failureMessage!.isNotEmpty) {
      return failureMessage;
    }
    if (blockers.isNotEmpty) return blockers.join(' ');
    return 'Host handshake proof is blocked.';
  }

  List<String> get blockedGuidance {
    if (safeForPhase35C) return const [];
    if (nextRecommendation ==
        localUciHandshakeProbeAndroidFailureRecommendation) {
      return const [
        'Android/device handshake proof failed.',
        'This is not a successful Android UCI proof.',
        'Do not proceed to Phase 35C yet.',
        'Next action is fixing the Android local UCI handshake path.',
      ];
    }
    return const [
      'Host handshake proof is blocked.',
      'This is not a successful UCI proof.',
      'Do not proceed to Phase 35C yet.',
      'Next action is Android/device handshake proof.',
    ];
  }

  Map<String, Object?> toJson() => {
    'attemptedHandshake': attemptedHandshake,
    'engineLaunchAttempted': engineLaunchAttempted,
    'nativeBridgePathUsed': nativeBridgePathUsed,
    'processPathUsed': processPathUsed,
    'uciCommandSent': uciCommandSent,
    'isReadyCommandSent': isReadyCommandSent,
    'uciOkReceived': uciOkReceived,
    'readyOkReceived': readyOkReceived,
    'timedOut': timedOut,
    'failedToLaunch': failedToLaunch,
    'failureMessage': failureMessage,
    'rawOutputLineCount': rawOutputLineCount,
    'sanitizedOutputPreview': sanitizedOutputPreview,
    'unsafeOutputSuppressed': unsafeOutputSuppressed,
    'handshakeSucceeded': handshakeSucceeded,
    'safeForPhase35C': safeForPhase35C,
    'nextRecommendation': nextRecommendation,
    'blockedReason': blockedReason,
    'blockedGuidance': blockedGuidance,
    'blockers': blockers,
    'warnings': warnings,
    'forbiddenCommandsNotSentByProbe': const [
      'ucinewgame',
      'position fen',
      'go depth',
      'go movetime',
      'stop',
      'quit',
    ],
    'forbiddenWorkNotAttempted': const [
      'fenInput',
      'pgnInput',
      'legalMoveGeneration',
      'engineEvaluationOutput',
      'classifierLabels',
      'deepTacticalVerifier',
      'analyzerRuntimeWiring',
      'schedulerExecution',
      'persistenceWrite',
      'productUi',
      'backendApi',
    ],
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Local UCI Handshake Probe')
      ..writeln()
      ..writeln('phase: Phase 35B - Local UCI Handshake Probe')
      ..writeln('attemptedHandshake: $attemptedHandshake')
      ..writeln('engineLaunchAttempted: $engineLaunchAttempted')
      ..writeln('nativeBridgePathUsed: ${nativeBridgePathUsed ?? 'none'}')
      ..writeln('processPathUsed: ${processPathUsed ?? 'none'}')
      ..writeln('uciCommandSent: $uciCommandSent')
      ..writeln('isReadyCommandSent: $isReadyCommandSent')
      ..writeln('uciOkReceived: $uciOkReceived')
      ..writeln('readyOkReceived: $readyOkReceived')
      ..writeln('timedOut: $timedOut')
      ..writeln('failedToLaunch: $failedToLaunch')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('rawOutputLineCount: $rawOutputLineCount')
      ..writeln('unsafeOutputSuppressed: $unsafeOutputSuppressed')
      ..writeln('handshakeSucceeded: $handshakeSucceeded')
      ..writeln('safeForPhase35C: $safeForPhase35C')
      ..writeln('nextRecommendation: $nextRecommendation')
      ..writeln('blockedReason: ${blockedReason ?? 'none'}')
      ..writeln()
      ..writeln('## Sanitized Output Preview');
    _writeList(buffer, sanitizedOutputPreview);
    buffer
      ..writeln()
      ..writeln('## Blockers');
    _writeList(buffer, blockers);
    buffer
      ..writeln()
      ..writeln('## Warnings');
    _writeList(buffer, warnings);
    if (blockedGuidance.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Blocked Guidance');
      _writeList(buffer, blockedGuidance);
    }
    buffer
      ..writeln()
      ..writeln('## Safety Notes')
      ..writeln('- Probe-sent UCI commands: uci, isready only')
      ..writeln('- FEN/PGN input: not attempted')
      ..writeln('- position/go/evaluation commands: not sent')
      ..writeln(
        '- Evaluation, bestmove, score, mate, MultiPV parsing: not used',
      )
      ..writeln('- Analyzer runtime wiring: not changed')
      ..writeln('- Scheduler execution: not attempted')
      ..writeln('- Persistence/cache/database writes: not attempted');
    return buffer.toString();
  }

  static void _writeList(StringBuffer buffer, List<String> values) {
    if (values.isEmpty) {
      buffer.writeln('- none');
      return;
    }
    for (final value in values) {
      buffer.writeln('- $value');
    }
  }
}

class LocalUciHandshakeProbe {
  LocalUciHandshakeProbe({
    ChessEngine Function(Duration startupTimeout)? engineFactory,
  }) : _engineFactory =
           engineFactory ??
           ((startupTimeout) =>
               StockfishEngine(startupTimeout: startupTimeout));

  final ChessEngine Function(Duration startupTimeout) _engineFactory;

  Future<LocalUciHandshakeProbeResult> run({
    Duration timeout = defaultLocalUciHandshakeProbeTimeout,
    String blockedRecommendation = localUciHandshakeProbeBlockedRecommendation,
  }) async {
    final normalizedTimeout = timeout.inMilliseconds > 0
        ? timeout
        : defaultLocalUciHandshakeProbeTimeout;
    final engine = _engineFactory(normalizedTimeout);
    final previewBuilder = _SanitizedProbeOutputBuilder();
    StreamSubscription<EngineEvent>? subscription;

    var engineLaunchAttempted = false;
    var attemptedHandshake = false;
    var uciCommandSent = false;
    var isReadyCommandSent = false;
    var uciOkReceived = false;
    var readyOkReceived = false;
    var timedOut = false;
    var failedToLaunch = false;
    String? failureMessage;
    String? nativeBridgePathUsed;

    final bothOk = Completer<void>();

    try {
      engineLaunchAttempted = true;
      await engine.start().timeout(normalizedTimeout);
      nativeBridgePathUsed = _sanitizeLine(engine.bridgeVersion);

      subscription = engine.events.listen((event) {
        previewBuilder.add(event);
        if (event is EngineUciOk) {
          uciOkReceived = true;
        } else if (event is EngineReadyOk) {
          readyOkReceived = true;
        } else if (event is EngineError && failureMessage == null) {
          failureMessage = _sanitizeLine(event.message);
        }
        if (uciOkReceived && readyOkReceived && !bothOk.isCompleted) {
          bothOk.complete();
        }
      });

      attemptedHandshake = true;
      engine.send(const UciHandshake());
      uciCommandSent = true;
      engine.send(const UciIsReady());
      isReadyCommandSent = true;

      await bothOk.future.timeout(normalizedTimeout);
    } on TimeoutException {
      timedOut = true;
      failureMessage ??=
          'UCI handshake timed out after '
          '${normalizedTimeout.inMilliseconds} ms.';
    } on EngineStartupException catch (e) {
      failedToLaunch = true;
      if (e.message.contains('timed out')) timedOut = true;
      failureMessage = _sanitizeLine(e.toString());
    } on Object catch (e) {
      failureMessage = _sanitizeLine(e.toString());
      if (!attemptedHandshake) failedToLaunch = true;
    } finally {
      await subscription?.cancel();
      if (engine.isRunning) {
        try {
          await engine.dispose().timeout(const Duration(seconds: 3));
        } on Object catch (e) {
          failureMessage ??= 'Engine cleanup failed: ${_sanitizeLine(e)}';
        }
      }
    }

    final handshakeSucceeded =
        attemptedHandshake &&
        uciCommandSent &&
        isReadyCommandSent &&
        uciOkReceived &&
        readyOkReceived &&
        !timedOut &&
        !failedToLaunch;
    final safeForPhase35C =
        handshakeSucceeded && uciOkReceived && readyOkReceived;
    final nextRecommendation = safeForPhase35C
        ? localUciHandshakeProbeNextRecommendation
        : blockedRecommendation;
    final blockers = <String>[];
    if (!safeForPhase35C) {
      blockers.add(
        blockedRecommendation ==
                localUciHandshakeProbeAndroidFailureRecommendation
            ? 'Android/device handshake proof failed.'
            : 'Host handshake proof is blocked.',
      );
    }
    if (failedToLaunch) {
      blockers.add('Engine launch failed before UCI handshake completed.');
    }
    if (timedOut) {
      blockers.add('UCI handshake timed out.');
    }
    if (attemptedHandshake && !uciOkReceived) {
      blockers.add('uciok was not received.');
    }
    if (attemptedHandshake && !readyOkReceived) {
      blockers.add('readyok was not received.');
    }
    if (!attemptedHandshake && !failedToLaunch) {
      blockers.add('UCI handshake was not attempted.');
    }

    final warnings = <String>[];
    if (!safeForPhase35C) {
      if (blockedRecommendation ==
          localUciHandshakeProbeAndroidFailureRecommendation) {
        warnings.add('This is not a successful Android UCI proof.');
        warnings.add('Do not proceed to Phase 35C yet.');
        warnings.add(
          'Next action is fixing the Android local UCI handshake path.',
        );
      } else {
        warnings.add('This is not a successful UCI proof.');
        warnings.add('Do not proceed to Phase 35C yet.');
        warnings.add('Next action is Android/device handshake proof.');
      }
    }
    if (previewBuilder.unsafeOutputSuppressed) {
      warnings.add(
        'Some engine output was suppressed from the preview to keep the report developer-safe.',
      );
    }
    if (nativeBridgePathUsed == null) {
      warnings.add('No native bridge version/path was available.');
    }

    blockers.sort();
    warnings.sort();

    return LocalUciHandshakeProbeResult(
      attemptedHandshake: attemptedHandshake,
      engineLaunchAttempted: engineLaunchAttempted,
      nativeBridgePathUsed: nativeBridgePathUsed,
      processPathUsed: null,
      uciCommandSent: uciCommandSent,
      isReadyCommandSent: isReadyCommandSent,
      uciOkReceived: uciOkReceived,
      readyOkReceived: readyOkReceived,
      timedOut: timedOut,
      failedToLaunch: failedToLaunch,
      failureMessage: failureMessage,
      rawOutputLineCount: previewBuilder.rawOutputLineCount,
      sanitizedOutputPreview: previewBuilder.preview,
      unsafeOutputSuppressed: previewBuilder.unsafeOutputSuppressed,
      handshakeSucceeded: handshakeSucceeded,
      safeForPhase35C: safeForPhase35C,
      nextRecommendation: nextRecommendation,
      blockers: List.unmodifiable(blockers),
      warnings: List.unmodifiable(warnings),
    );
  }
}

class _SanitizedProbeOutputBuilder {
  static const _maxPreviewLines = 12;
  static const _maxLineLength = 120;

  final List<String> _preview = <String>[];
  var rawOutputLineCount = 0;
  var unsafeOutputSuppressed = false;

  List<String> get preview => List.unmodifiable(_preview);

  void add(EngineEvent event) {
    rawOutputLineCount++;
    final line = _safePreviewLine(event);
    if (line == null) {
      unsafeOutputSuppressed = true;
      return;
    }
    if (_preview.length >= _maxPreviewLines) {
      unsafeOutputSuppressed = true;
      return;
    }
    _preview.add(_sanitizeLine(line, maxLength: _maxLineLength));
  }

  String? _safePreviewLine(EngineEvent event) {
    if (event is EngineUciOk) return 'uciok';
    if (event is EngineReadyOk) return 'readyok';
    if (event is EngineId) {
      final name = event.name == null ? null : _sanitizeLine(event.name!);
      final author = event.author == null ? null : _sanitizeLine(event.author!);
      if (name != null) return 'id name $name';
      if (author != null) return 'id author $author';
      return 'id';
    }
    if (event is EngineOption) {
      return 'option name ${_sanitizeLine(event.name)} type '
          '${_sanitizeLine(event.type)}';
    }
    if (event is EngineError) {
      return 'error ${_sanitizeLine(event.message)}';
    }
    if (event is EngineRawLine) {
      return 'raw ${_sanitizeLine(event.line)}';
    }
    return null;
  }
}

String _sanitizeLine(Object value, {int maxLength = 160}) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= maxLength) return safe;
  return '${safe.substring(0, maxLength)}...';
}
