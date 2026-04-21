import 'package:afc/widgets/action_sheet/action_sheet.dart';
import 'package:afc/widgets/action_sheet/action_sheet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required List<ActionSheetOption> options,
    required ValueChanged<ActionSheetOption> onOptionSelected,
    VoidCallback? onCancel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ActionSheet(
          options: options,
          onOptionSelected: onOptionSelected,
          onCancel: onCancel,
        ),
      ),
    );
  }

  final mockOptions = [
    const ActionSheetOption(id: '1', label: 'Download'),
    const ActionSheetOption(id: '2', label: 'Save to my favorite'),
    const ActionSheetOption(id: '3', label: 'Comment'),
  ];

  group('ActionSheet Widget Tests', () {
    testWidgets('Renders correctly with default state', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(options: mockOptions, onOptionSelected: (_) {}),
      );

      expect(find.text('Select action'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Save to my favorite'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Initially, all radios should be unchecked
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);
    });

    testWidgets('onOptionSelected callback fires and updates UI state', (
      tester,
    ) async {
      ActionSheetOption? selected;

      await tester.pumpWidget(
        buildTestWidget(
          options: mockOptions,
          onOptionSelected: (option) {
            selected = option;
          },
        ),
      );

      await tester.tap(find.text('Download'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, '1');

      // UI should update to show checked radio
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    });

    testWidgets('onCancel callback fires correctly', (tester) async {
      bool canceled = false;

      await tester.pumpWidget(
        buildTestWidget(
          options: mockOptions,
          onOptionSelected: (_) {},
          onCancel: () {
            canceled = true;
          },
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(canceled, isTrue);
    });
  });
}
