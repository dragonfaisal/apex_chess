/// Flutter asset-I/O adapter for the pure-Dart opening index.
library;

import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

class OpeningAssetLoader {
  OpeningAssetLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static Future<OpeningIndex> loadFromAssetBundle(
    AssetBundle bundle, {
    String sourcePath = 'assets/openings/eco.tsv',
    String manifestPath = 'assets/openings/eco.provenance.json',
  }) => OpeningAssetLoader(
    bundle: bundle,
  ).load(sourcePath: sourcePath, manifestPath: manifestPath);

  final AssetBundle _bundle;

  Future<OpeningIndex> load({
    String sourcePath = 'assets/openings/eco.tsv',
    String manifestPath = 'assets/openings/eco.provenance.json',
  }) async {
    final Map<String, dynamic> manifest;
    try {
      final raw = await _bundle.loadString(manifestPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Opening manifest is not an object.');
      }
      manifest = decoded;
      _validateManifest(manifest);
    } on FormatException {
      return OpeningIndex.unavailable(
        verification: OpeningArtifactVerification.malformedManifest,
        reasonCode: 'opening_manifest_malformed',
      );
    } on Object {
      return OpeningIndex.unavailable(
        reasonCode: 'opening_manifest_unavailable',
      );
    }

    final String source;
    try {
      source = await _bundle.loadString(sourcePath);
    } on Object {
      return OpeningIndex.unavailable(reasonCode: 'opening_source_unavailable');
    }
    final OpeningIndex index;
    try {
      index = await Isolate.run(
        () => OpeningIndex.fromTsv(
          source,
          identity: kApexOpeningArtifactIdentity,
          buildTimestamp: DateTime.now().toUtc(),
        ),
      );
    } on Object {
      return OpeningIndex.unavailable(
        verification: OpeningArtifactVerification.invalidData,
        reasonCode: 'opening_index_build_failed',
      );
    }
    if (!index.isAvailable) return index;
    if (index.metrics.sourceRows != manifest['sourceRowCount'] ||
        index.metrics.indexedPositions != manifest['indexedPositionCount'] ||
        index.metrics.indexedTransitions !=
            manifest['indexedTransitionCount'] ||
        index.metrics.maximumPly != manifest['maximumIndexedPly']) {
      return OpeningIndex.unavailable(
        verification: OpeningArtifactVerification.invalidData,
        reasonCode: 'opening_manifest_metric_mismatch',
      );
    }
    return index;
  }
}

void _validateManifest(Map<String, dynamic> manifest) {
  final license = manifest['license'];
  final timestamp = manifest['buildTimestamp'];
  if (manifest['manifestSchemaVersion'] != 1 ||
      manifest['artifactSchemaVersion'] !=
          kApexOpeningArtifactIdentity.schemaVersion ||
      manifest['openingPolicyVersion'] !=
          kApexOpeningArtifactIdentity.openingPolicyVersion ||
      manifest['datasetName'] != kApexOpeningArtifactIdentity.datasetName ||
      manifest['sourceRevision'] !=
          kApexOpeningArtifactIdentity.sourceRevision ||
      manifest['sourceSha256'] != kApexOpeningArtifactIdentity.sourceSha256 ||
      manifest['canonicalIndexContentSha256'] !=
          kApexOpeningArtifactIdentity.contentSha256 ||
      manifest['buildTimestampIsIdentity'] != false ||
      timestamp is! String ||
      DateTime.tryParse(timestamp) == null ||
      license is! Map<String, dynamic> ||
      license['spdx'] != kApexOpeningArtifactIdentity.licenseSpdx ||
      license['licenseFile'] != 'assets/openings/CC0-1.0.txt') {
    throw const FormatException('Opening manifest contract mismatch.');
  }
}
