import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/saved_review_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = '8/8/8/8/8/8/8/8 w - - 0 1';
const _pgn = '''
[Event "Saved"]
[White "Alpha"]
[Black "Beta"]
[Result "1-0"]

1. e4 e5 *
''';

void main() {
  test('openable saved review is found before analysis progress is needed', () {
    final saved = _game(id: 'fast', mode: AnalysisMode.quick);

    final match = findOpenableCanonicalSavedReview(
      games: [saved],
      pgn: _pgn,
      white: 'Alpha',
      black: 'Beta',
      result: '1-0',
    );

    expect(match, same(saved));
    expect(match!.cachedTimeline, isNotNull);
  });

  test('Deep saved review is preferred for Preview', () {
    final fast = _game(
      id: 'fast',
      mode: AnalysisMode.quick,
      analyzedAt: DateTime(2026, 5, 1),
    );
    final deep = _game(
      id: 'deep',
      mode: AnalysisMode.deep,
      analyzedAt: DateTime(2026, 5, 2),
    );

    final match = findOpenableCanonicalSavedReview(
      games: [fast, deep],
      pgn: _pgn,
      white: 'Alpha',
      black: 'Beta',
      result: '1-0',
    );

    expect(match!.id, 'deep');
    expect(match.reviewModeLabel, 'Deep');
  });

  test('partial saved review without timeline is ignored', () {
    final partial = _game(id: 'partial', includeCachedTimeline: false);

    final match = findOpenableCanonicalSavedReview(
      games: [partial],
      pgn: _pgn,
      white: 'Alpha',
      black: 'Beta',
      result: '1-0',
    );

    expect(match, isNull);
  });
}

ArchivedGame _game({
  required String id,
  AnalysisMode mode = AnalysisMode.deep,
  DateTime? analyzedAt,
  bool includeCachedTimeline = true,
}) {
  final timeline = _timeline(mode);
  return ArchivedGame(
    id: id,
    source: ArchiveSource.pgn,
    white: 'Alpha',
    black: 'Beta',
    result: '1-0',
    analyzedAt: analyzedAt ?? DateTime(2026, 5, 1),
    depth: mode == AnalysisMode.quick ? 14 : 22,
    pgn: _pgn,
    qualityCounts: const {MoveQuality.best: 1},
    averageCpLoss: mode == AnalysisMode.quick ? 22 : 8,
    totalPlies: 2,
    cachedTimeline: includeCachedTimeline ? timeline : null,
    analysisMode: mode,
    analysisProfileId: mode == AnalysisMode.quick
        ? 'fast_review'
        : 'deep_review',
  );
}

AnalysisTimeline _timeline(AnalysisMode mode) {
  return AnalysisTimeline(
    moves: [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _fen,
        fenAfter: _fen,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 52,
        deltaW: 2,
        isWhiteMove: true,
        classification: MoveQuality.best,
        message: 'Best',
      ),
    ],
    startingFen: _fen,
    headers: const {'White': 'Alpha', 'Black': 'Beta', 'Result': '1-0'},
    winPercentages: const [52],
    analysisMode: mode == AnalysisMode.quick ? 'quick' : 'deep',
    analysisProfileId: mode == AnalysisMode.quick
        ? 'fast_review'
        : 'deep_review',
  );
}
