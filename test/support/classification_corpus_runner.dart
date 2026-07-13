library;

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart'
    show normalizeCastlingUci;
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';

const classificationCorpusFixturePath =
    'test/fixtures/classification/apex_classification_policy_corpus_v1.json';

const _specialLabels = <String>{
  'brilliant',
  'great',
  'onlyMove',
  'forced',
  'missedWin',
};

class ClassificationCorpus {
  ClassificationCorpus({
    required this.schemaVersion,
    required this.corpusVersion,
    required this.policyVersion,
    required this.expectationOwner,
    required Map<String, Object?> evidenceDefaults,
    required List<ClassificationCorpusCase> cases,
  }) : evidenceDefaults = Map<String, Object?>.unmodifiable(evidenceDefaults),
       cases = List<ClassificationCorpusCase>.unmodifiable(cases);

  final int schemaVersion;
  final String corpusVersion;
  final int policyVersion;
  final String expectationOwner;
  final Map<String, Object?> evidenceDefaults;
  final List<ClassificationCorpusCase> cases;

  static ClassificationCorpus load({
    String fixturePath = classificationCorpusFixturePath,
  }) {
    final decoded = jsonDecode(File(fixturePath).readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Classification corpus root must be JSON.');
    }
    final rawCases = decoded['cases'];
    if (rawCases is! List<dynamic>) {
      throw const FormatException('Classification corpus cases are missing.');
    }
    return ClassificationCorpus(
      schemaVersion: _int(decoded['schemaVersion']),
      corpusVersion: _string(decoded['corpusVersion']),
      policyVersion: _int(decoded['policyVersion']),
      expectationOwner: _string(decoded['expectationOwner']),
      evidenceDefaults: _stringObjectMap(decoded['evidenceDefaults']),
      cases: rawCases
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Corpus case must be an object.');
            }
            return ClassificationCorpusCase.fromJson(item);
          })
          .toList(growable: false),
    );
  }
}

class ClassificationCorpusCase {
  ClassificationCorpusCase({
    required this.id,
    required this.schemaVersion,
    required this.provenanceType,
    required this.expectationOwner,
    required this.fenBefore,
    required this.playedMoveUci,
    required this.mover,
    required Map<String, Object?> evidence,
    required List<String> allowedLabels,
    required List<String> forbiddenLabels,
    required List<String> requiredReasonCodes,
    required List<String> tags,
    required this.rationale,
    required this.calibrationStatus,
  }) : evidence = Map<String, Object?>.unmodifiable(evidence),
       allowedLabels = List<String>.unmodifiable(allowedLabels),
       forbiddenLabels = List<String>.unmodifiable(forbiddenLabels),
       requiredReasonCodes = List<String>.unmodifiable(requiredReasonCodes),
       tags = List<String>.unmodifiable(tags);

  final String id;
  final int schemaVersion;
  final String provenanceType;
  final String expectationOwner;
  final String fenBefore;
  final String playedMoveUci;
  final String mover;
  final Map<String, Object?> evidence;
  final List<String> allowedLabels;
  final List<String> forbiddenLabels;
  final List<String> requiredReasonCodes;
  final List<String> tags;
  final String rationale;
  final String calibrationStatus;

  factory ClassificationCorpusCase.fromJson(Map<String, dynamic> json) =>
      ClassificationCorpusCase(
        id: _string(json['id']),
        schemaVersion: _int(json['schemaVersion']),
        provenanceType: _string(json['provenanceType']),
        expectationOwner: _string(json['expectationOwner']),
        fenBefore: _string(json['fenBefore']),
        playedMoveUci: _string(json['playedMoveUci']),
        mover: _string(json['mover']),
        evidence: _stringObjectMap(json['evidence']),
        allowedLabels: _stringList(json['allowedLabels']),
        forbiddenLabels: _stringList(json['forbiddenLabels']),
        requiredReasonCodes: _stringList(json['requiredReasonCodes']),
        tags: _stringList(json['tags']),
        rationale: _string(json['rationale']),
        calibrationStatus: _string(json['calibrationStatus']),
      );

