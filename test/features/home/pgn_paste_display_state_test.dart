import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/features/home/presentation/pgn_paste_display_state.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

void main() {
  const identity = GameIdentityService();

  test('PGN paste input auto-collapse is enabled after valid PGN parse', () {
    const pgn = '''
[Event "Rated blitz game"]
[White "ApexUser"]
[Black "RojoHijo"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 1-0
''';
    final preview = identity.parsePgn(pgn, userHandle: 'ApexUser');

    expect(
      PgnPasteDisplayState.shouldCollapseInput(pgn: pgn, identity: preview),
      isTrue,
    );
  });

  test('PGN paste input stays expanded when parsing has no moves', () {
    const pgn = '[White "ApexUser"]';
    final preview = identity.parsePgn(pgn, userHandle: 'ApexUser');

    expect(
      PgnPasteDisplayState.shouldCollapseInput(pgn: pgn, identity: preview),
      isFalse,
    );
  });

  test('PGN side copy uses played-side wording', () {
    expect(PgnPasteDisplayState.sideLabel(true), 'You played White');
    expect(PgnPasteDisplayState.sideLabel(false), 'You played Black');
    expect(
      PgnPasteDisplayState.sideLabel(true),
      isNot(contains('Detected perspective')),
    );
    expect(PgnPasteDisplayState.sideLabel(false), isNot(contains('You:')));
  });

  test('PGN opening lookup returns a known opening from local ECO data', () {
    const pgn = '''
1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *
''';
    final preview = identity.parsePgn(pgn);
    final index = _verifiedOpeningIndex(
      'eco\tname\tpgn\nC60\tRuy Lopez\t1. e4 e5 2. Nf3 Nc6 3. Bb5\n',
    );

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        openingLookup: index,
      ),
      'C60 · Ruy Lopez',
    );
    expect(index.lookupCount, 6);
  });

  test('PGN preview does not invent a common opening without evidence', () {
    const pgn = '1. e4 c5 2. Nf3 d6 *';
    final preview = identity.parsePgn(pgn);
    final index = _verifiedOpeningIndex('eco\tname\tpgn\n');

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        openingLookup: index,
      ),
      ApexCopy.openingNotDetected,
    );
  });

  test('PGN headers cannot override authoritative no-match evidence', () {
    const pgn = '''
[ECO "B20"]
[Opening "Sicilian Defense"]

1. h4 h5 *
''';
    final preview = identity.parsePgn(pgn);
    final index = _verifiedOpeningIndex('eco\tname\tpgn\n');

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        openingLookup: index,
      ),
      ApexCopy.openingNotDetected,
    );
  });

  test('loading and unavailable opening data remain visibly distinct', () {
    const pgn = '1. e4 *';
    final preview = identity.parsePgn(pgn);

    expect(
      PgnPasteDisplayState.openingLabel(pgn: pgn, identity: preview),
      ApexCopy.openingDataLoading,
    );
    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        openingLookup: OpeningIndex.unavailable(),
      ),
      ApexCopy.openingDataUnavailable,
    );
  });

  test('PGN unknown opening returns fallback copy', () {
    const pgn = '1. h4 h5 2. Rh3 Rh6 *';
    final preview = identity.parsePgn(pgn);
    final index = _verifiedOpeningIndex('eco\tname\tpgn\n');

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        openingLookup: index,
      ),
      ApexCopy.openingNotDetected,
    );
  });

  test('Setup/FEN games cannot inherit standard-start opening names', () {
    const pgn = '''
[Setup "1"]
[FEN "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"]
[Result "*"]

1. e4 *
''';
    final preview = identity.parsePgn(pgn);
    final index = _verifiedOpeningIndex(
      'eco\tname\tpgn\nB00\tKing\'s Pawn Opening\t1. e4\n',
    );

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        openingLookup: index,
      ),
      ApexCopy.openingNotDetected,
    );
    expect(index.lookupCount, 1);
  });
}

OpeningIndex _verifiedOpeningIndex(String body) {
  final probe = OpeningIndex.fromTsv(body);
  final identity = OpeningArtifactIdentity(
    datasetName: 'apex-test-openings',
    sourceRevision: 'fixture-v1',
    sourceSha256: probe.metrics.sourceSha256,
    contentSha256: probe.metrics.canonicalContentSha256,
    licenseSpdx: 'CC0-1.0',
    provenanceReference: 'test-fixture',
  );
  final index = OpeningIndex.fromTsv(body, identity: identity);
  expect(index.verification, OpeningArtifactVerification.verified);
  return index;
}
