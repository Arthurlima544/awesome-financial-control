import 'package:afc/shared/components/custom_tooltip/custom_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomTooltip Widget', () {
    const title = 'Title';
    const description = 'Description text goes here';

    testWidgets('renders child but tooltip is initially hidden', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomTooltip(
            title: title,
            description: description,
            child: Icon(Icons.info),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text(title), findsNothing);
    });

    testWidgets('shows tooltip on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTooltip(
              title: title,
              description: description,
              child: Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.info));
      await tester.pump();

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
    });

    testWidgets('calls onVisibleChanged on toggle', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTooltip(
              title: title,
              description: description,
              onVisibleChanged: () => called = true,
              child: const Icon(Icons.info),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.info));
      await tester.pump();
      expect(called, true);
    });

    testWidgets('matches golden file', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomTooltip(
                title: 'UI Match',
                description: 'Checking design accuracy',
                child: Icon(Icons.info),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CustomTooltip),
        matchesGoldenFile('custom_tooltip_default.png'),
      );
    });
  });
}
