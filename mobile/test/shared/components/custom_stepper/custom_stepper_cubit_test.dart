import 'package:afc/shared/components/custom_stepper/custom_stepper_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomStepperCubit', () {
    late CustomStepperCubit cubit;

    setUp(() {
      cubit = CustomStepperCubit(initialStep: 0, totalSteps: 3);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const CustomStepperState(currentStep: 0, errorMessage: null),
      );
    });

    blocTest<CustomStepperCubit, CustomStepperState>(
      'emits correct state when setStep is called with valid index',
      build: () => cubit,
      act: (cubit) => cubit.setStep(2),
      expect: () => [
        const CustomStepperState(currentStep: 2, errorMessage: null),
      ],
    );

    blocTest<CustomStepperCubit, CustomStepperState>(
      'emits error state when setStep is called with out of bounds index (too high)',
      build: () => cubit,
      act: (cubit) => cubit.setStep(5),
      expect: () => [
        const CustomStepperState(
          currentStep: 0,
          errorMessage: 'Invalid step selection.',
        ),
      ],
    );

    blocTest<CustomStepperCubit, CustomStepperState>(
      'emits error state when setStep is called with out of bounds index (negative)',
      build: () => cubit,
      act: (cubit) => cubit.setStep(-1),
      expect: () => [
        const CustomStepperState(
          currentStep: 0,
          errorMessage: 'Invalid step selection.',
        ),
      ],
    );

    blocTest<CustomStepperCubit, CustomStepperState>(
      'clears error when valid setStep is called after an error',
      build: () => cubit,
      seed: () => const CustomStepperState(
        currentStep: 0,
        errorMessage: 'Previous error',
      ),
      act: (cubit) => cubit.setStep(1),
      expect: () => [
        const CustomStepperState(currentStep: 1, errorMessage: null),
      ],
    );

    blocTest<CustomStepperCubit, CustomStepperState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const CustomStepperState(currentStep: 2, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(0),
      expect: () => [
        const CustomStepperState(currentStep: 0, errorMessage: null),
      ],
    );
  });
}
