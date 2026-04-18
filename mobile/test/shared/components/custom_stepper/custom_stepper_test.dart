import 'package:afc/shared/components/custom_stepper/custom_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required List<String> steps,
    int initialStep = 0,
    ValueChanged<int>? onStepTapped,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CustomStepper(
              steps: steps,
              initialStep: initialStep,
              onStepTapped: onStepTapped,
            ),
          ),
        ),
      ),
    );
  }

  group('CustomStepper Widget Tests', () {
    testWidgets('Renders correctly with default state', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          steps: ['Details', 'Shipping', 'Payment'],
          initialStep: 1,
        ),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Shipping'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);

      // Since initialStep is 1:
      // Index 0 (Details) should be completed (shows check icon)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Index 1 (Shipping) should be active (shows number 2)
      expect(find.text('2'), findsOneWidget);

      // Index 2 (Payment) should be inactive (shows number 3)
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('onStepTapped callback fires correctly and updates UI state', (
      tester,
    ) async {
      int? tappedStep;

      await tester.pumpWidget(
        buildTestWidget(
          steps: ['Step A', 'Step B', 'Step C'],
          onStepTapped: (index) {
            tappedStep = index;
          },
        ),
      );

      // Initially active step is 0 ('1')
      expect(find.text('1'), findsOneWidget);

      // Tap on the 3rd step (index 2)
      await tester.tap(find.text('Step C'));
      await tester.pumpAndSettle();

      // Callback should return index 2
      expect(tappedStep, 2);

      // Now steps 0 and 1 should be completed (2 check marks)
      expect(find.byIcon(Icons.check), findsNWidgets(2));
      // Step 2 is active (shows number 3)
      expect(find.text('3'), findsOneWidget);
    });
  });
}
