import 'package:afc/widgets/custom_date_picker/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({Function(DateTime?, DateTime?)? onChanged}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: CustomDatePicker(
            key: const ValueKey('date_picker'),
            onChanged: onChanged ?? (s, e) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders reduced button with placeholder initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text("Select Date"), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });

  testWidgets('opens dialog when trigger is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text("Done"), findsOneWidget);
    expect(find.text("Reset"), findsOneWidget);
  });

  testWidgets('callback fires when Done is pressed', (
    WidgetTester tester,
  ) async {
    DateTime? capturedStart;
    await tester.pumpWidget(
      createWidgetUnderTest(onChanged: (s, e) => capturedStart = s),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    // Tap a day (e.g., 15th)
    await tester.tap(find.text("15").first);
    await tester.pump();

    await tester.tap(find.text("Done"));
    await tester.pumpAndSettle();

    expect(capturedStart, isNotNull);
    expect(capturedStart!.day, 15);
  });
}
