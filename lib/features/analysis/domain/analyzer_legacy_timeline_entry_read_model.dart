import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

const analyzerLegacyTimelineEntryReadModelSource =
    'phase36CLegacyTimelineEntryReadModelMapper';
const analyzerLegacyTimelineEntryReadModelVersion = 'phase36C.v1';
const analyzerLegacyTimelineEntryReadModelNextRecommendation =
    'implementLegacyTimelineCollectionReadModelWithoutPublicLabels';
const analyzerLegacyTimelineEntryReadModelFailureRecommendation =
    'fixLegacyTimelineEntryReadModelMapping';

enum AnalyzerLegacyTimelineEntryKind {
  privateSingleMoveDraft('privateSingleMoveDraft'),
  unavailable('unavailable');

  const AnalyzerLegacyTimelineEntryKind(this.wire);

  final String wire;
}

class AnalyzerLegacyTimelineEntryReadModel {
  const AnalyzerLegacyTimelineEntryReadModel({
    required this.timelineEntryId,
    required this.sourceReadModelId,
    required this.legacyReintegrationResultId,
    required this.phase35QAnalysisResultId,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.timelineEntrySource,
    required this.timelineEntryVersion,
    required this.timelineEntryComputed,
    required this.timelineEntryKind,
    required this.timelineEntryOrderKey,
    required this.timelineEntryIsSingleMoveOnly,
    required this.timelineEntryIsFullGameTimeline,
    required this.timelineEntryIsProductTimeline,
    required this.timelineEntryIsUiOutput,
    required this.privateDraftBucket,
    required this.privateDraftReasonCode,
    required this.privateDraftConfidenceTier,
    required this.sourceReadModelComputed,
    required this.sourceReadModelIsPublic,
    required this.sourceReadModelIsProductReview,
    required this.sourceReadModelIsSavedAnalysis,
    required this.sourceReadModelIsOfficial,
    required this.sourceReadModelIsUiOutput,
    required this.sourceReadModelIsArchiveStatsOutput,
    required this.publicLabelComputed,
    required this.publicLabel,
    required this.officialMoveQualityComputed,
    required this.officialMoveQuality,
    required this.officialCpLossComputed,
    required this.officialWinPercentComputed,
    required this.accuracyComputed,
    required this.acplComputed,
    required this.classificationComputed,
    required this.publicClassifierOutputComputed,
    required this.savedAnalysisWritten,
    required this.uiOutputProduced,
    required this.archiveStatsTouched,
    required this.mappingSucceeded,
    required this.failureMessage,
    required this.safeForPhase36D,
    required this.nextRecommendation,
  });

  final String timelineEntryId;
  final String sourceReadModelId;
  final String legacyReintegrationResultId;
  final String phase35QAnalysisResultId;
  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String timelineEntrySource;
  final String timelineEntryVersion;
  final bool timelineEntryComputed;
  final AnalyzerLegacyTimelineEntryKind timelineEntryKind;
  final int timelineEntryOrderKey;
  final bool timelineEntryIsSingleMoveOnly;
  final bool timelineEntryIsFullGameTimeline;
  final bool timelineEntryIsProductTimeline;
  final bool timelineEntryIsUiOutput;
  final AnalyzerPrivateDraftBucket privateDraftBucket;
  final AnalyzerPrivateDraftReasonCode privateDraftReasonCode;
  final AnalyzerPrivateDraftConfidenceTier privateDraftConfidenceTier;
  final bool sourceReadModelComputed;
  final bool sourceReadModelIsPublic;
  final bool sourceReadModelIsProductReview;
  final bool sourceReadModelIsSavedAnalysis;
  final bool sourceReadModelIsOfficial;
  final bool sourceReadModelIsUiOutput;
  final bool sourceReadModelIsArchiveStatsOutput;
  final bool publicLabelComputed;
  final String? publicLabel;
  final bool officialMoveQualityComputed;
  final String? officialMoveQuality;
  final bool officialCpLossComputed;
  final bool officialWinPercentComputed;
  final bool accuracyComputed;
  final bool acplComputed;
  final bool classificationComputed;
  final bool publicClassifierOutputComputed;
  final bool savedAnalysisWritten;
  final bool uiOutputProduced;
  final bool archiveStatsTouched;
  final bool mappingSucceeded;
  final String? failureMessage;
  final bool safeForPhase36D;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'timelineEntryId': timelineEntryId,
    'sourceReadModelId': sourceReadModelId,
    'legacyReintegrationResultId': legacyReintegrationResultId,
    'phase35QAnalysisResultId': phase35QAnalysisResultId,
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'timelineEntrySource': timelineEntrySource,
    'timelineEntryVersion': timelineEntryVersion,
    'timelineEntryComputed': timelineEntryComputed,
    'timelineEntryKind': timelineEntryKind.wire,
    'timelineEntryOrderKey': timelineEntryOrderKey,
    'timelineEntryIsSingleMoveOnly': timelineEntryIsSingleMoveOnly,
    'timelineEntryIsFullGameTimeline': timelineEntryIsFullGameTimeline,
    'timelineEntryIsProductTimeline': timelineEntryIsProductTimeline,
    'timelineEntryIsUiOutput': timelineEntryIsUiOutput,
    'privateDraftBucket': privateDraftBucket.wire,
    'privateDraftReasonCode': privateDraftReasonCode.wire,
    'privateDraftConfidenceTier': privateDraftConfidenceTier.wire,
    'sourceReadModelComputed': sourceReadModelComputed,
    'sourceReadModelIsPublic': sourceReadModelIsPublic,
    'sourceReadModelIsProductReview': sourceReadModelIsProductReview,
    'sourceReadModelIsSavedAnalysis': sourceReadModelIsSavedAnalysis,
    'sourceReadModelIsOfficial': sourceReadModelIsOfficial,
    'sourceReadModelIsUiOutput': sourceReadModelIsUiOutput,
    'sourceReadModelIsArchiveStatsOutput': sourceReadModelIsArchiveStatsOutput,
    'publicLabelComputed': publicLabelComputed,
    'publicLabel': publicLabel,
    'officialMoveQualityComputed': officialMoveQualityComputed,
    'officialMoveQuality': officialMoveQuality,
    'officialCpLossComputed': officialCpLossComputed,
    'officialWinPercentComputed': officialWinPercentComputed,
    'accuracyComputed': accuracyComputed,
    'acplComputed': acplComputed,
    'classificationComputed': classificationComputed,
    'publicClassifierOutputComputed': publicClassifierOutputComputed,
    'savedAnalysisWritten': savedAnalysisWritten,
    'uiOutputProduced': uiOutputProduced,
    'archiveStatsTouched': archiveStatsTouched,
    'mappingSucceeded': mappingSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase36D': safeForPhase36D,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
