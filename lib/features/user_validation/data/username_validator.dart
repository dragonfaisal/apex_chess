/// Username-existence validator for Chess.com and Lichess.
///
/// Both providers expose public, unauthenticated profile endpoints that
/// return 200 for existing users and 404 for missing ones:
///
///   * Chess.com: `GET https://api.chess.com/pub/player/{username}`
///   * Lichess:   `GET https://lichess.org/api/user/{username}`
///
/// Neither provider offers a prefix-autocomplete API, so live
/// `"type-ahead suggestions"` aren't feasible — the closest honest
/// equivalent is a debounced existence check that renders a green
/// check / red X pill inline in the search field. Network failures
/// return `UsernameExistence.unknown` so the UI can stay neutral
/// instead of falsely claiming a user is missing.
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:apex_chess/core/network/api_headers.dart';

enum UsernameExistence { exists, missing, unknown }

class UsernameValidator {
  UsernameValidator({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 6);

  /// Resolves [username] on [source] (`'chess.com'` or `'lichess'`).
  /// Trims + lower-cases the input to match provider conventions.
  Future<UsernameExistence> check({
    required String source,
    required String username,
  }) async {
    final u = username.trim().toLowerCase();
    if (u.isEmpty) return UsernameExistence.unknown;
    final uri = switch (source) {
      'chess.com' => Uri.parse('https://api.chess.com/pub/player/$u'),
      'lichess' => Uri.parse('https://lichess.org/api/user/$u'),
      _ => null,
    };
    if (uri == null) return UsernameExistence.unknown;

    try {
      final res = await _client
          .get(uri, headers: apexJsonHeaders)
          .timeout(_timeout);
      if (res.statusCode == 200) {
        // Lichess returns 200 with `{"closed": true, ...}` for closed
        // accounts — treat those as missing so we don't green-light a
        // profile that can't be scanned.
        if (source == 'lichess' && res.body.contains('"closed":true')) {
          return UsernameExistence.missing;
        }
        return UsernameExistence.exists;
      }
      if (res.statusCode == 404) return UsernameExistence.missing;
      return UsernameExistence.unknown;
    } on TimeoutException {
      return UsernameExistence.unknown;
    } on SocketException {
      return UsernameExistence.unknown;
    } on http.ClientException {
      return UsernameExistence.unknown;
    }
  }

  void dispose() => _client.close();
}
