@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:flutter_test/flutter_test.dart';

InternalEvidenceAdapterDesignResult? _cachedDesign;
InternalEvidenceSummaryLayerResult? _cachedSummary;

void main() {
  setUpAll(() {
    _cachedSummary = const InternalEvidenceSummaryLayer().evaluate();
    _cachedDesign = const InternalEvidenceAdapterDesign().evaluate();
  });

  group('InternalEvidenceAdapterDesign safe demo', () {
    test('consumes safe Phase 32L summary', () {
      final summary = _summary();
      final result = const InternalEvidenceAdapterDesign().evaluate(
        InternalEvidenceAdapterDesignRequest(summaryResult: summary),
      );

      expect(
        result.sourceSummaryStatus,
        InternalEvidenceSummaryLayerStatus.summarizedWithWarnings,
      );
      expect(summary.safeForPhase32M, isTrue);
      expect(result.safeForPhase32N, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status is design ready with warning honesty', () {
      final result = _design();

      expect(
        result.designStatus,
        isIn(<InternalEvidenceAdapterDesignStatus>[
          InternalEvidenceAdapterDesignStatus.designReadyWithWarnings,
          InternalEvidenceAdapterDesignStatus.designReadyClean,
        ]),
      );
      expect(
        result.designStatus,
        InternalEvidenceAdapterDesignStatus.designReadyWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32N, isTrue);
    });

    test('unsafe summary blocks adapter design', () {
      final unsafeSummary = _summary().copyWith(
        summaryStatus:
            InternalEvidenceSummaryLayerStatus.blockedByUnsafeReadiness,
        unsafeCount: 1,
        safeForPhase32M: false,
      );
      final result = const InternalEvidenceAdapterDesign().evaluate(
        InternalEvidenceAdapterDesignRequest(summaryResult: unsafeSummary),
      );

      expect(
        result.designStatus,
        InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary,
      );
      expect(result.safeForPhase32N, isFalse);
      expect(result.totalAdapterRecords, 0);
      expect(
        result.phase32NRecommendation,
        InternalEvidenceAdapterPhase32NRecommendation
            .blockedByUnsafeAdapterDesign,
      );
    });

    test('aggregate adapter counts are deterministic', () {
      final first = _design();
      final second = const InternalEvidenceAdapterDesign().evaluate();

      expect(first.totalAdapterRecords, 7);
      expect(first.coreAdapterRecordCount, 2);
      expect(first.contextOnlyRecordCount, 3);
      expect(first.blockedRecordCount, 1);
      expect(first.futureOnlyRecordCount, 1);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32N recommendation and support IDs are deterministic', () {
      final result = _design();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32NRecommendation,
        InternalEvidenceAdapterPhase32NRecommendation
            .proceedToInternalEvidenceAdapterPrototype,
      );
      expect(result.safeForPhase32N, isTrue);
    });
  });

  group('Adapter input contract behavior', () {
    test('allowed summary becomes core adapter input', () {
      final input = _design().inputContract(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );
      final record = _design().adapterRecord(
        InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
      );

      expect(input.inputStatus, InternalEvidenceAdapterInputStatus.coreAllowed);
      expect(input.allowedForAdapterCore, isTrue);
      expect(input.allowedForAdapterContext, isFalse);
      expect(input.blockedFromAdapter, isFalse);
      expect(record.adapterRole, InternalEvidenceAdapterRole.coreEvidence);
      expect(
        record.designStatus,
        InternalEvidenceAdapterRecordStatus.coreAdapterReady,
      );
    });

    test('improved support summary becomes core adapter input', () {
      final input = _design().inputContract(
        InternalEvidenceSummaryGroupId.improvedSupportSummary,
      );
      final record = _design().adapterRecord(
        InternalEvidenceSummaryGroupId.improvedSupportSummary,
      );

      expect(input.inputStatus, InternalEvidenceAdapterInputStatus.coreAllowed);
      expect(input.newlyAddedSupportCaseIds, isNotEmpty);
      expect(record.adapterRole, InternalEvidenceAdapterRole.coreEvidence);
      expect(
        record.recommendation,
        InternalEvidenceAdapterRecommendation.allowCoreAdapterDesign,
      );
    });

    test(
      'PV, Android proof, and warning-limited summaries are context-only',
      () {
        for (final groupId in <InternalEvidenceSummaryGroupId>[
          InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
          InternalEvidenceSummaryGroupId.proofLimitedSummary,
          InternalEvidenceSummaryGroupId.warningLimitedSummary,
        ]) {
          final input = _design().inputContract(groupId);
          final record = _design().adapterRecord(groupId);

          expect(
            input.inputStatus,
            InternalEvidenceAdapterInputStatus.contextOnly,
          );
          expect(input.allowedForAdapterCore, isFalse);
          expect(input.allowedForAdapterContext, isTrue);
          expect(
            record.adapterRole,
            InternalEvidenceAdapterRole.contextualConstraint,
          );
          expect(
            record.designStatus,
            InternalEvidenceAdapterRecordStatus.contextOnly,
          );
          expect(
            record.recommendation,
            InternalEvidenceAdapterRecommendation.allowContextOnly,
          );
        }
      },
    );

    test('blocked and future-only summaries are not active', () {
      final blocked = _design().inputContract(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );
      final future = _design().inputContract(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(blocked.inputStatus, InternalEvidenceAdapterInputStatus.blocked);
      expect(blocked.blockedFromAdapter, isTrue);
      expect(future.inputStatus, InternalEvidenceAdapterInputStatus.futureOnly);
      expect(future.blockedFromAdapter, isTrue);
      expect(
        _design()
            .adapterRecord(
              InternalEvidenceSummaryGroupId.blockedBoundarySummary,
            )
            .allowedOutputFieldIds,
        isEmpty,
      );
      expect(
        _design()
            .adapterRecord(InternalEvidenceSummaryGroupId.futureOnlySummary)
            .allowedOutputFieldIds,
        isEmpty,
      );
    });
  });

  group('Adapter output contract behavior', () {
    test('allowed output fields include internal evidence-safe fields', () {
      expect(
        _design().outputContract.allowedOutputFieldIds,
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
    });

    test(
      'blocked output fields include product, labels, values, metrics, and integrations',
      () {
        expect(
          _design().blockedOutputFieldIds,
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
        for (final fieldId in _design().blockedOutputFieldIds) {
          expect(
            _design().outputContract.allowedOutputFieldIds,
            isNot(contains(fieldId)),
          );
          expect(
            _design().outputContract.contextOnlyOutputFieldIds,
            isNot(contains(fieldId)),
          );
        }
      },
    );

    test('proof and owner boundaries hold', () {
      expect(_design().androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(_design().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_design().androidProofCaseIds, isNot(contains(caseId)));
        for (final record in _design().adapterRecords) {
          expect(record.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });
  });

  group('InternalEvidenceAdapterDesignValidator', () {
    test(
      'rejects unproven Android proof and Phase 32E captured proof claims',
      () {
        final unproven = _design().copyWith(
          androidProofCaseIds: <String>[
            ..._design().androidProofCaseIds,
            'unproven-android-proof',
          ],
        );
        final phase32E = _withAdapterRecord(
          InternalEvidenceSummaryGroupId.proofLimitedSummary,
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
      'rejects active label, numeric score, ranking, metric, and future metric fields',
      () {
        final validator = _validator();

        expect(
          validator
              .validate(_withAllowedOutputField('productLabel'))
              .map((finding) => finding.id),
          contains('productOutputFieldAllowed'),
        );
        expect(
          validator
              .validate(_withAllowedOutputField('finalMoveLabel'))
              .map((finding) => finding.id),
          contains('classifierLabelOutputFieldAllowed'),
        );
        expect(
          validator
              .validate(_withAllowedOutputField('numericMoveScore'))
              .map((finding) => finding.id),
          contains('numericScoreOutputFieldAllowed'),
        );
        expect(
          validator
              .validate(_withAllowedOutputField('moveRanking'))
              .map((finding) => finding.id),
          contains('moveRankingOutputFieldAllowed'),
        );
        expect(
          validator
              .validate(_withAllowedOutputField('officialAccuracy'))
              .map((finding) => finding.id),
          contains('officialMetricOutputFieldAllowed'),
        );
        expect(
          validator
              .validate(_withAllowedOutputField('cpLoss'))
              .map((finding) => finding.id),
          contains('futureMetricOutputFieldAllowed'),
        );
        expect(
          validator
              .validate(_withAllowedOutputField('winProbability'))
              .map((finding) => finding.id),
          contains('futureMetricOutputFieldAllowed'),
        );
      },
    );

    test(
      'rejects quiet activation, constrained promotion, and blocked/future activation',
      () {
        final quiet = _design().copyWith(quietPreparatoryScopeActivated: true);
        final constrained = _withAdapterRecord(
          InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
          (record) => record.copyWith(
            adapterRole: InternalEvidenceAdapterRole.coreEvidence,
          ),
        );
        final blocked = _withAdapterRecord(
          InternalEvidenceSummaryGroupId.blockedBoundarySummary,
          (record) => record.copyWith(
            adapterRole: InternalEvidenceAdapterRole.coreEvidence,
          ),
        );
        final future = _withAdapterRecord(
          InternalEvidenceSummaryGroupId.futureOnlySummary,
          (record) => record.copyWith(
            adapterRole: InternalEvidenceAdapterRole.coreEvidence,
          ),
        );

        expect(
          _validator().validate(quiet).map((finding) => finding.id),
          contains('adapterBoundaryPolicyViolation'),
        );
        expect(
          _validator().validate(constrained).map((finding) => finding.id),
          contains('constrainedGroupPromotedToCoreOutput'),
        );
        expect(
          _validator().validate(blocked).map((finding) => finding.id),
          contains('blockedGroupMadeActive'),
        );
        expect(
          _validator().validate(future).map((finding) => finding.id),
          contains('futureOnlyGroupMadeActive'),
        );
      },
    );

    test('rejects owner proof without PV reason and unsafe report text', () {
      final ownerProof = _design().copyWith(
        ownerProofQueueCount: 1,
        inputContractRecords: _design().inputContractRecords
            .map(
              (record) => record.copyWith(
                warningReasons: const <String>[],
                proofLimitReasons: const <String>[],
                futurePrerequisites: const <String>[],
              ),
            )
            .toList(),
        adapterRecords: _design().adapterRecords
            .map(
              (record) => record.copyWith(
                warningReason: '',
                proofLimitReason: '',
                futurePrerequisite: '',
              ),
            )
            .toList(),
      );
      final validator = _validator();

      expect(
        validator.validate(ownerProof).map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
      expect(
        validator.validateReportText(_design().renderMarkdownReport()),
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
            .validateReportText('allowed output fields: productLabel')
            .map((finding) => finding.id),
        contains('activeLabelReportText'),
      );
    });
  });

  group('Adapter report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _design().renderMarkdownReport();

      expect(report, contains('# Internal Evidence Adapter Design'));
      expect(report, contains('## Input Contract Table'));
      expect(report, contains('## Output Contract Table'));
      expect(report, contains('## Adapter Design Record Table'));
      expect(report, contains('## Blocked Output Fields'));
      expect(report, contains('## Phase 32N Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _design().renderJsonReport();
      final second = _design().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalEvidenceAdapterDesignReportVersion);
      expect(decoded['designStatus'], 'designReadyWithWarnings');
      expect(decoded['adapterRecords'], isA<List<Object?>>());
      expect(decoded['safeForPhase32N'], isTrue);
    });

    test('reports contain no raw engine or active product-output text', () {
      final report = _design().renderMarkdownReport();

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
        'lib/features/pgn_review/application/internal_evidence_adapter_design.dart',
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

InternalEvidenceAdapterDesignResult _design() => _cachedDesign!;

InternalEvidenceSummaryLayerResult _summary() => _cachedSummary!;

InternalEvidenceAdapterDesignValidator _validator() {
  return const InternalEvidenceAdapterDesignValidator();
}

InternalEvidenceAdapterDesignResult _withAdapterRecord(
  InternalEvidenceSummaryGroupId groupId,
  InternalEvidenceAdapterDesignRecord Function(
    InternalEvidenceAdapterDesignRecord record,
  )
  update,
) {
  final records = _design().adapterRecords.map((record) {
    if (record.sourceSummaryGroupId == groupId) return update(record);
    return record;
  }).toList();
  return _design().copyWith(adapterRecords: records);
}

InternalEvidenceAdapterDesignResult _withAllowedOutputField(String fieldId) {
  final outputContract = _design().outputContract.copyWith(
    allowedOutputFieldIds: <String>[
      ..._design().outputContract.allowedOutputFieldIds,
      fieldId,
    ],
  );
  return _design().copyWith(outputContract: outputContract);
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
