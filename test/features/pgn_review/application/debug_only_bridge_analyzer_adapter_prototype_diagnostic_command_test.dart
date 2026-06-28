@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart';

void main() {
  group('Debug-Only Bridge Analyzer Adapter Prototype Diagnostic command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('default markdown command succeeds and includes sections', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown,
      );
      expect(
        result.section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
      );
      expect(result.safeDemo, isTrue);
      expect(
        result.diagnosticResult!.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
            .prototypeDiagnosticCommandReadyWithWarnings,
      );
      expect(result.diagnosticResult!.safeForPhase33Z, isTrue);
      expect(result.stdoutText, contains('## Source Phase Chain'));
      expect(result.stdoutText, contains('## Inspection Snapshot Summary'));
      expect(result.stdoutText, contains('## Packet Summary'));
      expect(result.stdoutText, contains('## Policy Flag Summary'));
      expect(result.stdoutText, contains('## Record Role Summary'));
      expect(result.stdoutText, contains('## Android Proof Boundary Summary'));
      expect(result.stdoutText, contains('## Allowed/Denied Field Summary'));
      expect(
        result.stdoutText,
        contains(
          '## Runtime/Analyzer/Engine/Scheduler/Product Blocked Summary',
        ),
      );
      expect(result.stdoutText, contains('## Recommendation'));
      expect(result.stdoutText, contains('## Action Plan Metadata Summary'));
      expect(
        result.stdoutText,
        contains('## Action Plan Patch Set Metadata Summary'),
      );
      expect(result.stdoutText, contains('## Metadata Refinement Summary'));
      expect(
        result.stdoutText,
        contains(
          'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
        ),
      );
      expect(result.stderrText, isEmpty);
    });

    test('JSON command succeeds and is parseable', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion,
      );
      expect(
        decoded['diagnosticStatus'],
        'prototypeDiagnosticCommandReadyWithWarnings',
      );
      expect(decoded['section'], 'all');
      expect(decoded['safeForPhase33Z'], isTrue);
      expect(decoded['safeForNextStep'], isTrue);
      expect(
        decoded['nextRecommendation'],
        'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
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
      expect(decoded['sourcePhaseChain'], isA<Map<String, Object?>>());
      expect(decoded['snapshot'], isA<Map<String, Object?>>());
      expect(decoded['packets'], isA<Map<String, Object?>>());
      expect(decoded['policy'], isA<Map<String, Object?>>());
      expect(decoded['records'], isA<Map<String, Object?>>());
      expect(decoded['proof'], isA<Map<String, Object?>>());
      expect(decoded['boundaries'], isA<Map<String, Object?>>());
      expect(decoded['runtime'], isA<Map<String, Object?>>());
      expect(decoded['next'], isA<Map<String, Object?>>());
      expect(decoded['actionPlan'], isA<Map<String, Object?>>());
      expect(decoded['patches'], isA<Map<String, Object?>>());
      expect(decoded['metadataRefinement'], isA<Map<String, Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const <String>['--strict']);
      final diagnostic = result.diagnosticResult!;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(result.strict, isTrue);
      expect(diagnostic.safeForPhase33Z, isTrue);
      expect(diagnostic.unsafeCount, 0);
      expect(diagnostic.blockerCount, 0);
      expect(diagnostic.criticalCount, 0);
      expect(diagnostic.analyzerWiringCount, 0);
      expect(diagnostic.runtimeImplementationCount, 0);
      expect(diagnostic.executablePrototypeCount, 0);
      expect(diagnostic.engineCallCount, 0);
      expect(diagnostic.schedulerExecutionCount, 0);
      expect(diagnostic.persistenceWriteCount, 0);
      expect(diagnostic.productOutputCount, 0);
      expect(diagnostic.activeDeniedFieldCount, 0);
    });

    test('each section mode succeeds', () {
      for (final section
          in DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.values) {
        final result = _run(args: <String>['--section=${section.wire}']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
          reason: section.wire,
        );
        expect(result.section, section);
        expect(
          result.stdoutText,
          contains('selected section: ${section.wire}'),
        );
      }
    });

    test('section outputs include expected summaries', () {
      expect(
        _run(args: const <String>['--section=snapshot']).stdoutText,
        contains('## Inspection Snapshot Summary'),
      );
      expect(
        _run(args: const <String>['--section=packets']).stdoutText,
        contains('## Packet Summary'),
      );
      expect(
        _run(args: const <String>['--section=policy']).stdoutText,
        contains('## Policy Flag Summary'),
      );
      expect(
        _run(args: const <String>['--section=records']).stdoutText,
        contains('## Inspection Validation Rows'),
      );
      expect(
        _run(args: const <String>['--section=proof']).stdoutText,
        contains('owner proof queue count: 0'),
      );
      expect(
        _run(args: const <String>['--section=boundaries']).stdoutText,
        contains('Stockfish/raw UCI/PV dump denied: true'),
      );
      expect(
        _run(args: const <String>['--section=runtime']).stdoutText,
        contains('scheduler execution count: 0'),
      );
      expect(
        _run(args: const <String>['--section=recommendation']).stdoutText,
        contains(
          'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
        ),
      );
      expect(
        _run(args: const <String>['--section=action-plan']).stdoutText,
        contains('## Action Plan Metadata Summary'),
      );
      expect(
        _run(args: const <String>['--section=patches']).stdoutText,
        contains('## Action Plan Patch Set Metadata Summary'),
      );
      expect(
        _run(args: const <String>['--section=metadata-refinement']).stdoutText,
        contains('## Metadata Refinement Summary'),
      );
      expect(
        _run(args: const <String>['--section=runtime-preparation']).stdoutText,
        contains('## Controlled Runtime Preparation'),
      );
      expect(
        _run(args: const <String>['--section=golden']).stdoutText,
        contains('## Selected Golden Analyzer Adapter Prototype Diagnostic'),
      );
    });

    test('list Golden cases succeeds', () {
      final markdown = _run(args: const <String>['--list-golden-cases']);
      final json = _run(
        args: const <String>['--list-golden-cases', '--format=json'],
      );
      final decoded = jsonDecode(json.stdoutText) as Map<String, Object?>;

      expect(
        markdown.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(markdown.listGoldenCases, isTrue);
      expect(markdown.stdoutText, contains('queen-win-major-swing'));
      expect(markdown.stdoutText, contains('quiet-preparatory-hard-case'));
      expect(
        json.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(decoded['cases'], isA<List<Object?>>());
    });

    test('default selected Golden diagnostic succeeds', () {
      final result = _run(
        args: const <String>['--golden-case=default-selected'],
      );
      final selected = result.selectedGoldenDiagnostic!;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(selected.selection, 'default-selected');
      expect(
        selected.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticStatus
            .selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyWithWarnings,
      );
      expect(selected.safeForPhase34A, isTrue);
      expect(
        selected.nextRecommendation,
        'validateSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
      );
      expect(selected.unsafeCount, 0);
      expect(selected.blockerCount, 0);
      expect(selected.criticalCount, 0);
      expect(selected.analyzerWiringCount, 0);
      expect(selected.runtimeImplementationCount, 0);
      expect(selected.executablePrototypeCount, 0);
      expect(selected.engineCallCount, 0);
      expect(selected.schedulerExecutionCount, 0);
      expect(selected.persistenceWriteCount, 0);
      expect(selected.productOutputCount, 0);
      expect(selected.activeDeniedFieldCount, 0);
      expect(
        result.stdoutText,
        contains(
          'selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyWithWarnings',
        ),
      );
      expect(result.stdoutText, contains('quiet-preparatory-hard-case'));
    });

    test('all-safe selected Golden diagnostic succeeds', () {
      final result = _run(
        args: const <String>['--golden-case=all-safe-selected'],
      );
      final selected = result.selectedGoldenDiagnostic!;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(selected.selection, 'all-safe-selected');
      expect(selected.safeForPhase34A, isTrue);
      expect(selected.rows.length, greaterThan(8));
      expect(
        selected.rows.map((row) => row.caseId),
        contains('quiet-preparatory-uncertain'),
      );
    });

    test('single known selected Golden case succeeds', () {
      final result = _run(
        args: const <String>['--golden-case=queen-win-major-swing'],
      );
      final selected = result.selectedGoldenDiagnostic!;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(selected.rows, hasLength(1));
      expect(selected.rows.single.caseId, 'queen-win-major-swing');
      expect(
        selected.rows.single.diagnosticRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .developerDiagnosticInputSupport,
      );
      expect(selected.rows.single.androidProofIds, ['queen-win-major-swing']);
    });

    test('selected Golden JSON and strict modes succeed', () {
      final json = _run(
        args: const <String>['--golden-case=default-selected', '--format=json'],
      );
      final strict = _run(
        args: const <String>['--golden-case=default-selected', '--strict'],
      );
      final decoded = jsonDecode(json.stdoutText) as Map<String, Object?>;
      final selected =
          decoded['selectedGoldenDiagnostic'] as Map<String, Object?>;
      final counts = selected['counts'] as Map<String, Object?>;

      expect(
        json.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(
        selected['status'],
        'selectedGoldenAnalyzerAdapterPrototypeDiagnosticReadyWithWarnings',
      );
      expect(selected['safeForPhase34A'], isTrue);
      expect(
        selected['nextRecommendation'],
        'validateSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['blockerCount'], 0);
      expect(counts['criticalCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(
        strict.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
    });

    test('patch diagnostic JSON and strict modes succeed', () {
      final json = _run(
        args: const <String>['--patch-diagnostic=default', '--format=json'],
      );
      final strict = _run(
        args: const <String>['--patch-diagnostic=default', '--strict'],
      );
      final decoded = jsonDecode(json.stdoutText) as Map<String, Object?>;
      final patchDiagnostic =
          decoded['patchSetDiagnostic'] as Map<String, Object?>;
      final counts = patchDiagnostic['counts'] as Map<String, Object?>;

      expect(
        json.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(json.patchDiagnosticMode!.wire, 'default');
      expect(
        json.patchSetDiagnostic!.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
            .analyzerAdapterPrototypePatchSetDiagnosticReadyWithWarnings,
      );
      expect(
        patchDiagnostic['status'],
        'analyzerAdapterPrototypePatchSetDiagnosticReadyWithWarnings',
      );
      expect(patchDiagnostic['safeForPhase34E'], isTrue);
      expect(
        patchDiagnostic['nextRecommendation'],
        'implementAnalyzerAdapterPrototypeMetadataRefinementPatch',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['blockerCount'], 0);
      expect(counts['criticalCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(
        strict.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(strict.patchSetDiagnostic!.safeForPhase34E, isTrue);
    });

    test('refinement diagnostic JSON and strict modes succeed', () {
      final json = _run(
        args: const <String>[
          '--refinement-diagnostic=default',
          '--format=json',
        ],
      );
      final strict = _run(
        args: const <String>['--refinement-diagnostic=default', '--strict'],
      );
      final decoded = jsonDecode(json.stdoutText) as Map<String, Object?>;
      final refinementDiagnostic =
          decoded['metadataRefinementDiagnostic'] as Map<String, Object?>;
      final counts = refinementDiagnostic['counts'] as Map<String, Object?>;

      expect(
        json.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(json.refinementDiagnosticMode!.wire, 'default');
      expect(
        json.metadataRefinementDiagnostic!.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
            .analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings,
      );
      expect(
        refinementDiagnostic['status'],
        'analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings',
      );
      expect(refinementDiagnostic['safeForPhase34G'], isTrue);
      expect(
        refinementDiagnostic['nextRecommendation'],
        'implementControlledAnalyzerAdapterRuntimePreparationPatch',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['blockerCount'], 0);
      expect(counts['criticalCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(
        strict.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(strict.metadataRefinementDiagnostic!.safeForPhase34G, isTrue);
    });

    test('runtime preparation diagnostic JSON and strict modes succeed', () {
      final json = _run(
        args: const <String>[
          '--runtime-preparation-diagnostic=default',
          '--format=json',
        ],
      );
      final strict = _run(
        args: const <String>[
          '--runtime-preparation-diagnostic=default',
          '--strict',
        ],
      );
      final decoded = jsonDecode(json.stdoutText) as Map<String, Object?>;
      final runtimePreparationDiagnostic =
          decoded['runtimePreparationDiagnostic'] as Map<String, Object?>;
      final counts =
          runtimePreparationDiagnostic['counts'] as Map<String, Object?>;

      expect(
        json.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(json.runtimePreparationDiagnosticMode!.wire, 'default');
      expect(
        json.runtimePreparationDiagnostic!.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
            .controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings,
      );
      expect(
        runtimePreparationDiagnostic['status'],
        'controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings',
      );
      expect(runtimePreparationDiagnostic['safeForPhase34I'], isTrue);
      expect(
        runtimePreparationDiagnostic['nextRecommendation'],
        'implementDisabledAnalyzerAdapterRuntimeSkeleton',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['blockerCount'], 0);
      expect(counts['criticalCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(counts['runtimeExecutionCount'], 0);
      expect(counts['analyzerWiringCount'], 0);
      expect(
        strict.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(strict.runtimePreparationDiagnostic!.safeForPhase34I, isTrue);
    });

    test('each patch diagnostic mode succeeds through diagnostic command', () {
      for (final mode in const <String>[
        'default',
        'all-safe',
        'support',
        'warning',
        'proof',
        'guards',
        'denied',
        'blocked',
        'recommendation',
      ]) {
        final result = _run(args: <String>['--patch-diagnostic=$mode']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
          reason: mode,
        );
        expect(result.patchDiagnosticMode!.wire, mode);
        expect(result.patchSetDiagnostic!.safeForPhase34E, isTrue);
        expect(result.stdoutText, contains('patch diagnostic mode: $mode'));
      }
    });

    test(
      'each refinement diagnostic mode succeeds through diagnostic command',
      () {
        for (final mode in const <String>[
          'default',
          'all-safe',
          'support',
          'warning',
          'proof',
          'guards',
          'denied',
          'blocked',
          'surfaces',
          'recommendation',
        ]) {
          final result = _run(args: <String>['--refinement-diagnostic=$mode']);

          expect(
            result.exitCode,
            debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
            reason: mode,
          );
          expect(result.refinementDiagnosticMode!.wire, mode);
          expect(result.metadataRefinementDiagnostic!.safeForPhase34G, isTrue);
          expect(
            result.stdoutText,
            contains('refinement diagnostic mode: $mode'),
          );
        }
      },
    );

    test('each runtime preparation diagnostic mode succeeds through command', () {
      for (final mode
          in DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
              .values) {
        final result = _run(
          args: <String>['--runtime-preparation-diagnostic=${mode.wire}'],
        );

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
          reason: mode.wire,
        );
        expect(result.runtimePreparationDiagnosticMode, mode);
        expect(result.runtimePreparationDiagnostic!.safeForPhase34I, isTrue);
        expect(
          result.stdoutText,
          contains('runtime preparation diagnostic mode: ${mode.wire}'),
        );
      }
    });

    test('selected Golden role guardrails are preserved', () {
      final selected = _run(
        args: const <String>['--golden-case=default-selected'],
      ).selectedGoldenDiagnostic!;
      final byId = {for (final row in selected.rows) row.caseId: row};

      expect(
        byId['quiet-preparatory-hard-case']!.diagnosticRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .excludedNegativeGuard,
      );
      expect(
        byId['pv-multipv-support-boundary-32e']!.diagnosticRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .proofBoundaryOnly,
      );
      expect(
        byId['king-safety-mating-net-pressure-32e']!.diagnosticRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .warningLimited,
      );
      expect(
        byId['endgame-precision-candidate-spread-32e']!.diagnosticRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .warningLimited,
      );
      expect(
        byId['budget-pressure-wide-candidate-32e']!.diagnosticRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticRole
            .warningLimited,
      );
      expect(selected.phase32EProofClaimCount, 0);
      expect(selected.unprovenAndroidProofCount, 0);
      expect(selected.ownerProofQueueCount, 0);
      expect(selected.quietPreparatoryPromotionCount, 0);
      expect(selected.pvMultiPvPromotionCount, 0);
    });

    test('invalid section and format fail with usage error', () {
      final badSection = _run(args: const <String>['--section=unknown']);
      final badFormat = _run(args: const <String>['--format=yaml']);
      final badGolden = _run(args: const <String>['--golden-case=missing']);
      final badPatchDiagnostic = _run(
        args: const <String>['--patch-diagnostic=missing'],
      );
      final badRefinementDiagnostic = _run(
        args: const <String>['--refinement-diagnostic=missing'],
      );
      final badRuntimePreparationDiagnostic = _run(
        args: const <String>['--runtime-preparation-diagnostic=missing'],
      );

      expect(
        badSection.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(badSection.commandFailure, 'unknownSection');
      expect(badSection.stderrText, contains('usage:'));
      expect(
        badFormat.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(badFormat.commandFailure, 'unknownFormat');
      expect(badFormat.stderrText, contains('usage:'));
      expect(
        badGolden.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(badGolden.commandFailure, 'unknownGoldenCase');
      expect(badGolden.stderrText, contains('usage:'));
      expect(
        badPatchDiagnostic.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(badPatchDiagnostic.commandFailure, 'unknownPatchDiagnostic');
      expect(badPatchDiagnostic.stderrText, contains('usage:'));
      expect(
        badRefinementDiagnostic.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(
        badRefinementDiagnostic.commandFailure,
        'unknownRefinementDiagnostic',
      );
      expect(badRefinementDiagnostic.stderrText, contains('usage:'));
      expect(
        badRuntimePreparationDiagnostic.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(
        badRuntimePreparationDiagnostic.commandFailure,
        'unknownRuntimePreparationDiagnostic',
      );
      expect(badRuntimePreparationDiagnostic.stderrText, contains('usage:'));
    });

    test('output contains no raw engine spam or active product data', () {
      final markdown = _run().stdoutText;
      final json = _run(args: const <String>['--format=json']).stdoutText;
      final golden = _run(
        args: const <String>['--golden-case=default-selected'],
      ).stdoutText;
      final goldenJson = _run(
        args: const <String>['--golden-case=default-selected', '--format=json'],
      ).stdoutText;
      final patchDiagnostic = _run(
        args: const <String>['--patch-diagnostic=default'],
      ).stdoutText;
      final metadataRefinement = _run(
        args: const <String>['--section=metadata-refinement'],
      ).stdoutText;
      final refinementDiagnostic = _run(
        args: const <String>['--refinement-diagnostic=default'],
      ).stdoutText;
      final runtimePreparation = _run(
        args: const <String>['--section=runtime-preparation'],
      ).stdoutText;
      final runtimePreparationDiagnostic = _run(
        args: const <String>['--runtime-preparation-diagnostic=default'],
      ).stdoutText;

      _expectReportGuardrails(markdown);
      _expectReportGuardrails(json);
      _expectReportGuardrails(golden);
      _expectReportGuardrails(goldenJson);
      _expectReportGuardrails(patchDiagnostic);
      _expectReportGuardrails(metadataRefinement);
      _expectReportGuardrails(refinementDiagnostic);
      _expectReportGuardrails(runtimePreparation);
      _expectReportGuardrails(runtimePreparationDiagnostic);
    });

    test('source imports remain command-only and integration-free', () {
      final source = File(
        'tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart',
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
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult _run({
  List<String> args = const <String>[],
}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand(
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
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
