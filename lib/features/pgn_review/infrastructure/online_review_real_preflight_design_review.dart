/// Design approval review for the manual real-network Online Review preflight
/// command.
///
/// This contract approves only the command design. It never constructs
/// transport clients, executes commands, reads environment values, connects to
/// a backend, or sends analysis requests.
library;

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_manual_preflight_plan.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_private_staging_config_evaluator.dart';

const onlineReviewRealPreflightDesignReviewVersion =
    'online-review-real-preflight-design-review-v1';

const onlineReviewFutureRealPreflightCommandName =
    'dart run tool/online_review_manual_preflight.dart --real-network '
    '--i-understand-this-is-private-staging';

enum OnlineReviewRealPreflightDesignReviewStatus {
  notRequested,
  blocked,
  needsApproval,
  approvedForFutureRealPreflightDesign,
}

enum OnlineReviewRealPreflightDesignReviewBlocker {
  privateDryRunMissing,
  privateDryRunNotReady,
  fakeClientPlanMissing,
  fakeClientPlanNotApproved,
  realNetworkStillForbidden,
  missingFutureCommandDesign,
  arbitraryUrlInputForbidden,
  publicPreviewForbidden,
  analysisRequestForbidden,
  defaultHttpForbidden,
  urlLoggingForbidden,
  unknown,
}

enum OnlineReviewRealPreflightDesignReviewWarning {
  designOnly,
  noNetworkInThisPhase,
  envOnlyPrivateConfig,
  noUrlInSource,
  noAnalysisRequest,
  futurePhaseRequiresExplicitHumanApproval,
}

class OnlineReviewRealPreflightDesignReview {
  OnlineReviewRealPreflightDesignReview({
    required this.version,
    required this.status,
    required this.approvedForRealNetworkExecutionNow,
    required this.approvedForFutureRealPreflightDesign,
    required this.privateDryRunReady,
    required this.fakeClientPlanApproved,
    required this.allowedFutureCommandName,
    required List<String> allowedInputSources,
    required List<String> forbiddenInputSources,
    required List<String> requiredChecks,
    required List<OnlineReviewRealPreflightDesignReviewBlocker> blockers,
    required List<OnlineReviewRealPreflightDesignReviewWarning> warnings,
    required this.requiredNextStep,
  }) : allowedInputSources = List.unmodifiable(allowedInputSources),
       forbiddenInputSources = List.unmodifiable(forbiddenInputSources),
       requiredChecks = List.unmodifiable(requiredChecks),
       blockers = List.unmodifiable(blockers),
       warnings = List.unmodifiable(warnings);

  final String version;
  final OnlineReviewRealPreflightDesignReviewStatus status;
  final bool approvedForRealNetworkExecutionNow;
  final bool approvedForFutureRealPreflightDesign;
  final bool privateDryRunReady;
  final bool fakeClientPlanApproved;
  final String? allowedFutureCommandName;
  final List<String> allowedInputSources;
  final List<String> forbiddenInputSources;
  final List<String> requiredChecks;
  final List<OnlineReviewRealPreflightDesignReviewBlocker> blockers;
  final List<OnlineReviewRealPreflightDesignReviewWarning> warnings;
  final String requiredNextStep;
}

OnlineReviewRealPreflightDesignReview
buildOnlineReviewRealPreflightDesignReview({
  required OnlineReviewPrivateStagingConfigEvaluation? privateDryRun,
  required OnlineReviewManualPreflightPlan? manualPreflightPlan,
  required bool explicitApprovalForFutureRealPreflightDesign,
}) {
  final privateDryRunReady =
      privateDryRun?.canProceedToManualPreflight ?? false;
  final fakeClientPlanApproved =
      manualPreflightPlan?.approvedForFutureManualPreflight ?? false;
  final blockers = _blockers(
    privateDryRun: privateDryRun,
    manualPreflightPlan: manualPreflightPlan,
    privateDryRunReady: privateDryRunReady,
    fakeClientPlanApproved: fakeClientPlanApproved,
    explicitApprovalForFutureRealPreflightDesign:
        explicitApprovalForFutureRealPreflightDesign,
  );
  final status = _status(
    privateDryRun: privateDryRun,
    manualPreflightPlan: manualPreflightPlan,
    privateDryRunReady: privateDryRunReady,
    fakeClientPlanApproved: fakeClientPlanApproved,
    explicitApprovalForFutureRealPreflightDesign:
        explicitApprovalForFutureRealPreflightDesign,
  );

  return OnlineReviewRealPreflightDesignReview(
    version: onlineReviewRealPreflightDesignReviewVersion,
    status: status,
    approvedForRealNetworkExecutionNow: false,
    approvedForFutureRealPreflightDesign:
        status ==
        OnlineReviewRealPreflightDesignReviewStatus
            .approvedForFutureRealPreflightDesign,
    privateDryRunReady: privateDryRunReady,
    fakeClientPlanApproved: fakeClientPlanApproved,
    allowedFutureCommandName:
        status ==
            OnlineReviewRealPreflightDesignReviewStatus
                .approvedForFutureRealPreflightDesign
        ? onlineReviewFutureRealPreflightCommandName
        : null,
    allowedInputSources: onlineReviewRealPreflightAllowedInputSources,
    forbiddenInputSources: onlineReviewRealPreflightForbiddenInputSources,
    requiredChecks: onlineReviewRealPreflightRequiredChecks,
    blockers: blockers,
    warnings: const [
      OnlineReviewRealPreflightDesignReviewWarning.designOnly,
      OnlineReviewRealPreflightDesignReviewWarning.noNetworkInThisPhase,
      OnlineReviewRealPreflightDesignReviewWarning.envOnlyPrivateConfig,
      OnlineReviewRealPreflightDesignReviewWarning.noUrlInSource,
      OnlineReviewRealPreflightDesignReviewWarning.noAnalysisRequest,
      OnlineReviewRealPreflightDesignReviewWarning
          .futurePhaseRequiresExplicitHumanApproval,
    ],
    requiredNextStep: _requiredNextStep(status, blockers),
  );
}

