import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

const analyzerLegacyMoveResultReadModelSource =
    'phase36BLegacyMoveResultReadModelMapper';
const analyzerLegacyMoveResultReadModelVersion = 'phase36B.v1';
const analyzerLegacyMoveResultReadModelNextRecommendation =
    'implementLegacyTimelineEntryReadModelMappingWithoutPublicLabels';
const analyzerLegacyMoveResultReadModelFailureRecommendation =
    'fixLegacyMoveResultReadModelMapping';

class AnalyzerLegacyMoveResultReadModel {
  const AnalyzerLegacyMoveResultReadModel({
    required this.readModelId,
    required this.legacyReintegrationResultId,
    required this.phase35QAnalysisResultId,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.readModelSource,
    required this.readModelVersion,
    required this.privateDraftBucket,
    required this.privateDraftReasonCode,
    required this.privateDraftConfidenceTier,
    required this.sourceLegacyReintegrationComputed,
    required this.readModelComputed,
    required this.readModelIsPublic,
    required this.readModelIsProductReview,
    required this.readModelIsSavedAnalysis,
    required this.readModelIsOfficial,
    required this.readModelIsUiOutput,
    required this.readModelIsArchiveStatsOutput,
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
    required this.safeForPhase36C,
    required this.nextRecommendation,
  });

  final String readModelId;
  final String legacyReintegrationResultId;
  final String phase35QAnalysisResultId;
  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String readModelSource;
  final String readModelVersion;
  final AnalyzerPrivateDraftBucket privateDraftBucket;
  final AnalyzerPrivateDraftReasonCode privateDraftReasonCode;
  final AnalyzerPrivateDraftConfidenceTier privateDraftConfidenceTier;
  final bool sourceLegacyReintegrationComputed;
  final bool readModelComputed;
  final bool readModelIsPublic;
  final bool readModelIsProductReview;
  final bool readModelIsSavedAnalysis;
  final bool readModelIsOfficial;
  final bool readModelIsUiOutput;
  final bool readModelIsArchiveStatsOutput;
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
  final bool safeForPhase36C;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'readModelId': readModelId,
    'legacyReintegrationResultId': legacyReintegrationResultId,
    'phase35QAnalysisResultId': phase35QAnalysisResultId,
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'readModelSource': readModelSource,
    'readModelVersion': readModelVersion,
    'privateDraftBucket': privateDraftBucket.wire,
    'privateDraftReasonCode': privateDraftReasonCode.wire,
    'privateDraftConfidenceTier': privateDraftConfidenceTier.wire,
    'sourceLegacyReintegrationComputed': sourceLegacyReintegrationComputed,
    'readModelComputed': readModelComputed,
    'readModelIsPublic': readModelIsPublic,
    'readModelIsProductReview': readModelIsProductReview,
    'readModelIsSavedAnalysis': readModelIsSavedAnalysis,
    'readModelIsOfficial': readModelIsOfficial,
    'readModelIsUiOutput': readModelIsUiOutput,
    'readModelIsArchiveStatsOutput': readModelIsArchiveStatsOutput,
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
    'safeForPhase36C': safeForPhase36C,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
