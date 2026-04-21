import 'package:afc/widgets/adaptive_badge/adaptive_badge_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveBadgeCubit', () {
    late AdaptiveBadgeCubit cubit;

    setUp(() {
      cubit = AdaptiveBadgeCubit(initialLabel: 'Info', initialCount: 1);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const AdaptiveBadgeState(label: 'Info', count: 1, isVisible: true),
      );
    });

    blocTest<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      'updateLabel updates the label and clears error',
      build: () => cubit,
      seed: () =>
          const AdaptiveBadgeState(label: 'Info', errorMessage: 'Error'),
      act: (cubit) => cubit.updateLabel('Success'),
      expect: () => [
        const AdaptiveBadgeState(label: 'Success', errorMessage: null),
      ],
    );

    blocTest<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      'updateCount updates the count',
      build: () => cubit,
      act: (cubit) => cubit.updateCount(5),
      expect: () => [const AdaptiveBadgeState(label: 'Info', count: 5)],
    );

    blocTest<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      'setVisibility toggles visibility',
      build: () => cubit,
      act: (cubit) => cubit.setVisibility(false),
      expect: () => [
        const AdaptiveBadgeState(label: 'Info', count: 1, isVisible: false),
      ],
    );

    blocTest<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      'setFocus emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [
        const AdaptiveBadgeState(label: 'Info', count: 1, isFocused: true),
      ],
    );

    blocTest<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      'setError emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid Data'),
      expect: () => [
        const AdaptiveBadgeState(
          label: 'Info',
          count: 1,
          errorMessage: 'Invalid Data',
        ),
      ],
    );

    blocTest<AdaptiveBadgeCubit, AdaptiveBadgeState>(
      'reset returns to provided defaults',
      build: () => cubit,
      seed: () => const AdaptiveBadgeState(
        label: 'Changed',
        count: 99,
        isFocused: true,
      ),
      act: (cubit) => cubit.reset(defaultLabel: 'Default', defaultCount: 0),
      expect: () => [const AdaptiveBadgeState(label: 'Default', count: 0)],
    );
  });
}
