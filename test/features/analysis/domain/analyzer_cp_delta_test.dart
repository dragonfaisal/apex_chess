import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_delta.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_cp_delta_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalAnalyzerCpDeltaProbe', () {
    test('computes improved CP delta', () async {
      final probe = _probe(_beforeAfter(beforeCp: -39, afterCp: 95));

      final result = await probe.run(const AnalyzerCpDeltaRequest.controlled());

      expect(result.cpDeltaComputed, isTrue);
      expect(result.moverPerspectiveDeltaCp, 134);
      expect(result.deltaDirection, AnalyzerCpDeltaDirection.improved);
      expect(result.safeForPhase35J, isTrue);
      expect(result.nextRecommendation, analyzerCpDeltaNextRecommendation);
    });

    test('computes worsened CP delta', () async {
      final probe = _probe(_beforeAfter(beforeCp: 100, afterCp: 20));

      final result = await probe.run(const AnalyzerCpDeltaRequest.controlled());

      expect(result.cpDeltaComputed, isTrue);
      expect(result.moverPerspectiveDeltaCp, -80);
      expect(result.deltaDirection, AnalyzerCpDeltaDirection.worsened);
    });

    test('computes unchanged CP delta', () async {
      final probe = _probe(_beforeAfter(beforeCp: 50, afterCp: 50));

      final result = await probe.run(const AnalyzerCpDeltaRequest.controlled());

      expect(result.cpDeltaComputed, isTrue);
      expect(result.moverPerspectiveDeltaCp, 0);
      expect(result.deltaDirection, AnalyzerCpDeltaDirection.unchanged);
    });

    test('is unavailable when before CP is missing', () async {
      final probe = _probe(_beforeAfter(beforeCp: null, afterCp: 50));

      final result = await probe.run(const AnalyzerCpDeltaRequest.controlled());

      expect(result.cpDeltaComputed, isFalse);
      expect(result.moverPerspectiveDeltaCp, isNull);
      expect(result.deltaDirection, AnalyzerCpDeltaDirection.unavailable);
      expect(result.safeForPhase35J, isFalse);
      expect(result.failureMessage, contains('before CP'));
    });

    test('is unavailable when after CP is missing', () async {
      final probe = _probe(_beforeAfter(beforeCp: 50, afterCp: null));

      final result = await probe.run(const AnalyzerCpDeltaRequest.controlled());

      expect(result.cpDeltaComputed, isFalse);
      expect(result.moverPerspectiveDeltaCp, isNull);
      expect(result.deltaDirection, AnalyzerCpDeltaDirection.unavailable);
      expect(result.safeForPhase35J, isFalse);
      expect(result.failureMessage, contains('after CP'));
    });

    test(
      'does not compute CP-loss, Win%, classification, or move quality',
      () async {
        final probe = _probe(_beforeAfter(beforeCp: -39, afterCp: 95));

        final result = await probe.run(
          const AnalyzerCpDeltaRequest.controlled(),
        );
        final json = result.toJson();

        expect(result.cpLossComputed, isFalse);
        expect(result.winPercentComputed, isFalse);
        expect(result.classificationComputed, isFalse);
        expect(result.moveQualityComputed, isFalse);
        for (final forbiddenField in _forbiddenFields) {
          expect(json.containsKey(forbiddenField), isFalse);
        }
      },
    );

    test('black mover uses supplied mover perspective fields', () async {
      final probe = _probe(
        _beforeAfter(
          beforeCp: 39,
          afterCp: 30,
          moverColor: AnalyzerMoverColor.black,
          beforeWhiteCp: -39,
          afterWhiteCp: -30,
          beforeBlackCp: 39,
          afterBlackCp: 30,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpDeltaRequest.controlled(
          moverColor: AnalyzerMoverColor.black,
        ),
      );

      expect(result.moverColor, AnalyzerMoverColor.black);
      expect(result.moverPerspectiveBeforeCp, 39);
      expect(result.moverPerspectiveAfterCp, 30);
      expect(result.moverPerspectiveDeltaCp, -9);
      expect(result.deltaDirection, AnalyzerCpDeltaDirection.worsened);
    });
  });
}

