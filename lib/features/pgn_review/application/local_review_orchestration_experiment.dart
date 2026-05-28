/// Developer-only local review orchestration experiment over measured review.
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/features/pgn_review/application/local_smart_analysis_scheduler.dart';
import 'package:apex_chess/features/pgn_review/application/measured_local_review_prototype.dart';

enum LocalReviewOrchestrationSourceType {
  schedulerInputs('schedulerInputs'),
  parsedPositions('parsedPositions'),
  pgn('pgn');

  const LocalReviewOrchestrationSourceType(this.wire);

  final String wire;
}

enum LocalReviewOrchestrationStatus {
  completed('completed'),
  completedWithWarnings('completedWithWarnings'),
  partialFailure('partialFailure'),
  failed('failed'),
  rejected('rejected');

  const LocalReviewOrchestrationStatus(this.wire);

  final String wire;
}

enum LocalReviewOrchestrationRecommendation {
  readyForDeepGateExperiment('readyForDeepGateExperiment'),
  needsMappedPositions('needsMappedPositions'),
  tuneBudgetsBeforeDeepGate('tuneBudgetsBeforeDeepGate'),
  fixEngineFailuresBeforeDeepGate('fixEngineFailuresBeforeDeepGate'),
  fixMappingBeforeDeepGate('fixMappingBeforeDeepGate');

  const LocalReviewOrchestrationRecommendation(this.wire);

  final String wire;
}

class LocalReviewOrchestrationPosition {
  const LocalReviewOrchestrationPosition({
    required this.fen,
    this.reference,
    this.plyIndex,
    this.moveNumber,
    this.legalMoveCount,
    this.isOpeningKnown = false,
    this.isOnlyLegalMove = false,
    this.materialDeltaAfterMoveCp,
    this.previousEvalCp,
    this.provisionalEvalCp,
    this.candidateEvalSpreadCp,
    this.hasCheck = false,
    this.givesCheck = false,
    this.isCapture = false,
    this.isPromotion = false,
    this.isCastle = false,
    this.tags = const <String>[],
  });

  final String fen;
  final String? reference;
  final int? plyIndex;
  final int? moveNumber;
  final int? legalMoveCount;
  final bool isOpeningKnown;
  final bool isOnlyLegalMove;
  final int? materialDeltaAfterMoveCp;
  final int? previousEvalCp;
  final int? provisionalEvalCp;
  final int? candidateEvalSpreadCp;
  final bool hasCheck;
  final bool givesCheck;
  final bool isCapture;
  final bool isPromotion;
  final bool isCastle;
  final List<String> tags;
}

class LocalReviewOrchestrationExperimentRequest {
  const LocalReviewOrchestrationExperimentRequest._({
    required this.sourceType,
    required this.schedulerInputs,
    required this.parsedPositions,
    required this.pgn,
    this.profile = LocalSchedulerProfile.balanced,
    this.maxPositions,
    this.maxTotalEngineCalls,
    this.maxTotalElapsedBudgetMs,
    this.failFast = false,
    this.lowPower = false,
    this.requestId,
    this.includeOpeningSkips = true,
    this.includeForcedSkips = true,
    this.timeoutBudgetOverride,
  }) : assert(maxPositions == null || maxPositions >= 0),
       assert(maxTotalEngineCalls == null || maxTotalEngineCalls >= 0),
       assert(maxTotalElapsedBudgetMs == null || maxTotalElapsedBudgetMs >= 0);

  const LocalReviewOrchestrationExperimentRequest.fromSchedulerInputs({
    required List<LocalAnalysisPositionInput> positions,
    LocalSchedulerProfile profile = LocalSchedulerProfile.balanced,
    int? maxPositions,
    int? maxTotalEngineCalls,
    int? maxTotalElapsedBudgetMs,
    bool failFast = false,
    bool lowPower = false,
    String? requestId,
    bool includeOpeningSkips = true,
    bool includeForcedSkips = true,
    Duration? timeoutBudgetOverride,
  }) : this._(
         sourceType: LocalReviewOrchestrationSourceType.schedulerInputs,
         schedulerInputs: positions,
         parsedPositions: const <LocalReviewOrchestrationPosition>[],
         pgn: null,
         profile: profile,
         maxPositions: maxPositions,
         maxTotalEngineCalls: maxTotalEngineCalls,
         maxTotalElapsedBudgetMs: maxTotalElapsedBudgetMs,
         failFast: failFast,
         lowPower: lowPower,
         requestId: requestId,
         includeOpeningSkips: includeOpeningSkips,
         includeForcedSkips: includeForcedSkips,
         timeoutBudgetOverride: timeoutBudgetOverride,
       );

