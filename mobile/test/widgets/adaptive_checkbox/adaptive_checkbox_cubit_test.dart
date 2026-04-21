import 'package:afc/widgets/adaptive_checkbox/adaptive_checkbox_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveCheckboxCubit', () {
    late AdaptiveCheckboxCubit cubit;

    setUp(() {
      cubit = AdaptiveCheckboxCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct (default unchecked)', () {
      expect(cubit.state, const AdaptiveCheckboxState(isChecked: false));
    });

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'toggle() emits [isChecked: true] when initially false',
      build: () => cubit,
      act: (cubit) => cubit.toggle(),
      expect: () => [const AdaptiveCheckboxState(isChecked: true)],
    );

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'toggle() clears error message upon state change',
      build: () => cubit,
      seed: () => const AdaptiveCheckboxState(
        isChecked: false,
        errorMessage: 'Required',
      ),
      act: (cubit) => cubit.toggle(),
      expect: () => [
        const AdaptiveCheckboxState(isChecked: true, errorMessage: null),
      ],
    );

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'setValue(true) emits correctly and does nothing if already true',
      build: () => cubit,
      act: (cubit) {
        cubit.setValue(true);
        cubit.setValue(true);
      },
      expect: () => [const AdaptiveCheckboxState(isChecked: true)],
    );

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'toggle() does nothing if disabled',
      build: () => cubit,
      seed: () =>
          const AdaptiveCheckboxState(isChecked: false, isDisabled: true),
      act: (cubit) => cubit.toggle(),
      expect: () => [],
    );

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const AdaptiveCheckboxState(isFocused: true)],
    );

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Must accept terms'),
      expect: () => [
        const AdaptiveCheckboxState(errorMessage: 'Must accept terms'),
      ],
    );

    blocTest<AdaptiveCheckboxCubit, AdaptiveCheckboxState>(
      'reset() returns to default state',
      build: () => cubit,
      seed: () => const AdaptiveCheckboxState(isChecked: true, isFocused: true),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveCheckboxState()],
    );
  });
}
