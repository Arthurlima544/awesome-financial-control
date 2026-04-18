import 'package:afc/shared/components/adaptive_radio_button/adaptive_radio_button_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveRadioButtonCubit', () {
    late AdaptiveRadioButtonCubit cubit;

    setUp(() {
      cubit = AdaptiveRadioButtonCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveRadioButtonState(isSelected: false));
    });

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'select() emits [isSelected: true] when initially false',
      build: () => cubit,
      act: (cubit) => cubit.select(),
      expect: () => [const AdaptiveRadioButtonState(isSelected: true)],
    );

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'select() does not emit when already selected',
      build: () => cubit,
      seed: () => const AdaptiveRadioButtonState(isSelected: true),
      act: (cubit) => cubit.select(),
      expect: () => [],
    );

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'setSelection() forces state change and clears error',
      build: () => cubit,
      seed: () => const AdaptiveRadioButtonState(
        isSelected: true,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.setSelection(false),
      expect: () => [
        const AdaptiveRadioButtonState(isSelected: false, errorMessage: null),
      ],
    );

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'select() does nothing if disabled',
      build: () => cubit,
      seed: () =>
          const AdaptiveRadioButtonState(isSelected: false, isDisabled: true),
      act: (cubit) => cubit.select(),
      expect: () => [],
    );

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const AdaptiveRadioButtonState(isFocused: true)],
    );

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Selection required'),
      expect: () => [
        const AdaptiveRadioButtonState(errorMessage: 'Selection required'),
      ],
    );

    blocTest<AdaptiveRadioButtonCubit, AdaptiveRadioButtonState>(
      'reset() returns to default state',
      build: () => cubit,
      seed: () =>
          const AdaptiveRadioButtonState(isSelected: true, isFocused: true),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveRadioButtonState()],
    );
  });
}
