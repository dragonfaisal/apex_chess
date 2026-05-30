@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/pgn_review/application/game_level_deep_gating_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/golden_owner_android_proof_queue.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_integration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_review_orchestration_experiment.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_executor.dart';
import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldenOwnerAndroidProofQueueRequest', () {
    test('default request uses triage queue IDs', () {
      const request = GoldenOwnerAndroidProofQueueRequest();

      expect(
        request.resolveTargetCaseIds(),
        orderedEquals([
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
    });

    test('default request is balanced-only and conservative', () {
      const request = GoldenOwnerAndroidProofQueueRequest();

      expect(request.maxTargets, 3);
      expect(request.maxTotalEngineCalls, lessThanOrEqualTo(24));
      expect(request.maxTotalElapsedBudgetMs, lessThanOrEqualTo(30000));
      expect(request.includePerformance, isFalse);
      expect(request.budgetPresets(), hasLength(1));
      expect(
        request.budgetPresets().single.id,
        LocalReviewIntegrationBudgetPresetId.balancedDefault,
      );
    });

    test('performance is excluded unless explicit', () {
      const defaultRequest = GoldenOwnerAndroidProofQueueRequest();
      const performanceRequest = GoldenOwnerAndroidProofQueueRequest(
        includePerformance: true,
      );

      expect(
        defaultRequest.budgetPresets().map((preset) => preset.id),
        isNot(
          contains(LocalReviewIntegrationBudgetPresetId.performanceMeasured),
        ),
      );
      expect(
        performanceRequest.budgetPresets().map((preset) => preset.id),
        contains(LocalReviewIntegrationBudgetPresetId.performanceMeasured),
      );
    });

    test('max target count is respected', () {
      const request = GoldenOwnerAndroidProofQueueRequest(maxTargets: 2);

      expect(request.resolveTargetCaseIds(), hasLength(2));
    });

    test('proof queue excludes protected cases', () {
      const request = GoldenOwnerAndroidProofQueueRequest();

      expect(
        request.resolveTargetCaseIds(),
        isNot(contains('quiet-opening-skip')),
      );
      expect(
        request.resolveTargetCaseIds(),
        isNot(contains('technical-endgame-conservative')),
      );
    });
  });

  group('GoldenOwnerAndroidProofQueueCollector', () {
    test('unsupported mapping becomes proofSkipped, not crash', () async {
      final unsupported = _caseById('mate-threat-fast-evidence').copyWith(
        id: 'unsupported-proof-case',
        inputs: const <LocalAnalysisPositionInput>[],
      );
      final result =
          await _collector(_FakeLocalEvalService(), cases: [unsupported]).run(
            const GoldenOwnerAndroidProofQueueRequest(
              targetCaseIds: ['unsupported-proof-case'],
            ),
            engineIdentityProvider: () => 'apex-local-engine',
          );

      expect(
        result.summaries.single.status,
        GoldenOwnerAndroidProofCaseStatus.proofSkipped,
      );
      expect(
        result.status,
        GoldenOwnerAndroidProofQueueStatus.completedWithWarnings,
      );
      expect(
        result.summaries.single.warnings.join('\n'),
        contains('no scheduler'),
      );
    });

    test('missing PV becomes warning and proofIncomplete', () async {
      final result = await _collector(_FakeLocalEvalService(missingPv: true))
          .run(
            const GoldenOwnerAndroidProofQueueRequest(
              targetCaseIds: ['mate-threat-fast-evidence'],
            ),
            engineIdentityProvider: () => 'apex-local-engine',
          );

      final summary = result.summaries.single;
      expect(summary.status, GoldenOwnerAndroidProofCaseStatus.proofIncomplete);
      expect(summary.pvPresent, isFalse);
      expect(summary.warnings.join('\n'), contains('PV presence'));
      expect(result.missingPvCount, 1);
    });

    test('insufficient MultiPV becomes warning', () async {
      final result =
          await _collector(_FakeLocalEvalService(maxReturnedMultiPv: 1)).run(
            const GoldenOwnerAndroidProofQueueRequest(
              targetCaseIds: ['queen-win-major-swing'],
            ),
            engineIdentityProvider: () => 'apex-local-engine',
          );

      final summary = result.summaries.single;
      expect(summary.status, GoldenOwnerAndroidProofCaseStatus.proofIncomplete);
      expect(summary.warnings.join('\n'), contains('insufficient MultiPV'));
      expect(result.insufficientMultiPvCount, 1);
    });

    test('budget pressure is surfaced', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const GoldenOwnerAndroidProofQueueRequest(
          targetCaseIds: ['budget-pressure-candidates'],
          maxTotalEngineCalls: 12,
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );

      expect(result.budgetPressureCount, greaterThanOrEqualTo(1));
      expect(result.renderMarkdownReport(), contains('budget pressure'));
    });

    test('cap reached becomes a visible warning', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const GoldenOwnerAndroidProofQueueRequest(
          targetCaseIds: ['simple-tactical-capture-check'],
          maxTotalEngineCalls: 1,
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );

      expect(
        result.status,
        GoldenOwnerAndroidProofQueueStatus.completedWithWarnings,
      );
      expect(result.warnings.join('\n'), contains('cap'));
    });

    test('stub identity is rejected if visible in result metadata', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const GoldenOwnerAndroidProofQueueRequest(
          targetCaseIds: ['simple-tactical-capture-check'],
        ),
        engineIdentityProvider: () => 'ApexChess-Stub',
      );

      expect(result.stubIdentityDetected, isTrue);
      expect(result.status, GoldenOwnerAndroidProofQueueStatus.failed);
      expect(result.failures.join('\n'), contains('stub identity'));
    });
  });

  group('GoldenOwnerAndroidProofQueue reports and guardrails', () {
    test('report renderer is deterministic', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const GoldenOwnerAndroidProofQueueRequest(
          targetCaseIds: ['simple-tactical-capture-check'],
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );

      expect(result.renderMarkdownReport(), result.renderMarkdownReport());
      expect(
        result.renderMarkdownReport(),
        contains('Golden Owner Android Proof Queue'),
      );
    });

    test('json renderer is valid and deterministic', () async {
      final result = await _collector(_FakeLocalEvalService()).run(
        const GoldenOwnerAndroidProofQueueRequest(
          targetCaseIds: ['simple-tactical-capture-check'],
        ),
        engineIdentityProvider: () => 'apex-local-engine',
      );
      final first = result.renderJson();
      final second = result.renderJson();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['status'], result.status.wire);
      expect(decoded['summaries'], isA<List<Object?>>());
    });

    test('report contains no raw UCI spam', () async {
      final report = await _safeReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
    });

    test('report contains no PV dumps', () async {
      final report = await _safeReport();

      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('report contains no final quality labels', () async {
      final report = await _safeReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
    });

    test('report contains no official metric text', () async {
      final report = await _safeReport();

      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('integration test source is opt-in guarded', () {
      final source = File(
        'integration_test/golden_owner_android_proof_queue_test.dart',
      ).readAsStringSync();

      expect(source, contains(goldenOwnerAndroidProofQueueFlag));
      expect(source, contains('markTestSkipped'));
      expect(source, contains('Platform.isAndroid'));
    });

    test('integration test does not run engine without opt-in flag', () {
      final source = File(
        'integration_test/golden_owner_android_proof_queue_test.dart',
      ).readAsStringSync();

      expect(
        source.indexOf('if (!isGoldenOwnerAndroidProofQueueEnabled())'),
        lessThan(source.indexOf('StockfishEngine(')),
      );
    });

    test(
      'application model has no direct Stockfish, FFI, or native imports',
      () {
        final imports = _imports(_modelSource);

        expect(imports, isNot(contains('Stockfish')));
        expect(imports, isNot(contains('stockfish')));
        expect(imports, isNot(contains('dart:ffi')));
        expect(imports, isNot(contains('native')));
        expect(imports, isNot(contains('local_eval_service.dart')));
      },
    );

    test('application model has no UI or widget imports', () {
      final imports = _imports(_modelSource);

      expect(imports, isNot(contains('package:flutter/material.dart')));
      expect(imports, isNot(contains('package:flutter/widgets.dart')));
      expect(imports, isNot(contains('Widget')));
    });

    test('application model has no backend, preflight, or server imports', () {
      final imports = _imports(_modelSource);

      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
    });

    test(
      'application model has no persistence, cache, or database imports',
      () {
        final imports = _imports(_modelSource);

        expect(imports, isNot(contains('persistence')));
        expect(imports, isNot(contains('cache')));
        expect(imports, isNot(contains('database')));
        expect(imports, isNot(contains('shared_preferences')));
        expect(imports, isNot(contains('hive')));
      },
    );
  });
}

Future<String> _safeReport() async {
  final result = await _collector(_FakeLocalEvalService()).run(
    const GoldenOwnerAndroidProofQueueRequest(
      targetCaseIds: ['simple-tactical-capture-check'],
    ),
    engineIdentityProvider: () => 'apex-local-engine',
  );
  return result.renderMarkdownReport();
}

GoldenOwnerAndroidProofQueueCollector _collector(
  _FakeLocalEvalService eval, {
  List<GoldenAnalysisCase> cases = GoldenAnalysisCases.defaults,
}) {
  return GoldenOwnerAndroidProofQueueCollector(
    cases: cases,
    integration: LocalReviewIntegrationExperiment(
      deepGating: GameLevelDeepGatingExperiment(
        orchestration: LocalReviewOrchestrationExperiment(
          measuredReview: MeasuredLocalReviewPrototype(
            executor: LocalSmartAnalysisExecutor(eval: eval),
          ),
        ),
      ),
    ),
  );
}

GoldenAnalysisCase _caseById(String id) {
  return GoldenAnalysisCases.defaults.singleWhere((item) => item.id == id);
}

String get _modelSource => File(
  'lib/features/pgn_review/application/golden_owner_android_proof_queue.dart',
).readAsStringSync();

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

class _FakeLocalEvalService extends LocalEvalService {
  _FakeLocalEvalService({this.missingPv = false, this.maxReturnedMultiPv})
    : super(engine: _NoopChessEngine());

  final bool missingPv;
  final int? maxReturnedMultiPv;
  var _activeCalls = 0;
  var maxConcurrentCalls = 0;

  @override
  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? movetime,
    Duration? timeout,
    int multiPv = 1,
  }) async {
    _activeCalls++;
    if (_activeCalls > maxConcurrentCalls) {
      maxConcurrentCalls = _activeCalls;
    }
    try {
      final returnedMultiPv = maxReturnedMultiPv == null
          ? multiPv
          : _minInt(maxReturnedMultiPv!, multiPv);
      return (
        _snapshot(
          depth: depth ?? 12,
          pv: missingPv ? const <String>[] : const ['g1f3', 'g8f6'],
          multiPv: returnedMultiPv,
        ),
        null,
      );
    } finally {
      _activeCalls--;
    }
  }
}

