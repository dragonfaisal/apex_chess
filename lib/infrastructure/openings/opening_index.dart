/// Deterministic, offline opening artifact builder and transition lookup.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/opening_evidence.dart';

const String kApexOpeningDatasetName = 'lichess-org/chess-openings';
const String kApexOpeningSourceRevision =
    'a470acc9d1cdcb26018affa90459a6ec8689af79';
const String kApexOpeningSourceSha256 =
    '3db0ec6eed68209f215da6279b5bf79ea28bd8e227cad9a7d9f753c0709b448c';

const String kApexOpeningCanonicalContentSha256 =
    'ac74534c1a01fa8a010fa56f0f12fc33ec59adbf6fac20b15702d37df115ff97';

const OpeningArtifactIdentity kApexOpeningArtifactIdentity =
    OpeningArtifactIdentity(
      datasetName: kApexOpeningDatasetName,
      sourceRevision: kApexOpeningSourceRevision,
      sourceSha256: kApexOpeningSourceSha256,
      contentSha256: kApexOpeningCanonicalContentSha256,
      licenseSpdx: 'CC0-1.0',
      provenanceReference:
          'assets/openings/eco.provenance.json#lichess-org-chess-openings',
    );

class OpeningInvalidRow {
  const OpeningInvalidRow({required this.sourceLine, required this.reasonCode});

  final int sourceLine;
  final String reasonCode;

  Map<String, Object?> toJson() => <String, Object?>{
    'sourceLine': sourceLine,
    'reasonCode': reasonCode,
  };
}

class OpeningCoverageMetrics {
  const OpeningCoverageMetrics({
    required this.sourceRows,
    required this.validLines,
    required this.invalidRows,
    required this.totalPrefixes,
    required this.indexedPositions,
    required this.indexedTransitions,
    required this.oldTerminalPositions,
    required this.missingPrefixPositionsVsOld,
    required this.transpositionCollisions,
    required this.ambiguousCandidatePositions,
    required this.maximumPly,
    required this.sourceBytes,
    required this.canonicalContentBytes,
    required this.sourceSha256,
    required this.canonicalContentSha256,
    required this.buildMicros,
  });

  final int sourceRows;
  final int validLines;
  final List<OpeningInvalidRow> invalidRows;
  final int totalPrefixes;
  final int indexedPositions;
  final int indexedTransitions;
  final int oldTerminalPositions;
  final int missingPrefixPositionsVsOld;
  final int transpositionCollisions;
  final int ambiguousCandidatePositions;
  final int maximumPly;
  final int sourceBytes;
  final int canonicalContentBytes;
  final String sourceSha256;
  final String canonicalContentSha256;
  final int buildMicros;

  int get invalidLines => invalidRows.length;

  Map<String, Object?> toJson() => <String, Object?>{
    'sourceRows': sourceRows,
    'validLines': validLines,
    'invalidLines': invalidLines,
    'invalidRows': invalidRows
        .map((row) => row.toJson())
        .toList(growable: false),
    'totalPrefixes': totalPrefixes,
    'indexedPositions': indexedPositions,
    'indexedTransitions': indexedTransitions,
    'oldTerminalPositions': oldTerminalPositions,
    'missingPrefixPositionsVsOld': missingPrefixPositionsVsOld,
    'transpositionCollisions': transpositionCollisions,
    'ambiguousCandidatePositions': ambiguousCandidatePositions,
    'maximumPly': maximumPly,
    'sourceBytes': sourceBytes,
    'canonicalContentBytes': canonicalContentBytes,
    'sourceSha256': sourceSha256,
    'canonicalContentSha256': canonicalContentSha256,
    'buildMicros': buildMicros,
  };

  static const empty = OpeningCoverageMetrics(
    sourceRows: 0,
    validLines: 0,
    invalidRows: <OpeningInvalidRow>[],
    totalPrefixes: 0,
    indexedPositions: 0,
    indexedTransitions: 0,
    oldTerminalPositions: 0,
    missingPrefixPositionsVsOld: 0,
    transpositionCollisions: 0,
    ambiguousCandidatePositions: 0,
    maximumPly: 0,
    sourceBytes: 0,
    canonicalContentBytes: 0,
    sourceSha256: '',
    canonicalContentSha256: '',
    buildMicros: 0,
  );
}

