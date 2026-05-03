/// Conservative username identity matching for player/opponent search.
library;

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

enum ApexIdentityMatchTier { none, exact, startsWith, contains }

enum ApexIdentityResolutionKind {
  noMatch,
  confirmedUser,
  confirmedOpponent,
  ambiguousConnectedSubstring,
  lowConfidence,
}

class ApexIdentityCandidate {
  const ApexIdentityCandidate({required this.handle, required this.platform});

  final String handle;
  final String platform;
}

class ApexIdentityResolution {
  const ApexIdentityResolution({
    required this.kind,
    required this.tier,
    required this.query,
    this.candidate,
  });

  final ApexIdentityResolutionKind kind;
  final ApexIdentityMatchTier tier;
  final String query;
  final ApexIdentityCandidate? candidate;

  bool get isConfirmedOpponent =>
      kind == ApexIdentityResolutionKind.confirmedOpponent;
  bool get isConfirmedUser => kind == ApexIdentityResolutionKind.confirmedUser;
  bool get isAmbiguous =>
      kind == ApexIdentityResolutionKind.ambiguousConnectedSubstring ||
      kind == ApexIdentityResolutionKind.lowConfidence;

  String get copy => switch (kind) {
    ApexIdentityResolutionKind.confirmedUser => ApexCopy.connectedAccountNotice,
    ApexIdentityResolutionKind.ambiguousConnectedSubstring =>
      ApexCopy.chooseExactPlayer,
    ApexIdentityResolutionKind.lowConfidence => ApexCopy.chooseExactPlayer,
    ApexIdentityResolutionKind.noMatch => ApexCopy.noExactPlayerFound,
    ApexIdentityResolutionKind.confirmedOpponent => '',
  };
}

class ApexIdentityMatcher {
  const ApexIdentityMatcher();

  String normalizeHandle(String raw) {
    return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  ApexIdentityMatchTier matchTier(String query, String handle) {
    final q = normalizeHandle(query);
    final h = normalizeHandle(handle);
    if (q.isEmpty || h.isEmpty) return ApexIdentityMatchTier.none;
    if (q == h) return ApexIdentityMatchTier.exact;
    if (h.startsWith(q)) return ApexIdentityMatchTier.startsWith;
    if (h.contains(q)) return ApexIdentityMatchTier.contains;
    return ApexIdentityMatchTier.none;
  }

  ApexIdentityResolution resolveOpponentQuery({
    required String query,
    required String platform,
    ApexIdentityCandidate? connectedAccount,
    List<ApexIdentityCandidate> candidates = const [],
    bool excludeConnectedAccount = true,
  }) {
    final normalizedQuery = normalizeHandle(query);
    if (normalizedQuery.isEmpty) {
      return ApexIdentityResolution(
        kind: ApexIdentityResolutionKind.noMatch,
        tier: ApexIdentityMatchTier.none,
        query: query,
      );
    }

    final connected = connectedAccount;
    if (connected != null &&
        _samePlatform(platform, connected.platform) &&
        excludeConnectedAccount) {
      final connectedTier = matchTier(query, connected.handle);
      if (connectedTier == ApexIdentityMatchTier.exact) {
        return ApexIdentityResolution(
          kind: ApexIdentityResolutionKind.confirmedUser,
          tier: connectedTier,
          query: query,
          candidate: connected,
        );
      }
      if (connectedTier == ApexIdentityMatchTier.contains ||
          connectedTier == ApexIdentityMatchTier.startsWith) {
        return ApexIdentityResolution(
          kind: ApexIdentityResolutionKind.ambiguousConnectedSubstring,
          tier: connectedTier,
          query: query,
          candidate: connected,
        );
      }
    }

    ApexIdentityResolution? lowConfidence;
    for (final candidate in candidates) {
      if (!_samePlatform(platform, candidate.platform)) continue;
      if (connected != null &&
          excludeConnectedAccount &&
          _sameHandle(candidate.handle, connected.handle) &&
          _samePlatform(candidate.platform, connected.platform)) {
        continue;
      }
      final tier = matchTier(query, candidate.handle);
      if (tier == ApexIdentityMatchTier.none) continue;
      if (tier == ApexIdentityMatchTier.exact ||
          tier == ApexIdentityMatchTier.startsWith) {
        return ApexIdentityResolution(
          kind: ApexIdentityResolutionKind.confirmedOpponent,
          tier: tier,
          query: query,
          candidate: candidate,
        );
      }
      lowConfidence ??= ApexIdentityResolution(
        kind: ApexIdentityResolutionKind.lowConfidence,
        tier: tier,
        query: query,
        candidate: candidate,
      );
    }

    return lowConfidence ??
        ApexIdentityResolution(
          kind: ApexIdentityResolutionKind.noMatch,
          tier: ApexIdentityMatchTier.none,
          query: query,
        );
  }

  bool _sameHandle(String a, String b) =>
      normalizeHandle(a) == normalizeHandle(b);

  bool _samePlatform(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