EvalSnapshot _snapshot({
  int depth = 12,
  List<String> pv = const ['g1f3', 'g8f6'],
  int multiPv = 1,
}) {
  return EvalSnapshot(
    scoreCp: 80,
    mateIn: null,
    depth: depth,
    bestMoveUci: 'g1f3',
    pvMoves: pv,
    engineLines: [
      for (var rank = 1; rank <= multiPv; rank++)
        EngineLine(
          rank: rank,
          moveUci: rank == 1 ? 'g1f3' : 'd2d4',
          scoreCp: 80 - (rank - 1) * 20,
          mateIn: null,
          depth: depth,
          whiteWinPercent: 55,
          pvMoves: pv.isEmpty
              ? const <String>[]
              : rank == 1
              ? pv
              : const ['d2d4', 'd7d5'],
        ),
    ],
  );
}

class _NoopChessEngine implements ChessEngine {
  @override
  Stream<EngineEvent> get events => const Stream<EngineEvent>.empty();

  @override
  String get bridgeVersion => 'fake-local-eval';

  @override
  bool get isRunning => true;

  @override
  Future<void> start() async {}

  @override
  void send(UciCommand command) {}

  @override
  void sendRaw(String line) {}

  @override
  void stop() {}

  @override
  Future<void> dispose() async {}
}

int _minInt(int a, int b) => a < b ? a : b;
