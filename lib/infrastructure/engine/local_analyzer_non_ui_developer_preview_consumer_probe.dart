import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_non_ui_developer_preview_consumer.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_read_only_developer_preview_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_read_only_developer_preview_adapter_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerReadOnlyDeveloperPreviewAdapterRunner =
    Future<AnalyzerReadOnlyDeveloperPreviewAdapterResult> Function(
      AnalyzerLegacyReintegrationRequest request, {
      Duration timeout,
      AnalyzerReadOnlyDeveloperPreviewChainObserver? onLayer,
    });

class LocalAnalyzerNonUiDeveloperPreviewConsumerProbe {
  LocalAnalyzerNonUiDeveloperPreviewConsumerProbe({
    LocalAnalyzerReadOnlyDeveloperPreviewAdapterProbe? adapterProbe,
    AnalyzerReadOnlyDeveloperPreviewAdapterRunner? adapterRunner,
  }) : _adapterRunner =
           adapterRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout, onLayer}) {
             return (adapterProbe ??
                     LocalAnalyzerReadOnlyDeveloperPreviewAdapterProbe())
                 .run(request, timeout: timeout, onLayer: onLayer);
           });

  final AnalyzerReadOnlyDeveloperPreviewAdapterRunner _adapterRunner;

  Future<AnalyzerNonUiDeveloperPreviewConsumerResult> run(
    AnalyzerLegacyReintegrationRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
    AnalyzerReadOnlyDeveloperPreviewChainObserver? onLayer,
  }) async {
    final adapter = await _adapterRunner(
      request,
      timeout: timeout,
      onLayer: onLayer,
    );
    final consumer = consumeReadOnlyDeveloperPreviewAdapterResult(adapter);
    onLayer?.call(
      layer: 'non-UI developer preview consumer',
      succeeded: consumer.mappingSucceeded && consumer.safeForPhase37E,
      failureMessage: consumer.failureMessage,
    );
    return consumer;
  }
}
