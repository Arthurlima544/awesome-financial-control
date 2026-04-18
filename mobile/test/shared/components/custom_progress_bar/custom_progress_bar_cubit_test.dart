import 'package:afc/shared/components/custom_progress_bar/custom_progress_bar_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomProgressBarCubit', () {
    late CustomProgressBarCubit cubit;

    setUp(() {
      cubit = CustomProgressBarCubit(initialProgress: 0.3);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct based on constructor input', () {
      expect(
        cubit.state,
        const CustomProgressBarState(progress: 0.3, errorMessage: null),
      );
    });

    test('initial state clamps out-of-bounds input', () {
      final localCubit = CustomProgressBarCubit(initialProgress: 1.5);
      expect(localCubit.state, const CustomProgressBarState(progress: 1.0));
      localCubit.close();
    });

    blocTest<CustomProgressBarCubit, CustomProgressBarState>(
      'emits correct state when setProgress is called with valid input',
      build: () => cubit,
      act: (cubit) => cubit.setProgress(0.75),
      expect: () => [
        const CustomProgressBarState(progress: 0.75, errorMessage: null),
      ],
    );

    blocTest<CustomProgressBarCubit, CustomProgressBarState>(
      'emits error state when setProgress is called with input > 1.0',
      build: () => cubit,
      act: (cubit) => cubit.setProgress(1.2),
      expect: () => [
        const CustomProgressBarState(
          progress: 0.3,
          errorMessage: 'Progress must be between 0.0 and 1.0',
        ),
      ],
    );

    blocTest<CustomProgressBarCubit, CustomProgressBarState>(
      'emits error state when setProgress is called with input < 0.0',
      build: () => cubit,
      act: (cubit) => cubit.setProgress(-0.5),
      expect: () => [
        const CustomProgressBarState(
          progress: 0.3,
          errorMessage: 'Progress must be between 0.0 and 1.0',
        ),
      ],
    );

    blocTest<CustomProgressBarCubit, CustomProgressBarState>(
      'clears error when valid setProgress is called after an error',
      build: () => cubit,
      seed: () => const CustomProgressBarState(
        progress: 0.3,
        errorMessage: 'Previous error',
      ),
      act: (cubit) => cubit.setProgress(0.5),
      expect: () => [
        const CustomProgressBarState(progress: 0.5, errorMessage: null),
      ],
    );

    blocTest<CustomProgressBarCubit, CustomProgressBarState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const CustomProgressBarState(progress: 0.8, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(initialProgress: 0.0),
      expect: () => [
        const CustomProgressBarState(progress: 0.0, errorMessage: null),
      ],
    );
  });
}
