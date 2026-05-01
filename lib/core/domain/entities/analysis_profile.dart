/// User-facing analysis profiles and their deterministic local budgets.
library;

enum AnalysisProfileId {
  fastReview('fast_review'),
  deepReview('deep_review'),
  offlineReview('offline_review');

  const AnalysisProfileId(this.wire);
  final String wire;

  static AnalysisProfileId fromWire(String? raw) => values.firstWhere(
    (v) => v.wire == raw,
    orElse: () => AnalysisProfileId.deepReview,
  );
}

enum AnalysisProviderIntent { onlineFirst, localOnly }

class AnalysisProfile {
  const AnalysisProfile({
    required this.id,
    required this.label,
    required this.providerIntent,
    required this.purpose,
    required this.cacheRequired,
    required this.localDepth,
    required this.localMovetimeMs,
    required this.localMultiPv,
    required this.candidateVerificationEnabled,
    this.warning,
  });

  final AnalysisProfileId id;
  final String label;
  final AnalysisProviderIntent providerIntent;
  final String purpose;
  final bool cacheRequired;
  final int localDepth;
  final int localMovetimeMs;
  final int localMultiPv;
  final bool candidateVerificationEnabled;
  final String? warning;

  static const fastReview = AnalysisProfile(
    id: AnalysisProfileId.fastReview,
    label: 'Fast Review',
    providerIntent: AnalysisProviderIntent.onlineFirst,
    purpose: 'Fast, stable review for most games.',
    cacheRequired: true,
    localDepth: 14,
    localMovetimeMs: 900,
    localMultiPv: 1,
    candidateVerificationEnabled: false,
  );

  static const deepReview = AnalysisProfile(
    id: AnalysisProfileId.deepReview,
    label: 'Deep Review',
    providerIntent: AnalysisProviderIntent.onlineFirst,
    purpose: 'Stronger tactical review.',
    cacheRequired: true,
    localDepth: 22,
    localMovetimeMs: 6000,
    localMultiPv: 3,
    candidateVerificationEnabled: true,
  );

  static const offlineReview = AnalysisProfile(
    id: AnalysisProfileId.offlineReview,
    label: 'Offline Review',
    providerIntent: AnalysisProviderIntent.localOnly,
    purpose: 'Local fallback when online review is unavailable.',
    cacheRequired: true,
    localDepth: 18,
    localMovetimeMs: 2500,
    localMultiPv: 3,
    candidateVerificationEnabled: true,
    warning: 'Runs on this device and may be slower.',
  );

  static const values = <AnalysisProfile>[
    fastReview,
    deepReview,
    offlineReview,
  ];

  static AnalysisProfile byId(AnalysisProfileId id) =>
      values.firstWhere((p) => p.id == id, orElse: () => deepReview);

  static AnalysisProfile fromWire(String? raw) =>
      byId(AnalysisProfileId.fromWire(raw));
}
