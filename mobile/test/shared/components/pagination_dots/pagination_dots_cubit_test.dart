import 'package:afc/shared/components/pagination_dots/pagination_dots_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginationDotsCubit', () {
    late PaginationDotsCubit cubit;

    setUp(() {
      cubit = PaginationDotsCubit(initialPage: 0);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const PaginationDotsState(currentPage: 0, errorMessage: null),
      );
    });

    blocTest<PaginationDotsCubit, PaginationDotsState>(
      'emits correct state when setPage is called with valid index',
      build: () => cubit,
      act: (cubit) => cubit.setPage(2, 5),
      expect: () => [
        const PaginationDotsState(currentPage: 2, errorMessage: null),
      ],
    );

    blocTest<PaginationDotsCubit, PaginationDotsState>(
      'emits error state when setPage is called with out of bounds index (> total)',
      build: () => cubit,
      act: (cubit) => cubit.setPage(5, 5),
      expect: () => [
        const PaginationDotsState(
          currentPage: 0,
          errorMessage: 'Invalid page selected.',
        ),
      ],
    );

    blocTest<PaginationDotsCubit, PaginationDotsState>(
      'emits error state when setPage is called with negative index',
      build: () => cubit,
      act: (cubit) => cubit.setPage(-1, 5),
      expect: () => [
        const PaginationDotsState(
          currentPage: 0,
          errorMessage: 'Invalid page selected.',
        ),
      ],
    );

    blocTest<PaginationDotsCubit, PaginationDotsState>(
      'clears error when valid setPage is called after an error',
      build: () => cubit,
      seed: () => const PaginationDotsState(
        currentPage: 0,
        errorMessage: 'Previous error',
      ),
      act: (cubit) => cubit.setPage(1, 5),
      expect: () => [
        const PaginationDotsState(currentPage: 1, errorMessage: null),
      ],
    );

    blocTest<PaginationDotsCubit, PaginationDotsState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const PaginationDotsState(currentPage: 3, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(defaultPage: 0),
      expect: () => [
        const PaginationDotsState(currentPage: 0, errorMessage: null),
      ],
    );
  });
}
