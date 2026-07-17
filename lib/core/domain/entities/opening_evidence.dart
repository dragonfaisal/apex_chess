/// Immutable, provider-neutral opening facts persisted with a review.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart';

/// Whether the bytes behind an opening artifact were verified before use.
enum OpeningArtifactVerification {
  verified,
  unavailable,
  malformedManifest,
  hashMismatch,
  invalidData,
}

/// Exact result of looking up one played move in an opening artifact.
enum OpeningMatchState {
  unavailable,
  noMatch,
  knownPosition,
  knownTransition,
  leftTheory,
  ambiguousCandidates,
}

/// Semantic identity of the opening data and policy used by an analysis.
///
/// [licenseSpdx] and [provenanceReference] are audit metadata. They are
/// deliberately excluded from [canonicalMaterial], as is any runtime build
/// timestamp held by the index. A data or policy change must instead change
/// one of the five semantic fields below.
class OpeningArtifactIdentity {
  const OpeningArtifactIdentity({
    this.schemaVersion = 1,
    this.openingPolicyVersion = 2,
    required this.datasetName,
    required this.sourceRevision,
    required this.sourceSha256,
    required this.contentSha256,
    required this.licenseSpdx,
    required this.provenanceReference,
  });

  final int schemaVersion;
  final int openingPolicyVersion;
  final String datasetName;
  final String sourceRevision;

  /// SHA-256 of the exact bundled source bytes. This is provenance metadata,
  /// not semantic identity: reordering equivalent input rows may change it.
  final String sourceSha256;

  /// SHA-256 of the canonical, sorted built-index content.
  final String contentSha256;
  final String licenseSpdx;
  final String provenanceReference;

  bool get isStructurallyValid =>
      schemaVersion == 1 &&
      openingPolicyVersion == 2 &&
      datasetName.trim().isNotEmpty &&
      sourceRevision.trim().isNotEmpty &&
      _sha256Pattern.hasMatch(sourceSha256) &&
      _sha256Pattern.hasMatch(contentSha256) &&
      licenseSpdx.trim().isNotEmpty &&
      provenanceReference.trim().isNotEmpty;

  /// Stable semantic material used by analysis-variant compatibility.
  String get canonicalMaterial =>
      '${<String>['apex-opening-artifact', 'schema=$schemaVersion', 'policy=$openingPolicyVersion', _lengthPrefixed('dataset', datasetName), _lengthPrefixed('revision', sourceRevision), 'sha256=${contentSha256.toLowerCase()}'].join('\n')}\n';

  String get semanticId =>
      sha256.convert(utf8.encode(canonicalMaterial)).toString();

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'openingPolicyVersion': openingPolicyVersion,
    'datasetName': datasetName,
    'sourceRevision': sourceRevision,
    'sourceSha256': sourceSha256.toLowerCase(),
    'contentSha256': contentSha256.toLowerCase(),
    'licenseSpdx': licenseSpdx,
    'provenanceReference': provenanceReference,
  };

  factory OpeningArtifactIdentity.fromJson(Map<dynamic, dynamic> json) {
    final schemaVersion = (json['schemaVersion'] as num?)?.toInt();
    final policyVersion = (json['openingPolicyVersion'] as num?)?.toInt();
    final identity = OpeningArtifactIdentity(
      schemaVersion: schemaVersion ?? -1,
      openingPolicyVersion: policyVersion ?? -1,
      datasetName: json['datasetName'] as String? ?? '',
      sourceRevision: json['sourceRevision'] as String? ?? '',
      sourceSha256: json['sourceSha256'] as String? ?? '',
      contentSha256: json['contentSha256'] as String? ?? '',
      licenseSpdx: json['licenseSpdx'] as String? ?? '',
      provenanceReference: json['provenanceReference'] as String? ?? '',
    );
    if (identity.schemaVersion <= 0 ||
        identity.openingPolicyVersion <= 0 ||
        identity.datasetName.trim().isEmpty ||
        identity.sourceRevision.trim().isEmpty ||
        !_sha256Pattern.hasMatch(identity.sourceSha256) ||
        !_sha256Pattern.hasMatch(identity.contentSha256) ||
        identity.licenseSpdx.trim().isEmpty ||
        identity.provenanceReference.trim().isEmpty) {
      throw const FormatException('Malformed opening artifact identity.');
    }
    return identity;
  }
}

/// Versioned standard-chess opening position identity.
///
/// dartchess validates the FEN and emits only a legally capturable en-passant
/// square. Halfmove and fullmove counters are intentionally excluded.
class OpeningPositionKey {
  const OpeningPositionKey._(this.value, this.canonicalFen);

  static const int schemaVersion = 1;
  static const String ruleset = 'standard';

  final String value;
  final String canonicalFen;

