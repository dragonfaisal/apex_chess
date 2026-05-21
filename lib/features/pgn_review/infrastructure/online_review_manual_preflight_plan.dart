/// Fake-client-only approval plan for future manual Online Review preflight.
///
/// This layer is an approval contract, not activation. It consumes a private
/// staging dry-run evaluation and an optional preflight result produced outside
/// the builder. It never constructs transport clients, reads environment
/// values, connects to a backend, or sends analysis requests.
library;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_private_staging_config_evaluator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';

const onlineReviewManualPreflightPlanVersion =
    'online-review-manual-preflight-plan-v1';

enum OnlineReviewManualPreflightApprovalStatus {
  notRequested,
  blocked,
  readyForFakeClientSimulation,
  fakeClientSimulationPassed,
  approvedForFutureManualPreflight,
}

enum OnlineReviewManualPreflightBlocker {
  privateDryRunNotReady,
  stagingReadinessNotReady,
  smokeReportNotPassed,
  hardSafetyNotPassed,
  publicPreviewMode,
  missingExplicitApproval,
  preflightContractMismatch,
  preflightTransportFailed,
  forbiddenPayloadDetected,
  realNetworkForbiddenInThisPhase,
  unknown,
}

enum OnlineReviewManualPreflightWarning {
  fakeClientOnly,
  noRealBackendConnection,
  noAnalysisRequest,
  approvalRequired,
  keepUrlOutOfSource,
  manualPreflightFuturePhaseOnly,
}

class OnlineReviewManualPreflightPlan {
  OnlineReviewManualPreflightPlan({
    required this.version,
    required this.status,
    required this.approvedForRealNetworkPreflight,
    required this.approvedForFutureManualPreflight,
    required this.dryRunCanProceed,
    required this.fakeClientPreflightSuccess,
    required List<OnlineReviewManualPreflightBlocker> blockers,
    required List<OnlineReviewManualPreflightWarning> warnings,
    required this.requiredNextStep,
  }) : blockers = List.unmodifiable(blockers),
       warnings = List.unmodifiable(warnings);

  final String version;
  final OnlineReviewManualPreflightApprovalStatus status;
  final bool approvedForRealNetworkPreflight;
  final bool approvedForFutureManualPreflight;
  final bool dryRunCanProceed;
  final bool fakeClientPreflightSuccess;
  final List<OnlineReviewManualPreflightBlocker> blockers;
  final List<OnlineReviewManualPreflightWarning> warnings;
  final String requiredNextStep;
}

OnlineReviewManualPreflightPlan buildOnlineReviewManualPreflightPlan({
  required OnlineReviewPrivateStagingConfigEvaluation privateDryRun,
  OnlineReviewStagingPreflightResult? fakeClientPreflightResult,
  required bool explicitApprovalForFutureManualPreflight,
}) {
  final fakeClientPreflightSuccess =
      fakeClientPreflightResult?.isSuccess ?? false;
  final blockers = _blockers(
    privateDryRun: privateDryRun,
    fakeClientPreflightResult: fakeClientPreflightResult,
    fakeClientPreflightSuccess: fakeClientPreflightSuccess,
    explicitApprovalForFutureManualPreflight:
        explicitApprovalForFutureManualPreflight,
  );
  final status = _status(
    privateDryRun: privateDryRun,
    fakeClientPreflightResult: fakeClientPreflightResult,
    fakeClientPreflightSuccess: fakeClientPreflightSuccess,
    explicitApprovalForFutureManualPreflight:
        explicitApprovalForFutureManualPreflight,
    blockers: blockers,
  );

  return OnlineReviewManualPreflightPlan(
    version: onlineReviewManualPreflightPlanVersion,
    status: status,
    approvedForRealNetworkPreflight: false,
    approvedForFutureManualPreflight:
        status ==
        OnlineReviewManualPreflightApprovalStatus
            .approvedForFutureManualPreflight,
    dryRunCanProceed: privateDryRun.canProceedToManualPreflight,
    fakeClientPreflightSuccess: fakeClientPreflightSuccess,
    blockers: blockers,
    warnings: const [
      OnlineReviewManualPreflightWarning.fakeClientOnly,
      OnlineReviewManualPreflightWarning.noRealBackendConnection,
      OnlineReviewManualPreflightWarning.noAnalysisRequest,
      OnlineReviewManualPreflightWarning.approvalRequired,
      OnlineReviewManualPreflightWarning.keepUrlOutOfSource,
      OnlineReviewManualPreflightWarning.manualPreflightFuturePhaseOnly,
    ],
    requiredNextStep: _requiredNextStep(status, blockers),
  );
}

