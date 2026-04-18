import 'package:afc/shared/components/adaptive_slider/adaptive_slider_cubit.dart';
import 'package:afc/shared/components/adaptive_slider/adptive_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveSliderCubit cubit,
    bool isRange = false,
    ValueChanged<double>? onChangedSingle,
    ValueChanged<RangeValues>? onChangedRange,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveSlider(
              semanticLabel: 'Volume Slider',
              isRange: isRange,
              min: 0.0,
              max: 10.0,
              showLabels: true,
              onChangedSingle: onChangedSingle,
              onChangedRange: onChangedRange,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveSlider Widget Tests', () {
    late AdaptiveSliderCubit cubit;

    setUp(() {
      cubit = AdaptiveSliderCubit(initialStart: 2.0, initialEnd: 5.0);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly as a single slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          isRange: false,
          onChangedSingle: (_) {},
        ),
      );

      expect(find.byType(AdaptiveSlider), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(RangeSlider), findsNothing);
    });

    testWidgets('renders correctly as a range slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          isRange: true,
          onChangedRange: (_) {},
        ),
      );

      expect(find.byType(AdaptiveSlider), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.byType(Slider), findsNothing);
    });

    testWidgets(
      'single slider dragging triggers onChanged callback and state updates',
      (WidgetTester tester) async {
        double? changedValue;

        await tester.pumpWidget(
          buildTestableWidget(
            cubit: cubit,
            isRange: false,
            onChangedSingle: (val) => changedValue = val,
          ),
        );

        // Simulate dragging the slider
        await tester.drag(find.byType(Slider), const Offset(100.0, 0.0));
        await tester.pumpAndSettle();

        expect(changedValue, isNotNull);
        expect(cubit.state.endValue, equals(changedValue));
      },
    );

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      double? changedValue;

      // Providing null to onChanged disables it effectively
      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          isRange: false,
          onChangedSingle: null,
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(100.0, 0.0));
      await tester.pumpAndSettle();

      expect(changedValue, isNull);
      expect(cubit.state.endValue, 5.0); // Remains at initial value
    });

    testWidgets('renders error state visually via SliderTheme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          isRange: false,
          onChangedSingle: (_) {},
        ),
      );

      cubit.setError('Limit exceeded');
      await tester.pumpAndSettle();

      final sliderTheme = tester.widget<SliderTheme>(
        find.byType(SliderTheme).first,
      );
      expect(sliderTheme.data.activeTrackColor, Colors.red);
      expect(sliderTheme.data.thumbColor, Colors.red);
    });
  });
}