  factory OpeningPositionKey.fromFen(String fen) {
    try {
      return OpeningPositionKey.fromPosition(
        Chess.fromSetup(Setup.parseFen(fen)),
      );
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('Invalid opening position FEN.', error);
    }
  }

  /// Builds the same identity from an already-validated immutable position.
  /// Artifact construction uses this path to avoid reparsing every generated
  /// prefix FEN while retaining the exact public FEN contract.
  factory OpeningPositionKey.fromPosition(Position position) {
    if (position is! Chess) {
      throw const FormatException(
        'Opening position identity supports standard chess only.',
      );
    }
    final parts = position.fen.split(' ');
    if (parts.length < 4) {
      throw const FormatException('Opening position FEN has too few fields.');
    }
    final canonicalFen = parts.take(4).join(' ');
    return OpeningPositionKey._(
      'apex-opening-position-v$schemaVersion|$ruleset|$canonicalFen',
      canonicalFen,
    );
  }

  static OpeningPositionKey? tryFromFen(String fen) {
    try {
      return OpeningPositionKey.fromFen(fen);
    } on FormatException {
      return null;
    }
  }

  static bool isStandardInitialFen(String fen) {
    final key = tryFromFen(fen);
    return key != null && key == OpeningPositionKey.fromFen(Chess.initial.fen);
  }

  @override
  bool operator ==(Object other) =>
      other is OpeningPositionKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// One legitimate ECO/name claim contributed by a source line.
class OpeningCandidate {
  const OpeningCandidate({
    required this.ecoCode,
    required this.openingName,
    this.variation,
    required this.sourceLineId,
    required this.sourceTerminalPly,
    required this.matchedPly,
    required this.exactPositionName,
  });

  final String ecoCode;

  /// Full source name. It is never reconstructed from UI prose.
  final String openingName;
  final String? variation;

  /// Stable SHA-256 over ECO/name/canonical ordered-UCI source fields.
  final String sourceLineId;

  /// One-based source-line terminal depth and matched prefix depth.
  final int sourceTerminalPly;
  final int matchedPly;
  final bool exactPositionName;

  String get canonicalMaterial => <String>[
    _lengthPrefixed('eco', ecoCode),
    _lengthPrefixed('name', openingName),
    _lengthPrefixed('variation', variation ?? ''),
    'source=$sourceLineId',
    'terminal-ply=$sourceTerminalPly',
    'matched-ply=$matchedPly',
    'exact=$exactPositionName',
  ].join('\n');

  Map<String, Object?> toJson() => <String, Object?>{
    'ecoCode': ecoCode,
    'openingName': openingName,
    'variation': variation,
    'sourceLineId': sourceLineId,
    'sourceTerminalPly': sourceTerminalPly,
    'matchedPly': matchedPly,
    'exactPositionName': exactPositionName,
  };

  factory OpeningCandidate.fromJson(Map<dynamic, dynamic> json) {
    final candidate = OpeningCandidate(
      ecoCode: json['ecoCode'] as String? ?? '',
      openingName: json['openingName'] as String? ?? '',
      variation: json['variation'] as String?,
      sourceLineId: json['sourceLineId'] as String? ?? '',
      sourceTerminalPly: (json['sourceTerminalPly'] as num?)?.toInt() ?? -1,
      matchedPly: (json['matchedPly'] as num?)?.toInt() ?? -1,
      exactPositionName: json['exactPositionName'] as bool? ?? false,
    );
    if (candidate.ecoCode.trim().isEmpty ||
        candidate.openingName.trim().isEmpty ||
        !_sha256Pattern.hasMatch(candidate.sourceLineId) ||
        candidate.sourceTerminalPly <= 0 ||
        candidate.matchedPly <= 0 ||
        candidate.matchedPly > candidate.sourceTerminalPly) {
      throw const FormatException('Malformed opening candidate.');
    }
    return candidate;
  }
}

/// Auditable facts for one played move's opening lookup.
///
/// The index retains the complete candidate list for diagnostics. This compact
/// persisted record carries only the deterministic selection and a count, then
/// protects those facts with [integrityDigest].
abstract interface class OpeningLookup {
  OpeningArtifactIdentity get identity;
  OpeningArtifactVerification get verification;
  bool get isAvailable;