/// One immutable runtime index. It owns both position diagnostics and the
/// transition authority used by analysis; there is no parallel name map.
class OpeningIndex implements OpeningLookup {
  OpeningIndex._({
    required this.identity,
    required this.verification,
    required this.metrics,
    required Map<OpeningPositionKey, _PositionRecord> positions,
    required Map<_TransitionKey, _TransitionRecord> transitions,
    required this.unavailableReasonCode,
    this.buildTimestamp,
  }) : _positions = Map<OpeningPositionKey, _PositionRecord>.unmodifiable(
         positions,
       ),
       _transitions = Map<_TransitionKey, _TransitionRecord>.unmodifiable(
         transitions,
       );

  factory OpeningIndex.fromTsv(
    String body, {
    OpeningArtifactIdentity identity = kApexOpeningArtifactIdentity,
    DateTime? buildTimestamp,
  }) {
    final watch = Stopwatch()..start();
    final sourceBytes = utf8.encode(body);
    final sourceHash = sha256.convert(sourceBytes).toString();
    final mutablePositions = <OpeningPositionKey, _MutablePositionRecord>{};
    final mutableTransitions = <_TransitionKey, _MutableTransitionRecord>{};
    final oldTerminalPositions = <OpeningPositionKey>{};
    final allAfterPositions = <OpeningPositionKey>{};
    final invalidRows = <OpeningInvalidRow>[];
    var sourceRows = 0;
    var validLines = 0;
    var totalPrefixes = 0;
    var maximumPly = 0;

    final lines = const LineSplitter().convert(body);
    final headerIsValid =
        lines.isNotEmpty && lines.first.trimRight() == 'eco\tname\tpgn';
    if (!headerIsValid) {
      invalidRows.add(
        const OpeningInvalidRow(
          sourceLine: 1,
          reasonCode: 'missing_or_invalid_header',
        ),
      );
    } else {
      final standardRoot = OpeningPositionKey.fromFen(Chess.initial.fen);
      mutablePositions[standardRoot] = _MutablePositionRecord()..routes.add('');
      for (var index = 1; index < lines.length; index++) {
        final line = lines[index].trimRight();
        if (line.isEmpty) continue;
        sourceRows++;
        final sourceLine = index + 1;
        final columns = line.split('\t');
        if (columns.length != 3) {
          invalidRows.add(
            OpeningInvalidRow(
              sourceLine: sourceLine,
              reasonCode: 'invalid_column_count',
            ),
          );
          continue;
        }
        final eco = columns[0].trim();
        final name = columns[1].trim();
        final pgn = columns[2].trim();
        if (eco.isEmpty || name.isEmpty || pgn.isEmpty) {
          invalidRows.add(
            OpeningInvalidRow(
              sourceLine: sourceLine,
              reasonCode: 'empty_required_field',
            ),
          );
          continue;
        }

        final _ParsedSourceGame game;
        try {
          game = _parseSourceGame(pgn);
        } on Object {
          invalidRows.add(
            OpeningInvalidRow(
              sourceLine: sourceLine,
              reasonCode: 'invalid_legal_mainline',
            ),
          );
          continue;
        }
        if (!OpeningPositionKey.isStandardInitialFen(game.startingFen) ||
            game.moves.isEmpty) {
          invalidRows.add(
            OpeningInvalidRow(
              sourceLine: sourceLine,
              reasonCode: 'unsupported_or_empty_mainline',
            ),
          );
          continue;
        }

        validLines++;
        totalPrefixes += game.moves.length;
        if (game.moves.length > maximumPly) maximumPly = game.moves.length;
        final canonicalUci = game.moves.map((move) => move.uci).join(' ');
        final sourceLineId = _sourceLineId(eco, name, canonicalUci);
        final route = <String>[];

        for (var ply = 0; ply < game.moves.length; ply++) {
          final move = game.moves[ply];
          final before = move.before;
          final after = move.after;
          final uci = _normalizeCastlingUci(move.uci.toLowerCase());
          route.add(uci);
          final candidate = OpeningCandidate(
            ecoCode: eco,
            openingName: name,
            variation: _variationFromName(name),
            sourceLineId: sourceLineId,
            sourceTerminalPly: game.moves.length,
            matchedPly: ply + 1,
            exactPositionName: ply == game.moves.length - 1,
          );

          final beforeRoute = route.take(route.length - 1).join(' ');
          mutablePositions
              .putIfAbsent(before, _MutablePositionRecord.new)
              .routes
              .add(beforeRoute);
          final position = mutablePositions.putIfAbsent(
            after,
            _MutablePositionRecord.new,
          );
          position.routes.add(route.join(' '));
          position.candidates[candidate.canonicalMaterial] = candidate;
          allAfterPositions.add(after);

          final transitionKey = _TransitionKey(before, uci);
          final transition = mutableTransitions.putIfAbsent(
            transitionKey,
            () => _MutableTransitionRecord(after),
          );
          if (transition.after != after) {
            invalidRows.add(
              OpeningInvalidRow(
                sourceLine: sourceLine,
                reasonCode: 'contradictory_transition',
              ),
            );
            continue;
          }
          transition.candidates[candidate.canonicalMaterial] = candidate;
        }
        oldTerminalPositions.add(game.moves.last.after);
      }
    }

    final positions = <OpeningPositionKey, _PositionRecord>{
      for (final entry in mutablePositions.entries)
        entry.key: entry.value.freeze(),
    };
    final transitions = <_TransitionKey, _TransitionRecord>{
      for (final entry in mutableTransitions.entries)
        entry.key: entry.value.freeze(),
    };
    final canonicalContent = _canonicalIndexDigest(positions, transitions);
    final canonicalHash = canonicalContent.sha256;
    watch.stop();
    final metrics = OpeningCoverageMetrics(
      sourceRows: sourceRows,
      validLines: validLines,
      invalidRows: List<OpeningInvalidRow>.unmodifiable(invalidRows),
      totalPrefixes: totalPrefixes,
      indexedPositions: positions.length,
      indexedTransitions: transitions.length,
      oldTerminalPositions: oldTerminalPositions.length,
      missingPrefixPositionsVsOld: allAfterPositions
          .difference(oldTerminalPositions)
          .length,
      transpositionCollisions: positions.values
          .where((position) => position.routeCount > 1)
          .length,
      ambiguousCandidatePositions: positions.values
          .where((position) => position.distinctNameCount > 1)
          .length,
      maximumPly: maximumPly,
      sourceBytes: sourceBytes.length,
      canonicalContentBytes: canonicalContent.byteLength,
      sourceSha256: sourceHash,
      canonicalContentSha256: canonicalHash,
      buildMicros: watch.elapsedMicroseconds,
    );

    final OpeningArtifactVerification verification;
    final String? reason;
    if (invalidRows.isNotEmpty) {
      verification = OpeningArtifactVerification.invalidData;
      reason = 'invalid_opening_data';
    } else if (sourceHash.toLowerCase() !=
            identity.sourceSha256.toLowerCase() ||
        canonicalHash.toLowerCase() != identity.contentSha256.toLowerCase()) {
      verification = OpeningArtifactVerification.hashMismatch;
      reason = 'opening_artifact_hash_mismatch';
    } else {
      verification = OpeningArtifactVerification.verified;
      reason = null;
    }
    return OpeningIndex._(
      identity: identity,
      verification: verification,
      metrics: metrics,
      positions: positions,
      transitions: transitions,
      unavailableReasonCode: reason,
      buildTimestamp: buildTimestamp?.toUtc(),
    );
  }

