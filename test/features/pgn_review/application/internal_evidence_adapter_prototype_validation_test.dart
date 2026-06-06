@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:flutter_test/flutter_test.dart';

InternalEvidenceAdapterPrototypeValidationResult? _cachedValidation;
InternalEvidenceAdapterPrototypeReviewResult? _cachedReview;
InternalEvidenceAdapterPrototypeResult? _cachedPrototype;
InternalEvidenceAdapterDesignResult? _cachedDesign;
InternalEvidenceSummaryLayerResult? _cachedSummary;
RefreshedPacketEvidenceReadinessGateResult? _cachedReadiness;

void main() {
  setUpAll(() {
    _cachedReadiness = const RefreshedPacketEvidenceReadinessGate().evaluate();
    _cachedSummary = const InternalEvidenceSummaryLayer().evaluate(
      InternalEvidenceSummaryLayerRequest(readinessResult: _cachedReadiness),
    );
    _cachedDesign = const InternalEvidenceAdapterDesign().evaluate(
      InternalEvidenceAdapterDesignRequest(
        summaryResult: _cachedSummary,
        readinessResult: _cachedReadiness,
      ),
    );
    _cachedPrototype = const InternalEvidenceAdapterPrototype().evaluate(
      InternalEvidenceAdapterPrototypeRequest(
        designResult: _cachedDesign,
        summaryResult: _cachedSummary,
        readinessResult: _cachedReadiness,
      ),
    );
    _cachedReview = const InternalEvidenceAdapterPrototypeReview().evaluate(
      InternalEvidenceAdapterPrototypeReviewRequest(
        prototypeResult: _cachedPrototype,
        designResult: _cachedDesign,
        summaryResult: _cachedSummary,
        readinessResult: _cachedReadiness,
      ),
    );
    _cachedValidation = const InternalEvidenceAdapterPrototypeValidation()
        .evaluate(
          InternalEvidenceAdapterPrototypeValidationRequest(
            reviewResult: _cachedReview,
            prototypeResult: _cachedPrototype,
            designResult: _cachedDesign,
            summaryResult: _cachedSummary,
            readinessResult: _cachedReadiness,
          ),
        );
  });

  group('InternalEvidenceAdapterPrototypeValidation safe demo', () {
    test('consumes safe Phase 32O review and upstream contracts', () {
      final result = const InternalEvidenceAdapterPrototypeValidation()
          .evaluate(
            InternalEvidenceAdapterPrototypeValidationRequest(
              reviewResult: _review(),
              prototypeResult: _prototype(),
              designResult: _design(),
              summaryResult: _summary(),
              readinessResult: _readiness(),
            ),
          );

      expect(
        result.sourceReviewStatus,
        InternalEvidenceAdapterPrototypeReviewStatus.reviewedWithWarnings,
      );
      expect(
        result.sourcePrototypeStatus,
        InternalEvidenceAdapterPrototypeStatus.completedWithWarnings,
      );
      expect(
        result.sourceDesignStatus,
        InternalEvidenceAdapterDesignStatus.designReadyWithWarnings,
      );
      expect(
        result.sourceSummaryStatus,
        InternalEvidenceSummaryLayerStatus.summarizedWithWarnings,
      );
      expect(result.validationFindings, isEmpty);
      expect(result.safeForPhase32Q, isTrue);
    });

    test('default status is validated with warning honesty', () {
      final result = _validation();

      expect(
        result.validationStatus,
        isIn(<InternalEvidenceAdapterPrototypeValidationStatus>[
          InternalEvidenceAdapterPrototypeValidationStatus
              .validatedWithWarnings,
          InternalEvidenceAdapterPrototypeValidationStatus.validatedClean,
        ]),
      );
      expect(
        result.validationStatus,
        InternalEvidenceAdapterPrototypeValidationStatus.validatedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32Q, isTrue);
    });

    test('unsafe review blocks validation', () {
      final unsafeReview = _review().copyWith(
        reviewStatus: InternalEvidenceAdapterPrototypeReviewStatus
            .blockedByUnsafePrototype,
        unsafeCount: 1,
        safeForPhase32P: false,
      );
      final result = _validationFromReview(unsafeReview);

      expect(
        result.validationStatus,
        InternalEvidenceAdapterPrototypeValidationStatus.blockedByUnsafeReview,
      );
      expect(result.safeForPhase32Q, isFalse);
      expect(
        result.phase32QRecommendation,
        InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
            .blockedByUnsafeAdapterValidation,
      );
    });

    test('aggregate counts and checks are deterministic', () {
      final first = _validation();
      final second = const InternalEvidenceAdapterPrototypeValidation()
          .evaluate();

      expect(first.totalChecks, 13);
      expect(first.warningCheckCount, greaterThanOrEqualTo(1));
      expect(first.blockerCount, 0);
      expect(first.criticalCount, 0);
      expect(first.totalPacketRows, 7);
      expect(first.validCorePacketCount, 2);
      expect(first.validContextOnlyPacketCount, 3);
      expect(first.validBlockedPacketCount, 1);
      expect(first.validFutureOnlyPacketCount, 1);
      expect(first.invalidPacketCount, 0);
      expect(first.unsafePacketCount, 0);
      expect(first.toJson(), second.toJson());
      expect(
        first.checks.map((check) => check.checkId),
        orderedEquals(<String>[
          'activeOutputFieldsAreInternalOnly',
          'androidProofIdsAreCapturedOnly',
          'blockedFuturePacketsStayInactive',
          'blockedOutputFieldsRemainBlocked',
          'contextOnlyPacketsStayContextOnly',
          'corePacketsUseOnlyCoreSources',
          'noLabelsScoresRankingsMetrics',
          'noUiBackendPersistenceEngineFlags',
          'ownerProofQueueRemainsEmpty',
          'phase32ECasesAreNotCapturedProof',
          'productBoundariesRemainBlocked',
          'prototypeConsumesApprovedDesign',
          'quietScopeRemainsExcluded',
        ]),
      );
    });

    test('Phase 32Q recommendation and proof IDs are deterministic', () {
      final result = _validation();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32QRecommendation,
        InternalEvidenceAdapterPrototypeValidationPhase32QRecommendation
            .proceedToAdapterPrototypeReadinessGate,
      );
      expect(result.safeForPhase32Q, isTrue);
    });
  });

  group('Packet validation behavior', () {
    test('core packets from allowed and improved summaries validate', () {
      final allowed = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );
      final improved = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.improvedSupportSummary,
      );

      expect(
        allowed.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus.validCorePacket,
      );
      expect(
        improved.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus.validCorePacket,
      );
      for (final row in <InternalEvidenceAdapterPrototypeValidationRow>[
        allowed,
        improved,
      ]) {
        expect(row.adapterRole.isCore, isTrue);
        expect(row.supportCaseIds, isNotEmpty);
        expect(row.allowedEvidenceRecordIds, isNotEmpty);
        expect(row.contractSatisfied, isTrue);
        expect(row.safetySatisfied, isTrue);
        expect(row.safeForNextGate, isTrue);
      }
    });

    test('context-only packets validate as context-only rows', () {
      final watch = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      );
      final proof = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.proofLimitedSummary,
      );
      final warning = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.warningLimitedSummary,
      );

      expect(
        watch.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus
            .validContextOnlyPacket,
      );
      expect(
        proof.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus
            .validContextOnlyPacket,
      );
      expect(
        warning.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus
            .validContextOnlyPacket,
      );
      expect(
        _validation().check('contextOnlyPacketsStayContextOnly').checkStatus,
        InternalEvidenceAdapterPrototypeValidationCheckStatus
            .passedWithWarnings,
      );
    });

    test('blocked and future-only packets validate as inactive rows', () {
      final blocked = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );
      final future = _validation().rowForGroup(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(
        blocked.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus
            .validBlockedPacket,
      );
      expect(
        future.validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus
            .validFutureOnlyPacket,
      );
      for (final row in <InternalEvidenceAdapterPrototypeValidationRow>[
        blocked,
        future,
      ]) {
        expect(row.activeOutputFieldIds, isEmpty);
        expect(row.allowedEvidenceRecordIds, isEmpty);
        expect(row.safeForNextGate, isTrue);
      }
    });

    test('core packet from non-core source fails', () {
      final result = _validationFromReview(
        _withReviewRow(
          'review-packet-allowedEvidenceSummary',
          (row) => row.copyWith(
            sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[
              InternalEvidenceSummaryGroupId.warningLimitedSummary,
            ],
          ),
        ),
      );

      expect(
        result.rowForPacket('packet-allowedEvidenceSummary').validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus.invalidPacket,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('corePacketFromNonCoreSource'),
      );
    });

    test('context-only packet cannot become core', () {
      final result = _validationFromReview(
        _withReviewRow(
          'review-packet-constrainedWatchListSummary',
          (row) => row.copyWith(
            adapterRole: InternalEvidenceAdapterPacketRole.coreEvidencePacket,
          ),
        ),
      );

      expect(
        result
            .rowForPacket('packet-constrainedWatchListSummary')
            .validationStatus,
        InternalEvidenceAdapterPrototypePacketValidationStatus.invalidPacket,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('contextOnlyPacketPromotedToCore'),
      );
    });

    test('blocked and future-only packets cannot become active', () {
      final blocked = _validationFromReview(
        _withReviewRow(
          'review-packet-blockedBoundarySummary',
          (row) => row.copyWith(
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        ),
      );
      final future = _validationFromReview(
        _withReviewRow(
          'review-packet-futureOnlySummary',
          (row) => row.copyWith(
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        ),
      );

      expect(
        blocked.validationFindings.map((finding) => finding.id),
        contains('blockedPacketMadeActive'),
      );
      expect(
        future.validationFindings.map((finding) => finding.id),
        contains('futureOnlyPacketMadeActive'),
      );
    });
  });

  group('Output field and proof validation behavior', () {
    test('active output fields are internal evidence-safe only', () {
      expect(
        _validation().activeOutputFieldIds,
        containsAll(<String>[
          'adapterPacketId',
          'sourceSummaryGroupIds',
          'allowedEvidenceRecordIds',
          'supportCaseIds',
          'newlyAddedSupportCaseIds',
          'evidenceAreaIds',
          'bucketIds',
          'qualitativeConfidence',
          'internalWarnings',
          'internalConstraints',
          'futurePrerequisites',
        ]),
      );
      for (final fieldId in _validation().blockedOutputFieldIds) {
        expect(_validation().activeOutputFieldIds, isNot(contains(fieldId)));
      }
    });

    test('blocked output fields remain blocked', () {
      expect(
        _validation().blockedOutputFieldIds,
        containsAll(<String>[
          'productLabel',
          'finalMoveLabel',
          'brilliantGreatMissStyleLabels',
          'bestGoodInaccuracyMistakeBlunderStyleLabels',
          'numericMoveScore',
          'officialAccuracy',
          'acpl',
          'cpLoss',
          'winProbability',
          'moveRanking',
          'uiOutputFields',
          'backendPersistenceFields',
          'directEngineCallFields',
        ]),
      );
      expect(
        _validation().check('blockedOutputFieldsRemainBlocked').checkStatus,
        InternalEvidenceAdapterPrototypeValidationCheckStatus.passed,
      );
    });

    test('Android proof IDs and owner proof status remain honest', () {
      expect(
        _validation().androidProofCaseIds,
        orderedEquals(_provenAndroidIds),
      );
      expect(_validation().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_validation().androidProofCaseIds, isNot(contains(caseId)));
        for (final row in _validation().packetRows) {
          expect(row.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('validated packets do not emit product or scoring families', () {
      for (final row in _validation().packetRows) {
        expect(row.isProductOutput, isFalse);
        expect(row.isClassifierLabel, isFalse);
        expect(row.hasNumericScore, isFalse);
        expect(row.ranksMoves, isFalse);
        expect(row.isOfficialMetric, isFalse);
        expect(row.cpLossOutputActive, isFalse);
        expect(row.winProbabilityOutputActive, isFalse);
        expect(row.callsEngine, isFalse);
        expect(row.writesPersistence, isFalse);
        expect(row.targetsUi, isFalse);
      }
    });
  });

  group('InternalEvidenceAdapterPrototypeValidationValidator', () {
    test('rejects unsafe review marked validated', () {
      final unsafeValidated = _validation().copyWith(
        sourceReviewStatus: InternalEvidenceAdapterPrototypeReviewStatus
            .blockedByUnsafePrototype,
        unsafePacketCount: 1,
        unsafeCount: 1,
        safeForPhase32Q: true,
      );

      expect(
        _validator().validate(unsafeValidated).map((finding) => finding.id),
        contains('unsafeReviewMarkedValidated'),
      );
    });

    test('rejects unproven Android proof and Phase 32E proof claims', () {
      final unproven = _validation().copyWith(
        androidProofCaseIds: <String>[
          ..._validation().androidProofCaseIds,
          'unproven-android-proof',
        ],
      );
      final phase32E = _withValidationRow(
        'validation-packet-proofLimitedSummary',
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
    });

    test('rejects active labels, scores, rankings, and metrics', () {
      final validator = _validator();

      expect(
        validator
            .validate(_withActiveField('productLabel'))
            .map((finding) => finding.id),
        contains('productOutputActive'),
      );
      expect(
        validator
            .validate(_withActiveField('finalMoveLabel'))
            .map((finding) => finding.id),
        contains('classifierLabelOutputActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag(
                (row) => row.copyWith(hasNumericScore: true),
              ),
            )
            .map((finding) => finding.id),
        contains('numericScoreOutputActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag((row) => row.copyWith(ranksMoves: true)),
            )
            .map((finding) => finding.id),
        contains('moveRankingOutputActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag(
                (row) => row.copyWith(isOfficialMetric: true),
              ),
            )
            .map((finding) => finding.id),
        contains('officialMetricOutputActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag(
                (row) => row.copyWith(cpLossOutputActive: true),
              ),
            )
            .map((finding) => finding.id),
        contains('futureMetricOutputActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag(
                (row) => row.copyWith(winProbabilityOutputActive: true),
              ),
            )
            .map((finding) => finding.id),
        contains('futureMetricOutputActive'),
      );
    });

    test('rejects quiet activation and integration flags', () {
      final validator = _validator();

      expect(
        validator
            .validate(
              _withValidationRowFlag(
                (row) => row.copyWith(quietPreparatoryScopeActive: true),
              ),
            )
            .map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag((row) => row.copyWith(callsEngine: true)),
            )
            .map((finding) => finding.id),
        contains('engineCallFlagActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag(
                (row) => row.copyWith(writesPersistence: true),
              ),
            )
            .map((finding) => finding.id),
        contains('persistenceWriteFlagActive'),
      );
      expect(
        validator
            .validate(
              _withValidationRowFlag((row) => row.copyWith(targetsUi: true)),
            )
            .map((finding) => finding.id),
        contains('uiTargetFlagActive'),
      );
    });

    test('rejects owner proof without explicit PV reason', () {
      final ownerProof = _validation().copyWith(
        ownerProofQueueCount: 1,
        warnings: const <String>[],
        failures: const <String>[],
        packetRows: _validation().packetRows
            .map((row) => row.copyWith(violationReasons: const <String>[]))
            .toList(),
      );

      expect(
        _validator().validate(ownerProof).map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();

      expect(
        validator.validateReportText(_validation().renderMarkdownReport()),
        isEmpty,
      );
      expect(
        validator
            .validateReportText('uciok\ninfo depth 1\nbestmove e2e4')
            .map((finding) => finding.id),
        contains('rawUciReportText'),
      );
      expect(
        validator
            .validateReportText('active fields: finalMoveLabel')
            .map((finding) => finding.id),
        contains('activeBlockedFieldReportText'),
      );
    });
  });

  group('Validation report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _validation().renderMarkdownReport();

      expect(
        report,
        contains('# Internal Evidence Adapter Prototype Validation'),
      );
      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Packet Validation Table'));
      expect(report, contains('## Core Packet Validation Rows'));
      expect(report, contains('## Context-Only Validation Rows'));
      expect(report, contains('## Blocked Output Field Summary'));
      expect(report, contains('## Phase 32Q Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _validation().renderJsonReport();
      final second = _validation().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalEvidenceAdapterPrototypeValidationReportVersion,
      );
      expect(decoded['validationStatus'], 'validatedWithWarnings');
      expect(decoded['checks'], isA<List<Object?>>());
      expect(decoded['packetRows'], isA<List<Object?>>());
      expect(decoded['safeForPhase32Q'], isTrue);
    });

    test('reports contain no raw engine or active product-output text', () {
      final report = _validation().renderMarkdownReport();

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        ' pv ',
        'pvMoves',
        'active productLabel',
        'active finalMoveLabel',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL',
        'official accuracy',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('source does not import engine, UI, backend, or persistence seams', () {
      final source = File(
        'lib/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart',
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

InternalEvidenceAdapterPrototypeValidationResult _validation() {
  return _cachedValidation!;
}

InternalEvidenceAdapterPrototypeReviewResult _review() => _cachedReview!;

InternalEvidenceAdapterPrototypeResult _prototype() => _cachedPrototype!;

InternalEvidenceAdapterDesignResult _design() => _cachedDesign!;

InternalEvidenceSummaryLayerResult _summary() => _cachedSummary!;

RefreshedPacketEvidenceReadinessGateResult _readiness() => _cachedReadiness!;

InternalEvidenceAdapterPrototypeValidationValidator _validator() {
  return const InternalEvidenceAdapterPrototypeValidationValidator();
}

InternalEvidenceAdapterPrototypeValidationResult _validationFromReview(
  InternalEvidenceAdapterPrototypeReviewResult review,
) {
  return const InternalEvidenceAdapterPrototypeValidation().evaluate(
    InternalEvidenceAdapterPrototypeValidationRequest(
      reviewResult: review,
      prototypeResult: _cachedPrototype,
      designResult: _cachedDesign,
      summaryResult: _cachedSummary,
      readinessResult: _cachedReadiness,
    ),
  );
}

InternalEvidenceAdapterPrototypeReviewResult _withReviewRow(
  String reviewRowId,
  InternalEvidenceAdapterPrototypeReviewRow Function(
    InternalEvidenceAdapterPrototypeReviewRow row,
  )
  update,
) {
  final rows = _review().rows.map((row) {
    if (row.reviewRowId == reviewRowId) return update(row);
    return row;
  }).toList();
  return _review().copyWith(rows: rows);
}

InternalEvidenceAdapterPrototypeValidationResult _withValidationRow(
  String validationRowId,
  InternalEvidenceAdapterPrototypeValidationRow Function(
    InternalEvidenceAdapterPrototypeValidationRow row,
  )
  update,
) {
  final rows = _validation().packetRows.map((row) {
    if (row.validationRowId == validationRowId) return update(row);
    return row;
  }).toList();
  return _validation().copyWith(packetRows: rows);
}

InternalEvidenceAdapterPrototypeValidationResult _withValidationRowFlag(
  InternalEvidenceAdapterPrototypeValidationRow Function(
    InternalEvidenceAdapterPrototypeValidationRow row,
  )
  update,
) {
  return _withValidationRow('validation-packet-allowedEvidenceSummary', update);
}

InternalEvidenceAdapterPrototypeValidationResult _withActiveField(
  String fieldId,
) {
  return _withValidationRow(
    'validation-packet-allowedEvidenceSummary',
    (row) => row.copyWith(
      activeOutputFieldIds: <String>[...row.activeOutputFieldIds, fieldId],
    ),
  );
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
