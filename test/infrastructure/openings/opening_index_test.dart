import 'dart:convert';
import 'dart:io' as io;

import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

void main() {
  group('OpeningArtifactIdentity and evidence', () {
    test('semantic identity excludes raw source order and build timestamp', () {
      final first = _verifiedIndex(
        _tsv(<String>['B00\tKing Pawn\t1. e4', 'A00\tQueen Pawn\t1. d4']),
        buildTimestamp: DateTime.utc(2026, 1, 1),
      );
      final shuffled = _verifiedIndex(
        _tsv(<String>['A00\tQueen Pawn\t1. d4', 'B00\tKing Pawn\t1. e4']),
        buildTimestamp: DateTime.utc(2030, 1, 1),
      );

      expect(first.metrics.sourceSha256, isNot(shuffled.metrics.sourceSha256));
      expect(
        first.metrics.canonicalContentSha256,
        shuffled.metrics.canonicalContentSha256,
      );
      expect(first.identity.semanticId, shuffled.identity.semanticId);
      expect(first.buildTimestamp, isNot(shuffled.buildTimestamp));
    });

    test('identity JSON rejects missing required provenance', () {
      final json = Map<String, Object?>.from(
        kApexOpeningArtifactIdentity.toJson(),
      )..['licenseSpdx'] = '';

      expect(
        () => OpeningArtifactIdentity.fromJson(json),
        throwsFormatException,
      );
    });

    test('opening evidence JSON rejects a changed fact', () {
      final index = _verifiedIndex(_tsv(<String>['B00\tKing Pawn\t1. e4']));
      final move = _line('1. e4').single;
      final evidence = _lookup(index, move, ply: 0);
      final json = Map<String, Object?>.from(evidence.toJson())
        ..['reasonCode'] = 'tampered';

      expect(evidence.hasValidIntegrity, isTrue);
      expect(() => OpeningEvidence.fromJson(json), throwsFormatException);
    });

    test('only exact verified knownTransition is Book-authoritative', () {
      final index = _verifiedIndex(_tsv(<String>['B00\tKing Pawn\t1. e4']));
      final verified = _lookup(index, _line('1. e4').single, ply: 0);
      final ambiguous = OpeningEvidence(
        artifact: verified.artifact,
        artifactVerification: OpeningArtifactVerification.verified,
        state: OpeningMatchState.ambiguousCandidates,
        beforePositionKey: verified.beforePositionKey,
        afterPositionKey: verified.afterPositionKey,
        playedUci: verified.playedUci,
        transitionVerified: true,
        selectedCandidate: verified.selectedCandidate,
        totalCandidateCount: verified.totalCandidateCount,
        matchedPly: 1,
        reasonCode: 'ambiguous_name',
      );

      expect(verified.isVerifiedBookTransition, isTrue);
      expect(ambiguous.isVerifiedBookTransition, isFalse);
    });
  });

  group('OpeningPositionKey', () {
    test('ignores clocks but preserves side and castling rights', () {
      const base = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';
      expect(
        OpeningPositionKey.fromFen(base),
        OpeningPositionKey.fromFen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 99 77'),
      );
      expect(
        OpeningPositionKey.fromFen(base),
        isNot(
          OpeningPositionKey.fromFen('r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1'),
        ),
      );
      expect(
        OpeningPositionKey.fromFen(base),
        isNot(OpeningPositionKey.fromFen('r3k2r/8/8/8/8/8/8/R3K2R w KQ - 0 1')),
      );
    });

    test('preserves only legally relevant en-passant state', () {
      final relevant = _line('1. e4 a6 2. e5 d5').last.fenAfter;
      expect(relevant, contains(' d6 '));
      final withoutRelevantEp = relevant.replaceFirst(' d6 ', ' - ');
      expect(
        OpeningPositionKey.fromFen(relevant),
        isNot(OpeningPositionKey.fromFen(withoutRelevantEp)),
      );

      const irrelevantEp =
          'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1';
      const noEp = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
      expect(
        OpeningPositionKey.fromFen(irrelevantEp),
        OpeningPositionKey.fromFen(noEp),
      );
    });

    test('rejects malformed FEN and recognizes only the standard root', () {
      expect(OpeningPositionKey.tryFromFen('not-a-fen'), isNull);
      expect(
        OpeningPositionKey.isStandardInitialFen(Chess.initial.fen),
        isTrue,
      );
      expect(
        OpeningPositionKey.isStandardInitialFen(_line('1. e4').last.fenAfter),
        isFalse,
      );
    });
  });

  group('OpeningIndex transitions and naming', () {
    test('one source line contributes every legal prefix and transition', () {
      final index = _verifiedIndex(
        _tsv(<String>['C40\tKing Knight\t1. e4 e5 2. Nf3']),
      );
      final moves = _line('1. e4 e5 2. Nf3');

      expect(index.metrics.validLines, 1);
      expect(index.metrics.invalidLines, 0);
      expect(index.metrics.totalPrefixes, 3);
      expect(index.metrics.indexedPositions, 4);
      expect(index.metrics.indexedTransitions, 3);
      for (var ply = 0; ply < moves.length; ply++) {
        final evidence = _lookup(index, moves[ply], ply: ply);
        expect(evidence.state, OpeningMatchState.knownTransition);
        expect(evidence.isVerifiedBookTransition, isTrue);
      }
      expect(_lookup(index, moves.first, ply: 0).selectedCandidate, isNull);
      expect(
        _lookup(index, moves.last, ply: 2).selectedCandidate?.ecoCode,
        'C40',
      );
    });

    test('different move orders share identity and retain both names', () {
      final index = _verifiedIndex(
        _tsv(<String>[
          'A04\tReti Route\t1. Nf3 d5 2. g3 Nf6 3. Bg2 g6',
          'A00\tHungarian Route\t1. g3 d5 2. Nf3 Nf6 3. Bg2 g6',
        ]),
      );
      final first = _line('1. Nf3 d5 2. g3 Nf6 3. Bg2 g6');
      final second = _line('1. g3 d5 2. Nf3 Nf6 3. Bg2 g6');

      expect(
        OpeningPositionKey.fromFen(first.last.fenAfter),
        OpeningPositionKey.fromFen(second.last.fenAfter),
      );
      final candidates = index.diagnosticCandidatesForPosition(
        first.last.fenAfter,
      );
      expect(candidates.map((candidate) => candidate.openingName).toSet(), {
        'Reti Route',
        'Hungarian Route',
      });
      final evidence = _lookup(index, second.last, ply: 5);
      expect(evidence.state, OpeningMatchState.knownTransition);
      expect(evidence.transposition, isTrue);
      expect(evidence.totalCandidateCount, 2);
      expect(
        candidates.map((candidate) => candidate.sourceLineId),
        contains(evidence.selectedSourceLineId),
      );
    });

    test('row order cannot choose a different public name', () {
      final rows = <String>[
        'A04\tReti Route\t1. Nf3 d5 2. g3',
        'A05\tReti Route: Long Variation\t1. g3 d5 2. Nf3',
      ];
      final first = _verifiedIndex(_tsv(rows));
      final reversed = _verifiedIndex(_tsv(rows.reversed.toList()));
      final move = _line('1. g3 d5 2. Nf3').last;

      final firstEvidence = _lookup(first, move, ply: 2);
      final reversedEvidence = _lookup(reversed, move, ply: 2);
      expect(first.identity.semanticId, reversed.identity.semanticId);
      expect(
        firstEvidence.selectedCandidate?.sourceLineId,
        reversedEvidence.selectedCandidate?.sourceLineId,
      );
      expect(
        firstEvidence.selectedCandidate?.openingName,
        'Reti Route: Long Variation',
      );
    });

    test('known position without indexed transition is not Book', () {
      final index = _verifiedIndex(
        _tsv(<String>['A04\tReti Route\t1. Nf3 d5 2. g3']),
      );
      final transposed = _line('1. g3 d5 2. Nf3');
      final evidence = _lookup(index, transposed.last, ply: 2);

      expect(evidence.state, OpeningMatchState.knownPosition);
      expect(evidence.transitionVerified, isFalse);
      expect(evidence.isVerifiedBookTransition, isFalse);
    });

    test('known position plus unknown move is leftTheory', () {
      final index = _verifiedIndex(_tsv(<String>['B00\tKing Pawn\t1. e4']));
      final evidence = _lookup(index, _line('1. d4').single, ply: 0);

      expect(evidence.state, OpeningMatchState.leftTheory);
      expect(evidence.leavingTheoryPly, 1);
      expect(evidence.isVerifiedBookTransition, isFalse);
    });

    test('unknown position is noMatch and unavailable stays distinct', () {
      final index = _verifiedIndex(_tsv(<String>['B00\tKing Pawn\t1. e4']));
      final setupMove = _setupMove('8/8/8/8/8/8/K6k/8 w - - 0 1', 'a2a3');
      final noMatch = _lookup(index, setupMove, ply: 0);
      final unavailable = _lookup(
        OpeningIndex.unavailable(),
        _line('1. e4').single,
        ply: 0,
      );

      expect(noMatch.state, OpeningMatchState.noMatch);
      expect(unavailable.state, OpeningMatchState.unavailable);
      expect(unavailable.artifact, kApexOpeningArtifactIdentity);
    });

    test('Setup/FEN guard cannot fabricate standard opening evidence', () {
      final index = _verifiedIndex(_tsv(<String>['B00\tKing Pawn\t1. e4']));
      final evidence = _lookup(
        index,
        _line('1. e4').single,
        ply: 0,
        standardStart: false,
      );

      expect(evidence.state, OpeningMatchState.noMatch);
      expect(evidence.reasonCode, 'unsupported_start_position');
      expect(evidence.isVerifiedBookTransition, isFalse);
    });

    test('legal move and exact after-position continuity are enforced', () {
      final index = _verifiedIndex(_tsv(<String>['B00\tKing Pawn\t1. e4']));
      final e4 = _line('1. e4').single;
      final d4 = _line('1. d4').single;

      expect(
        () => index.lookupTransition(
          fenBefore: e4.fenBefore,
          playedMoveUci: e4.uci,
          fenAfter: d4.fenAfter,
          ply: 0,
          standardStart: true,
        ),
        throwsFormatException,
      );
    });

    test('PGN comments and formatting do not change built index identity', () {
      final compact = _verifiedIndex(
        _tsv(<String>['C20\tOpen Game\t1. e4 e5']),
      );
      final formatted = _verifiedIndex(
        _tsv(<String>[
          'C20\tOpen Game\t[White "Alice"] [Black "Bob"] '
              '[Site "Chess.com"] 1. e4 {comment} 1... e5',
        ]),
      );

      expect(
        compact.metrics.canonicalContentSha256,
        formatted.metrics.canonicalContentSha256,
      );
      expect(compact.identity.semanticId, formatted.identity.semanticId);
    });

    test('deepestNamed is the one stable game-level selector', () {
      final index = _verifiedIndex(
        _tsv(<String>['B00\tKing Pawn\t1. e4', 'C20\tOpen Game\t1. e4 e5']),
      );
      final moves = _line('1. e4 e5');
      final evidence = <OpeningEvidence>[
        _lookup(index, moves.first, ply: 0),
        _lookup(index, moves.last, ply: 1),
      ];

      expect(OpeningEvidence.deepestNamed(evidence)?.openingName, 'Open Game');
    });
  });

  group('Bundled artifact coverage', () {
    test('real source verifies exact deterministic metrics', () async {
      final body = await io.File('assets/openings/eco.tsv').readAsString();
      final index = OpeningIndex.fromTsv(body);

      expect(index.verification, OpeningArtifactVerification.verified);
      expect(index.metrics.sourceRows, 3690);
      expect(index.metrics.validLines, 3690);
      expect(index.metrics.invalidLines, 0);
      expect(index.metrics.totalPrefixes, 35530);
      expect(index.metrics.indexedPositions, 7602);
      expect(index.metrics.indexedTransitions, 7789);
      expect(index.metrics.oldTerminalPositions, 3690);
      expect(index.metrics.missingPrefixPositionsVsOld, 3911);
      expect(index.metrics.transpositionCollisions, 538);
      expect(index.metrics.ambiguousCandidatePositions, 2556);
      expect(index.metrics.maximumPly, 36);
      expect(index.metrics.sourceSha256, kApexOpeningSourceSha256);
      expect(
        index.metrics.canonicalContentSha256,
        kApexOpeningCanonicalContentSha256,
      );
    });

    test('real graph preserves transposition routes and theory exit', () async {
      final body = await io.File('assets/openings/eco.tsv').readAsString();
      final index = OpeningIndex.fromTsv(body);

      final transposedLine = _line('1. g3 d5 2. Nf3');
      final transposition = _lookup(index, transposedLine.last, ply: 2);
      final candidates = index.diagnosticCandidatesForPosition(
        transposedLine.last.fenAfter,
      );
      expect(transposition.state, OpeningMatchState.knownTransition);
      expect(transposition.transposition, isTrue);
      expect(
        transposition.selectedCandidate?.openingName,
        "King's Indian Attack",
      );
      expect(transposition.totalCandidateCount, candidates.length);
      expect(candidates.length, greaterThan(1));

      final departure = _line('1. e4 e5 2. Nf3 Nc6 3. a3 h5');
      final leavingTheory = _lookup(index, departure[4], ply: 4);
      final afterDeparture = _lookup(index, departure[5], ply: 5);
      expect(leavingTheory.state, OpeningMatchState.leftTheory);
      expect(leavingTheory.reasonCode, 'known_position_unknown_transition');
      expect(leavingTheory.leavingTheoryPly, 5);
      expect(afterDeparture.state, OpeningMatchState.noMatch);
    });

    test('corrupt and wrong-byte artifacts fail explicitly', () {
      const malformed = 'eco\tname\tpgn\nB00\tBroken\t1. Zz\n';
      final malformedIndex = OpeningIndex.fromTsv(malformed);
      final wrongBytes = OpeningIndex.fromTsv(
        _tsv(<String>['B00\tKing Pawn\t1. e4']),
      );

      expect(
        malformedIndex.verification,
        OpeningArtifactVerification.invalidData,
      );
      expect(wrongBytes.verification, OpeningArtifactVerification.hashMismatch);
      expect(malformedIndex.isAvailable, isFalse);
      expect(wrongBytes.isAvailable, isFalse);
    });
  });
}

