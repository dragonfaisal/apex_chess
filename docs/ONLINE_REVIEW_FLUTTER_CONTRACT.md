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
boundary, plus a conservative selection factory. The default remains disabled
until a later provider/UI activation phase, and HTTP selection requires an
explicit base URI rather than a hardcoded live endpoint.

The domain layer intentionally does not model backend review-draft internals,
governance, storage, schema, reanalysis, Classifier V2, or merge-proposal
objects. Debug data remains compact and limited to omitted section names plus a
small safety summary.

Current fixtures live in `test/fixtures/online_review_product/`. Future Online
Fast/Deep integration should parse backend JSON into DTOs first, then adapt DTOs
into `ApexOnlineReview`, then return that domain model through the repository
boundary.
