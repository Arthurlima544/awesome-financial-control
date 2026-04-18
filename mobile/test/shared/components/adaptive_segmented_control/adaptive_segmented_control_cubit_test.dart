import 'package:afc/shared/components/adaptive_segmented_control/adaptive_segmented_control_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveSegmentedControlCubit', () {
    late AdaptiveSegmentedControlCubit cubit;

    setUp(() {
      cubit = AdaptiveSegmentedControlCubit(initialIndex: 0);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const AdaptiveSegmentedControlState(selectedIndex: 0),
      );
    });

    blocTest<AdaptiveSegmentedControlCubit, AdaptiveSegmentedControlState>(
      'setSelectedIndex updates index and clears error',
      build: () => cubit,
      seed: () => const AdaptiveSegmentedControlState(
        selectedIndex: 0,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.setSelectedIndex(1),
      expect: () => [
        const AdaptiveSegmentedControlState(
          selectedIndex: 1,
          errorMessage: null,
        ),
      ],
    );

    blocTest<AdaptiveSegmentedControlCubit, AdaptiveSegmentedControlState>(
      'setSelectedIndex does nothing if already selected',
      build: () => cubit,
      seed: () => const AdaptiveSegmentedControlState(selectedIndex: 1),
      act: (cubit) => cubit.setSelectedIndex(1),
      expect: () => [],
    );

    blocTest<AdaptiveSegmentedControlCubit, AdaptiveSegmentedControlState>(
      'setSelectedIndex does nothing if disabled',
      build: () => cubit,
      seed: () => const AdaptiveSegmentedControlState(
        selectedIndex: 0,
        isDisabled: true,
      ),
      act: (cubit) => cubit.setSelectedIndex(2),
      expect: () => [],
    );

    blocTest<AdaptiveSegmentedControlCubit, AdaptiveSegmentedControlState>(
      'setFocus emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [
        const AdaptiveSegmentedControlState(selectedIndex: 0, isFocused: true),
      ],
    );

    blocTest<AdaptiveSegmentedControlCubit, AdaptiveSegmentedControlState>(
      'setError emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid selection'),
      expect: () => [
        const AdaptiveSegmentedControlState(
          selectedIndex: 0,
          errorMessage: 'Invalid selection',
        ),
      ],
    );

    blocTest<AdaptiveSegmentedControlCubit, AdaptiveSegmentedControlState>(
      'reset returns to default index',
      build: () => cubit,
      seed: () => const AdaptiveSegmentedControlState(
        selectedIndex: 2,
        isFocused: true,
      ),
      act: (cubit) => cubit.reset(defaultIndex: 0),
      expect: () => [const AdaptiveSegmentedControlState(selectedIndex: 0)],
    );
  });
}