const onlineReviewRealPreflightAllowedInputSources = [
  'Explicit non-committed environment variables only.',
  'APEX_PRIVATE_ONLINE_REVIEW_MODE',
  'APEX_PRIVATE_ONLINE_REVIEW_BASE_URI',
  'APEX_PRIVATE_ONLINE_REVIEW_ALLOW_HTTP',
];

const onlineReviewRealPreflightForbiddenInputSources = [
  'Command-line URL arguments such as --baseUri.',
  'Hardcoded source URL.',
  'Committed environment files.',
  'Pull request template values.',
  'CI secrets in this phase.',
  'Public preview configuration.',
];

const onlineReviewRealPreflightRequiredChecks = [
  'Build config report passes with allPassed and hardSafetyPassed.',
  'All-scenarios staging readiness report passes.',
  'Private staging config dry-run passes.',
  'Fake-client preflight fixture simulation passes.',
  'Manual preflight plan approves future manual preflight.',
  'Real preflight design review approves future command design.',
  'Manual real-network preflight command remains private, env-only, and '
      'no-default-activation.',
];

String renderOnlineReviewRealPreflightDesignReviewMarkdown(
  OnlineReviewRealPreflightDesignReview review,
) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Real Preflight Design Review')
    ..writeln()
    ..writeln('* Version: `${review.version}`')
    ..writeln('* Status: ${review.status.name}')
    ..writeln(
      '* Approved for real network execution now: '
      '${_yesNo(review.approvedForRealNetworkExecutionNow)}',
    )
    ..writeln(
      '* Approved for future real preflight design: '
      '${_yesNo(review.approvedForFutureRealPreflightDesign)}',
    )
    ..writeln('* Private dry-run ready: ${_yesNo(review.privateDryRunReady)}')
    ..writeln(
      '* Fake-client plan approved: '
      '${_yesNo(review.fakeClientPlanApproved)}',
    )
    ..writeln(
      '* Allowed future command name: '
      '${review.allowedFutureCommandName ?? 'design-only-not-approved'}',
    )
    ..writeln('* Required next step: ${review.requiredNextStep}')
    ..writeln()
    ..writeln('## Allowed Input Sources')
    ..writeln();

  for (final source in review.allowedInputSources) {
    buffer.writeln('* $source');
  }

  buffer
    ..writeln()
    ..writeln('## Forbidden Input Sources')
    ..writeln();

  for (final source in review.forbiddenInputSources) {
    buffer.writeln('* $source');
  }

  buffer
    ..writeln()
    ..writeln('## Required Checks')
    ..writeln();

  for (final check in review.requiredChecks) {
    buffer.writeln('* $check');
  }

  buffer
    ..writeln()
    ..writeln('## Blockers')
    ..writeln();

  if (review.blockers.isEmpty) {
    buffer.writeln('* None');
  } else {
    for (final blocker in review.blockers) {
      buffer.writeln('* `${blocker.name}`');
    }
  }

  buffer
    ..writeln()
    ..writeln('## Warnings')
    ..writeln();

  for (final warning in review.warnings) {
    buffer.writeln('* `${warning.name}`');
  }

  buffer
    ..writeln()
    ..writeln('## Safety Notes')
    ..writeln()
    ..writeln('* This review performs no network call.')
    ..writeln('* This review does not execute the manual preflight command.')
    ..writeln('* Analysis requests remain blocked.')
    ..writeln(
      '* Full backend URLs must not appear in source, docs, tests, logs, or '
      'output.',
    );

  return buffer.toString();
}

