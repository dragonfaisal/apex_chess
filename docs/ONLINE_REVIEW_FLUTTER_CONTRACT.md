# Online Review Flutter Contract

`online-review-product-v1` is consumed across three boundaries:

- `OnlineReviewProductResponseDto` and related DTOs parse backend product JSON.
- `ApexOnlineReview` and related domain models are app-facing objects for
  future providers, state, and UI.
- `OnlineReviewProductRepository` returns those domain models to future
  app-facing flows.

`OnlineReviewProductAdapter` is pure and non-live. It performs only DTO-to-domain
mapping, with no HTTP calls, provider activation, caching, persistence, or UI.

`OnlineReviewProductRepository` is the next app-facing boundary. Callers submit
`ApexOnlineReviewRequest` objects and receive repository results that expose
`ApexOnlineReview` domain models rather than transport DTOs. The repository now
has fixture-backed test support and an HTTP implementation behind the same
boundary, plus a conservative selection factory. It is registered in the app
dependency graph, but the default provider mode remains disabled until a later
provider/UI activation phase. HTTP selection requires an explicit base URI
rather than a hardcoded live endpoint.

`OnlineReviewProductUseCase` now wraps that repository boundary for future
state/UI layers. Future app-facing flows should call the use-case instead of
transport DTOs or HTTP repositories directly. The registered default path still
resolves to disabled behavior until a later explicit feature-activation phase.

`OnlineReviewProductController` now wraps the use-case with a non-UI async state
model for future screens. Future UI should consume controller state rather than
calling DTOs, repositories, or HTTP implementations directly. The controller is
registered but remains dormant from visible app flows while the default path is
still disabled.

`OnlineReviewProductViewModelMapper` now turns controller state into a
presentation-safe view model with stable keys, summary rows, move rows, notices,
and compact debug data. Future UI should consume that view model rather than raw
controller, use-case, repository, or DTO internals. No widgets or user-facing
activation are part of this layer.

`onlineReviewProductViewModelProvider` is now the screen-ready seam for future
UI. It watches controller state, applies the mapper, and exposes presentation
data only. Future widgets should watch that provider instead of reaching into
controller, use-case, repository, or DTO layers directly; the seam is still
dormant and not user-facing.

`onlineReviewProductActionsProvider` is the matching presentation action seam.
Future UI should read from `onlineReviewProductViewModelProvider` and submit,
retry, or reset through this facade instead of calling controller methods
directly. The facade is still dormant from visible screens, and the default path
remains disabled.

`OnlineReviewProductShell` is now the first guarded UI composition layer over
those seams. It renders presentation-safe idle/loading/success/failure states
and delegates submit, retry, and reset back through the actions facade. The
shell is not wired into main navigation; future full UI should keep using the
same read/write seams.

`OnlineReviewProductDevHarness` adds an explicit dev/test activation seam for
the shell. The feature gate is disabled by default, the shell stays non-public
unless the harness is deliberately enabled, and enabling that harness remains
separate from enabling any HTTP repository configuration.

`OnlineReviewRuntimeGateConfig` and `OnlineReviewActivationDecision` now define
the runtime activation policy. UI visibility, HTTP enablement, base URI
presence, debug harness access, and public availability are separate decisions.
The default remains disabled, a backend base URI must be explicit, and no public
activation is added.

`OnlineReviewRuntimeConfigAdapter` can now build runtime gate config from safe
environment/config inputs. The app root reads Dart build defines through a thin
bridge, but an empty environment still resolves to the same disabled runtime
config. A backend base URI must be supplied explicitly, HTTP still requires its
own explicit gate, and shell visibility/debug harness access remain separate
from transport selection. Public activation still does not exist.

Non-production dev harness example, with no backend transport enabled:

```sh
flutter run --dart-define=APEX_ONLINE_REVIEW_MODE=devHarness \
  --dart-define=APEX_ONLINE_REVIEW_ALLOW_DEBUG_HARNESS=true
```

`OnlineReviewBuildConfigMatrix` defines deterministic verification scenarios for
disabled, dev harness, staging, internal tester, and public preview policy
shapes. It checks expected runtime config, activation decisions, repository
mode, warnings, and unsafe combinations using placeholder `.example.test`
values only. This matrix is a safety/governance layer for future build
configuration work; it does not activate public navigation, supply real backend
URLs, or make Online Review user-facing.

`OnlineReviewBuildConfigReport` renders a deterministic build-mode smoke report
from that matrix for developer and future CI inspection. It summarizes scenario
pass/fail counts, shell/HTTP/debug/public gates, repository mode, warnings, and
a hard safety verdict. The report is observability for configuration hygiene
only; it does not read live build defines, provide real URLs, activate Online
Review, or change runtime behavior.

`OnlineReviewStagingBackendReadiness` defines the next readiness contract for
future staging/backend work. It is pure and readiness-only: it consumes an
activation decision, repository config, and smoke report verdict, then returns
typed status, blockers, warnings, and a stable developer next step. Staging or
internal tester modes are considered ready only when an explicit HTTPS base URI,
the HTTP gate, repository HTTP config, and smoke report safety verdict all
agree. Public preview is not staging-ready in this phase, and readiness output
records only a redacted host fingerprint rather than a full backend URL.

## Build-mode safety verification

The CI/developer smoke report command is:

```sh
dart run tool/online_review_build_config_report.dart
```

The command prints the deterministic Markdown report and exits non-zero if the
matrix or hard safety checks fail. It does not read live build defines,
instantiate providers or HTTP clients, activate Online Review, or include real
backend URLs.

This check is required before any staging backend, internal tester, or public
preview configuration work. The expected current result is that all scenarios
pass, the hard safety verdict passes, the default mode remains disabled, and
the report includes no real backend URLs. Passing this check is verification
only; it does not activate Online Review or make any route user-facing.

PRs touching Online Review runtime gates, environment config, repository
activation, shell visibility, public preview logic, or backend base URI handling
must reference this smoke command in the PR checklist. For PRs unrelated to
Online Review, the checklist items may be marked N/A in the PR description.

### Future CI adoption plan

1. Phase 1: PR checklist requires the smoke command manually.
2. Phase 2: When a repo CI convention exists, add the smoke command as a
   pre-build verification step.
3. Phase 3: Before staging or public preview, require the smoke command,
   focused `test/features/pgn_review/` tests, and source guardrails proving no
   real backend URLs or activation flags were added.

The domain layer intentionally does not model backend review-draft internals,
governance, storage, schema, reanalysis, Classifier V2, or merge-proposal
objects. Debug data remains compact and limited to omitted section names plus a
small safety summary.

Current fixtures live in `test/fixtures/online_review_product/`. Future Online
Fast/Deep integration should parse backend JSON into DTOs first, then adapt DTOs
into `ApexOnlineReview`, then return that domain model through the repository
boundary, application use-case, controller state, and presentation view model.
