import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_non_ui_developer_preview_consumer.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract_mapper.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_non_ui_developer_preview_consumer_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_read_only_developer_preview_adapter_probe.dart';
import 'package:apex_chess/infrastructure/engine/local_search_eval_probe.dart'
    show defaultLocalSearchEvalProbeTimeout;

typedef AnalyzerNonUiDeveloperPreviewConsumerRunner =
    Future<AnalyzerNonUiDeveloperPreviewConsumerResult> Function(
      AnalyzerLegacyReintegrationRequest request, {
      Duration timeout,
      AnalyzerReadOnlyDeveloperPreviewChainObserver? onLayer,
    });

class LocalAnalyzerProductSafeReviewContractProbe {
  LocalAnalyzerProductSafeReviewContractProbe({
    LocalAnalyzerNonUiDeveloperPreviewConsumerProbe? consumerProbe,
    AnalyzerNonUiDeveloperPreviewConsumerRunner? consumerRunner,
  }) : _consumerRunner =
           consumerRunner ??
           ((request, {timeout = defaultLocalSearchEvalProbeTimeout, onLayer}) {
             return (consumerProbe ??
                     LocalAnalyzerNonUiDeveloperPreviewConsumerProbe())
                 .run(request, timeout: timeout, onLayer: onLayer);
           });

  final AnalyzerNonUiDeveloperPreviewConsumerRunner _consumerRunner;

  Future<AnalyzerProductSafeReviewContract> run(
    AnalyzerLegacyReintegrationRequest request, {
    Duration timeout = defaultLocalSearchEvalProbeTimeout,
    AnalyzerReadOnlyDeveloperPreviewChainObserver? onLayer,
  }) async {
    final consumer = await _consumerRunner(
      request,
      timeout: timeout,
      onLayer: onLayer,
    );
    final contract = mapProductSafeReviewContractFromConsumer(consumer);
    onLayer?.call(
      layer: 'product-safe review contract',
      succeeded: contract.mappingSucceeded && contract.safeForPhase38D,
      failureMessage: contract.failureMessage,
    );
    return contract;
  }
}
