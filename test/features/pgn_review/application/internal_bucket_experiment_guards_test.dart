@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalBucketExperimentGuard safe default', () {
    test('safe default experiment is allowed internal-only', () {
      final result = _run();

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.allowedInternalOnly,
      );
      expect(result.allowed, isTrue);
      expect(result.requestedBucketCount, 13);
      expect(result.policyViolations, isEmpty);
      expect(result.failures, isEmpty);
    });

    test('safe default includes only supported non-quiet buckets', () {
      final result = _run();

      expect(
        result.allowedBucketIds,
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
        result.allowedBucketIds,
        isNot(contains(InternalEvidenceBucketId.quietPreparatoryExcluded)),
      );
      expect(
        result.allowedBucketIds,
        isNot(contains(InternalEvidenceBucketId.productLabelOutputBlocked)),
      );
    });

    test('supporting case IDs and negative guard are preserved', () {
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
        result.excludedScopeIds,
        containsAll([
          'quietPreparatoryEvidenceClassification',
          'quiet-preparatory-uncertain',
        ]),
      );
    });
  });

  group('InternalBucketExperimentPolicy bucket behavior', () {
    test('partial bucket produces warning, not product output', () {
      final base = _baseBuckets();
      final partial = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.tacticalSupported)
              bucket.copyWith(status: InternalEvidenceBucketStatus.partial)
            else
              bucket,
        ],
      );
      final result = _run(
        InternalBucketExperimentRequest(
          requestedBuckets: const <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: const <String>[],
          bucketPrototype: partial,
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.allowedWithWarnings,
      );
      expect(result.allowed, isTrue);
      expect(
        result.warningBucketIds,
        orderedEquals([InternalEvidenceBucketId.tacticalSupported]),
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('partialBucketRequested'),
      );
    });

    test('unsupported bucket blocks request', () {
      final base = _baseBuckets();
      final unsupported = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.tacticalSupported)
              bucket.copyWith(status: InternalEvidenceBucketStatus.unsupported)
            else
              bucket,
        ],
      );
      final result = _run(
        InternalBucketExperimentRequest(
          requestedBuckets: const <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: const <String>[],
          bucketPrototype: unsupported,
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
      );
      expect(result.allowed, isFalse);
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('unsupportedBucketRequested'),
      );
    });

    test('blocked bucket cannot be allowed', () {
      final result = _run(
        const InternalBucketExperimentRequest(
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.productLabelOutputBlocked,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
      );
      expect(
        result.blockedBucketIds,
        orderedEquals([InternalEvidenceBucketId.productLabelOutputBlocked]),
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('blockedBucketRequested'),
      );
    });

    test('future-only bucket cannot be consumed as present', () {
      final result = _run(
        const InternalBucketExperimentRequest(
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.cpLossComputationBlocked,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('futureOnlyBucketRequested'),
      );
    });

    test('quiet preparatory bucket is blocked by exclusion', () {
      final result = _run(
        const InternalBucketExperimentRequest(
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.quietPreparatoryExcluded,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByQuietScopeExclusion,
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        containsAll(['excludedBucketRequested', 'quietScopeRequested']),
      );
    });
  });

  group('InternalBucketExperimentPolicy output and boundary behavior', () {
    test('product label request is blocked', () {
      final result = _run(
        const InternalBucketExperimentRequest(
          allowProductLabels: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByProductLabelPolicy,
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('productLabelOutputRequested'),
      );
    });

    test('advanced label requests are blocked', () {
      for (final family in const ['Brilliant', 'Great', 'Miss']) {
        final result = _run(
          InternalBucketExperimentRequest(
            requestedBuckets: const <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.tacticalSupported,
            ],
            claimedAndroidProofCaseIds: const <String>[],
            requestedOutputFamilies: [family],
          ),
        );

        expect(
          result.overallStatus,
          InternalBucketExperimentGuardStatus.blockedByAdvancedLabelPolicy,
        );
        expect(
          result.policyViolations.map((violation) => violation.id),
          contains('advancedLabelOutputRequested'),
        );
      }
    });

    test('move-quality output requests are blocked', () {
      for (final family in const [
        'Best',
        'Good',
        'Inaccuracy',
        'Mistake',
        'Blunder',
      ]) {
        final result = _run(
          InternalBucketExperimentRequest(
            requestedBuckets: const <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.tacticalSupported,
            ],
            claimedAndroidProofCaseIds: const <String>[],
            requestedOutputFamilies: [family],
          ),
        );

        expect(
          result.overallStatus,
          InternalBucketExperimentGuardStatus.blockedByProductLabelPolicy,
        );
        expect(
          result.policyViolations.map((violation) => violation.id),
          contains('productLabelOutputRequested'),
        );
      }
    });

    test('official metric requests are blocked', () {
      for (final family in const ['official accuracy', 'ACPL']) {
        final result = _run(
          InternalBucketExperimentRequest(
            requestedBuckets: const <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.tacticalSupported,
            ],
            claimedAndroidProofCaseIds: const <String>[],
            requestedOutputFamilies: [family],
          ),
        );

        expect(
          result.overallStatus,
          InternalBucketExperimentGuardStatus.blockedByOfficialMetricPolicy,
        );
        expect(
          result.policyViolations.map((violation) => violation.id),
          contains('officialMetricOutputRequested'),
        );
      }
    });

    test('CP-loss and win-probability computation requests are blocked', () {
      final cpLoss = _run(
        const InternalBucketExperimentRequest(
          allowCpLossComputation: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );
      final winProbability = _run(
        const InternalBucketExperimentRequest(
          allowWinProbabilityComputation: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        cpLoss.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByComputationPolicy,
      );
      expect(
        winProbability.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByComputationPolicy,
      );
      expect(
        cpLoss.policyViolations.map((violation) => violation.id),
        contains('cpLossComputationRequested'),
      );
      expect(
        winProbability.policyViolations.map((violation) => violation.id),
        contains('winProbabilityComputationRequested'),
      );
    });

    test('direct engine access request is blocked', () {
      final result = _run(
        const InternalBucketExperimentRequest(
          allowDirectEngineAccess: true,
          requestedEngineAccessApis: <String>['LocalEvalService', 'Stockfish'],
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByEngineAccessPolicy,
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('directEngineAccessRequested'),
      );
    });

    test('UI, backend, and persistence requests are blocked', () {
      final persistence = _run(
        const InternalBucketExperimentRequest(
          allowPersistence: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );
      final boundary = _run(
        const InternalBucketExperimentRequest(
          allowUiOutput: true,
          allowBackendOutput: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        persistence.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByPersistencePolicy,
      );
      expect(
        boundary.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByUiOrBackendPolicy,
      );
    });
  });

  group('InternalBucketExperimentPolicy Android proof behavior', () {
    test(
      'captured Android proof IDs are allowed as evidence reference only',
      () {
        final result = _run(
          const InternalBucketExperimentRequest(
            requestedBuckets: <InternalEvidenceBucketId>[
              InternalEvidenceBucketId.androidProofBacked,
            ],
            claimedAndroidProofCaseIds: <String>[
              'mate-threat-fast-evidence',
              'queen-win-major-swing',
              'simple-tactical-capture-check',
            ],
          ),
        );

        expect(result.allowed, isTrue);
        expect(
          result.provenAndroidCaseIds,
          orderedEquals([
            'mate-threat-fast-evidence',
            'queen-win-major-swing',
            'simple-tactical-capture-check',
          ]),
        );
        expect(result.unprovenAndroidCaseIds, isEmpty);
      },
    );

    test('unproven Android proof claim is blocked', () {
      final result = _run(
        const InternalBucketExperimentRequest(
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.androidProofBacked,
          ],
          claimedAndroidProofCaseIds: <String>[
            'mate-threat-fast-evidence',
            'quiet-preparatory-hard-case',
          ],
        ),
      );

      expect(
        result.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByUnprovenAndroidProof,
      );
      expect(
        result.unprovenAndroidCaseIds,
        orderedEquals(['quiet-preparatory-hard-case']),
      );
      expect(
        result.policyViolations.map((violation) => violation.id),
        contains('unprovenAndroidProofClaim'),
      );
    });
  });

  group('InternalBucketExperimentGuard reports and guardrails', () {
    test('markdown report includes guard status and policy sections', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('# Internal Bucket Experiment Guards'));
      expect(report, contains('allowedInternalOnly'));
      expect(report, contains('Policy Violations'));
      expect(report, contains('Quiet Preparatory Exclusion'));
      expect(report, contains('Android Proof Claim Check'));
      expect(report, contains('Phase 31E'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalBucketExperimentGuardsReportVersion);
      expect(decoded['status'], 'allowedInternalOnly');
      expect(decoded['allowed'], isTrue);
      expect(decoded['allowedBucketIds'], isA<List<Object?>>());
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

      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_guardSource);

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

InternalBucketExperimentGuardResult _run([
  InternalBucketExperimentRequest request =
      const InternalBucketExperimentRequest.safeDemo(),
]) {
  return const InternalBucketExperimentGuard().evaluate(request);
}

InternalEvidenceBucketPrototype _baseBuckets() {
  return const InternalEvidenceBucketBuilder().evaluate(
    const InternalEvidenceBucketRequest(),
  );
}

String get _guardSource => File(
  'lib/features/pgn_review/application/internal_bucket_experiment_guards.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
