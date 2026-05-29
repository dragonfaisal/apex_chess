import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/deep_gating_budget_tuning.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepGatingBudgetTuning scenarios and matrix', () {
    test('representative scenarios have unique ids', () {
      final ids = DeepGatingRepresentativeGames.defaults
          .map((scenario) => scenario.id)
          .toList();

      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, contains('quiet-opening-heavy'));
      expect(ids, contains('tactical-middlegame'));
      expect(ids, contains('budget-pressure'));
    });

    test('tuning matrix includes eco balanced performance and owner', () {
      final profileIds = DeepGatingBudgetProfileMatrix.defaultRuns
          .map((run) => run.profile.id)
          .toSet();

      expect(profileIds, contains(LocalSchedulerProfileId.eco));
      expect(profileIds, contains(LocalSchedulerProfileId.balanced));
      expect(profileIds, contains(LocalSchedulerProfileId.performance));
      expect(profileIds, contains(LocalSchedulerProfileId.owner));
      expect(
        DeepGatingBudgetProfileMatrix.defaultRuns.any((run) => run.lowPower),
        isTrue,
      );
    });

    test('empty scenario set returns safe empty result', () {
      final result = const DeepGatingBudgetTuningRunner().run(
        const DeepGatingBudgetTuningRequest(scenarios: []),
      );

      expect(result.status, DeepGatingBudgetTuningStatus.empty);
      expect(result.scenarioCount, 0);
      expect(result.totalPositionsConsidered, 0);
      expect(result.candidatesSelected, 0);
      expect(result.observations.single, contains('no representative'));
    });
  });

  group('DeepGatingBudgetTuning scenario behavior', () {
    test('quiet opening-heavy scenario does not select every position', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.quietOpeningHeavy,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
        ),
      );

      expect(summary.positionsConsidered, 5);
      expect(summary.candidatesSelected, 0);
      expect(summary.selectedDeepRatio, lessThan(1));
      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.openingSuppressed],
        3,
      );
    });

    test('tactical scenario selects candidates when evidence supports it', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.tacticalMiddlegame,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
        ),
      );

      expect(summary.candidatesGenerated, greaterThanOrEqualTo(3));
      expect(summary.candidatesSelected, greaterThanOrEqualTo(1));
      expect(
        summary.topReasonCounts[DeepCandidateReasonCode.materialSwing],
        greaterThanOrEqualTo(1),
      );
      expect(
        summary.topReasonCounts[DeepCandidateReasonCode.majorEvalSwing],
        greaterThanOrEqualTo(1),
      );
    });

    test('technical endgame scenario remains conservative', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.endgameTechnical,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
        ),
      );

      expect(summary.candidatesGenerated, 0);
      expect(summary.candidatesSelected, 0);
      expect(
        summary.recommendation,
        DeepGatingScenarioTuningRecommendation.budgetLooksSafe,
      );
    });

    test('eco profile suppresses deep candidates', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.tacticalMiddlegame,
        const DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.eco),
      );

      expect(summary.candidatesGenerated, 0);
      expect(summary.candidatesSelected, 0);
      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.profileSuppressed],
        greaterThan(0),
      );
    });

    test('low-power run suppresses deep candidates', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.lowPowerSuppression,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
          lowPower: true,
        ),
      );

      expect(summary.candidatesSelected, 0);
      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.lowPowerSuppressed],
        greaterThan(0),
      );
      expect(
        summary.recommendation,
        DeepGatingScenarioTuningRecommendation.lowPowerSuppressedAsExpected,
      );
    });

    test('balanced selects fewer or equal candidates than owner', () {
      final result = const DeepGatingBudgetTuningRunner().run(
        const DeepGatingBudgetTuningRequest(
          scenarios: [DeepGatingRepresentativeGames.tacticalMiddlegame],
          profileRuns: [
            DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.balanced),
            DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.owner),
          ],
        ),
      );
      final balanced = result.scenarioSummaries.firstWhere(
        (summary) => summary.profileId.startsWith('balanced'),
      );
      final owner = result.scenarioSummaries.firstWhere(
        (summary) => summary.profileId.startsWith('owner'),
      );

      expect(
        balanced.candidatesSelected,
        lessThanOrEqualTo(owner.candidatesSelected),
      );
    });

    test('owner still does not select every move by default', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.tacticalMiddlegame,
        const DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.owner),
      );

      expect(summary.candidatesSelected, lessThan(summary.positionsConsidered));
      expect(summary.selectedDeepRatio, lessThan(1));
    });

    test('budget pressure scenario reports budget pressure clearly', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.budgetPressure,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
        ),
      );

      expect(
        summary.budgetStatus,
        DeepGatingScenarioBudgetStatus.budgetPressure,
      );
      expect(
        summary.recommendation,
        DeepGatingScenarioTuningRecommendation.blockedByBudget,
      );
      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.budgetSuppressed],
        greaterThan(0),
      );
    });

    test('mixed invalid scenario suppresses invalid FEN safely', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.mixedInvalidSafety,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
        ),
      );

      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.invalidFenSuppressed],
        1,
      );
    });

    test('opening-known and forced positions are suppressed from deep', () {
      final summary = _singleSummary(
        DeepGatingRepresentativeGames.mixedInvalidSafety,
        const DeepGatingTuningProfileRun(
          profile: LocalSchedulerProfile.balanced,
        ),
      );

      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.openingSuppressed],
        1,
      );
      expect(
        summary.suppressionCounts[DeepCandidateReasonCode.forcedSuppressed],
        1,
      );
    });
  });

  group('DeepGatingBudgetTuning aggregate telemetry', () {
    test('selectedDeepRatio is deterministic', () {
      final runner = const DeepGatingBudgetTuningRunner();
      final request = const DeepGatingBudgetTuningRequest(
        scenarios: [DeepGatingRepresentativeGames.tacticalMiddlegame],
        profileRuns: [
          DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.balanced),
        ],
      );

      final first = runner.run(request);
      final second = runner.run(request);

      expect(first.selectedDeepRatio, second.selectedDeepRatio);
      expect(
        first.scenarioSummaries.single.debugSummary,
        second.scenarioSummaries.single.debugSummary,
      );
    });

    test('suppression counts are aggregated correctly', () {
      final result = const DeepGatingBudgetTuningRunner().run(
        const DeepGatingBudgetTuningRequest(
          scenarios: [DeepGatingRepresentativeGames.mixedInvalidSafety],
          profileRuns: [
            DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.balanced),
          ],
        ),
      );

      expect(
        result.suppressionsByReason[DeepCandidateReasonCode
            .invalidFenSuppressed],
        1,
      );
      expect(
        result.suppressionsByReason[DeepCandidateReasonCode.openingSuppressed],
        1,
      );
      expect(
        result.suppressionsByReason[DeepCandidateReasonCode.forcedSuppressed],
        1,
      );
    });

    test('reason-code counts are aggregated correctly', () {
      final result = const DeepGatingBudgetTuningRunner().run(
        const DeepGatingBudgetTuningRequest(
          scenarios: [DeepGatingRepresentativeGames.tacticalMiddlegame],
          profileRuns: [
            DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.balanced),
          ],
        ),
      );

      expect(
        result.reasonCounts[DeepCandidateReasonCode.materialSwing],
        greaterThanOrEqualTo(1),
      );
      expect(
        result.reasonCounts[DeepCandidateReasonCode.candidateEvalSpread],
        greaterThanOrEqualTo(1),
      );
      expect(result.estimatedEngineCalls, greaterThan(0));
      expect(result.multiPvDeepCount, greaterThan(0));
    });

    test('default representative run renders completed report', () {
      final result = const DeepGatingBudgetTuningRunner().run(
        const DeepGatingBudgetTuningRequest(
          scenarios: DeepGatingRepresentativeGames.defaults,
        ),
      );

      expect(
        result.scenarioCount,
        DeepGatingRepresentativeGames.defaults.length,
      );
      expect(
        result.profileRunCount,
        DeepGatingBudgetProfileMatrix.defaultRuns.length,
      );
      expect(result.totalPositionsConsidered, greaterThan(0));
      expect(result.budgetViolations, greaterThan(0));
      expect(result.timeouts, 0);
    });
  });

  group('DeepGatingBudgetTuning reports and guardrails', () {
    test('report renderer is deterministic', () {
      final result = const DeepGatingBudgetTuningRunner().run(
        const DeepGatingBudgetTuningRequest(
          scenarios: [DeepGatingRepresentativeGames.tacticalMiddlegame],
          profileRuns: [
            DeepGatingTuningProfileRun(profile: LocalSchedulerProfile.balanced),
          ],
        ),
      );

      expect(result.renderMarkdownReport(), result.renderMarkdownReport());
      expect(
        result.renderMarkdownReport(),
        contains('Deep Gating Budget Tuning'),
      );
      expect(result.renderMarkdownReport(), contains('tactical-middlegame'));
    });

    test('report contains no raw engine spam or PV dumps', () {
      final report = const DeepGatingBudgetTuningRunner()
          .run(
            const DeepGatingBudgetTuningRequest(
              scenarios: DeepGatingRepresentativeGames.defaults,
            ),
          )
          .renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains('e2e4 e7e5')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('report contains no final labels or official metric text', () {
      final report = const DeepGatingBudgetTuningRunner()
          .run(
            const DeepGatingBudgetTuningRequest(
              scenarios: DeepGatingRepresentativeGames.defaults,
            ),
          )
          .renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('source avoids forbidden layers and project markers', () {
      final source = File(
        'lib/features/pgn_review/application/deep_gating_budget_tuning.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, contains('game_level_deep_gating_experiment.dart'));
      expect(imports, isNot(contains('local_eval_service.dart')));
      expect(imports, isNot(contains('stockfish')));
      expect(imports, isNot(contains('ffi')));
      expect(imports, isNot(contains('native')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('database')));
      expect(source, isNot(contains('MoveQuality')));
      expect(source, isNot(contains('Brilliant')));
      expect(source, isNot(contains('Great')));
      expect(source, isNot(contains('Miss')));
      expect(source, isNot(contains('ACPL')));
      expect(source, isNot(contains('accuracy')));
      expect(source, isNot(contains('Chesskit')));
      expect(source, isNot(contains('DroidFish')));
      expect(source, isNot(contains('StockfishForFlutter')));
      expect(source, isNot(contains('python-chess')));
    });
  });
}

DeepGatingScenarioTuningSummary _singleSummary(
  DeepGatingRepresentativeGame scenario,
  DeepGatingTuningProfileRun run,
) {
  return const DeepGatingBudgetTuningRunner()
      .run(
        DeepGatingBudgetTuningRequest(
          scenarios: [scenario],
          profileRuns: [run],
        ),
      )
      .scenarioSummaries
      .single;
}
