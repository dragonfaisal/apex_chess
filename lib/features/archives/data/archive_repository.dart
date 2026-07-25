/// Non-destructive persistence boundary for canonical ReviewDocuments and the
/// bounded legacy ArchivedGame box.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';

const int kReviewStoreSchemaVersion = 1;
const int kReviewIndexSchemaVersion = 1;
const int kReviewMigrationSchemaVersion = 1;

class ReviewStoreDiagnostics {
  const ReviewStoreDiagnostics({
    this.documents = 0,
    this.indexEntries = 0,
    this.legacyRecords = 0,
    this.migratedRecords = 0,
    this.legacyUntrustedRecords = 0,
    this.quarantineRecords = 0,
    this.repairedIndexes = 0,
    this.orphanedIndexes = 0,
  });

  final int documents;
  final int indexEntries;
  final int legacyRecords;
  final int migratedRecords;
  final int legacyUntrustedRecords;
  final int quarantineRecords;
  final int repairedIndexes;
  final int orphanedIndexes;
}

enum ReviewDocumentSourceIssueKind {
  corruptCanonical,
  legacyUntrusted,
  legacyMalformed,
}

class ValidatedReviewDocumentSource {
  const ValidatedReviewDocumentSource({
    required this.document,
    required this.contentDigest,
  });

  final ReviewDocument document;
  final String contentDigest;
}

class ReviewDocumentSourceIssue {
  const ReviewDocumentSourceIssue({
    required this.sourceKey,
    required this.kind,
  });

  final String sourceKey;
  final ReviewDocumentSourceIssueKind kind;
}

class ReviewDocumentSourceScan {
  const ReviewDocumentSourceScan({
    required this.sources,
    required this.issues,
    required this.revision,
  });

  final List<ValidatedReviewDocumentSource> sources;
  final List<ReviewDocumentSourceIssue> issues;
  final int revision;
}

class ArchiveRepository {
  ArchiveRepository._({
    required Box<String> legacyBox,
    required Box<String> documentBox,
    required Box<String> indexBox,
    required Box<String> migrationBox,
    required Box<String> quarantineBox,
  }) : _legacyBox = legacyBox,
       _documentBox = documentBox,
       _indexBox = indexBox,
       _migrationBox = migrationBox,
       _quarantineBox = quarantineBox;

  /// Chapter 1 and older records remain in this box untouched by migration.
  static const String boxName = 'apex_archived_games';
  static const String documentBoxName = 'apex_review_documents_v1';
  static const String indexBoxName = 'apex_review_index_v1';
  static const String migrationBoxName = 'apex_review_migration_v1';
  static const String quarantineBoxName = 'apex_review_quarantine_v1';

  static Future<ArchiveRepository> open() async {
    final boxes = await Future.wait<Box<String>>([
      Hive.openBox<String>(boxName),
      Hive.openBox<String>(documentBoxName),
      Hive.openBox<String>(indexBoxName),
      Hive.openBox<String>(migrationBoxName),
      Hive.openBox<String>(quarantineBoxName),
    ]);
    final repository = ArchiveRepository._(
      legacyBox: boxes[0],
      documentBox: boxes[1],
      indexBox: boxes[2],
      migrationBox: boxes[3],
      quarantineBox: boxes[4],
    );
    await repository._repairAndMigrate();
    return repository;
  }

  final Box<String> _legacyBox;
  final Box<String> _documentBox;
  final Box<String> _indexBox;
  final Box<String> _migrationBox;
  final Box<String> _quarantineBox;

  ReviewStoreDiagnostics _diagnostics = const ReviewStoreDiagnostics();
  ReviewStoreDiagnostics get diagnostics => _diagnostics;
  int _contentRevision = 0;

  /// Legacy compatibility write. New product saves use [saveReviewDocument].
  Future<void> save(ArchivedGame game) async {
    await _legacyBox.put(game.id, jsonEncode(game.toJson()));
    _contentRevision++;
  }

