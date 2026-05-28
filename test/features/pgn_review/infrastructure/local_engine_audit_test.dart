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
        expect(report.androidAbiFilters, contains('arm64-v8a'));
        expect(report.render(), contains('runtime mode:'));
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
        expect(source, isNot(contains('Chesskit')));
        expect(source, isNot(contains('DroidFish')));
        expect(source, isNot(contains('StockfishForFlutter')));
        expect(source, isNot(contains('python-chess')));
      }
    });
  });
}
