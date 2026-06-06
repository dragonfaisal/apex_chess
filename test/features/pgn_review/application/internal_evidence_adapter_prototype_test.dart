@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_adapter_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_summary_layer.dart';
import 'package:flutter_test/flutter_test.dart';

InternalEvidenceAdapterPrototypeResult? _cachedPrototype;
InternalEvidenceAdapterDesignResult? _cachedDesign;

void main() {
  setUpAll(() {
    _cachedDesign = const InternalEvidenceAdapterDesign().evaluate();
    _cachedPrototype = const InternalEvidenceAdapterPrototype().evaluate();
  });

  group('InternalEvidenceAdapterPrototype safe demo', () {
    test('consumes safe Phase 32M design', () {
      final design = _design();
      final result = const InternalEvidenceAdapterPrototype().evaluate(
        InternalEvidenceAdapterPrototypeRequest(designResult: design),
      );

      expect(
        result.sourceDesignStatus,
        InternalEvidenceAdapterDesignStatus.designReadyWithWarnings,
      );
      expect(design.safeForPhase32N, isTrue);
      expect(result.safeForPhase32O, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status is completed with warning honesty', () {
      final result = _prototype();

      expect(
        result.prototypeStatus,
        isIn(<InternalEvidenceAdapterPrototypeStatus>[
          InternalEvidenceAdapterPrototypeStatus.completedWithWarnings,
          InternalEvidenceAdapterPrototypeStatus.completedClean,
        ]),
      );
      expect(
        result.prototypeStatus,
        InternalEvidenceAdapterPrototypeStatus.completedWithWarnings,
      );
      expect(result.unsafeCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.safeForPhase32O, isTrue);
    });

    test('unsafe design blocks prototype', () {
      final unsafeDesign = _design().copyWith(
        designStatus:
            InternalEvidenceAdapterDesignStatus.blockedByUnsafeSummary,
        unsafeCount: 1,
        safeForPhase32N: false,
      );
      final result = const InternalEvidenceAdapterPrototype().evaluate(
        InternalEvidenceAdapterPrototypeRequest(designResult: unsafeDesign),
      );

      expect(
        result.prototypeStatus,
        InternalEvidenceAdapterPrototypeStatus.skippedByUnsafeDesign,
      );
      expect(result.safeForPhase32O, isFalse);
      expect(result.totalPackets, 0);
      expect(
        result.phase32ORecommendation,
        InternalEvidenceAdapterPrototypePhase32ORecommendation
            .blockedByUnsafeAdapterPrototype,
      );
    });

    test('aggregate prototype counts are deterministic', () {
      final first = _prototype();
      final second = const InternalEvidenceAdapterPrototype().evaluate();

      expect(first.totalPackets, 7);
      expect(first.corePacketCount, 2);
      expect(first.contextOnlyPacketCount, 3);
      expect(first.blockedPacketCount, 1);
      expect(first.futureOnlyPacketCount, 1);
      expect(first.unsafeCount, 0);
      expect(first.criticalCount, 0);
      expect(first.toJson(), second.toJson());
    });

    test('Phase 32O recommendation and support IDs are deterministic', () {
      final result = _prototype();

      expect(
        result.newlyAddedSupportCaseIds,
        orderedEquals(_phase32ECaseIdsSorted),
      );
      expect(result.androidProofCaseIds, orderedEquals(_provenAndroidIds));
      expect(
        result.phase32ORecommendation,
        InternalEvidenceAdapterPrototypePhase32ORecommendation
            .reviewInternalEvidenceAdapterPrototype,
      );
      expect(result.safeForPhase32O, isTrue);
    });
  });

  group('Adapter packet generation behavior', () {
    test(
      'core packets are generated from allowed and improved summaries only',
      () {
        expect(_prototype().corePackets, hasLength(2));
        expect(
          _prototype().corePackets.map(
            (packet) => packet.sourceSummaryGroupIds.single,
          ),
          unorderedEquals(<InternalEvidenceSummaryGroupId>[
            InternalEvidenceSummaryGroupId.allowedEvidenceSummary,
            InternalEvidenceSummaryGroupId.improvedSupportSummary,
          ]),
        );
        for (final packet in _prototype().corePackets) {
          expect(
            packet.adapterRole,
            InternalEvidenceAdapterPacketRole.coreEvidencePacket,
          );
          expect(packet.supportCaseIds, isNotEmpty);
          expect(packet.allowedEvidenceRecordIds, isNotEmpty);
          expect(packet.evidenceAreaIds, isNotEmpty);
          expect(packet.bucketIds, isNotEmpty);
        }
      },
    );

    test(
      'context-only packets are generated from constrained summaries only',
      () {
        expect(_prototype().contextOnlyPackets, hasLength(3));
        expect(
          _prototype().contextOnlyPackets.map(
            (packet) => packet.sourceSummaryGroupIds.single,
          ),
          unorderedEquals(<InternalEvidenceSummaryGroupId>[
            InternalEvidenceSummaryGroupId.constrainedWatchListSummary,
            InternalEvidenceSummaryGroupId.proofLimitedSummary,
            InternalEvidenceSummaryGroupId.warningLimitedSummary,
          ]),
        );
        for (final packet in _prototype().contextOnlyPackets) {
          expect(
            packet.adapterRole,
            InternalEvidenceAdapterPacketRole.contextOnlyPacket,
          );
          expect(packet.activeOutputFieldIds, isNotEmpty);
          expect(packet.activeOutputFieldIds, isNot(contains('productLabel')));
        }
      },
    );

    test('blocked and future-only summaries produce inactive packets only', () {
      final blocked = _prototype().packetForGroup(
        InternalEvidenceSummaryGroupId.blockedBoundarySummary,
      );
      final future = _prototype().packetForGroup(
        InternalEvidenceSummaryGroupId.futureOnlySummary,
      );

      expect(
        blocked.adapterRole,
        InternalEvidenceAdapterPacketRole.blockedBoundaryPacket,
      );
      expect(
        future.adapterRole,
        InternalEvidenceAdapterPacketRole.futureOnlyPacket,
      );
      for (final packet in <InternalEvidenceAdapterPacket>[blocked, future]) {
        expect(packet.activeOutputFieldIds, isEmpty);
        expect(packet.allowedEvidenceRecordIds, isEmpty);
        expect(packet.isInactiveSafe, isTrue);
      }
    });

    test('active and blocked output fields obey the contract', () {
      expect(
        _prototype().activeOutputFieldIds,
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
      expect(
        _prototype().blockedOutputFieldIds,
        containsAll(<String>[
          'productLabel',
          'finalMoveLabel',
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
      for (final fieldId in _prototype().blockedOutputFieldIds) {
        expect(_prototype().activeOutputFieldIds, isNot(contains(fieldId)));
      }
    });

    test('packet flags are safe by default', () {
      for (final packet in _prototype().packets) {
        expect(packet.isProductOutput, isFalse);
        expect(packet.isClassifierLabel, isFalse);
        expect(packet.isOfficialMetric, isFalse);
        expect(packet.hasNumericScore, isFalse);
        expect(packet.ranksMoves, isFalse);
        expect(packet.callsEngine, isFalse);
        expect(packet.writesPersistence, isFalse);
        expect(packet.targetsUi, isFalse);
      }
    });

    test('proof and owner boundaries hold', () {
      expect(
        _prototype().androidProofCaseIds,
        orderedEquals(_provenAndroidIds),
      );
      expect(_prototype().ownerProofQueueCount, 0);

      for (final caseId in _phase32ECaseIdsSorted) {
        expect(_prototype().androidProofCaseIds, isNot(contains(caseId)));
        for (final packet in _prototype().packets) {
          expect(packet.androidProofCaseIds, isNot(contains(caseId)));
        }
      }
    });
  });

  group('InternalEvidenceAdapterPrototypeValidator', () {
    test(
      'rejects unproven Android proof and Phase 32E captured proof claims',
      () {
        final unproven = _prototype().copyWith(
          androidProofCaseIds: <String>[
            ..._prototype().androidProofCaseIds,
            'unproven-android-proof',
          ],
        );
        final phase32E = _withPacket(
          'packet-proofLimitedSummary',
          (packet) => packet.copyWith(
            androidProofCaseIds: <String>[
              ...packet.androidProofCaseIds,
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
      'rejects active labels, values, ordering, metrics, and future metrics',
      () {
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
                _withPacketFlag(
                  (packet) => packet.copyWith(hasNumericScore: true),
                ),
              )
              .map((finding) => finding.id),
          contains('numericScoreOutputActive'),
        );
        expect(
          validator
              .validate(
                _withPacketFlag((packet) => packet.copyWith(ranksMoves: true)),
              )
              .map((finding) => finding.id),
          contains('moveRankingOutputActive'),
        );
        expect(
          validator
              .validate(
                _withPacketFlag(
                  (packet) => packet.copyWith(isOfficialMetric: true),
                ),
              )
              .map((finding) => finding.id),
          contains('officialMetricOutputActive'),
        );
        expect(
          validator
              .validate(
                _withPacketFlag(
                  (packet) => packet.copyWith(cpLossOutputActive: true),
                ),
              )
              .map((finding) => finding.id),
          contains('futureMetricOutputActive'),
        );
        expect(
          validator
              .validate(
                _withPacketFlag(
                  (packet) => packet.copyWith(winProbabilityOutputActive: true),
                ),
              )
              .map((finding) => finding.id),
          contains('futureMetricOutputActive'),
        );
      },
    );

    test(
      'rejects quiet activation, context promotion, and inactive packet activation',
      () {
        final quiet = _withPacketFlag(
          (packet) => packet.copyWith(quietPreparatoryScopeActive: true),
        );
        final contextPromoted = _withPacket(
          'packet-constrainedWatchListSummary',
          (packet) => packet.copyWith(
            adapterRole: InternalEvidenceAdapterPacketRole.coreEvidencePacket,
          ),
        );
        final blockedActive = _withPacket(
          'packet-blockedBoundarySummary',
          (packet) => packet.copyWith(
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        );
        final futureActive = _withPacket(
          'packet-futureOnlySummary',
          (packet) => packet.copyWith(
            activeOutputFieldIds: const <String>['adapterPacketId'],
          ),
        );

        expect(
          _validator().validate(quiet).map((finding) => finding.id),
          contains('quietPreparatoryScopeActivated'),
        );
        expect(
          _validator().validate(contextPromoted).map((finding) => finding.id),
          contains('contextOnlyPacketPromotedToCore'),
        );
        expect(
          _validator().validate(blockedActive).map((finding) => finding.id),
          contains('blockedPacketMadeActive'),
        );
        expect(
          _validator().validate(futureActive).map((finding) => finding.id),
          contains('futureOnlyPacketMadeActive'),
        );
      },
    );

    test('rejects engine, persistence, UI, and owner proof policy seams', () {
      final engine = _withPacketFlag(
        (packet) => packet.copyWith(callsEngine: true),
      );
      final persistence = _withPacketFlag(
        (packet) => packet.copyWith(writesPersistence: true),
      );
      final ui = _withPacketFlag((packet) => packet.copyWith(targetsUi: true));
      final ownerProof = _prototype().copyWith(
        ownerProofQueueCount: 1,
        packets: _prototype().packets
            .map(
              (packet) => packet.copyWith(
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
        _validator().validate(engine).map((finding) => finding.id),
        contains('engineCallFlagActive'),
      );
      expect(
        _validator().validate(persistence).map((finding) => finding.id),
        contains('persistenceWriteFlagActive'),
      );
      expect(
        _validator().validate(ui).map((finding) => finding.id),
        contains('uiTargetFlagActive'),
      );
      expect(
        _validator().validate(ownerProof).map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('normal report text is clean and unsafe report text is rejected', () {
      final validator = _validator();

      expect(
        validator.validateReportText(_prototype().renderMarkdownReport()),
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
            .validateReportText('active fields: productLabel')
            .map((finding) => finding.id),
        contains('activeBlockedFieldReportText'),
      );
    });
  });

  group('Prototype report rendering and guardrails', () {
    test('markdown includes required sections', () {
      final report = _prototype().renderMarkdownReport();

      expect(report, contains('# Internal Evidence Adapter Prototype'));
      expect(report, contains('## Adapter Packet Table'));
      expect(report, contains('## Core Packets'));
      expect(report, contains('## Context-Only Packets'));
      expect(report, contains('## Blocked Output Field Summary'));
      expect(report, contains('## Phase 32O Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _prototype().renderJsonReport();
      final second = _prototype().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalEvidenceAdapterPrototypeReportVersion);
      expect(decoded['prototypeStatus'], 'completedWithWarnings');
      expect(decoded['packets'], isA<List<Object?>>());
      expect(decoded['safeForPhase32O'], isTrue);
    });

    test('reports contain no raw engine or active product-output text', () {
      final report = _prototype().renderMarkdownReport();

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
        'lib/features/pgn_review/application/internal_evidence_adapter_prototype.dart',
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

InternalEvidenceAdapterPrototypeResult _prototype() => _cachedPrototype!;

InternalEvidenceAdapterDesignResult _design() => _cachedDesign!;

InternalEvidenceAdapterPrototypeValidator _validator() {
  return const InternalEvidenceAdapterPrototypeValidator();
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

InternalEvidenceAdapterPrototypeResult _withPacketFlag(
  InternalEvidenceAdapterPacket Function(InternalEvidenceAdapterPacket packet)
  update,
) {
  return _withPacket('packet-allowedEvidenceSummary', update);
}

InternalEvidenceAdapterPrototypeResult _withActiveField(String fieldId) {
  return _prototype().copyWith(
    activeOutputFieldIds: <String>[
      ..._prototype().activeOutputFieldIds,
      fieldId,
    ],
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
