library;

import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/player_intelligence/data/player_intelligence_memory_cache.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_builder.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';

final playerAnalyticsBuilderProvider = Provider<PlayerAnalyticsBuilder>(
  (ref) => const PlayerAnalyticsBuilder(),
);

final playerAnalyticsExecutorProvider = Provider<PlayerAnalyticsExecutor>(
  (ref) => const PlayerAnalyticsExecutor(),
);

final playerAnalyticsCoordinatorProvider =
    Provider<PlayerAnalyticsBuildCoordinator>(
      (ref) => PlayerAnalyticsBuildCoordinator(),
    );

final playerIntelligenceMemoryCacheProvider =
    Provider<PlayerIntelligenceMemoryCache>(
      (ref) => PlayerIntelligenceMemoryCache(),
    );

final playerIntelligenceControllerProvider =
    AsyncNotifierProvider<
      PlayerIntelligenceController,
      PlayerAnalyticsSnapshot
    >(PlayerIntelligenceController.new);

class PlayerAnalyticsExecutor {
  const PlayerAnalyticsExecutor();

  Future<PlayerAnalyticsSnapshot> build(
    PlayerAnalyticsBuilder builder,
    PlayerAnalyticsBuildInput input,
  ) => Isolate.run(() => builder.build(input));
}

class PlayerAnalyticsBuildCoordinator {
  final Map<String, Future<PlayerAnalyticsSnapshot>> _inFlight = {};

  Future<PlayerAnalyticsSnapshot> run(
    String sourceToken,
    Future<PlayerAnalyticsSnapshot> Function() operation,
  ) {
    final existing = _inFlight[sourceToken];
    if (existing != null) return existing;
    final future = Future<PlayerAnalyticsSnapshot>.sync(operation);
    _inFlight[sourceToken] = future;
    future.whenComplete(() {
      if (identical(_inFlight[sourceToken], future)) {
        _inFlight.remove(sourceToken);
      }
    }).ignore();
    return future;
  }
}

class PlayerIntelligenceController
    extends AsyncNotifier<PlayerAnalyticsSnapshot> {
  @override
  Future<PlayerAnalyticsSnapshot> build() async {
    // ArchiveController publishes a new immutable list after every canonical
    // save/delete/clear. Watching it invalidates the derived snapshot without
    // making the UI decode ReviewDocuments.
    ref.watch(archiveControllerProvider.select((state) => state.games));
    final account = ref.watch(accountControllerProvider).valueOrNull;
    final repository = await ref.watch(archiveRepositoryProvider.future);
    final scan = await repository.scanValidatedReviewDocuments();
    final playerScope = account == null
        ? 'local'
        : '${account.source.wire}:${account.username.trim().toLowerCase()}';
    final sourceToken = buildPlayerAnalyticsSourceToken(scan, playerScope);
    final cache = ref.read(playerIntelligenceMemoryCacheProvider);
    final cached = cache.read(sourceToken);
    if (cached != null) {
      return cached.copyWith(
        performance: cached.performance.copyWith(cacheHit: true),
      );
    }

    final documents = [for (final source in scan.sources) source.document];
    final digests = {
      for (final source in scan.sources)
        source.document.documentId: source.contentDigest,
    };
    final exclusions = [
      for (final issue in scan.issues)
        PlayerAnalyticsExclusion(
          reason: PlayerAnalyticsExclusionReason.corruptOrUnavailable,
          detail: switch (issue.kind) {
            ReviewDocumentSourceIssueKind.corruptCanonical =>
              'A canonical saved review failed validation.',
            ReviewDocumentSourceIssueKind.legacyUntrusted =>
              'A legacy saved review lacks sufficient canonical evidence.',
            ReviewDocumentSourceIssueKind.legacyMalformed =>
              'A malformed legacy saved review remains quarantined.',
          },
          documentId: issue.sourceKey,
        ),
    ];
    final input = PlayerAnalyticsBuildInput(
      documents: documents,
      playerIdentityScope: playerScope,
      analysisDigests: digests,
      sourceExclusions: exclusions,
    );
    final snapshot = await ref
        .read(playerAnalyticsCoordinatorProvider)
        .run(
          sourceToken,
          () => ref
              .read(playerAnalyticsExecutorProvider)
              .build(ref.read(playerAnalyticsBuilderProvider), input),
        );
    cache.write(sourceToken, snapshot);
    return snapshot;
  }

  void refresh() => ref.invalidateSelf();
}

String buildPlayerAnalyticsSourceToken(
  ReviewDocumentSourceScan scan,
  String playerScope,
) {
  final sources = [...scan.sources]
    ..sort(
      (left, right) =>
          left.document.documentId.compareTo(right.document.documentId),
    );
  final issues = [...scan.issues]
    ..sort((left, right) {
      final kind = left.kind.name.compareTo(right.kind.name);
      return kind != 0 ? kind : left.sourceKey.compareTo(right.sourceKey);
    });
  final fields = <String>[
    _lengthPrefixedCacheField(
      'analyticsPolicy',
      '$kPlayerAnalyticsPolicyVersion',
    ),
    _lengthPrefixedCacheField(
      'analyticsSchema',
      '$kPlayerAnalyticsSchemaVersion',
    ),
    _lengthPrefixedCacheField('scope', playerScope),
    _lengthPrefixedCacheField('revision', '${scan.revision}'),
    for (final source in sources) ...[
      _lengthPrefixedCacheField('documentId', source.document.documentId),
      _lengthPrefixedCacheField('contentDigest', source.contentDigest),
    ],
    for (final issue in issues) ...[
      _lengthPrefixedCacheField('issueKind', issue.kind.name),
      _lengthPrefixedCacheField('issueKey', issue.sourceKey),
    ],
  ];
  return sha256.convert(utf8.encode('${fields.join('\n')}\n')).toString();
}

String _lengthPrefixedCacheField(String name, String value) =>
    '$name:${utf8.encode(value).length}:$value';
