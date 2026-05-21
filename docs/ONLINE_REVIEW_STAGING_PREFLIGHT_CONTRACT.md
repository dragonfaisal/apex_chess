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

## Private Staging Opt-In Plan

1. Run `dart run tool/online_review_build_config_report.dart`; all scenarios
   and hard safety must pass.
2. Run `dart run tool/online_review_staging_readiness_report.dart --all-scenarios`;
   all fixture expectations and unsafe-output checks must pass.
3. Verify the placeholder staging scenario:
   `dart run tool/online_review_staging_readiness_report.dart --scenario=stagingPlaceholderReady`.
4. Supply any future private staging base URI only through explicit local or
   build configuration outside committed source.
5. Manually invoke preflight only in a future explicit phase after readiness
   is staging or internal-tester ready.
6. Keep Online Review analysis requests blocked until preflight success is
   integrated into a later activation plan.

No real URL may be committed. No public activation exists. Private staging use
is future work, not part of the current Flutter runtime path.
