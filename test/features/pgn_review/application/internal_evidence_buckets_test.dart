@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalEvidenceBucket default prototype', () {
    test('bucket prototype includes all expected bucket IDs', () {
      final result = _run();

      expect(result.totalCaseCount, 15);
      expect(result.protectedCount, 14);
      expect(result.negativeGuardCount, 1);
      expect(result.incompleteCount, 0);
      expect(result.realDeviceNeededCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.capturedAndroidProofCount, 3);
      expect(
        result.buckets.map((bucket) => bucket.id),
        containsAll(InternalEvidenceBucketId.values),
      );
      expect(
        result.buckets.map((bucket) => bucket.id).toSet().length,
        InternalEvidenceBucketId.values.length,
      );
      expect(
        result.status,
        InternalEvidenceBucketPrototypeStatus.readyForInternalBucketPrototype,
      );
      expect(result.readyForPhase31D, isTrue);
    });

    test('tactical bucket is supported by protected golden cases', () {
      final bucket = _run().bucket(InternalEvidenceBucketId.tacticalSupported);

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('material bucket is supported by protected golden cases', () {
      final bucket = _run().bucket(
        InternalEvidenceBucketId.materialSwingSupported,
      );

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        containsAll([
          'queen-win-major-swing',
          'sacrifice-compensation-hard-case',
          'material-sacrifice-compensation',
        ]),
      );
    });

    test('forcing-line bucket is supported by protected golden cases', () {
      final bucket = _run().bucket(
        InternalEvidenceBucketId.forcingLineSupported,
      );

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        containsAll([
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
          'king-safety-mating-net-hard-case',
        ]),
      );
    });

    test('king-safety bucket is supported by protected golden cases', () {
      final bucket = _run().bucket(
        InternalEvidenceBucketId.kingSafetySupported,
      );

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        containsAll([
          'king-safety-mating-net-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('endgame bucket is conservative and supported', () {
      final bucket = _run().bucket(
        InternalEvidenceBucketId.endgameConservativeSupported,
      );

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        containsAll([
          'endgame-precision-hard-case',
          'technical-endgame-conservative',
        ]),
      );
      expect(bucket.recommendation, contains('conservative'));
    });

    test('safety and suppression buckets map to expected cases', () {
      final result = _run();

      expect(
        result
            .bucket(InternalEvidenceBucketId.safetySuppressionSupported)
            .supportingCaseIds,
        containsAll([
          'invalid-fen-safety',
          'quiet-opening-skip',
          'forced-move-skip',
          'budget-pressure-candidates',
        ]),
      );
      expect(
        result
            .bucket(InternalEvidenceBucketId.invalidFenSuppressed)
            .supportingCaseIds,
        orderedEquals(['invalid-fen-safety']),
      );
      expect(
        result
            .bucket(InternalEvidenceBucketId.openingSuppressed)
            .supportingCaseIds,
        orderedEquals(['quiet-opening-skip']),
      );
      expect(
        result
            .bucket(InternalEvidenceBucketId.forcedMoveSuppressed)
            .supportingCaseIds,
        orderedEquals(['forced-move-skip']),
      );
      expect(
        result
            .bucket(InternalEvidenceBucketId.budgetPressureVisible)
            .supportingCaseIds,
        orderedEquals(['budget-pressure-candidates']),
      );
    });

    test('Android proof bucket includes only proven case IDs', () {
      final bucket = _run().bucket(InternalEvidenceBucketId.androidProofBacked);

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        bucket.supportingCaseIds,
        isNot(contains('quiet-preparatory-hard-case')),
      );
    });

    test('candidate spread bucket maps to candidate-spread evidence cases', () {
      final bucket = _run().bucket(
        InternalEvidenceBucketId.candidateSpreadSupported,
      );

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'king-safety-mating-net-hard-case',
          'sacrifice-compensation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('PV and MultiPV bucket maps only to proof-backed cases', () {
      final bucket = _run().bucket(InternalEvidenceBucketId.pvMultiPvSupported);

      expect(bucket.status, InternalEvidenceBucketStatus.supported);
      expect(
        bucket.supportingCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
    });

    test('quiet preparatory bucket is excluded by negative guard', () {
      final bucket = _run().bucket(
        InternalEvidenceBucketId.quietPreparatoryExcluded,
      );

      expect(bucket.status, InternalEvidenceBucketStatus.excluded);
      expect(bucket.supportingCaseIds, contains('quiet-preparatory-hard-case'));
      expect(
        bucket.blockerCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
      expect(bucket.blockers.join('\n'), contains('negative guard'));
    });

    test('blocked and future buckets remain unavailable', () {
      final result = _run();

      expect(
        result
            .bucket(InternalEvidenceBucketId.productLabelOutputBlocked)
            .status,
        InternalEvidenceBucketStatus.blockedByPolicy,
      );
      expect(
        result.bucket(InternalEvidenceBucketId.advancedLabelGateBlocked).status,
        InternalEvidenceBucketStatus.blockedByPolicy,
      );
      expect(
        result.bucket(InternalEvidenceBucketId.officialMetricsBlocked).status,
        InternalEvidenceBucketStatus.blockedByPolicy,
      );
      expect(
        result.bucket(InternalEvidenceBucketId.cpLossComputationBlocked).status,
        InternalEvidenceBucketStatus.futureOnly,
      );
      expect(
        result
            .bucket(InternalEvidenceBucketId.winProbabilityComputationBlocked)
            .status,
        InternalEvidenceBucketStatus.futureOnly,
      );
    });
  });

  group('InternalEvidenceBucket validator', () {
    test('rejects supported bucket with no cases', () {
      final base = _run();
      final mutated = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.tacticalSupported)
              bucket.copyWith(supportingCaseIds: const <String>[])
            else
              bucket,
        ],
      );

      final findings = const InternalEvidenceBucketValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('supportedBucketWithoutCases'),
      );
    });

    test('rejects blocked bucket marked supported', () {
      final base = _run();
      final mutated = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.productLabelOutputBlocked)
              bucket.copyWith(
                status: InternalEvidenceBucketStatus.supported,
                supportingCaseIds: ['simple-tactical-capture-check'],
              )
            else
              bucket,
        ],
      );

      final findings = const InternalEvidenceBucketValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('policyBlockedBucketAllowed'),
      );
    });

    test('rejects quiet bucket if not excluded', () {
      final base = _run();
      final mutated = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.quietPreparatoryExcluded)
              bucket.copyWith(status: InternalEvidenceBucketStatus.supported)
            else
              bucket,
        ],
      );

      final findings = const InternalEvidenceBucketValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('quietBucketNotExcluded'),
      );
    });

    test('rejects official metrics if allowed', () {
      final base = _run();
      final mutated = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.officialMetricsBlocked)
              bucket.copyWith(status: InternalEvidenceBucketStatus.supported)
            else
              bucket,
        ],
      );

      final findings = const InternalEvidenceBucketValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('policyBlockedBucketAllowed'),
      );
    });

    test('rejects future computations if marked available', () {
      final base = _run();
      final mutated = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id ==
                    InternalEvidenceBucketId.cpLossComputationBlocked ||
                bucket.id ==
                    InternalEvidenceBucketId.winProbabilityComputationBlocked)
              bucket.copyWith(
                status: InternalEvidenceBucketStatus.supported,
                supportingCaseIds: ['simple-tactical-capture-check'],
              )
            else
              bucket,
        ],
      );

      final findings = const InternalEvidenceBucketValidator().validate(
        mutated,
      );

      expect(
        findings.where((finding) => finding.id == 'futureComputationAllowed'),
        hasLength(2),
      );
    });

    test('rejects Android proof bucket with unproven cases', () {
      final base = _run();
      final mutated = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.androidProofBacked)
              bucket.copyWith(
                supportingCaseIds: [
                  ...bucket.supportingCaseIds,
                  'quiet-preparatory-hard-case',
                ],
              )
            else
              bucket,
        ],
      );

      final findings = const InternalEvidenceBucketValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('unprovenAndroidProofBucketCase'),
      );
    });

    test('rejects emitted forbidden product output families', () {
      final findings = const InternalEvidenceBucketValidator().validate(
        _run().copyWith(
          emittedOutputFamilies: const <String>['productLabelOutput'],
        ),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('forbiddenOutputEmitted'),
      );
    });

    test('host-only fake proof is not Android proof bucket support', () {
      final result = _run(proof: _hostOnlyProofForMateThreat);

      expect(result.capturedAndroidProofCount, 0);
      expect(
        result.bucket(InternalEvidenceBucketId.androidProofBacked).status,
        InternalEvidenceBucketStatus.partial,
      );
      expect(
        result
            .bucket(InternalEvidenceBucketId.androidProofBacked)
            .supportingCaseIds,
        isEmpty,
      );
    });
  });

  group('InternalEvidenceBucket reports and guardrails', () {
    test('markdown report is deterministic and includes bucket tables', () {
      final first = _run().renderMarkdownReport();
      final second = _run().renderMarkdownReport();

      expect(first, second);
      expect(first, contains('# Internal Evidence Buckets Prototype'));
      expect(first, contains('Bucket Table'));
      expect(first, contains('Supported Buckets'));
      expect(first, contains('Blocked Buckets'));
      expect(first, contains('Future-Only Buckets'));
    });

    test('markdown report includes support mapping and quiet exclusion', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('Support Mapping'));
      expect(report, contains('tacticalSupported'));
      expect(report, contains('quietPreparatoryExcluded'));
      expect(report, contains('quiet-preparatory-uncertain'));
      expect(report, contains('quiet-preparatory-hard-case'));
      expect(report, contains('mate-threat-fast-evidence'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalEvidenceBucketsReportVersion);
      expect(summary['totalCases'], 15);
      expect(summary['protectedCount'], 14);
      expect(summary['negativeGuardCount'], 1);
      expect(decoded['buckets'], isA<List<Object?>>());
      expect(
        decoded['nextRecommendedPhase'],
        'Phase 31D -- Internal Non-Label Bucket Experiment Guards',
      );
    });

    test('report contains no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('report does not emit final labels or official metric names', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_bucketSource);

      expect(imports, isNot(contains('Stockfish')));
      expect(imports, isNot(contains('stockfish_bridge')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('native')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('flutter/material')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
    });
  });
}