  /// Looks up a single played move. [ply] is zero-based, matching
  /// `MoveAnalysis.ply`; persisted [OpeningEvidence.matchedPly] is one-based.
  OpeningEvidence lookupTransition({
    required String fenBefore,
    required String playedMoveUci,
    required String fenAfter,
    required int ply,
    required bool standardStart,
  });
}

class OpeningEvidence {
  factory OpeningEvidence({
    int schemaVersion = 1,
    required OpeningArtifactIdentity artifact,
    required OpeningArtifactVerification artifactVerification,
    required OpeningMatchState state,
    required String beforePositionKey,
    required String afterPositionKey,
    required String playedUci,
    required bool transitionVerified,
    OpeningCandidate? selectedCandidate,
    required int totalCandidateCount,
    required int matchedPly,
    bool transposition = false,
    int? leavingTheoryPly,
    required String reasonCode,
  }) {
    final evidence = OpeningEvidence._(
      schemaVersion: schemaVersion,
      artifact: artifact,
      artifactVerification: artifactVerification,
      state: state,
      beforePositionKey: beforePositionKey,
      afterPositionKey: afterPositionKey,
      playedUci: playedUci.toLowerCase(),
      transitionVerified: transitionVerified,
      selectedCandidate: selectedCandidate,
      totalCandidateCount: totalCandidateCount,
      matchedPly: matchedPly,
      transposition: transposition,
      leavingTheoryPly: leavingTheoryPly,
      reasonCode: reasonCode,
      integrityDigest: '',
    );
    evidence._validateShape();
    return evidence._withDigest(evidence._calculateIntegrityDigest());
  }

  const OpeningEvidence._({
    required this.schemaVersion,
    required this.artifact,
    required this.artifactVerification,
    required this.state,
    required this.beforePositionKey,
    required this.afterPositionKey,
    required this.playedUci,
    required this.transitionVerified,
    required this.selectedCandidate,
    required this.totalCandidateCount,
    required this.matchedPly,
    required this.transposition,
    required this.leavingTheoryPly,
    required this.reasonCode,
    required this.integrityDigest,
  });

  final int schemaVersion;
  final OpeningArtifactIdentity artifact;
  final OpeningArtifactVerification artifactVerification;
  final OpeningMatchState state;
  final String beforePositionKey;
  final String afterPositionKey;
  final String playedUci;
  final bool transitionVerified;
  final OpeningCandidate? selectedCandidate;
  final int totalCandidateCount;

  /// One-based played ply, matching the opening artifact's prefix depth.
  final int matchedPly;
  final bool transposition;
  final int? leavingTheoryPly;
  final String reasonCode;
  final String integrityDigest;

  String? get selectedSourceLineId => selectedCandidate?.sourceLineId;

  int get alternateCandidateCount =>
      totalCandidateCount - (selectedCandidate == null ? 0 : 1);

  bool get isArtifactVerified =>
      artifact.isStructurallyValid &&
      artifactVerification == OpeningArtifactVerification.verified;

  /// The sole authority helper that may be mapped to classifier Book state.
  bool get isVerifiedBookTransition =>
      isArtifactVerified &&
      transitionVerified &&
      state == OpeningMatchState.knownTransition;

  bool get hasValidIntegrity => integrityDigest == _calculateIntegrityDigest();

  /// One deterministic game-level name selector shared by archive, summary,
  /// and preview consumers. Later reached names win; ties never depend on
  /// input iteration order.
  static OpeningCandidate? deepestNamed(Iterable<OpeningEvidence> evidence) {
    final named = <(OpeningEvidence, OpeningCandidate)>[];
    for (final item in evidence) {
      final selected = item.selectedCandidate;
      if (selected != null) named.add((item, selected));
    }
    if (named.isEmpty) return null;
    named.sort((a, b) {
      final plyOrder = b.$1.matchedPly.compareTo(a.$1.matchedPly);
      if (plyOrder != 0) return plyOrder;
      if (a.$2.exactPositionName != b.$2.exactPositionName) {
        return a.$2.exactPositionName ? -1 : 1;
      }
      return _compareCandidatesCanonical(a.$2, b.$2);
    });
    return named.first.$2;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'artifact': artifact.toJson(),
    'artifactVerification': artifactVerification.name,
    'state': state.name,
    'beforePositionKey': beforePositionKey,
    'afterPositionKey': afterPositionKey,
    'playedUci': playedUci,
    'transitionVerified': transitionVerified,
    'selectedCandidate': selectedCandidate?.toJson(),
    'totalCandidateCount': totalCandidateCount,
    'matchedPly': matchedPly,
    'transposition': transposition,
    'leavingTheoryPly': leavingTheoryPly,
    'reasonCode': reasonCode,
    'integrityDigest': integrityDigest,
  };

