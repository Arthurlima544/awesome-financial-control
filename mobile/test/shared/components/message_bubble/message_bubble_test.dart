import 'package:afc/shared/components/message_bubble/message_bubble.dart';
import 'package:afc/shared/components/message_bubble/message_bubble_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('MessageBubble Widget Tests', () {
    testWidgets('Renders correctly with default values (Received with Tail)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(child: const MessageBubble(message: 'Hello World')),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('Renders error state when Cubit emits error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const MessageBubble(message: 'Failed Message')),
      );

      // Access the internal Cubit to simulate an error
      final BuildContext context = tester.element(find.byType(Align).first);
      context.read<MessageBubbleCubit>().setError('Delivery failed');
      await tester.pumpAndSettle();

      expect(find.text('Delivery failed'), findsOneWidget);
    });

    testWidgets('onTap callback fires correctly', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: MessageBubble(
            message: 'Tap me',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onSelectionChanged callback fires correctly on long press', (
      tester,
    ) async {
      bool? isSelectedResult;

      await tester.pumpWidget(
        buildTestWidget(
          child: MessageBubble(
            message: 'Long press me',
            onSelectionChanged: (val) {
              isSelectedResult = val;
            },
          ),
        ),
      );

      await tester.longPress(find.text('Long press me'));
      await tester.pumpAndSettle();

      expect(isSelectedResult, isTrue);
    });

    testWidgets('Matches Golden file for all 4 visual variations', (
      tester,
    ) async {
      // Set explicit size for deterministic golden tests
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      const columnKey = ValueKey('golden-column');
      await tester.pumpWidget(
        buildTestWidget(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              key: columnKey,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                MessageBubble(
                  message: 'Message. Lorem ipsum dolor.',
                  type: MessageBubbleType.received,
                  hasTail: false,
                ),
                MessageBubble(
                  message: 'Message. Lorem ipsum dolor.',
                  type: MessageBubbleType.received,
                  hasTail: true,
                ),
                MessageBubble(
                  message: 'Message. Lorem ipsum dolor.',
                  type: MessageBubbleType.sent,
                  hasTail: false,
                ),
                MessageBubble(
                  message: 'Message. Lorem ipsum dolor.',
                  type: MessageBubbleType.sent,
                  hasTail: true,
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(columnKey),
        matchesGoldenFile('goldens/message_bubble_variations.png'),
      );

      // Cleanup
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
