@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_evidence_readiness_gate.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });

  group('InternalEvidenceAdapterPrototypeReview safe demo', () {
    test('consumes safe Phase 32N prototype and upstream contracts', () {
      final result = const InternalEvidenceAdapterPrototypeReview().evaluate(
        InternalEvidenceAdapterPrototypeReviewRequest(
          prototypeResult: _prototype(),
          designResult: _design(),
          summaryResult: _summary(),
          readinessResult: _readiness(),
        ),
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
      expect(
        result.sourceReadinessStatus,
        RefreshedPacketEvidenceReadinessStatus.readyWithWarnings,
      );
      expect(_prototype().safeForPhase32O, isTrue);
      expect(result.safeForPhase32P, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status is reviewed with warning honesty', () {
      final result = _review();

      expect(
        result.reviewStatus,
        isIn(<InternalEvidenceAdapterPrototypeReviewStatus>[
          InternalEvidenceAdapterPrototypeReviewStatus.reviewedWithWarnings,
          InternalEvidenceAdapterPrototypeReviewStatus.reviewedClean,
        ]),
      );
      expect(
        result.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewStatus.reviewedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32P, isTrue);
    });

    test('unsafe prototype blocks review', () {
      final unsafePrototype = _prototype().copyWith(
        prototypeStatus:
            InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign,
        unsafeCount: 1,
        safeForPhase32O: false,
      );
      final result = const InternalEvidenceAdapterPrototypeReview().evaluate(
        InternalEvidenceAdapterPrototypeReviewRequest(
          prototypeResult: unsafePrototype,
          designResult: _design(),
          summaryResult: _summary(),
          readinessResult: _readiness(),
        ),
      );

      expect(
        result.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewStatus.blockedByUnsafePrototype,
      );
      expect(result.safeForPhase32P, isFalse);
      expect(
        result.phase32PRecommendation,
        InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
            .blockedByUnsafeAdapterReview,
      );
    });

    test('aggregate review result is deterministic', () {
      final first = _review();
      final second = const InternalEvidenceAdapterPrototypeReview().evaluate();

      expect(first.totalRows, 7);
      expect(first.validCorePacketCount, 2);
      expect(first.validContextOnlyPacketCount, 3);
      expect(first.validBlockedPacketCount, 1);
      expect(first.validFutureOnlyPacketCount, 1);
      expect(first.invalidCount, 0);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32P recommendation and support IDs are deterministic', () {
      final result = _review();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32PRecommendation,
        InternalEvidenceAdapterPrototypeReviewPhase32PRecommendation
            .proceedToAdapterPrototypeValidation,
      );
      expect(result.safeForPhase32P, isTrue);
    });
  });

  group('Packet review behavior', () {
    test('core packets from allowed and improved summaries are valid', () {
      final allowed = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );
      final improved = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.improvedSupportSummary,
      );

      expect(
        allowed.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validCorePacket,
      );
      expect(
        improved.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validCorePacket,
      );
      for (final row in <InternalEvidenceAdapterPrototypeReviewRow>[
        allowed,
        improved,
      ]) {
        expect(row.adapterRole.isCore, isTrue);
        expect(row.supportCaseIds, isNotEmpty);
        expect(row.allowedEvidenceRecordIds, isNotEmpty);
        expect(row.safeForNextAdapterGate, isTrue);
      }
    });

    test('context-only packets remain valid context-only packets', () {
      final watch = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
      );
      final proof = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.proofLimitedSummary,
      );
      final warning = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.warningLimitedSummary,
      );

      expect(
        watch.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validContextOnlyPacket,
      );
      expect(
        proof.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validContextOnlyPacket,
      );
      expect(
        warning.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validContextOnlyPacket,
      );
      expect(watch.watchListReason, isNotEmpty);
      expect(proof.proofLimitReason, isNotEmpty);
      expect(warning.warningLimitedReason, isNotEmpty);
    });

    test('blocked and future-only packets remain inactive and valid', () {
      final blocked = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );
      final future = _review().rowForGroup(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(
        blocked.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validBlockedPacket,
      );
      expect(
        future.reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.validFutureOnlyPacket,
      );
      for (final row in <InternalEvidenceAdapterPrototypeReviewRow>[
        blocked,
        future,
      ]) {
        expect(row.activeOutputFieldIds, isEmpty);
        expect(row.allowedEvidenceRecordIds, isEmpty);
        expect(row.safeForNextAdapterGate, isTrue);
      }
    });

    test('context-only packet cannot become core', () {
      final result = _reviewFromPrototype(
        _withPacket(
          'packet-constrainedWatchListSummary',
          (packet) => packet.copyWith(
            adapterRole: InternalEvidenceAdapterPacketRole.coreEvidencePacket,
          ),
        ),
      );

      expect(
        result.rowForPacket('packet-constrainedWatchListSummary').reviewStatus,
        InternalEvidenceAdapterPrototypeReviewRowStatus.invalidPacket,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('contextOnlyPacketPromotedToCore'),
      );
    });

    test('blocked and future-only packets cannot become active', () {
      final blocked = _reviewFromPrototype(
        _withPacket(
          'packet-blockedBoundarySummary',
          (packet) => packet.copyWith(
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        ),
      );
      final future = _reviewFromPrototype(
        _withPacket(
          'packet-futureOnlySummary',
          (packet) => packet.copyWith(
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

  group('Output field and proof review behavior', () {
    test('active output fields are internal evidence-safe only', () {
      expect(
        _review().activeOutputFieldIds,
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
      for (final fieldId in _review().blockedOutputFieldIds) {
        expect(_review().activeOutputFieldIds, isNot(contains(fieldId)));
      }
    });

    test(
      'blocked fields include labels, scores, metrics, rankings, and integrations',
      () {
        expect(
          _review().blockedOutputFieldIds,
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
      },
    );

    test('Android proof IDs and owner proof status remain honest', () {
      expect(_review().androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(_review().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_review().androidProofCaseIds, isNot(contains(caseId)));
        for (final row in _review().rows) {
          expect(row.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });

    test('reviewed packets do not emit product output or scoring families', () {
      for (final row in _review().rows) {
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

  group('InternalEvidenceAdapterPrototypeReviewValidator', () {
    test('rejects unsafe prototype marked reviewed', () {
      final unsafeReviewed = _review().copyWith(
        sourcePrototypeStatus:
            InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign,
        unsafeCount: 1,
        safeForPhase32P: true,
      );

      expect(
        _validator().validate(unsafeReviewed).map((finding) => finding.id),
        contains('unsafePrototypeMarkedReviewed'),
      );
    });

    test('rejects unproven Android proof and Phase 32E proof claims', () {
      final unproven = _review().copyWith(
        androidProofCaseIds: <String>[
          ..._review().androidProofCaseIds,
          'unproven-android-proof',
        ],
      );
      final phase32E = _withRow(
        'review-packet-proofLimitedSummary',
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
              _withRowFlag((row) => row.copyWith(hasNumericScore: true)),
            )
            .map((finding) => finding.id),
        contains('numericScoreOutputActive'),
      );
      expect(
        validator
            .validate(_withRowFlag((row) => row.copyWith(ranksMoves: true)))
            .map((finding) => finding.id),
        contains('moveRankingOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRowFlag((row) => row.copyWith(isOfficialMetric: true)),
            )
            .map((finding) => finding.id),
        contains('officialMetricOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRowFlag((row) => row.copyWith(cpLossOutputActive: true)),
            )
            .map((finding) => finding.id),
        contains('futureMetricOutputActive'),
      );
      expect(
        validator
            .validate(
              _withRowFlag(
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
              _withRowFlag(
                (row) => row.copyWith(quietPreparatoryScopeActive: true),
              ),
            )
            .map((finding) => finding.id),
        contains('quietPreparatoryScopeActivated'),
      );
      expect(
        validator
            .validate(_withRowFlag((row) => row.copyWith(callsEngine: true)))
            .map((finding) => finding.id),
        contains('engineCallFlagActive'),
      );
      expect(
        validator
            .validate(
              _withRowFlag((row) => row.copyWith(writesPersistence: true)),
            )
            .map((finding) => finding.id),
        contains('persistenceWriteFlagActive'),
      );
      expect(
        validator
            .validate(_withRowFlag((row) => row.copyWith(targetsUi: true)))
            .map((finding) => finding.id),
        contains('uiTargetFlagActive'),
      );
    });

    test('rejects owner proof without explicit PV reason', () {
      final ownerProof = _review().copyWith(
        ownerProofQueueCount: 1,
        rows: _review().rows
            .map(
              (row) => row.copyWith(
                internalWarnings: const <String>[],
                internalConstraints: const <String>[],
                futurePrerequisites: const <String>[],
                proofLimitReason: '',
                watchListReason: '',
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
        validator.validateReportText(_review().renderMarkdownReport()),
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

  group('Review report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _review().renderMarkdownReport();

      expect(report, contains('# Internal Evidence Adapter Prototype Review'));
      expect(report, contains('## Packet Review Table'));
      expect(report, contains('## Core Packet Review Rows'));
      expect(report, contains('## Context-Only Packet Review Rows'));
      expect(report, contains('## Blocked Output Field Summary'));
      expect(report, contains('## Phase 32P Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _review().renderJsonReport();
      final second = _review().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalEvidenceAdapterPrototypeReviewReportVersion,
      );
      expect(decoded['reviewStatus'], 'reviewedWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
      expect(decoded['safeForPhase32P'], isTrue);
    });

    test('reports contain no raw engine or active product-output text', () {
      final report = _review().renderMarkdownReport();

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
        'lib/features/pgn_review/application/internal_evidence_adapter_prototype_review.dart',
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

InternalEvidenceAdapterPrototypeReviewResult _review() => _cachedReview!;

InternalEvidenceAdapterPrototypeResult _prototype() => _cachedPrototype!;

InternalEvidenceAdapterDesignResult _design() => _cachedDesign!;

InternalEvidenceSummaryLayerResult _summary() => _cachedSummary!;

RefreshedPacketEvidenceReadinessGateResult _readiness() => _cachedReadiness!;

InternalEvidenceAdapterPrototypeReviewValidator _validator() {
  return const InternalEvidenceAdapterPrototypeReviewValidator();
}

InternalEvidenceAdapterPrototypeReviewResult _reviewFromPrototype(
  InternalEvidenceAdapterPrototypeResult prototype,
) {
  return const InternalEvidenceAdapterPrototypeReview().evaluate(
    InternalEvidenceAdapterPrototypeReviewRequest(
      prototypeResult: prototype,
      designResult: _cachedDesign,
      summaryResult: _cachedSummary,
      readinessResult: _cachedReadiness,
    ),
  );
}

InternalEvidenceAdapterPrototypeResult _withPacket(
  String adapterPacketId,
  InternalEvidenceAdapterPacket Function(InternalEvidenceAdapterPacket packet)
  update,
) {
  final packets = _prototype().packets.map((packet) {
    if (packet.adapterPacketId == adapterPacketId) return update(packet);
    return packet;
  }).toList();
  return _prototype().copyWith(packets: packets);
}

InternalEvidenceAdapterPrototypeReviewResult _withRow(
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

InternalEvidenceAdapterPrototypeReviewResult _withRowFlag(
  InternalEvidenceAdapterPrototypeReviewRow Function(
    InternalEvidenceAdapterPrototypeReviewRow row,
  )
  update,
) {
  return _withRow('review-packet-allowedEvidenceSummary', update);
}

InternalEvidenceAdapterPrototypeReviewResult _withActiveField(String fieldId) {
  return _withRow(
    'review-packet-allowedEvidenceSummary',
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
