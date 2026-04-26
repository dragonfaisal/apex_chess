/// Sanitizer for any string we might hand to Flutter's text shaper.
///
/// Why this file exists
/// ────────────────────
/// Skia's paragraph builder asserts `check(fUnicode)` (SIGABRT in
/// `hwuiTask1`) whenever we feed it a string the ICU/HarfBuzz pipeline
/// rejects — most commonly a lone UTF-16 surrogate, an embedded NUL,
/// or a non-character code point. This is a hard native crash, not a
/// catchable exception.
///
/// In Apex Chess we render strings that originate outside the app
/// (Chess.com / Lichess player handles, PGN tag values, opening names,
/// engine `info string` lines, error messages from network failures).
/// Any of those can carry pathological code points — a Chess.com
/// handle was the smoking gun in the production crash log
/// (`Fatal signal 6 (SIGABRT) … skia: ParagraphBuilderImpl.cpp:252:
/// fatal error: "check(fUnicode)"`).
///
/// [safeText] returns a string that is guaranteed never to trip Skia:
///
///   * `null` becomes the caller's [fallback] (default `''`).
///   * Every UTF-16 code unit in the surrogate range (U+D800..U+DFFF)
///     is required to be part of a valid surrogate pair; lone halves
///     are dropped.
///   * Non-character code points (`U+FDD0..U+FDEF` and any `U+xxFFFE`
///     / `U+xxFFFF`) are dropped.
///   * The C0/C1 control ranges are dropped except for tab / LF / CR,
///     which the shaper handles correctly.
///   * The result is truncated to [maxLength] characters so a
///     pathologically long handle can't single-handedly stall the
///     shaper. The default is generous (256) — usernames are short.
///
/// The sanitizer is intentionally conservative: any code point Skia
/// would render normally is left untouched, so visual output for
/// well-formed input is identical to passing the raw string.
library;

const int _kSafeTextDefaultMaxLength = 256;

/// Returns a string that is safe to pass to a Flutter [Text] / [TextSpan].
///
/// Always returns a non-null [String]. Never throws.
String safeText(
  String? value, {
  String fallback = '',
  int maxLength = _kSafeTextDefaultMaxLength,
}) {
  if (value == null || value.isEmpty) return fallback;

  final units = value.codeUnits;
  final out = StringBuffer();
  var written = 0;

  for (var i = 0; i < units.length; i++) {
    if (written >= maxLength) break;
    final cu = units[i];

    // Drop NUL and most C0 / DEL / C1 controls. Keep tab (9), LF (10),
    // CR (13) — the shaper handles them as line breaks / whitespace.
    if (cu == 0x09 || cu == 0x0A || cu == 0x0D) {
      out.writeCharCode(cu);
      written++;
      continue;
    }
    if (cu < 0x20 || (cu >= 0x7F && cu < 0xA0)) {
      continue;
    }

    // High surrogate: must be followed by a matching low surrogate.
    if (cu >= 0xD800 && cu <= 0xDBFF) {
      if (i + 1 < units.length) {
        final next = units[i + 1];
        if (next >= 0xDC00 && next <= 0xDFFF) {
          // Decode and check non-character ranges before emitting.
          final cp = 0x10000 +
              ((cu - 0xD800) << 10) +
              (next - 0xDC00);
          // Per Unicode, the last two code points of every plane are
          // non-characters (U+xxFFFE / U+xxFFFF).
          final low = cp & 0xFFFF;
          if (low == 0xFFFE || low == 0xFFFF) {
            i++; // skip the surrogate pair
            continue;
          }
          out.writeCharCode(cu);
          out.writeCharCode(next);
          written += 2;
          i++;
          continue;
        }
      }
      // Lone high surrogate — drop it.
      continue;
    }
    // Lone low surrogate — drop it.
    if (cu >= 0xDC00 && cu <= 0xDFFF) {
      continue;
    }

    // BMP non-characters: U+FDD0..U+FDEF and U+FFFE / U+FFFF.
    if (cu >= 0xFDD0 && cu <= 0xFDEF) continue;
    if (cu == 0xFFFE || cu == 0xFFFF) continue;

    out.writeCharCode(cu);
    written++;
  }

  final result = out.toString();
  return result.isEmpty ? fallback : result;
}

/// Convenience for "either show this validated string or a placeholder".
///
/// Identical to [safeText] but with a non-empty default placeholder so
/// callers don't have to remember to pass one for required-text widgets
/// (player handles, tag values, etc.).
String safeLabel(String? value, {String placeholder = '—'}) =>
    safeText(value, fallback: placeholder);
