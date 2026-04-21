import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveTextFieldCubit cubit,
    ValueChanged<String>? onChanged,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: BlocProvider.value(
              value: cubit,
              child: AdaptiveTextField(
                hintText: 'Input text',
                onChanged: onChanged,
                leadingIcon: leadingIcon,
                trailingIcon: trailingIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveTextField Widget Tests', () {
    late AdaptiveTextFieldCubit cubit;

    setUp(() {
      cubit = AdaptiveTextFieldCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(cubit: cubit));

      expect(find.text('Input text'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onChanged callback fires and updates Cubit state', (
      WidgetTester tester,
    ) async {
      String changedValue = '';

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onChanged: (val) => changedValue = val,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello Flutter');
      await tester.pump();

      expect(changedValue, 'Hello Flutter');
      expect(cubit.state.text, 'Hello Flutter');
    });

    testWidgets('renders icons when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          leadingIcon: const Icon(Icons.circle_outlined),
          trailingIcon: const Icon(Icons.arrow_drop_down),
        ),
      );

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('renders error state correctly when Cubit emits error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(cubit: cubit));

      cubit.setError('This field is required');
      await tester.pumpAndSettle();

      expect(find.text('This field is required'), findsOneWidget);

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(Focus),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.border?.top.color,
        const Color(0xFFE53935),
      ); // defaultErrorColor
    });

    testWidgets('TextField is disabled when state is disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(cubit: cubit));

      cubit.setDisabled(true);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });
}
