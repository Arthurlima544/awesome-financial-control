import 'package:afc/widgets/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveChipCubit', () {
    late AdaptiveChipCubit cubit;

    setUp(() {
      cubit = AdaptiveChipCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveChipState(isSelected: false));
    });

    blocTest<AdaptiveChipCubit, AdaptiveChipState>(
      'toggleSelection() emits [isSelected: true] when initially false',
      build: () => cubit,
      act: (cubit) => cubit.toggleSelection(),
      expect: () => [const AdaptiveChipState(isSelected: true)],
    );

    blocTest<AdaptiveChipCubit, AdaptiveChipState>(
      'setSelected(true) emits correct state and clears error',
      build: () => cubit,
      seed: () =>
          const AdaptiveChipState(isSelected: false, errorMessage: 'Error'),
      act: (cubit) => cubit.setSelected(true),
      expect: () => [
        const AdaptiveChipState(isSelected: true, errorMessage: null),
      ],
    );

    blocTest<AdaptiveChipCubit, AdaptiveChipState>(
      'toggleSelection() does nothing if disabled',
      build: () => cubit,
      seed: () => const AdaptiveChipState(isSelected: false, isDisabled: true),
      act: (cubit) => cubit.toggleSelection(),
      expect: () => [],
    );

    blocTest<AdaptiveChipCubit, AdaptiveChipState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const AdaptiveChipState(isFocused: true)],
    );

    blocTest<AdaptiveChipCubit, AdaptiveChipState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Must select at least one'),
      expect: () => [
        const AdaptiveChipState(errorMessage: 'Must select at least one'),
      ],
    );

    blocTest<AdaptiveChipCubit, AdaptiveChipState>(
      'reset() returns to default state',
      build: () => cubit,
      seed: () => const AdaptiveChipState(isSelected: true, isFocused: true),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveChipState()],
    );
  });
}