  MoveClassificationEvidence buildEvidence(Map<String, Object?> defaults) {
    final raw = <String, Object?>{...defaults, ...evidence};
    final before = _score(cp: raw['prevWhiteCp'], mate: raw['prevWhiteMate']);
    final played = _score(cp: raw['currWhiteCp'], mate: raw['currWhiteMate']);
    final best =
        _score(
          cp: raw.containsKey('bestWhiteCp')
              ? raw['bestWhiteCp']
              : raw['prevWhiteCp'],
          mate: raw.containsKey('bestWhiteMate')
              ? raw['bestWhiteMate']
              : raw['prevWhiteMate'],
        ) ??
        before;
    final bestMove = _nullableMove(raw['engineBestMoveUci']);
    final playedMove = _nullableMove(
      playedMoveUci == 'n/a' ? null : playedMoveUci,
    );
    final receivedMultiPv = _int(raw['receivedMultiPvCount']);
    final requestedMultiPv = raw['requestedMultiPvCount'] == null
        ? (receivedMultiPv <= 1 ? 1 : 3)
        : _int(raw['requestedMultiPvCount']);
    final candidateWinPercents = _doubleList(raw['multiPvWhiteWinPercents']);
    final configuredCandidateRoots = _stringList(raw['candidateRootUcis']);
    final candidateRoots =
        configuredCandidateRoots.length == candidateWinPercents.length
        ? configuredCandidateRoots
        : _candidateRoots(
            count: candidateWinPercents.length,
            bestMove: bestMove,
            playedMove: playedMove,
          );
    final candidateLegalFlags = _boolList(raw['candidateLegalFlags']);
    final achievedDepth = _int(raw['achievedDepth']);
    final candidates = <ClassificationCandidateEvidence>[
      for (var index = 0; index < candidateWinPercents.length; index++)
        ClassificationCandidateEvidence(
          rootUci: candidateRoots[index],
          rank: index + 1,
          score: index == 0 && best != null
              ? best
              : _scoreFromWhiteWinPercent(candidateWinPercents[index]),
          achievedDepth: achievedDepth,
          isLegal: index < candidateLegalFlags.length
              ? candidateLegalFlags[index]
              : true,
          pvComplete: true,
        ),
    ];
    final scoreCoverage = _string(raw['scoreCoverage']);
    final contradictory =
        scoreCoverage == 'pv1BestmoveContradiction' ||
        raw['candidateVerificationStatus'] == 'contradicted';
    final candidateSetCoherent = _bool(raw['multiPvCoherent']);
    final alternativeComplete = _bool(raw['alternativeEvidenceComplete']);
    final tactical = _stringObjectMap(raw['tacticalVerdict']);

    return MoveClassificationEvidence(
      schemaVersion: schemaVersion,
      mover: mover == 'black'
          ? ClassificationMover.black
          : ClassificationMover.white,
      evaluationBefore: before,
      playedMoveEvaluation: played,
      bestMoveEvaluation: best,
      playedMoveUci: playedMove,
      bestMoveUci: bestMove,
      candidates: candidates,
      requestedMultiPv: requestedMultiPv,
      receivedMultiPv: receivedMultiPv,
      candidateSetComplete:
          alternativeComplete && receivedMultiPv >= requestedMultiPv,
      candidateSetCoherent: candidateSetCoherent,
      bestMovePv1Consistent:
          !contradictory &&
          bestMove != null &&
          candidates.isNotEmpty &&
          candidates.first.rootUci.toLowerCase() == bestMove.toLowerCase(),
      searchQualityMet:
          scoreCoverage == 'complete' &&
          achievedDepth > 0 &&
          before?.isValid == true &&
          played?.isValid == true,
      achievedDepthFloor: _nullableInt(raw['achievedDepthFloor']),
      legalMoveCount: _nullableInt(raw['legalCandidateCount']),
      bookState: _bookState(raw['bookEvidenceState']),
      verificationState: _verificationState(raw['candidateVerificationStatus']),
      forcedState: _forcedState(raw['forcedResponseEvidence']),
      isSacrifice: _nullableBool(raw['isSacrifice']),
      isCapture: _nullableBool(raw['isCapture']),
      isFreeCapture: _nullableBool(raw['isFreeCapture']),
      isRecapture: _nullableBool(raw['isRecapture']),
      isTrivialRecapture: _nullableBool(raw['isTrivialRecapture']),
      isFirstSacrificePly: _nullableBool(raw['isFirstSacrificePly']),
      tacticalBestOrNearBest:
          _bool(tactical['isBestOrNearBest']) ||
          _bool(raw['tacticalBestOrNearBest']),
      tacticalHasForcingOutcome:
          _bool(tactical['hasForcingOutcome']) ||
          _bool(raw['tacticalHasForcingOutcome']),
      tacticalForcedMate:
          _bool(tactical['forcedMate']) || _bool(raw['tacticalForcedMate']),
      unavailableReason: _unavailableReason(scoreCoverage),
    );
  }

