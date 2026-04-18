import 'package:afc/shared/components/adaptive_button/adaptive_button_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveButtonCubit', () {
    late AdaptiveButtonCubit cubit;

    setUp(() {
      cubit = AdaptiveButtonCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveButtonState());
    });

    blocTest<AdaptiveButtonCubit, AdaptiveButtonState>(
      'emits [isLoading: true] when setLoading(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setLoading(true),
      expect: () => [const AdaptiveButtonState(isLoading: true)],
    );

    blocTest<AdaptiveButtonCubit, AdaptiveButtonState>(
      'emits [isDisabled: true] when setDisabled(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setDisabled(true),
      expect: () => [const AdaptiveButtonState(isDisabled: true)],
    );

    blocTest<AdaptiveButtonCubit, AdaptiveButtonState>(
      'emits [isFocused: true] when setFocus(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const AdaptiveButtonState(isFocused: true)],
    );

    blocTest<AdaptiveButtonCubit, AdaptiveButtonState>(
      'emits error state when setError is called with validation message',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid action'),
      expect: () => [const AdaptiveButtonState(errorMessage: 'Invalid action')],
    );

    blocTest<AdaptiveButtonCubit, AdaptiveButtonState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () => const AdaptiveButtonState(
        isLoading: true,
        isDisabled: true,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveButtonState()],
    );
  });
}
