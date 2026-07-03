import 'dart:convert';

const localRawEvalPerspectiveScorePerspective = 'sideToMove';
const localRawEvalPerspectiveNextRecommendation =
    'implementAnalyzerAdapterSingleFenRawEvalContract';
const localRawEvalPerspectiveFailureRecommendation =
    'fixRawEvalPerspectiveNormalization';

enum LocalRawEvalSideToMove {
  white('white', 'w'),
  black('black', 'b');

  const LocalRawEvalSideToMove(this.wire, this.fenToken);

  final String wire;
  final String fenToken;
}

class LocalRawEvalPerspective {
  const LocalRawEvalPerspective({
    required this.requestedFen,
    required this.requestedDepth,
    required this.sideToMove,
    required this.rawScoreType,
    required this.rawScoreCp,
    required this.rawScoreMate,
    required this.rawScorePerspective,
    required this.whitePerspectiveCp,
    required this.blackPerspectiveCp,
    required this.whitePerspectiveMate,
    required this.blackPerspectiveMate,
    required this.playerPerspectiveCpWhite,
    required this.playerPerspectiveCpBlack,
    required this.playerPerspectiveMateWhite,
    required this.playerPerspectiveMateBlack,
    required this.normalizationSucceeded,
    required this.failureMessage,
    required this.safeForPhase35G,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String requestedFen;
  final int requestedDepth;
  final LocalRawEvalSideToMove? sideToMove;
  final String? rawScoreType;
  final int? rawScoreCp;
  final int? rawScoreMate;
  final String rawScorePerspective;
  final int? whitePerspectiveCp;
  final int? blackPerspectiveCp;
  final int? whitePerspectiveMate;
  final int? blackPerspectiveMate;
  final int? playerPerspectiveCpWhite;
  final int? playerPerspectiveCpBlack;
  final int? playerPerspectiveMateWhite;
  final int? playerPerspectiveMateBlack;
  final bool normalizationSucceeded;
  final String? failureMessage;
  final bool safeForPhase35G;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'requestedFen': requestedFen,
    'requestedDepth': requestedDepth,
    'sideToMove': sideToMove?.wire,
    'rawScoreType': rawScoreType,
    'rawScoreCp': rawScoreCp,
    'rawScoreMate': rawScoreMate,
    'rawScorePerspective': rawScorePerspective,
    'whitePerspectiveCp': whitePerspectiveCp,
    'blackPerspectiveCp': blackPerspectiveCp,
    'whitePerspectiveMate': whitePerspectiveMate,
    'blackPerspectiveMate': blackPerspectiveMate,
    'playerPerspectiveCpWhite': playerPerspectiveCpWhite,
    'playerPerspectiveCpBlack': playerPerspectiveCpBlack,
    'playerPerspectiveMateWhite': playerPerspectiveMateWhite,
    'playerPerspectiveMateBlack': playerPerspectiveMateBlack,
    'normalizationSucceeded': normalizationSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase35G': safeForPhase35G,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
    'rawPerspectiveEvidenceOnly': true,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Raw Eval Perspective Normalization Probe')
      ..writeln()
      ..writeln('phase: Phase 35F - Raw Eval Perspective Normalization Probe')
      ..writeln('requestedFen: $requestedFen')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('sideToMove: ${sideToMove?.wire ?? 'none'}')
      ..writeln('rawScoreType: ${rawScoreType ?? 'none'}')
      ..writeln('rawScoreCp: ${rawScoreCp ?? 'none'}')
      ..writeln('rawScoreMate: ${rawScoreMate ?? 'none'}')
      ..writeln('rawScorePerspective: $rawScorePerspective')
      ..writeln('whitePerspectiveCp: ${whitePerspectiveCp ?? 'none'}')
      ..writeln('blackPerspectiveCp: ${blackPerspectiveCp ?? 'none'}')
      ..writeln(
        'playerPerspectiveCpWhite: ${playerPerspectiveCpWhite ?? 'none'}',
      )
      ..writeln(
        'playerPerspectiveCpBlack: ${playerPerspectiveCpBlack ?? 'none'}',
      )
      ..writeln('whitePerspectiveMate: ${whitePerspectiveMate ?? 'none'}')
      ..writeln('blackPerspectiveMate: ${blackPerspectiveMate ?? 'none'}')
      ..writeln(
        'playerPerspectiveMateWhite: '
        '${playerPerspectiveMateWhite ?? 'none'}',
      )
      ..writeln(
        'playerPerspectiveMateBlack: '
        '${playerPerspectiveMateBlack ?? 'none'}',
      )
      ..writeln('normalizationSucceeded: $normalizationSucceeded')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35G: $safeForPhase35G')
      ..writeln('nextRecommendation: $nextRecommendation')
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
      ..writeln('- Raw UCI score perspective is side-to-move')
      ..writeln('- White and Black perspective fields are explicit')
      ..writeln('- Mate is not converted to centipawns')
      ..writeln('- No Win%, CP-loss, accuracy, or ACPL')
      ..writeln('- No classifier labels or move quality')
      ..writeln('- No analyzer runtime, scheduler, persistence, or UI wiring');
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