Future<OnlineReviewStagingPreflightResult>
runFakeOnlineReviewStagingPreflightSimulation({
  required OnlineReviewStagingPreflightClient client,
  required OnlineReviewStagingBackendReadiness readiness,
}) {
  return client.check(readiness);
}

String renderOnlineReviewManualPreflightPlanMarkdown(
  OnlineReviewManualPreflightPlan plan,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Manual Preflight Approval Plan')
    ..writeln()
    ..writeln('* Version: `${plan.version}`')
    ..writeln('* Status: ${plan.status.name}')
    ..writeln(
      '* Approved for future manual preflight: '
      '${_yesNo(plan.approvedForFutureManualPreflight)}',
    )
    ..writeln(
      '* Approved for real network preflight: '
      '${_yesNo(plan.approvedForRealNetworkPreflight)}',
    )
    ..writeln('* Private dry-run can proceed: ${_yesNo(plan.dryRunCanProceed)}')
    ..writeln(
      '* Fake-client preflight success: '
      '${_yesNo(plan.fakeClientPreflightSuccess)}',
    )
    ..writeln('* Required next step: ${plan.requiredNextStep}')
    ..writeln()
    ..writeln('## Blockers')
    ..writeln();

  if (plan.blockers.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final blocker in plan.blockers) {
      buffer.writeln('* `${blocker.name}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();

  for (final warning in plan.warnings) {
    buffer.writeln('* `${warning.name}`');
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* Fake-client simulation only.')
    ..writeln('* No real backend connection is approved.')
    ..writeln('* No analysis request is sent.')
    ..writeln('* Full backend URL is not printed.')
    ..writeln('* Manual preflight remains a future explicit phase.');

  return buffer.toString();
}

List<OnlineReviewManualPreflightBlocker> _blockers({
  required OnlineReviewPrivateStagingConfigEvaluation privateDryRun,
  required OnlineReviewStagingPreflightResult? fakeClientPreflightResult,
  required bool fakeClientPreflightSuccess,
  required bool explicitApprovalForFutureManualPreflight,
}) {
  final blockers = <OnlineReviewManualPreflightBlocker>[];

  if (!privateDryRun.canProceedToManualPreflight) {
    blockers.add(OnlineReviewManualPreflightBlocker.privateDryRunNotReady);
  }
  if (!_readinessIsReady(privateDryRun.readinessStatus)) {
    blockers.add(OnlineReviewManualPreflightBlocker.stagingReadinessNotReady);
  }
  if (!privateDryRun.smokeReportAllPassed) {
    blockers.add(OnlineReviewManualPreflightBlocker.smokeReportNotPassed);
  }
  if (!privateDryRun.smokeReportHardSafetyPassed) {
    blockers.add(OnlineReviewManualPreflightBlocker.hardSafetyNotPassed);
  }
  if (privateDryRun.readinessStatus ==
      OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed) {
    blockers.add(OnlineReviewManualPreflightBlocker.publicPreviewMode);
  }

  if (privateDryRun.canProceedToManualPreflight &&
      fakeClientPreflightResult != null &&
      !fakeClientPreflightSuccess) {
    blockers.add(_preflightBlocker(fakeClientPreflightResult));
  }

  if (privateDryRun.canProceedToManualPreflight &&
      fakeClientPreflightSuccess &&
      !explicitApprovalForFutureManualPreflight) {
    blockers.add(OnlineReviewManualPreflightBlocker.missingExplicitApproval);
  }

  return _dedupe(blockers);
}

OnlineReviewManualPreflightApprovalStatus _status({
  required OnlineReviewPrivateStagingConfigEvaluation privateDryRun,
  required OnlineReviewStagingPreflightResult? fakeClientPreflightResult,
  required bool fakeClientPreflightSuccess,
  required bool explicitApprovalForFutureManualPreflight,
  required List<OnlineReviewManualPreflightBlocker> blockers,
}) {
  if (!privateDryRun.isDryRun) {
    return OnlineReviewManualPreflightApprovalStatus.notRequested;
  }
  if (!privateDryRun.canProceedToManualPreflight) {
    return OnlineReviewManualPreflightApprovalStatus.blocked;
  }
  if (fakeClientPreflightResult == null) {
    return OnlineReviewManualPreflightApprovalStatus
        .readyForFakeClientSimulation;
  }
  if (!fakeClientPreflightSuccess || blockers.isNotEmpty) {
    return OnlineReviewManualPreflightApprovalStatus.blocked;
  }
  if (!explicitApprovalForFutureManualPreflight) {
    return OnlineReviewManualPreflightApprovalStatus.blocked;
  }
  return OnlineReviewManualPreflightApprovalStatus
      .approvedForFutureManualPreflight;
}

OnlineReviewManualPreflightBlocker _preflightBlocker(
  OnlineReviewStagingPreflightResult result,
) {
  final failureCode = result.failure?.code;
  return switch (failureCode) {
    OnlineReviewStagingPreflightFailureCode.contractMismatch ||
    OnlineReviewStagingPreflightFailureCode.invalidJson =>
      OnlineReviewManualPreflightBlocker.preflightContractMismatch,
    OnlineReviewStagingPreflightFailureCode.forbiddenPayload =>
      OnlineReviewManualPreflightBlocker.forbiddenPayloadDetected,
    OnlineReviewStagingPreflightFailureCode.networkError ||
    OnlineReviewStagingPreflightFailureCode.timeout ||
    OnlineReviewStagingPreflightFailureCode.httpStatus ||
    OnlineReviewStagingPreflightFailureCode.unexpected =>
      OnlineReviewManualPreflightBlocker.preflightTransportFailed,
    OnlineReviewStagingPreflightFailureCode.readinessNotReady ||
    OnlineReviewStagingPreflightFailureCode.missingBaseUri ||
    OnlineReviewStagingPreflightFailureCode.httpNotAllowed ||
    OnlineReviewStagingPreflightFailureCode.unsafeBaseUri ||
    OnlineReviewStagingPreflightFailureCode.smokeReportFailed =>
      OnlineReviewManualPreflightBlocker.stagingReadinessNotReady,
    null => OnlineReviewManualPreflightBlocker.unknown,
  };
}

bool _readinessIsReady(OnlineReviewStagingReadinessStatus status) {
  return status == OnlineReviewStagingReadinessStatus.readyForStagingSmoke ||
      status == OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke;
}

String _requiredNextStep(
  OnlineReviewManualPreflightApprovalStatus status,
  List<OnlineReviewManualPreflightBlocker> blockers,
) {
  if (blockers.contains(
    OnlineReviewManualPreflightBlocker.privateDryRunNotReady,
  )) {
    return 'Pass the private staging config dry-run before fake-client '
        'preflight simulation.';
  }
  if (status ==
      OnlineReviewManualPreflightApprovalStatus.readyForFakeClientSimulation) {
    return 'Run fake-client preflight fixture simulation, then rebuild the '
        'manual preflight plan.';
  }
  if (blockers.contains(
    OnlineReviewManualPreflightBlocker.preflightContractMismatch,
  )) {
    return 'Fix fake-client preflight contract compatibility before approval.';
  }
  if (blockers.contains(
    OnlineReviewManualPreflightBlocker.forbiddenPayloadDetected,
  )) {
    return 'Remove forbidden payload content from the fake preflight contract '
        'before approval.';
  }
  if (blockers.contains(
    OnlineReviewManualPreflightBlocker.preflightTransportFailed,
  )) {
    return 'Fix fake-client preflight failure mapping before approval; do not '
        'retry real network in this phase.';
  }
  if (blockers.contains(
    OnlineReviewManualPreflightBlocker.missingExplicitApproval,
  )) {
    return 'Record explicit future manual preflight approval after fake-client '
        'simulation passes; real network remains forbidden in this phase.';
  }
  if (status ==
      OnlineReviewManualPreflightApprovalStatus
          .approvedForFutureManualPreflight) {
    return 'Future manual preflight is approved only as a later explicit '
        'phase; real network remains forbidden now.';
  }
  return 'Complete build config report, all-scenarios readiness, private '
      'dry-run, fake-client simulation, and explicit approval before any '
      'future manual preflight.';
}

List<T> _dedupe<T>(List<T> values) {
  final seen = <T>{};
  return [
    for (final value in values)
      if (seen.add(value)) value,
  ];
}

String _yesNo(bool value) => value ? 'yes' : 'no';
