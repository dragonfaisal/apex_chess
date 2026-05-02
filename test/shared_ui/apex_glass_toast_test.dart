import 'package:apex_chess/shared_ui/widgets/apex_snack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApexToastDeduper suppresses repeated messages briefly', () {
    final deduper = ApexToastDeduper(window: const Duration(milliseconds: 500));
    final now = DateTime(2026, 5, 2, 12);

    expect(deduper.shouldShow('Offline', now), isTrue);
    expect(
      deduper.shouldShow('Offline', now.add(const Duration(milliseconds: 250))),
      isFalse,
    );
    expect(
      deduper.shouldShow('Offline', now.add(const Duration(milliseconds: 700))),
      isTrue,
    );
    expect(deduper.shouldShow('Back online', now), isTrue);
  });
}
