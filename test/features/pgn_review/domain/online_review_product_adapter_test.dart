import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/domain/online_review_product_adapter.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adapter = OnlineReviewProductAdapter();

  group('OnlineReviewProductAdapter fixture mapping', () {
    test('maps minimal success into app-domain review', () {
      final review = _review('success/success_fast_minimal.json');

      expect(review.contractVersion, onlineReviewProductContractVersion);
      expect(review.mode, ApexOnlineReviewMode.onlineFast);
      expect(review.status, ApexReviewStatus.completed);
      expect(review.isSuccess, isTrue);
      expect(review.isPartial, isFalse);
      expect(review.isFailed, isFalse);
      expect(review.headers!.white, 'Faisal');
      expect(review.headers!.black, 'Opponent');
      expect(review.headers!.hasPlayers, isTrue);
      expect(review.summary.totalPlies, 1);
      expect(review.summary.analyzedMoves, 1);
      expect(
        review.providerInfo.productContractVersion,
        review.contractVersion,
      );
      expect(review.providerInfo.mode, ApexOnlineReviewMode.onlineFast);
      expect(review.moves, hasLength(1));
      expect(review.moves.single.quality, ApexMoveQuality.best);
      expect(review.moves.single.confidence, ApexReviewConfidence.high);
      expect(review.moves.single.hasBetterMove, isFalse);
      expect(review.moves.single.hasEngineLine, isTrue);
      expect(review.failure, isNull);
    });

    test('maps better move object and preserves confidence/source', () {
      final review = _review('success/success_fast_with_better_move.json');
      final move = review.moves.single;

      expect(move.quality, ApexMoveQuality.mistake);
      expect(move.isBadMove, isTrue);
      expect(move.isStrongMove, isFalse);
      expect(move.hasBetterMove, isTrue);
      expect(move.betterMove!.moveUci, 'e7e5');
      expect(move.betterMove!.san, isNull);
      expect(move.betterMove!.source, 'enginePrimary');
      expect(move.betterMove!.confidence, ApexReviewConfidence.low);
      expect(move.engineLine!.bestMoveUci, 'e7e5');
      expect(move.engineLine!.score!.scoreType, 'cp');
    });

    test('maps criticality and highlight flags', () {
      final review = _review('success/success_deep_with_criticality.json');
      final move = review.moves.single;

      expect(review.mode, ApexOnlineReviewMode.onlineDeep);
      expect(review.providerInfo.targetDepthTier, 'deep');
      expect(move.criticalityLevel, ApexCriticalityLevel.high);
      expect(move.isCritical, isTrue);
      expect(move.shouldHighlight, isTrue);
    });

    test('maps mate warning and warning strings unchanged', () {
      final review = _review('success/success_with_mate_warning.json');
      final move = review.moves.single;

      expect(move.hasMateWarning, isTrue);
      expect(move.hasWarning, isTrue);
      expect(move.warnings, contains('mateSensitive'));
      expect(move.shouldHighlight, isTrue);
    });

    test('maps partial analysis without engine-line crashes', () {
      final review = _review('success/success_partial_analysis.json');

      expect(review.status, ApexReviewStatus.partial);
      expect(review.isPartial, isTrue);
      expect(review.isFailed, isFalse);
      expect(review.summary.failedMoves, 2);
      expect(review.moves, hasLength(2));
      expect(review.moves.every((move) => move.engineLine == null), isTrue);
      expect(
        review.moves.every(
          (move) => move.warnings.contains('engineDataIncomplete'),
        ),
        isTrue,
      );
    });

    test('maps invalid PGN failure safely', () {
      final review = _review('failure/failure_invalid_pgn.json');

      expect(review.status, ApexReviewStatus.failed);
      expect(review.isFailed, isTrue);
      expect(review.isSuccess, isFalse);
      expect(review.moves, isEmpty);
      expect(review.failure!.code, 'invalidPgn');
      expect(review.failure!.message, 'Invalid PGN');
      expect(review.debugInfo, isNull);
    });

    test('maps compact debug info only', () {
      final review = _review('debug/debug_enabled_compact.json');
      final debug = review.debugInfo!;

      expect(review.hasDebug, isTrue);
      expect(debug.enabled, isTrue);
      expect(debug.sourceEndpoint, '/analysis/dev/review-draft');
      expect(debug.omittedInternalSections, isNotEmpty);
      expect(debug.omittedInternalSections, contains('reanalysisEnvelope'));
      expect(debug.internalSafetySummary!.ledgerPersistent, isFalse);
      expect(debug.internalSafetySummary!.runtimeMigrationReady, isFalse);
    });

    test('maps every copied fixture through DTO into domain', () {
      for (final fixture in _productFixturePaths) {
        final review = adapter.fromDto(_dto(fixture));

        expect(review.contractVersion, onlineReviewProductContractVersion);
        expect(review.moves, isA<List<ApexReviewedMove>>());
        expect(review.summary.accuracy, isNull);
        expect(review.summary.acpl, isNull);
      }
    });
  });

  group('OnlineReviewProductAdapter safety', () {
    test('preserves DTO enum fallback values in domain mapping', () {
      final json = _fixtureJson('success/success_fast_minimal.json');
      final move = (json['moves']! as List<Object?>).first as Map;
      json['mode'] = 'futureMode';
      json['status'] = 'futureStatus';
      json['providerMetadata']! as Map
        ..['mode'] = 'futureMode'
        ..['targetDepthTier'] = 'futureTier';
      move['quality'] = 'futureQuality';
      move['confidence'] = 'futureConfidence';
      move['criticalityLevel'] = 'futureCriticality';
      move['warnings'] = ['futureWarning'];

      final review = adapter.fromDto(
        OnlineReviewProductResponseDto.fromJson(json),
      );

      expect(review.mode, ApexOnlineReviewMode.dev);
      expect(review.status, ApexReviewStatus.failed);
      expect(review.providerInfo.mode, ApexOnlineReviewMode.dev);
      expect(review.providerInfo.targetDepthTier, 'futureTier');
      expect(review.moves.single.quality, ApexMoveQuality.unclassified);
      expect(review.moves.single.confidence, ApexReviewConfidence.unknown);
      expect(review.moves.single.criticalityLevel, ApexCriticalityLevel.none);
      expect(review.moves.single.warnings, contains('futureWarning'));
    });

    test('ignores extra internal fields already ignored by DTO parsing', () {
      final json = _fixtureJson('success/success_fast_minimal.json');
      final move = (json['moves']! as List<Object?>).first as Map;
      json['classifierExperimentLedger'] = {'isPersistent': false};
      json['classifierLedgerSchemaReviewContract'] = {
        'migrationAllowed': false,
      };
      json['reanalysisEnvelope'] = {'requests': []};
      move['classifierV2DryRun'] = {'proposedQuality': 'Miss'};
      move['multiPvBefore'] = [];
      move['mergeProposal'] = {'wouldChangeQuality': false};

      final review = adapter.fromDto(
        OnlineReviewProductResponseDto.fromJson(json),
      );

      expect(review.moves.single.quality, ApexMoveQuality.best);
      expect(review.moves.single.hasEngineLine, isTrue);
    });

    test(
      'defensively copies DTO collections into immutable domain collections',
      () {
        final dto = _dto('success/success_fast_with_better_move.json');
        final review = adapter.fromDto(dto);

        dto.moves.clear();
        dto.summary.qualityCounts['blunder'] = 99;

        expect(review.moves, hasLength(1));
        expect(review.summary.qualityCounts['blunder'], 0);
        expect(
          () => review.moves.add(review.moves.single),
          throwsUnsupportedError,
        );
        expect(
          () => review.summary.qualityCounts['blunder'] = 10,
          throwsUnsupportedError,
        );
        expect(
          () => review.moves.single.warnings.add('mutated'),
          throwsUnsupportedError,
        );
      },
    );

    test(
      'domain and adapter sources do not import provider or network layers',
      () {
        final adapterSource = File(
          'lib/features/pgn_review/domain/online_review_product_adapter.dart',
        ).readAsStringSync();
        final domainSource = File(
          'lib/features/pgn_review/domain/online_review_product_domain.dart',
        ).readAsStringSync();
        final combined = '$adapterSource\n$domainSource';

        expect(combined, isNot(contains('http_online_review_provider')));
        expect(combined, isNot(contains('package:http')));
        expect(combined, isNot(contains('flutter_riverpod')));
        expect(combined, isNot(contains('package:riverpod')));
        expect(combined, isNot(contains('ProviderContainer')));
      },
    );

    test('domain enums do not include advanced labels or official metrics', () {
      final qualities = ApexMoveQuality.values.map((value) => value.wire);

      expect(qualities, isNot(contains('Brilliant')));
      expect(qualities, isNot(contains('Miss')));
      expect(qualities, isNot(contains('Great')));
      expect(qualities, isNot(contains('Book')));
      expect(qualities, isNot(contains('Forced')));
      for (final fixture in _productFixturePaths) {
        final review = _review(fixture);
        expect(review.summary.accuracy, isNull);
        expect(review.summary.acpl, isNull);
      }
    });
  });
}

const _fixtureRoot = 'test/fixtures/online_review_product';

const _productFixturePaths = [
  'success/success_fast_minimal.json',
  'success/success_fast_with_better_move.json',
  'success/success_deep_with_criticality.json',
  'success/success_with_mate_warning.json',
  'success/success_partial_analysis.json',
  'failure/failure_invalid_pgn.json',
  'debug/debug_enabled_compact.json',
];

ApexOnlineReview _review(String path) {
  return const OnlineReviewProductAdapter().fromDto(_dto(path));
}

OnlineReviewProductResponseDto _dto(String path) {
  return OnlineReviewProductResponseDto.fromJson(_fixtureJson(path));
}

Map<String, Object?> _fixtureJson(String path) {
  final raw = File('$_fixtureRoot/$path').readAsStringSync();
  final decoded = jsonDecode(raw);
  return (decoded as Map).map((key, value) => MapEntry(key.toString(), value));
}
