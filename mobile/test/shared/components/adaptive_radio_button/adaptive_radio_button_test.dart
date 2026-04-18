import 'dart:ui' show CheckedState, Tristate;
import 'package:afc/shared/components/adaptive_radio_button/adaptive_radio_button.dart';
import 'package:afc/shared/components/adaptive_radio_button/adaptive_radio_button_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveRadioButtonCubit cubit,
    VoidCallback? onSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveRadioButton(
              semanticLabel: 'Accept Terms Radio',
              onSelected: onSelected,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveRadioButton Widget Tests', () {
    late AdaptiveRadioButtonCubit cubit;

    setUp(() {
      cubit = AdaptiveRadioButtonCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default unselected state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onSelected: () {}),
      );

      expect(find.byType(AdaptiveRadioButton), findsOneWidget);

      // Verify semantics
      final semanticsNode = tester.getSemantics(
        find.bySemanticsLabel('Accept Terms Radio'),
      );
      expect(semanticsNode.label, 'Accept Terms Radio');
      expect(semanticsNode.flagsCollection.isEnabled, Tristate.isTrue);
      expect(semanticsNode.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(semanticsNode.flagsCollection.isChecked, CheckedState.isFalse);
      expect(
        semanticsNode.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
    });

    testWidgets('taps trigger onSelected callback and update UI state', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onSelected: () => wasTapped = true),
      );

      // Tap the radio button
      await tester.tap(find.byType(AdaptiveRadioButton));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
      expect(cubit.state.isSelected, isTrue);

      // Verify selected visual properties (inner dot is present when selected)
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(AnimatedContainer).first,
        ),
      );

      // Since it's selected, it should have a child (the inner white dot)
      expect(container.child, isNotNull);
    });

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      // Passing null to onSelected disables the widget effectively
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onSelected: null),
      );

      await tester.tap(find.byType(AdaptiveRadioButton));
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
      expect(cubit.state.isSelected, isFalse);
    });

    testWidgets('renders error state border', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onSelected: () {}),
      );

      cubit.setError('Error!');
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(AnimatedContainer).first,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
    });

    testWidgets('Golden Test - Default Unselected State', (
      WidgetTester tester,
    ) async {
      // Fix physical size for reliable golden tests
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onSelected: () {}),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AdaptiveRadioButton),
        matchesGoldenFile('goldens/adaptive_radio_button_unselected.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
