import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/classification_corpus_runner.dart';

const _exportFlag = 'APEX_CHAPTER4_CORPUS_EXPORT';
const _fixtureEnvironment = 'APEX_CHAPTER4_CORPUS_FIXTURE';
const _jsonEnvironment = 'APEX_CHAPTER4_CORPUS_JSON';
const _csvEnvironment = 'APEX_CHAPTER4_CORPUS_CSV';
const _pliesEnvironment = 'APEX_CHAPTER4_CORPUS_PERFORMANCE_PLIES';
const _iterationsEnvironment = 'APEX_CHAPTER4_CORPUS_PERFORMANCE_ITERATIONS';

void main() {
  late ClassificationCorpus corpus;

  setUpAll(() {
    corpus = ClassificationCorpus.load();
  });

  group('Chapter 4 frozen classification corpus metadata', () {
    test('contains at least 48 unique, fully reviewable cases', () {
      expect(corpus.schemaVersion, 1);
      expect(corpus.corpusVersion, isNotEmpty);
      expect(corpus.policyVersion, kApexClassifierVersion);
      expect(corpus.cases.length, greaterThanOrEqualTo(48));
      expect(
        corpus.cases.map((corpusCase) => corpusCase.id).toSet().length,
        corpus.cases.length,
      );

      for (final corpusCase in corpus.cases) {
        expect(
          corpusCase.id,
          matches(RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')),
          reason: corpusCase.id,
        );
        expect(corpusCase.schemaVersion, corpus.schemaVersion);
        expect(corpusCase.provenanceType, isNotEmpty, reason: corpusCase.id);
        expect(corpusCase.expectationOwner, isNotEmpty, reason: corpusCase.id);
        expect(
          corpusCase.fenBefore.startsWith('n/a:') ||
              corpusCase.fenBefore.split(' ').length == 6,
          isTrue,
          reason: corpusCase.id,
        );
        expect(
          corpusCase.playedMoveUci == 'n/a' ||
              RegExp(
                r'^[a-h][1-8][a-h][1-8][qrbn]?$',
              ).hasMatch(corpusCase.playedMoveUci),
          isTrue,
          reason: corpusCase.id,
        );
        expect(
          corpusCase.mover,
          anyOf('white', 'black'),
          reason: corpusCase.id,
        );
        expect(corpusCase.evidence, isNotEmpty, reason: corpusCase.id);
        expect(corpusCase.allowedLabels, isNotEmpty, reason: corpusCase.id);
        expect(corpusCase.forbiddenLabels, isNotEmpty, reason: corpusCase.id);
        expect(
          corpusCase.requiredReasonCodes,
          isNotEmpty,
          reason: corpusCase.id,
        );
        expect(
          corpusCase.tags.length,
          greaterThanOrEqualTo(2),
          reason: corpusCase.id,
        );
        expect(corpusCase.rationale, isNotEmpty, reason: corpusCase.id);
        expect(corpusCase.calibrationStatus, isNotEmpty, reason: corpusCase.id);
        expect(
          corpusCase.allowedLabels.toSet().intersection(
            corpusCase.forbiddenLabels.toSet(),
          ),
          isEmpty,
          reason: corpusCase.id,
        );
      }
    });

    test('spans every required high-risk category', () {
      final tags = corpus.cases.expand((corpusCase) => corpusCase.tags).toSet();
      const requiredTags = <String>{
        'general',
        'perspective',
        'mate',
        'outcome-band',
        'alternatives',
        'brilliant-positive',
        'brilliant-negative',
        'great-positive',
        'great-negative',
        'only-move-positive',
        'only-move-negative',
        'forced-positive',
        'forced-negative',
        'missed-win-positive',
        'missed-win-negative',
        'book',
        'opening',
        'middlegame',
        'endgame',
        'low-material',
        'fortress-like',
        'repetition',
        'perpetual-check',
        'stalemate',
        'promotion',
        'queen-promotion',
        'rook-promotion',
        'bishop-promotion',
        'knight-promotion',
        'en-passant',
        'castling',
        'checkmate',
        'quiet-maneuver',
        'tactical-sequence',
        'fast',
        'offline',
        'deep',
        'ENGINE_INVARIANT',
        'POLICY_CONTRACT',
        'HUMAN_REVIEWED_EXPECTATION',
        'ADVERSARIAL_NEGATIVE',
        'REGRESSION',
      };
      expect(tags, containsAll(requiredTags));
    });

    test('uses Apex-owned evidence rather than proprietary label fixtures', () {
      const forbiddenProvenanceTerms = <String>{
        'chess.com label',
        'competitor label',
        'hidden policy',
        'proprietary label',
      };
      final searchable = jsonEncode(<String, Object?>{
        'owner': corpus.expectationOwner,
        'cases': <Object?>[
          for (final corpusCase in corpus.cases)
            <String, Object?>{
              'provenance': corpusCase.provenanceType,
              'rationale': corpusCase.rationale,
            },
        ],
      }).toLowerCase();
      for (final term in forbiddenProvenanceTerms) {
        expect(searchable, isNot(contains(term)), reason: term);
      }
    });

    test('models malformed alternatives as structured evidence', () {
      ClassificationCorpusCase caseById(String id) =>
          corpus.cases.singleWhere((corpusCase) => corpusCase.id == id);

      final duplicateRoots = caseById(
        'alternatives-duplicate-roots',
      ).buildEvidence(corpus.evidenceDefaults);
      final illegalRoot = caseById(
        'alternatives-illegal-root',
      ).buildEvidence(corpus.evidenceDefaults);
      final normalizedCastling = caseById(
        'state-castling-normalized-best',
      ).buildEvidence(corpus.evidenceDefaults);

      expect(duplicateRoots.hasStructurallyCoherentCandidates, isFalse);
      expect(illegalRoot.hasStructurallyCoherentCandidates, isFalse);
      expect(
        normalizedCastling.hasStructurallyCoherentCandidates,
        isTrue,
        reason: jsonEncode(normalizedCastling.toJson()),
      );
    });

    test('contains no duplicate authoritative classifier inputs', () {
      final casesByFingerprint = <String, List<String>>{};
      for (final corpusCase in corpus.cases) {
        final fingerprint = corpusCase.semanticInputFingerprint(
          corpus.evidenceDefaults,
        );
        casesByFingerprint
            .putIfAbsent(fingerprint, () => <String>[])
            .add(corpusCase.id);
      }
      final duplicates = <List<String>>[
        for (final ids in casesByFingerprint.values)
          if (ids.length > 1) ids,
      ];
      expect(duplicates, isEmpty, reason: jsonEncode(duplicates));
      expect(casesByFingerprint, hasLength(corpus.cases.length));
    });
  });

  group('Chapter 4 frozen classification policy', () {
    test('every frozen case matches its allowed label and reason contract', () {
      final result = const ClassificationCorpusRunner().run(corpus);
      final failures = result.caseResults
          .where((caseResult) => !caseResult.passed)
          .map(
            (caseResult) => <String, Object?>{
              'caseId': caseResult.caseId,
              'allowed': caseResult.allowedLabels,
              'actual': caseResult.actualLabel,
              'reasons': caseResult.reasonCodes,
              'missingReasons': caseResult.missingReasonCodes,
              'forbidden': caseResult.forbiddenLabelViolations,
              'failedGates': caseResult.failedGates,
              'expectedPolicyVersion': caseResult.expectedPolicyVersion,
              'actualPolicyVersion': caseResult.policyVersion,
              'error': caseResult.error,
            },
          )
          .toList(growable: false);
      expect(failures, isEmpty, reason: jsonEncode(failures));
      expect(result.passedCases, corpus.cases.length);
      expect(result.failedCases, 0);
      expect(result.policyVersionMismatchCount, 0);
    });

    test('has zero forbidden special-label false positives', () {
      final result = const ClassificationCorpusRunner().run(corpus);
      final violations = result.caseResults
          .where((caseResult) => caseResult.specialFalsePositive)
          .map(
            (caseResult) => <String, Object?>{
              'caseId': caseResult.caseId,
              'actual': caseResult.actualLabel,
              'forbidden': caseResult.forbiddenLabelViolations,
            },
          )
          .toList(growable: false);
      expect(violations, isEmpty, reason: jsonEncode(violations));
      expect(result.specialLabelFalsePositiveCount, 0);
      expect(result.forbiddenLabelViolationCount, 0);
    });

    test('identical evidence and policy version are deterministic', () {
      const runner = ClassificationCorpusRunner();
      final first = runner.run(corpus);
      final second = runner.run(corpus);
      expect(first.caseResults.length, second.caseResults.length);
      for (var index = 0; index < first.caseResults.length; index++) {
        final a = first.caseResults[index];
        final b = second.caseResults[index];
        expect(b.caseId, a.caseId);
        expect(b.actualLabel, a.actualLabel, reason: a.caseId);
        expect(b.reasonCodes, a.reasonCodes, reason: a.caseId);
        expect(b.failedGates, a.failedGates, reason: a.caseId);
        expect(b.policyVersion, a.policyVersion, reason: a.caseId);
        expect(jsonEncode(b.diagnostics), jsonEncode(a.diagnostics));
      }
    });

    test('JSON and CSV reports preserve one result per case', () {
      final result = const ClassificationCorpusRunner().run(corpus);
      final json = result.toJson();
      final csvLines = const LineSplitter().convert(
        result.renderCsv().trimRight(),
      );
      expect(json['totalCases'], corpus.cases.length);
      expect(json['categoryCounts'], isA<Map<String, int>>());
      expect(json['cases'], hasLength(corpus.cases.length));
      expect(csvLines, hasLength(corpus.cases.length + 1));
      expect(csvLines.first, contains('forbidden_violations'));
      expect(csvLines.first, contains('calibration_status'));
      expect(csvLines.first, contains('expected_policy_version'));
      expect(csvLines.first, contains('actual_policy_version'));
    });
  });

  test('exports JSON and CSV when invoked by CLI tool', () {
    if (Platform.environment[_exportFlag] != '1') return;

    final fixturePath = _requiredEnvironment(_fixtureEnvironment);
    final jsonPath = _requiredEnvironment(_jsonEnvironment);
    final csvPath = _requiredEnvironment(_csvEnvironment);
    final timelinePlies = _positiveEnvironmentInt(_pliesEnvironment);
    final iterations = _positiveEnvironmentInt(_iterationsEnvironment);
    final exportCorpus = ClassificationCorpus.load(fixturePath: fixturePath);
    const runner = ClassificationCorpusRunner();
    final result = runner.run(exportCorpus);
    final performance = runner.measureTimeline(
      corpus: exportCorpus,
      timelinePlies: timelinePlies,
      iterations: iterations,
    );
    final json = result.toJson()
      ..['performanceMeasurement'] = performance.toJson();
    final jsonFile = File(jsonPath);
    final csvFile = File(csvPath);
    jsonFile.parent.createSync(recursive: true);
    csvFile.parent.createSync(recursive: true);
    jsonFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    csvFile.writeAsStringSync(result.renderCsv());

    // ignore: avoid_print
    print(
      jsonEncode(<String, Object?>{
        'totalCases': result.totalCases,
        'passedCases': result.passedCases,
        'failedCases': result.failedCases,
        'manualReviewCases': result.manualReviewCases,
        'forbiddenLabelViolationCount': result.forbiddenLabelViolationCount,
        'reasonCodeMismatchCount': result.reasonCodeMismatchCount,
        'specialLabelFalsePositiveCount': result.specialLabelFalsePositiveCount,
        'policyVersionMismatchCount': result.policyVersionMismatchCount,
        'performance': performance.toJson(),
        'jsonOutput': jsonFile.absolute.path,
        'csvOutput': csvFile.absolute.path,
      }),
    );

    expect(result.failedCases, 0);
    expect(result.forbiddenLabelViolationCount, 0);
    expect(result.reasonCodeMismatchCount, 0);
    expect(result.specialLabelFalsePositiveCount, 0);
    expect(result.policyVersionMismatchCount, 0);
  });

  test('measures a 100-ply timeline 1000x without a brittle time gate', () {
    final measurement = const ClassificationCorpusRunner().measureTimeline(
      corpus: corpus,
      timelinePlies: 100,
      iterations: 1000,
    );
    expect(measurement.timelinePlies, 100);
    expect(measurement.iterations, 1000);
    expect(measurement.decisions, 100000);
    expect(measurement.elapsedMicroseconds, greaterThanOrEqualTo(0));
    expect(measurement.microsecondsPerDecision, greaterThanOrEqualTo(0));
    expect(measurement.checksum, greaterThan(0));
    // Measurement is evidence for the report, not a machine-dependent gate.
    // ignore: avoid_print
    print(jsonEncode(measurement.toJson()));
  });
}

String _requiredEnvironment(String name) {
  final value = Platform.environment[name];
  if (value == null || value.trim().isEmpty) {
    throw StateError('Missing required export environment variable: $name');
  }
  return value;
}

int _positiveEnvironmentInt(String name) {
  final raw = _requiredEnvironment(name);
  final value = int.tryParse(raw);
  if (value == null || value <= 0) {
    throw StateError('$name must be a positive integer.');
  }
  return value;
}
