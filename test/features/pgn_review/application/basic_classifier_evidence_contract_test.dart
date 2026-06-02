@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_policy.dart';
import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BasicClassifierEvidenceContract default prototype', () {
    test('contract includes all current golden evidence facts', () {
      final result = _run();

      expect(result.totalCaseCount, 15);
      expect(result.totalCaseCount, GoldenAnalysisCases.defaults.length);
      expect(result.protectedCount, 14);
      expect(result.negativeGuardCount, 1);
      expect(result.incompleteCount, 0);
      expect(result.realDeviceNeededCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.capturedAndroidProofCount, 3);
      expect(
        result.negativeGuardCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
      expect(
        result.status,
        BasicClassifierEvidenceContractStatus
            .readyForDeveloperEvidencePrototype,
      );
      expect(result.readyForPhase31C, isTrue);
    });

    test('contract includes all required evidence fields', () {
      final result = _run();

      expect(
        result.fields.map((field) => field.field),
        containsAll(BasicClassifierContractField.values),
      );
      expect(
        result.fields.map((field) => field.field).toSet().length,
        BasicClassifierContractField.values.length,
      );
    });

    test(
      'product and future metric fields stay blocked or not implemented',
      () {
        final result = _run();

        expect(
          result
              .field(BasicClassifierContractField.productLabelOutputAvailable)
              .status,
          BasicClassifierEvidenceFieldStatus.blockedByPolicy,
        );
        expect(
          result
              .field(BasicClassifierContractField.officialAccuracyAvailable)
              .status,
          BasicClassifierEvidenceFieldStatus.blockedByPolicy,
        );
        expect(
          result
              .field(BasicClassifierContractField.officialAcplAvailable)
              .status,
          BasicClassifierEvidenceFieldStatus.blockedByPolicy,
        );
        expect(
          result.field(BasicClassifierContractField.cpLossAvailable).status,
          BasicClassifierEvidenceFieldStatus.notImplemented,
        );
        expect(
          result
              .field(BasicClassifierContractField.winProbabilityAvailable)
              .status,
          BasicClassifierEvidenceFieldStatus.notImplemented,
        );
        expect(
          result
              .field(BasicClassifierContractField.productLabelOutputAvailable)
              .isPresent,
          isFalse,
        );
        expect(
          result.field(BasicClassifierContractField.cpLossAvailable).isPresent,
          isFalse,
        );
        expect(
          result
              .field(BasicClassifierContractField.winProbabilityAvailable)
              .isPresent,
          isFalse,
        );
      },
    );

    test('quiet preparatory scope is excluded by negative guard', () {
      final result = _run();
      final group = result.group(
        BasicClassifierEvidenceGroup.quietPreparatoryEvidence,
      );

      expect(group.readiness, BasicClassifierEvidenceGroupReadiness.excluded);
      expect(group.supportingCaseIds, contains('quiet-preparatory-hard-case'));
      expect(
        group.blockerCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
      expect(
        result.excludedScopes,
        contains('quietPreparatoryEvidenceClassification'),
      );
      expect(
        result
            .field(BasicClassifierContractField.negativeGuardScopeExcluded)
            .blockers,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
    });
  });

  group('BasicClassifierEvidenceContract support mapping', () {
    test('tactical group maps to supporting protected golden cases', () {
      final result = _run();
      final group = result.group(BasicClassifierEvidenceGroup.tacticalEvidence);

      expect(
        group.readiness,
        BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence,
      );
      expect(
        group.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
      expect(
        result
            .field(BasicClassifierContractField.captureOrPromotionAvailable)
            .supportingCaseIds,
        contains('simple-tactical-capture-check'),
      );
      expect(
        result
            .field(BasicClassifierContractField.givesCheckAvailable)
            .supportingCaseIds,
        contains('mate-threat-fast-evidence'),
      );
    });

    test('material group maps to supporting protected golden cases', () {
      final group = _run().group(BasicClassifierEvidenceGroup.materialEvidence);

      expect(
        group.readiness,
        BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence,
      );
      expect(
        group.supportingCaseIds,
        containsAll([
          'queen-win-major-swing',
          'material-sacrifice-compensation',
          'sacrifice-compensation-hard-case',
        ]),
      );
    });

    test('forcing group maps to supporting protected golden cases', () {
      final group = _run().group(BasicClassifierEvidenceGroup.forcingEvidence);

      expect(
        group.readiness,
        BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence,
      );
      expect(
        group.supportingCaseIds,
        containsAll([
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('king-safety group maps to supporting protected golden cases', () {
      final group = _run().group(
        BasicClassifierEvidenceGroup.kingSafetyEvidence,
      );

      expect(
        group.readiness,
        BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence,
      );
      expect(
        group.supportingCaseIds,
        containsAll([
          'king-safety-mating-net-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('safety group maps to suppression protected golden cases', () {
      final group = _run().group(
        BasicClassifierEvidenceGroup.safetySuppressionEvidence,
      );

      expect(
        group.readiness,
        BasicClassifierEvidenceGroupReadiness.readyForDeveloperEvidence,
      );
      expect(
        group.supportingCaseIds,
        containsAll([
          'invalid-fen-safety',
          'quiet-opening-skip',
          'forced-move-skip',
          'budget-pressure-candidates',
          'quiet-preparatory-uncertain',
        ]),
      );
    });

    test('evaluation group is partial because eval inputs are future-only', () {
      final group = _run().group(
        BasicClassifierEvidenceGroup.evaluationAvailability,
      );

      expect(group.readiness, BasicClassifierEvidenceGroupReadiness.partial);
      expect(
        group.supportingCaseIds,
        containsAll([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        group.fieldIds,
        containsAll([
          BasicClassifierContractField.previousEvalAvailable,
          BasicClassifierContractField.playedMoveEvalAvailable,
          BasicClassifierContractField.bestMoveEvalAvailable,
          BasicClassifierContractField.pvAvailable,
          BasicClassifierContractField.multiPvAvailable,
        ]),
      );
    });
  });

  group('BasicClassifierEvidenceContract validator', () {
    test('evidence group cannot be ready without support cases', () {
      final base = _run();
      final mutated = base.copyWith(
        groups: [
          for (final group in base.groups)
            if (group.group == BasicClassifierEvidenceGroup.tacticalEvidence)
              group.copyWith(
                readiness: BasicClassifierEvidenceGroupReadiness
                    .readyForDeveloperEvidence,
                supportingCaseIds: const <String>[],
              )
            else
              group,
        ],
      );

      final findings = const BasicClassifierEvidenceContractValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('readyGroupWithoutSupport'),
      );
    });

    test(
      'fake proof is not treated as Android proof for real-proof fields',
      () {
        final result = _run(proof: _hostOnlyProofForMateThreat);

        expect(result.capturedAndroidProofCount, 0);
        expect(
          result.field(BasicClassifierContractField.pvAvailable).status,
          BasicClassifierEvidenceFieldStatus.missing,
        );
        expect(
          result.field(BasicClassifierContractField.multiPvAvailable).status,
          BasicClassifierEvidenceFieldStatus.missing,
        );
        expect(result.validationFindings, isEmpty);
      },
    );

    test('validator rejects product output availability', () {
      final base = _run();
      final mutated = base.copyWith(
        fields: [
          for (final field in base.fields)
            if (field.field ==
                BasicClassifierContractField.productLabelOutputAvailable)
              field.copyWith(status: BasicClassifierEvidenceFieldStatus.present)
            else
              field,
        ],
      );

      final findings = const BasicClassifierEvidenceContractValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('blockedFieldPresent'),
      );
    });

    test('validator rejects official metric availability', () {
      final base = _run();
      final mutated = base.copyWith(
        fields: [
          for (final field in base.fields)
            if (field.field ==
                    BasicClassifierContractField.officialAccuracyAvailable ||
                field.field ==
                    BasicClassifierContractField.officialAcplAvailable)
              field.copyWith(status: BasicClassifierEvidenceFieldStatus.present)
            else
              field,
        ],
      );

      final findings = const BasicClassifierEvidenceContractValidator()
          .validate(mutated);

      expect(
        findings.where((finding) => finding.id == 'blockedFieldPresent'),
        hasLength(2),
      );
    });

    test('validator rejects quiet scope availability', () {
      final base = _run();
      final mutated = base.copyWith(
        groups: [
          for (final group in base.groups)
            if (group.group ==
                BasicClassifierEvidenceGroup.quietPreparatoryEvidence)
              group.copyWith(
                readiness: BasicClassifierEvidenceGroupReadiness
                    .readyForDeveloperEvidence,
                supportingCaseIds: ['quiet-preparatory-hard-case'],
              )
            else
              group,
        ],
      );

      final findings = const BasicClassifierEvidenceContractValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('quietScopeAllowed'),
      );
    });

    test('validator rejects emitted forbidden output families', () {
      final base = _run();
      final findings = const BasicClassifierEvidenceContractValidator()
          .validate(
            base.copyWith(
              emittedOutputFamilies: const <String>['productLabelOutput'],
            ),
          );

      expect(
        findings.map((finding) => finding.id),
        contains('forbiddenOutputEmitted'),
      );
    });

    test('validator rejects unproven real-device support citations', () {
      final base = _run();
      final mutated = base.copyWith(
        fields: [
          for (final field in base.fields)
            if (field.field == BasicClassifierContractField.pvAvailable)
              field.copyWith(supportingCaseIds: ['quiet-preparatory-hard-case'])
            else
              field,
        ],
      );

      final findings = const BasicClassifierEvidenceContractValidator()
          .validate(mutated);

      expect(
        findings.map((finding) => finding.id),
        contains('unprovenRealDeviceProof'),
      );
    });
  });

  group('BasicClassifierEvidenceContract reports and guardrails', () {
    test('markdown report is deterministic and includes field table', () {
      final first = _run().renderMarkdownReport();
      final second = _run().renderMarkdownReport();

      expect(first, second);
      expect(first, contains('# Basic Classifier Evidence Contract Prototype'));
      expect(first, contains('Evidence Field Table'));
      expect(first, contains('Evidence Group Readiness'));
      expect(first, contains('Support Mapping'));
      expect(first, contains('Blocked And Future Fields'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], basicClassifierEvidenceContractReportVersion);
      expect(summary['totalCases'], 15);
      expect(summary['protectedCount'], 14);
      expect(summary['negativeGuardCount'], 1);
      expect(decoded['fields'], isA<List<Object?>>());
      expect(decoded['groups'], isA<List<Object?>>());
      expect(
        decoded['nextRecommendedPhase'],
        'Phase 31C -- Internal Non-Label Bucket Design',
      );
    });

    test('report includes quiet exclusion and supporting case IDs', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('quiet-preparatory-uncertain'));
      expect(report, contains('quiet-preparatory-hard-case'));
      expect(report, contains('simple-tactical-capture-check'));
      expect(report, contains('queen-win-major-swing'));
      expect(report, contains('king-safety-mating-net-hard-case'));
    });

    test('report contains no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('report does not emit final labels or official metrics', () {
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
      final imports = _imports(_contractSource);

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

BasicClassifierEvidenceContractPrototype _run({
  GoldenAndroidProofEvidence? proof =
      GoldenAndroidProofEvidence.phase30uS22Ultra,
}) {
  return const BasicClassifierEvidenceContractBuilder().evaluate(
    BasicClassifierEvidenceContractRequest(androidProofEvidence: proof),
  );
}

String get _contractSource => File(
  'lib/features/pgn_review/application/basic_classifier_evidence_contract.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _hostOnlyProofForMateThreat = GoldenAndroidProofEvidence(
  proofVersion: goldenAndroidProofEvidenceVersion,
  sourceId: 'host-only-fake-proof',
  sourceNote: 'fake proof must not satisfy real-device proof',
  deviceFamily: 'host',
  deviceModel: 'host',
  platform: 'host',
  abi: 'x64',
  engineIdentity: 'fake-engine',
  stubIdentityDetected: false,
  runs: <GoldenAndroidProofRunEvidence>[
    GoldenAndroidProofRunEvidence(
      preset: 'balancedDefault',
      status: 'completedWithWarnings',
      targetCaseCount: 1,
      executedTargetCount: 1,
      selectedDeepCount: 1,
      executedDeepCount: 1,
      fastEngineCalls: 1,
      deepEngineCalls: 1,
      totalEngineCalls: 2,
      elapsedMs: 100,
      timeoutCount: 0,
      warningCount: 0,
      failureCount: 0,
      budgetPressureCount: 0,
      missingPvCount: 0,
      insufficientMultiPvCount: 0,
      warnings: <String>[],
      failures: <String>[],
      caseRows: <GoldenAndroidProofCaseEvidence>[
        GoldenAndroidProofCaseEvidence(
          caseId: 'mate-threat-fast-evidence',
          preset: 'balancedDefault',
          proofStatus: 'proofCaptured',
          selectedDeepCount: 1,
          executedDeepCount: 1,
          pvPresent: true,
          multiPvLineCount: 3,
          reasonCodeCounts: <DeepCandidateReasonCode, int>{
            DeepCandidateReasonCode.candidateEvalSpread: 1,
            DeepCandidateReasonCode.givesCheck: 1,
            DeepCandidateReasonCode.tacticalSignal: 1,
          },
          warnings: <String>[],
          failures: <String>[],
          nextAction: 'ignoreFakeProof',
        ),
      ],
    ),
  ],
);