  factory OpeningIndex.unavailable({
    OpeningArtifactIdentity identity = kApexOpeningArtifactIdentity,
    OpeningArtifactVerification verification =
        OpeningArtifactVerification.unavailable,
    String reasonCode = 'opening_artifact_unavailable',
  }) {
    if (verification == OpeningArtifactVerification.verified) {
      throw ArgumentError(
        'An unavailable index cannot have verified artifact state.',
      );
    }
    return OpeningIndex._(
      identity: identity,
      verification: verification,
      metrics: OpeningCoverageMetrics.empty,
      positions: const <OpeningPositionKey, _PositionRecord>{},
      transitions: const <_TransitionKey, _TransitionRecord>{},
      unavailableReasonCode: reasonCode,
    );
  }

  @override
  final OpeningArtifactIdentity identity;

  @override
  final OpeningArtifactVerification verification;

  final OpeningCoverageMetrics metrics;
  final String? unavailableReasonCode;

  /// Non-identity runtime metadata only.
  final DateTime? buildTimestamp;

  final Map<OpeningPositionKey, _PositionRecord> _positions;
  final Map<_TransitionKey, _TransitionRecord> _transitions;
  var _lookupCount = 0;

  @override
  bool get isAvailable => verification == OpeningArtifactVerification.verified;

