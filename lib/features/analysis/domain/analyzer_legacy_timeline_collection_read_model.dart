import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';

const analyzerLegacyTimelineCollectionReadModelSource =
    'phase36DLegacyTimelineCollectionReadModelMapper';
const analyzerLegacyTimelineCollectionReadModelVersion = 'phase36D.v1';
const analyzerLegacyTimelineCollectionReadModelNextRecommendation =
    'implementLegacyReviewSummaryReadModelWithoutPublicLabels';
const analyzerLegacyTimelineCollectionReadModelFailureRecommendation =
    'fixLegacyTimelineCollectionReadModelMapping';

class AnalyzerLegacyTimelineCollectionReadModel {
  const AnalyzerLegacyTimelineCollectionReadModel({
    required this.timelineCollectionId,
    required this.timelineCollectionSource,
    required this.timelineCollectionVersion,
    required this.sourceEntryCount,
    required this.mappedEntryCount,
    required this.blockedEntryCount,
    required this.timelineCollectionComputed,
    required this.timelineCollectionIsPublic,
    required this.timelineCollectionIsProductReview,
    required this.timelineCollectionIsSavedAnalysis,
    required this.timelineCollectionIsOfficial,
    required this.timelineCollectionIsUiOutput,
    required this.timelineCollectionIsArchiveStatsOutput,
    required this.timelineCollectionIsFullGameAnalysis,
    required this.timelineCollectionIsProductTimeline,
    required this.timelineCollectionIsDeveloperOnly,
    required this.entries,
    required this.entryIds,
    required this.allEntriesAreSingleMoveOnly,
    required this.allEntriesArePrivateSingleMoveDraft,
    required this.allEntriesSafe,
    required this.entriesSortedByOrderKey,
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
    required this.safeForPhase36E,
    required this.nextRecommendation,
  });

  final String timelineCollectionId;
  final String timelineCollectionSource;
  final String timelineCollectionVersion;
  final int sourceEntryCount;
  final int mappedEntryCount;
  final int blockedEntryCount;
  final bool timelineCollectionComputed;
  final bool timelineCollectionIsPublic;
  final bool timelineCollectionIsProductReview;
  final bool timelineCollectionIsSavedAnalysis;
  final bool timelineCollectionIsOfficial;
  final bool timelineCollectionIsUiOutput;
  final bool timelineCollectionIsArchiveStatsOutput;
  final bool timelineCollectionIsFullGameAnalysis;
  final bool timelineCollectionIsProductTimeline;
  final bool timelineCollectionIsDeveloperOnly;
  final List<AnalyzerLegacyTimelineEntryReadModel> entries;
  final List<String> entryIds;
  final bool allEntriesAreSingleMoveOnly;
  final bool allEntriesArePrivateSingleMoveDraft;
  final bool allEntriesSafe;
  final bool entriesSortedByOrderKey;
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
  final bool safeForPhase36E;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'timelineCollectionId': timelineCollectionId,
    'timelineCollectionSource': timelineCollectionSource,
    'timelineCollectionVersion': timelineCollectionVersion,
    'sourceEntryCount': sourceEntryCount,
    'mappedEntryCount': mappedEntryCount,
    'blockedEntryCount': blockedEntryCount,
    'timelineCollectionComputed': timelineCollectionComputed,
    'timelineCollectionIsPublic': timelineCollectionIsPublic,
    'timelineCollectionIsProductReview': timelineCollectionIsProductReview,
    'timelineCollectionIsSavedAnalysis': timelineCollectionIsSavedAnalysis,
    'timelineCollectionIsOfficial': timelineCollectionIsOfficial,
    'timelineCollectionIsUiOutput': timelineCollectionIsUiOutput,
    'timelineCollectionIsArchiveStatsOutput':
        timelineCollectionIsArchiveStatsOutput,
    'timelineCollectionIsFullGameAnalysis':
        timelineCollectionIsFullGameAnalysis,
    'timelineCollectionIsProductTimeline': timelineCollectionIsProductTimeline,
    'timelineCollectionIsDeveloperOnly': timelineCollectionIsDeveloperOnly,
    'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
    'entryIds': entryIds,
    'allEntriesAreSingleMoveOnly': allEntriesAreSingleMoveOnly,
    'allEntriesArePrivateSingleMoveDraft': allEntriesArePrivateSingleMoveDraft,
    'allEntriesSafe': allEntriesSafe,
    'entriesSortedByOrderKey': entriesSortedByOrderKey,
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
    'safeForPhase36E': safeForPhase36E,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