  String semanticInputFingerprint(Map<String, Object?> defaults) =>
      jsonEncode(buildEvidence(defaults).toJson());
}

class ClassificationCorpusCaseResult {
  ClassificationCorpusCaseResult({
    required this.caseId,
    required this.provenanceType,
    required this.expectationOwner,
    required this.fenBefore,
    required this.playedMoveUci,
    required this.mover,
    required this.allowedLabels,
    required this.forbiddenLabels,
    required this.actualLabel,
    required this.reasonCodes,
    required this.failedGates,
    required this.forbiddenLabelViolations,
    required this.missingReasonCodes,
    required this.evidenceAvailable,
    required this.achievedDepthFloor,
    required this.receivedMultiPv,
    required this.profile,
    required this.durationMicroseconds,
    required this.tags,
    required this.rationale,
    required this.calibrationStatus,
    required this.expectedPolicyVersion,
    required this.policyVersion,
    required this.diagnostics,
    this.error,
  });

  final String caseId;
  final String provenanceType;
  final String expectationOwner;
  final String fenBefore;
  final String playedMoveUci;
  final String mover;
  final List<String> allowedLabels;
  final List<String> forbiddenLabels;
  final String actualLabel;
  final List<String> reasonCodes;
  final List<String> failedGates;
  final List<String> forbiddenLabelViolations;
  final List<String> missingReasonCodes;
  final bool evidenceAvailable;
  final int? achievedDepthFloor;
  final int receivedMultiPv;
  final String profile;
  final int durationMicroseconds;
  final List<String> tags;
  final String rationale;
  final String calibrationStatus;
  final int expectedPolicyVersion;
  final int policyVersion;
  final Map<String, Object?> diagnostics;
  final String? error;

  bool get allowedLabelMatch => allowedLabels.contains(actualLabel);
  bool get policyVersionMatch => policyVersion == expectedPolicyVersion;

  bool get passed =>
      error == null &&
      policyVersionMatch &&
      allowedLabelMatch &&
      forbiddenLabelViolations.isEmpty &&
      missingReasonCodes.isEmpty;

  bool get manualReviewRequired =>
      calibrationStatus.contains('MANUAL_REVIEW_REQUIRED');

  String get outcome => manualReviewRequired
      ? 'manual-review'
      : passed
      ? 'pass'
      : 'fail';

  bool get specialFalsePositive =>
      _specialLabels.contains(actualLabel) &&
      forbiddenLabelViolations.contains(actualLabel);

  Map<String, Object?> toJson() => <String, Object?>{
    'caseId': caseId,
    'provenanceType': provenanceType,
    'expectationOwner': expectationOwner,
    'fenBefore': fenBefore,
    'playedMoveUci': playedMoveUci,
    'mover': mover,
    'expectedAllowedLabels': allowedLabels,
    'forbiddenLabels': forbiddenLabels,
    'actualLabel': actualLabel,
    'forbiddenLabelViolations': forbiddenLabelViolations,
    'reasonCodes': reasonCodes,
    'missingReasonCodes': missingReasonCodes,
    'failedGates': failedGates,
    'evidenceAvailable': evidenceAvailable,
    'profile': profile,
    'achievedEvidence': <String, Object?>{
      'depthFloor': achievedDepthFloor,
      'receivedMultiPv': receivedMultiPv,
    },
    'durationMicroseconds': durationMicroseconds,
    'state': outcome,
    'tags': tags,
    'rationale': rationale,
    'calibrationStatus': calibrationStatus,
    'expectedPolicyVersion': expectedPolicyVersion,
    'policyVersion': policyVersion,
    'policyVersionMatch': policyVersionMatch,
    'diagnostics': diagnostics,
    'error': error,
  };
}