List<OnlineReviewRealPreflightDesignReviewBlocker> _blockers({
  required OnlineReviewPrivateStagingConfigEvaluation? privateDryRun,
  required OnlineReviewManualPreflightPlan? manualPreflightPlan,
  required bool privateDryRunReady,
  required bool fakeClientPlanApproved,
  required bool explicitApprovalForFutureRealPreflightDesign,
}) {
  final blockers = <OnlineReviewRealPreflightDesignReviewBlocker>[];

  if (privateDryRun == null) {
    blockers.add(
      OnlineReviewRealPreflightDesignReviewBlocker.privateDryRunMissing,
    );
  } else if (!privateDryRunReady) {
    blockers.add(
      OnlineReviewRealPreflightDesignReviewBlocker.privateDryRunNotReady,
    );
    if (privateDryRun.readinessStatus.name == 'publicPreviewNotAllowed') {
      blockers.add(
        OnlineReviewRealPreflightDesignReviewBlocker.publicPreviewForbidden,
      );
    }
  }

  if (manualPreflightPlan == null) {
    blockers.add(
      OnlineReviewRealPreflightDesignReviewBlocker.fakeClientPlanMissing,
    );
  } else if (!fakeClientPlanApproved) {
    blockers.add(
      OnlineReviewRealPreflightDesignReviewBlocker.fakeClientPlanNotApproved,
    );
  }

  if (privateDryRunReady &&
      fakeClientPlanApproved &&
      !explicitApprovalForFutureRealPreflightDesign) {
    blockers.add(
      OnlineReviewRealPreflightDesignReviewBlocker.missingFutureCommandDesign,
    );
  }

  return _dedupe(blockers);
}

OnlineReviewRealPreflightDesignReviewStatus _status({
  required OnlineReviewPrivateStagingConfigEvaluation? privateDryRun,
  required OnlineReviewManualPreflightPlan? manualPreflightPlan,
  required bool privateDryRunReady,
  required bool fakeClientPlanApproved,
  required bool explicitApprovalForFutureRealPreflightDesign,
}) {
  if (privateDryRun == null && manualPreflightPlan == null) {
    return OnlineReviewRealPreflightDesignReviewStatus.notRequested;
  }
  if (!privateDryRunReady || !fakeClientPlanApproved) {
    return OnlineReviewRealPreflightDesignReviewStatus.blocked;
  }
  if (!explicitApprovalForFutureRealPreflightDesign) {
    return OnlineReviewRealPreflightDesignReviewStatus.needsApproval;
  }
  return OnlineReviewRealPreflightDesignReviewStatus
      .approvedForFutureRealPreflightDesign;
}

String _requiredNextStep(
  OnlineReviewRealPreflightDesignReviewStatus status,
  List<OnlineReviewRealPreflightDesignReviewBlocker> blockers,
) {
  if (blockers.contains(
    OnlineReviewRealPreflightDesignReviewBlocker.privateDryRunMissing,
  )) {
    return 'Run the private staging config dry-run before real preflight '
        'design review.';
  }
  if (blockers.contains(
    OnlineReviewRealPreflightDesignReviewBlocker.privateDryRunNotReady,
  )) {
    return 'Pass the private staging config dry-run before reviewing any real '
        'preflight command design.';
  }
  if (blockers.contains(
    OnlineReviewRealPreflightDesignReviewBlocker.fakeClientPlanMissing,
  )) {
    return 'Build the fake-client manual preflight plan before real preflight '
        'design review.';
  }
  if (blockers.contains(
    OnlineReviewRealPreflightDesignReviewBlocker.fakeClientPlanNotApproved,
  )) {
    return 'Approve the fake-client manual preflight plan before real '
        'preflight design review.';
  }
  if (status == OnlineReviewRealPreflightDesignReviewStatus.needsApproval) {
    return 'Record explicit human approval for the future real preflight '
        'command design; do not execute network in this phase.';
  }
  if (status ==
      OnlineReviewRealPreflightDesignReviewStatus
          .approvedForFutureRealPreflightDesign) {
    return 'Command design is approved; real preflight may run only through '
        'the explicit env-only manual command after every gate passes.';
  }
  return 'Complete private dry-run, fake-client manual preflight approval, '
      'and explicit design approval before any future command design proceeds.';
}

List<T> _dedupe<T>(List<T> values) {
  final seen = <T>{};
  return [
    for (final value in values)
      if (seen.add(value)) value,
  ];
}

String _yesNo(bool value) => value ? 'yes' : 'no';
