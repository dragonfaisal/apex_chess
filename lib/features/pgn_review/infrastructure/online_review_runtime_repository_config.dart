/// Safe repository configuration derivation from the Online Review runtime gate.
///
/// This keeps transport selection explicit: HTTP is selected only when the
/// activation decision already allows it and provides a base URI.
library;

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';

OnlineReviewRepositoryConfig onlineReviewRepositoryConfigFromActivationDecision(
  OnlineReviewActivationDecision decision, {
  Duration timeout = const Duration(seconds: 10),
  Map<String, String> extraHeaders = const {},
}) {
  final baseUri = decision.baseUri;
  if (!decision.canUseHttp || baseUri == null) {
    return OnlineReviewRepositoryConfig.disabled();
  }

  return OnlineReviewRepositoryConfig.http(
    baseUri: baseUri,
    timeout: timeout,
    extraHeaders: extraHeaders,
  );
}
