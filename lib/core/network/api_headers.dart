/// Canonical HTTP headers for every outbound network call.
///
/// Chess.com's CDN silently returns empty archives when no User-Agent is
/// supplied — that's the "0 games found" bug. Lichess actively asks
/// integrations to identify themselves with a contact email so they can
/// reach out about rate-limit issues. We bake a single value here so
/// every client (Chess.com archives, Lichess archives + Cloud Eval +
/// Opening Explorer + profile stats + username validation) can't
/// accidentally drop the header on its own path.
library;

/// Display name + contact email per the Lichess API guidelines.
/// Update the email if the operator address changes.
const String apexUserAgent = 'ApexChess/1.0 (admin@apexchess.com)';

/// Header bundle for plain JSON requests — Lichess Cloud Eval, Opening
/// Explorer, profile stats, username validation, etc.
const Map<String, String> apexJsonHeaders = {
  'User-Agent': apexUserAgent,
  'Accept': 'application/json',
};

/// Header bundle for endpoints that stream NDJSON (Lichess game export).
const Map<String, String> apexNdjsonHeaders = {
  'User-Agent': apexUserAgent,
  'Accept': 'application/x-ndjson',
};

/// Header bundle for Chess.com archive endpoints which return PGN as
/// JSON wrappers — same Accept as JSON but kept separate so future
/// changes (e.g. `application/x-chess-pgn`) only touch one place.
const Map<String, String> apexChessComHeaders = {
  'User-Agent': apexUserAgent,
  'Accept': 'application/json',
};
