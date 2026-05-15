/// Pure adapter from backend product DTOs into app-domain online review models.
library;

import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_dto.dart';

class OnlineReviewProductAdapter {
  const OnlineReviewProductAdapter();

  ApexOnlineReview fromDto(OnlineReviewProductResponseDto dto) {
    return ApexOnlineReview(
      contractVersion: dto.contractVersion,
      gameKey: dto.gameKey,
      mode: _mode(dto.mode),
      status: _status(dto.status),
      headers: _headers(dto.headers),
      summary: _summary(dto.summary),
      moves: dto.moves.map(_move),
      providerInfo: _providerInfo(dto.providerMetadata),
      debugInfo: _debugInfo(dto.debug),
      failure: _failure(dto),
    );
  }

  ApexReviewHeaders? _headers(OnlineReviewHeadersDto? dto) {
    if (dto == null) return null;
    return ApexReviewHeaders(
      event: dto.event,
      site: dto.site,
      date: dto.date,
      round: dto.round,
      white: dto.white,
      black: dto.black,
      whiteElo: dto.whiteElo,
      blackElo: dto.blackElo,
      result: dto.result,
      eco: dto.eco,
      opening: dto.opening,
    );
  }

  ApexOnlineReviewSummary _summary(OnlineReviewSummaryDto dto) {
    return ApexOnlineReviewSummary(
      totalPlies: dto.totalPlies,
      analyzedMoves: dto.analyzedMoves,
      failedMoves: dto.failedMoves,
      qualityCounts: dto.qualityCounts,
      bestMoveCount: dto.bestMoveCount,
      inaccuracyCount: dto.inaccuracyCount,
      mistakeCount: dto.mistakeCount,
      blunderCount: dto.blunderCount,
      criticalMoveCount: dto.criticalMoveCount,
      averageCpLoss: dto.averageCpLoss,
      averageExpectedPointsLoss: dto.averageExpectedPointsLoss,
      maxCpLoss: dto.maxCpLoss,
      maxExpectedPointsLoss: dto.maxExpectedPointsLoss,
      accuracy: dto.accuracy,
      acpl: dto.acpl,
    );
  }

  ApexReviewedMove _move(OnlineReviewMoveDto dto) {
    return ApexReviewedMove(
      ply: dto.ply,
      moveNumber: dto.moveNumber,
      side: dto.side,
      san: dto.san,
      uci: dto.uci,
      quality: _quality(dto.quality),
      confidence: _confidence(dto.confidence),
      cpLoss: dto.cpLoss,
      expectedPointsLoss: dto.expectedPointsLoss,
      beforeFen: dto.beforeFen,
      afterFen: dto.afterFen,
      engineBestMove: dto.engineBestMove,
      playedMatchesEngineBest: dto.playedMatchesEngineBest,
      betterMove: _betterMove(dto.betterMove),
      engineLine: _engineLine(dto.engineLine),
      criticalityLevel: _criticality(dto.criticalityLevel),
      isCritical: dto.isCritical,
      isTacticalCandidate: dto.isTacticalCandidate,
      hasMateWarning: dto.hasMateWarning,
      warnings: dto.warnings,
    );
  }

  ApexBetterMove? _betterMove(OnlineReviewBetterMoveDto? dto) {
    if (dto == null) return null;
    return ApexBetterMove(
      moveUci: dto.moveUci,
      san: dto.san,
      source: dto.source,
      confidence: _confidence(dto.confidence),
    );
  }

  ApexEngineLine? _engineLine(OnlineReviewEngineLineDto? dto) {
    if (dto == null) return null;
    return ApexEngineLine(
      depth: dto.depth,
      bestMoveUci: dto.bestMoveUci,
      pv: dto.pv,
      score: _score(dto.score),
      multiPvCount: dto.multiPvCount,
    );
  }

  ApexEngineScore? _score(OnlineReviewScoreDto? dto) {
    if (dto == null) return null;
    return ApexEngineScore(
      scoreType: dto.scoreType,
      value: dto.value,
      whiteCentipawns: dto.whiteCentipawns,
      moverCentipawns: dto.moverCentipawns,
      mate: dto.mate,
    );
  }