  const LocalReviewOrchestrationExperimentRequest.fromParsedPositions({
    required List<LocalReviewOrchestrationPosition> positions,
    LocalSchedulerProfile profile = LocalSchedulerProfile.balanced,
    int? maxPositions,
    int? maxTotalEngineCalls,
    int? maxTotalElapsedBudgetMs,
    bool failFast = false,
    bool lowPower = false,
    String? requestId,
    bool includeOpeningSkips = true,
    bool includeForcedSkips = true,
    Duration? timeoutBudgetOverride,
  }) : this._(
         sourceType: LocalReviewOrchestrationSourceType.parsedPositions,
         schedulerInputs: const <LocalAnalysisPositionInput>[],
         parsedPositions: positions,
         pgn: null,
         profile: profile,
         maxPositions: maxPositions,
         maxTotalEngineCalls: maxTotalEngineCalls,
         maxTotalElapsedBudgetMs: maxTotalElapsedBudgetMs,
         failFast: failFast,
         lowPower: lowPower,
         requestId: requestId,
         includeOpeningSkips: includeOpeningSkips,
         includeForcedSkips: includeForcedSkips,
         timeoutBudgetOverride: timeoutBudgetOverride,
       );

  const LocalReviewOrchestrationExperimentRequest.fromPgn({
    required String pgn,
    LocalSchedulerProfile profile = LocalSchedulerProfile.balanced,
    int? maxPositions,
    int? maxTotalEngineCalls,
    int? maxTotalElapsedBudgetMs,
    bool failFast = false,
    bool lowPower = false,
    String? requestId,
    bool includeOpeningSkips = true,
    bool includeForcedSkips = true,
    Duration? timeoutBudgetOverride,
  }) : this._(
         sourceType: LocalReviewOrchestrationSourceType.pgn,
         schedulerInputs: const <LocalAnalysisPositionInput>[],
         parsedPositions: const <LocalReviewOrchestrationPosition>[],
         pgn: pgn,
         profile: profile,
         maxPositions: maxPositions,
         maxTotalEngineCalls: maxTotalEngineCalls,
         maxTotalElapsedBudgetMs: maxTotalElapsedBudgetMs,
         failFast: failFast,
         lowPower: lowPower,
         requestId: requestId,
         includeOpeningSkips: includeOpeningSkips,
         includeForcedSkips: includeForcedSkips,
         timeoutBudgetOverride: timeoutBudgetOverride,
       );

  final LocalReviewOrchestrationSourceType sourceType;
  final List<LocalAnalysisPositionInput> schedulerInputs;
  final List<LocalReviewOrchestrationPosition> parsedPositions;
  final String? pgn;
  final LocalSchedulerProfile profile;
  final int? maxPositions;
  final int? maxTotalEngineCalls;
  final int? maxTotalElapsedBudgetMs;
  final bool failFast;
  final bool lowPower;
  final String? requestId;
  final bool includeOpeningSkips;
  final bool includeForcedSkips;
  final Duration? timeoutBudgetOverride;
}

class LocalReviewOrchestrationFailure {
  const LocalReviewOrchestrationFailure({
    required this.code,
    required this.message,
    this.positionIndex,
    this.reference,
  });

  final String code;
  final String message;
  final int? positionIndex;
  final String? reference;

  String get debugSummary =>
      'code=$code index=${positionIndex ?? "-"} '
      'ref=${reference ?? "-"} message="$message"';
}

class LocalReviewOrchestrationTelemetry {
  const LocalReviewOrchestrationTelemetry({
    required this.sourcePositions,
    required this.mappedPositions,
    required this.skippedBeforeMapping,
    required this.mappingWarningCount,
    required this.measuredEngineCalls,
    required this.measuredFastCalls,
    required this.measuredDeepCalls,
    required this.measuredMultiPvCalls,
    required this.measuredSkipped,
    required this.measuredRejected,
    required this.elapsedMilliseconds,
    this.budgetStopReason,
    this.slowestPositionIndex,
    this.slowestPositionReference,
  });