InternalEvidenceBucketPrototype _run({
  GoldenAndroidProofEvidence? proof =
      GoldenAndroidProofEvidence.phase30uS22Ultra,
}) {
  return const InternalEvidenceBucketBuilder().evaluate(
    InternalEvidenceBucketRequest(androidProofEvidence: proof),
  );
}

String get _bucketSource => File(
  'lib/features/pgn_review/application/internal_evidence_buckets.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _hostOnlyProofForMateThreat = GoldenAndroidProofEvidence(
  proofVersion: goldenAndroidProofEvidenceVersion,
  sourceId: 'host-only-fake-proof',
  sourceNote: 'fake proof must not satisfy real-device proof',
  deviceFamily: 'host',
  deviceModel: 'host',
  platform: 'host',
  abi: 'x64',
  engineIdentity: 'fake-engine',
  stubIdentityDetected: false,
  runs: <GoldenAndroidProofRunEvidence>[
    GoldenAndroidProofRunEvidence(
      preset: 'balancedDefault',
      status: 'completedWithWarnings',
      targetCaseCount: 1,
      executedTargetCount: 1,
      selectedDeepCount: 1,
      executedDeepCount: 1,
      fastEngineCalls: 1,
      deepEngineCalls: 1,
      totalEngineCalls: 2,
      elapsedMs: 100,
      timeoutCount: 0,
      warningCount: 0,
      failureCount: 0,
      budgetPressureCount: 0,
      missingPvCount: 0,
      insufficientMultiPvCount: 0,
      warnings: <String>[],
      failures: <String>[],
      caseRows: <GoldenAndroidProofCaseEvidence>[
        GoldenAndroidProofCaseEvidence(
          caseId: 'mate-threat-fast-evidence',
          preset: 'balancedDefault',
          proofStatus: 'proofCaptured',
          selectedDeepCount: 1,
          executedDeepCount: 1,
          pvPresent: true,
          multiPvLineCount: 3,
          reasonCodeCounts: <DeepCandidateReasonCode, int>{
            DeepCandidateReasonCode.candidateEvalSpread: 1,
            DeepCandidateReasonCode.givesCheck: 1,
            DeepCandidateReasonCode.tacticalSignal: 1,
          },
          warnings: <String>[],
          failures: <String>[],
          nextAction: 'ignoreFakeProof',
        ),
      ],
    ),
  ],
);