class ClassificationCorpusRunResult {
  ClassificationCorpusRunResult({
    required this.corpusVersion,
    required this.policyVersion,
    required this.runTimestamp,
    required this.totalDurationMicroseconds,
    required this.categoryCounts,
    required List<ClassificationCorpusCaseResult> caseResults,
  }) : caseResults = List<ClassificationCorpusCaseResult>.unmodifiable(
         caseResults,
       );

  final String corpusVersion;
  final int policyVersion;
  final DateTime runTimestamp;
  final int totalDurationMicroseconds;
  final Map<String, int> categoryCounts;
  final List<ClassificationCorpusCaseResult> caseResults;

  int get totalCases => caseResults.length;
  int get passedCases => caseResults.where((result) => result.passed).length;
  int get failedCases => caseResults.where((result) => !result.passed).length;
  int get manualReviewCases =>
      caseResults.where((result) => result.manualReviewRequired).length;
  int get allowedLabelMatches =>
      caseResults.where((result) => result.allowedLabelMatch).length;
  int get forbiddenLabelViolationCount => caseResults.fold<int>(
    0,
    (total, result) => total + result.forbiddenLabelViolations.length,
  );
  int get reasonCodeMismatchCount => caseResults.fold<int>(
    0,
    (total, result) => total + result.missingReasonCodes.length,
  );
  int get specialLabelFalsePositiveCount =>
      caseResults.where((result) => result.specialFalsePositive).length;
  int get policyVersionMismatchCount =>
      caseResults.where((result) => !result.policyVersionMatch).length;

  Map<String, Object?> toJson() => <String, Object?>{
    'corpusVersion': corpusVersion,
    'policyVersion': policyVersion,
    'engineIdentity': 'not-required:frozen-policy-corpus',
    'runTimestamp': runTimestamp.toUtc().toIso8601String(),
    'totalCases': totalCases,
    'passedCases': passedCases,
    'failedCases': failedCases,
    'manualReviewCases': manualReviewCases,
    'allowedLabelMatches': allowedLabelMatches,
    'forbiddenLabelViolationCount': forbiddenLabelViolationCount,
    'reasonCodeMismatchCount': reasonCodeMismatchCount,
    'specialLabelFalsePositiveCount': specialLabelFalsePositiveCount,
    'policyVersionMismatchCount': policyVersionMismatchCount,
    'totalDurationMicroseconds': totalDurationMicroseconds,
    'categoryCounts': categoryCounts,
    'cases': caseResults.map((result) => result.toJson()).toList(),
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderCsv() {
    final rows = <List<Object?>>[
      <Object?>[
        'case_id',
        'provenance_type',
        'expectation_owner',
        'fen_before',
        'played_move_uci',
        'mover',
        'tags',
        'calibration_status',
        'allowed_labels',
        'forbidden_labels',
        'actual_label',
        'reason_codes',
        'failed_gates',
        'forbidden_violations',
        'missing_reasons',
        'evidence_available',
        'profile',
        'achieved_depth_floor',
        'received_multipv',
        'duration_microseconds',
        'state',
        'expected_policy_version',
        'actual_policy_version',
        'rationale',
      ],
      for (final result in caseResults)
        <Object?>[
          result.caseId,
          result.provenanceType,
          result.expectationOwner,
          result.fenBefore,
          result.playedMoveUci,
          result.mover,
          result.tags.join('|'),
          result.calibrationStatus,
          result.allowedLabels.join('|'),
          result.forbiddenLabels.join('|'),
          result.actualLabel,
          result.reasonCodes.join('|'),
          result.failedGates.join('|'),
          result.forbiddenLabelViolations.join('|'),
          result.missingReasonCodes.join('|'),
          result.evidenceAvailable,
          result.profile,
          result.achievedDepthFloor,
          result.receivedMultiPv,
          result.durationMicroseconds,
          result.outcome,
          result.expectedPolicyVersion,
          result.policyVersion,
          result.rationale,
        ],
    ];
    return '${rows.map(_csvRow).join('\r\n')}\r\n';
  }
}

class ClassificationCorpusPerformanceResult {
  const ClassificationCorpusPerformanceResult({
    required this.timelinePlies,
    required this.iterations,
    required this.decisions,
    required this.elapsedMicroseconds,
    required this.checksum,
  });

