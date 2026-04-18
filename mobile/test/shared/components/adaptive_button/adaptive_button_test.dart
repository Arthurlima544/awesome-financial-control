import 'package:afc/shared/components/adaptive_button/adaptive_button.dart';
import 'package:afc/shared/components/adaptive_button/adaptive_button_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveButtonCubit cubit,
    VoidCallback? onPressed,
    AdaptiveButtonVariant variant = AdaptiveButtonVariant.solid,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveButton(
              text: 'Click Me',
              onPressed: onPressed,
              variant: variant,
              leadingIcon: Icons.circle_outlined,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveButton Widget Tests', () {
    late AdaptiveButtonCubit cubit;

    setUp(() {
      cubit = AdaptiveButtonCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('onPressed callback fires correctly when tapped', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () => wasTapped = true),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('rebuilds and shows loading indicator on Cubit state change', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );

      // Trigger loading state
      cubit.setLoading(true);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Leading icon is hidden when loading
      expect(find.byIcon(Icons.circle_outlined), findsNothing);
    });

    testWidgets('does not fire onPressed when Cubit state is disabled', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () => wasTapped = true),
      );

      cubit.setDisabled(true);
      await tester.pump();

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
    });

    testWidgets('Golden Test - Default Solid Button', (
      WidgetTester tester,
    ) async {
      // Define a standard physical size for the golden test
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AdaptiveButton),
        matchesGoldenFile('goldens/adaptive_button_solid.png'),
      );

      // Reset view configurations
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
