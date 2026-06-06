@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh_review.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:flutter_test/flutter_test.dart';

InternalPacketEvidenceRefreshReviewResult? _cachedReview;
InternalPacketEvidenceRefreshResult? _cachedRefresh;

void main() {
  setUpAll(() {
    _cachedRefresh = const InternalPacketEvidenceRefresh().evaluate();
    _cachedReview = const InternalPacketEvidenceRefreshReview().evaluate();
  });

  group('InternalPacketEvidenceRefreshReview safe demo', () {
    test('consumes safe Phase 32I refresh result', () {
      final refresh = _refresh();
      final result = const InternalPacketEvidenceRefreshReview().evaluate(
        InternalPacketEvidenceRefreshReviewRequest(refreshResult: refresh),
      );

      expect(
        result.sourceRefreshStatus,
        InternalPacketEvidenceRefreshStatus.refreshedWithWarnings,
      );
      expect(refresh.safeForPhase32J, isTrue);
      expect(result.safeForPhase32K, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status reviews with warning honesty', () {
      final result = _review();

      expect(
        result.reviewStatus,
        isIn(<InternalPacketEvidenceRefreshReviewStatus>[
          InternalPacketEvidenceRefreshReviewStatus.reviewedWithWarnings,
          InternalPacketEvidenceRefreshReviewStatus.reviewedClean,
        ]),
      );
      expect(
        result.reviewStatus,
        InternalPacketEvidenceRefreshReviewStatus.reviewedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.safeForPhase32K, isTrue);
    });

    test('unsafe refresh blocks review', () {
      final unsafePlan = const RefreshedInternalPacketHardeningPlan()
          .evaluate()
          .copyWith(
            refreshedStatus:
                RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact,
            unsafeCount: 1,
            safeForPhase32H: false,
          );
      final unsafeValidation = const RefreshedPacketHardeningValidation()
          .evaluate(
            RefreshedPacketHardeningValidationRequest(
              refreshedPlanResult: unsafePlan,
            ),
          );
      final result = const InternalPacketEvidenceRefreshReview().evaluate(
        InternalPacketEvidenceRefreshReviewRequest(
          validationResult: unsafeValidation,
          refreshedPlanResult: unsafePlan,
        ),
      );

      expect(
        result.reviewStatus,
        InternalPacketEvidenceRefreshReviewStatus.blockedByUnsafeRefresh,
      );
      expect(result.safeForPhase32K, isFalse);
      expect(result.totalRows, 0);
      expect(
        result.phase32KRecommendation,
        InternalPacketEvidenceRefreshReviewPhase32KRecommendation
            .blockedByUnsafeReview,
      );
    });

    test('aggregate counts are deterministic', () {
      final first = _review();
      final second = const InternalPacketEvidenceRefreshReview().evaluate();

      expect(first.totalRows, 20);
      expect(first.validImprovedSupportCount, 2);
      expect(first.validPreservedStableCount, 2);
      expect(first.validWatchListedCount, 1);
      expect(first.validProofLimitedCount, 1);
      expect(first.validWarningLimitedCount, 4);
      expect(first.validBlockedCount, 8);
      expect(first.validFutureOnlyCount, 2);
      expect(first.invalidCount, 0);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.ownerProofQueueCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32K recommendation and support IDs are deterministic', () {
      final result = _review();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32KRecommendation,
        InternalPacketEvidenceRefreshReviewPhase32KRecommendation
            .proceedToRefreshedEvidenceReadinessGate,
      );
      expect(result.safeForPhase32K, isTrue);
    });
  });

  group('Review row behavior', () {
    test('tactical and material records are valid preserved stable', () {
      _expectStatus(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
      );
      _expectStatus(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
      );
    });

    test('forcing and candidate-spread records keep Phase 32E support', () {
      final forcing = _review().row(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );
      final candidate = _review().row(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(
        forcing.reviewStatus,
        isIn(<InternalPacketEvidenceRefreshReviewRowStatus>[
          InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
          InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
        ]),
      );
      expect(
        forcing.newlyAddedSupportCaseIds,
        containsAll(<String>[
          'budget-pressure-wide-candidate-32e',
          'suppression-forced-only-legal-32e',
        ]),
      );
      expect(
        candidate.reviewStatus,
        isIn(<InternalPacketEvidenceRefreshReviewRowStatus>[
          InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
          InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
        ]),
      );
      expect(
        candidate.newlyAddedSupportCaseIds,
        containsAll(<String>[
          'endgame-precision-candidate-spread-32e',
          'pv-multipv-support-boundary-32e',
        ]),
      );
      expect(forcing.safeForNextInternalGate, isTrue);
      expect(candidate.safeForNextInternalGate, isTrue);
    });

    test('PV and MultiPV record remains valid watch-listed', () {
      final row = _review().row(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        row.reviewStatus,
        InternalPacketEvidenceRefreshReviewRowStatus.validWatchListed,
      );
      expect(
        row.newlyAddedSupportCaseIds,
        contains('pv-multipv-support-boundary-32e'),
      );
      expect(row.proofLimitReason, contains('boundary-only'));
      expect(row.safeForNextInternalGate, isTrue);
    });

    test('Android proof record remains valid proof-limited', () {
      final row = _review().row(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        row.reviewStatus,
        InternalPacketEvidenceRefreshReviewRowStatus.validProofLimited,
      );
      expect(
        row.packetKind,
        InternalPacketEvidenceHardeningTargetKind.androidProofScope,
      );
      expect(row.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(row.proofLimitReason, contains('captured Android proof IDs'));
    });

    test('no Phase 32E case claims captured Android proof', () {
      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_review().androidProofCaseIds, isNot(contains(caseId)));
        for (final row in _review().rows) {
          expect(row.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('owner proof queue remains empty by default', () {
      expect(_review().ownerProofQueueCount, 0);
    });

    test('warning-limited scopes stay valid warning-limited', () {
      _expectWarningLimited(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        'king-safety-mating-net-pressure-32e',
      );
      _expectWarningLimited(
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        'endgame-precision-candidate-spread-32e',
      );
      _expectWarningLimited(
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
        'suppression-forced-only-legal-32e',
      );
      _expectWarningLimited(
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
        'budget-pressure-wide-candidate-32e',
      );
    });

    test(
      'quiet, product, advanced, metric, and integration records stay blocked',
      () {
        for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
          InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
          InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
          InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
          InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
          InternalNonLabelPrototypeScopeId.backendIntegrationScope,
          InternalNonLabelPrototypeScopeId.persistenceScope,
          InternalNonLabelPrototypeScopeId.directEngineAccessScope,
        ]) {
          final row = _review().row(scopeId);
          expect(
            row.reviewStatus,
            InternalPacketEvidenceRefreshReviewRowStatus.validBlocked,
            reason: scopeId.wire,
          );
          expect(row.safeForNextInternalGate, isTrue, reason: scopeId.wire);
        }
      },
    );

    test('CP-loss and win probability remain valid future-only', () {
      for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
        InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
      ]) {
        final row = _review().row(scopeId);
        expect(
          row.reviewStatus,
          InternalPacketEvidenceRefreshReviewRowStatus.validFutureOnly,
          reason: scopeId.wire,
        );
        expect(row.safeForNextInternalGate, isTrue, reason: scopeId.wire);
      }
    });
  });

  group('InternalPacketEvidenceRefreshReviewValidator', () {
    test('rejects watch-listed PV and MultiPV promotion without proof', () {
      final result = _withRow(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
        (row) => row.copyWith(
          reviewStatus:
              InternalPacketEvidenceRefreshReviewRowStatus.validPreservedStable,
        ),
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('watchListedPvMultiPvPromotedWithoutProof'),
      );
    });

    test('rejects warning-limited target promoted to core packet', () {
      final result = _withRow(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        (row) => row.copyWith(
          packetKind: InternalPacketEvidenceHardeningTargetKind.packet,
          reviewStatus:
              InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
        ),
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('warningLimitedScopePromotedToCorePacket'),
      );
    });

    test('rejects core packet review without source mapping', () {
      final result = _withRow(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        (row) => row.copyWith(
          supportCaseIds: const <String>[],
          activeSignalIds: const [],
          evidenceAreaIds: const [],
          bucketIds: const [],
        ),
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('corePacketReviewMissingEvidenceMapping'),
      );
    });

    test(
      'rejects unproven Android proof and Phase 32E captured proof claims',
      () {
        final unproven = _review().copyWith(
          androidProofCaseIds: <String>[
            ..._review().androidProofCaseIds,
            'unproven-android-proof',
          ],
        );
        final phase32E = _withRow(
          InternalNonLabelPrototypeScopeId
              .androidProofConfidenceInternalPrototypeScope,
          (row) => row.copyWith(
            androidProofCaseIds: <String>[
              ...row.androidProofCaseIds,
              'pv-multipv-support-boundary-32e',
            ],
          ),
        );

        expect(
          _validator().validate(unproven).map((finding) => finding.id),
          contains('unprovenAndroidProofClaim'),
        );
        expect(
          _validator().validate(phase32E).map((finding) => finding.id),
          contains('phase32ECaseClaimedCapturedProof'),
        );
      },
    );

    test(
      'rejects label, value, ordering, metric, and quiet activation output',
      () {
        final validator = _validator();

        expect(
          validator
              .validate(_review().copyWith(classifierLabelsEmitted: true))
              .map((finding) => finding.id),
          contains('reviewBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_review().copyWith(numericMoveValuesComputed: true))
              .map((finding) => finding.id),
          contains('reviewBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_review().copyWith(moveOrderingComputed: true))
              .map((finding) => finding.id),
          contains('reviewBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_review().copyWith(officialMetricsAllowed: true))
              .map((finding) => finding.id),
          contains('reviewBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(
                _review().copyWith(quietPreparatoryScopeActivated: true),
              )
              .map((finding) => finding.id),
          contains('reviewBoundaryPolicyViolation'),
        );
      },
    );

    test('rejects product output and blocked record activation', () {
      final product = _withRow(
        InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
        (row) => row.copyWith(isProductOutput: true),
      );
      final quiet = _withRow(
        InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
        (row) => row.copyWith(
          reviewStatus:
              InternalPacketEvidenceRefreshReviewRowStatus.validImprovedSupport,
          quietScopeActive: true,
        ),
      );

      expect(
        _validator().validate(product).map((finding) => finding.id),
        contains('reviewRowBoundaryPolicyViolation'),
      );
      expect(
        _validator().validate(quiet).map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();
      final report = _review().renderMarkdownReport();

      expect(validator.validateReportText(report), isEmpty);
      expect(
        validator
            .validateReportText('uciok\ninfo depth 1\nbestmove e2e4')
            .map((finding) => finding.id),
        contains('rawUciReportText'),
      );
      expect(
        validator
            .validateReportText('rankedMoves: e2e4')
            .map((finding) => finding.id),
        contains('moveOrderingReportText'),
      );
    });
  });

  group('Review report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _review().renderMarkdownReport();

      expect(report, contains('# Internal Packet Evidence Refresh Review'));
      expect(report, contains('## Review Table'));
      expect(report, contains('## Improved Support Records'));
      expect(report, contains('## Watch-Listed Records'));
      expect(report, contains('## Proof-Limited Records'));
      expect(report, contains('## Owner Proof Status'));
      expect(report, contains('## Phase 32K Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _review().renderJsonReport();
      final second = _review().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalPacketEvidenceRefreshReviewReportVersion,
      );
      expect(decoded['reviewStatus'], 'reviewedWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
      expect(decoded['safeForPhase32K'], isTrue);
    });

    test(
      'reports contain no raw engine, final label, metric, value, or ordering text',
      () {
        final report = _review().renderMarkdownReport();

        for (final token in const <String>[
          'uciok',
          'readyok',
          'info depth',
          'bestmove e2e4',
          ' pv ',
          'pvMoves',
          'Brilliant',
          'Great',
          'Miss',
          'Best',
          'Good',
          'Inaccuracy',
          'Mistake',
          'Blunder',
          'ACPL',
          'accuracy',
          'numeric move score:',
          'scoreValue',
          'moveScore',
          'rankedMoves',
          'moveRanking',
        ]) {
          expect(report, isNot(contains(token)), reason: token);
        }
      },
    );

    test('source does not import engine, UI, backend, or persistence seams', () {
      final source = File(
        'lib/features/pgn_review/application/internal_packet_evidence_refresh_review.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
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

InternalPacketEvidenceRefreshReviewResult _review() => _cachedReview!;

InternalPacketEvidenceRefreshResult _refresh() => _cachedRefresh!;

InternalPacketEvidenceRefreshReviewValidator _validator() {
  return const InternalPacketEvidenceRefreshReviewValidator();
}

void _expectStatus(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketEvidenceRefreshReviewRowStatus status,
) {
  final row = _review().row(scopeId);
  expect(row.reviewStatus, status, reason: scopeId.wire);
  expect(row.safeForNextInternalGate, isTrue, reason: scopeId.wire);
}

void _expectWarningLimited(
  InternalNonLabelPrototypeScopeId scopeId,
  String expectedCaseId,
) {
  final row = _review().row(scopeId);

  expect(
    row.reviewStatus,
    InternalPacketEvidenceRefreshReviewRowStatus.validWarningLimited,
    reason: scopeId.wire,
  );
  expect(
    row.packetKind,
    InternalPacketEvidenceHardeningTargetKind.warningScope,
    reason: scopeId.wire,
  );
  expect(row.newlyAddedSupportCaseIds, contains(expectedCaseId));
  expect(row.safeForNextInternalGate, isTrue, reason: scopeId.wire);
}

InternalPacketEvidenceRefreshReviewResult _withRow(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketEvidenceRefreshReviewRow Function(
    InternalPacketEvidenceRefreshReviewRow row,
  )
  update,
) {
  final rows = _review().rows.map((row) {
    if (row.scopeId == scopeId) return update(row);
    return row;
  }).toList();
  return _review().copyWith(rows: rows);
}

const _phase32ECaseIdsSorted = <String>[
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
];

const _provenAndroidIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];