  final int timelinePlies;
  final int iterations;
  final int decisions;
  final int elapsedMicroseconds;
  final int checksum;

  double get microsecondsPerDecision =>
      decisions == 0 ? 0 : elapsedMicroseconds / decisions;

  Map<String, Object?> toJson() => <String, Object?>{
    'timelinePlies': timelinePlies,
    'iterations': iterations,
    'decisions': decisions,
    'elapsedMicroseconds': elapsedMicroseconds,
    'microsecondsPerDecision': microsecondsPerDecision,
    'checksum': checksum,
  };
}

class ClassificationCorpusRunner {
  const ClassificationCorpusRunner({
    MoveClassifier classifier = const MoveClassifier(),
  }) : _classifier = classifier;

  final MoveClassifier _classifier;

  ClassificationCorpusRunResult run(ClassificationCorpus corpus) {
    final totalWatch = Stopwatch()..start();
    final results = <ClassificationCorpusCaseResult>[];
    for (final corpusCase in corpus.cases) {
      final evidence = corpusCase.buildEvidence(corpus.evidenceDefaults);
      final watch = Stopwatch()..start();
      try {
        final decision = _classifier.classifyEvidence(evidence);
        watch.stop();
        final actualLabel = decision.quality.name;
        final reasons = List<String>.unmodifiable(decision.reasonCodes);
        results.add(
          ClassificationCorpusCaseResult(
            caseId: corpusCase.id,
            provenanceType: corpusCase.provenanceType,
            expectationOwner: corpusCase.expectationOwner,
            fenBefore: corpusCase.fenBefore,
            playedMoveUci: corpusCase.playedMoveUci,
            mover: corpusCase.mover,
            allowedLabels: corpusCase.allowedLabels,
            forbiddenLabels: corpusCase.forbiddenLabels,
            actualLabel: actualLabel,
            reasonCodes: reasons,
            failedGates: List<String>.unmodifiable(decision.failedGates),
            forbiddenLabelViolations: corpusCase.forbiddenLabels
                .where((label) => label == actualLabel)
                .toList(growable: false),
            missingReasonCodes: corpusCase.requiredReasonCodes
                .where((reason) => !reasons.contains(reason))
                .toList(growable: false),
            evidenceAvailable: actualLabel != 'unavailable',
            achievedDepthFloor: evidence.achievedDepthFloor,
            receivedMultiPv: evidence.receivedMultiPv,
            profile: _profileFor(corpusCase),
            durationMicroseconds: watch.elapsedMicroseconds,
            tags: corpusCase.tags,
            rationale: corpusCase.rationale,
            calibrationStatus: corpusCase.calibrationStatus,
            expectedPolicyVersion: corpus.policyVersion,
            policyVersion: decision.policyVersion,
            diagnostics: Map<String, Object?>.unmodifiable(
              decision.diagnosticJson,
            ),
          ),
        );
      } on Object catch (error) {
        watch.stop();
        results.add(
          ClassificationCorpusCaseResult(
            caseId: corpusCase.id,
            provenanceType: corpusCase.provenanceType,
            expectationOwner: corpusCase.expectationOwner,
            fenBefore: corpusCase.fenBefore,
            playedMoveUci: corpusCase.playedMoveUci,
            mover: corpusCase.mover,
            allowedLabels: corpusCase.allowedLabels,
            forbiddenLabels: corpusCase.forbiddenLabels,
            actualLabel: 'error',
            reasonCodes: const <String>[],
            failedGates: const <String>[],
            forbiddenLabelViolations: const <String>[],
            missingReasonCodes: corpusCase.requiredReasonCodes,
            evidenceAvailable: false,
            achievedDepthFloor: evidence.achievedDepthFloor,
            receivedMultiPv: evidence.receivedMultiPv,
            profile: _profileFor(corpusCase),
            durationMicroseconds: watch.elapsedMicroseconds,
            tags: corpusCase.tags,
            rationale: corpusCase.rationale,
            calibrationStatus: corpusCase.calibrationStatus,
            expectedPolicyVersion: corpus.policyVersion,
            policyVersion: corpus.policyVersion,
            diagnostics: const <String, Object?>{},
            error: _sanitizeError(error),
          ),
        );
      }
    }
    totalWatch.stop();
    return ClassificationCorpusRunResult(
      corpusVersion: corpus.corpusVersion,
      policyVersion: corpus.policyVersion,
      runTimestamp: DateTime.now().toUtc(),
      totalDurationMicroseconds: totalWatch.elapsedMicroseconds,
      categoryCounts: _categoryCounts(corpus.cases),
      caseResults: results,
    );
  }

