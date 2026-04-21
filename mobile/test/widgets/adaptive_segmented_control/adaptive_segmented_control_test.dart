import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveSegmentedControlCubit cubit,
    List<String> segments = const ['One', 'Two', 'Three'],
    ValueChanged<int>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: BlocProvider.value(
              value: cubit,
              child: AdaptiveSegmentedControl(
                segments: segments,
                semanticLabel: 'Test Segments',
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveSegmentedControl Widget Tests', () {
    late AdaptiveSegmentedControlCubit cubit;

    setUp(() {
      cubit = AdaptiveSegmentedControlCubit(initialIndex: 0);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders all segments correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );

      expect(find.byType(AdaptiveSegmentedControl), findsOneWidget);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('taps trigger onChanged callback and update active index', (
      WidgetTester tester,
    ) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onChanged: (val) => tappedIndex = val,
        ),
      );

      // Tap the second segment ("Two")
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
      expect(cubit.state.selectedIndex, 1);

      // Verify visual update via AnimatedPositioned translation
      final animatedPositioned = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      // Left coordinate should now be > 0
      expect(animatedPositioned.left, greaterThan(0.0));
    });

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      int? tappedIndex;

      // Setting onChanged to null disables the widget
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: null),
      );

      await tester.tap(find.text('Three'));
      await tester.pumpAndSettle();

      expect(tappedIndex, isNull);
      expect(cubit.state.selectedIndex, 0); // Remains 0
    });

    testWidgets('renders error state border and background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );

      cubit.setError('Please select an option');
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Focus),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
      expect(decoration.color, Colors.red.withValues(alpha: 0.1));
    });
  });
}