  final int sourcePositions;
  final int mappedPositions;
  final int skippedBeforeMapping;
  final int mappingWarningCount;
  final int measuredEngineCalls;
  final int measuredFastCalls;
  final int measuredDeepCalls;
  final int measuredMultiPvCalls;
  final int measuredSkipped;
  final int measuredRejected;
  final int elapsedMilliseconds;
  final String? budgetStopReason;
  final int? slowestPositionIndex;
  final String? slowestPositionReference;
}

class LocalReviewDeepGatingObservations {
  const LocalReviewDeepGatingObservations({
    required this.deepSearchPositionRefs,
    required this.futureGateCandidateRefs,
    required this.budgetPressureObservations,
    required this.multiPvPressureObservations,
    required this.timeoutOrWarningHotspots,
  });

  final List<String> deepSearchPositionRefs;
  final List<String> futureGateCandidateRefs;
  final List<String> budgetPressureObservations;
  final List<String> multiPvPressureObservations;
  final List<String> timeoutOrWarningHotspots;
}

class LocalReviewOrchestrationExperimentResult {
  const LocalReviewOrchestrationExperimentResult({
    required this.requestId,
    required this.status,
    required this.sourcePositionCount,
    required this.mappedPositionCount,
    required this.measuredResult,
    required this.telemetry,
    required this.deepGatingObservations,
    required this.mappingWarnings,
    required this.orchestrationWarnings,
    required this.failures,
    required this.recommendation,
  });

  final String? requestId;
  final LocalReviewOrchestrationStatus status;
  final int sourcePositionCount;
  final int mappedPositionCount;
  final MeasuredLocalReviewResult measuredResult;
  final LocalReviewOrchestrationTelemetry telemetry;
  final LocalReviewDeepGatingObservations deepGatingObservations;
  final List<String> mappingWarnings;
  final List<String> orchestrationWarnings;
  final List<LocalReviewOrchestrationFailure> failures;
  final LocalReviewOrchestrationRecommendation recommendation;

  String get debugSummary =>
      'request=${requestId ?? "-"} status=${status.wire} '
      'source=$sourcePositionCount mapped=$mappedPositionCount '
      'engineCalls=${telemetry.measuredEngineCalls} '
      'fast=${telemetry.measuredFastCalls} '
      'deep=${telemetry.measuredDeepCalls} '
      'multipv=${telemetry.measuredMultiPvCalls} '
      'warnings=${mappingWarnings.length + orchestrationWarnings.length} '
      'failures=${failures.length} recommendation=${recommendation.wire}';

  String renderDeveloperReport() {
    final buffer = StringBuffer()
      ..writeln('# Local Review Orchestration Experiment')
      ..writeln()
      ..writeln('- status: ${status.wire}')
      ..writeln('- request: ${requestId ?? "-"}')
      ..writeln('- source positions: $sourcePositionCount')
      ..writeln('- mapped positions: $mappedPositionCount')
      ..writeln('- skipped before mapping: ${telemetry.skippedBeforeMapping}')
      ..writeln('- engine calls: ${telemetry.measuredEngineCalls}')
      ..writeln('- fast calls: ${telemetry.measuredFastCalls}')
      ..writeln('- deep calls: ${telemetry.measuredDeepCalls}')
      ..writeln('- multipv calls: ${telemetry.measuredMultiPvCalls}')
      ..writeln('- measured skipped: ${telemetry.measuredSkipped}')
      ..writeln('- measured rejected: ${telemetry.measuredRejected}')
      ..writeln('- elapsed ms: ${telemetry.elapsedMilliseconds}')
      ..writeln('- recommendation: ${recommendation.wire}');

    if (telemetry.budgetStopReason != null) {
      buffer.writeln('- budget stop: ${telemetry.budgetStopReason}');
    }
    if (telemetry.slowestPositionIndex != null) {
      buffer.writeln('- slowest position: ${telemetry.slowestPositionIndex}');
    }

    _writeSection(buffer, 'mapping warnings', mappingWarnings);
    _writeSection(buffer, 'orchestration warnings', orchestrationWarnings);
    _writeSection(
      buffer,
      'deep-gate observations',
      deepGatingObservations.futureGateCandidateRefs.take(20),
    );
    if (failures.isNotEmpty) {
      _writeSection(
        buffer,
        'failures',
        failures.map((failure) => failure.debugSummary).take(20),
      );
    }

    return buffer.toString().trimRight();
  }

