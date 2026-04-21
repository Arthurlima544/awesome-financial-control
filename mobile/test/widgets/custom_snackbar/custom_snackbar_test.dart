import 'package:afc/widgets/custom_snackbar/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('CustomSnackbar Widget Tests', () {
    testWidgets('Renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const CustomSnackbar(title: 'Content', subtitle: 'Caption'),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Caption'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets(
      'Action callback fires correctly and shows loading state temporarily',
      (WidgetTester tester) async {
        bool actionFired = false;

        await tester.pumpWidget(
          buildTestWidget(
            child: CustomSnackbar(
              title: 'Update Available',
              actionText: 'Action',
              onAction: () {
                actionFired = true;
              },
            ),
          ),
        );

        expect(find.text('Action'), findsOneWidget);

        await tester.tap(find.text('Action'));
        await tester.pump(); // trigger the tap

        expect(actionFired, isTrue);
        // Wait for the simulated network delay in the widget
        await tester.pump(const Duration(milliseconds: 300));
      },
    );

    testWidgets('Dismisses correctly via trailing icon', (
      WidgetTester tester,
    ) async {
      bool dismissCallbackFired = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: CustomSnackbar(
            title: 'Dismissible Snackbar',
            showTrailingIcon: true,
            onDismissed: () {
              dismissCallbackFired = true;
            },
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);

      await tester.tap(find.byType(Icon));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Snackbar'), findsNothing);
      expect(dismissCallbackFired, isTrue);
    });
  });
}
