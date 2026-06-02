@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BasicClassifierFoundationDesigner default design', () {
    test('design includes all current golden evidence facts', () {
      final result = _run();

      expect(result.totalCaseCount, 15);
      expect(result.totalCaseCount, GoldenAnalysisCases.defaults.length);
      expect(result.protectedCount, 14);
      expect(result.negativeGuardCount, 1);
      expect(result.incompleteCount, 0);
      expect(result.realDeviceNeededCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(
        result.negativeGuardCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
    });

    test('default decision is developer-only limited prototype design', () {
      final result = _run();

      expect(
        result.status,
        BasicClassifierFoundationStatus.readyForLimitedDeveloperPrototype,
      );
      expect(result.productLabelsReady, isFalse);
      expect(result.advancedLabelsReady, isFalse);
      expect(result.quietPreparatoryScopeAllowed, isFalse);
      expect(result.nonQuietBasicEvidenceDesignAllowed, isTrue);
      expect(result.evidenceContractCompleteForProduct, isFalse);
    });

    test('product and advanced output scopes remain blocked', () {
      final result = _run();

      expect(
        result.scope(BasicClassifierDesignScope.productFacingLabels).status,
        BasicClassifierDesignScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(BasicClassifierDesignScope.advancedBrilliantGate).status,
        BasicClassifierDesignScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(BasicClassifierDesignScope.advancedGreatMoveGate).status,
        BasicClassifierDesignScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(BasicClassifierDesignScope.advancedMissedWinGate).status,
        BasicClassifierDesignScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(BasicClassifierDesignScope.officialMetricAccuracy).status,
        BasicClassifierDesignScopeStatus.blockedByPolicy,
      );
      expect(
        result.scope(BasicClassifierDesignScope.officialMetricAcpl).status,
        BasicClassifierDesignScopeStatus.blockedByPolicy,
      );
    });

    test('quiet preparatory classification scope is excluded by guard', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.quietPreparatoryEvidenceClassification,
      );

      expect(scope.status, BasicClassifierDesignScopeStatus.blockedByEvidence);
      expect(scope.supportingCaseIds, contains('quiet-preparatory-hard-case'));
      expect(
        scope.blockedCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
      expect(scope.blockers.join('\n'), contains('negative guard'));
    });

    test(
      'non-quiet basic design is allowed without quiet preparatory cases',
      () {
        final scope = _run().scope(
          BasicClassifierDesignScope.nonQuietBasicEvidenceDesign,
        );

        expect(
          scope.status,
          BasicClassifierDesignScopeStatus.allowedForDeveloperPrototype,
        );
        expect(
          scope.supportingCaseIds,
          isNot(contains('quiet-preparatory-uncertain')),
        );
        expect(
          scope.supportingCaseIds,
          isNot(contains('quiet-preparatory-hard-case')),
        );
        expect(scope.recommendation, contains('Design only'));
      },
    );
  });

  group('BasicClassifierFoundationDesigner support mapping', () {
    test('tactical evidence design maps to supporting golden cases', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.tacticalEvidenceDesign,
      );

      expect(
        scope.status,
        BasicClassifierDesignScopeStatus.allowedForDeveloperPrototype,
      );
      expect(
        scope.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('material evidence design maps to supporting golden cases', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.materialSwingEvidenceDesign,
      );

      expect(
        scope.supportingCaseIds,
        containsAll([
          'queen-win-major-swing',
          'material-sacrifice-compensation',
          'sacrifice-compensation-hard-case',
        ]),
      );
    });

    test('forcing-line evidence design maps to supporting golden cases', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.forcingLineEvidenceDesign,
      );

      expect(
        scope.supportingCaseIds,
        containsAll([
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
          'simple-tactical-capture-check',
        ]),
      );
    });

    test('king-safety evidence design maps to supporting golden cases', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.kingSafetyEvidenceDesign,
      );

      expect(
        scope.supportingCaseIds,
        containsAll([
          'king-safety-mating-net-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('endgame evidence remains conservative design-only', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.endgameEvidenceDesign,
      );

      expect(
        scope.status,
        BasicClassifierDesignScopeStatus.allowedForDesignOnly,
      );
      expect(
        scope.supportingCaseIds,
        containsAll([
          'technical-endgame-conservative',
          'endgame-precision-hard-case',
        ]),
      );
    });

    test('safety suppression design maps to safety and budget cases', () {
      final scope = _run().scope(
        BasicClassifierDesignScope.safetySuppressionEvidenceDesign,
      );

      expect(
        scope.status,
        BasicClassifierDesignScopeStatus.allowedForDesignOnly,
      );
      expect(
        scope.supportingCaseIds,
        containsAll([
          'invalid-fen-safety',
          'quiet-opening-skip',
          'forced-move-skip',
          'budget-pressure-candidates',
        ]),
      );
    });
  });

  group('BasicClassifierEvidenceContract', () {
    test('contract lists required future input fields', () {
      final contract = _run().evidenceContract;

      expect(
        contract.fields.map((field) => field.field),
        containsAll(BasicClassifierEvidenceField.values),
      );
      expect(
        contract.field(BasicClassifierEvidenceField.cpLossAvailable).available,
        isFalse,
      );
      expect(
        contract
            .field(BasicClassifierEvidenceField.winProbabilityAvailable)
            .available,
        isFalse,
      );
      expect(
        contract
            .field(BasicClassifierEvidenceField.bestMoveEvalAvailable)
            .available,
        isFalse,
      );
      expect(contract.completeForProduct, isFalse);
    });

    test('contract marks existing broad evidence fields as available', () {
      final contract = _run().evidenceContract;

      expect(
        contract
            .field(BasicClassifierEvidenceField.candidateSpreadAvailable)
            .supportingCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
      expect(
        contract.field(BasicClassifierEvidenceField.multiPvAvailable).available,
        isTrue,
      );
      expect(
        contract
            .field(BasicClassifierEvidenceField.materialSwingAvailable)
            .supportingCaseIds,
        contains('queen-win-major-swing'),
      );
      expect(
        contract
            .field(BasicClassifierEvidenceField.negativeGuardScopeExcluded)
            .supportingCaseIds,
        orderedEquals(['quiet-preparatory-uncertain']),
      );
    });

    test('contract does not compute official metrics', () {
      final contract = _run().evidenceContract;

      expect(contract.computesOfficialAccuracy, isFalse);
      expect(contract.computesOfficialAcpl, isFalse);
      expect(
        contract.missingForProduct,
        contains(BasicClassifierEvidenceField.cpLossAvailable),
      );
    });

    test('output policy emits no classifier label families', () {
      final policy = _run().outputPolicy;

      expect(policy.allowedOutputFamilies, contains('scopeReadiness'));
      expect(policy.forbiddenOutputFamilies, contains('moveQualityLabels'));
      expect(
        policy.forbiddenOutputFamilies,
        contains('advancedCandidateLabels'),
      );
      expect(policy.emittedForbiddenOutputFamilies, isEmpty);
      expect(policy.hasViolation, isFalse);
    });
  });

  group('BasicClassifierFoundationDesign reports and guardrails', () {
    test('markdown report is deterministic and includes scopes', () {
      final first = _run().renderMarkdownReport();
      final second = _run().renderMarkdownReport();

      expect(first, second);
      expect(first, contains('# Basic Classifier Foundation Design'));
      expect(first, contains('Allowed Design Scopes'));
      expect(first, contains('Blocked Scopes'));
      expect(first, contains('nonQuietBasicEvidenceDesign'));
      expect(first, contains('quietPreparatoryEvidenceClassification'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], basicClassifierFoundationDesignReportVersion);
      expect(summary['totalCases'], 15);
      expect(summary['protectedCount'], 14);
      expect(summary['negativeGuardCount'], 1);
      expect(decoded['scopes'], isA<List<Object?>>());
      expect(decoded['evidenceContract'], isA<Map<String, Object?>>());
    });

    test('report includes support mapping and negative guard exclusion', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('simple-tactical-capture-check'));
      expect(report, contains('queen-win-major-swing'));
      expect(report, contains('king-safety-mating-net-hard-case'));
      expect(report, contains('quiet-preparatory-uncertain'));
      expect(report, contains('excluded scope'));
    });

    test('report includes next recommended phase', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('Next Recommended Phase'));
      expect(
        report,
        contains(
          'Phase 31B -- Evidence Contract Prototype With Product Labels Blocked',
        ),
      );
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
      final result = _run();
      final report = result.renderMarkdownReport();

      expect(result.outputPolicy.emittedForbiddenOutputFamilies, isEmpty);
      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
      expect(
        report,
        isNot(contains('emitted forbidden output families: finalMoveLabels')),
      );
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_designSource);

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

BasicClassifierFoundationDesignResult _run() {
  return const BasicClassifierFoundationDesigner().evaluate(
    const BasicClassifierFoundationDesignRequest(),
  );
}

String get _designSource => File(
  'lib/features/pgn_review/application/basic_classifier_foundation_design.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
