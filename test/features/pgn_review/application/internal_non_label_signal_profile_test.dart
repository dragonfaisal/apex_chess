@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalNonLabelSignalProfile default profile', () {
    test('includes all expected signal IDs', () {
      final result = _run();

      expect(
        result.status,
        InternalNonLabelSignalProfileStatus.readyWithWarnings,
      );
      expect(result.signalCount, InternalNonLabelSignalId.values.length);
      expect(
        result.signals.map((signal) => signal.signalId).toSet(),
        InternalNonLabelSignalId.values.toSet(),
      );
      expect(result.validationFindings, isEmpty);
      expect(result.guardAllowed, isTrue);
      expect(result.safeForFutureInternalExperiments, isTrue);
    });

    test('tactical signal is active with support cases', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.tacticalPressureSignal,
      );

      expect(signal.status, InternalNonLabelSignalStatus.active);
      expect(
        signal.confidence,
        InternalNonLabelSignalConfidence.highConfidence,
      );
      expect(
        signal.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('material signal is active with support cases', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.materialSwingSignal,
      );

      expect(signal.status, InternalNonLabelSignalStatus.active);
      expect(
        signal.supportingCaseIds,
        containsAll([
          'queen-win-major-swing',
          'sacrifice-compensation-hard-case',
          'material-sacrifice-compensation',
        ]),
      );
    });

    test('forcing-line signal is active with support cases', () {
      final signal = _run().signal(InternalNonLabelSignalId.forcingLineSignal);

      expect(signal.status, InternalNonLabelSignalStatus.active);
      expect(
        signal.supportingCaseIds,
        containsAll([
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
          'king-safety-mating-net-hard-case',
        ]),
      );
    });

    test('candidate-spread signal is active with support cases', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.candidateSpreadSignal,
      );

      expect(signal.status, InternalNonLabelSignalStatus.active);
      expect(
        signal.supportingCaseIds,
        containsAll([
          'simple-tactical-capture-check',
          'forcing-line-variation-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('PV and MultiPV signal is active only with proof-backed evidence', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.pvMultiPvSupportSignal,
      );

      expect(signal.status, InternalNonLabelSignalStatus.active);
      expect(
        signal.supportingCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        signal.androidProofCaseIds,
        orderedEquals(signal.supportingCaseIds),
      );
    });

    test('Android proof confidence signal includes only three proven IDs', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.androidProofConfidenceSignal,
      );

      expect(signal.status, InternalNonLabelSignalStatus.active);
      expect(
        signal.androidProofCaseIds,
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(
        signal.androidProofCaseIds,
        isNot(contains('quiet-preparatory-hard-case')),
      );
      expect(signal.confidenceReason, contains('captured Android proof'));
    });

    test('king-safety signal is active with warnings or partial', () {
      final signal = _run().signal(InternalNonLabelSignalId.kingSafetySignal);

      expect(
        signal.status,
        anyOf(
          InternalNonLabelSignalStatus.activeWithWarnings,
          InternalNonLabelSignalStatus.partial,
        ),
      );
      expect(
        signal.supportingCaseIds,
        containsAll([
          'king-safety-mating-net-hard-case',
          'mate-threat-fast-evidence',
        ]),
      );
    });

    test('endgame signal is active with warnings or partial', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.endgameSupportSignal,
      );

      expect(
        signal.status,
        anyOf(
          InternalNonLabelSignalStatus.activeWithWarnings,
          InternalNonLabelSignalStatus.partial,
        ),
      );
      expect(
        signal.supportingCaseIds,
        containsAll([
          'technical-endgame-conservative',
          'endgame-precision-hard-case',
        ]),
      );
    });

    test('suppression safety signal reflects partial suppression subareas', () {
      final signal = _run().signal(
        InternalNonLabelSignalId.suppressionSafetySignal,
      );

      expect(signal.status, InternalNonLabelSignalStatus.activeWithWarnings);
      expect(signal.confidence, InternalNonLabelSignalConfidence.warningOnly);
      expect(
        signal.supportingCaseIds,
        containsAll([
          'invalid-fen-safety',
          'quiet-opening-skip',
          'forced-move-skip',
          'budget-pressure-candidates',
        ]),
      );
      expect(signal.warningReasons, isNotEmpty);
    });

    test('budget risk signal is partial and warning-only', () {
      final signal = _run().signal(InternalNonLabelSignalId.budgetRiskSignal);

      expect(signal.status, InternalNonLabelSignalStatus.partial);
      expect(signal.confidence, InternalNonLabelSignalConfidence.warningOnly);
      expect(signal.supportingCaseIds, [
        'budget-pressure-candidates',
        'budget-pressure-wide-candidate-32e',
      ]);
    });

    test('quiet preparatory signal is excluded', () {
      final result = _run();
      final signal = result.signal(
        InternalNonLabelSignalId.quietPreparatorySignalExcluded,
      );

      expect(signal.status, InternalNonLabelSignalStatus.excluded);
      expect(signal.confidence, InternalNonLabelSignalConfidence.excluded);
      expect(result.excludedScopeIds, contains('quiet-preparatory-uncertain'));
      expect(signal.futurePrerequisites, isNotEmpty);
    });

    test('product, advanced, and official metric signals are blocked', () {
      final result = _run();

      expect(
        result
            .signal(InternalNonLabelSignalId.productLabelSignalBlocked)
            .status,
        InternalNonLabelSignalStatus.blockedByPolicy,
      );
      expect(
        result
            .signal(InternalNonLabelSignalId.advancedLabelSignalBlocked)
            .status,
        InternalNonLabelSignalStatus.blockedByPolicy,
      );
      expect(
        result
            .signal(InternalNonLabelSignalId.officialMetricSignalBlocked)
            .status,
        InternalNonLabelSignalStatus.blockedByPolicy,
      );
    });

    test('CP-loss and win-probability signals are future-only', () {
      final result = _run();

      expect(
        result.signal(InternalNonLabelSignalId.cpLossSignalFutureOnly).status,
        InternalNonLabelSignalStatus.futureOnly,
      );
      expect(
        result
            .signal(InternalNonLabelSignalId.winProbabilitySignalFutureOnly)
            .status,
        InternalNonLabelSignalStatus.futureOnly,
      );
      expect(result.cpLossComputationImplemented, isFalse);
      expect(result.winProbabilityComputationImplemented, isFalse);
    });

    test(
      'no signal emits labels, scores, ranking, metrics, engine, UI, or storage',
      () {
        final result = _run();

        for (final signal in result.signals) {
          expect(signal.emitsProductLabel, isFalse);
          expect(signal.emitsClassifierLabel, isFalse);
          expect(signal.emitsFinalMoveLabel, isFalse);
          expect(signal.hasNumericMoveScore, isFalse);
          expect(signal.ranksMoves, isFalse);
          expect(signal.claimsOfficialMetrics, isFalse);
        }
        expect(result.productLabelsEmitted, isFalse);
        expect(result.classifierLabelsEmitted, isFalse);
        expect(result.finalMoveLabelsEmitted, isFalse);
        expect(result.officialMetricsAllowed, isFalse);
        expect(result.numericMoveScoresComputed, isFalse);
        expect(result.moveRankingComputed, isFalse);
        expect(result.directEngineAccessUsed, isFalse);
        expect(result.uiOutputUsed, isFalse);
        expect(result.backendOutputUsed, isFalse);
        expect(result.persistenceUsed, isFalse);
        expect(result.hasUnsafeSignalProfilePolicyViolation, isFalse);
      },
    );
  });

  group('InternalNonLabelSignalProfile validator', () {
    test('rejects numeric score output when seam is mutated', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.tacticalPressureSignal,
        (signal) => signal.copyWith(hasNumericMoveScore: true),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('signalEmitsNumericScore'),
      );
    });

    test('rejects product labels when seam is mutated', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.tacticalPressureSignal,
        (signal) => signal.copyWith(emitsProductLabel: true),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('signalEmitsLabel'),
      );
    });

    test('rejects official metric activation', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.officialMetricSignalBlocked,
        (signal) => signal.copyWith(claimsOfficialMetrics: true),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('signalClaimsOfficialMetric'),
      );
    });

    test('rejects quiet activation', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.quietPreparatorySignalExcluded,
        (signal) => signal.copyWith(
          status: InternalNonLabelSignalStatus.active,
          quietScopeActive: true,
        ),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        containsAll(['quietSignalBecameActive', 'quietSignalNotExcluded']),
      );
    });

    test('rejects unproven Android proof support', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.androidProofConfidenceSignal,
        (signal) => signal.copyWith(
          androidProofCaseIds: [
            ...signal.androidProofCaseIds,
            'quiet-preparatory-hard-case',
          ],
        ),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('unprovenAndroidProofSupport'),
      );
    });

    test('rejects active signal without support', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.tacticalPressureSignal,
        (signal) => signal.copyWith(
          supportingCaseIds: const <String>[],
          protectedSupportCaseIds: const <String>[],
          androidProofCaseIds: const <String>[],
        ),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('activeSignalWithoutCases'),
      );
    });

    test('rejects move ranking and forbidden emitted output names', () {
      final mutated = _withSignal(
        _run(),
        InternalNonLabelSignalId.tacticalPressureSignal,
        (signal) => signal.copyWith(
          ranksMoves: true,
          emittedOutputNames: const <String>['finalMoveQuality'],
        ),
      );

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        containsAll(['signalRanksMoves', 'forbiddenSignalOutputName']),
      );
    });

    test('future computation activation is rejected', () {
      final mutated = _run().copyWith(cpLossComputationImplemented: true);

      final findings = const InternalNonLabelSignalProfileValidator().validate(
        mutated,
      );

      expect(
        findings.map((finding) => finding.id),
        contains('profileOutputPolicyViolation'),
      );
    });
  });

  group('InternalNonLabelSignalProfile reports and guardrails', () {
    test('markdown report includes signal table and mapping', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('# Internal Non-Label Signal Profile'));
      expect(report, contains('profile status: readyWithWarnings'));
      expect(report, contains('Signal Table'));
      expect(report, contains('qualitative confidence'));
      expect(report, contains('tacticalPressureSignal'));
      expect(report, contains('tacticalPressureDimension'));
      expect(report, contains('Future Prerequisites'));
      expect(report, contains('quiet-preparatory-uncertain'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalNonLabelSignalProfileReportVersion);
      expect(decoded['profileStatus'], 'readyWithWarnings');
      expect(decoded['signals'], isA<List<Object?>>());
    });

    test('markdown report is deterministic', () {
      expect(_run().renderMarkdownReport(), _run().renderMarkdownReport());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();
      final findings = const InternalNonLabelSignalProfileValidator()
          .validateReportText(report);

      expect(findings, isEmpty);
      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('reports do not emit final labels or official metric names', () {
      final report = _run().renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('reports contain no numeric move score output', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('numeric score values emitted: false'));
      expect(report, isNot(contains('numeric move score:')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('moveScore')));
    });

    test('source imports stay pure and local-only', () {
      final imports = _imports(_profileSource);

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

InternalNonLabelSignalProfileResult _run() {
  return const InternalNonLabelSignalProfilePrototype().evaluate(
    const InternalNonLabelSignalProfileRequest(),
  );
}

InternalNonLabelSignalProfileResult _withSignal(
  InternalNonLabelSignalProfileResult base,
  InternalNonLabelSignalId id,
  InternalNonLabelSignalProfileEntry Function(
    InternalNonLabelSignalProfileEntry,
  )
  update,
) {
  return base.copyWith(
    signals: [
      for (final signal in base.signals)
        if (signal.signalId == id) update(signal) else signal,
    ],
  );
}

String get _profileSource => File(
  'lib/features/pgn_review/application/internal_non_label_signal_profile.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
