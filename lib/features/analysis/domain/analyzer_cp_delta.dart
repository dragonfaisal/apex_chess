import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';

const analyzerCpDeltaControlledBeforeFen =
    analyzerBeforeAfterRawEvalControlledBeforeFen;
const analyzerCpDeltaControlledAfterFen =
    analyzerBeforeAfterRawEvalControlledAfterFen;
const analyzerCpDeltaPlayedMoveUci = analyzerBeforeAfterRawEvalPlayedMoveUci;
const analyzerCpDeltaDepth = analyzerBeforeAfterRawEvalDepth;
const analyzerCpDeltaDefaultSource = 'phase35IControlledCpDelta';
const analyzerCpDeltaNextRecommendation =
    'implementCpLossCandidateProbeWithoutClassifier';
const analyzerCpDeltaFailureRecommendation = 'fixAnalyzerCpDeltaProbe';

enum AnalyzerCpDeltaDirection {
  improved('improved'),
  worsened('worsened'),
  unchanged('unchanged'),
  unavailable('unavailable');

  const AnalyzerCpDeltaDirection(this.wire);

  final String wire;
}

class AnalyzerCpDeltaRequest {
  const AnalyzerCpDeltaRequest({
    required this.beforeFen,
    required this.afterFen,
    required this.playedMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerCpDeltaRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         beforeFen: analyzerCpDeltaControlledBeforeFen,
         afterFen: analyzerCpDeltaControlledAfterFen,
         playedMoveUci: analyzerCpDeltaPlayedMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerCpDeltaDepth,
         source: analyzerCpDeltaDefaultSource,
       );

  final String beforeFen;
  final String afterFen;
  final String playedMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerCpDeltaResult {
  const AnalyzerCpDeltaResult({
    required this.beforeFen,
    required this.afterFen,
    required this.playedMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.beforeAfterRawEvalSucceeded,
    required this.beforeEvalSucceeded,
    required this.afterEvalSucceeded,
    required this.moverPerspectiveBeforeCp,
    required this.moverPerspectiveAfterCp,
    required this.moverPerspectiveBeforeMate,
    required this.moverPerspectiveAfterMate,
    required this.cpDeltaComputed,
    required this.moverPerspectiveDeltaCp,
    required this.deltaDirection,
    required this.cpLossComputed,
    required this.winPercentComputed,
    required this.classificationComputed,
    required this.moveQualityComputed,
    required this.failureMessage,
    required this.safeForPhase35J,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String beforeFen;
  final String afterFen;
  final String playedMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final bool beforeAfterRawEvalSucceeded;
  final bool beforeEvalSucceeded;
  final bool afterEvalSucceeded;
  final int? moverPerspectiveBeforeCp;
  final int? moverPerspectiveAfterCp;
  final int? moverPerspectiveBeforeMate;
  final int? moverPerspectiveAfterMate;
  final bool cpDeltaComputed;
  final int? moverPerspectiveDeltaCp;
  final AnalyzerCpDeltaDirection deltaDirection;
  final bool cpLossComputed;
  final bool winPercentComputed;
  final bool classificationComputed;
  final bool moveQualityComputed;
  final String? failureMessage;
  final bool safeForPhase35J;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'beforeFen': beforeFen,
    'afterFen': afterFen,
    'playedMoveUci': playedMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'beforeAfterRawEvalSucceeded': beforeAfterRawEvalSucceeded,
    'beforeEvalSucceeded': beforeEvalSucceeded,
    'afterEvalSucceeded': afterEvalSucceeded,
    'moverPerspectiveBeforeCp': moverPerspectiveBeforeCp,
    'moverPerspectiveAfterCp': moverPerspectiveAfterCp,
    'moverPerspectiveBeforeMate': moverPerspectiveBeforeMate,
    'moverPerspectiveAfterMate': moverPerspectiveAfterMate,
    'cpDeltaComputed': cpDeltaComputed,
    'moverPerspectiveDeltaCp': moverPerspectiveDeltaCp,
    'deltaDirection': deltaDirection.wire,
    'cpLossComputed': cpLossComputed,
    'winPercentComputed': winPercentComputed,
    'classificationComputed': classificationComputed,
    'moveQualityComputed': moveQualityComputed,
    'failureMessage': failureMessage,
    'safeForPhase35J': safeForPhase35J,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Analyzer CP Delta Probe')
      ..writeln()
      ..writeln('phase: Phase 35I - CP Delta Probe Without Classifier')
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('beforeFen: $beforeFen')
      ..writeln('afterFen: $afterFen')
      ..writeln('beforeAfterRawEvalSucceeded: $beforeAfterRawEvalSucceeded')
      ..writeln('beforeEvalSucceeded: $beforeEvalSucceeded')
      ..writeln('afterEvalSucceeded: $afterEvalSucceeded')
      ..writeln(
        'moverPerspectiveBeforeCp: ${moverPerspectiveBeforeCp ?? 'none'}',
      )
      ..writeln('moverPerspectiveAfterCp: ${moverPerspectiveAfterCp ?? 'none'}')
      ..writeln(
        'moverPerspectiveBeforeMate: ${moverPerspectiveBeforeMate ?? 'none'}',
      )
      ..writeln(
        'moverPerspectiveAfterMate: ${moverPerspectiveAfterMate ?? 'none'}',
      )
      ..writeln('cpDeltaComputed: $cpDeltaComputed')
      ..writeln('moverPerspectiveDeltaCp: ${moverPerspectiveDeltaCp ?? 'none'}')
      ..writeln('deltaDirection: ${deltaDirection.wire}')
      ..writeln('cpLossComputed: $cpLossComputed')
      ..writeln('winPercentComputed: $winPercentComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln('moveQualityComputed: $moveQualityComputed')
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase35J: $safeForPhase35J')
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
      ..writeln('- Controlled before/after FEN pair only')
      ..writeln('- CP delta is mover-perspective after minus before')
      ..writeln('- Mate is not converted to centipawns')
      ..writeln('- CP-loss, Win%, move quality, and labels are not computed')
      ..writeln('- No PGN, move-list, legal move generation, or user games')
      ..writeln('- No scheduler, persistence, saved analysis, UI, or backend');
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