  Future<String> saveReviewDocument(ReviewDocument document) async {
    document.validate();
    if (!document.isTrustedComplete) {
      throw const ReviewDocumentValidationException(
        'Only complete trusted documents may be saved.',
      );
    }

    final existingRaw = _documentBox.get(document.documentId);
    final existing = loadReviewDocument(document.documentId);
    if (existingRaw != null && existing == null) {
      await _quarantine(
        sourceBox: documentBoxName,
        sourceKey: document.documentId,
        raw: existingRaw,
        reason: 'Invalid canonical document replaced by a validated rerun.',
      );
    }
    if (existing != null &&
        !document.hasEqualOrStrongerEvidenceThan(existing)) {
      await _repairIndexFor(existing);
      _refreshDiagnostics();
      return existing.documentId;
    }

    final raw = document.encode();
    await _documentBox.put(document.documentId, raw);
    await _repairIndexFor(document);

    final readBack = loadReviewDocument(document.documentId);
    if (readBack == null ||
        readBack.variantId.value != document.variantId.value ||
        readBack.game.gameId.value != document.game.gameId.value) {
      throw const ReviewDocumentValidationException(
        'Review document write/read verification failed.',
      );
    }
    final storedIndex = _readIndex(document.documentId);
    if (storedIndex == null || !storedIndex.matchesDocument(readBack)) {
      throw const ReviewDocumentValidationException(
        'Review index write/read verification failed.',
      );
    }
    _refreshDiagnostics();
    _contentRevision++;
    return document.documentId;
  }

  Future<void> _repairIndexFor(ReviewDocument document) async {
    final existingRaw = _indexBox.get(document.documentId);
    final existingIndex = _readIndex(document.documentId);
    if (existingRaw != null &&
        (existingIndex == null || !existingIndex.matchesDocument(document))) {
      await _quarantine(
        sourceBox: indexBoxName,
        sourceKey: document.documentId,
        raw: existingRaw,
        reason: 'Index payload failed validation against its document.',
      );
    }
    final index = _ReviewIndexEntry.fromDocument(document);
    await _indexBox.put(document.documentId, jsonEncode(index.toJson()));
  }

  ReviewDocument? loadReviewDocument(String documentId) {
    final raw = _documentBox.get(documentId);
    if (raw == null) return null;
    try {
      final document = ReviewDocument.decodeAndValidate(raw);
      if (document.documentId != documentId) return null;
      return document;
    } on Object {
      return null;
    }
  }

  List<ReviewDocument> listVariants(String gameId) {
    final out = <ReviewDocument>[];
    for (final key in _indexBox.keys) {
      final id = key.toString();
      final index = _readIndex(id);
      if (index?.gameId != gameId) continue;
      final document = loadReviewDocument(id);
      if (document != null) out.add(document);
    }
    out.sort((a, b) => b.run.completedAt.compareTo(a.run.completedAt));
    return out;
  }

  /// Validated, read-only source boundary for derived local analytics.
  ///
  /// Canonical documents are decoded exactly once per scan. Raw Hive payloads
  /// and legacy migration details remain inside the repository boundary.
  ///
  /// Decoding yields between bounded batches so a cold analytics scan cannot
  /// monopolize the Flutter event loop. If archive content changes during the
  /// scan, the stale snapshot is discarded and rebuilt from the new revision.
  Future<ReviewDocumentSourceScan> scanValidatedReviewDocuments({
    int yieldEvery = 2,
  }) async {
    if (yieldEvery < 1) {
      throw ArgumentError.value(yieldEvery, 'yieldEvery', 'Must be positive.');
    }
    while (true) {
      final revision = _contentRevision;
      final documentEntries = [
        for (final key in _documentBox.keys)
          MapEntry(key.toString(), _documentBox.get(key)),
      ];
      final legacyEntries = [
        for (final key in _legacyBox.keys)
          MapEntry(key.toString(), _legacyBox.get(key)),
      ];
      final sources = <ValidatedReviewDocumentSource>[];
      final issues = <ReviewDocumentSourceIssue>[];
      final validatedDocumentIds = <String>{};
      var processed = 0;

      await Future<void>.delayed(Duration.zero);
      for (final entry in documentEntries) {
        if (processed > 0 && processed % yieldEvery == 0) {
          await Future<void>.delayed(Duration.zero);
        }
        processed++;
        final documentId = entry.key;
        final raw = entry.value;
        if (raw == null) continue;
        try {
          final document = ReviewDocument.decodeAndValidate(raw);
          if (document.documentId != documentId) {
            throw const ReviewDocumentValidationException(
              'Document key does not match document id.',
            );
          }
          sources.add(
            ValidatedReviewDocumentSource(
              document: document,
              contentDigest: _fingerprint(raw),
            ),
          );
          validatedDocumentIds.add(document.documentId);
        } on Object {
          issues.add(
            ReviewDocumentSourceIssue(
              sourceKey: documentId,
              kind: ReviewDocumentSourceIssueKind.corruptCanonical,
            ),
          );
        }
      }

      for (final entry in legacyEntries) {
        if (processed > 0 && processed % yieldEvery == 0) {
          await Future<void>.delayed(Duration.zero);
        }
        processed++;
        final sourceKey = entry.key;
        final raw = entry.value;
        if (raw == null) continue;
        final state = _migrationState(sourceKey);
        if (state?.isMigrated == true &&
            state?.documentId != null &&
            validatedDocumentIds.contains(state!.documentId)) {
          continue;
        }
        issues.add(
          ReviewDocumentSourceIssue(
            sourceKey: sourceKey,
            kind: state?.disposition == _MigrationDisposition.quarantined
                ? ReviewDocumentSourceIssueKind.legacyMalformed
                : ReviewDocumentSourceIssueKind.legacyUntrusted,
          ),
        );
      }

      if (revision != _contentRevision) continue;
      sources.sort(
        (a, b) => a.document.documentId.compareTo(b.document.documentId),
      );
      issues.sort((a, b) => a.sourceKey.compareTo(b.sourceKey));
      return ReviewDocumentSourceScan(
        sources: List.unmodifiable(sources),
        issues: List.unmodifiable(issues),
        revision: revision,
      );
    }
  }