  ClassificationCorpusPerformanceResult measureTimeline({
    required ClassificationCorpus corpus,
    int timelinePlies = 100,
    int iterations = 1000,
  }) {
    if (corpus.cases.isEmpty || timelinePlies <= 0 || iterations <= 0) {
      return ClassificationCorpusPerformanceResult(
        timelinePlies: timelinePlies,
        iterations: iterations,
        decisions: 0,
        elapsedMicroseconds: 0,
        checksum: 0,
      );
    }
    final timeline = <MoveClassificationEvidence>[
      for (var ply = 0; ply < timelinePlies; ply++)
        corpus.cases[ply % corpus.cases.length].buildEvidence(
          corpus.evidenceDefaults,
        ),
    ];
    for (final evidence in timeline) {
      _classifier.classifyEvidence(evidence);
    }
    var checksum = 0;
    final watch = Stopwatch()..start();
    for (var iteration = 0; iteration < iterations; iteration++) {
      for (final evidence in timeline) {
        final decision = _classifier.classifyEvidence(evidence);
        checksum = (checksum + decision.quality.index + 1) & 0x7fffffff;
      }
    }
    watch.stop();
    return ClassificationCorpusPerformanceResult(
      timelinePlies: timelinePlies,
      iterations: iterations,
      decisions: timelinePlies * iterations,
      elapsedMicroseconds: watch.elapsedMicroseconds,
      checksum: checksum,
    );
  }
}

ClassificationScore? _score({required Object? cp, required Object? mate}) {
  final whiteCp = _nullableInt(cp);
  final whiteMate = _nullableInt(mate);
  if (whiteCp == null && whiteMate == null) return null;
  return ClassificationScore(whiteCp: whiteCp, whiteMate: whiteMate);
}

ClassificationScore _scoreFromWhiteWinPercent(double value) {
  if (value >= 99.999) return const ClassificationScore.mate(1);
  if (value <= 0.001) return const ClassificationScore.mate(-1);
  final ratio = value / (100.0 - value);
  final cp = (math.log(ratio) / WinPercentCalculator.k)
      .round()
      .clamp(WinPercentCalculator.clampMin, WinPercentCalculator.clampMax)
      .toInt();
  return ClassificationScore.cp(cp);
}

List<String> _candidateRoots({
  required int count,
  required String? bestMove,
  required String? playedMove,
}) {
  const fallback = <String>[
    'e2e4',
    'd2d4',
    'g1f3',
    'b1c3',
    'c2c4',
    'e7e5',
    'd7d5',
    'g8f6',
  ];
  final roots = <String>[];
  void add(String? value) {
    if (value == null || value.length < 4) return;
    final normalized = normalizeCastlingUci(value.toLowerCase());
    final alreadyPresent = roots.any(
      (root) => normalizeCastlingUci(root.toLowerCase()) == normalized,
    );
    if (!alreadyPresent) roots.add(value);
  }

  add(bestMove);
  add(playedMove);
  for (final root in fallback) {
    add(root);
    if (roots.length >= count) break;
  }
  while (roots.length < count) {
    roots.add('a${roots.length + 1}a${roots.length + 2}');
  }
  return roots.take(count).toList(growable: false);
}

ClassificationBookState _bookState(Object? raw) => switch (raw) {
  'verifiedBook' => ClassificationBookState.verified,
  'notBook' => ClassificationBookState.notBook,
  _ => ClassificationBookState.unavailable,
};

ClassificationVerificationState _verificationState(Object? raw) =>
    switch (raw) {
      'verified' => ClassificationVerificationState.complete,
      'notVerified' ||
      'incomplete' => ClassificationVerificationState.incomplete,
      'contradicted' => ClassificationVerificationState.contradicted,
      _ => ClassificationVerificationState.notRequested,
    };

ClassificationForcedState _forcedState(Object? raw) => switch (raw) {
  'onlyLegalMove' => ClassificationForcedState.onlyLegalMove,
  'onlyOutcomePreservingMove' =>
    ClassificationForcedState.verifiedForcedResponse,
  'none' => ClassificationForcedState.notForced,
  _ => ClassificationForcedState.unavailable,
};

ClassificationUnavailableReason? _unavailableReason(String coverage) =>
    switch (coverage) {
      'missingBefore' =>
        ClassificationUnavailableReason.missingEvaluationBefore,
      'terminalNoMove' => ClassificationUnavailableReason.missingMoveIdentity,
      'pv1BestmoveContradiction' =>
        ClassificationUnavailableReason.contradictoryBestMove,
      'complete' => null,
      _ => ClassificationUnavailableReason.unknown,
    };

Map<String, int> _categoryCounts(List<ClassificationCorpusCase> cases) {
  final counts = <String, int>{};
  for (final corpusCase in cases) {
    for (final tag in corpusCase.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }
  return Map<String, int>.unmodifiable(
    Map<String, int>.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ),
  );
}

String _profileFor(ClassificationCorpusCase corpusCase) {
  if (corpusCase.tags.contains('fast')) return 'fast';
  if (corpusCase.tags.contains('offline')) return 'offline';
  if (corpusCase.tags.contains('deep')) return 'deep';
  return 'frozen';
}

String _csvRow(List<Object?> values) => values.map(_csvCell).join(',');

String _csvCell(Object? value) {
  final raw = value?.toString() ?? '';
  if (!raw.contains(RegExp(r'[,"\r\n]'))) return raw;
  return '"${raw.replaceAll('"', '""')}"';
}

String _sanitizeError(Object error) {
  final singleLine = error.toString().replaceAll(RegExp(r'[\r\n\t]+'), ' ');
  return singleLine.length <= 240
      ? singleLine
      : '${singleLine.substring(0, 240)}...';
}

String? _nullableMove(Object? value) {
  if (value is! String) return null;
  final clean = value.trim();
  return clean.length >= 4 ? clean : null;
}

Map<String, Object?> _stringObjectMap(Object? value) {
  if (value is! Map) return const <String, Object?>{};
  return <String, Object?>{
    for (final entry in value.entries) entry.key.toString(): entry.value,
  };
}

List<String> _stringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((item) => item.toString()).toList(growable: false);
}

List<double> _doubleList(Object? value) {
  if (value is! List) return const <double>[];
  return value
      .whereType<num>()
      .map((item) => item.toDouble())
      .toList(growable: false);
}

List<bool> _boolList(Object? value) {
  if (value is! List) return const <bool>[];
  return value.whereType<bool>().toList(growable: false);
}

String _string(Object? value) => value?.toString() ?? '';
int _int(Object? value) => (value as num?)?.toInt() ?? 0;
int? _nullableInt(Object? value) => (value as num?)?.toInt();
bool _bool(Object? value) => value as bool? ?? false;
bool? _nullableBool(Object? value) => value as bool?;
