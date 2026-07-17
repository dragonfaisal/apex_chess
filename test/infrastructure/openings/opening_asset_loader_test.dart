import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/infrastructure/openings/opening_asset_loader.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rootBundle packages source, manifest, and license', () async {
    final index = await OpeningAssetLoader().load();
    final license = await rootBundle.loadString('assets/openings/CC0-1.0.txt');

    expect(index.verification, OpeningArtifactVerification.verified);
    expect(index.identity, kApexOpeningArtifactIdentity);
    expect(index.metrics.sourceRows, 3690);
    expect(index.buildTimestamp, isNotNull);
    expect(license, contains('CC0 1.0 Universal'));
  });

  test('missing source remains explicitly unavailable', () async {
    final manifest = await io.File(
      'assets/openings/eco.provenance.json',
    ).readAsString();
    final index = await OpeningAssetLoader.loadFromAssetBundle(
      _StringAssetBundle(<String, String>{
        'assets/openings/eco.provenance.json': manifest,
      }),
    );

    expect(index.verification, OpeningArtifactVerification.unavailable);
    expect(index.unavailableReasonCode, 'opening_source_unavailable');
    expect(index.identity, kApexOpeningArtifactIdentity);
  });

  test('malformed manifest never becomes an empty successful index', () async {
    final index = await OpeningAssetLoader.loadFromAssetBundle(
      _StringAssetBundle(<String, String>{
        'assets/openings/eco.provenance.json': '{not-json',
        'assets/openings/eco.tsv': 'eco\tname\tpgn\n',
      }),
    );

    expect(index.verification, OpeningArtifactVerification.malformedManifest);
    expect(index.unavailableReasonCode, 'opening_manifest_malformed');
    expect(index.isAvailable, isFalse);
  });

  test('wrong source bytes fail with hashMismatch', () async {
    final manifest = await io.File(
      'assets/openings/eco.provenance.json',
    ).readAsString();
    final index = await OpeningAssetLoader.loadFromAssetBundle(
      _StringAssetBundle(<String, String>{
        'assets/openings/eco.provenance.json': manifest,
        'assets/openings/eco.tsv': 'eco\tname\tpgn\nB00\tKing Pawn\t1. e4\n',
      }),
    );

    expect(index.verification, OpeningArtifactVerification.hashMismatch);
    expect(index.unavailableReasonCode, 'opening_artifact_hash_mismatch');
    expect(index.isAvailable, isFalse);
  });
}

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.values);

  final Map<String, String> values;

  @override
  Future<ByteData> load(String key) async {
    final value = values[key];
    if (value == null) throw StateError('Missing test asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}