  factory OpeningEvidence.fromJson(Map<dynamic, dynamic> json) {
    final artifactRaw = json['artifact'];
    final candidateRaw = json['selectedCandidate'];
    if (artifactRaw is! Map || (candidateRaw != null && candidateRaw is! Map)) {
      throw const FormatException('Malformed opening evidence.');
    }
    final state = _enumByName(OpeningMatchState.values, json['state']);
    if (state == null) {
      throw const FormatException('Unknown opening evidence state.');
    }
    final artifactVerification = _enumByName(
      OpeningArtifactVerification.values,
      json['artifactVerification'],
    );
    if (artifactVerification == null) {
      throw const FormatException('Unknown opening artifact verification.');
    }
    final evidence = OpeningEvidence(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? -1,
      artifact: OpeningArtifactIdentity.fromJson(artifactRaw),
      artifactVerification: artifactVerification,
      state: state,
      beforePositionKey: json['beforePositionKey'] as String? ?? '',
      afterPositionKey: json['afterPositionKey'] as String? ?? '',
      playedUci: json['playedUci'] as String? ?? '',
      transitionVerified: json['transitionVerified'] as bool? ?? false,
      selectedCandidate: candidateRaw is Map
          ? OpeningCandidate.fromJson(candidateRaw)
          : null,
      totalCandidateCount: (json['totalCandidateCount'] as num?)?.toInt() ?? -1,
      matchedPly: (json['matchedPly'] as num?)?.toInt() ?? -1,
      transposition: json['transposition'] as bool? ?? false,
      leavingTheoryPly: (json['leavingTheoryPly'] as num?)?.toInt(),
      reasonCode: json['reasonCode'] as String? ?? '',
    );
    final storedDigest = json['integrityDigest'] as String? ?? '';
    if (!_sha256Pattern.hasMatch(storedDigest) ||
        evidence.integrityDigest != storedDigest.toLowerCase()) {
      throw const FormatException('Opening evidence integrity mismatch.');
    }
    return evidence;
  }

  OpeningEvidence _withDigest(String digest) => OpeningEvidence._(
    schemaVersion: schemaVersion,
    artifact: artifact,
    artifactVerification: artifactVerification,
    state: state,
    beforePositionKey: beforePositionKey,
    afterPositionKey: afterPositionKey,
    playedUci: playedUci,
    transitionVerified: transitionVerified,
    selectedCandidate: selectedCandidate,
    totalCandidateCount: totalCandidateCount,
    matchedPly: matchedPly,
    transposition: transposition,
    leavingTheoryPly: leavingTheoryPly,
    reasonCode: reasonCode,
    integrityDigest: digest,
  );

  void _validateShape() {
    if (schemaVersion != 1 ||
        beforePositionKey.trim().isEmpty ||
        afterPositionKey.trim().isEmpty ||
        !_uciPattern.hasMatch(playedUci) ||
        matchedPly <= 0 ||
        totalCandidateCount < 0 ||
        (selectedCandidate != null && totalCandidateCount == 0) ||
        (leavingTheoryPly != null && leavingTheoryPly! <= 0) ||
        reasonCode.trim().isEmpty) {
      throw const FormatException('Malformed opening evidence fields.');
    }
    if (transitionVerified &&
        state != OpeningMatchState.knownTransition &&
        state != OpeningMatchState.ambiguousCandidates) {
      throw const FormatException(
        'Only a known transition may be transition-verified.',
      );
    }
    if (transitionVerified && totalCandidateCount == 0) {
      throw const FormatException(
        'Verified transition has no source candidate.',
      );
    }
  }

  String _calculateIntegrityDigest() {
    final fields = <String>[
      'apex-opening-evidence',
      'schema=$schemaVersion',
      'artifact=${artifact.semanticId}',
      'artifact-verification=${artifactVerification.name}',
      _lengthPrefixed('artifact-license', artifact.licenseSpdx),
      _lengthPrefixed('artifact-provenance', artifact.provenanceReference),
      'state=${state.name}',
      _lengthPrefixed('before', beforePositionKey),
      _lengthPrefixed('after', afterPositionKey),
      _lengthPrefixed('uci', playedUci),
      'transition-verified=$transitionVerified',
      'selected=${selectedSourceLineId ?? ''}',
      'total-candidates=$totalCandidateCount',
      'matched-ply=$matchedPly',
      'transposition=$transposition',
      'leaving-theory-ply=${leavingTheoryPly ?? ''}',
      _lengthPrefixed('reason', reasonCode),
      if (selectedCandidate != null)
        _lengthPrefixed('candidate', selectedCandidate!.canonicalMaterial),
    ];
    return sha256.convert(utf8.encode('${fields.join('\n')}\n')).toString();
  }
}

final RegExp _sha256Pattern = RegExp(r'^[0-9a-fA-F]{64}$');
final RegExp _uciPattern = RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$');

String _lengthPrefixed(String label, String value) =>
    '$label:${utf8.encode(value).length}:$value';

T? _enumByName<T extends Enum>(List<T> values, Object? raw) {
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return null;
}

int _compareCandidatesCanonical(OpeningCandidate a, OpeningCandidate b) =>
    a.canonicalMaterial.compareTo(b.canonicalMaterial);
