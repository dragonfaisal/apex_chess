/// Version stamps for analysis/cache invalidation.
///
/// Keep this in core so the analysis model, archive cache, and analyzer
/// pipeline all agree on the same classifier/schema version without making
/// core entities import feature-layer archive types.
library;

/// Bump whenever move-classification behavior or persisted per-ply analysis
/// metadata changes enough that old cached timelines should be recomputed.
const int kApexClassifierVersion = 6;

/// Human-readable classifier profile written into debug metadata.
const String kApexClassifierProfile = 'apex_trustworthy_offline_v6';

/// Bump when the tactical verifier output contract changes. This lets
/// Phase 21 invalidate pre-product-architecture cached reviews without
/// pretending the classifier thresholds changed.
const int kApexTacticalVerifierVersion = 3;

/// Bump when the persisted analysis result/cache schema changes.
const int kApexAnalysisSchemaVersion = 4;

/// Embedded opening-intelligence policy and persisted evidence contract.
///
/// Version 2 binds analysis compatibility to the expected opening artifact
/// content while keeping the classifier policy and analysis schema unchanged.
const int kApexOpeningBookVersion = 2;

/// Compatibility value for historic, transport, and synthetic timelines that
/// do not carry the Chapter 5 artifact/evidence contract.
const int kApexLegacyOpeningBookVersion = 1;
