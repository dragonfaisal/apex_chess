@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh_review.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:flutter_test/flutter_test.dart';

RefreshedPacketEvidenceReadinessGateResult? _cachedGate;
InternalPacketEvidenceRefreshReviewResult? _cachedReview;

void main() {
  setUpAll(() {
    _cachedReview = const InternalPacketEvidenceRefreshReview().evaluate();
    _cachedGate = const RefreshedPacketEvidenceReadinessGate().evaluate();
  });

  group('RefreshedPacketEvidenceReadinessGate safe demo', () {
    test('consumes safe Phase 32J review result', () {
      final review = _review();
      final result = const RefreshedPacketEvidenceReadinessGate().evaluate(
        RefreshedPacketEvidenceReadinessGateRequest(reviewResult: review),
      );

      expect(
        result.sourceReviewStatus,
        InternalPacketEvidenceRefreshReviewStatus.reviewedWithWarnings,
      );
      expect(review.safeForPhase32K, isTrue);
      expect(result.safeForPhase32L, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status is ready with warning honesty', () {
      final result = _gate();

      expect(
        result.readinessStatus,
        isIn(<RefreshedPacketEvidenceReadinessStatus>[
          RefreshedPacketEvidenceReadinessStatus.readyWithWarnings,
          RefreshedPacketEvidenceReadinessStatus
              .readyForNarrowInternalEvidenceSummary,
        ]),
      );
      expect(
        result.readinessStatus,
        RefreshedPacketEvidenceReadinessStatus.readyWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.safeForPhase32L, isTrue);
    });

    test('unsafe review blocks readiness', () {
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
      final unsafeReview = const InternalPacketEvidenceRefreshReview().evaluate(
        InternalPacketEvidenceRefreshReviewRequest(
          validationResult: unsafeValidation,
          refreshedPlanResult: unsafePlan,
        ),
      );
      final result = const RefreshedPacketEvidenceReadinessGate().evaluate(
        RefreshedPacketEvidenceReadinessGateRequest(
          reviewResult: unsafeReview,
          validationResult: unsafeValidation,
          refreshedPlanResult: unsafePlan,
        ),
      );

      expect(
        result.readinessStatus,
        RefreshedPacketEvidenceReadinessStatus.blockedByUnsafeReview,
      );
      expect(result.safeForPhase32L, isFalse);
      expect(result.totalRecords, 0);
      expect(
        result.phase32LRecommendation,
        RefreshedPacketEvidenceReadinessPhase32LRecommendation
            .blockedByUnsafeReadiness,
      );
    });

    test('invalid record blocks readiness', () {
      final invalidReview = _withReviewRow(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        (row) => row.copyWith(
          reviewStatus: InternalPacketEvidenceRefreshReviewRowStatus.invalid,
          safeForNextInternalGate: false,
        ),
      );
      final result = const RefreshedPacketEvidenceReadinessGate().evaluate(
        RefreshedPacketEvidenceReadinessGateRequest(
          reviewResult: invalidReview,
        ),
      );

      expect(
        result.readinessStatus,
        RefreshedPacketEvidenceReadinessStatus.blockedByInvalidRecord,
      );
      expect(result.safeForPhase32L, isFalse);
      expect(
        result
            .record(
              InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
            )
            .readinessStatus,
        RefreshedPacketEvidenceReadinessRecordStatus.invalid,
      );
    });

    test('aggregate counts are deterministic', () {
      final first = _gate();
      final second = const RefreshedPacketEvidenceReadinessGate().evaluate();

      expect(first.totalRecords, 20);
      expect(first.allowedRecordCount, 4);
      expect(first.constrainedRecordCount, 6);
      expect(first.blockedRecordCount, 8);
      expect(first.futureOnlyRecordCount, 2);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.ownerProofQueueCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32L recommendation and support IDs are deterministic', () {
      final result = _gate();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32LRecommendation,
        RefreshedPacketEvidenceReadinessPhase32LRecommendation
            .proceedToInternalEvidenceSummaryLayer,
      );
      expect(result.safeForPhase32L, isTrue);
    });
  });

  group('Readiness record behavior', () {
    test('preserved stable records become allowed', () {
      _expectRecord(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        RefreshedPacketEvidenceReadinessGroup.preservedStableEvidenceGroup,
        RefreshedPacketEvidenceReadinessRecordStatus.allowed,
        allowed: true,
      );
      _expectRecord(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        RefreshedPacketEvidenceReadinessGroup.preservedStableEvidenceGroup,
        RefreshedPacketEvidenceReadinessRecordStatus.allowed,
        allowed: true,
      );
    });

    test('improved support records become allowed', () {
      final forcing = _gate().record(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );
      final candidate = _gate().record(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(
        forcing.readinessGroup,
        RefreshedPacketEvidenceReadinessGroup.improvedSupportEvidenceGroup,
      );
      expect(forcing.allowedForNextInternalLayer, isTrue);
      expect(
        forcing.newlyAddedSupportCaseIds,
        containsAll(<String>[
          'budget-pressure-wide-candidate-32e',
          'suppression-forced-only-legal-32e',
        ]),
      );
      expect(
        candidate.readinessGroup,
        RefreshedPacketEvidenceReadinessGroup.improvedSupportEvidenceGroup,
      );
      expect(candidate.allowedForNextInternalLayer, isTrue);
      expect(
        candidate.newlyAddedSupportCaseIds,
        containsAll(<String>[
          'endgame-precision-candidate-spread-32e',
          'pv-multipv-support-boundary-32e',
        ]),
      );
    });

    test('PV and MultiPV watch-listed record remains constrained', () {
      final record = _gate().record(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        record.readinessGroup,
        RefreshedPacketEvidenceReadinessGroup.watchListedEvidenceGroup,
      );
      expect(
        record.readinessStatus,
        RefreshedPacketEvidenceReadinessRecordStatus.constrained,
      );
      expect(record.allowedForNextInternalLayer, isFalse);
      expect(record.proofLimitReason, contains('boundary-only'));
    });

    test('Android proof-limited record remains constrained', () {
      final record = _gate().record(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        record.readinessGroup,
        RefreshedPacketEvidenceReadinessGroup.proofLimitedEvidenceGroup,
      );
      expect(
        record.readinessStatus,
        RefreshedPacketEvidenceReadinessRecordStatus.constrained,
      );
      expect(record.allowedForNextInternalLayer, isFalse);
      expect(record.androidProofCaseIds, orderedEquals(_provenAndroidIds));
    });

    test('warning-limited records remain constrained', () {
      for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
      ]) {
        _expectRecord(
          scopeId,
          RefreshedPacketEvidenceReadinessGroup.warningLimitedEvidenceGroup,
          RefreshedPacketEvidenceReadinessRecordStatus.constrained,
          allowed: false,
        );
        expect(
          _gate().record(scopeId).newlyAddedSupportCaseIds,
          isNotEmpty,
          reason: scopeId.wire,
        );
      }
    });

    test('blocked records remain blocked', () {
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
        final record = _gate().record(scopeId);
        expect(
          record.readinessStatus,
          RefreshedPacketEvidenceReadinessRecordStatus.blocked,
          reason: scopeId.wire,
        );
        expect(
          record.allowedForNextInternalLayer,
          isFalse,
          reason: scopeId.wire,
        );
      }
    });

    test('future-only records remain future-only', () {
      _expectRecord(
        InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
        RefreshedPacketEvidenceReadinessGroup.cpLossFutureOnlyGroup,
        RefreshedPacketEvidenceReadinessRecordStatus.futureOnly,
        allowed: false,
      );
      _expectRecord(
        InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
        RefreshedPacketEvidenceReadinessGroup.winProbabilityFutureOnlyGroup,
        RefreshedPacketEvidenceReadinessRecordStatus.futureOnly,
        allowed: false,
      );
    });

    test('Android proof IDs are original only and owner proof stays empty', () {
      expect(_gate().androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(_gate().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_gate().androidProofCaseIds, isNot(contains(caseId)));
        for (final record in _gate().records) {
          expect(record.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('no constrained or blocked record is promoted', () {
      for (final record in _gate().records) {
        if (!record.readinessGroup.isAllowed) {
          expect(
            record.allowedForNextInternalLayer,
            isFalse,
            reason: record.scopeId.wire,
          );
        }
      }
    });
  });

  group('RefreshedPacketEvidenceReadinessGateValidator', () {
    test(
      'rejects unproven Android proof and Phase 32E captured proof claims',
      () {
        final unproven = _gate().copyWith(
          androidProofCaseIds: <String>[
            ..._gate().androidProofCaseIds,
            'unproven-android-proof',
          ],
        );
        final phase32E = _withRecord(
          InternalNonLabelPrototypeScopeId
              .androidProofConfidenceInternalPrototypeScope,
          (record) => record.copyWith(
            androidProofCaseIds: <String>[
              ...record.androidProofCaseIds,
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
              .validate(_gate().copyWith(classifierLabelsEmitted: true))
              .map((finding) => finding.id),
          contains('readinessBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_gate().copyWith(numericMoveValuesComputed: true))
              .map((finding) => finding.id),
          contains('readinessBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_gate().copyWith(moveOrderingComputed: true))
              .map((finding) => finding.id),
          contains('readinessBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_gate().copyWith(officialMetricsAllowed: true))
              .map((finding) => finding.id),
          contains('readinessBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_gate().copyWith(quietPreparatoryScopeActivated: true))
              .map((finding) => finding.id),
          contains('readinessBoundaryPolicyViolation'),
        );
      },
    );

    test('rejects constrained promotion and core missing mapping', () {
      final promoted = _withRecord(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
        (record) => record.copyWith(
          readinessStatus: RefreshedPacketEvidenceReadinessRecordStatus.allowed,
          allowedForNextInternalLayer: true,
        ),
      );
      final missingMapping = _withRecord(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        (record) => record.copyWith(
          supportCaseIds: const <String>[],
          activeSignalIds: const [],
          evidenceAreaIds: const [],
          bucketIds: const [],
        ),
      );

      expect(
        _validator().validate(promoted).map((finding) => finding.id),
        contains('constrainedRecordPromotedToAllowed'),
      );
      expect(
        _validator().validate(missingMapping).map((finding) => finding.id),
        contains('allowedRecordMissingEvidenceMapping'),
      );
    });

    test('rejects blocked, future-only, and owner proof misuse', () {
      final blocked = _withRecord(
        InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
        (record) => record.copyWith(
          readinessStatus: RefreshedPacketEvidenceReadinessRecordStatus.allowed,
          allowedForNextInternalLayer: true,
        ),
      );
      final futureOnly = _withRecord(
        InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
        (record) => record.copyWith(
          readinessStatus: RefreshedPacketEvidenceReadinessRecordStatus.allowed,
        ),
      );
      final ownerProof = _gate().copyWith(
        ownerProofQueueCount: 1,
        records: _gate().records
            .map(
              (record) => record.copyWith(
                warningReason: '',
                proofLimitReason: '',
                futurePrerequisite: '',
              ),
            )
            .toList(),
      );

      expect(
        _validator().validate(blocked).map((finding) => finding.id),
        contains('blockedRecordBecameActive'),
      );
      expect(
        _validator().validate(futureOnly).map((finding) => finding.id),
        contains('futureOnlyRecordBecameActive'),
      );
      expect(
        _validator().validate(ownerProof).map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();
      final report = _gate().renderMarkdownReport();

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

  group('Readiness report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _gate().renderMarkdownReport();

      expect(report, contains('# Refreshed Packet Evidence Readiness Gate'));
      expect(report, contains('## Readiness Table'));
      expect(report, contains('## Allowed Records'));
      expect(report, contains('## Constrained Records'));
      expect(report, contains('## Owner Proof Status'));
      expect(report, contains('## Phase 32L Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _gate().renderJsonReport();
      final second = _gate().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        refreshedPacketEvidenceReadinessGateReportVersion,
      );
      expect(decoded['readinessStatus'], 'readyWithWarnings');
      expect(decoded['records'], isA<List<Object?>>());
      expect(decoded['safeForPhase32L'], isTrue);
    });

    test(
      'reports contain no raw engine, final label, metric, value, or ordering text',
      () {
        final report = _gate().renderMarkdownReport();

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
        'lib/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart',
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

RefreshedPacketEvidenceReadinessGateResult _gate() => _cachedGate!;

InternalPacketEvidenceRefreshReviewResult _review() => _cachedReview!;

RefreshedPacketEvidenceReadinessGateValidator _validator() {
  return const RefreshedPacketEvidenceReadinessGateValidator();
}

void _expectRecord(
  InternalNonLabelPrototypeScopeId scopeId,
  RefreshedPacketEvidenceReadinessGroup group,
  RefreshedPacketEvidenceReadinessRecordStatus status, {
  required bool allowed,
}) {
  final record = _gate().record(scopeId);
  expect(record.readinessGroup, group, reason: scopeId.wire);
  expect(record.readinessStatus, status, reason: scopeId.wire);
  expect(record.allowedForNextInternalLayer, allowed, reason: scopeId.wire);
}

InternalPacketEvidenceRefreshReviewResult _withReviewRow(
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

RefreshedPacketEvidenceReadinessGateResult _withRecord(
  InternalNonLabelPrototypeScopeId scopeId,
  RefreshedPacketEvidenceReadinessRecord Function(
    RefreshedPacketEvidenceReadinessRecord record,
  )
  update,
) {
  final records = _gate().records.map((record) {
    if (record.scopeId == scopeId) return update(record);
    return record;
  }).toList();
  return _gate().copyWith(records: records);
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
