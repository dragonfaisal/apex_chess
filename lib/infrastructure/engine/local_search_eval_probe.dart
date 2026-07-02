import 'dart:async';
import 'dart:convert';

import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/stockfish/stockfish_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/infrastructure/engine/local_fen_position_input_probe.dart'
    show localFenPositionInputProbeControlledFen;

const localSearchEvalProbeControlledFen =
    localFenPositionInputProbeControlledFen;
const localSearchEvalProbeDepthLimit = 1;
const localSearchEvalProbeSearchCommand = 'go depth 1';
const localSearchEvalProbeNextRecommendation =
    'implementAnalyzerAdapterRawEvalBridge';
const localSearchEvalProbeFailureRecommendation = 'fixLocalSearchEvalProbe';

const defaultLocalSearchEvalProbeTimeout = Duration(milliseconds: 5000);

class LocalSearchEvalProbeResult {
  const LocalSearchEvalProbeResult({
    required this.attemptedProbe,
    required this.engineLaunchAttempted,
    required this.nativeBridgePathUsed,
    required this.processPathUsed,
    required this.handshakeSucceeded,
    required this.uciOkReceived,
    required this.initialReadyOkReceived,
    required this.fenInputSucceeded,
    required this.fenInputAttempted,
    required this.fenInputAcceptedByProbe,
    required this.positionCommandSent,
    required this.postPositionReadyOkReceived,
    required this.searchCommandSent,
    required this.searchCommand,
    required this.depthLimit,
    required this.bestMoveReceived,
    required this.bestMove,
    required this.rawScoreSeen,
    required this.scoreType,
    required this.scoreValue,
    required this.mateValue,
    required this.infoDepthSeen,
    required this.timedOut,
    required this.failedToLaunch,
    required this.failureMessage,
    required this.rawOutputLineCount,
    required this.sanitizedOutputPreview,
    required this.unsafeOutputSuppressed,
    required this.safeForPhase35E,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final bool attemptedProbe;
  final bool engineLaunchAttempted;
  final String? nativeBridgePathUsed;
  final String? processPathUsed;
  final bool handshakeSucceeded;
  final bool uciOkReceived;
  final bool initialReadyOkReceived;
  final bool fenInputSucceeded;
  final bool fenInputAttempted;
  final bool fenInputAcceptedByProbe;
  final bool positionCommandSent;
  final bool postPositionReadyOkReceived;
  final bool searchCommandSent;
  final String searchCommand;
  final int depthLimit;
  final bool bestMoveReceived;
  final String? bestMove;
  final bool rawScoreSeen;
  final String? scoreType;
  final int? scoreValue;
  final int? mateValue;
  final int? infoDepthSeen;
  final bool timedOut;
  final bool failedToLaunch;
  final String? failureMessage;
  final int rawOutputLineCount;
  final List<String> sanitizedOutputPreview;
  final bool unsafeOutputSuppressed;
  final bool safeForPhase35E;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  String? get blockedReason {
    if (safeForPhase35E) return null;
    if (failureMessage != null && failureMessage!.isNotEmpty) {
      return failureMessage;
    }
    if (blockers.isNotEmpty) return blockers.join(' ');
    return 'Local search eval proof is blocked.';
  }

  List<String> get blockedGuidance {
    if (safeForPhase35E) return const [];
    return const [
      'Local search eval proof is blocked.',
      'This is not a successful local search/eval proof.',
      'Do not proceed to Phase 35E yet.',
      'Next action is fixing the local search eval probe.',
    ];
  }

  Map<String, Object?> toJson() => {
    'attemptedProbe': attemptedProbe,
    'engineLaunchAttempted': engineLaunchAttempted,
    'nativeBridgePathUsed': nativeBridgePathUsed,
    'processPathUsed': processPathUsed,
    'handshakeSucceeded': handshakeSucceeded,
    'uciOkReceived': uciOkReceived,
    'initialReadyOkReceived': initialReadyOkReceived,
    'fenInputSucceeded': fenInputSucceeded,
    'fenInputAttempted': fenInputAttempted,
    'fenInputAcceptedByProbe': fenInputAcceptedByProbe,
    'positionCommandSent': positionCommandSent,
    'postPositionReadyOkReceived': postPositionReadyOkReceived,
    'searchCommandSent': searchCommandSent,
    'searchCommand': searchCommand,
    'depthLimit': depthLimit,
    'bestMoveReceived': bestMoveReceived,
    'bestMove': bestMove,
    'rawScoreSeen': rawScoreSeen,
    'scoreType': scoreType,
    'scoreValue': scoreValue,
    'mateValue': mateValue,
    'infoDepthSeen': infoDepthSeen,
    'timedOut': timedOut,
    'failedToLaunch': failedToLaunch,
    'failureMessage': failureMessage,
    'rawOutputLineCount': rawOutputLineCount,
    'sanitizedOutputPreview': sanitizedOutputPreview,
    'unsafeOutputSuppressed': unsafeOutputSuppressed,
    'safeForPhase35E': safeForPhase35E,
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
      localSearchEvalProbeSearchCommand,
    ],
    'forbiddenCommandsNotSentByProbe': const [
      'go depth > 1',
      'go movetime',
      'MultiPV',
      'setoption for analysis tuning',
      'stop',
      'ponderhit',
    ],
    'forbiddenWorkNotAttempted': const [
      'pgnInput',
      'importedGames',
      'moveListInput',
      'userGameAnalysis',
      'classifierLabels',
      'winPercent',
      'cpLoss',
      'accuracy',
      'deepTacticalVerifier',
      'analyzerRuntimeWiring',
      'schedulerExecution',
      'persistenceWrite',
      'savedAnalysisIntegration',
      'productUi',
      'backendApi',
    ],
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Local Search Eval Probe')
      ..writeln()
      ..writeln('phase: Phase 35D - Local Search Eval Probe')
      ..writeln('attemptedProbe: $attemptedProbe')
      ..writeln('engineLaunchAttempted: $engineLaunchAttempted')
      ..writeln('nativeBridgePathUsed: ${nativeBridgePathUsed ?? 'none'}')
      ..writeln('processPathUsed: ${processPathUsed ?? 'none'}')
      ..writeln('handshakeSucceeded: $handshakeSucceeded')
      ..writeln('uciOkReceived: $uciOkReceived')
      ..writeln('initialReadyOkReceived: $initialReadyOkReceived')
      ..writeln('fenInputSucceeded: $fenInputSucceeded')
      ..writeln('fenInputAttempted: $fenInputAttempted')
      ..writeln('fenInputAcceptedByProbe: $fenInputAcceptedByProbe')
      ..writeln('positionCommandSent: $positionCommandSent')
      ..writeln('postPositionReadyOkReceived: $postPositionReadyOkReceived')
      ..writeln('searchCommandSent: $searchCommandSent')
      ..writeln('searchCommand: $searchCommand')
      ..writeln('depthLimit: $depthLimit')
      ..writeln('bestMoveReceived: $bestMoveReceived')
      ..writeln('bestMove: ${bestMove ?? 'none'}')
      ..writeln('rawScoreSeen: $rawScoreSeen')
      ..writeln('scoreType: ${scoreType ?? 'none'}')
      ..writeln('scoreValue: ${scoreValue ?? 'none'}')
      ..writeln('mateValue: ${mateValue ?? 'none'}')
      ..writeln('infoDepthSeen: ${infoDepthSeen ?? 'none'}')
      ..writeln('timedOut: $timedOut')
      ..writeln('failedToLaunch: $failedToLaunch')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('rawOutputLineCount: $rawOutputLineCount')
      ..writeln('unsafeOutputSuppressed: $unsafeOutputSuppressed')
      ..writeln('safeForPhase35E: $safeForPhase35E')
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
        'controlled FEN position command, isready, go depth 1',
      )
      ..writeln('- Controlled FEN only: start position')
      ..writeln('- PGN/imported games/user input: not attempted')
      ..writeln('- MultiPV and search tuning: not sent')
      ..writeln('- Win%, CP-loss, accuracy, and classifier labels: not used')
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

class LocalSearchEvalProbe {
  LocalSearchEvalProbe({
    ChessEngine Function(Duration startupTimeout)? engineFactory,
  }) : _engineFactory =
           engineFactory ??
           ((startupTimeout) =>
               StockfishEngine(startupTimeout: startupTimeout));

  final ChessEngine Function(Duration startupTimeout) _engineFactory;

  Future<LocalSearchEvalProbeResult> run({
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
    String controlledFen = localSearchEvalProbeControlledFen,
  }) async {
    final normalizedTimeout = timeout.inMilliseconds > 0
        ? timeout
        : defaultLocalSearchEvalProbeTimeout;
    final previewBuilder = _SanitizedSearchProbeOutputBuilder();
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
    var searchCommandSent = false;
    var bestMoveReceived = false;
    String? bestMove;
    var rawScoreSeen = false;
    String? scoreType;
    int? scoreValue;
    int? mateValue;
    int? infoDepthSeen;
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
    final bestMoveCompleter = Completer<void>();

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
        } else if (event is EngineInfo && searchCommandSent) {
          final depth = event.depth;
          if (depth != null &&
              (infoDepthSeen == null || depth > infoDepthSeen!)) {
            infoDepthSeen = depth;
          }
          if (!rawScoreSeen && event.scoreCp != null) {
            rawScoreSeen = true;
            scoreType = 'cp';
            scoreValue = event.scoreCp;
          } else if (!rawScoreSeen && event.scoreMate != null) {
            rawScoreSeen = true;
            scoreType = 'mate';
            mateValue = event.scoreMate;
          }
        } else if (event is EngineBestMove && searchCommandSent) {
          bestMoveReceived = true;
          bestMove = _sanitizeLine(event.move, maxLength: 16);
          if (!bestMoveCompleter.isCompleted) bestMoveCompleter.complete();
        } else if (event is EngineError && failureMessage == null) {
          failureMessage = _sanitizeLine(event.message);
          if (!bestMoveCompleter.isCompleted) {
            bestMoveCompleter.completeError(event.message);
          }
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

      engine.send(const UciGo.depth(localSearchEvalProbeDepthLimit));
      searchCommandSent = true;

      await bestMoveCompleter.future.timeout(
        normalizedTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Depth-1 local search timed out after '
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
    final fenInputSucceeded =
        handshakeSucceeded &&
        fenInputAcceptedByProbe &&
        positionCommandSent &&
        postPositionIsReadySent &&
        postPositionReadyOkReceived &&
        !failedToLaunch;
    final safeForPhase35E =
        handshakeSucceeded &&
        fenInputSucceeded &&
        searchCommandSent &&
        bestMoveReceived &&
        !timedOut &&
        !failedToLaunch;
    final nextRecommendation = safeForPhase35E
        ? localSearchEvalProbeNextRecommendation
        : localSearchEvalProbeFailureRecommendation;

    final blockers = <String>[];
    if (!safeForPhase35E) {
      blockers.add('Local search eval proof is blocked.');
    }
    if (failedToLaunch) {
      blockers.add('Engine launch failed before local search completed.');
    }
    if (timedOut) {
      blockers.add('Local search eval probe timed out.');
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
    if (fenInputSucceeded && !searchCommandSent) {
      blockers.add('Depth-1 search command was not sent.');
    }
    if (searchCommandSent && !bestMoveReceived) {
      blockers.add('bestmove was not received.');
    }

    final warnings = <String>[];
    if (!safeForPhase35E) {
      warnings.add('This is not a successful local search/eval proof.');
      warnings.add('Do not proceed to Phase 35E yet.');
      warnings.add('Next action is fixing the local search eval probe.');
    }
    if (safeForPhase35E && !rawScoreSeen) {
      warnings.add(
        'bestmove was received but no raw score evidence was seen at depth 1.',
      );
    }
    if (newGameCommandSent && !postPositionReadyOkReceived) {
      warnings.add('ucinewgame was sent but the post-position sync failed.');
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

    return LocalSearchEvalProbeResult(
      attemptedProbe: attemptedProbe,
      engineLaunchAttempted: engineLaunchAttempted,
      nativeBridgePathUsed: nativeBridgePathUsed,
      processPathUsed: null,
      handshakeSucceeded: handshakeSucceeded,
      uciOkReceived: uciOkReceived,
      initialReadyOkReceived: initialReadyOkReceived,
      fenInputSucceeded: fenInputSucceeded,
      fenInputAttempted: fenInputAttempted,
      fenInputAcceptedByProbe: fenInputAcceptedByProbe,
      positionCommandSent: positionCommandSent,
      postPositionReadyOkReceived: postPositionReadyOkReceived,
      searchCommandSent: searchCommandSent,
      searchCommand: localSearchEvalProbeSearchCommand,
      depthLimit: localSearchEvalProbeDepthLimit,
      bestMoveReceived: bestMoveReceived,
      bestMove: bestMove,
      rawScoreSeen: rawScoreSeen,
      scoreType: scoreType,
      scoreValue: scoreValue,
      mateValue: mateValue,
      infoDepthSeen: infoDepthSeen,
      timedOut: timedOut,
      failedToLaunch: failedToLaunch,
      failureMessage: failureMessage,
      rawOutputLineCount: previewBuilder.rawOutputLineCount,
      sanitizedOutputPreview: previewBuilder.preview,
      unsafeOutputSuppressed: previewBuilder.unsafeOutputSuppressed,
      safeForPhase35E: safeForPhase35E,
      nextRecommendation: nextRecommendation,
      blockers: List.unmodifiable(blockers),
      warnings: List.unmodifiable(warnings),
    );
  }
}

class _SanitizedSearchProbeOutputBuilder {
  static const _maxPreviewLines = 20;
  static const _maxOptionPreviewLines = 6;
  static const _maxLineLength = 120;

  final List<String> _preview = <String>[];
  var rawOutputLineCount = 0;
  var unsafeOutputSuppressed = false;
  var _optionPreviewLines = 0;

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
    if (event is EngineBestMove) {
      return 'bestmove ${_sanitizeLine(event.move, maxLength: 16)}';
    }
    if (event is EngineInfo) {
      final depth = event.depth == null ? 'none' : event.depth.toString();
      if (event.scoreCp != null) {
        return 'info depth $depth score cp ${event.scoreCp}';
      }
      if (event.scoreMate != null) {
        return 'info depth $depth score mate ${event.scoreMate}';
      }
      return 'info depth $depth score none';
    }
    if (event is EngineId) {
      final name = event.name == null ? null : _sanitizeLine(event.name!);
      final author = event.author == null ? null : _sanitizeLine(event.author!);
      if (name != null) return 'id name $name';
      if (author != null) return 'id author $author';
      return 'id';
    }
    if (event is EngineOption) {
      if (_optionPreviewLines >= _maxOptionPreviewLines) return null;
      _optionPreviewLines++;
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
