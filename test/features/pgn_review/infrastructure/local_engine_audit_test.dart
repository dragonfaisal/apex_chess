import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/local_engine_audit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalEngineAuditor', () {
    test(
      'reports source and Android artifact reality without assuming host load',
      () async {
        final report = await const LocalEngineAuditor().run(
          repoRoot: Directory.current,
        );

        expect(report.vendoredStockfishPresent, isTrue);
        expect(report.nnuePresent, isTrue);
        expect(report.stockfishMainRenamed, isTrue);
        expect(report.stubBridgeSourcePresent, isTrue);
        expect(report.stubFallbackSelectable, isTrue);
        expect(report.stubPolicyFailClosed, isTrue);
        expect(report.stubAllowOptionPresent, isTrue);
        expect(report.stubAllowDefaultOff, isTrue);
        expect(report.stubMissingSourcesFatal, isTrue);
        expect(report.stubUnsafeCompileDefinitionPresent, isTrue);
        expect(report.androidAbiFilters, contains('arm64-v8a'));
        expect(report.render(), contains('runtime mode:'));
        expect(report.render(), contains('stub policy fail-closed: true'));
        expect(report.render(), contains('Android packaging:'));
        expect(report.render(), contains('next recommendation:'));

        if (report.androidCmakeTargetJson != null) {
          expect(report.androidCmakeDefines, contains('STOCKFISH_REAL=1'));
          expect(
            report.androidCmakeDefines,
            isNot(contains('STOCKFISH_STUB=1')),
          );
          expect(report.androidCmakeStockfishSourceCount, greaterThan(0));
        }
      },
    );

    test('CMake source gates stub fallback behind explicit opt-in', () {
      final cmake = File('src/native/CMakeLists.txt').readAsStringSync();

      expect(cmake, contains('APEX_ALLOW_STOCKFISH_STUB'));
      expect(cmake, contains('OFF'));
      expect(cmake, contains('message(FATAL_ERROR'));
      expect(cmake, contains('APEX_STOCKFISH_STUB_UNSAFE_FOR_ANALYSIS'));
      expect(cmake, contains('-DAPEX_ALLOW_STOCKFISH_STUB=ON'));
    });

    test('tool exposes audit-only and packaging audit modes', () {
      final tool = File(
        'tool/local_stockfish_benchmark.dart',
      ).readAsStringSync();

      expect(tool, contains('--audit-only'));
      expect(tool, contains('--audit-packaging'));
      expect(tool, contains('androidPackagingAudit.render()'));
    });

    test('decision record is linked from the audit doc', () {
      final auditDoc = File(
        'docs/LOCAL_STOCKFISH_ENGINE_AUDIT.md',
      ).readAsStringSync();
      final decisionDoc = File(
        'docs/LOCAL_ENGINE_SUBSTRATE_DECISION.md',
      ).readAsStringSync();

      expect(auditDoc, contains('LOCAL_ENGINE_SUBSTRATE_DECISION.md'));
      expect(decisionDoc, contains('Current FFI Bridge'));
      expect(decisionDoc, contains('Standalone Subprocess'));
      expect(decisionDoc, contains('provisional'));
    });

    test('stub mode is never acceptable as a real analysis engine', () {
      expect(LocalEngineRuntimeMode.stubDetected.label, isNot('real'));
      expect(
        detectSuspiciousStubBehavior(const [
          EngineSearchObservation(
            positionLabel: 'a',
            bestMove: 'e2e4',
            scoreCp: 0,
            depth: 1,
            nodes: 1,
            elapsed: Duration(milliseconds: 1),
          ),
          EngineSearchObservation(
            positionLabel: 'b',
            bestMove: 'e2e4',
            scoreCp: 0,
            depth: 1,
            nodes: 1,
            elapsed: Duration(milliseconds: 1),
          ),
        ]),
        isNotEmpty,
      );
    });

    test('detects obvious bridge stub markers', () {
      final markers = detectStubMarkersInSource('''
        #if defined(STOCKFISH_STUB)
        id name ApexChess-Stub
        info depth 1 score cp 0 nodes 1 pv e2e4
        bestmove e2e4
      ''');

      expect(markers.map((m) => m.code), contains('stockfish_stub_define'));
      expect(markers.map((m) => m.code), contains('stub_engine_id'));
      expect(markers.map((m) => m.code), contains('constant_stub_output'));
    });

    test('detects suspicious constant fake search behavior', () {
      final findings = detectSuspiciousStubBehavior(const [
        EngineSearchObservation(
          positionLabel: 'startpos',
          bestMove: 'e2e4',
          scoreCp: 0,
          depth: 1,
          nodes: 1,
          elapsed: Duration(milliseconds: 1),
        ),
        EngineSearchObservation(
          positionLabel: 'mate_threat',
          bestMove: 'e2e4',
          scoreCp: 0,
          depth: 1,
          nodes: 1,
          elapsed: Duration(milliseconds: 1),
        ),
      ]);

      expect(findings.map((f) => f.code), contains('same_bestmove'));
      expect(findings.map((f) => f.code), contains('constant_cp'));
      expect(findings.map((f) => f.code), contains('immediate_no_search'));
    });

    test('packaging audit handles missing APK artifacts safely', () {
      final audit = analyzeAndroidPackaging(
        configuredAbiFilters: const ['arm64-v8a'],
        packagedEngineAbis: const [],
        artifactPresent: false,
      );

      expect(audit.statusLabel, 'artifact-missing');
      expect(audit.matchesConfigured, isFalse);
      expect(audit.warnings.single, contains('packaging is unproven'));
      expect(audit.render(), contains('artifact present: false'));
    });

    test(
      'packaging audit detects stale extra ABI entries from APK listing',
      () {
        final abis = parseAndroidEngineAbisFromApkListing('''
lib/arm64-v8a/libstockfish_bridge.so
lib/armeabi-v7a/libstockfish_bridge.so
lib/x86_64/libstockfish_bridge.so
lib/arm64-v8a/libflutter.so
''');
        final audit = analyzeAndroidPackaging(
          configuredAbiFilters: const ['arm64-v8a'],
          packagedEngineAbis: abis,
          artifactPresent: true,
        );

        expect(abis, ['arm64-v8a', 'armeabi-v7a', 'x86_64']);
        expect(audit.statusLabel, 'abi-mismatch');
        expect(audit.extraPackagedAbis, ['armeabi-v7a', 'x86_64']);
        expect(audit.missingPackagedAbis, isEmpty);
        expect(audit.warnings.single, contains('extra Stockfish ABIs'));
      },
    );

    test('packaging audit accepts ABI-consistent APK listing', () {
      final audit = analyzeAndroidPackaging(
        configuredAbiFilters: const ['arm64-v8a'],
        packagedEngineAbis: parseAndroidEngineAbisFromApkListing(
          'lib/arm64-v8a/libstockfish_bridge.so',
        ),
        artifactPresent: true,
      );

      expect(audit.statusLabel, 'abi-consistent');
      expect(audit.matchesConfigured, isTrue);
      expect(audit.warnings, isEmpty);
    });

    test('new audit and benchmark files stay local, non-UI, and original', () {
      const paths = [
        'lib/features/pgn_review/infrastructure/local_engine_audit.dart',
        'lib/features/pgn_review/infrastructure/local_stockfish_benchmark.dart',
        'tool/local_stockfish_benchmark.dart',
      ];
      for (final path in paths) {
        final source = File(path).readAsStringSync();
        expect(source, isNot(contains('package:flutter/material.dart')));
        expect(source, isNot(contains('package:flutter/widgets.dart')));
        expect(source, isNot(contains('online_review_staging_preflight')));
        expect(source, isNot(contains('C:\\apex_chess_backend')));
        expect(source, isNot(contains('preflight')));
        expect(source, isNot(contains('MoveQuality.brilliant')));
        expect(source, isNot(contains('MoveQuality.great')));
        expect(source, isNot(contains('MoveQuality.miss')));
        expect(source, isNot(contains('ACPL')));
        expect(source, isNot(contains('Chesskit')));
        expect(source, isNot(contains('DroidFish')));
        expect(source, isNot(contains('StockfishForFlutter')));
        expect(source, isNot(contains('python-chess')));
      }
    });
  });
}
