@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:flutter_test/flutter_test.dart';

InternalAdapterReadinessSummaryResult? _cachedSummaryResult;
InternalEvidenceAdapterPrototypeReadinessGateResult? _cachedGate;
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
    _cachedGate = const InternalEvidenceAdapterPrototypeReadinessGate()
        .evaluate(
          InternalEvidenceAdapterPrototypeReadinessGateRequest(
            validationResult: _cachedValidation,
            reviewResult: _cachedReview,
            prototypeResult: _cachedPrototype,
            designResult: _cachedDesign,
            summaryResult: _cachedSummary,
            readinessResult: _cachedReadiness,
          ),
        );
    _cachedSummaryResult = const InternalAdapterReadinessSummary().evaluate(
      InternalAdapterReadinessSummaryRequest(
        readinessGateResult: _cachedGate,
        validationResult: _cachedValidation,
        reviewResult: _cachedReview,
        prototypeResult: _cachedPrototype,
        designResult: _cachedDesign,
        summaryResult: _cachedSummary,
        readinessResult: _cachedReadiness,
      ),
    );
  });

  group('InternalAdapterReadinessSummary safe demo', () {
    test('consumes safe Phase 32Q readiness gate and upstream contracts', () {
      final result = const InternalAdapterReadinessSummary().evaluate(
        InternalAdapterReadinessSummaryRequest(
          readinessGateResult: _gate(),
          validationResult: _validation(),
          reviewResult: _review(),
          prototypeResult: _prototype(),
          designResult: _design(),
          summaryResult: _summary(),
          readinessResult: _readiness(),
        ),
      );

      expect(
        result.sourceReadinessGateStatus,
        InternalEvidenceAdapterPrototypeReadinessGateStatus.readyWithWarnings,
      );
      expect(
        result.sourceValidationStatus,
        InternalEvidenceAdapterPrototypeValidationStatus.validatedWithWarnings,
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
      expect(result.validationFindings, isEmpty);
      expect(result.safeForPhase32S, isTrue);
    });

    test('default status is summarized with warning honesty', () {
      final result = _readinessSummary();

      expect(
        result.summaryStatus,
        isIn(<InternalAdapterReadinessSummaryStatus>[
          InternalAdapterReadinessSummaryStatus.summarizedWithWarnings,
          InternalAdapterReadinessSummaryStatus.summarizedClean,
        ]),
      );
      expect(
        result.summaryStatus,
        InternalAdapterReadinessSummaryStatus.summarizedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32S, isTrue);
    });

    test('unsafe readiness blocks summary', () {
      final unsafeGate = _gate().copyWith(
        readinessStatus: InternalEvidenceAdapterPrototypeReadinessGateStatus
            .blockedByValidationFailure,
        unsafeCount: 1,
        safeForPhase32R: false,
      );
      final result = _summaryFromGate(unsafeGate);

      expect(
        result.summaryStatus,
        InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness,
      );
      expect(result.safeForPhase32S, isFalse);
      expect(
        result.phase32SRecommendation,
        InternalAdapterReadinessSummaryPhase32SRecommendation
            .blockedByUnsafeAdapterSummary,
      );
    });

    test('aggregate counts and summary groups are deterministic', () {
      final first = _readinessSummary();
      final second = const InternalAdapterReadinessSummary().evaluate();

      expect(first.totalGroups, 8);
      expect(first.totalRecords, 7);
      expect(first.allowedCorePacketCount, 2);
      expect(first.constrainedContextPacketCount, 3);
      expect(first.inactiveBlockedPacketCount, 1);
      expect(first.inactiveFutureOnlyPacketCount, 1);
      expect(first.allowedActiveOutputFieldCount, 15);
      expect(first.blockedOutputFieldCount, 13);
      expect(first.unsafeCount, 0);
      expect(first.blockerCount, 0);
      expect(first.criticalCount, 0);
      expect(first.toJson(), second.toJson());
      expect(
        first.groups.map((group) => group.groupId),
        orderedEquals(<InternalAdapterReadinessSummaryGroupId>[
          InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
          InternalAdapterReadinessSummaryGroupId
              .constrainedContextPacketSummary,
          InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
          InternalAdapterReadinessSummaryGroupId
              .inactiveFutureOnlyPacketSummary,
          InternalAdapterReadinessSummaryGroupId
              .allowedActiveOutputFieldSummary,
          InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
          InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
          InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
        ]),
      );
    });

    test('Phase 32S recommendation and proof IDs are deterministic', () {
      final result = _readinessSummary();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32SRecommendation,
        InternalAdapterReadinessSummaryPhase32SRecommendation
            .proceedToAdapterReadinessSummaryValidation,
      );
      expect(result.safeForPhase32S, isTrue);
    });
  });

  group('Summary group behavior', () {
    test(
      'allowed core packet summary includes exactly allowed core packets',
      () {
        final group = _readinessSummary().summaryGroup(
          InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
        );
        final allowed = _readinessSummary().recordForGroup(
          InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
        );
        final improved = _readinessSummary().recordForGroup(
          InternalEvidenceSummaryGroupId.improvedSupportSummary,
        );

        expect(group.packetIds, hasLength(2));
        expect(group.packetIds, contains('packet-allowedEvidenceSummary'));
        expect(group.packetIds, contains('packet-improvedSupportSummary'));
        for (final record in <InternalAdapterReadinessSummaryRecord>[
          allowed,
          improved,
        ]) {
          expect(
            record.summaryStatus,
            InternalAdapterReadinessSummaryItemStatus.allowedCorePacketSummary,
          );
          expect(record.allowedForNextInternalStep, isTrue);
          expect(record.supportCaseIds, isNotEmpty);
        }
      },
    );

    test(
      'constrained context packet summary includes context-only packets',
      () {
        final group = _readinessSummary().summaryGroup(
          InternalAdapterReadinessSummaryGroupId
              .constrainedContextPacketSummary,
        );
        final watch = _readinessSummary().recordForGroup(
          InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
        );
        final proof = _readinessSummary().recordForGroup(
          InternalEvidenceSummaryGroupId.proofLimitedSummary,
        );
        final warning = _readinessSummary().recordForGroup(
          InternalEvidenceSummaryGroupId.warningLimitedSummary,
        );

        expect(group.packetIds, hasLength(3));
        for (final record in <InternalAdapterReadinessSummaryRecord>[
          watch,
          proof,
          warning,
        ]) {
          expect(
            record.summaryStatus,
            InternalAdapterReadinessSummaryItemStatus
                .constrainedContextPacketSummary,
          );
          expect(record.allowedForNextInternalStep, isFalse);
          expect(record.constrainedForContextOnly, isTrue);
          expect(record.warningReason, isNotEmpty);
        }
      },
    );

    test('inactive blocked and future-only packet summaries stay inactive', () {
      final blocked = _readinessSummary().recordForGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );
      final future = _readinessSummary().recordForGroup(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(
        blocked.summaryStatus,
        InternalAdapterReadinessSummaryItemStatus.inactiveBlockedPacketSummary,
      );
      expect(
        future.summaryStatus,
        InternalAdapterReadinessSummaryItemStatus
            .inactiveFutureOnlyPacketSummary,
      );
      for (final record in <InternalAdapterReadinessSummaryRecord>[
        blocked,
        future,
      ]) {
        expect(record.allowedForNextInternalStep, isFalse);
        expect(record.constrainedForContextOnly, isFalse);
        expect(record.inactiveBoundary, isTrue);
        expect(record.activeOutputFieldIds, isEmpty);
      }
    });

    test('core packet from non-core source fails summary', () {
      final result = _summaryFromGate(
        _withReadinessRecord(
          'readiness-packet-allowedEvidenceSummary',
          (record) => record.copyWith(
            sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[
              InternalEvidenceSummaryGroupId.warningLimitedSummary,
            ],
          ),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('corePacketFromNonCoreSource'),
      );
      expect(result.safeForPhase32S, isFalse);
    });

    test('context-only packet cannot become allowed core summary', () {
      final result = _withSummaryRecord(
        'summary-packet-constrainedWatchListSummary',
        (record) => record.copyWith(allowedForNextInternalStep: true),
      );

      expect(
        _validator().validate(result).map((finding) => finding.id),
        contains('contextOnlyPacketPromotedToAllowedCore'),
      );
    });

    test('blocked and future-only packets cannot become active', () {
      final blocked = _summaryFromGate(
        _withReadinessRecord(
          'readiness-packet-blockedBoundarySummary',
          (record) => record.copyWith(
            inactiveBoundary: false,
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        ),
      );
      final future = _summaryFromGate(
        _withReadinessRecord(
          'readiness-packet-futureOnlySummary',
          (record) => record.copyWith(
            inactiveBoundary: false,
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

  group('Output field and proof summary behavior', () {
    test('active output field summary includes safe fields only', () {
      expect(
        _readinessSummary().activeOutputFieldIds,
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
          'androidProofCaseIds',
          'proofLimitReason',
          'watchListReason',
          'warningLimitedReason',
        ]),
      );
      for (final fieldId in _readinessSummary().blockedOutputFieldIds) {
        expect(
          _readinessSummary().activeOutputFieldIds,
          isNot(contains(fieldId)),
        );
      }
    });

    test('blocked output field summary includes denied fields', () {
      expect(
        _readinessSummary().blockedOutputFieldIds,
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
        _readinessSummary()
            .summaryGroup(
              InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
            )
            .safeForNextInternalStep,
        isTrue,
      );
    });

    test('Android proof boundary and owner proof summaries remain honest', () {
      expect(
        _readinessSummary().androidProofCaseIds,
        orderedEquals(_provenAndroidIds),
      );
      expect(
        _readinessSummary()
            .summaryGroup(
              InternalAdapterReadinessSummaryGroupId
                  .androidProofBoundarySummary,
            )
            .androidProofCaseIds,
        orderedEquals(_provenAndroidIds),
      );
      expect(_readinessSummary().ownerProofQueueCount, 0);
      expect(
        _readinessSummary()
            .summaryGroup(
              InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
            )
            .safeForNextInternalStep,
        isTrue,
      );

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(
          _readinessSummary().androidProofCaseIds,
          isNot(contains(caseId)),
        );
        for (final record in _readinessSummary().records) {
          expect(record.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('summary packets do not emit product or scoring families', () {
      for (final record in _readinessSummary().records) {
        expect(record.isProductOutput, isFalse);
        expect(record.isClassifierLabel, isFalse);
        expect(record.hasNumericScore, isFalse);
        expect(record.ranksMoves, isFalse);
        expect(record.isOfficialMetric, isFalse);
        expect(record.cpLossOutputActive, isFalse);
        expect(record.winProbabilityOutputActive, isFalse);
        expect(record.callsEngine, isFalse);
        expect(record.writesPersistence, isFalse);
        expect(record.targetsUi, isFalse);
      }
    });
  });

  group('InternalAdapterReadinessSummaryValidator', () {
    test('rejects unsafe readiness marked summarized', () {
      final unsafeSummary = _readinessSummary().copyWith(
        sourceReadinessGateStatus:
            InternalEvidenceAdapterPrototypeReadinessGateStatus
                .blockedByValidationFailure,
        unsafeCount: 1,
        safeForPhase32S: true,
      );

      expect(
        _validator().validate(unsafeSummary).map((finding) => finding.id),
        contains('unsafeReadinessMarkedSummarized'),
      );
    });

    test('rejects unproven Android proof and Phase 32E proof claims', () {
      final unproven = _readinessSummary().copyWith(
        androidProofCaseIds: <String>[
          ..._readinessSummary().androidProofCaseIds,
          'unproven-android-proof',
        ],
      );
      final phase32E = _withSummaryRecord(
        'summary-packet-proofLimitedSummary',
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
              _withRecordFlag(
                (record) => record.copyWith(hasNumericScore: true),
              ),
            )
            .map((finding) => finding.id),
        contains('numericScoreOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag((record) => record.copyWith(ranksMoves: true)),
            )
            .map((finding) => finding.id),
        contains('moveRankingOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag(
                (record) => record.copyWith(isOfficialMetric: true),
              ),
            )
            .map((finding) => finding.id),
        contains('officialMetricOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag(
                (record) => record.copyWith(cpLossOutputActive: true),
              ),
            )
            .map((finding) => finding.id),
        contains('futureMetricOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag(
                (record) => record.copyWith(winProbabilityOutputActive: true),
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
              _withRecordFlag(
                (record) => record.copyWith(quietPreparatoryScopeActive: true),
              ),
            )
            .map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag((record) => record.copyWith(callsEngine: true)),
            )
            .map((finding) => finding.id),
        contains('engineCallFlagActive'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag(
                (record) => record.copyWith(writesPersistence: true),
              ),
            )
            .map((finding) => finding.id),
        contains('persistenceWriteFlagActive'),
      );
      expect(
        validator
            .validate(
              _withRecordFlag((record) => record.copyWith(targetsUi: true)),
            )
            .map((finding) => finding.id),
        contains('uiTargetFlagActive'),
      );
    });

    test('rejects owner proof without explicit PV reason', () {
      final ownerProof = _readinessSummary().copyWith(
        ownerProofQueueCount: 1,
        warnings: const <String>[],
        failures: const <String>[],
        records: _readinessSummary().records
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
        _validator().validate(ownerProof).map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();

      expect(
        validator.validateReportText(
          _readinessSummary().renderMarkdownReport(),
        ),
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
            .validateReportText('info depth 1 pv e2e4 e7e5')
            .map((finding) => finding.id),
        contains('rawPvReportText'),
      );
      expect(
        validator
            .validateReportText('active fields: finalMoveLabel')
            .map((finding) => finding.id),
        contains('activeBlockedFieldReportText'),
      );
    });
  });

  group('Summary report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _readinessSummary().renderMarkdownReport();

      expect(report, contains('# Internal Adapter Readiness Summary'));
      expect(report, contains('## Summary Group Table'));
      expect(report, contains('## Summary Record Table'));
      expect(report, contains('## Allowed Core Packet Summary'));
      expect(report, contains('## Constrained Context Packet Summary'));
      expect(report, contains('## Blocked Output Field Summary'));
      expect(report, contains('## Owner Proof Status'));
      expect(report, contains('## Phase 32S Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _readinessSummary().renderJsonReport();
      final second = _readinessSummary().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalAdapterReadinessSummaryReportVersion);
      expect(decoded['summaryStatus'], 'summarizedWithWarnings');
      expect(decoded['groups'], isA<List<Object?>>());
      expect(decoded['records'], isA<List<Object?>>());
      expect(decoded['safeForPhase32S'], isTrue);
    });

    test('reports contain no raw engine or active product-output text', () {
      final report = _readinessSummary().renderMarkdownReport();

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
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
        'lib/features/pgn_review/application/internal_adapter_readiness_summary.dart',
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

InternalAdapterReadinessSummaryResult _readinessSummary() {
  return _cachedSummaryResult!;
}

InternalEvidenceAdapterPrototypeReadinessGateResult _gate() => _cachedGate!;

InternalEvidenceAdapterPrototypeValidationResult _validation() {
  return _cachedValidation!;
}

InternalEvidenceAdapterPrototypeReviewResult _review() => _cachedReview!;

InternalEvidenceAdapterPrototypeResult _prototype() => _cachedPrototype!;

InternalEvidenceAdapterDesignResult _design() => _cachedDesign!;

InternalEvidenceSummaryLayerResult _summary() => _cachedSummary!;

RefreshedPacketEvidenceReadinessGateResult _readiness() => _cachedReadiness!;

InternalAdapterReadinessSummaryValidator _validator() {
  return const InternalAdapterReadinessSummaryValidator();
}

InternalAdapterReadinessSummaryResult _summaryFromGate(
  InternalEvidenceAdapterPrototypeReadinessGateResult gate,
) {
  return const InternalAdapterReadinessSummary().evaluate(
    InternalAdapterReadinessSummaryRequest(
      readinessGateResult: gate,
      validationResult: _cachedValidation,
      reviewResult: _cachedReview,
      prototypeResult: _cachedPrototype,
      designResult: _cachedDesign,
      summaryResult: _cachedSummary,
      readinessResult: _cachedReadiness,
    ),
  );
}

InternalEvidenceAdapterPrototypeReadinessGateResult _withReadinessRecord(
  String readinessRecordId,
  InternalEvidenceAdapterPrototypeReadinessRecord Function(
    InternalEvidenceAdapterPrototypeReadinessRecord record,
  )
  update,
) {
  final records = _gate().records.map((record) {
    if (record.readinessRecordId == readinessRecordId) return update(record);
    return record;
  }).toList();
  return _gate().copyWith(records: records);
}

InternalAdapterReadinessSummaryResult _withSummaryRecord(
  String summaryRecordId,
  InternalAdapterReadinessSummaryRecord Function(
    InternalAdapterReadinessSummaryRecord record,
  )
  update,
) {
  final records = _readinessSummary().records.map((record) {
    if (record.summaryRecordId == summaryRecordId) return update(record);
    return record;
  }).toList();
  return _readinessSummary().copyWith(records: records);
}

InternalAdapterReadinessSummaryResult _withRecordFlag(
  InternalAdapterReadinessSummaryRecord Function(
    InternalAdapterReadinessSummaryRecord record,
  )
  update,
) {
  return _withSummaryRecord('summary-packet-allowedEvidenceSummary', update);
}

InternalAdapterReadinessSummaryResult _withActiveField(String fieldId) {
  return _withSummaryRecord(
    'summary-packet-allowedEvidenceSummary',
    (record) => record.copyWith(
      activeOutputFieldIds: <String>[...record.activeOutputFieldIds, fieldId],
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
