/// Profile Scanner service — real engine-backed accuracy math.
///
/// Pulls the opponent's last N games via the public Chess.com /
/// Lichess endpoints, replays each through the local [LocalGameAnalyzer]
/// at Fast D14, and aggregates the opponent's per-ply Win% loss into a
/// single mean accuracy score. Suspicion bucketing is unchanged from
/// the scaffold: >= 92% accuracy is flagged suspicious, >= 82% is a
/// flag-for-review moderate, anything else is clean.
///
/// Cost: ~30 plies × ~1 s × N games. Default [sampleSize] is 5 so a
/// scan completes in ~2–3 minutes rather than the ~6 of a 10-game
/// run; the scanner UI surfaces progress and a cancel button.
library;

import 'dart:async';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/import_match/data/chess_com_repository.dart';
import 'package:apex_chess/features/import_match/data/lichess_repository.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';

import '../domain/profile_scan_result.dart';

/// Cooperative cancellation flag passed from the UI. The service
/// checks it between games and, when the flag flips, returns
/// immediately without writing more state. Keeping this lightweight
/// avoids pulling the `async` package just for one flag.
class ScanCancellation {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class ScanProgress {
  const ScanProgress({
    required this.completed,
    required this.total,
    required this.currentPly,
    required this.currentPlyTotal,
    this.currentGame,
  });

  final int completed;
  final int total;
  final int currentPly;
  final int currentPlyTotal;
  final String? currentGame;

  double get overall {
    if (total == 0) return 0;
    final gameFraction = (completed / total).clamp(0, 1).toDouble();
    final plyFraction =
        currentPlyTotal == 0 ? 0.0 : (currentPly / currentPlyTotal) / total;
    return (gameFraction + plyFraction).clamp(0, 1).toDouble();
  }
}

class ScanCancelledException implements Exception {
  const ScanCancelledException();
}

class ProfileScannerService {
  ProfileScannerService({
    required this.chessCom,
    required this.lichess,
    required this.analyzer,
  });

  final ChessComRepository chessCom;
  final LichessRepository lichess;
  final LocalGameAnalyzer analyzer;

