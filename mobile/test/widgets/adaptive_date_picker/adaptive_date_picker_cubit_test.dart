import 'package:afc/widgets/adaptive_date_picker/adaptive_date_picker_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveDatePickerCubit', () {
    late AdaptiveDatePickerCubit cubit;
    final defaultMonth = DateTime(2023, 10, 1); // October 2023

    setUp(() {
      cubit = AdaptiveDatePickerCubit(initialMonth: defaultMonth);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        AdaptiveDatePickerState(displayedMonth: defaultMonth),
      );
    });

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'selectDate() updates selectedDate and normalizes to midnight',
      build: () => cubit,
      act: (cubit) => cubit.selectDate(DateTime(2023, 10, 15, 14, 30)),
      expect: () => [
        AdaptiveDatePickerState(
          displayedMonth: defaultMonth,
          selectedDate: DateTime(2023, 10, 15),
        ),
      ],
    );

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'selectDate() clears error message on successful selection',
      build: () => cubit,
      seed: () => AdaptiveDatePickerState(
        displayedMonth: defaultMonth,
        errorMessage: 'Invalid Date',
      ),
      act: (cubit) => cubit.selectDate(DateTime(2023, 10, 15)),
      expect: () => [
        AdaptiveDatePickerState(
          displayedMonth: defaultMonth,
          selectedDate: DateTime(2023, 10, 15),
          errorMessage: null,
        ),
      ],
    );

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'changeMonth() updates displayedMonth to the 1st of the new month',
      build: () => cubit,
      act: (cubit) => cubit.changeMonth(DateTime(2023, 11, 15)),
      expect: () => [
        AdaptiveDatePickerState(displayedMonth: DateTime(2023, 11, 1)),
      ],
    );

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'does nothing if disabled',
      build: () =>
          AdaptiveDatePickerCubit(initialMonth: defaultMonth, isDisabled: true),
      act: (cubit) {
        cubit.selectDate(DateTime(2023, 10, 15));
        cubit.changeMonth(DateTime(2023, 11, 1));
      },
      expect: () => [],
    );

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'setFocus() emits [isFocused: true]',
      build: () => cubit,
      act: (cubit) => cubit.setFocus(true),
      expect: () => [
        AdaptiveDatePickerState(displayedMonth: defaultMonth, isFocused: true),
      ],
    );

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'setError() emits error state',
      build: () => cubit,
      act: (cubit) => cubit.setError('Please pick a future date'),
      expect: () => [
        AdaptiveDatePickerState(
          displayedMonth: defaultMonth,
          errorMessage: 'Please pick a future date',
        ),
      ],
    );

    blocTest<AdaptiveDatePickerCubit, AdaptiveDatePickerState>(
      'reset() returns to default month and clears selection',
      build: () => cubit,
      seed: () => AdaptiveDatePickerState(
        displayedMonth: DateTime(2024, 1, 1),
        selectedDate: DateTime(2024, 1, 15),
        isFocused: true,
      ),
      act: (cubit) => cubit.reset(DateTime(2023, 5, 1)),
      expect: () => [
        AdaptiveDatePickerState(displayedMonth: DateTime(2023, 5, 1)),
      ],
    );
  });
}
