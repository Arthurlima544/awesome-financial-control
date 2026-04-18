import 'package:afc/shared/components/adaptive_date_picker/adaptive_date_picker.dart';
import 'package:afc/shared/components/adaptive_date_picker/adaptive_date_picker_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveDatePickerCubit cubit,
    ValueChanged<DateTime>? onDateSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 350, // Constrain width to simulate mobile view
            child: BlocProvider.value(
              value: cubit,
              child: AdaptiveDatePicker(
                semanticLabel: 'Booking Date Picker',
                onDateSelected: onDateSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveDatePicker Widget Tests', () {
    late AdaptiveDatePickerCubit cubit;
    // We use a fixed date that matches the arrangement seen in the design image
    // Note: The design starts with Sunday.
    final fixedMonth = DateTime(
      2023,
      10,
      1,
    ); // October 2023 starts on a Sunday.

    setUp(() {
      cubit = AdaptiveDatePickerCubit(initialMonth: fixedMonth);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onDateSelected: (_) {}),
      );

      expect(find.byType(AdaptiveDatePicker), findsOneWidget);
      expect(find.text('Oct 2023'), findsOneWidget);
      expect(find.text('S'), findsNWidgets(2)); // Sunday, Saturday
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('taps on a date trigger callback and update state', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onDateSelected: (date) => selectedDate = date,
        ),
      );

      // Tap on the 15th
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(selectedDate, DateTime(2023, 10, 15));
      expect(cubit.state.selectedDate, DateTime(2023, 10, 15));

      // Verify visual circle rendered (AnimatedContainer changes color)
      final container = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('15'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNot(Colors.transparent));
    });

    testWidgets('disabled state prevents interactions', (
      WidgetTester tester,
    ) async {
      DateTime? selectedDate;

      // Passing null to onDateSelected effectively disables it
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onDateSelected: null),
      );

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(selectedDate, isNull);
      expect(cubit.state.selectedDate, isNull);
    });

    testWidgets('renders error border when cubit emits error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onDateSelected: (_) {}),
      );

      cubit.setError('Date unavailable');
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Focus),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
    });
  });
}
