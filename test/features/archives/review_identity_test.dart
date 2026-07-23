import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';

void main() {
  group('canonical GameId', () {
    test('has a deterministic v1 serialization and SHA-256 golden', () {
      final game = const CanonicalGameIdentityService().fromPgn(
        pgn: _basePgn,
        sourceProvider: 'pgn',
      );

      expect(game.gameId.algorithmVersion, 1);
      expect(
        game.canonicalIdentityMaterial,
        'apex-chess-game-id\n'
        'algorithm=1\n'
        'ruleset=8:standard\n'
        'starting-fen=56:rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/'
        'RNBQKBNR w KQkq - 0 1\n'
        'move-count=3\n'
        'move-0=4:e2e4\n'
        'move-1=4:e7e5\n'
        'move-2=4:g1f3\n',
      );
      expect(
        game.gameId.value,
        '456bfe070d82a301c43ab94d482c1f07131b77f6abfd53d719cf0372368f2b31',
      );
    });

    test(
      'comments, formatting, headers, and SAN annotations do not differ',
      () {
        const decorated = '''
[Event "Different title"]
[White "RENAMED"]
[Black "Someone else"]

1. e4! {comment} e5?! (1... c5) 2. Nf3 *
''';
        final service = const CanonicalGameIdentityService();
        expect(
          service
              .fromPgn(pgn: decorated, sourceProvider: 'chess.com')
              .gameId
              .value,
          service.fromPgn(pgn: _basePgn, sourceProvider: 'pgn').gameId.value,
        );
      },
    );

    test('different mainline and different starting FEN differ', () {
      final service = const CanonicalGameIdentityService();
      final base = service.fromPgn(pgn: _basePgn, sourceProvider: 'pgn');
      final mainline = service.fromPgn(
        pgn: '1. d4 d5 2. Nf3 *',
        sourceProvider: 'pgn',
      );
      final custom = service.fromPgn(
        pgn: '''
[SetUp "1"]
[FEN "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"]

1... e5 *
''',
        sourceProvider: 'pgn',
      );

      expect(mainline.gameId.value, isNot(base.gameId.value));
      expect(custom.gameId.value, isNot(base.gameId.value));
    });

    test('every FEN state field contributes to canonical identity', () {
      const startingFens = <String>[
        '8/8/8/8/8/8/8/K6k w - - 0 1',
        '8/8/8/8/8/8/8/K5Qk w - - 0 1',
        '8/8/8/8/8/8/8/K6k b - - 0 1',
        '8/8/8/8/8/8/8/K6k w KQkq - 0 1',
        '8/8/8/8/8/8/8/K6k w - e3 0 1',
        '8/8/8/8/8/8/8/K6k w - - 7 1',
        '8/8/8/8/8/8/8/K6k w - - 0 42',
      ];
      final ids = {
        for (final fen in startingFens)
          sha256
              .convert(
                utf8.encode(
                  CanonicalGameIdentityService.canonicalMaterial(
                    ruleset: 'standard',
                    startingFen: fen,
                    uciMoves: const <String>[],
                  ),
                ),
              )
              .toString(),
      };

      expect(ids, hasLength(startingFens.length));
    });

    test('serialization is length-delimited and UTF-8 deterministic', () {
      final material = CanonicalGameIdentityService.canonicalMaterial(
        ruleset: 'chess-960-é',
        startingFen: 'fen:with\nseparator',
        uciMoves: const ['e2e4', 'e7e5'],
      );

      expect(material, contains('ruleset=12:chess-960-é'));
      expect(material, contains('starting-fen=18:fen:with\nseparator'));
      expect(
        sha256.convert(utf8.encode(material)).toString(),
        sha256.convert(utf8.encode(material)).toString(),
      );
    });

    test('source metadata, timestamps, and header order are excluded', () {
      const reordered = '''
[Black "Beta"]
[Result "*"]
[Event "Événement"]
[White "Alpha"]

1. e4 e5 2. Nf3 *
''';
      final service = const CanonicalGameIdentityService();
      final first = service.fromPgn(
        pgn: _basePgn,
        sourceProvider: 'pgn',
        sourceGameId: 'local-one',
        importedAt: DateTime.utc(2020),
      );
      final second = service.fromPgn(
        pgn: reordered,
        sourceProvider: 'lichess',
        sourceGameId: 'remote-two',
        importedAt: DateTime.utc(2030),
      );

      expect(second.gameId.value, first.gameId.value);
    });
  });

  group('AnalysisVariantId', () {
    test('historic opening-v1 material and SHA-256 remain frozen', () {
      final game = const CanonicalGameIdentityService().fromPgn(
        pgn: _basePgn,
        sourceProvider: 'pgn',
      );
      final compatibility = AnalysisCompatibility.fromTimeline(
        gameId: game.gameId,
        timeline: _timeline().copyWith(openingBookVersion: 1),
      );

      expect(
        compatibility.canonicalMaterial,
        'apex-analysis-variant\n'
        'algorithm=1\n'
        'game=1:456bfe070d82a301c43ab94d482c1f07131b77f6abfd53d719cf0372368f2b31\n'
        'profile=11:fast_review\n'
        'profile-version=1\n'
        'provider=13:local_offline\n'
        'engine-declared=40:apex-stockfish-bridge/0.3.0|Stockfish 17\n'
        'engine-name=9:Stockfish\n'
        'engine-version=2:17\n'
        'bridge=27:apex-stockfish-bridge/0.3.0\n'
        'nnue=20:nn-37f18f62d772.nnue\n'
        'nnue-verification=configuredOnly\n'
        'depth=14\n'
        'movetime-ms=900\n'
        'nodes=unknown\n'
        'multipv=1\n'
        'candidate-verification=false\n'
        'analysis-schema=4\n'
        'classifier=6\n'
        'tactical=3\n'
        'opening=1\n'
        'score-perspective=1\n',
      );
      expect(
        AnalysisVariantId.fromCompatibility(compatibility).value,
        '709dfdbc459374152ec22fae5d22c65a06a3d43f31593317f7d3dfe66293654e',
      );
    });

    test('opening-v2 binds semantic artifact but not execution state', () {
      final game = const CanonicalGameIdentityService().fromPgn(
        pgn: _basePgn,
        sourceProvider: 'pgn',
      );
      String id(AnalysisTimeline timeline) =>
          AnalysisVariantId.fromCompatibility(
            AnalysisCompatibility.fromTimeline(
              gameId: game.gameId,
              timeline: timeline,
            ),
          ).value;
      final verified = _timeline().copyWith(
        openingBookVersion: 2,
        openingArtifact: _artifact,
        openingArtifactVerification: OpeningArtifactVerification.verified,
      );
      final unavailable = verified.copyWith(
        openingArtifactVerification: OpeningArtifactVerification.unavailable,
      );
      final provenanceOnly = verified.copyWith(
        openingArtifact: const OpeningArtifactIdentity(
          datasetName: 'apex-eco',
          sourceRevision: '2026-07-17',
          sourceSha256:
              'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
          contentSha256:
              'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
          licenseSpdx: 'MIT-0',
          provenanceReference: 'different-audit-path',
        ),
      );
      final changedContent = verified.copyWith(
        openingArtifact: const OpeningArtifactIdentity(
          datasetName: 'apex-eco',
          sourceRevision: '2026-07-17',
          sourceSha256:
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          contentSha256:
              'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
          licenseSpdx: 'MIT',
          provenanceReference: 'assets/openings/PROVENANCE.md',
        ),
      );

      expect(id(unavailable), id(verified));
      expect(id(provenanceOnly), id(verified));
      expect(id(changedContent), isNot(id(verified)));
      expect(
        AnalysisCompatibility.fromTimeline(
          gameId: game.gameId,
          timeline: verified,
        ).canonicalMaterial,
        contains('opening-artifact=${_artifact.semanticId}'),
      );
    });

    test('explanation contract uses variant v2 and changes compatibility', () {
      final game = const CanonicalGameIdentityService().fromPgn(
        pgn: _basePgn,
        sourceProvider: 'pgn',
      );
      final current = _timeline().copyWith(
        analysisSchemaVersion: kApexAnalysisSchemaVersion,
        openingBookVersion: kApexOpeningBookVersion,
        openingArtifact: _artifact,
        openingArtifactVerification: OpeningArtifactVerification.verified,
        explanationPolicyVersion: kApexExplanationPolicyVersion,
        explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
        explanationRendererVersion: kApexExplanationRendererVersion,
      );
      AnalysisVariantId idFor(AnalysisTimeline timeline) =>
          AnalysisVariantId.fromCompatibility(
            AnalysisCompatibility.fromTimeline(
              gameId: game.gameId,
              timeline: timeline,
            ),
          );

      final currentId = idFor(current);
      final rendererChanged = idFor(
        current.copyWith(explanationRendererVersion: 3),
      );
      final historicId = idFor(
        current.copyWith(
          analysisSchemaVersion: kApexLegacyAnalysisSchemaVersion,
          explanationPolicyVersion: 0,
          explanationClaimSchemaVersion: 0,
          explanationRendererVersion: 0,
        ),
      );

      expect(currentId.algorithmVersion, kAnalysisVariantAlgorithmVersion);
      expect(rendererChanged.value, isNot(currentId.value));
      expect(
        historicId.algorithmVersion,
        kLegacyAnalysisVariantAlgorithmVersion,
      );
    });

    test('opening-v2 without a valid artifact fails closed', () {
      final game = const CanonicalGameIdentityService().fromPgn(
        pgn: _basePgn,
        sourceProvider: 'pgn',
      );
      final compatibility = AnalysisCompatibility.fromTimeline(
        gameId: game.gameId,
        timeline: _timeline().copyWith(openingBookVersion: 2),
      );

      expect(
        () => AnalysisVariantId.fromCompatibility(compatibility),
        throwsStateError,
      );
    });

    test(
      'semantic compatibility changes identity, transient run time does not',
      () {
        final game = const CanonicalGameIdentityService().fromPgn(
          pgn: _basePgn,
          sourceProvider: 'pgn',
        );
        final fast = _timeline().copyWith(classifierVersion: 5);
        final samePolicyLater = fast.copyWith(
          completedAt: DateTime.utc(2030, 1, 1),
          engineSearchCount: 99,
          engineCacheHitCount: 50,
        );
        final deep = fast.copyWith(
          analysisMode: 'deep',
          analysisProfileId: 'deep_review',
          requestedDepth: 22,
          movetimeMs: 6000,
          multipv: 3,
          candidateVerificationEnabled: true,
        );
        final engine18 = fast.copyWith(
          engineVersion: 'apex-stockfish-bridge/0.4.0|Stockfish 18',
        );
        final classifier6 = fast.copyWith(
          classifierVersion: kApexClassifierVersion,
        );

        String id(AnalysisTimeline timeline) =>
            AnalysisVariantId.fromCompatibility(
              AnalysisCompatibility.fromTimeline(
                gameId: game.gameId,
                timeline: timeline,
              ),
            ).value;

        expect(id(samePolicyLater), id(fast));
        expect(id(deep), isNot(id(fast)));
        expect(id(engine18), isNot(id(fast)));
        expect(id(classifier6), isNot(id(fast)));
      },
    );

    test('unknown runtime provenance remains explicit', () {
      final engine = ReviewEngineIdentity.fromDeclared('unknown');
      expect(engine.engineName, isNull);
      expect(engine.engineVersion, isNull);
      expect(engine.bridgeIdentity, isNull);
      expect(engine.configuredNnueIdentity, isNull);
      expect(engine.identityVerification, ProvenanceVerification.unknown);
      expect(engine.nnueVerification, ProvenanceVerification.unknown);
    });
  });
}

AnalysisTimeline _timeline() => AnalysisTimeline(
  startingFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
  moves: const [],
  headers: const {},
  winPercentages: const [],
  analysisMode: 'quick',
  analysisProfileId: 'fast_review',
  providerId: 'local_offline',
  engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
  requestedDepth: 14,
  depth: 14,
  movetimeMs: 900,
  multipv: 1,
  candidateVerificationEnabled: false,
  completedAt: DateTime.utc(2026, 7, 11),
  engineSearchCount: 4,
  engineCacheHitCount: 2,
);

const _basePgn = '''
[Event "Canonical"]
[White "Alpha"]
[Black "Beta"]
[Result "*"]

1. e4 e5 2. Nf3 *
''';

const _artifact = OpeningArtifactIdentity(
  datasetName: 'apex-eco',
  sourceRevision: '2026-07-17',
  sourceSha256:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  contentSha256:
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  licenseSpdx: 'MIT',
  provenanceReference: 'assets/openings/PROVENANCE.md',
);