  int get lookupCount => _lookupCount;

  List<OpeningCandidate> diagnosticCandidatesForPosition(String fen) {
    final key = OpeningPositionKey.fromFen(fen);
    return _positions[key]?.candidates ?? const <OpeningCandidate>[];
  }

  List<OpeningCandidate> diagnosticCandidatesForTransition({
    required String fenBefore,
    required String playedMoveUci,
  }) {
    final before = OpeningPositionKey.fromFen(fenBefore);
    final uci = _normalizeCastlingUci(playedMoveUci.toLowerCase());
    return _transitions[_TransitionKey(before, uci)]?.candidates ??
        const <OpeningCandidate>[];
  }

  @override
  OpeningEvidence lookupTransition({
    required String fenBefore,
    required String playedMoveUci,
    required String fenAfter,
    required int ply,
    required bool standardStart,
  }) {
    if (ply < 0) throw const FormatException('Opening lookup ply is negative.');
    final before = OpeningPositionKey.fromFen(fenBefore);
    final after = OpeningPositionKey.fromFen(fenAfter);
    final uci = _normalizeCastlingUci(playedMoveUci.toLowerCase());
    if (!_uciPattern.hasMatch(uci)) {
      throw const FormatException('Opening lookup UCI is malformed.');
    }
    _lookupCount++;

    OpeningEvidence evidence({
      required OpeningMatchState state,
      required String reasonCode,
      bool transitionVerified = false,
      OpeningCandidate? selected,
      int candidateCount = 0,
      bool transposition = false,
      int? leavingTheoryPly,
    }) => OpeningEvidence(
      artifact: identity,
      artifactVerification: verification,
      state: state,
      beforePositionKey: before.value,
      afterPositionKey: after.value,
      playedUci: uci,
      transitionVerified: transitionVerified,
      selectedCandidate: selected,
      totalCandidateCount: candidateCount,
      matchedPly: ply + 1,
      transposition: transposition,
      leavingTheoryPly: leavingTheoryPly,
      reasonCode: reasonCode,
    );

    if (!isAvailable) {
      return evidence(
        state: OpeningMatchState.unavailable,
        reasonCode: unavailableReasonCode ?? 'opening_artifact_unavailable',
      );
    }
    if (!standardStart) {
      return evidence(
        state: OpeningMatchState.noMatch,
        reasonCode: 'unsupported_start_position',
      );
    }
    _validateLegalTransition(
      fenBefore: fenBefore,
      playedMoveUci: uci,
      expectedAfter: after,
    );

    final transition = _transitions[_TransitionKey(before, uci)];
    if (transition != null && transition.after == after) {
      final afterPosition = _positions[after];
      final selected = _selectExactName(afterPosition?.candidates ?? const []);
      return evidence(
        state: OpeningMatchState.knownTransition,
        reasonCode: (afterPosition?.routeCount ?? 0) > 1
            ? 'verified_transposition'
            : 'verified_known_transition',
        transitionVerified: true,
        selected: selected,
        candidateCount:
            afterPosition?.candidates.length ?? transition.candidates.length,
        transposition: (afterPosition?.routeCount ?? 0) > 1,
      );
    }
    final beforeKnown = _positions.containsKey(before);
    final afterPosition = _positions[after];
    if (beforeKnown) {
      return evidence(
        state: OpeningMatchState.leftTheory,
        reasonCode: 'known_position_unknown_transition',
        leavingTheoryPly: ply + 1,
      );
    }
    if (afterPosition != null) {
      return evidence(
        state: OpeningMatchState.knownPosition,
        reasonCode: 'known_position_without_verified_transition',
        selected: _selectExactName(afterPosition.candidates),
        candidateCount: afterPosition.candidates.length,
        transposition: afterPosition.routeCount > 1,
      );
    }
    return evidence(
      state: OpeningMatchState.noMatch,
      reasonCode: 'position_and_transition_not_found',
    );
  }
}

class _MutablePositionRecord {
  final Map<String, OpeningCandidate> candidates = <String, OpeningCandidate>{};
  final Set<String> routes = <String>{};

  _PositionRecord freeze() {
    final ordered = candidates.values.toList()..sort(_compareCandidates);
    return _PositionRecord(
      candidates: List<OpeningCandidate>.unmodifiable(ordered),
      routes: Set<String>.unmodifiable(routes),
    );
  }
}

