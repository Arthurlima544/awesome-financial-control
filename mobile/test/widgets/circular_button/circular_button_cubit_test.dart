import 'package:afc/widgets/circular_button/circular_button_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CircularButtonCubit', () {
    late CircularButtonCubit cubit;

    setUp(() {
      cubit = CircularButtonCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const CircularButtonState());
    });

    blocTest<CircularButtonCubit, CircularButtonState>(
      'emits [isLoading: true] when setLoading(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setLoading(true),
      expect: () => [const CircularButtonState(isLoading: true)],
    );

    blocTest<CircularButtonCubit, CircularButtonState>(
      'emits [isDisabled: true] when setDisabled(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setDisabled(true),
      expect: () => [const CircularButtonState(isDisabled: true)],
    );

    blocTest<CircularButtonCubit, CircularButtonState>(
      'emits [isFocused: true] when setFocus(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const CircularButtonState(isFocused: true)],
    );

    blocTest<CircularButtonCubit, CircularButtonState>(
      'emits error state when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Action failed'),
      expect: () => [const CircularButtonState(errorMessage: 'Action failed')],
    );

    blocTest<CircularButtonCubit, CircularButtonState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () => const CircularButtonState(
        isLoading: true,
        isDisabled: true,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [const CircularButtonState()],
    );
  });
}