  /// Compact archive list. Canonical timelines are not decoded here.
  List<ArchivedGame> loadAll() {
    final out = <ArchivedGame>[];
    for (final key in _indexBox.keys) {
      final id = key.toString();
      final index = _readIndex(id);
      if (index == null || !_documentBox.containsKey(id)) continue;
      out.add(index.toArchivedGame());
    }

    for (final key in _legacyBox.keys) {
      final sourceKey = key.toString();
      final raw = _legacyBox.get(key);
      if (raw == null) continue;
      final state = _migrationState(sourceKey);
      if (state?.fingerprint == _fingerprint(raw) &&
          state?.isMigrated == true &&
          state?.documentId != null) {
        final migrated = loadReviewDocument(state!.documentId!);
        if (migrated != null && migrated.game.sourceGameId == sourceKey) {
          continue;
        }
      }
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) throw const FormatException('root is not object');
        out.add(ArchivedGame.fromJson(decoded));
      } on Object {
        out.add(_unavailableLegacyEntry(sourceKey, state?.reason));
      }
    }
    out.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    return out;
  }

  ArchivedGame? find(String id) {
    final document = loadReviewDocument(id);
    if (document != null) return _archivedGameFromDocument(document);

    final raw = _legacyBox.get(id);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return ArchivedGame.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  Future<void> delete(String id) async {
    final existed =
        _indexBox.containsKey(id) ||
        _documentBox.containsKey(id) ||
        _legacyBox.containsKey(id);
    if (_indexBox.containsKey(id) || _documentBox.containsKey(id)) {
      await _documentBox.delete(id);
      await _indexBox.delete(id);
    } else {
      await _legacyBox.delete(id);
    }
    _refreshDiagnostics();
    if (existed) _contentRevision++;
  }

  Future<void> clear() async {
    final hadContent =
        _legacyBox.isNotEmpty ||
        _documentBox.isNotEmpty ||
        _indexBox.isNotEmpty ||
        _migrationBox.isNotEmpty ||
        _quarantineBox.isNotEmpty;
    await Future.wait([
      _legacyBox.clear(),
      _documentBox.clear(),
      _indexBox.clear(),
      _migrationBox.clear(),
      _quarantineBox.clear(),
    ]);
    _refreshDiagnostics();
    if (hadContent) _contentRevision++;
  }

  Future<void> _repairAndMigrate() async {
    var repaired = 0;
    var orphaned = 0;

    for (final key in _documentBox.keys.toList(growable: false)) {
      final documentId = key.toString();
      final raw = _documentBox.get(key);
      if (raw == null) continue;
      ReviewDocument document;
      try {
        document = ReviewDocument.decodeAndValidate(raw);
        if (document.documentId != documentId) {
          throw const ReviewDocumentValidationException(
            'Document key does not match document id.',
          );
        }
      } on Object catch (error) {
        await _quarantine(
          sourceBox: documentBoxName,
          sourceKey: documentId,
          raw: raw,
          reason: 'Invalid canonical document: ${error.runtimeType}',
        );
        await _indexBox.delete(documentId);
        continue;
      }
      final index = _readIndex(documentId);
      if (index == null || !index.matchesDocument(document)) {
        await _repairIndexFor(document);
        repaired++;
      }
    }

    for (final key in _indexBox.keys.toList(growable: false)) {
      final documentId = key.toString();
      if (_documentBox.containsKey(documentId)) continue;
      final raw = _indexBox.get(key);
      if (raw != null) {
        await _quarantine(
          sourceBox: indexBoxName,
          sourceKey: documentId,
          raw: raw,
          reason: 'Index entry has no document.',
        );
      }
      await _indexBox.delete(key);
      orphaned++;
    }

    for (final key in _legacyBox.keys.toList(growable: false)) {
      final sourceKey = key.toString();
      final raw = _legacyBox.get(key);
      if (raw == null) continue;
      final fingerprint = _fingerprint(raw);
      final prior = _migrationState(sourceKey);
      if (prior?.fingerprint == fingerprint &&
          prior?.isFinal == true &&
          prior?.isMigrated == false) {
        continue;
      }

      ArchivedGame legacy;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) throw const FormatException('root is not object');
        legacy = ArchivedGame.fromJson(decoded);
      } on Object catch (error) {
        final reason = 'Malformed legacy record: ${error.runtimeType}';
        await _quarantine(
          sourceBox: boxName,
          sourceKey: sourceKey,
          raw: raw,
          reason: reason,
        );
        await _writeMigrationState(
          _MigrationState.quarantined(
            sourceKey: sourceKey,
            fingerprint: fingerprint,
            reason: reason,
          ),
        );
        continue;
      }

      final timeline = legacy.cachedTimeline;
      if (timeline == null ||
          !timeline.isComplete ||
          !_canMigrateLegacyTimeline(legacy, timeline)) {
        await _writeMigrationState(
          _MigrationState.legacyUntrusted(
            sourceKey: sourceKey,
            fingerprint: fingerprint,
            reason: 'Legacy record lacks current complete analysis evidence.',
          ),
        );
        continue;
      }

      try {
        final document = ReviewDocument.fromCompletedTimeline(
          pgn: legacy.pgn,
          timeline: timeline,
          sourceProvider: legacy.source.wire,
          sourceGameId: sourceKey,
          importedAt: legacy.playedAt,
          userIsWhite: legacy.analyzedUserIsWhite,
          createdAt: legacy.analyzedAt,
          timeControl: legacy.timeControl,
        );
        if (prior?.fingerprint == fingerprint &&
            prior?.isMigrated == true &&
            prior?.documentId == document.documentId &&
            loadReviewDocument(document.documentId) != null) {
          continue;
        }
        await saveReviewDocument(document);
        await _writeMigrationState(
          _MigrationState.migrated(
            sourceKey: sourceKey,
            fingerprint: fingerprint,
            documentId: document.documentId,
          ),
        );
      } on Object catch (error) {
        await _writeMigrationState(
          _MigrationState.legacyUntrusted(
            sourceKey: sourceKey,
            fingerprint: fingerprint,
            reason:
                'Legacy evidence failed canonical validation: '
                '${error.runtimeType}',
          ),
        );
      }
    }

    _refreshDiagnostics(repairedIndexes: repaired, orphanedIndexes: orphaned);
  }

  bool _canMigrateLegacyTimeline(
    ArchivedGame legacy,
    AnalysisTimeline timeline,
  ) {
    if (legacy.isCacheCurrent) return true;
    return legacy.openingBookVersion == kApexLegacyOpeningBookVersion &&
        timeline.openingBookVersion == kApexLegacyOpeningBookVersion &&
        legacy.classifierVersion == kApexClassifierVersion &&
        timeline.classifierVersion == kApexClassifierVersion &&
        legacy.tacticalVerifierVersion == kApexTacticalVerifierVersion &&
        timeline.tacticalVerifierVersion == kApexTacticalVerifierVersion &&
        legacy.analysisSchemaVersion == kApexLegacyAnalysisSchemaVersion &&
        timeline.analysisSchemaVersion == kApexLegacyAnalysisSchemaVersion &&
        (legacy.cacheKey == null || timeline.cacheKey == legacy.cacheKey);
  }

  _ReviewIndexEntry? _readIndex(String documentId) {
    final raw = _indexBox.get(documentId);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final index = _ReviewIndexEntry.fromJson(decoded);
      if (index.documentId != documentId ||
          index.schemaVersion != kReviewIndexSchemaVersion) {
        return null;
      }
      return index;
    } on Object {
      return null;
    }
  }

  _MigrationState? _migrationState(String sourceKey) {
    final raw = _migrationBox.get(sourceKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return _MigrationState.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  Future<void> _writeMigrationState(_MigrationState state) =>
      _migrationBox.put(state.sourceKey, jsonEncode(state.toJson()));

  Future<void> _quarantine({
    required String sourceBox,
    required String sourceKey,
    required String raw,
    required String reason,
  }) async {
    final fingerprint = _fingerprint(raw);
    final quarantineKey = '$sourceBox:$sourceKey:$fingerprint';
    if (_quarantineBox.containsKey(quarantineKey)) return;
    await _quarantineBox.put(
      quarantineKey,
      jsonEncode({
        'schemaVersion': kReviewMigrationSchemaVersion,
        'sourceBox': sourceBox,
        'sourceKey': sourceKey,
        'fingerprint': fingerprint,
        'reason': reason,
        'raw': raw,
        'quarantinedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  void _refreshDiagnostics({int repairedIndexes = 0, int orphanedIndexes = 0}) {
    var migrated = 0;
    var legacyUntrusted = 0;
    for (final raw in _migrationBox.values) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) continue;
        final state = _MigrationState.fromJson(decoded);
        if (state.isMigrated) migrated++;
        if (state.disposition == _MigrationDisposition.legacyUntrusted) {
          legacyUntrusted++;
        }
      } on Object {
        // A malformed migration marker is non-authoritative and ignored.
      }
    }
    _diagnostics = ReviewStoreDiagnostics(
      documents: _documentBox.length,
      indexEntries: _indexBox.length,
      legacyRecords: _legacyBox.length,
      migratedRecords: migrated,
      legacyUntrustedRecords: legacyUntrusted,
      quarantineRecords: _quarantineBox.length,
      repairedIndexes: repairedIndexes,
      orphanedIndexes: orphanedIndexes,
    );
  }
}

class _ReviewIndexEntry {
  const _ReviewIndexEntry({
    required this.schemaVersion,
    required this.aggregateCacheVersion,
    required this.documentId,
    required this.gameId,
    required this.variantId,
    required this.source,
    required this.white,
    required this.black,
    required this.whiteRating,
    required this.blackRating,
    required this.result,
    required this.playedAt,
    required this.analyzedAt,
    required this.profileId,
    required this.providerId,
    required this.engineIdentity,
    required this.requestedDepth,
    required this.achievedDepth,
    required this.requestedMovetimeMs,
    required this.multiPv,
    required this.candidateVerificationEnabled,
    required this.qualityCounts,
    required this.verifiedAcpl,
    required this.cpLossSampleCount,
    required this.totalPlies,
    required this.openingName,
    required this.ecoCode,
    required this.timeControl,
    required this.userIsWhite,
    required this.classifierVersion,
    required this.tacticalVerifierVersion,
    required this.openingBookVersion,
    required this.analysisSchemaVersion,
  });

  final int schemaVersion;
  final int aggregateCacheVersion;
  final String documentId;
  final String gameId;
  final String variantId;
  final String source;
  final String white;
  final String black;
  final String? whiteRating;
  final String? blackRating;
  final String result;
  final DateTime? playedAt;
  final DateTime analyzedAt;
  final String profileId;
  final String providerId;
  final String engineIdentity;
  final int? requestedDepth;
  final int? achievedDepth;
  final int? requestedMovetimeMs;
  final int? multiPv;
  final bool candidateVerificationEnabled;
  final Map<MoveQuality, int> qualityCounts;
  final double? verifiedAcpl;
  final int cpLossSampleCount;
  final int totalPlies;
  final String? openingName;
  final String? ecoCode;
  final String? timeControl;
  final bool? userIsWhite;
  final int classifierVersion;
  final int tacticalVerifierVersion;
  final int openingBookVersion;
  final int analysisSchemaVersion;

  factory _ReviewIndexEntry.fromDocument(ReviewDocument document) {
    final headers = document.game.headers;
    final opening = document.compatibility.openingBookVersion >= 2
        ? OpeningEvidence.deepestNamed(
            document.timeline.moves
                .map((move) => move.openingEvidence)
                .whereType<OpeningEvidence>(),
          )
        : null;
    final useStoredOpeningEvidence =
        document.compatibility.openingBookVersion >= 2;
    return _ReviewIndexEntry(
      schemaVersion: kReviewIndexSchemaVersion,
      aggregateCacheVersion: kReviewAggregateCacheVersion,
      documentId: document.documentId,
      gameId: document.game.gameId.value,
      variantId: document.variantId.value,
      source: document.game.sourceProvider,
      white: headers['White'] ?? 'White',
      black: headers['Black'] ?? 'Black',
      whiteRating: headers['WhiteElo'],
      blackRating: headers['BlackElo'],
      result: headers['Result'] ?? '*',
      playedAt: document.game.importedAt,
      analyzedAt: document.run.completedAt,
      profileId: document.compatibility.profileId,
      providerId: document.compatibility.providerId,
      engineIdentity: document.compatibility.engine.declaredIdentity,
      requestedDepth: document.compatibility.searchPolicy.requestedDepth,
      achievedDepth: document.run.achievedDepth,
      requestedMovetimeMs:
          document.compatibility.searchPolicy.requestedMovetimeMs,
      multiPv: document.compatibility.searchPolicy.multiPv,
      candidateVerificationEnabled:
          document.compatibility.searchPolicy.candidateVerificationEnabled,
      qualityCounts: document.classificationCounts,
      verifiedAcpl: document.verifiedAcpl,
      cpLossSampleCount: document.cpLossEligibleCount,
      totalPlies: document.timeline.totalPlies,
      openingName: useStoredOpeningEvidence
          ? opening?.openingName
          : headers['Opening'],
      ecoCode: useStoredOpeningEvidence ? opening?.ecoCode : headers['ECO'],
      timeControl: headers['TimeControl'],
      userIsWhite: document.userIsWhite,
      classifierVersion: document.compatibility.classifierVersion,
      tacticalVerifierVersion: document.compatibility.tacticalVerifierVersion,
      openingBookVersion: document.compatibility.openingBookVersion,
      analysisSchemaVersion: document.compatibility.analysisSchemaVersion,
    );
  }

  bool matchesDocument(ReviewDocument document) {
    final expected = _ReviewIndexEntry.fromDocument(document);
    return schemaVersion == expected.schemaVersion &&
        aggregateCacheVersion == expected.aggregateCacheVersion &&
        documentId == expected.documentId &&
        gameId == expected.gameId &&
        variantId == expected.variantId &&
        source == expected.source &&
        white == expected.white &&
        black == expected.black &&
        whiteRating == expected.whiteRating &&
        blackRating == expected.blackRating &&
        result == expected.result &&
        playedAt == expected.playedAt &&
        analyzedAt == expected.analyzedAt &&
        profileId == expected.profileId &&
        providerId == expected.providerId &&
        engineIdentity == expected.engineIdentity &&
        requestedDepth == expected.requestedDepth &&
        achievedDepth == expected.achievedDepth &&
        requestedMovetimeMs == expected.requestedMovetimeMs &&
        multiPv == expected.multiPv &&
        candidateVerificationEnabled == expected.candidateVerificationEnabled &&
        _sameQualityCounts(qualityCounts, expected.qualityCounts) &&
        verifiedAcpl == expected.verifiedAcpl &&
        cpLossSampleCount == expected.cpLossSampleCount &&
        totalPlies == expected.totalPlies &&
        openingName == expected.openingName &&
        ecoCode == expected.ecoCode &&
        timeControl == expected.timeControl &&
        userIsWhite == expected.userIsWhite &&
        classifierVersion == expected.classifierVersion &&
        tacticalVerifierVersion == expected.tacticalVerifierVersion &&
        openingBookVersion == expected.openingBookVersion &&
        analysisSchemaVersion == expected.analysisSchemaVersion;
  }

  ArchivedGame toArchivedGame() => ArchivedGame(
    id: documentId,
    source: ArchiveSource.fromWire(source),
    white: white,
    black: black,
    whiteRating: whiteRating,
    blackRating: blackRating,
    result: result,
    playedAt: playedAt,
    analyzedAt: analyzedAt,
    depth: achievedDepth ?? requestedDepth ?? 0,
    pgn: '',
    qualityCounts: qualityCounts,
    averageCpLoss: verifiedAcpl ?? 0,
    cpLossSampleCount: cpLossSampleCount,
    totalPlies: totalPlies,
    openingName: openingName,
    ecoCode: ecoCode,
    classifierVersion: classifierVersion,
    analysisMode: profileId == 'fast_review'
        ? AnalysisMode.quick
        : AnalysisMode.deep,
    analysisProfileId: profileId,
    providerId: providerId,
    tacticalVerifierVersion: tacticalVerifierVersion,
    openingBookVersion: openingBookVersion,
    analysisSchemaVersion: analysisSchemaVersion,
    timeControl: timeControl,
    analysisMovetimeMs: requestedMovetimeMs,
    analysisMultiPv: multiPv,
    candidateVerificationEnabled: candidateVerificationEnabled,
    recordKind: ArchivedRecordKind.canonicalDocument,
    canonicalGameId: gameId,
    analysisVariantId: variantId,
    analyzedUserIsWhite: userIsWhite,
    engineIdentity: engineIdentity,
    canonicalIndexVerified: true,
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'aggregateCacheVersion': aggregateCacheVersion,
    'documentId': documentId,
    'gameId': gameId,
    'variantId': variantId,
    'source': source,
    'white': white,
    'black': black,
    'whiteRating': whiteRating,
    'blackRating': blackRating,
    'result': result,
    'playedAt': playedAt?.toUtc().toIso8601String(),
    'analyzedAt': analyzedAt.toUtc().toIso8601String(),
    'profileId': profileId,
    'providerId': providerId,
    'engineIdentity': engineIdentity,
    'requestedDepth': requestedDepth,
    'achievedDepth': achievedDepth,
    'requestedMovetimeMs': requestedMovetimeMs,
    'multiPv': multiPv,
    'candidateVerificationEnabled': candidateVerificationEnabled,
    'qualityCounts': {
      for (final entry in qualityCounts.entries) entry.key.name: entry.value,
    },
    'verifiedAcpl': verifiedAcpl,
    'cpLossSampleCount': cpLossSampleCount,
    'totalPlies': totalPlies,
    'openingName': openingName,
    'ecoCode': ecoCode,
    'timeControl': timeControl,
    'userIsWhite': userIsWhite,
    'classifierVersion': classifierVersion,
    'tacticalVerifierVersion': tacticalVerifierVersion,
    'openingBookVersion': openingBookVersion,
    'analysisSchemaVersion': analysisSchemaVersion,
  };

  factory _ReviewIndexEntry.fromJson(Map<dynamic, dynamic> json) {
    final counts = (json['qualityCounts'] as Map?) ?? const {};
    return _ReviewIndexEntry(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      aggregateCacheVersion:
          (json['aggregateCacheVersion'] as num?)?.toInt() ?? 0,
      documentId: json['documentId'] as String,
      gameId: json['gameId'] as String,
      variantId: json['variantId'] as String,
      source: json['source'] as String,
      white: json['white'] as String,
      black: json['black'] as String,
      whiteRating: json['whiteRating'] as String?,
      blackRating: json['blackRating'] as String?,
      result: json['result'] as String,
      playedAt: json['playedAt'] == null
          ? null
          : DateTime.parse(json['playedAt'] as String).toUtc(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String).toUtc(),
      profileId: json['profileId'] as String,
      providerId: json['providerId'] as String,
      engineIdentity: json['engineIdentity'] as String,
      requestedDepth: (json['requestedDepth'] as num?)?.toInt(),
      achievedDepth: (json['achievedDepth'] as num?)?.toInt(),
      requestedMovetimeMs: (json['requestedMovetimeMs'] as num?)?.toInt(),
      multiPv: (json['multiPv'] as num?)?.toInt(),
      candidateVerificationEnabled:
          json['candidateVerificationEnabled'] as bool? ?? false,
      qualityCounts: {
        for (final quality in MoveQuality.values)
          if (counts[quality.name] != null)
            quality: (counts[quality.name] as num).toInt(),
      },
      verifiedAcpl: (json['verifiedAcpl'] as num?)?.toDouble(),
      cpLossSampleCount: (json['cpLossSampleCount'] as num).toInt(),
      totalPlies: (json['totalPlies'] as num).toInt(),
      openingName: json['openingName'] as String?,
      ecoCode: json['ecoCode'] as String?,
      timeControl: json['timeControl'] as String?,
      userIsWhite: json['userIsWhite'] as bool?,
      classifierVersion: (json['classifierVersion'] as num).toInt(),
      tacticalVerifierVersion: (json['tacticalVerifierVersion'] as num).toInt(),
      openingBookVersion: (json['openingBookVersion'] as num).toInt(),
      analysisSchemaVersion: (json['analysisSchemaVersion'] as num).toInt(),
    );
  }
}

bool _sameQualityCounts(
  Map<MoveQuality, int> left,
  Map<MoveQuality, int> right,
) {
  for (final quality in MoveQuality.values) {
    if ((left[quality] ?? 0) != (right[quality] ?? 0)) return false;
  }
  return true;
}

enum _MigrationDisposition { migrated, legacyUntrusted, quarantined }

class _MigrationState {
  const _MigrationState({
    required this.sourceKey,
    required this.fingerprint,
    required this.disposition,
    required this.updatedAt,
    this.documentId,
    this.reason,
  });

  factory _MigrationState.migrated({
    required String sourceKey,
    required String fingerprint,
    required String documentId,
  }) => _MigrationState(
    sourceKey: sourceKey,
    fingerprint: fingerprint,
    disposition: _MigrationDisposition.migrated,
    updatedAt: DateTime.now().toUtc(),
    documentId: documentId,
  );

  factory _MigrationState.legacyUntrusted({
    required String sourceKey,
    required String fingerprint,
    required String reason,
  }) => _MigrationState(
    sourceKey: sourceKey,
    fingerprint: fingerprint,
    disposition: _MigrationDisposition.legacyUntrusted,
    updatedAt: DateTime.now().toUtc(),
    reason: reason,
  );

  factory _MigrationState.quarantined({
    required String sourceKey,
    required String fingerprint,
    required String reason,
  }) => _MigrationState(
    sourceKey: sourceKey,
    fingerprint: fingerprint,
    disposition: _MigrationDisposition.quarantined,
    updatedAt: DateTime.now().toUtc(),
    reason: reason,
  );

  final String sourceKey;
  final String fingerprint;
  final _MigrationDisposition disposition;
  final DateTime updatedAt;
  final String? documentId;
  final String? reason;

  bool get isMigrated => disposition == _MigrationDisposition.migrated;
  bool get isFinal => true;

  Map<String, dynamic> toJson() => {
    'schemaVersion': kReviewMigrationSchemaVersion,
    'sourceKey': sourceKey,
    'fingerprint': fingerprint,
    'disposition': disposition.name,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'documentId': documentId,
    'reason': reason,
  };

  factory _MigrationState.fromJson(Map<dynamic, dynamic> json) =>
      _MigrationState(
        sourceKey: json['sourceKey'] as String,
        fingerprint: json['fingerprint'] as String,
        disposition: _MigrationDisposition.values.firstWhere(
          (value) => value.name == json['disposition'],
          orElse: () => _MigrationDisposition.legacyUntrusted,
        ),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toUtc(),
        documentId: json['documentId'] as String?,
        reason: json['reason'] as String?,
      );
}

ArchivedGame _archivedGameFromDocument(ReviewDocument document) {
  final index = _ReviewIndexEntry.fromDocument(document);
  final summary = index.toArchivedGame();
  return ArchivedGame(
    id: summary.id,
    source: summary.source,
    white: summary.white,
    black: summary.black,
    whiteRating: summary.whiteRating,
    blackRating: summary.blackRating,
    result: summary.result,
    playedAt: summary.playedAt,
    analyzedAt: summary.analyzedAt,
    depth: summary.depth,
    pgn: document.game.originalPgn,
    qualityCounts: document.classificationCounts,
    averageCpLoss: document.verifiedAcpl ?? 0,
    cpLossSampleCount: document.cpLossEligibleCount,
    totalPlies: document.timeline.totalPlies,
    openingName: summary.openingName,
    ecoCode: summary.ecoCode,
    cachedTimeline: document.timeline,
    classifierVersion: document.compatibility.classifierVersion,
    analysisMode: summary.analysisMode,
    analysisProfileId: document.compatibility.profileId,
    providerId: document.compatibility.providerId,
    pgnHash: document.timeline.pgnHash,
    cacheKey: document.timeline.cacheKey,
    tacticalVerifierVersion: document.compatibility.tacticalVerifierVersion,
    openingBookVersion: document.compatibility.openingBookVersion,
    analysisSchemaVersion: document.compatibility.analysisSchemaVersion,
    timeControl: summary.timeControl,
    analysisMovetimeMs: summary.analysisMovetimeMs,
    analysisMultiPv: summary.analysisMultiPv,
    candidateVerificationEnabled: summary.candidateVerificationEnabled,
    recordKind: ArchivedRecordKind.canonicalDocument,
    canonicalGameId: document.game.gameId.value,
    analysisVariantId: document.variantId.value,
    analyzedUserIsWhite: document.userIsWhite,
    engineIdentity: document.compatibility.engine.declaredIdentity,
    canonicalIndexVerified: true,
  );
}

ArchivedGame _unavailableLegacyEntry(String sourceKey, String? reason) =>
    ArchivedGame(
      id: sourceKey,
      source: ArchiveSource.pgn,
      white: 'Saved review',
      black: 'Unavailable',
      result: '*',
      analyzedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      depth: 0,
      pgn: '',
      qualityCounts: const {},
      averageCpLoss: 0,
      totalPlies: 0,
      classifierVersion: 1,
      tacticalVerifierVersion: 1,
      openingBookVersion: 1,
      analysisSchemaVersion: 1,
      recordKind: ArchivedRecordKind.unavailable,
      unavailableReason: reason ?? 'Saved review data could not be read.',
    );

String _fingerprint(String raw) => sha256.convert(utf8.encode(raw)).toString();
