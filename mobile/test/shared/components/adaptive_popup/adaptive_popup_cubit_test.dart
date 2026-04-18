import 'package:afc/shared/components/adaptive_popup/adaptive_popup_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptivePopupCubit', () {
    late AdaptivePopupCubit cubit;

    setUp(() {
      cubit = AdaptivePopupCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptivePopupState());
    });

    blocTest<AdaptivePopupCubit, AdaptivePopupState>(
      'onInputChanged updates inputValue and clears error',
      build: () => cubit,
      seed: () => const AdaptivePopupState(errorMessage: 'Required'),
      act: (cubit) => cubit.onInputChanged('Test Team'),
      expect: () => [
        const AdaptivePopupState(inputValue: 'Test Team', errorMessage: null),
      ],
    );

    blocTest<AdaptivePopupCubit, AdaptivePopupState>(
      'setLoading emits correct state',
      build: () => cubit,
      act: (cubit) => cubit.setLoading(true),
      expect: () => [const AdaptivePopupState(isLoading: true)],
    );

    blocTest<AdaptivePopupCubit, AdaptivePopupState>(
      'setError emits correct error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Network failed'),
      expect: () => [const AdaptivePopupState(errorMessage: 'Network failed')],
    );

    test('validateInput returns false and sets error if empty', () {
      final result = cubit.validateInput(errorMessage: 'Cannot be empty');
      expect(result, isFalse);
      expect(cubit.state.errorMessage, 'Cannot be empty');
    });

    test('validateInput returns true if input exists', () {
      cubit.onInputChanged('Valid Name');
      final result = cubit.validateInput(errorMessage: 'Cannot be empty');
      expect(result, isTrue);
      expect(cubit.state.errorMessage, isNull);
    });

    blocTest<AdaptivePopupCubit, AdaptivePopupState>(
      'reset returns to default state',
      build: () => cubit,
      seed: () =>
          const AdaptivePopupState(inputValue: 'Dirty', isLoading: true),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptivePopupState()],
    );
  });
}
