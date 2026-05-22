# Online Review Staging Preflight Contract

This document defines the backend-owned compatibility fixture shape for the
future Online Review staging preflight endpoint. It is a contract and fixture
reference only. It does not activate Online Review, does not provide a backend
URL, and does not permit analysis requests.

## Endpoint Policy

- Placeholder path: `/analysis/dev/online-review-product/preflight`
- Method expected by Flutter: `POST`
- Preflight contract version: `online-review-staging-preflight-v1`
- Supported product contract: `online-review-product-v1`

The endpoint is dormant from the Flutter app today. It may only be called by a
future explicitly injected preflight client after staging readiness has already
passed.

## Success Response

```json
{
  "contractVersion": "online-review-staging-preflight-v1",
  "ok": true,
  "backendName": "Apex Online Review",
  "backendVersion": "test-placeholder",
  "supportedProductContract": "online-review-product-v1",
  "serverTime": "2026-01-01T00:00:00Z",
  "warnings": []
}
```

## Allowed Response Fields

- `contractVersion`
- `ok`
- `backendName`
- `backendVersion`
- `supportedProductContract`
- `serverTime`
- `warnings`

Warnings must be safe strings intended for developer diagnostics. Unknown safe
warning strings remain tolerated.

## Forbidden Request Or Response Content

Preflight must not carry:

- raw PGN
- FEN history
- user identifiers
- access tokens
- API keys
- auth secrets
- engine stdout or stderr
- engine logs
- review payloads
- classifier internals
- governance, storage, schema, or reanalysis payloads
- stack traces

Flutter rejects known forbidden payload field names as an incompatible
preflight contract and never surfaces forbidden values in failure messages.

## Failure Mapping

- Wrong `contractVersion`: contract mismatch.
- Missing required fields: contract mismatch.
- Unsupported `supportedProductContract`: contract mismatch.
- `ok: false`: safe backend-unavailable failure.
- Non-JSON response: invalid JSON failure.
- Non-2xx response: safe HTTP-status failure without raw body leakage.
- Network exception or timeout: retryable transport failure.
- Forbidden payload field: forbidden-payload contract failure.

None of these failures unlock analysis requests.

## Private Staging Config Dry-Run

Private staging configuration can be evaluated through the developer command
only when values are supplied through explicit, non-committed environment
variables:

- `APEX_PRIVATE_ONLINE_REVIEW_MODE`
- `APEX_PRIVATE_ONLINE_REVIEW_BASE_URI`
- `APEX_PRIVATE_ONLINE_REVIEW_ALLOW_HTTP`

The dry-run command is:

```sh
dart run tool/online_review_staging_readiness_report.dart --private-config-dry-run
```

This evaluation is still dormant and non-activating. It does not connect to a
backend, does not call the staging preflight client, and does not send an
analysis request. It checks whether the supplied private config would satisfy
the current runtime mode, HTTP gate, base URI, repository config, smoke report,
and staging readiness contract.

Rendered output never prints the full backend address. It records only a
redacted fingerprint and safe typed blockers or warnings. This dry-run is a
precondition for a future manual preflight phase; it is not that phase.

## Manual Preflight Approval Plan

The manual preflight approval plan is a fake-client-only gate for future work.
It consumes the private staging config dry-run result and an optional preflight
result produced by fixture-backed fake-client simulation. The plan builder does
not construct transport clients, does not connect to a backend, and does not
send analysis requests.

Before any future real manual preflight can be considered, a developer must
complete all of these steps:

1. Pass `dart run tool/online_review_build_config_report.dart`.
2. Pass `dart run tool/online_review_staging_readiness_report.dart --all-scenarios`.
3. Pass `dart run tool/online_review_staging_readiness_report.dart --private-config-dry-run`.
4. Pass fake-client preflight fixture simulation against the staging preflight
   contract.
5. Record explicit approval for a future manual preflight phase.

This phase does not approve real network preflight. Real backend connection
remains forbidden, full backend addresses remain out of source and output, and
analysis remains blocked until a later activation phase explicitly integrates
preflight success.

## Real-Network Manual Preflight Design Review

The real-network manual preflight design review approves at most a future
command design. It does not approve real network execution, does not create a
command, and does not connect to a backend in this phase.

The allowed future command shape is:

```sh
dart run tool/online_review_manual_preflight.dart --real-network --i-understand-this-is-private-staging
```

That command file is implemented only as a private, manual, env-only preflight
tool. It is not part of app DI, navigation, public UI, or Online Review
analysis activation.

Future real preflight input policy:

- Private staging values may come only from explicit non-committed
  environment variables.
