import 'package:afc/shared/components/horizontal_date_picker/horizontal_date_picker_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HorizontalDatePickerCubit', () {
    late HorizontalDatePickerCubit cubit;
    final testDate = DateTime(2023, 10, 25);

    setUp(() {
      cubit = HorizontalDatePickerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct (null date)', () {
      expect(
        cubit.state,
        const HorizontalDatePickerState(selectedDate: null, errorMessage: null),
      );
    });

    test('initial state handles initialDate injection', () {
      final prefilledCubit = HorizontalDatePickerCubit(initialDate: testDate);
      expect(
        prefilledCubit.state,
        HorizontalDatePickerState(selectedDate: testDate),
      );
      prefilledCubit.close();
    });

    blocTest<HorizontalDatePickerCubit, HorizontalDatePickerState>(
      'emits correct state when selectDate is called and clears error',
      build: () => cubit,
      seed: () => const HorizontalDatePickerState(errorMessage: 'Error'),
      act: (cubit) => cubit.selectDate(testDate),
      expect: () => [
        HorizontalDatePickerState(selectedDate: testDate, errorMessage: null),
      ],
    );

    blocTest<HorizontalDatePickerCubit, HorizontalDatePickerState>(
      'emits correct state when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Invalid Date'),
      expect: () => [
        const HorizontalDatePickerState(errorMessage: 'Invalid Date'),
      ],
    );

    blocTest<HorizontalDatePickerCubit, HorizontalDatePickerState>(
      'emits correct state when reset is called',
      build: () => cubit,
      seed: () => HorizontalDatePickerState(
        selectedDate: testDate,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.reset(null),
      expect: () => [
        const HorizontalDatePickerState(selectedDate: null, errorMessage: null),
      ],
    );
  });
}
