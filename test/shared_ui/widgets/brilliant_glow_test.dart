import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/brilliant_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(ValueNotifier<bool> visible, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: ApexTheme.dark,
    home: Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (context, value, _) => BrilliantGlow(
          visible: value,
          reduceMotion: reduceMotion,
          child: const SizedBox(
            key: ValueKey('brilliant-child'),
            width: 120,
            height: 120,
          ),
        ),
      ),
    ),
  );
}

Widget _identityHost(ValueNotifier<(bool, int)> state) {
  return MaterialApp(
    theme: ApexTheme.dark,
    home: Scaffold(
      body: ValueListenableBuilder<(bool, int)>(
        valueListenable: state,
        builder: (context, value, _) => BrilliantGlow(
          key: ValueKey(value.$2),
          visible: value.$1,
          child: const SizedBox(
            key: ValueKey('brilliant-identity-child'),
            width: 120,
            height: 120,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('historic Brilliant does not replay on initial mount', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);

    await tester.pumpWidget(_host(visible));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('brilliant-child')), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('leaving Brilliant stops and resets the emphasis immediately', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(false);
    addTearDown(visible.dispose);

    await tester.pumpWidget(_host(visible));
    visible.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    visible.value = false;
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion suppresses Brilliant emphasis', (tester) async {
    final visible = ValueNotifier<bool>(false);
    addTearDown(visible.dispose);

    await tester.pumpWidget(_host(visible, reduceMotion: true));
    visible.value = true;
    await tester.pump();

    expect(find.byKey(const ValueKey('brilliant-child')), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('replacement identity clears an active historic emphasis', (
    tester,
  ) async {
    final state = ValueNotifier<(bool, int)>((false, 1));
    addTearDown(state.dispose);

    await tester.pumpWidget(_identityHost(state));
    state.value = (true, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    state.value = (true, 2);
    await tester.pump();

    expect(
      find.byKey(const ValueKey('brilliant-identity-child')),
      findsOneWidget,
    );
    expect(tester.binding.transientCallbackCount, 0);
  });
}
