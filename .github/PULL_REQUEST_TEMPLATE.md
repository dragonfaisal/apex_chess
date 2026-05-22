## Summary

- TBD

## Verification

- [ ] I ran the relevant checks for this change.
- [ ] I updated docs or tests when behavior or release safety changed.

## Online Review Safety

For PRs unrelated to Online Review runtime, config, repository, shell,
public-preview, or backend base URI handling, mark these items N/A in the PR
description.

- [ ] If this PR touches Online Review runtime gate, environment config,
  activation policy, repository selection, shell visibility,
  public-preview logic, or backend base URI handling, I ran:
  `dart run tool/online_review_build_config_report.dart`
- [ ] If this PR touches Online Review staging readiness, I also ran:
  `dart run tool/online_review_staging_readiness_report.dart`
- [ ] If this PR touches Online Review staging scenario/readiness logic, I also
  ran:
  `dart run tool/online_review_staging_readiness_report.dart --all-scenarios`
- [ ] If this PR touches Online Review staging preflight transport,
  compatibility fixtures, or contract docs, I ran the focused preflight tests
  and kept default HTTP disabled.
- [ ] If this PR touches private staging config dry-run evaluation, I ran the
  focused evaluator tests and kept private config env-only, redacted, and
  non-activating.
- [ ] If this PR touches manual preflight approval planning, I ran the focused
  manual preflight plan tests and kept it fake-client-only.
- [ ] If this PR touches real preflight design review, I ran the focused design
  review tests and kept real network execution unimplemented.
- [ ] If this PR touches the manual real-network preflight command, I ran the
  focused command tests and kept it private, env-only, no-default-HTTP, and
  URL-redacted.
- [ ] If this PR touches the manual preflight runbook or result review, I ran
  the focused result-review tests and kept raw URLs, private values, and command
  output out of stored summaries.
- [ ] The smoke report passed with `allPassed == true` and
  `hardSafetyPassed == true`.
- [ ] This PR does not add hardcoded loopback, emulator, staging, or production
  backend URLs.
- [ ] This PR does not enable live HTTP by default.
- [ ] This PR does not make Online Review public or user-facing without an
  explicit approved phase.
- [ ] Shell visibility and HTTP enablement remain separate decisions.
- [ ] Base URI remains explicit and gated.
