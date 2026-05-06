import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/account/data/account_repository.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/account/presentation/views/connect_account_screen.dart';
import 'package:apex_chess/features/user_validation/data/username_validator.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
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

    await tester.enterText(find.byType(TextField), 'Apex');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(ApexCopy.connectedAccountNotice), findsNothing);
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
