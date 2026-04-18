import 'package:afc/shared/components/adaptive_stepper/adaptive_stepper.dart';
import 'package:afc/shared/components/adaptive_stepper/adaptive_stepper_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveStepperCubit cubit,
    ValueChanged<int>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveStepper(
              semanticLabel: 'Item Quantity',
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveStepper Widget Tests', () {
    late AdaptiveStepperCubit cubit;

    setUp(() {
      cubit = AdaptiveStepperCubit(initialValue: 0, min: 0, max: 5);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );

      expect(find.byType(AdaptiveStepper), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('taps trigger increment and onChanged callback', (
      WidgetTester tester,
    ) async {
      int? steppedValue;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onChanged: (val) => steppedValue = val,
        ),
      );

      // Tap the plus icon
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(steppedValue, 1);
      expect(cubit.state.value, 1);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('cannot decrement below min value', (
      WidgetTester tester,
    ) async {
      int? steppedValue;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onChanged: (val) => steppedValue = val,
        ),
      );

      // Value is 0 (min), tap minus
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(steppedValue, isNull);
      expect(cubit.state.value, 0);
    });

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      // Passing null to onChanged effectively disables it
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: null),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(cubit.state.value, 0);
    });

    testWidgets('renders error state border', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );

      cubit.setError('Limit reached');
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Focus),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
    });
  });
}
