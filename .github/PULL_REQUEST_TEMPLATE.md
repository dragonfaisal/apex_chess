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
- [ ] The smoke report passed with `allPassed == true` and
  `hardSafetyPassed == true`.
- [ ] This PR does not add hardcoded loopback, emulator, staging, or production
  backend URLs.
- [ ] This PR does not enable live HTTP by default.
- [ ] This PR does not make Online Review public or user-facing without an
  explicit approved phase.
- [ ] Shell visibility and HTTP enablement remain separate decisions.
- [ ] Base URI remains explicit and gated.
