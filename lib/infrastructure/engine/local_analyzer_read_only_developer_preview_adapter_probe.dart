import 'package:apex_chess/features/analysis/domain/analyzer_developer_debug_preview_contract_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_move_result_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_read_only_developer_preview_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_legacy_reintegration_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerLegacyReintegrationRunner =
    Future<AnalyzerLegacyReintegrationResult> Function(
      AnalyzerLegacyReintegrationRequest request, {
      Duration timeout,
    });

typedef AnalyzerReadOnlyDeveloperPreviewChainObserver =
    void Function({
      required String layer,
      required bool succeeded,
      String? failureMessage,
    });

class LocalAnalyzerReadOnlyDeveloperPreviewAdapterProbe {
  LocalAnalyzerReadOnlyDeveloperPreviewAdapterProbe({
    LocalAnalyzerLegacyReintegrationProbe? legacyReintegrationProbe,
    AnalyzerLegacyReintegrationRunner? legacyReintegrationRunner,
  }) : _legacyReintegrationRunner =
           legacyReintegrationRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout}) {
             return (legacyReintegrationProbe ??
                     LocalAnalyzerLegacyReintegrationProbe())
                 .run(request, timeout: timeout);
           });

  final AnalyzerLegacyReintegrationRunner _legacyReintegrationRunner;

  Future<AnalyzerReadOnlyDeveloperPreviewAdapterResult> run(
    AnalyzerLegacyReintegrationRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
    AnalyzerReadOnlyDeveloperPreviewChainObserver? onLayer,
  }) async {
    final legacyReintegration = await _legacyReintegrationRunner(
      request,
      timeout: timeout,
    );
    _notify(
      onLayer,
      layer: 'legacy reintegration',
      succeeded:
          legacyReintegration.legacyReintegrationProbeSucceeded &&
          legacyReintegration.safeForPhase36B,
      failureMessage: legacyReintegration.failureMessage,
    );

    final moveResult = mapLegacyReintegrationToMoveResultReadModel(
      legacyReintegration,
    );
    _notify(
      onLayer,
      layer: 'move result read model',
      succeeded: moveResult.mappingSucceeded && moveResult.safeForPhase36C,
      failureMessage: moveResult.failureMessage,
    );

    final timelineEntry = mapLegacyMoveResultToTimelineEntryReadModel(
      moveResult,
    );
    _notify(
      onLayer,
      layer: 'timeline entry',
      succeeded:
          timelineEntry.mappingSucceeded && timelineEntry.safeForPhase36D,
      failureMessage: timelineEntry.failureMessage,
    );

    final timelineCollection = mapLegacyTimelineEntriesToCollectionReadModel([
      timelineEntry,
    ]);
    _notify(
      onLayer,
      layer: 'timeline collection',
      succeeded:
          timelineCollection.mappingSucceeded &&
          timelineCollection.safeForPhase36E,
      failureMessage: timelineCollection.failureMessage,
    );

    final reviewSummary = mapLegacyTimelineCollectionToReviewSummaryReadModel(
      timelineCollection,
    );
    _notify(
      onLayer,
      layer: 'review summary',
      succeeded:
          reviewSummary.mappingSucceeded && reviewSummary.safeForPhase36F,
      failureMessage: reviewSummary.failureMessage,
    );

    final reviewEnvelope =
        mapLegacyCollectionAndSummaryToReviewEnvelopeReadModel(
          collection: timelineCollection,
          summary: reviewSummary,
        );
    _notify(
      onLayer,
      layer: 'review envelope',
      succeeded:
          reviewEnvelope.mappingSucceeded && reviewEnvelope.safeForPhase36G,
      failureMessage: reviewEnvelope.failureMessage,
    );

    final developerSnapshot =
        mapLegacyReviewEnvelopeToDeveloperReviewEnvelopeSnapshot(
          reviewEnvelope,
        );
    _notify(
      onLayer,
      layer: 'developer snapshot',
      succeeded:
          developerSnapshot.mappingSucceeded &&
          developerSnapshot.safeForPhase36I,
      failureMessage: developerSnapshot.failureMessage,
    );

    final exportContract = mapDeveloperReviewEnvelopeSnapshotToExportContract(
      developerSnapshot,
    );
    _notify(
      onLayer,
      layer: 'export contract',
      succeeded:
          exportContract.mappingSucceeded && exportContract.safeForPhase36K,
      failureMessage: exportContract.failureMessage,
    );

    final debugReadFacade = mapDeveloperSnapshotExportContractToDebugReadFacade(
      exportContract,
    );
    _notify(
      onLayer,
      layer: 'debug read facade',
      succeeded:
          debugReadFacade.mappingSucceeded && debugReadFacade.safeForPhase36M,
      failureMessage: debugReadFacade.failureMessage,
    );

    final debugPreviewContract =
        mapDeveloperSnapshotDebugReadFacadeToDebugPreviewContract(
          debugReadFacade,
        );
    _notify(
      onLayer,
      layer: 'debug preview contract',
      succeeded:
          debugPreviewContract.mappingSucceeded &&
          debugPreviewContract.safeForPhase36O,
      failureMessage: debugPreviewContract.failureMessage,
    );

    final adapter =
        adaptDeveloperDebugPreviewContractToReadOnlyDeveloperPreview(
          debugPreviewContract,
        );
    _notify(
      onLayer,
      layer: 'read-only developer preview adapter',
      succeeded: adapter.mappingSucceeded && adapter.safeForPhase37B,
      failureMessage: adapter.failureMessage,
    );

    return adapter;
  }

  void _notify(
    AnalyzerReadOnlyDeveloperPreviewChainObserver? observer, {
    required String layer,
    required bool succeeded,
    required String? failureMessage,
  }) {
    observer?.call(
      layer: layer,
      succeeded: succeeded,
      failureMessage: failureMessage,
    );
  }
}
