import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_side_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('white marker display model is safe and labeled', () {
    final display = ApexSideMarkerDisplay.fromSide(ApexSideMarkerSide.white);

    expect(display.label, 'White');
    expect(display.semanticLabel, 'White side');
    expect(display.keySuffix, 'white');
    expect(display.isKnown, isTrue);
  });

  test('black marker display model is safe and labeled', () {
    final display = ApexSideMarkerDisplay.fromSide(ApexSideMarkerSide.black);

    expect(display.label, 'Black');
    expect(display.semanticLabel, 'Black side');
    expect(display.keySuffix, 'black');
    expect(display.isKnown, isTrue);
  });

  test('unknown marker remains safe', () {
    final display = ApexSideMarkerDisplay.fromSide(ApexSideMarkerSide.unknown);

    expect(display.label, 'Side');
    expect(display.semanticLabel, 'Unknown side');
    expect(display.keySuffix, 'unknown');
    expect(display.isKnown, isFalse);
  });

  testWidgets('marker widget can show optional label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: const ApexSideMarker(
          side: ApexSideMarkerSide.white,
          showLabel: true,
          keyPrefix: 'test',
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('test-white-side-marker')),
      findsOneWidget,
    );
    expect(find.text('White'), findsOneWidget);
  });
}
