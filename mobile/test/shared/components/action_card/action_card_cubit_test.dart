import 'package:afc/shared/components/action_card/action_card_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionCardCubit', () {
    late ActionCardCubit cubit;

    setUp(() {
      cubit = ActionCardCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const ActionCardState(isActionLoading: false, errorMessage: null),
      );
    });

    blocTest<ActionCardCubit, ActionCardState>(
      'emits state with isActionLoading: true when setActionLoading is called',
      build: () => cubit,
      act: (cubit) => cubit.setActionLoading(true),
      expect: () => [
        const ActionCardState(isActionLoading: true, errorMessage: null),
      ],
    );

    blocTest<ActionCardCubit, ActionCardState>(
      'emits error state and turns off loading when setError is called',
      build: () => cubit,
      seed: () => const ActionCardState(isActionLoading: true),
      act: (cubit) => cubit.setError('Network Error'),
      expect: () => [
        const ActionCardState(
          isActionLoading: false,
          errorMessage: 'Network Error',
        ),
      ],
    );

    blocTest<ActionCardCubit, ActionCardState>(
      'clears error message when setActionLoading is called again',
      build: () => cubit,
      seed: () => const ActionCardState(errorMessage: 'Previous Error'),
      act: (cubit) => cubit.setActionLoading(true),
      expect: () => [
        const ActionCardState(isActionLoading: true, errorMessage: null),
      ],
    );

    blocTest<ActionCardCubit, ActionCardState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const ActionCardState(isActionLoading: true, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(),
      expect: () => [const ActionCardState()],
    );
  });
}
