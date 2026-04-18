import 'dart:ui' show Tristate;
import 'package:afc/shared/components/pagination_dots/pagination_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required int totalPages,
    int initialPage = 0,
    ValueChanged<int>? onPageSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: PaginationDots(
              totalPages: totalPages,
              initialPage: initialPage,
              onPageSelected: onPageSelected,
            ),
          ),
        ),
      ),
    );
  }

  group('PaginationDots Widget Tests', () {
    testWidgets('Renders correctly with default state', (tester) async {
      await tester.pumpWidget(buildTestWidget(totalPages: 5, initialPage: 0));

      // We expect 5 total dots rendered as AnimatedContainers
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
      expect(find.byType(PaginationDots), findsOneWidget);
    });

    testWidgets('Renders correctly with pre-selected page', (tester) async {
      await tester.pumpWidget(buildTestWidget(totalPages: 3, initialPage: 1));

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
      // By semantic label, we can check the state indirectly if needed
      expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);
    });

    testWidgets(
      'onPageSelected callback fires correctly and updates UI state',
      (tester) async {
        int? tappedPage;

        await tester.pumpWidget(
          buildTestWidget(
            totalPages: 4,
            onPageSelected: (index) {
              tappedPage = index;
            },
          ),
        );

        // Ensure the initial active semantics state is correct
        final SemanticsNode nodeBefore = tester.getSemantics(
          find.bySemanticsLabel('Page 1 of 4'),
        );
        expect(nodeBefore.flagsCollection.isSelected, Tristate.isTrue);

        // Tap on the 3rd dot (index 2)
        await tester.tap(find.bySemanticsLabel('Page 3 of 4'));
        await tester.pumpAndSettle();

        // Callback should return index 2
        expect(tappedPage, 2);

        // Semantics for page 3 should now indicate it is selected
        final SemanticsNode nodeAfter = tester.getSemantics(
          find.bySemanticsLabel('Page 3 of 4'),
        );
        expect(nodeAfter.flagsCollection.isSelected, Tristate.isTrue);
      },
    );

    testWidgets('Matches Golden file for default state', (tester) async {
      tester.view.physicalSize = const Size(400, 200);
      tester.view.devicePixelRatio = 1.0;

      const columnKey = ValueKey('golden-column');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                key: columnKey,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  PaginationDots(totalPages: 2, initialPage: 1),
                  PaginationDots(totalPages: 5, initialPage: 1),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(columnKey),
        matchesGoldenFile('goldens/pagination_dots_default.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