OpeningIndex _verifiedIndex(String tsv, {DateTime? buildTimestamp}) {
  final sourceHash = sha256.convert(utf8.encode(tsv)).toString();
  final probeIdentity = OpeningArtifactIdentity(
    datasetName: 'apex-test-openings',
    sourceRevision: 'test-v1',
    sourceSha256: sourceHash,
    contentSha256:
        '0000000000000000000000000000000000000000000000000000000000000000',
    licenseSpdx: 'CC0-1.0',
    provenanceReference: 'test-fixture',
  );
  final probe = OpeningIndex.fromTsv(tsv, identity: probeIdentity);
  final identity = OpeningArtifactIdentity(
    datasetName: probeIdentity.datasetName,
    sourceRevision: probeIdentity.sourceRevision,
    sourceSha256: sourceHash,
    contentSha256: probe.metrics.canonicalContentSha256,
    licenseSpdx: probeIdentity.licenseSpdx,
    provenanceReference: probeIdentity.provenanceReference,
  );
  final index = OpeningIndex.fromTsv(
    tsv,
    identity: identity,
    buildTimestamp: buildTimestamp,
  );
  expect(index.verification, OpeningArtifactVerification.verified);
  return index;
}

String _tsv(List<String> rows) => 'eco\tname\tpgn\n${rows.join('\n')}\n';

