import 'package:apex_chess/shared_ui/widgets/apex_snack.dart';
import 'package:flutter/material.dart';
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

  testWidgets('Apex glass toast is floating and raised above bottom nav', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showApexGlassToast(
                    context,
                    message: 'Raised toast',
                    type: ApexGlassToastType.warning,
                  );
                },
                child: const Text('show toast'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('show toast'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(snackBar.backgroundColor, Colors.transparent);
    expect(snackBar.margin, isNotNull);
    expect((snackBar.margin! as EdgeInsets).bottom, greaterThanOrEqualTo(78));
    expect((snackBar.margin! as EdgeInsets).left, greaterThan(36));
    expect((snackBar.margin! as EdgeInsets).right, greaterThan(36));
  });

  test('toast display model uses short one-line copy', () {
    final display = ApexToastDisplay.from(
      message: 'Offline',
      detail: 'Showing saved data',
      type: ApexGlassToastType.warning,
    );

    expect(display.label, 'Showing saved data');
    expect(display.isOneLine, isTrue);
  });

  testWidgets('toast width is not forced full screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(420, 800)),
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showApexGlassToast(
                      context,
                      message: 'Offline',
                      type: ApexGlassToastType.warning,
                    );
                  },
                  child: const Text('show narrow toast'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show narrow toast'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final margin = snackBar.margin! as EdgeInsets;
    expect(420 - margin.left - margin.right, lessThanOrEqualTo(280));
  });
}
