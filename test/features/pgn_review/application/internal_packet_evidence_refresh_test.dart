@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_refresh.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:flutter_test/flutter_test.dart';

InternalPacketEvidenceRefreshResult? _cachedRefresh;
RefreshedPacketHardeningValidationResult? _cachedValidation;

void main() {
  setUpAll(() {
    _cachedRefresh = const InternalPacketEvidenceRefresh().evaluate();
    _cachedValidation = const RefreshedPacketHardeningValidation().evaluate();
  });

  group('InternalPacketEvidenceRefresh safe demo', () {
    test('consumes safe Phase 32H validation', () {
      final validation = _validation();
      final result = const InternalPacketEvidenceRefresh().evaluate(
        InternalPacketEvidenceRefreshRequest(validationResult: validation),
      );

      expect(
        result.sourceValidationStatus,
        RefreshedPacketHardeningValidationStatus.validatedWithWarnings,
      );
      expect(validation.safeForPhase32I, isTrue);
      expect(result.safeForPhase32J, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status refreshes with warning honesty', () {
      final result = _refresh();

      expect(
        result.refreshStatus,
        isIn(<InternalPacketEvidenceRefreshStatus>[
          InternalPacketEvidenceRefreshStatus.refreshedWithWarnings,
          InternalPacketEvidenceRefreshStatus.refreshedClean,
        ]),
      );
      expect(
        result.refreshStatus,
        InternalPacketEvidenceRefreshStatus.refreshedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.safeForPhase32J, isTrue);
    });

    test('unsafe validation blocks refresh', () {
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
      final result = const InternalPacketEvidenceRefresh().evaluate(
        InternalPacketEvidenceRefreshRequest(
          validationResult: unsafeValidation,
          refreshedPlanResult: unsafePlan,
        ),
      );

      expect(
        result.refreshStatus,
        InternalPacketEvidenceRefreshStatus.blockedByUnsafeValidation,
      );
      expect(result.safeForPhase32J, isFalse);
      expect(result.totalRecords, 0);
      expect(
        result.phase32JRecommendation,
        InternalPacketEvidenceRefreshPhase32JRecommendation
            .blockedByUnsafeRefresh,
      );
    });

    test('aggregate counts are deterministic', () {
      final first = _refresh();
      final second = const InternalPacketEvidenceRefresh().evaluate();

      expect(first.totalRecords, 20);
      expect(first.refreshedPacketCount, 6);
      expect(first.improvedSupportCount, 2);
      expect(first.preservedStableCount, 2);
      expect(first.watchListedCount, 1);
      expect(first.proofLimitedCount, 1);
      expect(first.warningLimitedCount, 4);
      expect(first.blockedCount, 8);
      expect(first.futureOnlyCount, 2);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.ownerProofQueueCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32J recommendation and support IDs are deterministic', () {
      final result = _refresh();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32JRecommendation,
        InternalPacketEvidenceRefreshPhase32JRecommendation
            .reviewRefreshedPacketEvidence,
      );
      expect(result.safeForPhase32J, isTrue);
    });
  });

  group('Refreshed record behavior', () {
    test('tactical and material packets are preserved stable', () {
      _expectStatus(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        InternalPacketEvidenceRefreshRecordStatus.preservedStable,
      );
      _expectStatus(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        InternalPacketEvidenceRefreshRecordStatus.preservedStable,
      );
    });

    test('forcing and candidate-spread packets record Phase 32E support', () {
      final forcing = _refresh().record(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );
      final candidate = _refresh().record(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(
        forcing.refreshStatus,
        isIn(<InternalPacketEvidenceRefreshRecordStatus>[
          InternalPacketEvidenceRefreshRecordStatus.improvedSupport,
          InternalPacketEvidenceRefreshRecordStatus.preservedStable,
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
        candidate.refreshStatus,
        isIn(<InternalPacketEvidenceRefreshRecordStatus>[
          InternalPacketEvidenceRefreshRecordStatus.improvedSupport,
          InternalPacketEvidenceRefreshRecordStatus.preservedStable,
        ]),
      );
      expect(
        candidate.newlyAddedSupportCaseIds,
        containsAll(<String>[
          'endgame-precision-candidate-spread-32e',
          'pv-multipv-support-boundary-32e',
        ]),
      );
      expect(forcing.safeForInternalUse, isTrue);
      expect(candidate.safeForInternalUse, isTrue);
    });

    test('PV and MultiPV packet remains watch-listed', () {
      final record = _refresh().record(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        record.refreshStatus,
        InternalPacketEvidenceRefreshRecordStatus.watchListed,
      );
      expect(
        record.newlyAddedSupportCaseIds,
        contains('pv-multipv-support-boundary-32e'),
      );
      expect(record.proofLimitReason, contains('boundary-only'));
      expect(record.safeForInternalUse, isTrue);
    });

    test('Android proof packet remains proof-limited', () {
      final record = _refresh().record(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        record.refreshStatus,
        InternalPacketEvidenceRefreshRecordStatus.proofLimited,
      );
      expect(
        record.packetKind,
        InternalPacketEvidenceHardeningTargetKind.androidProofScope,
      );
      expect(record.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(record.proofLimitReason, contains('captured Android proof IDs'));
    });

    test('no Phase 32E case claims captured Android proof', () {
      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_refresh().androidProofCaseIds, isNot(contains(caseId)));
        for (final record in _refresh().records) {
          expect(record.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('owner proof queue remains empty by default', () {
      expect(_refresh().ownerProofQueueCount, 0);
    });

    test(
      'warning-limited scopes remain outside core with improved support',
      () {
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
      },
    );

    test(
      'quiet, product, advanced, metric, and integration scopes stay blocked',
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
          final record = _refresh().record(scopeId);
          expect(
            record.refreshStatus,
            InternalPacketEvidenceRefreshRecordStatus.blockedCorrectly,
            reason: scopeId.wire,
          );
          expect(record.safeForInternalUse, isTrue, reason: scopeId.wire);
        }
      },
    );

    test('CP-loss and win probability remain future-only', () {
      for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
        InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
      ]) {
        final record = _refresh().record(scopeId);
        expect(
          record.refreshStatus,
          InternalPacketEvidenceRefreshRecordStatus.futureOnlyCorrectly,
          reason: scopeId.wire,
        );
        expect(record.safeForInternalUse, isTrue, reason: scopeId.wire);
      }
    });
  });

  group('InternalPacketEvidenceRefreshValidator', () {
    test('rejects watch-listed PV and MultiPV promotion without proof', () {
      final result = _withRecord(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
        (record) => record.copyWith(
          refreshStatus:
              InternalPacketEvidenceRefreshRecordStatus.preservedStable,
        ),
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('watchListedPvMultiPvPromotedWithoutProof'),
      );
    });

    test('rejects warning-limited target promoted to core packet', () {
      final result = _withRecord(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        (record) => record.copyWith(
          packetKind: InternalPacketEvidenceHardeningTargetKind.packet,
          refreshStatus:
              InternalPacketEvidenceRefreshRecordStatus.improvedSupport,
        ),
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('warningLimitedScopePromotedToCorePacket'),
      );
    });

    test(
      'rejects core packet without support, signal, area, or bucket mapping',
      () {
        final result = _withRecord(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (record) => record.copyWith(
            refreshedSupportCaseIds: const <String>[],
            activeSignalIds: const [],
            evidenceAreaIds: const [],
            bucketIds: const [],
          ),
        );

        expect(
          _validator().validate(result).map((finding) => finding.id),
          contains('corePacketMissingEvidenceMapping'),
        );
      },
    );

    test(
      'rejects unproven Android proof and Phase 32E captured proof claims',
      () {
        final unproven = _refresh().copyWith(
          androidProofCaseIds: <String>[
            ..._refresh().androidProofCaseIds,
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
              .validate(_refresh().copyWith(classifierLabelsEmitted: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_refresh().copyWith(numericMoveValuesComputed: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_refresh().copyWith(moveOrderingComputed: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(_refresh().copyWith(officialMetricsAllowed: true))
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
        expect(
          validator
              .validate(
                _refresh().copyWith(quietPreparatoryScopeActivated: true),
              )
              .map((finding) => finding.id),
          contains('refreshBoundaryPolicyViolation'),
        );
      },
    );

    test('rejects product output and blocked scope activation on records', () {
      final product = _withRecord(
        InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
        (record) => record.copyWith(isProductOutput: true),
      );
      final quiet = _withRecord(
        InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
        (record) => record.copyWith(
          refreshStatus:
              InternalPacketEvidenceRefreshRecordStatus.improvedSupport,
          quietScopeActive: true,
        ),
      );

      expect(
        _validator().validate(product).map((finding) => finding.id),
        contains('recordBoundaryPolicyViolation'),
      );
      expect(
        _validator().validate(quiet).map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();
      final report = _refresh().renderMarkdownReport();

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

  group('Refresh report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _refresh().renderMarkdownReport();

      expect(report, contains('# Internal Packet Evidence Refresh'));
      expect(report, contains('## Refreshed Evidence Table'));
      expect(report, contains('## Improved Support Records'));
      expect(report, contains('## Watch-Listed Records'));
      expect(report, contains('## Proof-Limited Records'));
      expect(report, contains('## Warning-Limited Records'));
      expect(report, contains('## Owner Proof Status'));
      expect(report, contains('## Phase 32J Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _refresh().renderJsonReport();
      final second = _refresh().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalPacketEvidenceRefreshReportVersion);
      expect(decoded['refreshStatus'], 'refreshedWithWarnings');
      expect(decoded['records'], isA<List<Object?>>());
      expect(decoded['safeForPhase32J'], isTrue);
    });

    test(
      'reports contain no raw engine, final label, metric, value, or ordering text',
      () {
        final report = _refresh().renderMarkdownReport();

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
        'lib/features/pgn_review/application/internal_packet_evidence_refresh.dart',
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

InternalPacketEvidenceRefreshResult _refresh() => _cachedRefresh!;

RefreshedPacketHardeningValidationResult _validation() => _cachedValidation!;

InternalPacketEvidenceRefreshValidator _validator() {
  return const InternalPacketEvidenceRefreshValidator();
}

void _expectStatus(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketEvidenceRefreshRecordStatus status,
) {
  final record = _refresh().record(scopeId);
  expect(record.refreshStatus, status, reason: scopeId.wire);
  expect(record.safeForInternalUse, isTrue, reason: scopeId.wire);
}

void _expectWarningLimited(
  InternalNonLabelPrototypeScopeId scopeId,
  String expectedCaseId,
) {
  final record = _refresh().record(scopeId);

  expect(
    record.refreshStatus,
    InternalPacketEvidenceRefreshRecordStatus.warningLimitedOnly,
    reason: scopeId.wire,
  );
  expect(
    record.packetKind,
    InternalPacketEvidenceHardeningTargetKind.warningScope,
    reason: scopeId.wire,
  );
  expect(record.newlyAddedSupportCaseIds, contains(expectedCaseId));
  expect(record.safeForInternalUse, isTrue, reason: scopeId.wire);
}

InternalPacketEvidenceRefreshResult _withRecord(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketEvidenceRefreshRecord Function(
    InternalPacketEvidenceRefreshRecord record,
  )
  update,
) {
  final records = _refresh().records.map((record) {
    if (record.scopeId == scopeId) return update(record);
    return record;
  }).toList();
  return _refresh().copyWith(records: records);
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
