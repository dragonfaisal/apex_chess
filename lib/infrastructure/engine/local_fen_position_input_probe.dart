import 'dart:async';
import 'dart:convert';

import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/stockfish/stockfish_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';

const localFenPositionInputProbeControlledFen =
    'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const localFenPositionInputProbeNextRecommendation =
    'implementLocalSearchEvalProbe';
const localFenPositionInputProbeFailureRecommendation =
    'fixControlledFenPositionInputPath';

const defaultLocalFenPositionInputProbeTimeout = Duration(milliseconds: 5000);

class LocalFenPositionInputProbeResult {
  const LocalFenPositionInputProbeResult({
    required this.attemptedProbe,
    required this.engineLaunchAttempted,
    required this.nativeBridgePathUsed,
    required this.processPathUsed,
    required this.uciCommandSent,
    required this.initialIsReadyCommandSent,
    required this.handshakeSucceeded,
    required this.uciOkReceived,
    required this.initialReadyOkReceived,
    required this.newGameCommandSent,
    required this.fenInputAttempted,
    required this.fenInputAcceptedByProbe,
    required this.positionCommandSent,
    required this.postPositionIsReadySent,
    required this.postPositionReadyOkReceived,
    required this.timedOut,
    required this.failedToLaunch,
    required this.failureMessage,
    required this.rawOutputLineCount,
    required this.sanitizedOutputPreview,
    required this.unsafeOutputSuppressed,
    required this.safeForPhase35D,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final bool attemptedProbe;
  final bool engineLaunchAttempted;
  final String? nativeBridgePathUsed;
  final String? processPathUsed;
  final bool uciCommandSent;
  final bool initialIsReadyCommandSent;
  final bool handshakeSucceeded;
  final bool uciOkReceived;
  final bool initialReadyOkReceived;
  final bool newGameCommandSent;
  final bool fenInputAttempted;
  final bool fenInputAcceptedByProbe;
  final bool positionCommandSent;
  final bool postPositionIsReadySent;
  final bool postPositionReadyOkReceived;
  final bool timedOut;
  final bool failedToLaunch;
  final String? failureMessage;
  final int rawOutputLineCount;
  final List<String> sanitizedOutputPreview;
  final bool unsafeOutputSuppressed;
  final bool safeForPhase35D;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  String? get blockedReason {
    if (safeForPhase35D) return null;
    if (failureMessage != null && failureMessage!.isNotEmpty) {
      return failureMessage;
    }
    if (blockers.isNotEmpty) return blockers.join(' ');
    return 'Controlled FEN position input proof is blocked.';
  }

  List<String> get blockedGuidance {
    if (safeForPhase35D) return const [];
    return const [
      'Controlled FEN position input proof is blocked.',
      'This is not a successful FEN input proof.',
      'Do not proceed to Phase 35D yet.',
      'Next action is fixing the controlled FEN position input path.',
    ];
  }

  Map<String, Object?> toJson() => {
    'attemptedProbe': attemptedProbe,
    'engineLaunchAttempted': engineLaunchAttempted,
    'nativeBridgePathUsed': nativeBridgePathUsed,
    'processPathUsed': processPathUsed,
    'uciCommandSent': uciCommandSent,
    'initialIsReadyCommandSent': initialIsReadyCommandSent,
    'handshakeSucceeded': handshakeSucceeded,
    'uciOkReceived': uciOkReceived,
    'initialReadyOkReceived': initialReadyOkReceived,
    'newGameCommandSent': newGameCommandSent,
    'fenInputAttempted': fenInputAttempted,
    'fenInputAcceptedByProbe': fenInputAcceptedByProbe,
    'positionCommandSent': positionCommandSent,
    'postPositionIsReadySent': postPositionIsReadySent,
    'postPositionReadyOkReceived': postPositionReadyOkReceived,
    'timedOut': timedOut,
    'failedToLaunch': failedToLaunch,
    'failureMessage': failureMessage,
    'rawOutputLineCount': rawOutputLineCount,
    'sanitizedOutputPreview': sanitizedOutputPreview,
    'unsafeOutputSuppressed': unsafeOutputSuppressed,
    'safeForPhase35D': safeForPhase35D,
    'nextRecommendation': nextRecommendation,
    'blockedReason': blockedReason,
    'blockedGuidance': blockedGuidance,
    'blockers': blockers,
    'warnings': warnings,
    'allowedCommandsSentByProbe': const [
      'uci',
      'isready',
      'ucinewgame',
      'controlled FEN position command',
      'isready',
    ],
    'forbiddenCommandsNotSentByProbe': const [
      'go depth',
      'go movetime',
      'stop',
      'ponderhit',
      'setoption for analysis tuning',
    ],
    'forbiddenWorkNotAttempted': const [
      'pgnInput',
      'moveListInput',
      'legalMoveGeneration',
      'engineEvaluationOutput',
      'scoreCpParsing',
      'scoreMateParsing',
      'bestMoveParsing',
      'multiPv',
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
      ..writeln('# Apex Controlled FEN Position Input Probe')
      ..writeln()
      ..writeln('phase: Phase 35C - Controlled FEN Position Input Probe')
      ..writeln('attemptedProbe: $attemptedProbe')
      ..writeln('engineLaunchAttempted: $engineLaunchAttempted')
      ..writeln('nativeBridgePathUsed: ${nativeBridgePathUsed ?? 'none'}')
      ..writeln('processPathUsed: ${processPathUsed ?? 'none'}')
      ..writeln('uciCommandSent: $uciCommandSent')
      ..writeln('initialIsReadyCommandSent: $initialIsReadyCommandSent')
      ..writeln('handshakeSucceeded: $handshakeSucceeded')
      ..writeln('uciOkReceived: $uciOkReceived')
      ..writeln('initialReadyOkReceived: $initialReadyOkReceived')
      ..writeln('newGameCommandSent: $newGameCommandSent')
      ..writeln('fenInputAttempted: $fenInputAttempted')
      ..writeln('fenInputAcceptedByProbe: $fenInputAcceptedByProbe')
      ..writeln('positionCommandSent: $positionCommandSent')
      ..writeln('postPositionIsReadySent: $postPositionIsReadySent')
      ..writeln('postPositionReadyOkReceived: $postPositionReadyOkReceived')
      ..writeln('timedOut: $timedOut')
      ..writeln('failedToLaunch: $failedToLaunch')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('rawOutputLineCount: $rawOutputLineCount')
      ..writeln('unsafeOutputSuppressed: $unsafeOutputSuppressed')
      ..writeln('safeForPhase35D: $safeForPhase35D')
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
      ..writeln(
        '- Probe-sent UCI commands: uci, isready, ucinewgame, '
        'controlled FEN position command, isready',
      )
      ..writeln('- Controlled FEN only: start position')
      ..writeln('- PGN/move-list/user input: not attempted')
      ..writeln('- Search/evaluation commands: not sent')
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

class LocalFenPositionInputProbe {
  LocalFenPositionInputProbe({
    ChessEngine Function(Duration startupTimeout)? engineFactory,
  }) : _engineFactory =
           engineFactory ??
           ((startupTimeout) =>
               StockfishEngine(startupTimeout: startupTimeout));

  final ChessEngine Function(Duration startupTimeout) _engineFactory;

  Future<LocalFenPositionInputProbeResult> run({
    Duration timeout = defaultLocalFenPositionInputProbeTimeout,
    String controlledFen = localFenPositionInputProbeControlledFen,
  }) async {
    final normalizedTimeout = timeout.inMilliseconds > 0
        ? timeout
        : defaultLocalFenPositionInputProbeTimeout;
    final previewBuilder = _SanitizedFenProbeOutputBuilder();
    final engine = _engineFactory(normalizedTimeout);
    StreamSubscription<EngineEvent>? subscription;

    const attemptedProbe = true;
    var engineLaunchAttempted = false;
    var uciCommandSent = false;
    var initialIsReadyCommandSent = false;
    var uciOkReceived = false;
    var initialReadyOkReceived = false;
    var newGameCommandSent = false;
    var fenInputAttempted = false;
    var fenInputAcceptedByProbe = false;
    var positionCommandSent = false;
    var postPositionIsReadySent = false;
    var postPositionReadyOkReceived = false;
    var timedOut = false;
    var failedToLaunch = false;
    String? failureMessage;
    String? nativeBridgePathUsed;

    final fenValidation = validateFenForEngineCommand(controlledFen);
    fenInputAcceptedByProbe = fenValidation.isValid;
    if (!fenValidation.isValid) {
      failureMessage = 'Controlled FEN rejected by probe: $fenValidation.';
    }

    final initialReady = Completer<void>();
    final postPositionReady = Completer<void>();

    try {
      if (!fenValidation.isValid) {
        throw _ControlledFenRejectedException(failureMessage!);
      }

      engineLaunchAttempted = true;
      await engine.start().timeout(normalizedTimeout);
      nativeBridgePathUsed = _sanitizeLine(engine.bridgeVersion);

      subscription = engine.events.listen((event) {
        previewBuilder.add(event);
        if (event is EngineUciOk) {
          uciOkReceived = true;
        } else if (event is EngineReadyOk) {
          if (!initialReadyOkReceived) {
            initialReadyOkReceived = true;
          } else if (positionCommandSent && postPositionIsReadySent) {
            postPositionReadyOkReceived = true;
          }
        } else if (event is EngineError && failureMessage == null) {
          failureMessage = _sanitizeLine(event.message);
        }
        if (uciOkReceived &&
            initialReadyOkReceived &&
            !initialReady.isCompleted) {
          initialReady.complete();
        }
        if (postPositionReadyOkReceived && !postPositionReady.isCompleted) {
          postPositionReady.complete();
        }
      });

      engine.send(const UciHandshake());
      uciCommandSent = true;
      engine.send(const UciIsReady());
      initialIsReadyCommandSent = true;

      await initialReady.future.timeout(
        normalizedTimeout,
        onTimeout: () {
          throw TimeoutException(
            'UCI handshake phase timed out after '
            '${normalizedTimeout.inMilliseconds} ms.',
          );
        },
      );

      engine.send(const UciNewGame());
      newGameCommandSent = true;
      fenInputAttempted = true;
      engine.send(UciPosition.fen(controlledFen));
      positionCommandSent = true;
      engine.send(const UciIsReady());
      postPositionIsReadySent = true;

      await postPositionReady.future.timeout(
        normalizedTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Post-position ready check timed out after '
            '${normalizedTimeout.inMilliseconds} ms.',
          );
        },
      );
    } on TimeoutException catch (e) {
      timedOut = true;
      failureMessage ??= _sanitizeLine(e.message ?? e.toString());
    } on EngineStartupException catch (e) {
      failedToLaunch = true;
      if (e.message.contains('timed out')) timedOut = true;
      failureMessage = _sanitizeLine(e.toString());
    } on _ControlledFenRejectedException catch (e) {
      failureMessage ??= e.message;
    } on Object catch (e) {
      failureMessage ??= _sanitizeLine(e.toString());
      if (!engineLaunchAttempted || !engine.isRunning) failedToLaunch = true;
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
        uciCommandSent &&
        initialIsReadyCommandSent &&
        uciOkReceived &&
        initialReadyOkReceived &&
        !failedToLaunch;
    final safeForPhase35D =
        handshakeSucceeded &&
        fenInputAcceptedByProbe &&
        positionCommandSent &&
        postPositionIsReadySent &&
        postPositionReadyOkReceived &&
        !timedOut &&
        !failedToLaunch;
    final nextRecommendation = safeForPhase35D
        ? localFenPositionInputProbeNextRecommendation
        : localFenPositionInputProbeFailureRecommendation;

    final blockers = <String>[];
    if (!safeForPhase35D) {
      blockers.add('Controlled FEN position input proof is blocked.');
    }
    if (failedToLaunch) {
      blockers.add('Engine launch failed before FEN probe completed.');
    }
    if (timedOut) {
      blockers.add('Controlled FEN position input probe timed out.');
    }
    if (uciCommandSent && !uciOkReceived) {
      blockers.add('uciok was not received.');
    }
    if (initialIsReadyCommandSent && !initialReadyOkReceived) {
      blockers.add('initial readyok was not received.');
    }
    if (fenInputAttempted && !fenInputAcceptedByProbe) {
      blockers.add('Controlled FEN was rejected before engine input.');
    }
    if (fenInputAcceptedByProbe && !positionCommandSent) {
      blockers.add('Controlled FEN position command was not sent.');
    }
    if (postPositionIsReadySent && !postPositionReadyOkReceived) {
      blockers.add('post-position readyok was not received.');
    }

    final warnings = <String>[];
    if (!safeForPhase35D) {
      warnings.add('This is not a successful FEN input proof.');
      warnings.add('Do not proceed to Phase 35D yet.');
      warnings.add(
        'Next action is fixing the controlled FEN position input path.',
      );
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

    return LocalFenPositionInputProbeResult(
      attemptedProbe: attemptedProbe,
      engineLaunchAttempted: engineLaunchAttempted,
      nativeBridgePathUsed: nativeBridgePathUsed,
      processPathUsed: null,
      uciCommandSent: uciCommandSent,
      initialIsReadyCommandSent: initialIsReadyCommandSent,
      handshakeSucceeded: handshakeSucceeded,
      uciOkReceived: uciOkReceived,
      initialReadyOkReceived: initialReadyOkReceived,
      newGameCommandSent: newGameCommandSent,
      fenInputAttempted: fenInputAttempted,
      fenInputAcceptedByProbe: fenInputAcceptedByProbe,
      positionCommandSent: positionCommandSent,
      postPositionIsReadySent: postPositionIsReadySent,
      postPositionReadyOkReceived: postPositionReadyOkReceived,
      timedOut: timedOut,
      failedToLaunch: failedToLaunch,
      failureMessage: failureMessage,
      rawOutputLineCount: previewBuilder.rawOutputLineCount,
      sanitizedOutputPreview: previewBuilder.preview,
      unsafeOutputSuppressed: previewBuilder.unsafeOutputSuppressed,
      safeForPhase35D: safeForPhase35D,
      nextRecommendation: nextRecommendation,
      blockers: List.unmodifiable(blockers),
      warnings: List.unmodifiable(warnings),
    );
  }
}

class _SanitizedFenProbeOutputBuilder {
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

class _ControlledFenRejectedException implements Exception {
  const _ControlledFenRejectedException(this.message);

  final String message;
}

String _sanitizeLine(Object value, {int maxLength = 160}) {
  final raw = value.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9 _.,:;=+\-/()[\]{}]'), '?');
  if (safe.length <= maxLength) return safe;
  return '${safe.substring(0, maxLength)}...';
}
