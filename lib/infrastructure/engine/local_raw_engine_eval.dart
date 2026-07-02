import 'dart:convert';

const localRawEngineEvalEngineSource = 'localStockfishUci';
const localRawEngineEvalBridgeSource = 'localSearchEvalProbe';
const localRawEngineEvalNextRecommendation =
    'implementRawEvalPerspectiveNormalizationProbe';
const localRawEngineEvalFailureRecommendation =
    'fixAnalyzerAdapterRawEvalBridge';

class LocalRawEngineEval {
  const LocalRawEngineEval({
    required this.requestedFen,
    required this.requestedDepth,
    required this.engineSource,
    required this.bridgeSource,
    required this.handshakeSucceeded,
    required this.fenInputSucceeded,
    required this.searchSucceeded,
    required this.bestMove,
    required this.bestMoveReceived,
    required this.infoDepthSeen,
    required this.rawScoreSeen,
    required this.scoreType,
    required this.scoreCp,
    required this.scoreMate,
    required this.rawScoreValue,
    required this.timedOut,
    required this.failedToLaunch,
    required this.failureMessage,
    required this.sanitizedOutputPreview,
    required this.rawOutputLineCount,
    required this.safeForAnalyzerAdapterPhase,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String requestedFen;
  final int requestedDepth;
  final String engineSource;
  final String bridgeSource;
  final bool handshakeSucceeded;
  final bool fenInputSucceeded;
  final bool searchSucceeded;
  final String? bestMove;
  final bool bestMoveReceived;
  final int? infoDepthSeen;
  final bool rawScoreSeen;
  final String? scoreType;
  final int? scoreCp;
  final int? scoreMate;
  final int? rawScoreValue;
  final bool timedOut;
  final bool failedToLaunch;
  final String? failureMessage;
  final List<String> sanitizedOutputPreview;
  final int rawOutputLineCount;
  final bool safeForAnalyzerAdapterPhase;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  bool get safeForPhase35F => safeForAnalyzerAdapterPhase;

  String? get blockedReason {
    if (safeForPhase35F) return null;
    if (failureMessage != null && failureMessage!.isNotEmpty) {
      return failureMessage;
    }
    if (blockers.isNotEmpty) return blockers.join(' ');
    return 'Analyzer adapter raw eval bridge is blocked.';
  }

  Map<String, Object?> toJson() => {
    'requestedFen': requestedFen,
    'requestedDepth': requestedDepth,
    'engineSource': engineSource,
    'bridgeSource': bridgeSource,
    'handshakeSucceeded': handshakeSucceeded,
    'fenInputSucceeded': fenInputSucceeded,
    'searchSucceeded': searchSucceeded,
    'bestMove': bestMove,
    'bestMoveReceived': bestMoveReceived,
    'infoDepthSeen': infoDepthSeen,
    'rawScoreSeen': rawScoreSeen,
    'scoreType': scoreType,
    'scoreCp': scoreCp,
    'scoreMate': scoreMate,
    'rawScoreValue': rawScoreValue,
    'timedOut': timedOut,
    'failedToLaunch': failedToLaunch,
    'failureMessage': failureMessage,
    'sanitizedOutputPreview': sanitizedOutputPreview,
    'rawOutputLineCount': rawOutputLineCount,
    'safeForAnalyzerAdapterPhase': safeForAnalyzerAdapterPhase,
    'safeForPhase35F': safeForPhase35F,
    'nextRecommendation': nextRecommendation,
    'blockedReason': blockedReason,
    'blockers': blockers,
    'warnings': warnings,
    'rawEvidenceOnly': true,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Local Raw Engine Eval Bridge')
      ..writeln()
      ..writeln('phase: Phase 35E - Analyzer Adapter Raw Eval Bridge')
      ..writeln('requestedFen: $requestedFen')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('engineSource: $engineSource')
      ..writeln('bridgeSource: $bridgeSource')
      ..writeln('handshakeSucceeded: $handshakeSucceeded')
      ..writeln('fenInputSucceeded: $fenInputSucceeded')
      ..writeln('searchSucceeded: $searchSucceeded')
      ..writeln('bestMoveReceived: $bestMoveReceived')
      ..writeln('bestMove: ${bestMove ?? 'none'}')
      ..writeln('infoDepthSeen: ${infoDepthSeen ?? 'none'}')
      ..writeln('rawScoreSeen: $rawScoreSeen')
      ..writeln('scoreType: ${scoreType ?? 'none'}')
      ..writeln('scoreCp: ${scoreCp ?? 'none'}')
      ..writeln('scoreMate: ${scoreMate ?? 'none'}')
      ..writeln('rawScoreValue: ${rawScoreValue ?? 'none'}')
      ..writeln('timedOut: $timedOut')
      ..writeln('failedToLaunch: $failedToLaunch')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('rawOutputLineCount: $rawOutputLineCount')
      ..writeln('safeForAnalyzerAdapterPhase: $safeForAnalyzerAdapterPhase')
      ..writeln('safeForPhase35F: $safeForPhase35F')
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
    buffer
      ..writeln()
      ..writeln('## Safety Notes')
      ..writeln('- Raw engine evidence only')
      ..writeln('- No perspective normalization')
      ..writeln('- No classifier labels or move quality')
      ..writeln('- No Win%, CP-loss, accuracy, or ACPL')
      ..writeln('- No analyzer runtime wiring')
      ..writeln('- No scheduler execution')
      ..writeln('- No persistence/cache/database writes')
      ..writeln('- No product UI exposure');
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
