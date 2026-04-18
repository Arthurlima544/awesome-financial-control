import 'dart:ui' show CheckedState, Tristate;
import 'package:afc/shared/components/adaptive_checkbox/adaptive_checkbox.dart';
import 'package:afc/shared/components/adaptive_checkbox/adaptive_checkbox_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveCheckboxCubit cubit,
    ValueChanged<bool>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveCheckbox(
              semanticLabel: 'Terms and Conditions',
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveCheckbox Widget Tests', () {
    late AdaptiveCheckboxCubit cubit;

    setUp(() {
      cubit = AdaptiveCheckboxCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );

      expect(find.byType(AdaptiveCheckbox), findsOneWidget);

      // Verify semantics
      final semanticsNode = tester.getSemantics(
        find.bySemanticsLabel('Terms and Conditions'),
      );
      expect(semanticsNode.label, 'Terms and Conditions');
      expect(semanticsNode.flagsCollection.isEnabled, Tristate.isTrue);
      expect(semanticsNode.flagsCollection.isChecked, CheckedState.isFalse);
      expect(
        semanticsNode.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
    });

    testWidgets('taps trigger onChanged callback and update UI', (
      WidgetTester tester,
    ) async {
      bool? checkboxValue;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onChanged: (val) => checkboxValue = val,
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(AdaptiveCheckbox));
      await tester.pumpAndSettle();

      expect(checkboxValue, isTrue);
      expect(cubit.state.isChecked, isTrue);

      // Verify the icon becomes visible
      final opacityWidget = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacityWidget.opacity, 1.0);
    });

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      // Passing null to onChanged effectively disables the checkbox
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: null),
      );

      await tester.tap(find.byType(AdaptiveCheckbox));
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
      expect(cubit.state.isChecked, isFalse);
    });

    testWidgets('renders error state border', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );

      cubit.setError('Error');
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

    testWidgets('Golden Test - Default Unchecked State', (
      WidgetTester tester,
    ) async {
      // Fix physical size to ensure consistent golden tests across environments
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AdaptiveCheckbox),
        matchesGoldenFile('goldens/adaptive_checkbox_default.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