  static void _writeSection(
    StringBuffer buffer,
    String title,
    Iterable<String> lines,
  ) {
    final items = lines.toList(growable: false);
    if (items.isEmpty) return;
    buffer
      ..writeln()
      ..writeln('$title:');
    for (final item in items) {
      buffer.writeln('- $item');
    }
  }
}

class LocalReviewOrchestrationExperiment {
  const LocalReviewOrchestrationExperiment({
    required MeasuredLocalReviewPrototype measuredReview,
  }) : _measuredReview = measuredReview;

  final MeasuredLocalReviewPrototype _measuredReview;

  Future<LocalReviewOrchestrationExperimentResult> run(
    LocalReviewOrchestrationExperimentRequest request,
  ) async {
    final stopwatch = Stopwatch()..start();
    final mapped = _mapRequest(request);
    final failures = <LocalReviewOrchestrationFailure>[
      if (mapped.failure != null) mapped.failure!,
    ];
    final measured = await _measuredReview.run(
      MeasuredLocalReviewRequest(
        positions: mapped.inputs,
        profile: request.profile,
        maxPositions: request.maxPositions,
        failFast: request.failFast,
        requestId: request.requestId,
        lowPowerOverride: request.lowPower,
        maxTotalEngineCalls: request.maxTotalEngineCalls,
        maxTotalElapsedBudgetMs: request.maxTotalElapsedBudgetMs,
        timeoutBudgetOverride: request.timeoutBudgetOverride,
      ),
    );
    stopwatch.stop();

    failures.addAll(
      measured.failures.map(
        (failure) => LocalReviewOrchestrationFailure(
          code: failure.code ?? failure.status.wire,
          message: failure.message ?? 'Measured local execution failed.',
          positionIndex: failure.positionIndex,
          reference: failure.requestId,
        ),
      ),
    );

    final orchestrationWarnings = <String>[...measured.warnings];
    final telemetry = _telemetryFor(
      mapped: mapped,
      measured: measured,
      elapsedMilliseconds: stopwatch.elapsedMilliseconds,
    );
    final status = _statusFor(
      mapped: mapped,
      measured: measured,
      mappingWarnings: mapped.mappingWarnings,
      orchestrationWarnings: orchestrationWarnings,
      failures: failures,
    );
    final observations = _observationsFor(
      mappedInputs: mapped.inputs,
      measured: measured,
      budgetStopReason: telemetry.budgetStopReason,
    );

    return LocalReviewOrchestrationExperimentResult(
      requestId: request.requestId,
      status: status,
      sourcePositionCount: mapped.sourcePositionCount,
      mappedPositionCount: mapped.inputs.length,
      measuredResult: measured,
      telemetry: telemetry,
      deepGatingObservations: observations,
      mappingWarnings: List<String>.unmodifiable(mapped.mappingWarnings),
      orchestrationWarnings: List<String>.unmodifiable(orchestrationWarnings),
      failures: List<LocalReviewOrchestrationFailure>.unmodifiable(failures),
      recommendation: _recommendationFor(
        mapped: mapped,
        status: status,
        measured: measured,
        telemetry: telemetry,
        failures: failures,
      ),
    );
  }

  static _MappedReviewPositions _mapRequest(
    LocalReviewOrchestrationExperimentRequest request,
  ) {
    return switch (request.sourceType) {
      LocalReviewOrchestrationSourceType.schedulerInputs => _mapSchedulerInputs(
        request,
      ),
      LocalReviewOrchestrationSourceType.parsedPositions => _mapParsedPositions(
        request,
        request.parsedPositions,
      ),
      LocalReviewOrchestrationSourceType.pgn => _mapPgn(request),
    };
  }

  static _MappedReviewPositions _mapSchedulerInputs(
    LocalReviewOrchestrationExperimentRequest request,
  ) {
    final inputs = <LocalAnalysisPositionInput>[];
    var skippedBeforeMapping = 0;
    for (final input in request.schedulerInputs) {
      if (!_shouldInclude(
        isOpeningKnown: input.isOpeningKnown,
        isOnlyLegalMove: input.isOnlyLegalMove,
        request: request,
      )) {
        skippedBeforeMapping++;
        continue;
      }
      inputs.add(input);
    }
    return _MappedReviewPositions(
      sourcePositionCount: request.schedulerInputs.length,
      inputs: inputs,
      skippedBeforeMapping: skippedBeforeMapping,
    );
  }

