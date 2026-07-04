import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';

const analyzerLegacyReintegrationPlayedMoveUci =
    analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci;
const analyzerLegacyReintegrationCandidateMoveUci =
    analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci;
const analyzerLegacyReintegrationDepth =
    analyzerPrivateSingleMoveDraftAnalysisDepth;
const analyzerLegacyReintegrationSource =
    'phase36AControlledLegacyReintegration';
const analyzerLegacyReintegrationModelName =
    'internalLegacyReintegrationSeamDeveloperOnly';
const analyzerLegacyReintegrationModelVersion = 'phase36A.v1';
const analyzerLegacyReintegrationNextRecommendation =
    'implementLegacyMoveResultReadModelMappingWithoutPublicLabels';
const analyzerLegacyReintegrationFailureRecommendation =
    'fixLegacyAnalyzerReintegrationSeam';

class AnalyzerLegacyReintegrationRequest {
  const AnalyzerLegacyReintegrationRequest({
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.source,
  });

  const AnalyzerLegacyReintegrationRequest.controlled({
    AnalyzerMoverColor moverColor = AnalyzerMoverColor.white,
  }) : this(
         playedMoveUci: analyzerLegacyReintegrationPlayedMoveUci,
         candidateMoveUci: analyzerLegacyReintegrationCandidateMoveUci,
         moverColor: moverColor,
         requestedDepth: analyzerLegacyReintegrationDepth,
         source: analyzerLegacyReintegrationSource,
       );

  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String source;
}

class AnalyzerLegacyReintegrationResult {
  const AnalyzerLegacyReintegrationResult({
    required this.legacyReintegrationResultId,
    required this.playedMoveUci,
    required this.candidateMoveUci,
    required this.moverColor,
    required this.requestedDepth,
    required this.reintegrationSource,
    required this.reintegrationModelName,
    required this.reintegrationModelVersion,
    required this.phase35QAnalysisResultId,
    required this.privateSingleMoveDraftAnalysisComputed,
    required this.privateDraftBucket,
    required this.privateDraftReasonCode,
    required this.privateDraftConfidenceTier,
    required this.legacyReintegrationComputed,
    required this.legacyReintegrationIsPublic,
    required this.legacyReintegrationIsProductReview,
    required this.legacyReintegrationIsSavedAnalysis,
    required this.legacyReintegrationIsOfficial,
    required this.legacyPublicLabelProduced,
    required this.legacyOfficialMoveQualityProduced,
    required this.legacySavedAnalysisWritten,
    required this.legacyUiOutputProduced,
    required this.legacyArchiveStatsTouched,
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
    required this.legacyReintegrationProbeSucceeded,
    required this.failureMessage,
    required this.safeForPhase36B,
    required this.nextRecommendation,
    required this.blockers,
    required this.warnings,
  });

  final String legacyReintegrationResultId;
  final String playedMoveUci;
  final String candidateMoveUci;
  final AnalyzerMoverColor moverColor;
  final int requestedDepth;
  final String reintegrationSource;
  final String reintegrationModelName;
  final String reintegrationModelVersion;
  final String phase35QAnalysisResultId;
  final bool privateSingleMoveDraftAnalysisComputed;
  final AnalyzerPrivateDraftBucket privateDraftBucket;
  final AnalyzerPrivateDraftReasonCode privateDraftReasonCode;
  final AnalyzerPrivateDraftConfidenceTier privateDraftConfidenceTier;
  final bool legacyReintegrationComputed;
  final bool legacyReintegrationIsPublic;
  final bool legacyReintegrationIsProductReview;
  final bool legacyReintegrationIsSavedAnalysis;
  final bool legacyReintegrationIsOfficial;
  final bool legacyPublicLabelProduced;
  final bool legacyOfficialMoveQualityProduced;
  final bool legacySavedAnalysisWritten;
  final bool legacyUiOutputProduced;
  final bool legacyArchiveStatsTouched;
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
  final bool legacyReintegrationProbeSucceeded;
  final String? failureMessage;
  final bool safeForPhase36B;
  final String nextRecommendation;
  final List<String> blockers;
  final List<String> warnings;