OpeningEvidence _lookup(
  OpeningIndex index,
  _TestMove move, {
  required int ply,
  bool standardStart = true,
}) => index.lookupTransition(
  fenBefore: move.fenBefore,
  playedMoveUci: move.uci,
  fenAfter: move.fenAfter,
  ply: ply,
  standardStart: standardStart,
);

List<_TestMove> _line(String pgn) {
  final cleaned = pgn.replaceAll(RegExp(r'\d+\.(?:\.\.)?'), ' ');
  final tokens = cleaned
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
  Position position = Chess.initial;
  final moves = <_TestMove>[];
  for (final san in tokens) {
    final move = position.parseSan(san)! as NormalMove;
    final before = position.fen;
    final after = position.play(move);
    moves.add(
      _TestMove(
        fenBefore: before,
        fenAfter: after.fen,
        uci: _normaliseCastling(move.uci),
      ),
    );
    position = after;
  }
  return moves;
}

_TestMove _setupMove(String fen, String uci) {
  final position = Chess.fromSetup(Setup.parseFen(fen));
  final move = Move.parse(uci)! as NormalMove;
  expect(position.isLegal(move), isTrue);
  return _TestMove(
    fenBefore: position.fen,
    fenAfter: position.play(move).fen,
    uci: uci,
  );
}

String _normaliseCastling(String uci) => switch (uci) {
  'e1h1' => 'e1g1',
  'e1a1' => 'e1c1',
  'e8h8' => 'e8g8',
  'e8a8' => 'e8c8',
  _ => uci,
};

class _TestMove {
  const _TestMove({
    required this.fenBefore,
    required this.fenAfter,
    required this.uci,
  });

  final String fenBefore;
  final String fenAfter;
  final String uci;
}
