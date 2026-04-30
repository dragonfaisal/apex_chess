/// Debug export for analyzed plies — used by the Phase A integration audit
/// (see `docs/specs/apex_chess_analysis_training_ux_spec.md`, audit step A).
///
/// In `kDebugMode` builds, [AnalysisDebugExport.dump] writes one JSON line
/// per ply to the developer log so a post-PR-#18 regression like
/// "Brilliant on the recapture instead of the sacrifice" can be diagnosed
/// from a single device-log dump instead of by inspecting the UI ply by
/// ply.
///
/// In release builds the helper is a no-op.
library;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/position_heuristics.dart';

class AnalysisDebugExport {
  const AnalysisDebugExport._();

  /// Dumps a structured per-ply trace of [timeline] to the developer log
  /// under the `apex_chess.analysis` channel. Each line carries the
  /// minimum signal an audit reviewer needs:
  ///
  ///   * ply index, SAN / UCI, mover colour
  ///   * fen before / after
  ///   * winBefore / winAfter / deltaW
  ///   * bestMove (UCI) — the engine's #1 candidate
  ///   * isBook / classification / one-line message
  ///
  /// The dump is gated on [kDebugMode] so analysis stays free of log
  /// chatter in release builds. [tag] is appended to the channel name so
  /// concurrent imports do not interleave their dumps.
  static void dump(
    AnalysisTimeline timeline, {
    String tag = 'timeline',
    String? userColor,
  }) {
    if (!kDebugMode) return;
    final channel = 'apex_chess.analysis.$tag';
    developer.log(
      jsonEncode({
        'event': 'timeline_start',
        'startingFen': timeline.startingFen,
        'totalPlies': timeline.totalPlies,
        'userColor': userColor,
        'headers': timeline.headers,
      }),
      name: channel,
    );
    for (final m in timeline.moves) {
      developer.log(jsonEncode(_movePayload(m)), name: channel);
    }
    developer.log(
      jsonEncode({
        'event': 'timeline_end',
        'qualityCounts': {
          for (final e in timeline.qualityCounts.entries) e.key.name: e.value,
        },
        'averageCpLoss': timeline.averageCpLoss,
      }),
      name: channel,
    );
  }

  /// Developer-only text payload for copy/paste from logs or tests.
  static String jsonLines(AnalysisTimeline timeline) =>
      timeline.moves.map((m) => jsonEncode(_movePayload(m))).join('\n');

  static Map<String, Object?> _movePayload(MoveAnalysis m) => {
    'event': 'ply',
    'ply': m.ply,
    'san': m.san,
    'uci': m.uci,
    'mover': m.isWhiteMove ? 'white' : 'black',
    'fenBefore': m.fenBefore,
    'fenAfter': m.fenAfter,
    'classification': m.classification.name,
    'baseClassification': m.baseClassification.name,
    'finalClassification': m.finalClassification.name,
    'reasonCode': m.reasonCode,
    'playedEqualsPV1': m.playedEqualsPv1,
    'pv1': _linePayload(m, 0),
    'pv2': _linePayload(m, 1),
    'pv3': _linePayload(m, 2),
    'pvGap1to2': _pvGap(m, 1),
    'pvGap1to3': _pvGap(m, 2),
    'moverWinBefore': m.isWhiteMove
        ? m.winPercentBefore
        : 100.0 - m.winPercentBefore,
    'moverWinAfter': m.isWhiteMove
        ? m.winPercentAfter
        : 100.0 - m.winPercentAfter,
    'deltaW': m.deltaW,
    'cpLoss': m.moverCpLoss,
    'materialBefore': PositionHeuristics.materialBalanceFromFen(m.fenBefore),
    'materialAfter': PositionHeuristics.materialBalanceFromFen(m.fenAfter),
    'isFreeCapture': m.isFreeCapture,
    'isRecapture': m.isRecapture,
    'isCapture': m.isCapture,
    'isSacrifice': m.isSacrifice,
    'isFirstSacrificePly': m.isFirstSacrificePly,
    'openingStatus': m.openingStatus.name,
    'isBook': m.inBook,
    'mateInfo': {
      'mateInAfter': m.mateInAfter,
      'moverDeliveredMate':
          m.mateInAfter != null &&
          ((m.isWhiteMove && m.mateInAfter! > 0) ||
              (!m.isWhiteMove && m.mateInAfter! < 0)),
    },
    'bestMoveUci': m.engineBestMoveUci,
    'bestMoveSan': m.engineBestMoveSan,
    'scoreCpAfter': m.scoreCpAfter,
    'mateInAfter': m.mateInAfter,
    'openingName': m.openingName,
    'ecoCode': m.ecoCode,
    'message': m.message,
  };

  static Map<String, Object?>? _linePayload(MoveAnalysis m, int index) {
    if (m.engineLines.length <= index) return null;
    final line = m.engineLines[index];
    return {
      'uci': line.moveUci,
      'san': line.moveSan,
      'cp': line.scoreCp,
      'mate': line.mateIn,
      'winPercent': line.whiteWinPercent,
    };
  }

  static double? _pvGap(MoveAnalysis m, int index) {
    if (m.engineLines.length <= index || m.engineLines.isEmpty) return null;
    final pv1 = _moverWin(m, m.engineLines.first.whiteWinPercent);
    final alt = _moverWin(m, m.engineLines[index].whiteWinPercent);
    return pv1 - alt;
  }

  static double _moverWin(MoveAnalysis m, double whiteWin) =>
      m.isWhiteMove ? whiteWin : 100.0 - whiteWin;
}
