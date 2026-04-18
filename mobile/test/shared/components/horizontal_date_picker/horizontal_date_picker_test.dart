import 'package:afc/shared/components/horizontal_date_picker/horizontal_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required DateTime startDate,
    int daysCount = 7,
    DateTime? initialDate,
    ValueChanged<DateTime>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: HorizontalDatePicker(
            startDate: startDate,
            daysCount: daysCount,
            initialSelectedDate: initialDate,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  group('HorizontalDatePicker Widget Tests', () {
    final baseDate = DateTime(2023, 10, 23); // Monday

    testWidgets('Renders correctly with default state', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(startDate: baseDate, daysCount: 3),
      );

      // Should render MO, TU, WE and 23, 24, 25
      expect(find.text('MO'), findsOneWidget);
      expect(find.text('TU'), findsOneWidget);
      expect(find.text('WE'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('Selects date and triggers onChanged callback', (tester) async {
      DateTime? selectedDateResult;

      await tester.pumpWidget(
        buildTestWidget(
          startDate: baseDate,
          onChanged: (date) {
            selectedDateResult = date;
          },
        ),
      );

      // Tap on the 24th (Tuesday)
      await tester.tap(find.text('24'));
      await tester.pumpAndSettle();

      expect(selectedDateResult, isNotNull);
      expect(selectedDateResult!.day, 24);
      expect(selectedDateResult!.month, 10);
      expect(selectedDateResult!.year, 2023);
    });

    testWidgets('Renders with pre-selected initial date', (tester) async {
      final initial = DateTime(2023, 10, 25);

      await tester.pumpWidget(
        buildTestWidget(startDate: baseDate, initialDate: initial),
      );

      // Rebuilding to let initial state sync if needed (though injected directly here)
      await tester.pumpAndSettle();

      final containerFinder = find
          .ancestor(
            of: find.text('25'),
            matching: find.byType(AnimatedContainer),
          )
          .first;

      final AnimatedContainer container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // Selected color is the default blue (0xFF2962FF)
      expect(decoration.color, const Color(0xFF2962FF));
    });
  });
}
