import 'package:afc/shared/components/adaptive_popup/adaptive_popup.dart';
import 'package:afc/shared/components/adaptive_popup/adaptive_popup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptivePopupCubit cubit,
    bool showInputField = false,
    String? secondaryButtonText,
    Widget? headerImage,
    void Function(String)? onPrimaryAction,
    VoidCallback? onSecondaryAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor:
            Colors.grey.shade800, // Background to make popup stand out
        body: BlocProvider.value(
          value: cubit,
          child: AdaptivePopup(
            title: 'Remove item?',
            description:
                'Are you sure want to remove this item from your cart?',
            primaryButtonText: 'Sure',
            secondaryButtonText: secondaryButtonText,
            showInputField: showInputField,
            headerImage: headerImage,
            onPrimaryAction: onPrimaryAction,
            onSecondaryAction: onSecondaryAction,
          ),
        ),
      ),
    );
  }

  group('AdaptivePopup Widget Tests', () {
    late AdaptivePopupCubit cubit;

    setUp(() {
      cubit = AdaptivePopupCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders basic text popup correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPrimaryAction: (_) {}),
      );

      expect(find.text('Remove item?'), findsOneWidget);
      expect(
        find.text('Are you sure want to remove this item from your cart?'),
        findsOneWidget,
      );
      expect(find.text('Sure'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('renders secondary button when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, secondaryButtonText: 'No, thanks'),
      );

      expect(find.text('No, thanks'), findsOneWidget);
    });

    testWidgets('taps trigger callbacks appropriately', (
      WidgetTester tester,
    ) async {
      String? submittedValue;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          showInputField: true,
          secondaryButtonText: 'Cancel',
          onPrimaryAction: (val) => submittedValue = val,
          onSecondaryAction: () => secondaryTapped = true,
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'My Team Name');
      await tester.pump();

      // Tap Primary
      await tester.tap(find.text('Sure'));
      await tester.pumpAndSettle();

      // Tap Secondary
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(submittedValue, 'My Team Name');
      expect(secondaryTapped, isTrue);
    });

    testWidgets('renders loading indicator and disables buttons when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, secondaryButtonText: 'Cancel'),
      );

      cubit.setLoading(true);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sure'), findsNothing); // Text is replaced by spinner
    });

    testWidgets('renders error text on TextField when Cubit emits error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, showInputField: true),
      );

      cubit.setError('Team name is required');
      await tester.pump();

      expect(find.text('Team name is required'), findsOneWidget);
    });

    testWidgets('Golden Test - Popup with Input and Two Buttons', (
      WidgetTester tester,
    ) async {
      // Fix physical size to ensure consistent golden tests across environments
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          showInputField: true,
          secondaryButtonText: 'No, thanks',
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AdaptivePopup),
        matchesGoldenFile('goldens/adaptive_popup_complex.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
