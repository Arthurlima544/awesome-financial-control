import 'package:afc/shared/components/adaptive_slider/adaptive_slider_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveSliderCubit', () {
    late AdaptiveSliderCubit cubit;

    setUp(() {
      cubit = AdaptiveSliderCubit(initialStart: 0.0, initialEnd: 5.0);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const AdaptiveSliderState(startValue: 0.0, endValue: 5.0),
      );
    });

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'updateSingleValue() updates endValue and clears error',
      build: () => cubit,
      seed: () => const AdaptiveSliderState(
        startValue: 0.0,
        endValue: 5.0,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.updateSingleValue(8.0),
      expect: () => [
        const AdaptiveSliderState(
          startValue: 0.0,
          endValue: 8.0,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'updateRangeValues() updates both values if start <= end',
      build: () => cubit,
      act: (cubit) => cubit.updateRangeValues(2.0, 7.0),
      expect: () => [const AdaptiveSliderState(startValue: 2.0, endValue: 7.0)],
    );

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'updateRangeValues() ignores update if start > end',
      build: () => cubit,
      act: (cubit) => cubit.updateRangeValues(8.0, 5.0),
      expect: () => [],
    );

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'updates do nothing if disabled',
      build: () => cubit,
      seed: () => const AdaptiveSliderState(
        startValue: 0.0,
        endValue: 5.0,
        isDisabled: true,
      ),
      act: (cubit) {
        cubit.updateSingleValue(10.0);
        cubit.updateRangeValues(1.0, 9.0);
      },
      expect: () => [],
    );

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [
        const AdaptiveSliderState(
          startValue: 0.0,
          endValue: 5.0,
          isFocused: true,
        ),
      ],
    );

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Value too high'),
      expect: () => [
        const AdaptiveSliderState(
          startValue: 0.0,
          endValue: 5.0,
          errorMessage: 'Value too high',
        ),
      ],
    );

    blocTest<AdaptiveSliderCubit, AdaptiveSliderState>(
      'reset() returns to provided default values',
      build: () => cubit,
      seed: () => const AdaptiveSliderState(
        startValue: 2.0,
        endValue: 8.0,
        isFocused: true,
      ),
      act: (cubit) => cubit.reset(0.0, 10.0),
      expect: () => [
        const AdaptiveSliderState(startValue: 0.0, endValue: 10.0),
      ],
    );
  });
}
