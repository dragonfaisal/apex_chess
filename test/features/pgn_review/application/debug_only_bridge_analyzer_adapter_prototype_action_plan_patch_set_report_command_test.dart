@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Prototype Action Plan Patch Set report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess,
        );
        expect(
          result.result!.status.wire,
          'analyzerAdapterPrototypeActionPlanPatchSetAppliedWithWarnings',
        );
        expect(result.result!.safeForPhase34D, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runAnalyzerAdapterPrototypeActionPlanPatchSetDiagnostic',
        );
        expect(result.stdoutText, contains('## Patch Record Table'));
        expect(result.stdoutText, contains('## Support Traceability Patches'));
        expect(
          result.stdoutText,
          contains('## Warning Follow-Up Marker Patches'),
        );
        expect(result.stdoutText, contains('## Proof Boundary Marker Patches'));
        expect(
          result.stdoutText,
          contains('## Excluded Guard Preservation Patches'),
        );
        expect(
          result.stdoutText,
          contains('## Denied Field Protection Patches'),
        );
        expect(
          result.stdoutText,
          contains('## Blocked Integration Sentinel Patches'),
        );
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetVersion,
        );
        expect(
          decoded['status'],
          'analyzerAdapterPrototypeActionPlanPatchSetAppliedWithWarnings',
        );
        expect(decoded['safeForPhase34D'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runAnalyzerAdapterPrototypeActionPlanPatchSetDiagnostic',
        );
        expect(counts['unsafeCount'], 0);
        expect(counts['blockerCount'], 0);
        expect(counts['criticalCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['runtimeImplementationCount'], 0);
        expect(counts['executablePrototypeCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
        expect(decoded['patches'], isA<List<Object?>>());
      });

      test('strict report succeeds', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.safeForPhase34D, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('section commands succeed', () {
        for (final section in const <String>[
          'all',
          'patches',
          'support',
          'warning',
          'proof',
          'guards',
          'denied',
          'blocked',
          'recommendation',
        ]) {
          final result = _run(args: <String>['--section=$section']);

          expect(
            result.exitCode,
            debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitSuccess,
            reason: section,
          );
          expect(result.section.wire, section);
          expect(result.stdoutText, contains('selected section: $section'));
        }
      });

      test('invalid format and section fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=yaml']);
        final badSection = _run(args: const <String>['--section=unknown']);

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetExitUsage,
        );
        expect(badSection.commandFailure, 'unknownSection');
      });

      test('output contains no raw engine spam or active product data', () {
        final markdown = _run().stdoutText;
        final json = _run(args: const <String>['--format=json']).stdoutText;

        _expectReportGuardrails(markdown);
        _expectReportGuardrails(json);
      });

      test('source imports remain model-only and command-only', () {
        final source = File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set_report.dart',
        ).readAsStringSync();
        final imports = RegExp(
          r"import '([^']+)';",
        ).allMatches(source).map((match) => match.group(1)!).join('\n');

        for (final forbidden in const <String>[
          'package:flutter/',
          'widgets',
          'backend',
          'preflight',
          'server',
          'cache',
          'database',
          'ffi',
          'native',
          'stockfish',
          'local_eval_service',
          'scheduler',
        ]) {
          expect(imports.toLowerCase(), isNot(contains(forbidden)));
        }
      });
    },
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetReportCommand(
    args: args,
  );
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'pv e2e4',
    'active fields: productLabel',
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'runtime implemented: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'readiness summary chain active',
    'readiness gate active',
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
