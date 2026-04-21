import 'dart:ui' show Tristate;
import 'package:afc/widgets/adaptive_switch/adaptive_switch.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveSwitchCubit cubit,
    ValueChanged<bool>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveSwitch(
              semanticLabel: 'Enable Notifications',
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveSwitch Widget Tests', () {
    late AdaptiveSwitchCubit cubit;

    setUp(() {
      cubit = AdaptiveSwitchCubit();
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

      expect(find.byType(AdaptiveSwitch), findsOneWidget);
      // Verify semantics are setup for a switch
      final semanticsNode = tester.getSemantics(
        find.bySemanticsLabel('Enable Notifications'),
      );
      expect(semanticsNode.label, 'Enable Notifications');
      expect(semanticsNode.flagsCollection.isEnabled, Tristate.isTrue);
      expect(semanticsNode.flagsCollection.isToggled, Tristate.isFalse);
      expect(
        semanticsNode.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
    });

    testWidgets('taps trigger onChanged callback and update UI', (
      WidgetTester tester,
    ) async {
      bool? switchValue;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onChanged: (val) => switchValue = val,
        ),
      );

      // Tap the switch
      await tester.tap(find.byType(AdaptiveSwitch));
      await tester.pumpAndSettle();

      expect(switchValue, isTrue);
      expect(cubit.state.isOn, isTrue);

      // Verify alignment changed to right (active state)
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(AnimatedContainer).first,
        ),
      );
      expect(container.alignment, Alignment.centerRight);
    });

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      bool? switchValue;

      // Passing no onChanged disables the switch effectively
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: null),
      );

      await tester.tap(find.byType(AdaptiveSwitch));
      await tester.pumpAndSettle();

      // State shouldn't change
      expect(switchValue, isNull);
      expect(cubit.state.isOn, isFalse);
    });

    testWidgets('renders error state border', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onChanged: (_) {}),
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
  });
}
