import 'package:afc/shared/components/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveTextFieldCubit', () {
    late AdaptiveTextFieldCubit cubit;

    setUp(() {
      cubit = AdaptiveTextFieldCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveTextFieldState());
    });

    blocTest<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      'emits correct state when textChanged is called and clears error',
      build: () => cubit,
      seed: () => const AdaptiveTextFieldState(errorMessage: 'Required'),
      act: (cubit) => cubit.textChanged('Hello'),
      expect: () => [
        const AdaptiveTextFieldState(text: 'Hello', errorMessage: null),
      ],
    );

    blocTest<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      'emits [isFocused: true] when focusChanged(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.focusChanged(true),
      expect: () => [const AdaptiveTextFieldState(isFocused: true)],
    );

    blocTest<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      'emits [isDisabled: true] when setDisabled(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setDisabled(true),
      expect: () => [const AdaptiveTextFieldState(isDisabled: true)],
    );

    blocTest<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      'emits error state when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid input'),
      expect: () => [
        const AdaptiveTextFieldState(errorMessage: 'Invalid input'),
      ],
    );

    blocTest<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      'validate emits error when validation fails',
      build: () => cubit,
      seed: () => const AdaptiveTextFieldState(text: ''),
      act: (cubit) =>
          cubit.validate((val) => val.isEmpty ? 'Cannot be empty' : null),
      expect: () => [
        const AdaptiveTextFieldState(text: '', errorMessage: 'Cannot be empty'),
      ],
    );

    blocTest<AdaptiveTextFieldCubit, AdaptiveTextFieldState>(
      'emits initial clean state when reset is called',
      build: () => cubit,
      seed: () => const AdaptiveTextFieldState(
        text: 'Test',
        isFocused: true,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveTextFieldState()],
    );
  });
}
