import 'package:afc/shared/components/custom_list_tile/custom_list_tile.dart';
import 'package:afc/shared/components/custom_list_tile/custom_list_tile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('CustomListTile Widget Tests', () {
    testWidgets('Renders correctly with default values', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const CustomListTile(
            title: 'Notifications',
            description: 'Manage alerts',
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Manage alerts'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget); // Default leading
      expect(
        find.byIcon(Icons.chevron_right),
        findsOneWidget,
      ); // Default trailing
    });

    testWidgets('Renders error state when Cubit emits error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const CustomListTile(title: 'Toggle Item')),
      );

      // Access the internal Cubit to simulate a validation error
      final BuildContext context = tester.element(
        find.byType(CustomListTileView),
      );
      context.read<CustomListTileCubit>().setError('Action not allowed');
      await tester.pumpAndSettle();

      expect(find.text('Action not allowed'), findsOneWidget);
    });

    testWidgets('onChanged callback fires and updates switch correctly', (
      tester,
    ) async {
      bool toggleValue = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: CustomListTile(
            title: 'Enable WiFi',
            trailingType: CustomListTileTrailing.toggleSwitch,
            initialValue: false,
            onChanged: (val) {
              toggleValue = val;
            },
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);

      // Tap the tile
      await tester.tap(find.text('Enable WiFi'));
      await tester.pumpAndSettle();

      expect(toggleValue, isTrue);

      // Check if Switch visually updated
      final Switch switchWidget = tester.widget(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('onTap callback fires correctly for arrow tile', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: CustomListTile(
            title: 'Navigate to Profile',
            trailingType: CustomListTileTrailing.arrow,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Navigate to Profile'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Matches Golden file for default state combinations', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      const columnKey = ValueKey('golden-column');
      await tester.pumpWidget(
        buildTestWidget(
          child: Column(
            key: columnKey,
            children: const [
              CustomListTile(
                title: 'Title',
                description: 'Description. Lorem ipsum dolor sit amet.',
                trailingType: CustomListTileTrailing.arrow,
              ),
              CustomListTile(
                title: 'Title',
                description: 'Description. Lorem ipsum dolor sit amet.',
                trailingType: CustomListTileTrailing.toggleSwitch,
              ),
              CustomListTile(
                title: 'Title',
                description: 'Description. Lorem ipsum dolor sit amet.',
                leadingType: CustomListTileLeading.avatar,
                trailingType: CustomListTileTrailing.badge,
                badgeText: '9',
              ),
            ],
          ),
        ),
      );

      await expectLater(
        find.byKey(columnKey),
        matchesGoldenFile('goldens/custom_list_tile_variations.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
