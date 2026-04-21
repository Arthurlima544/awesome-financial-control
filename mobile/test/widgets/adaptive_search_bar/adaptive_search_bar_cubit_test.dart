import 'package:afc/widgets/adaptive_search_bar/adaptive_search_bar_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveSearchBarCubit', () {
    late AdaptiveSearchBarCubit cubit;

    setUp(() {
      cubit = AdaptiveSearchBarCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const AdaptiveSearchBarState());
    });

    blocTest<AdaptiveSearchBarCubit, AdaptiveSearchBarState>(
      'emits correct state when updateQuery is called and clears error',
      build: () => cubit,
      seed: () => const AdaptiveSearchBarState(errorMessage: 'Error'),
      act: (cubit) => cubit.updateQuery('Colorado'),
      expect: () => [
        const AdaptiveSearchBarState(query: 'Colorado', errorMessage: null),
      ],
    );

    blocTest<AdaptiveSearchBarCubit, AdaptiveSearchBarState>(
      'emits correct state when setFocus is called',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [const AdaptiveSearchBarState(isFocused: true)],
    );

    blocTest<AdaptiveSearchBarCubit, AdaptiveSearchBarState>(
      'emits error state when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid input'),
      expect: () => [
        const AdaptiveSearchBarState(errorMessage: 'Invalid input'),
      ],
    );

    blocTest<AdaptiveSearchBarCubit, AdaptiveSearchBarState>(
      'emits initial clean state when clear is called',
      build: () => cubit,
      seed: () => const AdaptiveSearchBarState(
        query: 'Testing',
        isFocused: true,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.clear(),
      expect: () => [
        const AdaptiveSearchBarState(
          query: '',
          isFocused: true,
          errorMessage: null,
        ),
      ],
    );
  });
}