  /// Analyses [sampleSize] recent games for [username] and returns a
  /// [ProfileScanResult]. Progress updates stream via [onProgress] so
  /// the UI can render a live progress bar.
  Future<ProfileScanResult> scan({
    required String username,
    required String source,
    int sampleSize = 5,
    int depth = 14,
    ScanCancellation? cancellation,
    void Function(ScanProgress)? onProgress,
  }) async {
    // 1. Fetch the opponent's recent games from the correct provider.
    final List<ImportedGame> games;
    try {
      if (source == 'chess.com') {
        games = await chessCom.fetchRecentGames(
          username,
          limit: sampleSize,
        );
      } else {
        games = await lichess.fetchRecentGames(
          username,
          limit: sampleSize,
        );
      }
    } on ImportException catch (e) {
      throw StateError(e.userMessage);
    }

    if (games.isEmpty) {
      throw StateError('No games found for $username on $source.');
    }

    // 2. Walk the list oldest-first so the list the user sees
    // reads chronologically in the results card.
    games.sort((a, b) => a.playedAt.compareTo(b.playedAt));
    final toScan = games.take(sampleSize).toList();

    final perGameAccuracy = <GameAccuracy>[];
    double accuracySum = 0;

    for (var i = 0; i < toScan.length; i++) {
      if (cancellation?.isCancelled ?? false) {
        throw const ScanCancelledException();
      }
      final g = toScan[i];
      onProgress?.call(ScanProgress(
        completed: i,
        total: toScan.length,
        currentPly: 0,
        currentPlyTotal: 1,
        currentGame: '${g.whiteName} vs ${g.blackName}',
      ));

      AnalysisTimeline? timeline;
      try {
        timeline = await analyzer.analyzeFromPgn(
          g.pgn,
          depth: depth,
          onProgress: (c, t) {
            if (cancellation?.isCancelled ?? false) return;
            onProgress?.call(ScanProgress(
              completed: i,
              total: toScan.length,
              currentPly: c,
              currentPlyTotal: t,
              currentGame: '${g.whiteName} vs ${g.blackName}',
            ));
          },
        );
      } on LocalAnalysisException {
        // One game failing shouldn't tank the whole scan; record a
        // zero-accuracy row and move on. Rare in practice.
        perGameAccuracy.add(GameAccuracy(
          id: g.id,
          white: g.whiteName,
          black: g.blackName,
          result: g.resultLabel,
          accuracy: 0,
          brilliantCount: 0,
          blunderCount: 0,
        ));
        continue;
      }

      final accuracy = _opponentAccuracy(timeline, username);
      accuracySum += accuracy;

      perGameAccuracy.add(GameAccuracy(
        id: g.id,
        white: g.whiteName,
        black: g.blackName,
        result: g.resultLabel,
        accuracy: accuracy,
        brilliantCount:
            timeline.qualityCounts[MoveQuality.brilliant] ?? 0,
        blunderCount:
            timeline.qualityCounts[MoveQuality.blunder] ?? 0,
      ));
    }

    if (cancellation?.isCancelled ?? false) {
      throw const ScanCancelledException();
    }

    onProgress?.call(ScanProgress(
      completed: toScan.length,
      total: toScan.length,
      currentPly: 1,
      currentPlyTotal: 1,
    ));

    final avg = perGameAccuracy.isEmpty
        ? 0.0
        : accuracySum / perGameAccuracy.length;
    final suspicion = avg >= 92
        ? SuspicionLevel.suspicious
        : avg >= 82
            ? SuspicionLevel.moderate
            : SuspicionLevel.clean;
    final verdict = switch (suspicion) {
      SuspicionLevel.clean =>
        'Accuracy sits within the human band for the stated rating.',
      SuspicionLevel.moderate =>
        'Accuracy is above the typical band — flag for a human review.',
      SuspicionLevel.suspicious =>
        'Accuracy is well above what a human of this rating typically produces.',
    };

    return ProfileScanResult(
      username: username,
      source: source,
      sampleSize: perGameAccuracy.length,
      averageAccuracy: avg,
      suspicion: suspicion,
      verdict: verdict,
      // Reverse so newest plays first in the results list.
      games: perGameAccuracy.reversed.toList(),
    );
  }

  /// Average Win% accuracy for the user-of-interest in a single game.
  ///
  /// "Accuracy" here is a simple dual of the `averageCpLoss` aggregate
  /// already used across the app: for each ply where the user was on
  /// move, accumulate `max(0, -deltaW)` (negative delta = loss for the
  /// mover) and divide by the number of plies. We clamp to 0..100
  /// because deltas can briefly exceed the range on blundered mate-in
  /// lines.
  double _opponentAccuracy(AnalysisTimeline timeline, String username) {
    final userIsWhite = _inferUserColor(timeline, username);
    if (userIsWhite == null) {
      // Username not on either side of the header — fall back to
      // whole-game accuracy so the row still has a signal.
      return (100 - timeline.averageCpLoss).clamp(0, 100).toDouble();
    }
    double totalLoss = 0;
    int plies = 0;
    for (final m in timeline.moves) {
      if (m.isWhiteMove != userIsWhite) continue;
      if (m.inBook) continue; // Don't count book theory toward accuracy.
      plies++;
      if (m.deltaW < 0) totalLoss += m.deltaW.abs();
    }
    if (plies == 0) return 0;
    final avgLoss = totalLoss / plies;
    return (100 - avgLoss).clamp(0, 100).toDouble();
  }

  bool? _inferUserColor(AnalysisTimeline timeline, String username) {
    final white = (timeline.headers['White'] ?? '').toLowerCase();
    final black = (timeline.headers['Black'] ?? '').toLowerCase();
    final me = username.toLowerCase();
    if (white == me) return true;
    if (black == me) return false;
    return null;
  }
}


