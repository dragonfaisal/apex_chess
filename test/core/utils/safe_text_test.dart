/// Regression tests for [safeText].
///
/// The crash this guards against — `skia: ParagraphBuilderImpl.cpp:252:
/// fatal error: "check(fUnicode)"` — only reproduces on a real Skia /
/// HarfBuzz pipeline, which we can't run from a host VM. Instead we
/// pin the *byte-level* contract of the sanitizer so any regression
/// that re-introduces a category of dangerous code units fails here.
library;

import 'package:apex_chess/core/utils/safe_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('safeText', () {
    test('null becomes the fallback (default empty)', () {
      expect(safeText(null), '');
      expect(safeText(null, fallback: '—'), '—');
    });

    test('empty string becomes the fallback', () {
      expect(safeText(''), '');
      expect(safeText('', fallback: 'Anonymous'), 'Anonymous');
    });

    test('plain ASCII passes through unchanged', () {
      expect(safeText('MagnusCarlsen'), 'MagnusCarlsen');
      expect(safeText('Hikaru'), 'Hikaru');
    });

    test('Arabic / RTL handles render verbatim — they are well-formed',
        () {
      // Pulled from the production crash log right before SIGABRT.
      const handle = 'حلل الكل لجل نتساد';
      expect(safeText(handle), handle);
    });

    test('CJK / emoji handles render verbatim', () {
      expect(safeText('日本語ユーザー'), '日本語ユーザー');
      // U+1F4A1 (light bulb) — surrogate pair must survive intact.
      expect(safeText('idea\u{1F4A1}'), 'idea\u{1F4A1}');
    });

    test('lone high surrogate is dropped', () {
      // 0xD83D alone, with no following 0xDC00..DFFF.
      const lone = '\uD83Dhello';
      expect(safeText(lone), 'hello');
    });

    test('lone low surrogate is dropped', () {
      const lone = 'hello\uDC00';
      expect(safeText(lone), 'hello');
    });

    test('NUL byte is dropped', () {
      expect(safeText('foo\u0000bar'), 'foobar');
    });

    test('BMP non-character U+FFFE / U+FFFF are dropped', () {
      expect(safeText('a\uFFFEb\uFFFFc'), 'abc');
    });

    test('Arabic-presentation non-character range is dropped', () {
      expect(safeText('a\uFDD0b\uFDEFc'), 'abc');
    });

    test('C0 / C1 controls are dropped except tab / LF / CR', () {
      // 0x07 (BEL) and 0x88 (PU2) are dropped; tab / LF / CR pass.
      const input = 'a\u0007b\tc\nd\re\u0088f';
      expect(safeText(input), 'ab\tc\nd\ref');
    });

    test('result is truncated to maxLength', () {
      final result = safeText('A' * 1000, maxLength: 10);
      expect(result.length, 10);
    });

    test('does not throw for any single-code-unit input in 0..0xFFFF', () {
      // Defence-in-depth fuzz: nothing in the BMP should make us throw.
      for (var cu = 0; cu <= 0xFFFF; cu++) {
        // ignore: invalid_use_of_visible_for_testing_member
        expect(() => safeText(String.fromCharCode(cu)), returnsNormally);
      }
    });
  });

  group('safeLabel', () {
    test('returns placeholder when input is empty / null', () {
      expect(safeLabel(null), '—');
      expect(safeLabel(''), '—');
    });

    test('passes through good input', () {
      expect(safeLabel('e4'), 'e4');
    });

    test('a string that becomes empty after sanitising falls back to '
        'placeholder', () {
      // Lone surrogate + NUL → empty after sanitising → placeholder.
      expect(safeLabel('\uD83D\u0000', placeholder: '?'), '?');
    });
  });
}