  ApexReviewProviderInfo _providerInfo(OnlineReviewProviderMetadataDto dto) {
    return ApexReviewProviderInfo(
      provider: dto.provider,
      engine: dto.engine,
      analysisVersion: dto.analysisVersion,
      classifierVersion: dto.classifierVersion,
      productContractVersion: dto.productContractVersion,
      mode: _mode(dto.mode),
      targetDepthTier: dto.targetDepthTier,
      isExecutionHintOnly: dto.isExecutionHintOnly,
    );
  }

  ApexReviewDebugInfo? _debugInfo(OnlineReviewDebugEnvelopeDto? dto) {
    if (dto == null) return null;
    return ApexReviewDebugInfo(
      enabled: dto.enabled,
      sourceEndpoint: dto.sourceEndpoint,
      internalGameKey: dto.internalGameKey,
      omittedInternalSections: dto.omittedInternalSections,
      internalSafetySummary: _safetySummary(dto.internalSafetySummary),
    );
  }

  ApexReviewInternalSafetySummary? _safetySummary(
    OnlineReviewInternalSafetySummaryDto? dto,
  ) {
    if (dto == null) return null;
    return ApexReviewInternalSafetySummary(
      reviewDraftOk: dto.reviewDraftOk,
      moveCount: dto.moveCount,
      failedMoves: dto.failedMoves,
      classifierVersion: dto.classifierVersion,
      ledgerPersistent: dto.ledgerPersistent,
      runtimeMigrationReady: dto.runtimeMigrationReady,
    );
  }

  ApexReviewFailure? _failure(OnlineReviewProductResponseDto dto) {
    final error = dto.error;
    if (error != null) {
      return ApexReviewFailure(code: error.code, message: error.message);
    }
    if (!dto.ok || dto.status == OnlineReviewProductStatus.failed) {
      return const ApexReviewFailure(
        code: 'onlineReviewFailed',
        message: 'Online review failed',
      );
    }
    return null;
  }

  ApexOnlineReviewMode _mode(OnlineReviewMode mode) {
    return switch (mode) {
      OnlineReviewMode.onlineFast => ApexOnlineReviewMode.onlineFast,
      OnlineReviewMode.onlineDeep => ApexOnlineReviewMode.onlineDeep,
      OnlineReviewMode.dev => ApexOnlineReviewMode.dev,
    };
  }

  ApexReviewStatus _status(OnlineReviewProductStatus status) {
    return switch (status) {
      OnlineReviewProductStatus.completed => ApexReviewStatus.completed,
      OnlineReviewProductStatus.partial => ApexReviewStatus.partial,
      OnlineReviewProductStatus.failed => ApexReviewStatus.failed,
    };
  }

  ApexMoveQuality _quality(OnlineReviewMoveQuality quality) {
    return switch (quality) {
      OnlineReviewMoveQuality.best => ApexMoveQuality.best,
      OnlineReviewMoveQuality.excellent => ApexMoveQuality.excellent,
      OnlineReviewMoveQuality.good => ApexMoveQuality.good,
      OnlineReviewMoveQuality.inaccuracy => ApexMoveQuality.inaccuracy,
      OnlineReviewMoveQuality.mistake => ApexMoveQuality.mistake,
      OnlineReviewMoveQuality.blunder => ApexMoveQuality.blunder,
      OnlineReviewMoveQuality.unclassified => ApexMoveQuality.unclassified,
    };
  }

  ApexReviewConfidence _confidence(OnlineReviewConfidence confidence) {
    return switch (confidence) {
      OnlineReviewConfidence.high => ApexReviewConfidence.high,
      OnlineReviewConfidence.medium => ApexReviewConfidence.medium,
      OnlineReviewConfidence.low => ApexReviewConfidence.low,
      OnlineReviewConfidence.unknown => ApexReviewConfidence.unknown,
    };
  }

  ApexCriticalityLevel _criticality(OnlineReviewCriticalityLevel criticality) {
    return switch (criticality) {
      OnlineReviewCriticalityLevel.none => ApexCriticalityLevel.none,
      OnlineReviewCriticalityLevel.low => ApexCriticalityLevel.low,
      OnlineReviewCriticalityLevel.medium => ApexCriticalityLevel.medium,
      OnlineReviewCriticalityLevel.high => ApexCriticalityLevel.high,
      OnlineReviewCriticalityLevel.critical => ApexCriticalityLevel.critical,
    };
  }
}