class _PositionRecord {
  const _PositionRecord({required this.candidates, required this.routes});

  final List<OpeningCandidate> candidates;
  final Set<String> routes;

  int get routeCount => routes.length;
  int get distinctNameCount => candidates
      .map((candidate) => '${candidate.ecoCode}\u0000${candidate.openingName}')
      .toSet()
      .length;
}

class _MutableTransitionRecord {
  _MutableTransitionRecord(this.after);

  final OpeningPositionKey after;
  final Map<String, OpeningCandidate> candidates = <String, OpeningCandidate>{};

  _TransitionRecord freeze() {
    final ordered = candidates.values.toList()..sort(_compareCandidates);
    return _TransitionRecord(
      after: after,
      candidates: List<OpeningCandidate>.unmodifiable(ordered),
    );
  }
}

class _TransitionRecord {
  const _TransitionRecord({required this.after, required this.candidates});

  final OpeningPositionKey after;
  final List<OpeningCandidate> candidates;
}

class _TransitionKey {
  const _TransitionKey(this.before, this.uci);

  final OpeningPositionKey before;
  final String uci;

  @override
  bool operator ==(Object other) =>
      other is _TransitionKey && other.before == before && other.uci == uci;

  @override
  int get hashCode => Object.hash(before, uci);
}

_CanonicalIndexDigest _canonicalIndexDigest(
  Map<OpeningPositionKey, _PositionRecord> positions,
  Map<_TransitionKey, _TransitionRecord> transitions,
) {
  final digestSink = _SingleDigestSink();
  final hashSink = sha256.startChunkedConversion(digestSink);
  var byteLength = 0;

  void addField(String field) {
    final bytes = utf8.encode(field);
    hashSink
      ..add(bytes)
      ..add(const <int>[0x0a]);
    byteLength += bytes.length + 1;
  }

  addField('apex-opening-index');
  addField('schema=${kApexOpeningArtifactIdentity.schemaVersion}');
  addField('policy=${kApexOpeningArtifactIdentity.openingPolicyVersion}');
  final positionEntries = positions.entries.toList()
    ..sort((a, b) => a.key.value.compareTo(b.key.value));
  for (final entry in positionEntries) {
    addField(_lengthPrefixed('position', entry.key.value));
    final routes = entry.value.routes.toList()..sort();
    for (final route in routes) {
      addField(_lengthPrefixed('route', route));
    }
    for (final candidate in entry.value.candidates) {
      addField(_lengthPrefixed('candidate', candidate.canonicalMaterial));
    }
  }
  final transitionEntries = transitions.entries.toList()
    ..sort((a, b) {
      final before = a.key.before.value.compareTo(b.key.before.value);
      if (before != 0) return before;
      return a.key.uci.compareTo(b.key.uci);
    });
  for (final entry in transitionEntries) {
    addField(_lengthPrefixed('transition-before', entry.key.before.value));
    addField(_lengthPrefixed('transition-uci', entry.key.uci));
    addField(_lengthPrefixed('transition-after', entry.value.after.value));
    for (final candidate in entry.value.candidates) {
      addField(
        _lengthPrefixed('transition-candidate', candidate.canonicalMaterial),
      );
    }
  }
  hashSink.close();
  return _CanonicalIndexDigest(
    sha256: digestSink.digest.toString(),
    byteLength: byteLength,
  );
}

class _CanonicalIndexDigest {
  const _CanonicalIndexDigest({required this.sha256, required this.byteLength});

  final String sha256;
  final int byteLength;
}

class _SingleDigestSink implements Sink<Digest> {
  Digest? _digest;

  Digest get digest => _digest ?? (throw StateError('Digest is unavailable.'));

  @override
  void add(Digest data) {
    if (_digest != null) throw StateError('Digest was emitted more than once.');
    _digest = data;
  }

  @override
  void close() {}
}

void _validateLegalTransition({
  required String fenBefore,
  required String playedMoveUci,
  required OpeningPositionKey expectedAfter,
}) {
  final position = Chess.fromSetup(Setup.parseFen(fenBefore));
  final move = Move.parse(playedMoveUci);
  if (move is! NormalMove || !position.isLegal(move)) {
    throw const FormatException('Opening lookup move is not legal.');
  }
  final actualAfter = OpeningPositionKey.fromFen(position.play(move).fen);
  if (actualAfter != expectedAfter) {
    throw const FormatException('Opening lookup after-position mismatch.');
  }
}