  static _MappedReviewPositions _mapParsedPositions(
    LocalReviewOrchestrationExperimentRequest request,
    List<LocalReviewOrchestrationPosition> positions,
  ) {
    final inputs = <LocalAnalysisPositionInput>[];
    final mappingWarnings = <String>[];
    var skippedBeforeMapping = 0;

    for (var index = 0; index < positions.length; index++) {
      final position = positions[index];
      if (!_shouldInclude(
        isOpeningKnown: position.isOpeningKnown,
        isOnlyLegalMove: position.isOnlyLegalMove,
        request: request,
      )) {
        skippedBeforeMapping++;
        continue;
      }
      final cleanFen = position.fen.trim();
      if (cleanFen.isEmpty) {
        mappingWarnings.add('position $index has empty FEN');
      }
      if (position.plyIndex != null && position.plyIndex! < 0) {
        mappingWarnings.add('position $index has negative ply index');
      }
      inputs.add(
        LocalAnalysisPositionInput(
          fen: cleanFen,
          moveNumber: position.moveNumber,
          plyIndex: position.plyIndex,
          legalMoveCount: position.legalMoveCount,
          isOpeningKnown: position.isOpeningKnown,
          isOnlyLegalMove: position.isOnlyLegalMove,
          materialDeltaAfterMoveCp: position.materialDeltaAfterMoveCp,
          previousEvalCp: position.previousEvalCp,
          provisionalEvalCp: position.provisionalEvalCp,
          candidateEvalSpreadCp: position.candidateEvalSpreadCp,
          hasCheck: position.hasCheck,
          givesCheck: position.givesCheck,
          isCapture: position.isCapture,
          isPromotion: position.isPromotion,
          isCastle: position.isCastle,
          tags: [
            if (position.reference != null) 'ref:${position.reference}',
            ...position.tags,
          ],
        ),
      );
    }

    return _MappedReviewPositions(
      sourcePositionCount: positions.length,
      inputs: inputs,
      skippedBeforeMapping: skippedBeforeMapping,
      mappingWarnings: mappingWarnings,
    );
  }

  static _MappedReviewPositions _mapPgn(
    LocalReviewOrchestrationExperimentRequest request,
  ) {
    final pgn = request.pgn?.trim() ?? '';
    if (pgn.isEmpty) {
      return const _MappedReviewPositions(
        sourcePositionCount: 0,
        inputs: <LocalAnalysisPositionInput>[],
        mappingWarnings: ['empty PGN source'],
        failure: LocalReviewOrchestrationFailure(
          code: 'empty_pgn',
          message: 'PGN source was empty.',
        ),
      );
    }

    try {
      final parsed = _positionsFromPgn(pgn);
      return _mapParsedPositions(request, parsed);
    } on Object catch (error) {
      return _MappedReviewPositions(
        sourcePositionCount: 0,
        inputs: const <LocalAnalysisPositionInput>[],
        mappingWarnings: ['PGN source could not be parsed'],
        failure: LocalReviewOrchestrationFailure(
          code: 'invalid_pgn',
          message: error.toString(),
        ),
      );
    }
  }

  static List<LocalReviewOrchestrationPosition> _positionsFromPgn(String pgn) {
    final game = PgnGame.parsePgn(pgn);
    Position position = PgnGame.startingPosition(game.headers);
    final positions = <LocalReviewOrchestrationPosition>[];

    var ply = 0;
    for (final node in game.moves.mainline()) {
      final move = position.parseSan(node.san);
      if (move == null) {
        throw FormatException('Could not parse SAN at ply $ply.');
      }
      final fenBefore = position.fen;
      final next = position.play(move);
      final normal = move is NormalMove ? move : null;
      final isCastle = normal != null && _isCastle(position, normal);
      final uci = normal == null
          ? null
          : '${_sqAlg(normal.from)}${_sqAlg(normal.to)}'
                '${normal.promotion == null ? "" : _roleChar(normal.promotion!)}';

      positions.add(
        LocalReviewOrchestrationPosition(
          fen: fenBefore,
          reference: 'ply-$ply',
          plyIndex: ply,
          moveNumber: (ply ~/ 2) + 1,
          hasCheck: position.isCheck,
          givesCheck: next.isCheck,
          isCapture: normal != null && _isCapture(position, normal),
          isPromotion: normal?.promotion != null,
          isCastle: isCastle,
          tags: ['source:pgn', 'san:${node.san}', if (uci != null) 'uci:$uci'],
        ),
      );

      position = next;
      ply++;
    }

    return positions;
  }

