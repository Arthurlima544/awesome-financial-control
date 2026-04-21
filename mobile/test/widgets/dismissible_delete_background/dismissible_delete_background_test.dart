import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/widgets/dismissible_delete_background/dismissible_delete_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() => const MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 72,
        width: 400,
        child: DismissibleDeleteBackground(key: ValueKey('bg')),
      ),
    ),
  );

  group('DismissibleDeleteBackground', () {
    testWidgets('renders delete icon with error background', (tester) async {
      await tester.pumpWidget(buildSubject());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('bg')),
          matching: find.byType(Container),
        ),
      );
      expect(container.color, AppColors.error);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('icon color is AppColors.onError', (tester) async {
      await tester.pumpWidget(buildSubject());

      final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));
      expect(icon.color, AppColors.onError);
    });

    testWidgets('background is aligned to center right', (tester) async {
      await tester.pumpWidget(buildSubject());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const ValueKey('bg')),
          matching: find.byType(Container),
        ),
      );
      expect(container.alignment, Alignment.centerRight);
    });
  });
}
