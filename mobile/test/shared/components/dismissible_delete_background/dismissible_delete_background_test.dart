import 'package:afc/config/app_colors.dart';
import 'package:afc/shared/components/dismissible_delete_background/dismissible_delete_background.dart';
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

    testWidgets('golden', (tester) async {
      tester.view.physicalSize = const Size(400, 72);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await expectLater(
        find.byKey(const ValueKey('bg')),
        matchesGoldenFile('goldens/dismissible_delete_background.png'),
      );
    });
  });
}