  static bool _shouldInclude({
    required bool isOpeningKnown,
    required bool isOnlyLegalMove,
    required LocalReviewOrchestrationExperimentRequest request,
  }) {
    if (isOpeningKnown && !request.includeOpeningSkips) return false;
    if (isOnlyLegalMove && !request.includeForcedSkips) return false;
    return true;
  }

  static LocalReviewOrchestrationTelemetry _telemetryFor({
    required _MappedReviewPositions mapped,
    required MeasuredLocalReviewResult measured,
    required int elapsedMilliseconds,
  }) {
    final budgetStop = measured.warnings
        .where(
          (warning) =>
              warning.contains('maxTotalEngineCalls') ||
              warning.contains('maxTotalElapsedBudgetMs'),
        )
        .firstOrNull;
    return LocalReviewOrchestrationTelemetry(
      sourcePositions: mapped.sourcePositionCount,
      mappedPositions: mapped.inputs.length,
      skippedBeforeMapping: mapped.skippedBeforeMapping,
      mappingWarningCount: mapped.mappingWarnings.length,
      measuredEngineCalls: measured.totalEngineCalls,
      measuredFastCalls: measured.fastCount,
      measuredDeepCalls: measured.deepCount,
      measuredMultiPvCalls: measured.multiPvCount,
      measuredSkipped: measured.skippedCount,
      measuredRejected: measured.rejectedCount,
      elapsedMilliseconds: elapsedMilliseconds,
      budgetStopReason: budgetStop,
      slowestPositionIndex: measured.telemetry.slowestPositionIndex,
      slowestPositionReference: measured.telemetry.slowestPositionId,
    );
  }

  static LocalReviewDeepGatingObservations _observationsFor({
    required List<LocalAnalysisPositionInput> mappedInputs,
    required MeasuredLocalReviewResult measured,
    required String? budgetStopReason,
  }) {
    final deepRefs = <String>[];
    final gateRefs = <String>[];
    final budgetPressure = <String>[
      if (budgetStopReason != null) budgetStopReason,
    ];
    final multiPvPressure = <String>[];
    final hotspots = <String>[];

    for (var index = 0; index < measured.positionResults.length; index++) {
      final result = measured.positionResults[index];
      final ref = _referenceFor(mappedInputs, index, result.requestId);
      if (result.deepSnapshot != null || result.telemetry.deepCalls > 0) {
        deepRefs.add(ref);
      }
      if (_isFutureGateCandidate(result.decision.type)) {
        gateRefs.add(ref);
      }
      if (result.plannedMultiPv > 1 || result.executedMultiPv > 1) {
        multiPvPressure.add(
          '$ref planned=${result.plannedMultiPv} executed=${result.executedMultiPv}',
        );
      }
      if (result.telemetry.timeoutCount > 0 || result.warnings.isNotEmpty) {
        hotspots.add(ref);
      }
    }

    return LocalReviewDeepGatingObservations(
      deepSearchPositionRefs: List<String>.unmodifiable(deepRefs),
      futureGateCandidateRefs: List<String>.unmodifiable(gateRefs),
      budgetPressureObservations: List<String>.unmodifiable(budgetPressure),
      multiPvPressureObservations: List<String>.unmodifiable(multiPvPressure),
      timeoutOrWarningHotspots: List<String>.unmodifiable(hotspots),
    );
  }

  static bool _isFutureGateCandidate(LocalSchedulerDecisionType type) {
    return type == LocalSchedulerDecisionType.deepReanalysis ||
        type == LocalSchedulerDecisionType.fastPassThenMaybeDeep ||
        type == LocalSchedulerDecisionType.multipvProbe;
  }

