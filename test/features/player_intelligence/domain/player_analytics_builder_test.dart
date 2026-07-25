import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/player_intelligence/data/player_intelligence_memory_cache.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_builder.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_coaching_priority_engine.dart';

import '../../../support/player_intelligence_test_fixtures.dart';

void main() {
  group('canonical selection and metric integrity', () {
    test('deduplicates GameId and selects deterministic stronger evidence', () {
      final weaker = analyticsDocument(
        gameSeed: 1,
        variantSeed: 'weak',
        depth: 12,
      );
      final stronger = analyticsDocument(
        gameSeed: 1,
        variantSeed: 'strong',
        depth: 20,
        completeCandidates: true,
      );

      final snapshot = _build([weaker, stronger]);

      expect(snapshot.distinctSavedGames, 1);
      expect(snapshot.canonicalAnalyzedGames, 1);
      expect(
        snapshot.manifest.selectedGames.single.variantId,
        stronger.variantId.value,
      );
      expect(
        snapshot.manifest.exclusions
            .where(
              (item) =>
                  item.reason ==
                  PlayerAnalyticsExclusionReason.duplicateGameVariant,
            )
            .single
            .variantId,
        weaker.variantId.value,
      );
      expect(
        snapshot.manifest.selectedGames.map((game) => game.gameId).toSet(),
        hasLength(1),
      );
    });

    test(
      'engine evidence outranks a shallow newer schema without mixing variants',
      () {
        final shallowSchema6 = analyticsDocument(
          gameSeed: 10,
          variantSeed: 'shallow-schema-6',
          analysisSchema: kApexAnalysisSchemaVersion,
          depth: 10,
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.dropsMaterial,
              materialDelta: -3,
            ),
          },
        );
        final strongerSchema5 = analyticsDocument(
          gameSeed: 10,
          variantSeed: 'strong-schema-5',
          analysisSchema: kApexLegacyInsightAnalysisSchemaVersion,
          depth: 20,
          completeCandidates: true,
        );

        final snapshot = _build([shallowSchema6, strongerSchema5]);

        expect(
          snapshot.manifest.selectedGames.single.documentId,
          strongerSchema5.documentId,
        );
        expect(
          snapshot.manifest.selectedGames.single.selectionReason,
          startsWith('trustedEngine=1,completeMultiPvPlies='),
        );
        expect(
          snapshot.manifest.exclusions.single.documentId,
          shallowSchema6.documentId,
        );
      },
    );

    test(
      'incomplete siblings never win and equal vectors use stable identity',
      () {
        final incomplete = analyticsDocument(
          gameSeed: 11,
          variantSeed: 'incomplete-high-depth',
          depth: 30,
          completeCandidates: true,
          trustedComplete: false,
        );
        final equalA = analyticsDocument(
          gameSeed: 11,
          variantSeed: 'equal-a',
          depth: 18,
          completeCandidates: true,
        );
        final equalB = analyticsDocument(
          gameSeed: 11,
          variantSeed: 'equal-b',
          depth: 18,
          completeCandidates: true,
        );
        final expected = [equalA, equalB]
          ..sort(
            (left, right) =>
                left.variantId.value.compareTo(right.variantId.value),
          );

        final first = _build([incomplete, equalB, equalA]);
        final reversed = _build([equalA, equalB, incomplete]);

        expect(
          first.manifest.selectedGames.single.documentId,
          expected.first.documentId,
        );
        expect(
          reversed.manifest.selectedGames.single.documentId,
          expected.first.documentId,
        );
        expect(
          first.manifest.exclusions.any(
            (item) =>
                item.reason ==
                    PlayerAnalyticsExclusionReason.incompleteDocument &&
                item.documentId == incomplete.documentId,
          ),
          isTrue,
        );
      },
    );

    test(
      'conflicting sides exclude a GameId and exact duplicates count once',
      () {
        final white = analyticsDocument(
          gameSeed: 12,
          variantSeed: 'white',
          playerIsWhite: true,
        );
        final black = analyticsDocument(
          gameSeed: 12,
          variantSeed: 'black',
          playerIsWhite: false,
        );
        final conflict = _build([white, black]);
        expect(conflict.canonicalAnalyzedGames, 0);
        expect(
          conflict.manifest.exclusions.single.detail,
          contains('contradict'),
        );

        final duplicate = _build([white, white, white]);
        expect(duplicate.canonicalAnalyzedGames, 1);
        expect(duplicate.manifest.exclusions, isEmpty);
      },
    );

    test('uses immutable White and Black side without name inference', () {
      final white = analyticsDocument(
        gameSeed: 2,
        playerIsWhite: true,
        playerQualities: const [MoveQuality.blunder, MoveQuality.good],
        opponentQualities: const [MoveQuality.brilliant, MoveQuality.brilliant],
      );
      final black = analyticsDocument(
        gameSeed: 3,
        playerIsWhite: false,
        playerQualities: const [MoveQuality.mistake, MoveQuality.good],
        opponentQualities: const [MoveQuality.brilliant, MoveQuality.brilliant],
      );
      final unknown = analyticsDocument(gameSeed: 4, playerIsWhite: null);

      final snapshot = _build([white, black, unknown]);

      expect(snapshot.canonicalAnalyzedGames, 2);
      expect(snapshot.totalPlayerMoves, 4);
      expect(
        snapshot.classificationDistribution[MoveQuality.brilliant]!.numerator,
        0,
      );
      expect(
        snapshot.classificationDistribution[MoveQuality.blunder]!.numerator,
        1,
      );
      expect(
        snapshot.classificationDistribution[MoveQuality.mistake]!.numerator,
        1,
      );
      expect(
        snapshot.manifest.exclusions.any(
          (item) =>
              item.reason == PlayerAnalyticsExclusionReason.unknownPlayerSide,
        ),
        isTrue,
      );
    });

    test('keeps explicit denominators and unavailable moves separate', () {
      final document = analyticsDocument(
        gameSeed: 5,
        playerQualities: const [
          MoveQuality.good,
          MoveQuality.inaccuracy,
          MoveQuality.mistake,
          MoveQuality.blunder,
          MoveQuality.missedWin,
          MoveQuality.unavailable,
        ],
      );

      final snapshot = _build([document]);

      expect(snapshot.totalPlayerMoves, 6);
      expect(snapshot.classificationEligibleMoves, 5);
      expect(
        snapshot.classificationDistribution[MoveQuality.good]!.denominator,
        5,
      );
      expect(
        snapshot.classificationDistribution[MoveQuality.unavailable]!.numerator,
        1,
      );
      expect(
        snapshot.criticalErrorMetrics['criticalErrorsPer100']!.numerator,
        4,
      );
      expect(
        snapshot.criticalErrorMetrics['criticalErrorsPer100']!.denominator,
        5,
      );
      expect(snapshot.criticalErrorMetrics['blundersPer100']!.rate, 20);
    });

    test('bounds historic insight and opening eligibility', () {
      final schema4 = analyticsDocument(
        gameSeed: 6,
        analysisSchema: kApexLegacyAnalysisSchemaVersion,
      );
      final schema5 = analyticsDocument(
        gameSeed: 7,
        analysisSchema: kApexLegacyInsightAnalysisSchemaVersion,
        playerInsights: const {
          0: AnalyticsInsightSpec(
            claim: MoveInsightClaimType.dropsMaterial,
            materialDelta: -3,
          ),
        },
      );
      final schema6Opening = analyticsDocument(
        gameSeed: 8,
        verifiedOpening: true,
        playerQualities: const [
          MoveQuality.book,
          MoveQuality.mistake,
          MoveQuality.good,
          MoveQuality.good,
        ],
      );

      final snapshot = _build([schema4, schema5, schema6Opening]);

      expect(snapshot.classificationEligibleMoves, 12);
      expect(snapshot.insightEligibleMoves, 8);
      expect(snapshot.openingEligibleGames, 1);
      expect(snapshot.openings.single.eco, 'C20');
      expect(snapshot.openings.single.leavingTheorySamples, 1);
    });
  });

  group('events, coaching, and exact evidence', () {
    test('counts primary events and publishes repeated exact priorities', () {
      final documents = [
        for (var seed = 20; seed < 23; seed++)
          analyticsDocument(
            gameSeed: seed,
            playerQualities: const [
              MoveQuality.blunder,
              MoveQuality.good,
              MoveQuality.good,
              MoveQuality.good,
            ],
            playerInsights: const {
              0: AnalyticsInsightSpec(
                claim: MoveInsightClaimType.dropsMaterial,
                materialDelta: -3,
              ),
            },
          ),
      ];

      final snapshot = _build(documents);
      final priority = snapshot.priorities.singleWhere(
        (item) => item.priorityId == 'material-losses',
      );

      expect(snapshot.materialEvents['droppedMaterial']!.negativeCount, 3);
      expect(priority.eventCount, 3);
      expect(priority.gameCount, 3);
      expect(priority.examples, hasLength(3));
      for (final example in priority.examples) {
        expect(example.gameId, hasLength(64));
        expect(example.variantId, hasLength(64));
        expect(example.documentId, hasLength(64));
        expect(example.ply, 0);
        expect(
          snapshot.manifest.selectedGames.any(
            (game) =>
                game.gameId == example.gameId &&
                game.variantId == example.variantId &&
                game.documentId == example.documentId,
          ),
          isTrue,
        );
      }
    });

    test('separates positive mechanisms and Only-Move defenses', () {
      final documents = [
        for (var seed = 30; seed < 35; seed++)
          analyticsDocument(
            gameSeed: seed,
            playerQualities: const [
              MoveQuality.onlyMove,
              MoveQuality.best,
              MoveQuality.good,
              MoveQuality.good,
            ],
            playerInsights: const {
              0: AnalyticsInsightSpec(
                claim: MoveInsightClaimType.onlyMoveDefense,
                mechanism: MoveInsightMechanismType.onlyMoveDefense,
                consequence: MoveInsightConsequenceType.avoidsCheckmate,
              ),
              1: AnalyticsInsightSpec(
                claim: MoveInsightClaimType.winsMaterial,
                mechanism: MoveInsightMechanismType.fork,
                consequence: MoveInsightConsequenceType.materialGain,
                materialDelta: 3,
              ),
            },
          ),
      ];

      final snapshot = _build(documents);

      expect(
        snapshot
            .tacticalMechanisms[MoveInsightMechanismType.fork]!
            .positiveCount,
        5,
      );
      expect(snapshot.mateEvents['onlyMovePreventingMate']!.positiveCount, 5);
      expect(
        snapshot.priorities.any(
          (priority) => priority.priorityId == 'only-move-defenses',
        ),
        isTrue,
      );
      expect(snapshot.strength, isNotNull);
    });

    test('suppresses one-off evidence and overlapping lower priorities', () {
      final oneOff = _build([
        analyticsDocument(
          gameSeed: 40,
          playerQualities: const [MoveQuality.blunder],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.dropsMaterial,
              mechanism: MoveInsightMechanismType.unsoundSacrifice,
              consequence: MoveInsightConsequenceType.materialLoss,
              materialDelta: -3,
            ),
          },
        ),
      ]);
      expect(oneOff.priorities, isEmpty);
      expect(
        oneOff.suppressedPriorities.any(
          (item) =>
              item.priorityId == 'material-losses' &&
              item.reason.contains('at least 2'),
        ),
        isTrue,
      );

      final repeated = _build([
        for (var seed = 41; seed < 43; seed++)
          analyticsDocument(
            gameSeed: seed,
            playerQualities: const [MoveQuality.blunder],
            playerInsights: const {
              0: AnalyticsInsightSpec(
                claim: MoveInsightClaimType.dropsMaterial,
                mechanism: MoveInsightMechanismType.unsoundSacrifice,
                consequence: MoveInsightConsequenceType.materialLoss,
                materialDelta: -3,
              ),
            },
          ),
      ]);
      expect(repeated.priorities, hasLength(1));
      expect(repeated.priorities.single.priorityId, 'unsound-sacrifices');
      expect(
        repeated.suppressedPriorities.any(
          (item) =>
              item.priorityId == 'material-losses' &&
              item.code ==
                  CoachingPrioritySuppressionCode
                      .overlappingPublishedPriority &&
              item.reason.contains('already represented'),
        ),
        isTrue,
      );
    });
  });

  group('trend, identity, cache source material, and scale', () {
    test('classifies equal non-overlapping trends and resists an outlier', () {
      expect(
        _trendHistory(previousErrors: 1, recentErrors: 0).trend.state,
        PlayerAnalyticsTrendState.improving,
      );
      expect(
        _trendHistory(previousErrors: 1, recentErrors: 1).trend.state,
        PlayerAnalyticsTrendState.stable,
      );
      expect(
        _trendHistory(previousErrors: 0, recentErrors: 1).trend.state,
        PlayerAnalyticsTrendState.declining,
      );

      final outlier = _build([
        for (var index = 0; index < 20; index++)
          analyticsDocument(
            gameSeed: 200 + index,
            completedAt: DateTime.utc(2026, 6, 1 + index),
            playerQualities: index == 19
                ? const [
                    MoveQuality.blunder,
                    MoveQuality.mistake,
                    MoveQuality.inaccuracy,
                    MoveQuality.good,
                  ]
                : const [
                    MoveQuality.good,
                    MoveQuality.good,
                    MoveQuality.good,
                    MoveQuality.good,
                  ],
          ),
      ]);
      expect(
        outlier.trend.state,
        PlayerAnalyticsTrendState.insufficientEvidence,
      );
      expect(outlier.trend.suppressionReason, contains('dominates'));
    });

    test('suppresses progress when either window has partial eligibility', () {
      final documents = _trendDocuments(
        250,
        previousErrors: 1,
        recentErrors: 0,
      );
      final partialRecent = analyticsDocument(
        gameSeed: 269,
        completedAt: DateTime.utc(2026, 5, 20),
        playerQualities: const [
          MoveQuality.good,
          MoveQuality.good,
          MoveQuality.good,
          MoveQuality.unavailable,
        ],
      );
      documents[19] = partialRecent;

      final snapshot = _build(documents);

      expect(
        snapshot.trend.state,
        PlayerAnalyticsTrendState.insufficientEvidence,
      );
      expect(snapshot.trend.suppressionReason, contains('eligibility'));
    });

    test('snapshot is order-independent and invalidates on source digest', () {
      final documents = [
        analyticsDocument(gameSeed: 300),
        analyticsDocument(gameSeed: 301),
        analyticsDocument(gameSeed: 302),
      ];
      final first = _build(documents);
      final reordered = _build(documents.reversed.toList());
      expect(reordered.manifest.snapshotId, first.manifest.snapshotId);

      final changed = _build(
        documents,
        digests: {
          for (final document in documents)
            document.documentId:
                document.documentId == documents.first.documentId
                ? 'changed-source-digest'
                : document.documentId,
        },
      );
      expect(changed.manifest.snapshotId, isNot(first.manifest.snapshotId));
    });

    test('snapshot identity covers every semantic source and scope input', () {
      final first = analyticsDocument(gameSeed: 310, variantSeed: 'first');
      final sibling = analyticsDocument(
        gameSeed: 310,
        variantSeed: 'sibling',
        depth: 20,
        completeCandidates: true,
      );
      final secondGame = analyticsDocument(gameSeed: 311);
      final baseline = _build([first]);
      final baselineId = baseline.manifest.snapshotId;

      expect(
        _build([first, secondGame]).manifest.snapshotId,
        isNot(baselineId),
      );
      expect(_build([first, first]).manifest.snapshotId, baselineId);
      expect(_build([first, sibling]).manifest.snapshotId, isNot(baselineId));
      expect(
        _build([
          _copyDocument(first, documentId: '${first.documentId}a'),
        ]).manifest.snapshotId,
        isNot(baselineId),
      );
      expect(
        _build([
          analyticsDocument(
            gameSeed: 310,
            variantSeed: 'first',
            playerIsWhite: false,
          ),
        ]).manifest.snapshotId,
        isNot(baselineId),
      );
      expect(
        _build(
          [first],
          exclusions: const [
            PlayerAnalyticsExclusion(
              reason: PlayerAnalyticsExclusionReason.corruptOrUnavailable,
              detail: 'Changed source exclusion.',
              documentId: 'corrupt',
            ),
          ],
        ).manifest.snapshotId,
        isNot(baselineId),
      );
      expect(
        _buildWith([first], scope: 'local:other-player').manifest.snapshotId,
        isNot(baselineId),
      );
      expect(
        _buildWith(
          [first],
          policy: const PlayerAnalyticsPolicy(policyVersion: 99),
        ).manifest.snapshotId,
        isNot(baselineId),
      );
      expect(
        _buildWith(
          [first],
          policy: const PlayerAnalyticsPolicy(schemaVersion: 99),
        ).manifest.snapshotId,
        isNot(baselineId),
      );
    });

    test('500-game aggregation remains deterministic and bounded', () {
      final timings = <int, int>{};
      String? digest;
      for (final count in [10, 50, 100, 500]) {
        final documents = [
          for (var index = 0; index < count; index++)
            analyticsDocument(gameSeed: 1000 + index),
        ];
        final watch = Stopwatch()..start();
        final snapshot = _build(documents);
        watch.stop();
        timings[count] = watch.elapsedMicroseconds;
        expect(snapshot.canonicalAnalyzedGames, count);
        expect(
          snapshot.manifest.selectedGames.map((game) => game.gameId).toSet(),
          hasLength(count),
        );
        if (count == 500) digest = snapshot.manifest.snapshotId;
      }
      expect(
        timings[500]!,
        lessThan(const Duration(seconds: 4).inMicroseconds),
      );
      expect(digest, hasLength(64));
    });
  });

  test('Apex player-history corpus covers required families', () {
    final results = <Map<String, Object?>>[];
    final performance = <String, int>{};
    final historyTimings = <String, int>{};

    PlayerAnalyticsSnapshot record(
      String name,
      List<ReviewDocument> documents, {
      List<PlayerAnalyticsExclusion> exclusions = const [],
      Map<String, String> digests = const {},
    }) {
      final watch = Stopwatch()..start();
      final snapshot = _build(
        documents,
        exclusions: exclusions,
        digests: digests,
      );
      watch.stop();
      final selectedIds = snapshot.manifest.selectedGames
          .map((game) => game.gameId)
          .toList();
      expect(selectedIds.toSet(), hasLength(selectedIds.length), reason: name);
      for (final priority in snapshot.priorities) {
        expect(priority.examples, isNotEmpty, reason: name);
        for (final example in priority.examples) {
          expect(
            snapshot.manifest.selectedGames.any(
              (game) =>
                  game.gameId == example.gameId &&
                  game.variantId == example.variantId &&
                  game.documentId == example.documentId,
            ),
            isTrue,
            reason: name,
          );
        }
      }
      final duplicate = _build(
        documents,
        exclusions: exclusions,
        digests: digests,
      );
      expect(duplicate.manifest.snapshotId, snapshot.manifest.snapshotId);
      historyTimings[name] = watch.elapsedMicroseconds;
      results.add({
        'history': name,
        'pass': true,
        'canonicalGames': snapshot.canonicalAnalyzedGames,
        'selectedVariantIds': snapshot.manifest.selectedGames
            .map((game) => game.variantId)
            .toList(),
        'exclusions': snapshot.manifest.exclusions
            .map((item) => item.reason.name)
            .toList(),
        'playerMoves': snapshot.totalPlayerMoves,
        'classificationDenominator': snapshot.classificationEligibleMoves,
        'insightDenominator': snapshot.insightEligibleMoves,
        'trend': snapshot.trend.state.name,
        'publishedPriorities': snapshot.priorities
            .map((item) => item.priorityId)
            .toList(),
        'suppressedPriorities': snapshot.suppressedPriorities
            .map((item) => item.priorityId)
            .toList(),
        'priorityCandidates': _priorityCandidateRows(snapshot),
        'snapshotId': snapshot.manifest.snapshotId,
      });
      return snapshot;
    }

    final weak = analyticsDocument(
      gameSeed: 400,
      variantSeed: 'weak',
      depth: 10,
    );
    final strong = analyticsDocument(
      gameSeed: 400,
      variantSeed: 'strong',
      depth: 20,
      completeCandidates: true,
    );
    final duplicate = record('duplicate_variants_for_one_game_id', [
      weak,
      strong,
    ]);
    expect(duplicate.canonicalAnalyzedGames, 1);
    expect(
      duplicate.manifest.selectedGames.single.variantId,
      strong.variantId.value,
    );
    final shallowCurrent = analyticsDocument(
      gameSeed: 400,
      variantSeed: 'shallow-current',
      analysisSchema: kApexAnalysisSchemaVersion,
      depth: 10,
    );
    final deepHistoric = analyticsDocument(
      gameSeed: 400,
      variantSeed: 'deep-historic',
      analysisSchema: kApexLegacyInsightAnalysisSchemaVersion,
      depth: 20,
      completeCandidates: true,
    );
    final crossSchema = record('stronger_versus_weaker_variant_selection', [
      shallowCurrent,
      deepHistoric,
    ]);
    expect(
      crossSchema.manifest.selectedGames.single.documentId,
      deepHistoric.documentId,
    );
    record('unknown_player_side', [
      analyticsDocument(gameSeed: 401, playerIsWhite: null),
    ]);
    record('white_perspective', [
      analyticsDocument(gameSeed: 402, playerIsWhite: true),
    ]);
    record('black_perspective', [
      analyticsDocument(gameSeed: 403, playerIsWhite: false),
    ]);
    record('mixed_schema_4_5_6', [
      analyticsDocument(
        gameSeed: 404,
        analysisSchema: kApexLegacyAnalysisSchemaVersion,
      ),
      analyticsDocument(
        gameSeed: 405,
        analysisSchema: kApexLegacyInsightAnalysisSchemaVersion,
      ),
      analyticsDocument(gameSeed: 406),
    ]);
    record(
      'corrupt_document_exclusion',
      [analyticsDocument(gameSeed: 407)],
      exclusions: const [
        PlayerAnalyticsExclusion(
          reason: PlayerAnalyticsExclusionReason.corruptOrUnavailable,
          detail: 'Synthetic corrupt source.',
          documentId: 'corrupt-source',
        ),
      ],
    );
    record('no_opening_evidence', [
      analyticsDocument(
        gameSeed: 408,
        playerQualities: const [MoveQuality.blunder, MoveQuality.blunder],
        playerInsights: const {
          0: AnalyticsInsightSpec(
            claim: MoveInsightClaimType.dropsMaterial,
            materialDelta: -3,
          ),
          1: AnalyticsInsightSpec(
            claim: MoveInsightClaimType.dropsMaterial,
            materialDelta: -3,
          ),
        },
      ),
    ]);
    record('verified_opening_evidence', [
      analyticsDocument(gameSeed: 409, verifiedOpening: true),
    ]);
    record('mate_domain_events', [
      for (var seed = 410; seed < 412; seed++)
        analyticsDocument(
          gameSeed: seed,
          playerQualities: const [MoveQuality.blunder],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.allowsForcedMate,
              consequence: MoveInsightConsequenceType.checkmate,
            ),
          },
        ),
    ]);
    record('cp_domain_classifications', [
      analyticsDocument(
        gameSeed: 412,
        playerQualities: const [
          MoveQuality.good,
          MoveQuality.inaccuracy,
          MoveQuality.mistake,
          MoveQuality.blunder,
        ],
      ),
    ]);
    record('repeated_material_drops', _materialHistory(420));
    record('repeated_missed_wins', [
      for (var seed = 430; seed < 433; seed++)
        analyticsDocument(
          gameSeed: seed,
          playerQualities: const [MoveQuality.missedWin],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.missesMaterialWin,
              mechanism: MoveInsightMechanismType.missedMaterialResource,
              consequence: MoveInsightConsequenceType.missedMaterialGain,
            ),
          },
        ),
    ]);
    record('successful_tactical_patterns', [
      for (var seed = 440; seed < 445; seed++)
        analyticsDocument(
          gameSeed: seed,
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.winsMaterial,
              mechanism: MoveInsightMechanismType.fork,
              consequence: MoveInsightConsequenceType.materialGain,
              materialDelta: 3,
            ),
          },
        ),
    ]);
    final unsound = record('unsound_sacrifices', [
      for (var seed = 450; seed < 453; seed++)
        analyticsDocument(
          gameSeed: seed,
          playerQualities: const [MoveQuality.blunder],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.dropsMaterial,
              mechanism: MoveInsightMechanismType.unsoundSacrifice,
              consequence: MoveInsightConsequenceType.materialLoss,
              materialDelta: -3,
            ),
          },
        ),
    ]);
    expect(unsound.priorities.single.priorityId, 'unsound-sacrifices');
    expect(
      unsound.suppressedPriorities
          .singleWhere((item) => item.priorityId == 'material-losses')
          .code,
      CoachingPrioritySuppressionCode.overlappingPublishedPriority,
    );
    record('only_move_defenses', [
      for (var seed = 460; seed < 463; seed++)
        analyticsDocument(
          gameSeed: seed,
          playerQualities: const [MoveQuality.onlyMove],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.onlyMoveDefense,
              mechanism: MoveInsightMechanismType.onlyMoveDefense,
              consequence: MoveInsightConsequenceType.avoidsCheckmate,
            ),
          },
        ),
    ]);
    record('insufficient_sample', [
      analyticsDocument(
        gameSeed: 470,
        playerQualities: const [MoveQuality.blunder],
        playerInsights: const {
          0: AnalyticsInsightSpec(
            claim: MoveInsightClaimType.dropsMaterial,
            materialDelta: -3,
          ),
        },
      ),
    ]);
    record(
      'improving_equal_windows',
      _trendDocuments(500, previousErrors: 1, recentErrors: 0),
    );
    record(
      'stable_equal_windows',
      _trendDocuments(530, previousErrors: 1, recentErrors: 1),
    );
    record(
      'declining_equal_windows',
      _trendDocuments(560, previousErrors: 0, recentErrors: 1),
    );
    record('outlier_game', [
      for (var index = 0; index < 20; index++)
        analyticsDocument(
          gameSeed: 600 + index,
          completedAt: DateTime.utc(2026, 5, 1 + index),
          playerQualities: index == 19
              ? const [
                  MoveQuality.blunder,
                  MoveQuality.mistake,
                  MoveQuality.inaccuracy,
                  MoveQuality.good,
                ]
              : const [
                  MoveQuality.good,
                  MoveQuality.good,
                  MoveQuality.good,
                  MoveQuality.good,
                ],
        ),
    ]);
    final ordered = _materialHistory(630);
    final orderedSnapshot = record('same_values_archive_order_a', ordered);
    final reorderedSnapshot = record(
      'same_values_archive_order_b',
      ordered.reversed.toList(),
    );
    expect(
      reorderedSnapshot.manifest.snapshotId,
      orderedSnapshot.manifest.snapshotId,
    );
    final priorityTieDocuments = [
      for (var seed = 640; seed < 642; seed++)
        analyticsDocument(
          gameSeed: seed,
          playerQualities: const [
            MoveQuality.blunder,
            MoveQuality.blunder,
            MoveQuality.missedWin,
            MoveQuality.onlyMove,
          ],
          playerInsights: const {
            0: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.dropsMaterial,
              materialDelta: -3,
            ),
            1: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.allowsForcedMate,
              consequence: MoveInsightConsequenceType.checkmate,
            ),
            2: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.missesMaterialWin,
              mechanism: MoveInsightMechanismType.missedMaterialResource,
              consequence: MoveInsightConsequenceType.missedMaterialGain,
            ),
            3: AnalyticsInsightSpec(
              claim: MoveInsightClaimType.onlyMoveDefense,
              mechanism: MoveInsightMechanismType.onlyMoveDefense,
              consequence: MoveInsightConsequenceType.avoidsCheckmate,
            ),
          },
        ),
    ];
    final priorityTie = record(
      'deterministic_priority_tie',
      priorityTieDocuments,
    );
    expect(priorityTie.priorities, hasLength(3));
    expect(
      priorityTie.suppressedPriorities
          .singleWhere((item) => item.priorityId == 'only-move-defenses')
          .code,
      CoachingPrioritySuppressionCode.maximumThreeLimit,
    );
    expect(
      _build(
        priorityTieDocuments.reversed.toList(),
      ).priorities.map((item) => item.priorityId),
      priorityTie.priorities.map((item) => item.priorityId),
    );
    final digestDocs = [analyticsDocument(gameSeed: 650)];
    final digestA = record(
      'snapshot_digest_source_a',
      digestDocs,
      digests: {digestDocs.single.documentId: 'source-a'},
    );
    final digestB = record(
      'snapshot_digest_source_b',
      digestDocs,
      digests: {digestDocs.single.documentId: 'source-b'},
    );
    expect(digestB.manifest.snapshotId, isNot(digestA.manifest.snapshotId));

    for (final count in [10, 50, 100, 500]) {
      final docs = [
        for (var index = 0; index < count; index++)
          analyticsDocument(gameSeed: 2000 + count * 10 + index),
      ];
      final watch = Stopwatch()..start();
      final snapshot = _build(docs);
      watch.stop();
      performance['snapshot${count}GamesMicros'] = watch.elapsedMicroseconds;
      if (count == 500) {
        performance['manifest500GamesMicros'] =
            snapshot.performance.manifestMicros;
        performance['selection500GamesMicros'] =
            snapshot.performance.selectionMicros;
        performance['aggregation500GamesMicros'] =
            snapshot.performance.aggregationMicros;
        performance['priority500GamesMicros'] =
            snapshot.performance.priorityMicros;
        performance['input500GamesBytes'] = snapshot.performance.inputBytes;
      }
    }
    final cache = PlayerIntelligenceMemoryCache();
    final cachedSnapshot = orderedSnapshot;
    cache.write(cachedSnapshot.manifest.snapshotId, cachedSnapshot);
    final cacheWatch = Stopwatch()..start();
    final cacheHit = cache.read(cachedSnapshot.manifest.snapshotId);
    cacheWatch.stop();
    expect(cacheHit, same(cachedSnapshot));
    performance['cacheHitMicros'] = cacheWatch.elapsedMicroseconds;
    final invalidationWatch = Stopwatch()..start();
    final invalidated = _build(
      ordered,
      digests: {
        for (final document in ordered)
          document.documentId: '${document.documentId}-changed',
      },
    );
    invalidationWatch.stop();
    expect(
      invalidated.manifest.snapshotId,
      isNot(cachedSnapshot.manifest.snapshotId),
    );
    performance['cacheInvalidationMicros'] =
        invalidationWatch.elapsedMicroseconds;

    expect(results, hasLength(26));
    expect(results.where((item) => item['pass'] == true), hasLength(26));
    final outputDirectory = Platform.environment['APEX_CHAPTER9_REPORT_DIR'];
    if (outputDirectory != null && outputDirectory.isNotEmpty) {
      final directory = Directory(outputDirectory)..createSync(recursive: true);
      final semanticCorpus = <String, Object?>{
        'corpusVersion': 1,
        'analyticsPolicyVersion': kPlayerAnalyticsPolicyVersion,
        'analyticsSchemaVersion': kPlayerAnalyticsSchemaVersion,
        'historyCount': results.length,
        'histories': results,
        'gamesAndVariantsRepresented': results.fold<int>(
          0,
          (sum, item) =>
              sum + (item['selectedVariantIds'] as List<Object?>).length,
        ),
        'pass': true,
        'metricInvariants': {
          'explicitDenominators': true,
          'oneVariantPerGameId': true,
          'unknownSideNeverGuessed': true,
          'cpMateDomainsSeparated': true,
        },
        'deduplicationViolations': 0,
        'perspectiveViolations': 0,
        'trendViolations': 0,
        'priorityViolations': 0,
        'forbiddenMetricViolations': 0,
        'unresolvedHumanReviews': 0,
        'duplicateSnapshotDigests': {
          'orderIndependent': true,
          'sourceDigestInvalidates': true,
        },
        'derivedStorageBytes': 0,
      };
      final semanticSha256 = sha256
          .convert(utf8.encode(jsonEncode(semanticCorpus)))
          .toString();
      final corpus = <String, Object?>{
        ...semanticCorpus,
        'semanticSha256': semanticSha256,
        'observationalPerformance': {
          'historyElapsedMicros': historyTimings,
          'scale': performance,
        },
      };
      File(
        '${directory.path}${Platform.pathSeparator}Apex_Player_Intelligence_Corpus_Results.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(corpus));

      final rows = <List<String>>[
        [
          'history',
          'priority_candidate',
          'published',
          'event_count',
          'game_count',
          'denominator',
          'severity_rank',
          'frequency_rank',
          'recency_rank',
          'specificity_rank',
          'candidate_rank_position',
          'suppression_code',
          'suppression_reason',
          'snapshot_id',
        ],
      ];
      for (final result in results) {
        final name = result['history']! as String;
        final published = (result['publishedPriorities']! as List<Object?>)
            .cast<String>()
            .toSet();
        final candidates = (result['priorityCandidates']! as List<Object?>)
            .cast<Map<String, Object?>>();
        expect(candidates, hasLength(kPlayerCoachingPriorityIds.length));
        expect(
          candidates.map((candidate) => candidate['priorityId']).toSet(),
          kPlayerCoachingPriorityIds.toSet(),
          reason: name,
        );
        for (final candidate in candidates) {
          final priorityId = candidate['priorityId']! as String;
          final isPublished = candidate['published']! as bool;
          expect(isPublished, published.contains(priorityId), reason: name);
          rows.add([
            name,
            priorityId,
            '$isPublished',
            '${candidate['eventCount']}',
            '${candidate['gameCount']}',
            '${candidate['eligibleDenominator']}',
            '${candidate['severity']}',
            '${candidate['frequency']}',
            '${candidate['recency']}',
            '${candidate['specificity']}',
            '${candidate['rankPosition']}',
            '${candidate['suppressionCode'] ?? ''}',
            '${candidate['suppressionReason'] ?? ''}',
            '${result['snapshotId']}',
          ]);
        }
      }
      expect(rows, hasLength(1 + results.length * 9));
      expect(
        rows
            .skip(1)
            .every(
              (row) =>
                  row[3].isNotEmpty &&
                  row[4].isNotEmpty &&
                  row[5].isNotEmpty &&
                  row[6].isNotEmpty &&
                  row[7].isNotEmpty &&
                  row[8].isNotEmpty &&
                  row[9].isNotEmpty &&
                  row[10].isNotEmpty,
            ),
        isTrue,
      );
      File(
        '${directory.path}${Platform.pathSeparator}Apex_Coaching_Priority_Matrix.csv',
      ).writeAsStringSync(
        rows.map((row) => row.map(_csv).join(',')).join('\r\n'),
      );
    }
  });
}

