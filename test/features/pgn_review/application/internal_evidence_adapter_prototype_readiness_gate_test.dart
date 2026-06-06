@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_validation.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });

  group('InternalEvidenceAdapterPrototypeReadinessGate safe demo', () {
    test('consumes safe Phase 32P validation and upstream contracts', () {
      final result = const InternalEvidenceAdapterPrototypeReadinessGate()
          .evaluate(
            InternalEvidenceAdapterPrototypeReadinessGateRequest(
              validationResult: _validation(),
              reviewResult: _review(),
              prototypeResult: _prototype(),
              designResult: _design(),
              summaryResult: _summary(),
              readinessResult: _readiness(),
            ),
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
      expect(
        result.sourceSummaryStatus,
        InternalEvidenceSummaryLayerStatus.summarizedWithWarnings,
      );
      expect(result.validationFindings, isEmpty);
      expect(result.safeForPhase32R, isTrue);
    });

    test('default status is ready with warning honesty', () {
      final result = _gate();

      expect(
        result.readinessStatus,
        isIn(<InternalEvidenceAdapterPrototypeReadinessGateStatus>[
          InternalEvidenceAdapterPrototypeReadinessGateStatus.readyWithWarnings,
          InternalEvidenceAdapterPrototypeReadinessGateStatus.readyClean,
        ]),
      );
      expect(
        result.readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessGateStatus.readyWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32R, isTrue);
    });

    test('unsafe validation blocks readiness', () {
      final unsafeValidation = _validation().copyWith(
        validationStatus: InternalEvidenceAdapterPrototypeValidationStatus
            .blockedByUnsafeReview,
        unsafeCount: 1,
        unsafePacketCount: 1,
        safeForPhase32Q: false,
      );
      final result = _gateFromValidation(unsafeValidation);

      expect(
        result.readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessGateStatus
            .blockedByValidationFailure,
      );
      expect(result.safeForPhase32R, isFalse);
      expect(
        result.phase32RRecommendation,
        InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
            .blockedByUnsafeAdapterReadiness,
      );
    });

    test('aggregate counts and groups are deterministic', () {
      final first = _gate();
      final second = const InternalEvidenceAdapterPrototypeReadinessGate()
          .evaluate();

      expect(first.totalRecords, 7);
      expect(first.allowedCorePacketCount, 2);
      expect(first.constrainedContextPacketCount, 3);
      expect(first.inactiveBlockedPacketCount, 1);
      expect(first.inactiveFutureOnlyPacketCount, 1);
      expect(first.unsafeCount, 0);
      expect(first.blockerCount, 0);
      expect(first.criticalCount, 0);
      expect(first.groups.length, 6);
      expect(first.toJson(), second.toJson());
      expect(
        first.groups.map((group) => group.groupId),
        orderedEquals(<InternalEvidenceAdapterPrototypeReadinessGroupId>[
          InternalEvidenceAdapterPrototypeReadinessGroupId
              .allowedCoreAdapterPackets,
          InternalEvidenceAdapterPrototypeReadinessGroupId
              .constrainedContextAdapterPackets,
          InternalEvidenceAdapterPrototypeReadinessGroupId
              .inactiveBlockedAdapterPackets,
          InternalEvidenceAdapterPrototypeReadinessGroupId
              .inactiveFutureOnlyAdapterPackets,
          InternalEvidenceAdapterPrototypeReadinessGroupId
              .allowedActiveOutputFields,
          InternalEvidenceAdapterPrototypeReadinessGroupId.blockedOutputFields,
        ]),
      );
    });

    test('Phase 32R recommendation and proof IDs are deterministic', () {
      final result = _gate();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32RRecommendation,
        InternalEvidenceAdapterPrototypeReadinessPhase32RRecommendation
            .proceedToInternalAdapterReadinessSummary,
      );
      expect(result.safeForPhase32R, isTrue);
    });
  });

  group('Readiness group behavior', () {
    test('valid core packets become allowed core readiness', () {
      final allowed = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );
      final improved = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.improvedSupportSummary,
      );
      final coreGroup = _gate().readinessGroup(
        InternalEvidenceAdapterPrototypeReadinessGroupId
            .allowedCoreAdapterPackets,
      );

      expect(
        allowed.readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessItemStatus.allowedCorePacket,
      );
      expect(
        improved.readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessItemStatus.allowedCorePacket,
      );
      for (final record in <InternalEvidenceAdapterPrototypeReadinessRecord>[
        allowed,
        improved,
      ]) {
        expect(record.allowedForNextInternalLayer, isTrue);
        expect(record.constrainedForContextOnly, isFalse);
        expect(record.inactiveBoundary, isFalse);
        expect(record.supportCaseIds, isNotEmpty);
      }
      expect(coreGroup.packetIds, hasLength(2));
      expect(coreGroup.safeForNextInternalLayer, isTrue);
    });

    test('watch, proof, and warning context packets remain constrained', () {
      final watch = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      );
      final proof = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.proofLimitedSummary,
      );
      final warning = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.warningLimitedSummary,
      );
      final contextGroup = _gate().readinessGroup(
        InternalEvidenceAdapterPrototypeReadinessGroupId
            .constrainedContextAdapterPackets,
      );

      for (final record in <InternalEvidenceAdapterPrototypeReadinessRecord>[
        watch,
        proof,
        warning,
      ]) {
        expect(
          record.readinessStatus,
          InternalEvidenceAdapterPrototypeReadinessItemStatus
              .constrainedContextOnlyPacket,
        );
        expect(record.allowedForNextInternalLayer, isFalse);
        expect(record.constrainedForContextOnly, isTrue);
        expect(record.warningReason, isNotEmpty);
      }
      expect(watch.proofLimitReason, isNotEmpty);
      expect(proof.proofLimitReason, isNotEmpty);
      expect(contextGroup.packetIds, hasLength(3));
      expect(contextGroup.safeForNextInternalLayer, isTrue);
    });

    test('blocked and future-only packets remain inactive', () {
      final blocked = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );
      final future = _gate().recordForGroup(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(
        blocked.readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessItemStatus
            .inactiveBlockedPacket,
      );
      expect(
        future.readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessItemStatus
            .inactiveFutureOnlyPacket,
      );
      for (final record in <InternalEvidenceAdapterPrototypeReadinessRecord>[
        blocked,
        future,
      ]) {
        expect(record.allowedForNextInternalLayer, isFalse);
        expect(record.constrainedForContextOnly, isFalse);
        expect(record.inactiveBoundary, isTrue);
        expect(record.activeOutputFieldIds, isEmpty);
      }
    });

    test('core packet from non-core source fails readiness', () {
      final result = _gateFromValidation(
        _withValidationRow(
          'validation-packet-allowedEvidenceSummary',
          (row) => row.copyWith(
            sourceSummaryGroupIds: const <InternalEvidenceSummaryGroupId>[
              InternalEvidenceSummaryGroupId.warningLimitedSummary,
            ],
          ),
        ),
      );

      expect(
        result.recordForPacket('packet-allowedEvidenceSummary').readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('corePacketFromNonCoreSource'),
      );
    });

    test('context-only packet cannot become allowed core readiness', () {
      final result = _gateFromValidation(
        _withValidationRow(
          'validation-packet-constrainedWatchListSummary',
          (row) => row.copyWith(
            adapterRole: InternalEvidenceAdapterPacketRole.coreEvidencePacket,
          ),
        ),
      );

      expect(
        result
            .recordForPacket('packet-constrainedWatchListSummary')
            .readinessStatus,
        InternalEvidenceAdapterPrototypeReadinessItemStatus.invalid,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('contextOnlyPacketPromotedToAllowedCore'),
      );
    });

    test('blocked and future-only packets cannot become active', () {
      final blocked = _gateFromValidation(
        _withValidationRow(
          'validation-packet-blockedBoundarySummary',
          (row) => row.copyWith(
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        ),
      );
      final future = _gateFromValidation(
        _withValidationRow(
          'validation-packet-futureOnlySummary',
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

  group('Output field and proof readiness behavior', () {
    test('active output fields are internal evidence-safe only', () {
      expect(
        _gate().activeOutputFieldIds,
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
      for (final fieldId in _gate().blockedOutputFieldIds) {
        expect(_gate().activeOutputFieldIds, isNot(contains(fieldId)));
      }
    });

    test('blocked output fields remain explicit denials', () {
      expect(
        _gate().blockedOutputFieldIds,
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
        _gate()
            .readinessGroup(
              InternalEvidenceAdapterPrototypeReadinessGroupId
                  .blockedOutputFields,
            )
            .safeForNextInternalLayer,
        isTrue,
      );
    });

    test('Android proof IDs and owner proof status remain honest', () {
      expect(_gate().androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(_gate().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_gate().androidProofCaseIds, isNot(contains(caseId)));
        for (final record in _gate().records) {
          expect(record.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('ready packets do not emit product or scoring families', () {
      for (final record in _gate().records) {
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

  group('InternalEvidenceAdapterPrototypeReadinessGateValidator', () {
    test('rejects unsafe validation marked ready', () {
      final unsafeReady = _gate().copyWith(
        sourceValidationStatus: InternalEvidenceAdapterPrototypeValidationStatus
            .blockedByUnsafeReview,
        unsafeCount: 1,
        safeForPhase32R: true,
      );

      expect(
        _validator().validate(unsafeReady).map((finding) => finding.id),
        contains('unsafeValidationMarkedReady'),
      );
    });

    test('rejects unproven Android proof and Phase 32E proof claims', () {
      final unproven = _gate().copyWith(
        androidProofCaseIds: <String>[
          ..._gate().androidProofCaseIds,
          'unproven-android-proof',
        ],
      );
      final phase32E = _withReadinessRecord(
        'readiness-packet-proofLimitedSummary',
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

    test('rejects direct readiness promotion and active inactive seams', () {
      final contextPromoted = _withReadinessRecord(
        'readiness-packet-constrainedWatchListSummary',
        (record) => record.copyWith(allowedForNextInternalLayer: true),
      );
      final blockedActive = _withReadinessRecord(
        'readiness-packet-blockedBoundarySummary',
        (record) => record.copyWith(
          inactiveBoundary: false,
          activeOutputFieldIds: const <String>['adapterPacketId'],
        ),
      );
      final futureActive = _withReadinessRecord(
        'readiness-packet-futureOnlySummary',
        (record) => record.copyWith(
          inactiveBoundary: false,
          activeOutputFieldIds: const <String>['adapterPacketId'],
        ),
      );

      expect(
        _validator().validate(contextPromoted).map((finding) => finding.id),
        contains('contextOnlyPacketPromotedToAllowedCore'),
      );
      expect(
        _validator().validate(blockedActive).map((finding) => finding.id),
        contains('blockedPacketMadeActive'),
      );
      expect(
        _validator().validate(futureActive).map((finding) => finding.id),
        contains('futureOnlyPacketMadeActive'),
      );
    });

    test('rejects owner proof without explicit PV reason', () {
      final ownerProof = _gate().copyWith(
        ownerProofQueueCount: 1,
        warnings: const <String>[],
        failures: const <String>[],
        records: _gate().records
            .map(
              (record) => record.copyWith(
                warningReason: '',
                proofLimitReason: '',
                futurePrerequisites: const <String>[],
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
        validator.validateReportText(_gate().renderMarkdownReport()),
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

  group('Readiness report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _gate().renderMarkdownReport();

      expect(
        report,
        contains('# Internal Evidence Adapter Prototype Readiness Gate'),
      );
      expect(report, contains('## Readiness Group Table'));
      expect(report, contains('## Readiness Record Table'));
      expect(report, contains('## Allowed Core Packets'));
      expect(report, contains('## Constrained Context-Only Packets'));
      expect(report, contains('## Blocked Output Field Summary'));
      expect(report, contains('## Phase 32R Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _gate().renderJsonReport();
      final second = _gate().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalEvidenceAdapterPrototypeReadinessGateReportVersion,
      );
      expect(decoded['readinessStatus'], 'readyWithWarnings');
      expect(decoded['groups'], isA<List<Object?>>());
      expect(decoded['records'], isA<List<Object?>>());
      expect(decoded['safeForPhase32R'], isTrue);
    });

    test('reports contain no raw engine or active product-output text', () {
      final report = _gate().renderMarkdownReport();

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
        'lib/features/pgn_review/application/internal_evidence_adapter_prototype_readiness_gate.dart',
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

InternalEvidenceAdapterPrototypeReadinessGateResult _gate() {
  return _cachedGate!;
}

InternalEvidenceAdapterPrototypeValidationResult _validation() {
  return _cachedValidation!;
}

InternalEvidenceAdapterPrototypeReviewResult _review() => _cachedReview!;

InternalEvidenceAdapterPrototypeResult _prototype() => _cachedPrototype!;

InternalEvidenceAdapterDesignResult _design() => _cachedDesign!;

InternalEvidenceSummaryLayerResult _summary() => _cachedSummary!;

RefreshedPacketEvidenceReadinessGateResult _readiness() => _cachedReadiness!;

InternalEvidenceAdapterPrototypeReadinessGateValidator _validator() {
  return const InternalEvidenceAdapterPrototypeReadinessGateValidator();
}

InternalEvidenceAdapterPrototypeReadinessGateResult _gateFromValidation(
  InternalEvidenceAdapterPrototypeValidationResult validation,
) {
  return const InternalEvidenceAdapterPrototypeReadinessGate().evaluate(
    InternalEvidenceAdapterPrototypeReadinessGateRequest(
      validationResult: validation,
      reviewResult: _cachedReview,
      prototypeResult: _cachedPrototype,
      designResult: _cachedDesign,
      summaryResult: _cachedSummary,
      readinessResult: _cachedReadiness,
    ),
  );
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

InternalEvidenceAdapterPrototypeReadinessGateResult _withRecordFlag(
  InternalEvidenceAdapterPrototypeReadinessRecord Function(
    InternalEvidenceAdapterPrototypeReadinessRecord record,
  )
  update,
) {
  return _withReadinessRecord(
    'readiness-packet-allowedEvidenceSummary',
    update,
  );
}

InternalEvidenceAdapterPrototypeReadinessGateResult _withActiveField(
  String fieldId,
) {
  return _withReadinessRecord(
    'readiness-packet-allowedEvidenceSummary',
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
