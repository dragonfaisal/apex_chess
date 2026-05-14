import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/domain/online_review_product_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DTO field matrix matches Flutter enum wires', () {
    final matrix = _fixtureJson('dto_alignment/dto_field_matrix.json');
    final models = (matrix['models']! as Map).map(
      (key, value) => MapEntry(key.toString(), value as Map),
    );

    expect(matrix['contractVersion'], onlineReviewProductContractVersion);
    expect(
      _stringList(models['OnlineReviewProductResponse']!['enum']['mode']),
      OnlineReviewMode.values.map((value) => value.wire),
    );
    expect(
      _stringList(models['OnlineReviewProductResponse']!['enum']['status']),
      OnlineReviewProductStatus.values.map((value) => value.wire),
    );
    expect(
      _stringList(models['OnlineReviewMove']!['enum']['quality']),
      OnlineReviewMoveQuality.values.map((value) => value.wire),
    );
    expect(
      _stringList(models['OnlineReviewMove']!['enum']['confidence']),
      OnlineReviewConfidence.values.map((value) => value.wire),
    );
    expect(
      _stringList(models['OnlineReviewMove']!['enum']['criticalityLevel']),
      OnlineReviewCriticalityLevel.values.map((value) => value.wire),
    );
    expect(
      _stringList(matrix['warningStrings']),
      containsAll([
        'engineDataIncomplete',
        'lowConfidence',
        'mateSensitive',
        'reanalysisUnavailable',
        'partialAnalysis',
      ]),
    );
  });

  test('copied fixtures cover DTO-ready product scenarios', () {
    final minimal = _dto('success/success_fast_minimal.json');
    final betterMove = _dto('success/success_fast_with_better_move.json');
    final critical = _dto('success/success_deep_with_criticality.json');
    final mate = _dto('success/success_with_mate_warning.json');
    final partial = _dto('success/success_partial_analysis.json');
    final failure = _dto('failure/failure_invalid_pgn.json');
    final debug = _dto('debug/debug_enabled_compact.json');

    expect(minimal.mode, OnlineReviewMode.onlineFast);
    expect(minimal.moves.single.betterMove, isNull);
    expect(betterMove.moves.single.betterMove!.moveUci, 'e7e5');
    expect(critical.mode, OnlineReviewMode.onlineDeep);
    expect(critical.moves.single.isCritical, isTrue);
    expect(mate.moves.single.hasMateWarning, isTrue);
    expect(partial.status, OnlineReviewProductStatus.partial);
    expect(partial.moves.every((move) => move.engineLine == null), isTrue);
    expect(failure.status, OnlineReviewProductStatus.failed);
    expect(failure.error!.code, 'invalidPgn');
    expect(debug.debug!.omittedInternalSections, isNotEmpty);
  });

  test('forbidden field fixture is not represented by DTO output', () {
    final forbidden = _fixtureJson('forbidden_internal_fields.json');
    final forbiddenKeys = _stringList(
      forbidden['defaultForbiddenKeys'],
    ).toSet();
    final debugAllowed = _stringList(
      forbidden['debugAllowedStringOnly'],
    ).toSet();
    final debug = _dto('debug/debug_enabled_compact.json');
    final product = _dto('success/success_fast_with_better_move.json');

    expect(debug.debug!.omittedInternalSections.toSet(), debugAllowed);
    expect(_allKeys(product.toJson()).intersection(forbiddenKeys), isEmpty);
    expect(_allKeys(debug.toJson()).intersection(forbiddenKeys), isEmpty);
  });
}

const _fixtureRoot = 'test/fixtures/online_review_product';

OnlineReviewProductResponseDto _dto(String path) {
  return OnlineReviewProductResponseDto.fromJson(_fixtureJson(path));
}

Map<String, Object?> _fixtureJson(String path) {
  final raw = File('$_fixtureRoot/$path').readAsStringSync();
  final decoded = jsonDecode(raw);
  return (decoded as Map).map((key, value) => MapEntry(key.toString(), value));
}

List<String> _stringList(Object? value) {
  final list = value as List;
  return [for (final item in list) item.toString()];
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