  Map<String, Object?> toJson() => {
    'legacyReintegrationResultId': legacyReintegrationResultId,
    'playedMoveUci': playedMoveUci,
    'candidateMoveUci': candidateMoveUci,
    'moverColor': moverColor.wire,
    'requestedDepth': requestedDepth,
    'reintegrationSource': reintegrationSource,
    'reintegrationModelName': reintegrationModelName,
    'reintegrationModelVersion': reintegrationModelVersion,
    'phase35QAnalysisResultId': phase35QAnalysisResultId,
    'privateSingleMoveDraftAnalysisComputed':
        privateSingleMoveDraftAnalysisComputed,
    'privateDraftBucket': privateDraftBucket.wire,
    'privateDraftReasonCode': privateDraftReasonCode.wire,
    'privateDraftConfidenceTier': privateDraftConfidenceTier.wire,
    'legacyReintegrationComputed': legacyReintegrationComputed,
    'legacyReintegrationIsPublic': legacyReintegrationIsPublic,
    'legacyReintegrationIsProductReview': legacyReintegrationIsProductReview,
    'legacyReintegrationIsSavedAnalysis': legacyReintegrationIsSavedAnalysis,
    'legacyReintegrationIsOfficial': legacyReintegrationIsOfficial,
    'legacyPublicLabelProduced': legacyPublicLabelProduced,
    'legacyOfficialMoveQualityProduced': legacyOfficialMoveQualityProduced,
    'legacySavedAnalysisWritten': legacySavedAnalysisWritten,
    'legacyUiOutputProduced': legacyUiOutputProduced,
    'legacyArchiveStatsTouched': legacyArchiveStatsTouched,
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
    'legacyReintegrationProbeSucceeded': legacyReintegrationProbeSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase36B': safeForPhase36B,
    'nextRecommendation': nextRecommendation,
    'blockers': blockers,
    'warnings': warnings,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String renderMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Apex Legacy Analyzer Reintegration Probe')
      ..writeln()
      ..writeln(
        'phase: Phase 36A - Legacy Analyzer Reintegration Against Private Draft Contract',
      )
      ..writeln('legacyReintegrationResultId: $legacyReintegrationResultId')
      ..writeln('playedMoveUci: $playedMoveUci')
      ..writeln('candidateMoveUci: $candidateMoveUci')
      ..writeln('moverColor: ${moverColor.wire}')
      ..writeln('requestedDepth: $requestedDepth')
      ..writeln('reintegrationSource: $reintegrationSource')
      ..writeln('reintegrationModelName: $reintegrationModelName')
      ..writeln('reintegrationModelVersion: $reintegrationModelVersion')
      ..writeln('phase35QAnalysisResultId: $phase35QAnalysisResultId')
      ..writeln(
        'privateSingleMoveDraftAnalysisComputed: '
        '$privateSingleMoveDraftAnalysisComputed',
      )
      ..writeln('privateDraftBucket: ${privateDraftBucket.wire}')
      ..writeln('privateDraftReasonCode: ${privateDraftReasonCode.wire}')
      ..writeln(
        'privateDraftConfidenceTier: ${privateDraftConfidenceTier.wire}',
      )
      ..writeln('legacyReintegrationComputed: $legacyReintegrationComputed')
      ..writeln('legacyReintegrationIsPublic: $legacyReintegrationIsPublic')
      ..writeln(
        'legacyReintegrationIsProductReview: '
        '$legacyReintegrationIsProductReview',
      )
      ..writeln(
        'legacyReintegrationIsSavedAnalysis: '
        '$legacyReintegrationIsSavedAnalysis',
      )
      ..writeln('legacyReintegrationIsOfficial: $legacyReintegrationIsOfficial')
      ..writeln('legacyPublicLabelProduced: $legacyPublicLabelProduced')
      ..writeln(
        'legacyOfficialMoveQualityProduced: '
        '$legacyOfficialMoveQualityProduced',
      )
      ..writeln('legacySavedAnalysisWritten: $legacySavedAnalysisWritten')
      ..writeln('legacyUiOutputProduced: $legacyUiOutputProduced')
      ..writeln('legacyArchiveStatsTouched: $legacyArchiveStatsTouched')
      ..writeln('publicLabelComputed: $publicLabelComputed')
      ..writeln('publicLabel: ${publicLabel ?? 'none'}')
      ..writeln('officialMoveQualityComputed: $officialMoveQualityComputed')
      ..writeln('officialMoveQuality: ${officialMoveQuality ?? 'none'}')
      ..writeln('officialCpLossComputed: $officialCpLossComputed')
      ..writeln('officialWinPercentComputed: $officialWinPercentComputed')
      ..writeln('accuracyComputed: $accuracyComputed')
      ..writeln('acplComputed: $acplComputed')
      ..writeln('classificationComputed: $classificationComputed')
      ..writeln(
        'publicClassifierOutputComputed: $publicClassifierOutputComputed',
      )
      ..writeln(
        'legacyReintegrationProbeSucceeded: '
        '$legacyReintegrationProbeSucceeded',
      )
      ..writeln('failureMessage: ${failureMessage ?? 'none'}')
      ..writeln('safeForPhase36B: $safeForPhase36B')
      ..writeln('nextRecommendation: $nextRecommendation')
      ..writeln()
      ..writeln('## Blockers');
    _writeList(buffer, blockers);
    buffer
      ..writeln()
      ..writeln('## Warnings');
    _writeList(buffer, warnings);
    buffer
      ..writeln()
      ..writeln('## Safety Notes')
      ..writeln('- Developer-only legacy reintegration seam')
      ..writeln('- Wraps Phase 35Q private output only')
      ..writeln('- Does not call legacy public classifier or saved analysis')
      ..writeln(
        '- No public labels, official metrics, UI, archive, or backend',
      );
    return buffer.toString();
  }

