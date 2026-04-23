import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afc/view_models/onboarding/onboarding_cubit.dart';

void main() {
  group('OnboardingCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state has isLoading true', () {
      final cubit = OnboardingCubit();
      expect(cubit.state.isLoading, true);
      cubit.close();
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'loadOnboardingStatus sets isLoading to false and isCompleted based on SharedPreferences',
      build: () => OnboardingCubit(),
      act: (cubit) => cubit.loadOnboardingStatus(),
      expect: () => [
        const OnboardingState(isCompleted: false, isLoading: false),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'setPage updates currentPage',
      build: () => OnboardingCubit(),
      seed: () => const OnboardingState(isLoading: false),
      act: (cubit) => cubit.setPage(1),
      expect: () => [const OnboardingState(currentPage: 1, isLoading: false)],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'completeOnboarding updates isCompleted and persists to SharedPreferences',
      build: () => OnboardingCubit(),
      seed: () => const OnboardingState(isLoading: false),
      act: (cubit) => cubit.completeOnboarding(),
      expect: () => [
        const OnboardingState(isCompleted: true, isLoading: false),
      ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('onboarding_done'), true);
      },
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'resetOnboarding updates isCompleted to false and persists to SharedPreferences',
      build: () => OnboardingCubit(),
      seed: () => const OnboardingState(isCompleted: true, isLoading: false),
      act: (cubit) => cubit.resetOnboarding(),
      expect: () => [
        const OnboardingState(
          isCompleted: false,
          isLoading: false,
          currentPage: 0,
        ),
      ],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('onboarding_done'), false);
      },
    );

    test('shouldShowOnboarding returns true if not done', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await OnboardingCubit.shouldShowOnboarding(), true);
    });

    test('shouldShowOnboarding returns false if done', () async {
      SharedPreferences.setMockInitialValues({'onboarding_done': true});
      expect(await OnboardingCubit.shouldShowOnboarding(), false);
    });
  });
}
