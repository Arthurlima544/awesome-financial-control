import 'package:afc/shared/components/action_card/action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('ActionCard Widget Tests', () {
    testWidgets('Renders correctly with icon header style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const ActionCard(
            style: ActionCardStyle.iconHeader,
            title: 'Premium Plan',
            subtitle: 'Billed monthly',
            description: 'Access all features and premium support.',
            buttonText: 'Subscribe',
            leadingIcon: Icons.star,
          ),
        ),
      );

      expect(find.text('Premium Plan'), findsOneWidget);
      expect(find.text('Billed monthly'), findsOneWidget);
      expect(
        find.text('Access all features and premium support.'),
        findsOneWidget,
      );
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Renders correctly with image header style and tag', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const ActionCard(
            style: ActionCardStyle.imageHeader,
            title: 'Design Assets',
            description: 'Download the complete vector package.',
            buttonText: 'Download',
            tagText: 'PRO',
          ),
        ),
      );

      expect(find.text('Design Assets'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(Icons.image), findsOneWidget); // Default placeholder
    });

    testWidgets('onAction callback fires and triggers loading state', (
      tester,
    ) async {
      bool callbackFired = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: ActionCard(
            style: ActionCardStyle.iconHeader,
            title: 'Action Test',
            description: 'Testing the action button.',
            buttonText: 'Click Me',
            onAction: () {
              callbackFired = true;
            },
          ),
        ),
      );

      // Initially button text is visible
      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap the button
      await tester.tap(find.text('Click Me'));
      await tester.pump();

      // Callback should have fired
      expect(callbackFired, isTrue);

      // Should now display loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the simulated async operation finish
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Matches Golden file for default state', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestWidget(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ActionCard(
                style: ActionCardStyle.imageHeader,
                title: 'Title',
                subtitle: 'Subtitle',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                buttonText: 'Button',
                tagText: 'TAG',
              ),
              ActionCard(
                style: ActionCardStyle.iconHeader,
                title: 'Title',
                subtitle: 'Subtitle',
                description:
                    'Description. Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do.',
                buttonText: 'Button',
                leadingIcon: Icons.favorite,
              ),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(Row),
        matchesGoldenFile('goldens/action_card_default.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
