import 'package:afc/widgets/custom_snackbar/custom_snackbar_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomSnackbarCubit', () {
    late CustomSnackbarCubit cubit;

    setUp(() {
      cubit = CustomSnackbarCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const CustomSnackbarState(
          isVisible: true,
          isActionLoading: false,
          errorMessage: null,
        ),
      );
    });

    blocTest<CustomSnackbarCubit, CustomSnackbarState>(
      'emits [isVisible: false] when dismiss is called',
      build: () => cubit,
      act: (cubit) => cubit.dismiss(),
      expect: () => [const CustomSnackbarState(isVisible: false)],
    );

    blocTest<CustomSnackbarCubit, CustomSnackbarState>(
      'emits [isActionLoading: true] when setActionLoading(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.setActionLoading(true),
      expect: () => [const CustomSnackbarState(isActionLoading: true)],
    );

    blocTest<CustomSnackbarCubit, CustomSnackbarState>(
      'emits correct state with error message when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Network failure'),
      expect: () => [
        const CustomSnackbarState(
          errorMessage: 'Network failure',
          isActionLoading: false,
        ),
      ],
    );

    blocTest<CustomSnackbarCubit, CustomSnackbarState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const CustomSnackbarState(isVisible: false, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(),
      expect: () => [const CustomSnackbarState()],
    );
  });
}