const _forbiddenFields = <String>[
  'label',
  'moveLabel',
  'classification',
  'moveQuality',
  'winPercent',
  'whiteWinPercent',
  'blackWinPercent',
  'cpLoss',
  'accuracy',
  'acpl',
  'book',
  'openingPhase',
  'explanation',
];

LocalAnalyzerCpDeltaProbe _probe(AnalyzerBeforeAfterRawEvalResult result) {
  return LocalAnalyzerCpDeltaProbe(
    beforeAfterRunner:
        (
          AnalyzerBeforeAfterRawEvalRequest request, {
          Duration timeout = const Duration(seconds: 5),
        }) async => result,
  );
}

AnalyzerBeforeAfterRawEvalResult _beforeAfter({
  required int? beforeCp,
  required int? afterCp,
  AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  int? beforeWhiteCp,
  int? afterWhiteCp,
  int? beforeBlackCp,
  int? afterBlackCp,
}) {
  final beforeWhite = beforeWhiteCp ?? beforeCp;
  final afterWhite = afterWhiteCp ?? afterCp;
  final beforeBlack =
      beforeBlackCp ?? (beforeWhite == null ? null : -beforeWhite);
  final afterBlack = afterBlackCp ?? (afterWhite == null ? null : -afterWhite);
  return AnalyzerBeforeAfterRawEvalResult(
    beforeFen: analyzerCpDeltaControlledBeforeFen,
    afterFen: analyzerCpDeltaControlledAfterFen,
    playedMoveUci: analyzerCpDeltaPlayedMoveUci,
    moverColor: moverColor,
    requestedDepth: analyzerCpDeltaDepth,
    beforeEvalSucceeded: true,
    afterEvalSucceeded: true,
    beforeSideToMove: null,
    afterSideToMove: null,
    beforeRawScoreType: beforeCp == null ? 'mate' : 'cp',
    afterRawScoreType: afterCp == null ? 'mate' : 'cp',
    beforeRawScoreCp: beforeCp,
    afterRawScoreCp: afterCp,
    beforeRawScoreMate: beforeCp == null ? 3 : null,
    afterRawScoreMate: afterCp == null ? 2 : null,
    beforeWhitePerspectiveCp: beforeWhite,
    afterWhitePerspectiveCp: afterWhite,
    beforeBlackPerspectiveCp: beforeBlack,
    afterBlackPerspectiveCp: afterBlack,
    beforeWhitePerspectiveMate: beforeCp == null ? 3 : null,
    afterWhitePerspectiveMate: afterCp == null ? 2 : null,
    beforeBlackPerspectiveMate: beforeCp == null ? -3 : null,
    afterBlackPerspectiveMate: afterCp == null ? -2 : null,
    moverPerspectiveBeforeCp: beforeCp,
    moverPerspectiveAfterCp: afterCp,
    moverPerspectiveBeforeMate: beforeCp == null ? 3 : null,
    moverPerspectiveAfterMate: afterCp == null ? 2 : null,
    beforeBestMove: 'e2e3',
    afterBestMove: 'e7e6',
    beforeBestMoveReceived: true,
    afterBestMoveReceived: true,
    beforeInfoDepthSeen: analyzerCpDeltaDepth,
    afterInfoDepthSeen: analyzerCpDeltaDepth,
    beforeAfterRawEvalSucceeded: true,
    deltaComputed: false,
    cpLossComputed: false,
    winPercentComputed: false,
    classificationComputed: false,
    failureMessage: null,
    safeForPhase35I: true,
    nextRecommendation: analyzerBeforeAfterRawEvalNextRecommendation,
    blockers: const [],
    warnings: const [],
  );
}
