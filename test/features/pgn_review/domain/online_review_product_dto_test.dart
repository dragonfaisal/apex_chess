import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/domain/online_review_product_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('online-review-product-v1 DTO fixtures', () {
    test('parses all stable backend product fixtures', () {
      for (final path in _productFixturePaths) {
        final dto = _fixture(path);

        expect(dto.contractVersion, onlineReviewProductContractVersion);
        expect(dto.moves, isA<List<OnlineReviewMoveDto>>());
        expect(
          dto.providerMetadata.productContractVersion,
          dto.contractVersion,
        );
      }
    });

    test('parses success, partial, failure, and debug states safely', () {
      final minimal = _fixture('success/success_fast_minimal.json');
      final partial = _fixture('success/success_partial_analysis.json');
      final failure = _fixture('failure/failure_invalid_pgn.json');
      final debug = _fixture('debug/debug_enabled_compact.json');

      expect(minimal.ok, isTrue);
      expect(minimal.mode, OnlineReviewMode.onlineFast);
      expect(minimal.status, OnlineReviewProductStatus.completed);
      expect(minimal.summary.totalPlies, 1);
      expect(minimal.debug, isNull);
      expect(minimal.error, isNull);

      expect(partial.ok, isTrue);
      expect(partial.status, OnlineReviewProductStatus.partial);
      expect(partial.summary.failedMoves, 2);
      expect(partial.moves, hasLength(2));
      expect(partial.moves.every((move) => move.engineLine == null), isTrue);

      expect(failure.ok, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.status, OnlineReviewProductStatus.failed);
      expect(failure.moves, isEmpty);
      expect(failure.error!.code, 'invalidPgn');
      expect(failure.error!.message, 'Invalid PGN');
      expect(failure.debug, isNull);

      expect(debug.hasDebug, isTrue);
      expect(debug.debug!.enabled, isTrue);
      expect(debug.debug!.sourceEndpoint, '/analysis/dev/review-draft');
      expect(debug.debug!.omittedInternalSections, isNotEmpty);
      expect(debug.debug!.internalSafetySummary!.ledgerPersistent, isFalse);
      expect(
        debug.debug!.internalSafetySummary!.runtimeMigrationReady,
        isFalse,
      );
    });

    test(
      'parses move quality, confidence, criticality, better move, and score',
      () {
        final betterMove = _fixture(
          'success/success_fast_with_better_move.json',
        ).moves.single;
        final critical = _fixture(
          'success/success_deep_with_criticality.json',
        ).moves.single;

        expect(betterMove.quality, OnlineReviewMoveQuality.mistake);
        expect(betterMove.confidence, OnlineReviewConfidence.low);
        expect(betterMove.criticalityLevel, OnlineReviewCriticalityLevel.high);
        expect(betterMove.hasBetterMove, isTrue);
        expect(betterMove.betterMove!.moveUci, 'e7e5');
        expect(betterMove.betterMove!.san, isNull);
        expect(betterMove.betterMove!.source, 'enginePrimary');
        expect(betterMove.hasEngineLine, isTrue);
        expect(betterMove.engineLine!.bestMoveUci, 'e7e5');
        expect(betterMove.engineLine!.score!.scoreType, 'cp');
        expect(betterMove.engineLine!.pv, isNotEmpty);

        expect(critical.quality, OnlineReviewMoveQuality.mistake);
        expect(critical.isCritical, isTrue);
        expect(critical.isCriticalOrTactical, isTrue);
      },
    );

    test('parses mate warning and preserves warning strings', () {
      final move = _fixture(
        'success/success_with_mate_warning.json',
      ).moves.single;

      expect(move.hasMateWarning, isTrue);
      expect(move.hasWarnings, isTrue);
      expect(move.warnings, contains('mateSensitive'));
      expect(move.warnings, contains('lowConfidence'));
    });

    test('round-trips product-critical fields through JSON', () {
      final original = _fixture('success/success_fast_with_better_move.json');
      final encoded = original.toJson();
      final reparsed = OnlineReviewProductResponseDto.fromJson(encoded);

      expect(reparsed.contractVersion, original.contractVersion);
      expect(reparsed.mode, original.mode);
      expect(reparsed.status, original.status);
      expect(reparsed.summary.totalPlies, original.summary.totalPlies);
      expect(reparsed.summary.qualityCounts, original.summary.qualityCounts);
      expect(reparsed.moves, hasLength(original.moves.length));
      expect(reparsed.moves.first.quality, original.moves.first.quality);
      expect(
        reparsed.moves.first.betterMove!.moveUci,
        original.moves.first.betterMove!.moveUci,
      );
      expect(
        reparsed.providerMetadata.productContractVersion,
        onlineReviewProductContractVersion,
      );
    });
  });

  group('online-review-product-v1 DTO safety', () {
    test('unknown enum strings fall back safely', () {
      expect(
        OnlineReviewMoveQuality.fromJson('futureBrilliant'),
        OnlineReviewMoveQuality.unclassified,
      );
      expect(
        OnlineReviewConfidence.fromJson('futureCertain'),
        OnlineReviewConfidence.unknown,
      );
      expect(
        OnlineReviewCriticalityLevel.fromJson('futureExtreme'),
        OnlineReviewCriticalityLevel.none,
      );
      expect(OnlineReviewMode.fromJson('futureMode'), OnlineReviewMode.dev);
      expect(
        OnlineReviewProductStatus.fromJson('futureStatus'),
        OnlineReviewProductStatus.failed,
      );
    });

    test('unknown warning strings are preserved', () {
      final json = _fixtureJson('success/success_fast_minimal.json');
      final move = (json['moves']! as List<Object?>).first as Map;
      move['warnings'] = ['reanalysisUnavailable', 'futureBackendWarning'];

      final dto = OnlineReviewProductResponseDto.fromJson(json);

      expect(dto.moves.single.warnings, contains('futureBackendWarning'));
      expect(dto.moves.single.warnings, contains('reanalysisUnavailable'));
    });

    test('nullable product fields can be absent or null without crashes', () {
      final json = _fixtureJson('failure/failure_invalid_pgn.json')
        ..remove('gameKey')
        ..remove('headers')
        ..remove('debug')
        ..remove('error');

      final dto = OnlineReviewProductResponseDto.fromJson(json);

      expect(dto.gameKey, isNull);
      expect(dto.headers, isNull);
      expect(dto.debug, isNull);
      expect(dto.error, isNull);
      expect(dto.moves, isEmpty);
    });

    test('extra internal backend fields are ignored and not re-emitted', () {
      final json = _fixtureJson('success/success_fast_minimal.json');
      final moves = json['moves']! as List<Object?>;
      json['classifierExperimentLedger'] = {'isPersistent': false};
      json['classifierLedgerSchemaReviewContract'] = {
        'migrationAllowed': false,
      };
      json['reanalysisEnvelope'] = {'requests': []};
      (moves.first as Map)['classifierV2DryRun'] = {'proposedQuality': 'Miss'};
      (moves.first as Map)['multiPvBefore'] = [];
      (moves.first as Map)['mergeProposal'] = {'wouldChangeQuality': false};

      final dto = OnlineReviewProductResponseDto.fromJson(json);
      final output = dto.toJson();
      final keys = _allKeys(output);

      for (final key in _forbiddenInternalKeys) {
        expect(keys, isNot(contains(key)));
      }
    });

    test('advanced labels and official accuracy calculations are absent', () {
      final enumWires = OnlineReviewMoveQuality.values.map(
        (value) => value.wire,
      );
      final payloads = _productFixturePaths.map(_fixture);

      expect(enumWires, isNot(contains('Brilliant')));
      expect(enumWires, isNot(contains('Great')));
      expect(enumWires, isNot(contains('Miss')));
      expect(enumWires, isNot(contains('Book')));
      expect(enumWires, isNot(contains('Forced')));
      for (final payload in payloads) {
        expect(payload.summary.accuracy, isNull);
        expect(payload.summary.acpl, isNull);
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

const _forbiddenInternalKeys = {
  'classifierMergeBackPolicy',
  'classifierMergeBackSimulation',
  'classifierMergeBackReadiness',
  'classifierMergeBackApproval',
  'classifierExperimentLedger',
  'classifierLedgerStorageContract',
  'classifierLedgerSchemaReviewContract',
  'classifierLedgerSchemaApprovalValidation',
  'classifierLedgerMigrationGovernanceHandoff',
  'reanalysisEnvelope',
  'reanalysisExecution',
  'reanalysisShadow',
  'mergeProposal',
  'classifierV2DryRun',
  'classifierV2Eligibility',
  'multiPvBefore',
  'multiPvAfter',
  'engineAlternatives',
};

OnlineReviewProductResponseDto _fixture(String path) {
  return OnlineReviewProductResponseDto.fromJson(_fixtureJson(path));
}

Map<String, Object?> _fixtureJson(String path) {
  final raw = File('$_fixtureRoot/$path').readAsStringSync();
  final decoded = jsonDecode(raw);
  return (decoded as Map).map((key, value) => MapEntry(key.toString(), value));
}

Set<String> _allKeys(Object? value) {
  if (value is Map) {
    return {
      for (final key in value.keys) key.toString(),
      for (final child in value.values) ..._allKeys(child),
    };
  }
  if (value is List) {
    return {for (final child in value) ..._allKeys(child)};
  }
  return const {};
}
