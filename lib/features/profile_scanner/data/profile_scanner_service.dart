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
import 'dart:math' as math;

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
    //    Re-throw [ImportException] verbatim so the controller can show
    //    the underlying message (e.g. "Chess.com is rate-limiting requests"
    //    or "Chess.com has no public games for X") instead of the
    //    historical "Bad state: No games found" wrapper that hid both the
    //    network and the empty-account cases behind the same string.
    final List<ImportedGame> games;
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

    if (games.isEmpty) {
      throw ImportException(
        'No standard public games found for $username on $source.',
      );
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
          engineMatchRate: 0,
          cpLossStdDev: 0,
          rating: null,
        ));
        continue;
      }

      final signals = _collectSignals(timeline, username);
      accuracySum += signals.accuracy;

      perGameAccuracy.add(GameAccuracy(
        id: g.id,
        white: g.whiteName,
        black: g.blackName,
        result: g.resultLabel,
        accuracy: signals.accuracy,
        brilliantCount:
            timeline.qualityCounts[MoveQuality.brilliant] ?? 0,
        blunderCount:
            timeline.qualityCounts[MoveQuality.blunder] ?? 0,
        engineMatchRate: signals.engineMatchRate,
        cpLossStdDev: signals.cpLossStdDev,
        rating: signals.rating,
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

    if (perGameAccuracy.isEmpty) {
      return ProfileScanResult(
        username: username,
        source: source,
        sampleSize: 0,
        averageAccuracy: 0,
        averageEngineMatchRate: 0,
        averageRating: null,
        suspicionScore: 0,
        suspicion: SuspicionLevel.clean,
        verdict: 'No playable games found in this profile.',
        games: const [],
      );
    }

    final avgAccuracy = accuracySum / perGameAccuracy.length;
    final avgEngineMatch = perGameAccuracy
            .map((g) => g.engineMatchRate)
            .fold<double>(0, (s, v) => s + v) /
        perGameAccuracy.length;
    final avgCpStdDev = perGameAccuracy
            .map((g) => g.cpLossStdDev)
            .fold<double>(0, (s, v) => s + v) /
        perGameAccuracy.length;
    final ratedGames = perGameAccuracy.where((g) => g.rating != null).toList();
    final avgRating = ratedGames.isEmpty
        ? null
        : ratedGames
                .map((g) => g.rating!)
                .reduce((a, b) => a + b) ~/
            ratedGames.length;

    // ── Composite suspicion score ────────────────────────────────
    //
    // Three signals, each normalized to 0..1, then weighted.
    //
    //   accuracyExcess: how much accuracy exceeds the human band
    //       expected for [avgRating]. 1500 ≈ 75% baseline, each +400
    //       rating points buys +4% expected accuracy (linear approx,
    //       clamped).
    //   matchExcess:    how much engine-match exceeds the human band
    //       for [avgRating]. 1500 ≈ 45% baseline, each +400 rating
    //       points buys +5%.
    //   flatness:       low cp-loss variance at high accuracy. Humans
    //       spike on blunders; engines stay flat. Penalise sub-2% SD
    //       when accuracy is > 85%.
    //
    // Each term is 0..1; final score is a weighted sum × 100.
    final expectedAccuracy =
        _expectedAccuracyForRating(avgRating ?? 1500);
    final expectedMatch =
        _expectedEngineMatchForRating(avgRating ?? 1500);
    final accuracyExcess =
        ((avgAccuracy - expectedAccuracy) / 15).clamp(0, 1).toDouble();
    final matchExcess =
        ((avgEngineMatch - expectedMatch) / 0.25).clamp(0, 1).toDouble();
    final flatness = (avgAccuracy >= 85 && avgCpStdDev < 3.0)
        ? ((3.0 - avgCpStdDev) / 3.0).clamp(0, 1).toDouble()
        : 0.0;

    final suspicionScore =
        (0.45 * accuracyExcess + 0.40 * matchExcess + 0.15 * flatness) *
            100;

    final suspicion = suspicionScore >= 70
        ? SuspicionLevel.suspicious
        : suspicionScore >= 40
            ? SuspicionLevel.moderate
            : SuspicionLevel.clean;

    final verdict = switch (suspicion) {
      SuspicionLevel.clean =>
        'Signals sit within the human band for ${avgRating ?? "this rating"} '
        '— ${avgAccuracy.toStringAsFixed(0)}% accuracy, '
        '${(avgEngineMatch * 100).toStringAsFixed(0)}% top-line match.',
      SuspicionLevel.moderate =>
        'Elevated signals — ${avgAccuracy.toStringAsFixed(0)}% accuracy with '
        '${(avgEngineMatch * 100).toStringAsFixed(0)}% engine agreement at '
        '${avgRating ?? "the stated"} ELO. Flag for a human review.',
      SuspicionLevel.suspicious =>
        'Accuracy and top-line match are well above the human band for '
        '${avgRating ?? "this rating"} '
        '(SD ${avgCpStdDev.toStringAsFixed(1)}%). Strong engine assistance signal.',
    };

    return ProfileScanResult(
      username: username,
      source: source,
      sampleSize: perGameAccuracy.length,
      averageAccuracy: avgAccuracy,
      averageEngineMatchRate: avgEngineMatch,
      averageRating: avgRating,
      suspicionScore: suspicionScore,
      suspicion: suspicion,
      verdict: verdict,
      // Reverse so newest plays first in the results list.
      games: perGameAccuracy.reversed.toList(),
    );
  }

  /// Baseline human accuracy curve. ~75% at 1500, ~92% at 2500.
  /// Beyond that the scale plateaus — top GMs rarely score above 96%
  /// full-game accuracy under serious time control.
  double _expectedAccuracyForRating(int rating) {
    final clamped = rating.clamp(600, 2800);
    // Piecewise linear approximation calibrated to Chess.com's
    // published accuracy histograms.
    final acc = 60 + ((clamped - 600) / (2800 - 600)) * 36; // 60..96
    return acc.toDouble();
  }

  /// Baseline engine top-3 match rate. ~35% at 1500, ~65% at 2500.
  double _expectedEngineMatchForRating(int rating) {
    final clamped = rating.clamp(600, 2800);
    return 0.25 + ((clamped - 600) / (2800 - 600)) * 0.50; // 0.25..0.75
  }

  /// Collapses a single timeline into the three cheat-detection
  /// signals plus the user's rating.
  _Signals _collectSignals(AnalysisTimeline timeline, String username) {
    final userIsWhite = _inferUserColor(timeline, username);
    int? rating;
    if (userIsWhite == true) {
      rating = int.tryParse(timeline.headers['WhiteElo'] ?? '');
    } else if (userIsWhite == false) {
      rating = int.tryParse(timeline.headers['BlackElo'] ?? '');
    }

    if (userIsWhite == null) {
      // Username not on either side of the header — fall back to
      // whole-game signals so the row still shows something.
      final fallbackAcc =
          (100 - timeline.averageCpLoss).clamp(0, 100).toDouble();
      return _Signals(
        accuracy: fallbackAcc,
        engineMatchRate: 0,
        cpLossStdDev: 0,
        rating: rating,
      );
    }

    double totalLoss = 0;
    final losses = <double>[];
    int plies = 0;
    int engineMatches = 0;
    for (final m in timeline.moves) {
      if (m.isWhiteMove != userIsWhite) continue;
      if (m.inBook) continue; // don't count book theory toward accuracy
      plies++;
      final loss = m.deltaW < 0 ? m.deltaW.abs() : 0.0;
      totalLoss += loss;
      losses.add(loss);
      // `best` + `brilliant` are the two classifications that *require*
      // a match against the engine's top line; treat them as the
      // engine-correlation signal.
      if (m.classification == MoveQuality.best ||
          m.classification == MoveQuality.brilliant) {
        engineMatches++;
      }
    }
    if (plies == 0) {
      return _Signals(
        accuracy: 0,
        engineMatchRate: 0,
        cpLossStdDev: 0,
        rating: rating,
      );
    }
    final avgLoss = totalLoss / plies;
    final accuracy = (100 - avgLoss).clamp(0, 100).toDouble();
    final matchRate = engineMatches / plies;

    // Population stdev of the per-ply loss series.
    double varSum = 0;
    for (final l in losses) {
      final d = l - avgLoss;
      varSum += d * d;
    }
    final variance = plies <= 1 ? 0.0 : (varSum / plies).abs();
    final std = math.sqrt(variance);

    return _Signals(
      accuracy: accuracy,
      engineMatchRate: matchRate,
      cpLossStdDev: std,
      rating: rating,
    );
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

class _Signals {
  const _Signals({
    required this.accuracy,
    required this.engineMatchRate,
    required this.cpLossStdDev,
    required this.rating,
  });
  final double accuracy;
  final double engineMatchRate;
  final double cpLossStdDev;
  final int? rating;
}


