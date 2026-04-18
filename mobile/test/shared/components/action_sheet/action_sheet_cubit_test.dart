import 'package:afc/shared/components/action_sheet/action_sheet_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionSheetCubit', () {
    final mockOptions = [
      const ActionSheetOption(id: '1', label: 'Download'),
      const ActionSheetOption(id: '2', label: 'Share'),
    ];

    late ActionSheetCubit cubit;

    setUp(() {
      cubit = ActionSheetCubit(options: mockOptions);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        ActionSheetState(
          options: mockOptions,
          selectedOptionId: null,
          errorMessage: null,
        ),
      );
    });

    blocTest<ActionSheetCubit, ActionSheetState>(
      'emits state with selected option ID when selectOption is called',
      build: () => cubit,
      act: (cubit) => cubit.selectOption('1'),
      expect: () => [
        ActionSheetState(options: mockOptions, selectedOptionId: '1'),
      ],
    );

    blocTest<ActionSheetCubit, ActionSheetState>(
      'clears error when option is selected',
      build: () => cubit,
      seed: () => ActionSheetState(
        options: mockOptions,
        errorMessage: 'Please select an option',
      ),
      act: (cubit) => cubit.selectOption('2'),
      expect: () => [
        ActionSheetState(
          options: mockOptions,
          selectedOptionId: '2',
          errorMessage: null,
        ),
      ],
    );

    blocTest<ActionSheetCubit, ActionSheetState>(
      'emits state with error message when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid action'),
      expect: () => [
        ActionSheetState(options: mockOptions, errorMessage: 'Invalid action'),
      ],
    );

    blocTest<ActionSheetCubit, ActionSheetState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () => ActionSheetState(
        options: mockOptions,
        selectedOptionId: '2',
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [ActionSheetState(options: mockOptions)],
    );
  });
}