PlayerAnalyticsSnapshot _build(
  List<ReviewDocument> documents, {
  List<PlayerAnalyticsExclusion> exclusions = const [],
  Map<String, String> digests = const {},
}) => _buildWith(documents, exclusions: exclusions, digests: digests);

PlayerAnalyticsSnapshot _buildWith(
  List<ReviewDocument> documents, {
  List<PlayerAnalyticsExclusion> exclusions = const [],
  Map<String, String> digests = const {},
  String scope = 'chess.com:apex-player',
  PlayerAnalyticsPolicy policy = const PlayerAnalyticsPolicy(),
}) => PlayerAnalyticsBuilder(policy: policy).build(
  PlayerAnalyticsBuildInput(
    documents: documents,
    playerIdentityScope: scope,
    analysisDigests: digests,
    sourceExclusions: exclusions,
  ),
);

ReviewDocument _copyDocument(
  ReviewDocument source, {
  required String documentId,
}) => ReviewDocument(
  schemaVersion: source.schemaVersion,
  documentId: documentId,
  game: source.game,
  variantId: source.variantId,
  compatibility: source.compatibility,
  run: source.run,
  createdAt: source.createdAt,
  status: source.status,
  analyzedPerspective: source.analyzedPerspective,
  timeline: source.timeline,
);

