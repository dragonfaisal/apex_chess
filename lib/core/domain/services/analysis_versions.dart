/// Version stamps for analysis/cache invalidation.
///
/// Keep this in core so the analysis model, archive cache, and analyzer
/// pipeline all agree on the same classifier/schema version without making
/// core entities import feature-layer archive types.
library;

/// Bump whenever move-classification behavior or persisted per-ply analysis
/// metadata changes enough that old cached timelines should be recomputed.
const int kApexClassifierVersion = 4;

/// Human-readable classifier profile written into debug metadata.
const String kApexClassifierProfile = 'apex_tactical_v4';
