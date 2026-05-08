import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/import_match/presentation/views/import_match_screen.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('online unavailable picker keeps Fast and Deep honest', (
    tester,
  ) async {
    AnalysisProfile? selected;
    await tester.pumpWidget(
      _Host(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              selected = await showDialog<AnalysisProfile>(
                context: context,
                builder: (_) => DepthPickerDialog(
                  planOverride: ReviewModeRoutingPlan.build(
                    isOnline: true,
                    onlineFastConfigured: false,
                    onlineDeepConfigured: false,
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Online Fast'), findsOneWidget);
    expect(find.text('Online Deep'), findsOneWidget);
    expect(find.text('Online review unavailable'), findsNWidgets(2));
    expect(find.text('Offline Review'), findsOneWidget);

    await tester.tap(find.text('Online Fast'));
    await tester.pumpAndSettle();
    expect(selected, isNull);

    await tester.tap(find.text('Offline Review'));
    await tester.pumpAndSettle();
    expect(selected, AnalysisProfile.offlineReview);
  });

  testWidgets('offline picker exposes one local review option', (tester) async {
    await tester.pumpWidget(
      _Host(
        child: DepthPickerDialog(
          planOverride: ReviewModeRoutingPlan.build(
            isOnline: false,
            onlineFastConfigured: true,
            onlineDeepConfigured: true,
          ),
        ),
      ),
    );

    expect(find.text('Online Fast'), findsNothing);
    expect(find.text('Online Deep'), findsNothing);
    expect(find.text('Offline Review'), findsOneWidget);
  });
}

class _Host extends StatelessWidget {
  const _Host({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }
}