- Command-line URL arguments are forbidden.
- Hardcoded source URLs are forbidden.
- Committed environment files are forbidden.
- Pull request template values must not carry private configuration.
- CI secrets are not an input source in this phase.
- Public preview configuration is forbidden for private staging preflight.

Before the command may perform a real preflight network call, all of these
checks must pass:

1. `dart run tool/online_review_build_config_report.dart`
2. `dart run tool/online_review_staging_readiness_report.dart --all-scenarios`
3. `dart run tool/online_review_staging_readiness_report.dart --private-config-dry-run`
4. Fake-client preflight fixture simulation.
5. Manual preflight plan approval for a future manual preflight phase.
6. Real preflight design review approval for the future command design.
7. The manual real-network preflight command implementation remains
   non-default, env-only, and private.

Analysis remains blocked until a later activation phase integrates preflight
success. Full backend URLs must not appear in source, docs, tests, logs, or
output.

## Manual Real-Network Preflight Command

The manual real-network preflight command is:

```sh
dart run tool/online_review_manual_preflight.dart --real-network --i-understand-this-is-private-staging
```

The command is private and manual only. It can run only when every prior gate
passes and the developer supplies these explicit, non-committed environment
variables:

- `APEX_PRIVATE_ONLINE_REVIEW_MODE`
- `APEX_PRIVATE_ONLINE_REVIEW_BASE_URI`
- `APEX_PRIVATE_ONLINE_REVIEW_ALLOW_HTTP`
- `APEX_PRIVATE_ONLINE_REVIEW_REAL_PREFLIGHT_APPROVAL`

The approval value must equal exactly:

```text
I_UNDERSTAND_THIS_IS_PRIVATE_STAGING_PREFLIGHT_ONLY
```

Input policy:

- No command-line URL arguments are accepted.
- No real URL appears in source, docs, tests, fixtures, or examples.
- No committed environment file is read.
- CI secrets are not an input source in this phase.
- Only `staging` and `internalTester` modes can proceed.
- The base URI must be HTTPS, non-loopback, non-emulator, non-wildcard, and
  origin-only.
- Public preview is rejected.

Before constructing the HTTP client, the command requires:

1. Build config report passes with `allPassed` and `hardSafetyPassed`.
2. All-scenarios readiness summary passes expectations and hard safety.
3. Private staging config dry-run can proceed.
4. Fake-client preflight compatibility simulation passes.
5. Manual preflight plan approves future manual preflight.
6. Real preflight design review approves the command design.
7. The exact private approval environment value is present.

If any gate fails, no HTTP client is constructed and no network call is made.
After all gates pass, the command performs only the staging preflight POST and
validates `online-review-staging-preflight-v1` plus
`online-review-product-v1`. It sends no PGN, FEN, user data, auth token, engine
data, review payload, analytics, or analysis request.

Output policy:

- The full backend URL is never printed.
- The base URI is rendered only as `scheme=https;host=<redacted-host>`.
- Backend name, backend version, and warnings are printed only when they pass
  safe-string filtering.
- Raw response bodies, stack traces, path, query, fragment, userinfo, tokens,
  PGN, FEN, engine output, and review payload content are not printed.
- Preflight success does not activate Online Review and does not unlock
  analysis by itself.

Exit codes:

- `0`: preflight succeeded and the backend is compatible.
- `2`: preflight ran but failed or returned an incompatible contract.
- `64`: usage error, missing flags, unknown flags, or unsafe CLI URL input.
- `70`: safety gate failed before network.
- `74`: network or timeout failure.

## Private Staging Opt-In Plan

1. Run `dart run tool/online_review_build_config_report.dart`; all scenarios
   and hard safety must pass.
2. Run `dart run tool/online_review_staging_readiness_report.dart --all-scenarios`;
   all fixture expectations and unsafe-output checks must pass.
3. Verify the placeholder staging scenario:
   `dart run tool/online_review_staging_readiness_report.dart --scenario=stagingPlaceholderReady`.
4. Evaluate any future private staging config with
   `dart run tool/online_review_staging_readiness_report.dart --private-config-dry-run`.
5. Pass the fake-client manual preflight approval plan before any real manual
   preflight request.
6. Pass the real-network manual preflight design review before the manual
   command can execute network.
7. Supply any future private staging base URI only through explicit local or
   build configuration outside committed source.
8. Manually invoke preflight only through the explicit env-only command after
   readiness is staging or internal-tester ready.
9. Keep Online Review analysis requests blocked until preflight success is
   integrated into a later activation plan.

No real URL may be committed. No public activation exists. Private staging use
is not part of the current Flutter runtime path.
