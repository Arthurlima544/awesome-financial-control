import 'package:afc/widgets/adaptative_nav_bar/adaptive_nav_bar_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveNavBarCubit', () {
    late AdaptiveNavBarCubit cubit;

    setUp(() {
      cubit = AdaptiveNavBarCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveNavBarState());
    });

    blocTest<AdaptiveNavBarCubit, AdaptiveNavBarState>(
      'emits [AdaptiveNavBarState(isLoading: true)] when setLoading(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setLoading(true),
      expect: () => [const AdaptiveNavBarState(isLoading: true)],
    );

    blocTest<AdaptiveNavBarCubit, AdaptiveNavBarState>(
      'emits correct state when setActionDisabled is called',
      build: () => cubit,
      act: (cubit) => cubit.setActionDisabled(true),
      expect: () => [const AdaptiveNavBarState(isActionDisabled: true)],
    );

    blocTest<AdaptiveNavBarCubit, AdaptiveNavBarState>(
      'emits error state when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Sync failed'),
      expect: () => [const AdaptiveNavBarState(errorMessage: 'Sync failed')],
    );

    blocTest<AdaptiveNavBarCubit, AdaptiveNavBarState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const AdaptiveNavBarState(isLoading: true, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(),
      expect: () => [const AdaptiveNavBarState()],
    );
  });
}
