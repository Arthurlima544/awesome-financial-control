import 'package:afc/widgets/custom_list_tile/custom_list_tile_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomListTileCubit', () {
    late CustomListTileCubit cubit;

    setUp(() {
      cubit = CustomListTileCubit(initialValue: false);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const CustomListTileState(isSelected: false, errorMessage: null),
      );
    });

    blocTest<CustomListTileCubit, CustomListTileState>(
      'emits state with isSelected: true when toggleValue(true) is called',
      build: () => cubit,
      act: (cubit) => cubit.toggleValue(true),
      expect: () => [
        const CustomListTileState(isSelected: true, errorMessage: null),
      ],
    );

    blocTest<CustomListTileCubit, CustomListTileState>(
      'emits state with error message and clears it on toggle',
      build: () => cubit,
      act: (cubit) {
        cubit.setError('Invalid selection');
        cubit.toggleValue(true);
      },
      expect: () => [
        const CustomListTileState(
          isSelected: false,
          errorMessage: 'Invalid selection',
        ),
        const CustomListTileState(isSelected: true, errorMessage: null),
      ],
    );

    blocTest<CustomListTileCubit, CustomListTileState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const CustomListTileState(isSelected: true, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(false),
      expect: () => [
        const CustomListTileState(isSelected: false, errorMessage: null),
      ],
    );
  });
}
