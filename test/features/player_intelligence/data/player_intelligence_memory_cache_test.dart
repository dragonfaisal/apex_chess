import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/player_intelligence/data/player_intelligence_memory_cache.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_builder.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';
import 'package:apex_chess/features/player_intelligence/presentation/controllers/player_intelligence_controller.dart';

import '../../../support/player_intelligence_test_fixtures.dart';

void main() {
  test('session cache is keyed by exact source token and replaceable', () {
    final cache = PlayerIntelligenceMemoryCache();
    final snapshot = _emptySnapshot();

    cache.write('manifest-a', snapshot);

    expect(cache.read('manifest-a'), same(snapshot));
    expect(cache.read('manifest-b'), isNull);
    cache.clear();
    expect(cache.read('manifest-a'), isNull);
  });

  test('session cache evicts least-recently-used entry at its bound', () {
    final cache = PlayerIntelligenceMemoryCache(maximumEntries: 2);
    final snapshot = _emptySnapshot();

    cache.write('a', snapshot);
    cache.write('b', snapshot);
    expect(cache.read('a'), isNotNull);
    cache.write('c', snapshot);

    expect(cache.read('a'), isNotNull);
    expect(cache.read('b'), isNull);
    expect(cache.read('c'), isNotNull);
  });

  test('source token is order-safe and invalidates every archive input', () {
    final first = analyticsDocument(gameSeed: 4900);
    final second = analyticsDocument(gameSeed: 4901);
    ReviewDocumentSourceScan scan({
      int revision = 1,
      String firstDigest = 'digest-a',
      bool reversed = false,
      bool includeIssue = false,
    }) {
      final sources = [
        ValidatedReviewDocumentSource(
          document: first,
          contentDigest: firstDigest,
        ),
        ValidatedReviewDocumentSource(
          document: second,
          contentDigest: 'digest-b',
        ),
      ];
      return ReviewDocumentSourceScan(
        sources: reversed ? sources.reversed.toList() : sources,
        issues: includeIssue
            ? const [
                ReviewDocumentSourceIssue(
                  sourceKey: 'corrupt',
                  kind: ReviewDocumentSourceIssueKind.corruptCanonical,
                ),
              ]
            : const [],
        revision: revision,
      );
    }

    final baseline = buildPlayerAnalyticsSourceToken(scan(), 'local');
    expect(
      buildPlayerAnalyticsSourceToken(scan(reversed: true), 'local'),
      baseline,
    );
    expect(
      buildPlayerAnalyticsSourceToken(scan(revision: 2), 'local'),
      isNot(baseline),
    );
    expect(
      buildPlayerAnalyticsSourceToken(
        scan(firstDigest: 'digest-changed'),
        'local',
      ),
      isNot(baseline),
    );
    expect(
      buildPlayerAnalyticsSourceToken(scan(includeIssue: true), 'local'),
      isNot(baseline),
    );
    expect(
      buildPlayerAnalyticsSourceToken(scan(), 'chess.com:other'),
      isNot(baseline),
    );
  });

  test('analytics executor keeps aggregation off the caller isolate', () async {
    final input = PlayerAnalyticsBuildInput(
      documents: [
        for (var index = 0; index < 250; index++)
          analyticsDocument(gameSeed: 5000 + index),
      ],
      playerIdentityScope: 'local',
    );
    var callerEventLoopAdvanced = false;
    final future = const PlayerAnalyticsExecutor().build(
      const PlayerAnalyticsBuilder(),
      input,
    );
    Timer.run(() => callerEventLoopAdvanced = true);

    final snapshot = await future;

    expect(callerEventLoopAdvanced, isTrue);
    expect(snapshot.canonicalAnalyzedGames, 250);
  });

  test('coordinator shares one in-flight build per source token', () async {
    final coordinator = PlayerAnalyticsBuildCoordinator();
    final completer = Completer<PlayerAnalyticsSnapshot>();
    var calls = 0;

    Future<PlayerAnalyticsSnapshot> operation() {
      calls++;
      return completer.future;
    }

    final first = coordinator.run('manifest-a', operation);
    final second = coordinator.run('manifest-a', operation);
    expect(identical(first, second), isTrue);
    expect(calls, 1);

    final snapshot = _emptySnapshot();
    completer.complete(snapshot);
    expect(await first, same(snapshot));
    expect(await second, same(snapshot));

    final third = coordinator.run('manifest-a', () async {
      calls++;
      return snapshot;
    });
    expect(await third, same(snapshot));
    expect(calls, 2);
  });
}

PlayerAnalyticsSnapshot _emptySnapshot() =>
    const PlayerAnalyticsBuilder().build(
      const PlayerAnalyticsBuildInput(
        documents: [],
        playerIdentityScope: 'local',
      ),
    );
