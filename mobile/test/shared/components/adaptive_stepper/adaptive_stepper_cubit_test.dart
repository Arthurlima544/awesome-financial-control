import 'package:afc/shared/components/adaptive_stepper/adaptive_stepper_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveStepperCubit', () {
    late AdaptiveStepperCubit cubit;

    setUp(() {
      cubit = AdaptiveStepperCubit(initialValue: 0, min: 0, max: 5);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveStepperState(value: 0, min: 0, max: 5));
    });

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'increment() increases value when below max',
      build: () => cubit,
      act: (cubit) => cubit.increment(),
      expect: () => [const AdaptiveStepperState(value: 1, min: 0, max: 5)],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'increment() does nothing when at max',
      build: () => AdaptiveStepperCubit(initialValue: 5, min: 0, max: 5),
      act: (cubit) => cubit.increment(),
      expect: () => [],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'decrement() decreases value when above min',
      build: () => AdaptiveStepperCubit(initialValue: 2, min: 0, max: 5),
      act: (cubit) => cubit.decrement(),
      expect: () => [const AdaptiveStepperState(value: 1, min: 0, max: 5)],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'decrement() does nothing when at min',
      build: () => cubit,
      act: (cubit) => cubit.decrement(),
      expect: () => [],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'increment() / decrement() does nothing if disabled',
      build: () => AdaptiveStepperCubit(
        initialValue: 2,
        min: 0,
        max: 5,
        isDisabled: true,
      ),
      act: (cubit) {
        cubit.increment();
        cubit.decrement();
      },
      expect: () => [],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [
        const AdaptiveStepperState(value: 0, min: 0, max: 5, isFocused: true),
      ],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Out of stock'),
      expect: () => [
        const AdaptiveStepperState(
          value: 0,
          min: 0,
          max: 5,
          errorMessage: 'Out of stock',
        ),
      ],
    );

    blocTest<AdaptiveStepperCubit, AdaptiveStepperState>(
      'reset() returns to base min/max configuration',
      build: () => cubit,
      seed: () =>
          const AdaptiveStepperState(value: 3, min: 0, max: 5, isFocused: true),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveStepperState(value: 0, min: 0, max: 5)],
    );
  });
}
