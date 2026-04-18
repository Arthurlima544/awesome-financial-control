import 'package:afc/shared/components/message_input/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    String initialText = '',
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onAddAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: MessageInput(
              initialText: initialText,
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onAddAction: onAddAction,
            ),
          ),
        ),
      ),
    );
  }

  group('MessageInput Widget Tests', () {
    testWidgets('Renders correctly with default state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Should show Add icon and hint text
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Type a message...'), findsOneWidget);

      // Send button should NOT be visible initially
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets(
      'Entering text makes send button appear and triggers onChanged',
      (tester) async {
        String? changedText;

        await tester.pumpWidget(
          buildTestWidget(onChanged: (val) => changedText = val),
        );

        await tester.enterText(find.byType(TextFormField), 'Hello');
        await tester.pump();

        expect(changedText, 'Hello');
        // Send button should now be visible
        expect(find.byIcon(Icons.send), findsOneWidget);
      },
    );

    testWidgets('Tapping send button triggers onSubmitted and clears input', (
      tester,
    ) async {
      String? submittedText;
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestWidget(
          controller: controller,
          onSubmitted: (val) => submittedText = val,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test message');
      await tester.pump();

      // Tap the send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submittedText, 'Test message');
      expect(controller.text, isEmpty);
      // Send button disappears because field is empty
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('Tapping add icon triggers onAddAction', (tester) async {
      bool addTapped = false;

      await tester.pumpWidget(
        buildTestWidget(onAddAction: () => addTapped = true),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(addTapped, isTrue);
    });
  });
}
