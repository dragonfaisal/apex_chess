@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalBucketExperimentHarness safe default', () {
    test('safe demo runs only after guard approval', () {
      final result = _run();

      expect(
        result.status,
        InternalBucketExperimentHarnessStatus.completedInternalOnly,
      );
      expect(
        result.guardStatus,
        InternalBucketExperimentGuardStatus.allowedInternalOnly,
      );
      expect(result.guardAllowed, isTrue);
      expect(result.requestedBucketCount, 13);
      expect(result.observedBucketCount, 13);
      expect(result.guardPolicyViolations, isEmpty);
      expect(result.failures, isEmpty);
    });

    test('guard-blocked request is skipped before bucket observation', () {
      final blocked = _copyBlocked(_guardSafeResult());
      final result = _run(
        InternalBucketExperimentHarnessRequest(guardResult: blocked),
      );

      expect(
        result.status,
        InternalBucketExperimentHarnessStatus.skippedByGuard,
      );
      expect(result.guardAllowed, isFalse);
      expect(result.observations, isEmpty);
      expect(result.observedBucketCount, 0);
      expect(
        result.nextRecommendation,
        InternalBucketExperimentHarnessNextRecommendation.guardPolicyFixes,
      );
    });

    test('observes supported non-quiet buckets only', () {
      final result = _run();
      final observedIds = result.observations.map((item) => item.bucketId);

      expect(
        observedIds,
        containsAll([
          InternalEvidenceBucketId.tacticalSupported,
          InternalEvidenceBucketId.materialSwingSupported,
          InternalEvidenceBucketId.forcingLineSupported,
          InternalEvidenceBucketId.kingSafetySupported,
          InternalEvidenceBucketId.endgameConservativeSupported,
          InternalEvidenceBucketId.safetySuppressionSupported,
          InternalEvidenceBucketId.androidProofBacked,
          InternalEvidenceBucketId.candidateSpreadSupported,
          InternalEvidenceBucketId.pvMultiPvSupported,
        ]),
      );
      expect(
        observedIds,
        isNot(contains(InternalEvidenceBucketId.quietPreparatoryExcluded)),
      );
      expect(
        observedIds,
        isNot(contains(InternalEvidenceBucketId.productLabelOutputBlocked)),
      );
      expect(result.observations.every((item) => item.observed), isTrue);
    });

    test('includes support case IDs and ready evidence areas', () {
      final result = _run();

      expect(
        result.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'queen-win-major-swing',
          'king-safety-mating-net-hard-case',
        ]),
      );
      expect(
        result.readyEvidenceAreas,
        containsAll([
          'tacticalEvidence',
          'materialEvidence',
          'forcingEvidence',
          'kingSafetyEvidence',
          'safetySuppressionEvidence',
          'evaluationAvailability',
        ]),
      );
    });

    test('includes Android proof IDs only for captured proven cases', () {
      final result = _run();

      expect(
        result.androidProofCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        result.androidProofCaseIds,
        isNot(contains('quiet-preparatory-hard-case')),
      );
    });

    test('keeps quiet preparatory excluded and visible', () {
      final result = _run();
      final quietInactive = result.inactiveObservations.singleWhere(
        (item) =>
            item.bucketId == InternalEvidenceBucketId.quietPreparatoryExcluded,
      );

      expect(
        result.excludedScopeIds,
        containsAll([
          'quietPreparatoryEvidenceClassification',
          'quiet-preparatory-uncertain',
        ]),
      );
      expect(quietInactive.observed, isFalse);
      expect(quietInactive.isQuietScope, isTrue);
      expect(
        quietInactive.supportCaseIds,
        contains('quiet-preparatory-hard-case'),
      );
      expect(result.observations.where((item) => item.isQuietScope), isEmpty);
    });
  });

  group('InternalBucketExperimentHarness blocked requests', () {
    test('refuses product output request through the guard', () {
      final result = _run(
        const InternalBucketExperimentHarnessRequest(
          experimentRequest: InternalBucketExperimentRequest(
            allowProductLabels: true,
            requestedBuckets: <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.tacticalSupported,
            ],
            claimedAndroidProofCaseIds: <String>[],
          ),
        ),
      );

      expect(
        result.status,
        InternalBucketExperimentHarnessStatus.skippedByGuard,
      );
      expect(
        result.guardStatus,
        InternalBucketExperimentGuardStatus.blockedByProductLabelPolicy,
      );
      expect(result.observations, isEmpty);
      expect(result.hasUnsafeHarnessOutputPolicyViolation, isTrue);
    });

    test('blocks advanced, move-quality, and official metric requests', () {
      for (final family in const [
        'Brilliant',
        'Great',
        'Miss',
        'Best',
        'Good',
        'Inaccuracy',
        'Mistake',
        'Blunder',
        'official accuracy',
        'ACPL',
      ]) {
        final result = _run(
          InternalBucketExperimentHarnessRequest(
            experimentRequest: InternalBucketExperimentRequest(
              requestedBuckets: const <InternalEvidenceBucketId>[
                InternalEvidenceBucketId.tacticalSupported,
              ],
              claimedAndroidProofCaseIds: const <String>[],
              requestedOutputFamilies: [family],
            ),
          ),
        );

        expect(
          result.status,
          InternalBucketExperimentHarnessStatus.skippedByGuard,
        );
        expect(result.observations, isEmpty);
        expect(result.hasUnsafeHarnessOutputPolicyViolation, isTrue);
      }
    });

    test('does not compute CP-loss or win probability', () {
      final result = _run();

      expect(result.cpLossComputed, isFalse);
      expect(result.winProbabilityComputed, isFalse);
      expect(result.officialMetricsEmitted, isFalse);
      expect(result.productOutputEmitted, isFalse);
      expect(result.classifierLabelsEmitted, isFalse);
    });

    test('does not use direct engine, UI, backend, or persistence', () {
      final result = _run();

      expect(result.directEngineAccessUsed, isFalse);
      expect(result.uiOutputUsed, isFalse);
      expect(result.backendOutputUsed, isFalse);
      expect(result.persistenceUsed, isFalse);
    });

    test('unproven Android proof claim is rejected by the guard', () {
      final result = _run(
        const InternalBucketExperimentHarnessRequest(
          experimentRequest: InternalBucketExperimentRequest(
            requestedBuckets: <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.androidProofBacked,
            ],
            claimedAndroidProofCaseIds: <String>[
              'mate-threat-fast-evidence',
              'quiet-preparatory-hard-case',
            ],
          ),
        ),
      );

      expect(
        result.guardStatus,
        InternalBucketExperimentGuardStatus.blockedByUnprovenAndroidProof,
      );
      expect(
        result.unprovenAndroidCaseIds,
        orderedEquals(['quiet-preparatory-hard-case']),
      );
      expect(result.observations, isEmpty);
    });

    test(
      'unsupported, future-only, and blocked buckets are skipped by guard',
      () {
        final requests = <InternalBucketExperimentHarnessRequest>[
          InternalBucketExperimentHarnessRequest(
            experimentRequest: InternalBucketExperimentRequest(
              requestedBuckets: const <InternalEvidenceBucketId>[
                InternalEvidenceBucketId.tacticalSupported,
              ],
              claimedAndroidProofCaseIds: const <String>[],
              bucketPrototype: _bucketWith(
                InternalEvidenceBucketId.tacticalSupported,
                InternalEvidenceBucketStatus.unsupported,
              ),
            ),
          ),
          const InternalBucketExperimentHarnessRequest(
            experimentRequest: InternalBucketExperimentRequest(
              requestedBuckets: <InternalEvidenceBucketId>[
                InternalEvidenceBucketId.cpLossComputationBlocked,
              ],
              claimedAndroidProofCaseIds: <String>[],
            ),
          ),
          const InternalBucketExperimentHarnessRequest(
            experimentRequest: InternalBucketExperimentRequest(
              requestedBuckets: <InternalEvidenceBucketId>[
                InternalEvidenceBucketId.productLabelOutputBlocked,
              ],
              claimedAndroidProofCaseIds: <String>[],
            ),
          ),
        ];

        for (final request in requests) {
          final result = _run(request);

          expect(
            result.status,
            InternalBucketExperimentHarnessStatus.skippedByGuard,
          );
          expect(result.observations, isEmpty);
          expect(result.blockedBucketIds, isNotEmpty);
        }
      },
    );
  });

  group('InternalBucketExperimentHarness partial buckets', () {
    test('partial bucket is observed with warning when included', () {
      final result = _run(
        InternalBucketExperimentHarnessRequest(
          includePartialBuckets: true,
          experimentRequest: InternalBucketExperimentRequest(
            requestedBuckets: const <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.tacticalSupported,
            ],
            claimedAndroidProofCaseIds: const <String>[],
            bucketPrototype: _bucketWith(
              InternalEvidenceBucketId.tacticalSupported,
              InternalEvidenceBucketStatus.partial,
            ),
          ),
        ),
      );

      expect(
        result.status,
        InternalBucketExperimentHarnessStatus.completedWithWarnings,
      );
      expect(result.observedBucketCount, 1);
      expect(result.partialWarnings, isNotEmpty);
      expect(result.observations.single.warningReason, contains('partial'));
    });

    test('partial bucket is skipped deterministically when excluded', () {
      final result = _run(
        InternalBucketExperimentHarnessRequest(
          includePartialBuckets: false,
          experimentRequest: InternalBucketExperimentRequest(
            requestedBuckets: const <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.tacticalSupported,
            ],
            claimedAndroidProofCaseIds: const <String>[],
            bucketPrototype: _bucketWith(
              InternalEvidenceBucketId.tacticalSupported,
              InternalEvidenceBucketStatus.partial,
            ),
          ),
        ),
      );

      expect(
        result.status,
        InternalBucketExperimentHarnessStatus.completedWithWarnings,
      );
      expect(result.observedBucketCount, 0);
      expect(
        result.skippedBucketIds,
        orderedEquals([InternalEvidenceBucketId.tacticalSupported]),
      );
      expect(result.inactiveObservations.first.observed, isFalse);
    });
  });

  group('InternalBucketExperimentHarness reports and guardrails', () {
    test(
      'markdown report includes status, guard, observations, and exclusions',
      () {
        final report = _run().renderMarkdownReport();

        expect(report, contains('# Internal Bucket Experiment Harness'));
        expect(report, contains('harness status: completedInternalOnly'));
        expect(report, contains('guard status: allowedInternalOnly'));
        expect(report, contains('Observations'));
        expect(report, contains('Support Cases'));
        expect(report, contains('Android Proof References'));
        expect(report, contains('Quiet Preparatory Exclusion'));
        expect(report, contains('product-label block: active'));
        expect(report, contains('official-metric block: active'));
      },
    );

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalBucketExperimentHarnessReportVersion);
      expect(decoded['harnessStatus'], 'completedInternalOnly');
      expect(decoded['guardStatus'], 'allowedInternalOnly');
      expect(decoded['observations'], isA<List<Object?>>());
      expect(decoded['supportingCaseIds'], isA<List<Object?>>());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('reports do not emit final labels or official metric names', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_harnessSource);

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

InternalBucketExperimentHarnessResult _run([
  InternalBucketExperimentHarnessRequest request =
      const InternalBucketExperimentHarnessRequest(),
]) {
  return const InternalBucketExperimentHarness().run(request);
}

InternalBucketExperimentGuardResult _guardSafeResult() {
  return const InternalBucketExperimentGuard().evaluate(
    const InternalBucketExperimentRequest.safeDemo(),
  );
}

InternalBucketExperimentGuardResult _copyBlocked(
  InternalBucketExperimentGuardResult base,
) {
  return InternalBucketExperimentGuardResult(
    experimentId: base.experimentId,
    overallStatus:
        InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
    allowed: false,
    requestedBucketCount: base.requestedBucketCount,
    allowedBucketIds: const <InternalEvidenceBucketId>[],
    warningBucketIds: const <InternalEvidenceBucketId>[],
    blockedBucketIds: base.allowedBucketIds.take(1).toList(),
    policyViolations: const <InternalBucketExperimentPolicyViolation>[],
    supportingCaseIds: const <String>[],
    excludedScopeIds: base.excludedScopeIds,
    provenAndroidCaseIds: base.provenAndroidCaseIds,
    unprovenAndroidCaseIds: const <String>[],
    warnings: const <String>[],
    failures: const <String>['guard blocked request before harness execution'],
    bucketPrototypeStatus: base.bucketPrototypeStatus,
    contractStatus: base.contractStatus,
    foundationStatus: base.foundationStatus,
    readinessStatus: base.readinessStatus,
    nextRecommendation: InternalBucketExperimentNextPhase.guardPolicyFixes,
  );
}

InternalEvidenceBucketPrototype _baseBuckets() {
  return const InternalEvidenceBucketBuilder().evaluate(
    const InternalEvidenceBucketRequest(),
  );
}

InternalEvidenceBucketPrototype _bucketWith(
  InternalEvidenceBucketId id,
  InternalEvidenceBucketStatus status,
) {
  final base = _baseBuckets();
  return base.copyWith(
    buckets: [
      for (final bucket in base.buckets)
        if (bucket.id == id) bucket.copyWith(status: status) else bucket,
    ],
  );
}

String get _harnessSource => File(
  'lib/features/pgn_review/application/internal_bucket_experiment_harness.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
