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
      developer.log(
        jsonEncode(_movePayload(m)),
        name: channel,
      );
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

  static Map<String, Object?> _movePayload(MoveAnalysis m) => {
        'event': 'ply',
        'ply': m.ply,
        'san': m.san,
        'uci': m.uci,
        'moverColor': m.isWhiteMove ? 'white' : 'black',
        'fenBefore': m.fenBefore,
        'fenAfter': m.fenAfter,
        'winBefore': m.winPercentBefore,
        'winAfter': m.winPercentAfter,
        'deltaW': m.deltaW,
        'bestMoveUci': m.engineBestMoveUci,
        'bestMoveSan': m.engineBestMoveSan,
        'scoreCpAfter': m.scoreCpAfter,
        'mateInAfter': m.mateInAfter,
        'isBook': m.inBook,
        'openingName': m.openingName,
        'ecoCode': m.ecoCode,
        'classification': m.classification.name,
        'message': m.message,
      };
}
