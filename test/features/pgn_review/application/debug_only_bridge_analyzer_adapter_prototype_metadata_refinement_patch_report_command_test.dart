@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Prototype Metadata Refinement Patch report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
              .analyzerAdapterPrototypeMetadataRefinementPatchAppliedWithWarnings,
        );
        expect(result.result!.safeForPhase34F, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
        );
        expect(result.stdoutText, contains('## Metadata Refinement Records'));
        expect(result.stdoutText, contains('## Support Reason Summary'));
        expect(result.stdoutText, contains('## Warning Reason Summary'));
        expect(result.stdoutText, contains('## Proof Boundary Summary'));
        expect(result.stdoutText, contains('## Excluded Guard Summary'));
        expect(result.stdoutText, contains('## Denied-Field Summary'));
        expect(result.stdoutText, contains('## Blocked Integration Summary'));
        expect(result.stdoutText, contains('## Target Surface Summary'));
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchVersion,
        );
        expect(
          decoded['status'],
          'analyzerAdapterPrototypeMetadataRefinementPatchAppliedWithWarnings',
        );
        expect(decoded['section'], 'all');
        expect(decoded['safeForPhase34F'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
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
        expect(decoded['refinements'], isA<List<Object?>>());
      });

      test('strict report succeeds', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.safeForPhase34F, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('section commands succeed', () {
        for (final section
            in DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchSection
                .values) {
          final result = _run(args: <String>['--section=${section.wire}']);

          expect(
            result.exitCode,
            debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchExitSuccess,
            reason: section.wire,
          );
          expect(result.section, section);
          expect(
            result.stdoutText,
            contains('selected section: ${section.wire}'),
          );
        }
      });

      test('invalid format and section fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=yaml']);
        final badSection = _run(args: const <String>['--section=missing']);

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchExitUsage,
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
          'tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchReportCommand(
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