OpeningCandidate? _selectExactName(List<OpeningCandidate> candidates) {
  final exact =
      candidates.where((candidate) => candidate.exactPositionName).toList()
        ..sort(_comparePublicCandidates);
  return exact.firstOrNull;
}

int _comparePublicCandidates(OpeningCandidate a, OpeningCandidate b) {
  final depth = b.sourceTerminalPly.compareTo(a.sourceTerminalPly);
  if (depth != 0) return depth;
  final specificity = b.openingName.length.compareTo(a.openingName.length);
  if (specificity != 0) return specificity;
  return _compareCandidates(a, b);
}

int _compareCandidates(OpeningCandidate a, OpeningCandidate b) =>
    a.canonicalMaterial.compareTo(b.canonicalMaterial);

String _sourceLineId(String eco, String name, String canonicalUci) {
  final material = <String>[
    _lengthPrefixed('eco', eco),
    _lengthPrefixed('name', name),
    _lengthPrefixed('uci', canonicalUci),
  ].join('\n');
  return sha256.convert(utf8.encode('$material\n')).toString();
}

String? _variationFromName(String name) {
  final separator = name.indexOf(':');
  if (separator < 0 || separator == name.length - 1) return null;
  final variation = name.substring(separator + 1).trim();
  return variation.isEmpty ? null : variation;
}

String _lengthPrefixed(String label, String value) =>
    '$label:${utf8.encode(value).length}:$value';

final RegExp _uciPattern = RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$');

class _ParsedSourceGame {
  const _ParsedSourceGame({required this.startingFen, required this.moves});

  final String startingFen;
  final List<_ParsedSourceMove> moves;
}

class _ParsedSourceMove {
  const _ParsedSourceMove({
    required this.before,
    required this.after,
    required this.uci,
  });

  final OpeningPositionKey before;
  final OpeningPositionKey after;
  final String uci;
}

_ParsedSourceGame _parseSourceGame(String pgn) {
  var cleaned = pgn
      .replaceAll(RegExp(r'\[[^\]]+\]'), ' ')
      .replaceAll(RegExp(r'\{[^}]*\}', dotAll: true), ' ')
      .replaceAll(RegExp(r';[^\n\r]*'), ' ')
      .replaceAll(RegExp(r'\$\d+'), ' ');
  final variation = RegExp(r'\([^()]*\)');
  while (variation.hasMatch(cleaned)) {
    cleaned = cleaned.replaceAll(variation, ' ');
  }
  cleaned = cleaned.replaceAll(RegExp(r'\d+\.(?:\.\.)?'), ' ');
  final tokens = cleaned
      .split(RegExp(r'\s+'))
      .map((token) => token.trim().replaceAll(RegExp(r'[!?]+$'), ''))
      .where((token) => token.isNotEmpty && !_isResultToken(token))
      .toList(growable: false);
  if (tokens.isEmpty) {
    throw const FormatException('Opening source mainline is empty.');
  }

  Position position = Chess.initial;
  final startingFen = position.fen;
  final moves = <_ParsedSourceMove>[];
  for (final san in tokens) {
    final move = position.parseSan(san);
    if (move is! NormalMove || !position.isLegal(move)) {
      throw FormatException('Illegal opening source SAN: $san');
    }
    final after = position.play(move);
    moves.add(
      _ParsedSourceMove(
        before: OpeningPositionKey.fromPosition(position),
        after: OpeningPositionKey.fromPosition(after),
        uci: _normalizeCastlingUci(move.uci),
      ),
    );
    position = after;
  }
  return _ParsedSourceGame(
    startingFen: startingFen,
    moves: List<_ParsedSourceMove>.unmodifiable(moves),
  );
}

bool _isResultToken(String token) =>
    token == '1-0' || token == '0-1' || token == '1/2-1/2' || token == '*';

String _normalizeCastlingUci(String uci) {
  if (uci.length < 4) return uci;
  return switch (uci.substring(0, 4)) {
    'e1h1' => 'e1g1${uci.substring(4)}',
    'e1a1' => 'e1c1${uci.substring(4)}',
    'e8h8' => 'e8g8${uci.substring(4)}',
    'e8a8' => 'e8c8${uci.substring(4)}',
    _ => uci,
  };
}