  static void _writeList(StringBuffer buffer, List<String> values) {
    if (values.isEmpty) {
      buffer.writeln('- none');
      return;
    }
    for (final value in values) {
      buffer.writeln('- $value');
    }
  }
}

AnalyzerLegacyReintegrationResult evaluateAnalyzerLegacyReintegration({
  required AnalyzerLegacyReintegrationRequest request,
  required AnalyzerPrivateSingleMoveDraftAnalysisResult phase35Q,
}) {
  const legacyReintegrationIsPublic = false;
  const legacyReintegrationIsProductReview = false;
  const legacyReintegrationIsSavedAnalysis = false;
  const legacyReintegrationIsOfficial = false;
  const legacyPublicLabelProduced = false;
  const legacyOfficialMoveQualityProduced = false;
  const legacySavedAnalysisWritten = false;
  const legacyUiOutputProduced = false;
  const legacyArchiveStatsTouched = false;

  final resultId = _legacyResultId(request);
  final publicStringsClean = !_containsForbiddenPublicString(
    phase35Q,
    resultId,
  );
  final phase35QClean =
      phase35Q.privateSingleMoveDraftAnalysisProbeSucceeded &&
      phase35Q.safeForPhase36A &&
      phase35Q.privateSingleMoveDraftAnalysisComputed &&
      !phase35Q.privateSingleMoveDraftAnalysisIsPublic &&
      !phase35Q.privateSingleMoveDraftAnalysisIsProductReview &&
      !phase35Q.privateSingleMoveDraftAnalysisIsSavedAnalysis &&
      !phase35Q.privateSingleMoveDraftAnalysisIsOfficial &&
      !phase35Q.privateDraftClassifierIsPublic &&
      !phase35Q.privateDraftClassifierIsOfficialMoveQuality &&
      !phase35Q.privateDraftClassifierIsPublicLabel &&
      !phase35Q.publicLabelComputed &&
      phase35Q.publicLabel == null &&
      !phase35Q.officialMoveQualityComputed &&
      phase35Q.officialMoveQuality == null &&
      !phase35Q.officialCpLossComputed &&
      !phase35Q.officialWinPercentComputed &&
      !phase35Q.accuracyComputed &&
      !phase35Q.acplComputed &&
      !phase35Q.classificationComputed &&
      !phase35Q.publicClassifierOutputComputed &&
      !phase35Q.savedAnalysisWritten &&
      !phase35Q.uiOutputProduced;
  final legacyReintegrationComputed = phase35QClean && publicStringsClean;
  final succeeded =
      legacyReintegrationComputed &&
      !legacyReintegrationIsPublic &&
      !legacyReintegrationIsProductReview &&
      !legacyReintegrationIsSavedAnalysis &&
      !legacyReintegrationIsOfficial &&
      !legacyPublicLabelProduced &&
      !legacyOfficialMoveQualityProduced &&
      !legacySavedAnalysisWritten &&
      !legacyUiOutputProduced &&
      !legacyArchiveStatsTouched;

  final blockers = <String>[];
  if (!succeeded) {
    blockers.add('Legacy reintegration proof is blocked.');
  }
  if (!phase35Q.privateSingleMoveDraftAnalysisProbeSucceeded) {
    blockers.add('Phase 35Q private draft analysis did not succeed.');
  }
  if (!publicStringsClean) {
    blockers.add('Public label string appeared in legacy reintegration.');
  }
  blockers.addAll(phase35Q.blockers.map((b) => 'phase35Q: $b'));

  final warnings = <String>[];
  if (!succeeded) {
    warnings.add('This is not a successful legacy reintegration proof.');
    warnings.add('Do not proceed to Phase 36B yet.');
  }
  warnings.addAll(phase35Q.warnings.map((w) => 'phase35Q: $w'));

  return AnalyzerLegacyReintegrationResult(
    legacyReintegrationResultId: resultId,
    playedMoveUci: request.playedMoveUci,
    candidateMoveUci: request.candidateMoveUci,
    moverColor: request.moverColor,
    requestedDepth: request.requestedDepth,
    reintegrationSource: request.source,
    reintegrationModelName: analyzerLegacyReintegrationModelName,
    reintegrationModelVersion: analyzerLegacyReintegrationModelVersion,
    phase35QAnalysisResultId: phase35Q.analysisResultId,
    privateSingleMoveDraftAnalysisComputed:
        phase35Q.privateSingleMoveDraftAnalysisComputed,
    privateDraftBucket: phase35Q.privateDraftBucket,
    privateDraftReasonCode: phase35Q.privateDraftReasonCode,
    privateDraftConfidenceTier: phase35Q.privateDraftConfidenceTier,
    legacyReintegrationComputed: legacyReintegrationComputed,
    legacyReintegrationIsPublic: legacyReintegrationIsPublic,
    legacyReintegrationIsProductReview: legacyReintegrationIsProductReview,
    legacyReintegrationIsSavedAnalysis: legacyReintegrationIsSavedAnalysis,
    legacyReintegrationIsOfficial: legacyReintegrationIsOfficial,
    legacyPublicLabelProduced: legacyPublicLabelProduced,
    legacyOfficialMoveQualityProduced: legacyOfficialMoveQualityProduced,
    legacySavedAnalysisWritten: legacySavedAnalysisWritten,
    legacyUiOutputProduced: legacyUiOutputProduced,
    legacyArchiveStatsTouched: legacyArchiveStatsTouched,
    publicLabelComputed: phase35Q.publicLabelComputed,
    publicLabel: phase35Q.publicLabel,
    officialMoveQualityComputed: phase35Q.officialMoveQualityComputed,
    officialMoveQuality: phase35Q.officialMoveQuality,
    officialCpLossComputed: phase35Q.officialCpLossComputed,
    officialWinPercentComputed: phase35Q.officialWinPercentComputed,
    accuracyComputed: phase35Q.accuracyComputed,
    acplComputed: phase35Q.acplComputed,
    classificationComputed: phase35Q.classificationComputed,
    publicClassifierOutputComputed: phase35Q.publicClassifierOutputComputed,
    legacyReintegrationProbeSucceeded: succeeded,
    failureMessage: succeeded
        ? null
        : phase35Q.failureMessage ??
              'Legacy reintegration proof did not succeed.',
    safeForPhase36B: succeeded,
    nextRecommendation: succeeded
        ? analyzerLegacyReintegrationNextRecommendation
        : analyzerLegacyReintegrationFailureRecommendation,
    blockers: List.unmodifiable(blockers.toSet().toList()..sort()),
    warnings: List.unmodifiable(warnings.toSet().toList()..sort()),
  );
}

String _legacyResultId(AnalyzerLegacyReintegrationRequest request) {
  return [
    'phase36A',
    request.playedMoveUci,
    request.candidateMoveUci,
    request.moverColor.wire,
    'depth${request.requestedDepth}',
  ].join(':');
}

bool _containsForbiddenPublicString(
  AnalyzerPrivateSingleMoveDraftAnalysisResult phase35Q,
  String resultId,
) {
  final values = <String?>[
    phase35Q.publicLabel,
    phase35Q.officialMoveQuality,
    phase35Q.privateDraftBucket.wire,
    phase35Q.privateDraftReasonCode.wire,
    phase35Q.privateDraftConfidenceTier.wire,
    resultId,
  ].whereType<String>();
  return values.any(_forbiddenPublicStrings.contains);
}

const _forbiddenPublicStrings = <String>{
  'Brilliant',
  'Great',
  'Best',
  'Excellent',
  'Good',
  'Book',
  'Inaccuracy',
  'Mistake',
  'Miss',
  'Blunder',
  'Checkmate',
};