  static LocalReviewOrchestrationStatus _statusFor({
    required _MappedReviewPositions mapped,
    required MeasuredLocalReviewResult measured,
    required List<String> mappingWarnings,
    required List<String> orchestrationWarnings,
    required List<LocalReviewOrchestrationFailure> failures,
  }) {
    if (mapped.failure != null) return LocalReviewOrchestrationStatus.rejected;
    final base = switch (measured.status) {
      MeasuredLocalReviewStatus.completed =>
        LocalReviewOrchestrationStatus.completed,
      MeasuredLocalReviewStatus.completedWithWarnings =>
        LocalReviewOrchestrationStatus.completedWithWarnings,
      MeasuredLocalReviewStatus.partialFailure =>
        LocalReviewOrchestrationStatus.partialFailure,
      MeasuredLocalReviewStatus.failed => LocalReviewOrchestrationStatus.failed,
      MeasuredLocalReviewStatus.rejected =>
        LocalReviewOrchestrationStatus.rejected,
    };
    if (base == LocalReviewOrchestrationStatus.completed &&
        (mappingWarnings.isNotEmpty || orchestrationWarnings.isNotEmpty)) {
      return LocalReviewOrchestrationStatus.completedWithWarnings;
    }
    if (base == LocalReviewOrchestrationStatus.completed &&
        failures.isNotEmpty) {
      return LocalReviewOrchestrationStatus.partialFailure;
    }
    return base;
  }

  static LocalReviewOrchestrationRecommendation _recommendationFor({
    required _MappedReviewPositions mapped,
    required LocalReviewOrchestrationStatus status,
    required MeasuredLocalReviewResult measured,
    required LocalReviewOrchestrationTelemetry telemetry,
    required List<LocalReviewOrchestrationFailure> failures,
  }) {
    if (mapped.failure != null) {
      return LocalReviewOrchestrationRecommendation.fixMappingBeforeDeepGate;
    }
    if (mapped.inputs.isEmpty) {
      return LocalReviewOrchestrationRecommendation.needsMappedPositions;
    }
    if (failures.isNotEmpty ||
        status == LocalReviewOrchestrationStatus.failed ||
        status == LocalReviewOrchestrationStatus.partialFailure ||
        measured.timeoutCount > 0) {
      return LocalReviewOrchestrationRecommendation
          .fixEngineFailuresBeforeDeepGate;
    }
    if (telemetry.budgetStopReason != null) {
      return LocalReviewOrchestrationRecommendation.tuneBudgetsBeforeDeepGate;
    }
    return LocalReviewOrchestrationRecommendation.readyForDeepGateExperiment;
  }

  static String _referenceFor(
    List<LocalAnalysisPositionInput> inputs,
    int index,
    String? requestId,
  ) {
    if (index < inputs.length) {
      final input = inputs[index];
      final explicit = input.tags
          .where((tag) => tag.startsWith('ref:'))
          .map((tag) => tag.substring(4))
          .firstOrNull;
      if (explicit != null && explicit.isNotEmpty) return explicit;
      if (input.plyIndex != null) return 'ply-${input.plyIndex}';
    }
    return requestId ?? 'position-$index';
  }

  static bool _isCapture(Position position, NormalMove move) {
    final movingPiece = position.board.pieceAt(move.from);
    final targetPiece = position.board.pieceAt(move.to);
    if (targetPiece == null) return false;
    return !_isCastleForPiece(movingPiece, move);
  }

  static bool _isCastle(Position position, NormalMove move) {
    final movingPiece = position.board.pieceAt(move.from);
    return _isCastleForPiece(movingPiece, move);
  }

  static bool _isCastleForPiece(Piece? movingPiece, NormalMove move) {
    return movingPiece != null &&
        movingPiece.role == Role.king &&
        move.from.file == 4 &&
        (move.to.file == 0 || move.to.file == 7);
  }

  static String _sqAlg(Square sq) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
    return '$file${sq.rank + 1}';
  }

  static String _roleChar(Role role) => switch (role) {
    Role.queen => 'q',
    Role.rook => 'r',
    Role.bishop => 'b',
    Role.knight => 'n',
    _ => '',
  };
}

class _MappedReviewPositions {
  const _MappedReviewPositions({
    required this.sourcePositionCount,
    required this.inputs,
    this.skippedBeforeMapping = 0,
    this.mappingWarnings = const <String>[],
    this.failure,
  });

  final int sourcePositionCount;
  final List<LocalAnalysisPositionInput> inputs;
  final int skippedBeforeMapping;
  final List<String> mappingWarnings;
  final LocalReviewOrchestrationFailure? failure;
}
