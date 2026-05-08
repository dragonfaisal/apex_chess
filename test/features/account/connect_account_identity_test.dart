import 'dart:async';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/account/data/account_repository.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/account/presentation/views/connect_account_screen.dart';
import 'package:apex_chess/features/user_validation/data/username_validator.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('exact connected account is labeled without partial match', (
    tester,
  ) async {
    final container = await _containerWithAccount();
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(ApexCopy.connectedAccountNotice), findsOneWidget);
    expect(
      find.byKey(const ValueKey('connect-public-profile-found')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('connect-connected-notice')),
      findsNothing,
    );

    await tester.enterText(find.byType(TextField), 'Apex');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(ApexCopy.connectedAccountNotice), findsNothing);
    expect(
      find.byKey(const ValueKey('connect-connected-notice')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('connect-public-profile-found')),
      findsOneWidget,
    );
  });

  testWidgets('no connected account valid lookup shows verified', (
    tester,
  ) async {
    final container = await _containerWithoutAccount();
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'ApexUser');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(ApexCopy.connectedAccountNotice), findsNothing);
    expect(
      find.byKey(const ValueKey('connect-connected-notice')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('connect-public-profile-found')),
      findsOneWidget,
    );
  });

  testWidgets('selected Chess.com tab is visibly active', (tester) async {
    final container = await _containerWithoutAccount();
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();

    final chess = _sourceChipDecoration(tester, 'chessCom');
    final lichess = _sourceChipDecoration(tester, 'lichess');

    expect(_border(chess).top.width, greaterThan(_border(lichess).top.width));
    expect(chess.boxShadow, isNotNull);
    expect(lichess.boxShadow, isNull);
  });

  testWidgets('selected Lichess tab is visibly active', (tester) async {
    final container = await _containerWithoutAccount();
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('connect-source-lichess-chip')));
    await tester.pump(const Duration(milliseconds: 240));

    final chess = _sourceChipDecoration(tester, 'chessCom');
    final lichess = _sourceChipDecoration(tester, 'lichess');

    expect(_border(lichess).top.width, greaterThan(_border(chess).top.width));
    expect(lichess.boxShadow, isNotNull);
    expect(chess.boxShadow, isNull);
  });

  testWidgets('disabled and loading connect states remain readable', (
    tester,
  ) async {
    final repo = _SlowAccountRepository();
    final container = await _containerWithoutAccount(repository: repo);
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();

    final disabledLabel = tester.widget<Text>(
      find.byKey(const ValueKey('connect-account-cta-label')),
    );
    expect(disabledLabel.style?.color, ApexColors.textSecondary);
    expect(_border(_ctaDecoration(tester)).top.width, greaterThan(0));

    await tester.enterText(find.byType(TextField), 'ApexUser');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byKey(const ValueKey('connect-public-profile-found')),
      findsOneWidget,
    );
    expect(find.text(ApexCopy.connectedAccountNotice), findsNothing);
    expect(
      find.byKey(const ValueKey('connect-connected-notice')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('connect-account-cta')));
    await tester.pump();
    expect(find.text(ApexCopy.connectedAccountNotice), findsNothing);
    expect(
      find.byKey(const ValueKey('connect-connected-notice')),
      findsNothing,
    );

    final loader = tester.widget<ApexPulseLoader>(
      find.descendant(
        of: find.byKey(const ValueKey('connect-account-cta')),
        matching: find.byType(ApexPulseLoader),
      ),
    );
    expect(loader.color, ApexColors.textOnAccent);

    repo.complete();
    await tester.pump();
    await tester.pump();
    expect(
      find.byKey(const ValueKey('connect-public-profile-found')),
      findsNothing,
    );
    expect(find.text(ApexCopy.connectedAccountNotice), findsNothing);
    expect(
      find.byKey(const ValueKey('connect-connected-notice')),
      findsOneWidget,
    );
  });
}

Future<ProviderContainer> _containerWithAccount() async {
  SharedPreferences.setMockInitialValues({
    'apex.account.source': AccountSource.chessCom.wire,
    'apex.account.username': 'ApexUser',
    'apex.account.onboarding_seen': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      accountRepositoryProvider.overrideWithValue(
        AccountRepository(prefs: prefs),
      ),
      usernameValidatorProvider.overrideWithValue(_ExistsValidator()),
      connectionPresenceProvider.overrideWith(
        _NoopConnectionPresenceController.new,
      ),
    ],
  );
  await container.read(accountControllerProvider.future);
  return container;
}

Future<ProviderContainer> _containerWithoutAccount({
  AccountRepository? repository,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      accountRepositoryProvider.overrideWithValue(
        repository ?? AccountRepository(prefs: prefs),
      ),
      usernameValidatorProvider.overrideWithValue(_ExistsValidator()),
      connectionPresenceProvider.overrideWith(
        _NoopConnectionPresenceController.new,
      ),
    ],
  );
  await container.read(accountControllerProvider.future);
  return container;
}

Widget _host(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: ApexTheme.dark,
      home: const ConnectAccountScreen(allowSkip: false),
    ),
  );
}

class _ExistsValidator extends UsernameValidator {
  @override
  Future<UsernameExistence> check({
    required String source,
    required String username,
  }) async {
    return UsernameExistence.exists;
  }
}

class _NoopConnectionPresenceController extends ConnectionPresenceController {
  @override
  ApexConnectionPresence build() => const ApexConnectionPresence();

  @override
  Future<void> checkNow({bool notify = true}) async {}
}

BoxDecoration _sourceChipDecoration(WidgetTester tester, String platformName) {
  final chip = tester.widget<AnimatedContainer>(
    find.byKey(ValueKey('connect-source-$platformName-chip')),
  );
  return chip.decoration! as BoxDecoration;
}

BoxDecoration _ctaDecoration(WidgetTester tester) {
  final cta = tester.widget<AnimatedContainer>(
    find.byKey(const ValueKey('connect-account-cta')),
  );
  return cta.decoration! as BoxDecoration;
}

Border _border(BoxDecoration decoration) => decoration.border! as Border;

class _SlowAccountRepository extends AccountRepository {
  final _writeCompleter = Completer<void>();

  @override
  Future<ApexAccount?> read() async => null;

  @override
  Future<void> write(ApexAccount account) => _writeCompleter.future;

  @override
  Future<void> markOnboardingSeen() async {}

  void complete() {
    if (!_writeCompleter.isCompleted) _writeCompleter.complete();
  }
}
