import 'package:apex_chess/shared_ui/identity/apex_identity_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const matcher = ApexIdentityMatcher();
  const connected = ApexIdentityCandidate(
    handle: 'ALFAISALpro',
    platform: 'chess.com',
  );

  test('connected handle substring is not confirmed opponent', () {
    final result = matcher.resolveOpponentQuery(
      query: 'FAISAL',
      platform: 'chess.com',
      connectedAccount: connected,
    );

    expect(result.kind, ApexIdentityResolutionKind.ambiguousConnectedSubstring);
    expect(result.isConfirmedOpponent, isFalse);
    expect(result.copy, 'Choose exact player');
  });

  test('case-insensitive exact connected match is confirmed user', () {
    final result = matcher.resolveOpponentQuery(
      query: 'alfaisalPRO',
      platform: 'chess.com',
      connectedAccount: connected,
    );

    expect(result.kind, ApexIdentityResolutionKind.confirmedUser);
    expect(result.isConfirmedUser, isTrue);
    expect(result.copy, 'This is your connected account');
  });

  test('query magnolia returns opponent when loaded exact match exists', () {
    final result = matcher.resolveOpponentQuery(
      query: 'magnolia',
      platform: 'chess.com',
      connectedAccount: connected,
      candidates: const [
        ApexIdentityCandidate(
          handle: 'magnoliachickenhatdog',
          platform: 'chess.com',
        ),
      ],
    );

    expect(result.kind, ApexIdentityResolutionKind.confirmedOpponent);
    expect(result.tier, ApexIdentityMatchTier.startsWith);
  });

  test('contains match for non-connected candidate is low confidence', () {
    final result = matcher.resolveOpponentQuery(
      query: 'chicken',
      platform: 'chess.com',
      connectedAccount: connected,
      candidates: const [
        ApexIdentityCandidate(
          handle: 'magnoliachickenhatdog',
          platform: 'chess.com',
        ),
      ],
    );

    expect(result.kind, ApexIdentityResolutionKind.lowConfidence);
    expect(result.isConfirmedOpponent, isFalse);
  });
}
