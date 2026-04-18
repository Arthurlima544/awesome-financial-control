import 'package:afc/shared/components/adaptive_switch/adaptive_switch_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveSwitchCubit', () {
    late AdaptiveSwitchCubit cubit;

    setUp(() {
      cubit = AdaptiveSwitchCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct (default off)', () {
      expect(cubit.state, const AdaptiveSwitchState(isOn: false));
    });

    blocTest<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      'toggle() emits [isOn: true] when initially false',
      build: () => cubit,
      act: (cubit) => cubit.toggle(),
      expect: () => [const AdaptiveSwitchState(isOn: true)],
    );

    blocTest<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      'setValue() emits correct state and clears error',
      build: () => cubit,
      seed: () => const AdaptiveSwitchState(isOn: false, errorMessage: 'Error'),
      act: (cubit) => cubit.setValue(true),
      expect: () => [const AdaptiveSwitchState(isOn: true, errorMessage: null)],
    );

    blocTest<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      'toggle() does nothing if disabled',
      build: () => cubit,
      seed: () => const AdaptiveSwitchState(isOn: false, isDisabled: true),
      act: (cubit) => cubit.toggle(),
      expect: () => [],
    );

    blocTest<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const AdaptiveSwitchState(isFocused: true)],
    );

    blocTest<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Must accept terms'),
      expect: () => [
        const AdaptiveSwitchState(errorMessage: 'Must accept terms'),
      ],
    );

    blocTest<AdaptiveSwitchCubit, AdaptiveSwitchState>(
      'reset() returns to default state',
      build: () => cubit,
      seed: () => const AdaptiveSwitchState(isOn: true, isFocused: true),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveSwitchState()],
    );
  });
}
