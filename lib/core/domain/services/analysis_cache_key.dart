/// Stable analysis cache identity.
library;

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';

String normalizedPgnForHash(String pgn) {
  return pgn
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n')
      .trim();
}

/// Stable FNV-1a 32-bit hash, independent of Dart VM `String.hashCode`.
String stablePgnHash(String pgn) {
  const fnvPrime = 0x01000193;
  var hash = 0x811c9dc5;
  for (final unit in normalizedPgnForHash(pgn).codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

String buildAnalysisCacheKey({
  required String pgnHash,
  required AnalysisProfileId analysisProfileId,
  required String providerId,
  required String engineVersion,
  int classifierVersion = kApexClassifierVersion,
  int tacticalVerifierVersion = kApexTacticalVerifierVersion,
  int openingBookVersion = kApexOpeningBookVersion,
}) {
  return [
    pgnHash,
    analysisProfileId.wire,
    providerId,
    'engine=$engineVersion',
    'classifier=$classifierVersion',
    'tactical=$tacticalVerifierVersion',
    'opening=$openingBookVersion',
  ].join('|');
}