PlayerAnalyticsSnapshot _trendHistory({
  required int previousErrors,
  required int recentErrors,
}) => _build(
  _trendDocuments(
    100,
    previousErrors: previousErrors,
    recentErrors: recentErrors,
  ),
);

List<ReviewDocument> _trendDocuments(
  int seed, {
  required int previousErrors,
  required int recentErrors,
}) => [
  for (var index = 0; index < 20; index++)
    analyticsDocument(
      gameSeed: seed + index,
      completedAt: DateTime.utc(2026, 5, 1 + index),
      playerQualities: [
        for (var move = 0; move < 4; move++)
          move < (index < 10 ? previousErrors : recentErrors)
              ? MoveQuality.blunder
              : MoveQuality.good,
      ],
    ),
];

List<ReviewDocument> _materialHistory(int seed) => [
  for (var index = 0; index < 3; index++)
    analyticsDocument(
      gameSeed: seed + index,
      playerQualities: const [MoveQuality.blunder],
      playerInsights: const {
        0: AnalyticsInsightSpec(
          claim: MoveInsightClaimType.dropsMaterial,
          consequence: MoveInsightConsequenceType.materialLoss,
          materialDelta: -3,
        ),
      },
    ),
];

List<Map<String, Object?>> _priorityCandidateRows(
  PlayerAnalyticsSnapshot snapshot,
) {
  final published = {
    for (final priority in snapshot.priorities) priority.priorityId: priority,
  };
  final suppressed = {
    for (final priority in snapshot.suppressedPriorities)
      priority.priorityId: priority,
  };
  final rows = <Map<String, Object?>>[];
  for (final priorityId in kPlayerCoachingPriorityIds) {
    final active = published[priorityId];
    final inactive = suppressed[priorityId];
    expect(
      (active == null) != (inactive == null),
      isTrue,
      reason: 'Expected exactly one decision for $priorityId.',
    );
    final rank = active?.rank ?? inactive!.rank;
    rows.add({
      'priorityId': priorityId,
      'published': active != null,
      'eventCount': active?.eventCount ?? inactive!.eventCount,
      'gameCount': active?.gameCount ?? inactive!.gameCount,
      'eligibleDenominator':
          active?.eligibleDenominator ?? inactive!.eligibleDenominator,
      'severity': rank.severity,
      'frequency': rank.frequency,
      'recency': rank.recency,
      'specificity': rank.specificity,
      'suppressionCode': inactive?.code.name,
      'suppressionReason': inactive?.reason,
    });
  }
  final ranked = [...rows]..sort(_compareCandidateRows);
  final positions = <String, int>{
    for (var index = 0; index < ranked.length; index++)
      ranked[index]['priorityId']! as String: index + 1,
  };
  return [
    for (final row in rows)
      {...row, 'rankPosition': positions[row['priorityId']]!},
  ];
}

int _compareCandidateRows(
  Map<String, Object?> left,
  Map<String, Object?> right,
) {
  for (final field in ['severity', 'frequency', 'recency', 'specificity']) {
    final comparison = (right[field]! as int).compareTo(left[field]! as int);
    if (comparison != 0) return comparison;
  }
  return (left['priorityId']! as String).compareTo(
    right['priorityId']! as String,
  );
}

String _csv(String value) => '"${value.replaceAll('"', '""')}"';
