import 'package:afc/widgets/custom_progress_bar/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

void main() {
  Widget buildTestWidget({
    double initialProgress = 0.0,
    int? steps,
    ValueChanged<double>? onChanged,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomProgressBar(
              initialProgress: initialProgress,
              steps: steps,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('CustomProgressBar Widget Tests', () {
    testWidgets('Renders correctly with continuous state', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialProgress: 0.4));

      // Stack is used for continuous (at least one inside CustomProgressBar)
      expect(
        find.descendant(
          of: find.byType(CustomProgressBar),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
      // Row is used for stepped, so it should not exist
      expect(find.byType(Row), findsNothing);
      expect(find.byType(CustomProgressBar), findsOneWidget);
    });

    testWidgets('Renders correctly with stepped state', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialProgress: 0.6, steps: 5));

      // Row is used for Stepped
      expect(find.byType(Row), findsOneWidget);
      // 5 Expanded widgets for the 5 segments
      expect(find.byType(Expanded), findsNWidgets(5));
    });

    testWidgets(
      'onChanged callback fires and updates progress via tap interaction',
      (tester) async {
        double? updatedProgress;

        await tester.pumpWidget(
          buildTestWidget(
            initialProgress: 0.0,
            onChanged: (val) {
              updatedProgress = val;
            },
          ),
        );

        // Tap on the progress bar widget
        final progressFinder = find.byType(CustomProgressBar);
        await tester.tap(progressFinder);
        await tester.pumpAndSettle();

        // Since we tap the exact center of the widget via tester.tap
        expect(updatedProgress, 0.5);
      },
    );

    testWidgets('Snaps correctly to steps via tap interaction', (tester) async {
      double? updatedProgress;

      await tester.pumpWidget(
        buildTestWidget(
          initialProgress: 0.0,
          steps: 4, // 0%, 25%, 50%, 75%, 100%
          onChanged: (val) {
            updatedProgress = val;
          },
        ),
      );

      // Tap exactly in the center -> snaps to 0.5 (2/4 steps)
      final progressFinder = find.byType(CustomProgressBar);
      await tester.tap(progressFinder);
      await tester.pumpAndSettle();

      expect(updatedProgress, 0.5);
    });
  });
}
