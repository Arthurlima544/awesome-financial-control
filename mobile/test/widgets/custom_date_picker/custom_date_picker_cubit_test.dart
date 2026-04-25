import 'package:afc/widgets/custom_date_picker/custom_date_picker_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomDatePickerCubit', () {
    final now = DateTime(2024, 6, 1);

    blocTest<CustomDatePickerCubit, CustomDatePickerState>(
      'emits correct state when a single date is selected',
      build: () => CustomDatePickerCubit(mode: DatePickerMode.single),
      act: (cubit) => cubit.selectDate(now),
      expect: () => [
        isA<CustomDatePickerState>().having(
          (s) => s.startDate,
          'startDate',
          now,
        ),
      ],
    );

    blocTest<CustomDatePickerCubit, CustomDatePickerState>(
      'handles range selection: start and then end date',
      build: () => CustomDatePickerCubit(mode: DatePickerMode.range),
      act: (cubit) {
        cubit.selectDate(now);
        cubit.selectDate(now.add(const Duration(days: 5)));
      },
      expect: () => [
        isA<CustomDatePickerState>().having(
          (s) => s.startDate,
          'startDate',
          now,
        ),
        isA<CustomDatePickerState>()
            .having((s) => s.startDate, 'startDate', now)
            .having(
              (s) => s.endDate,
              'endDate',
              now.add(const Duration(days: 5)),
            ),
      ],
    );

    blocTest<CustomDatePickerCubit, CustomDatePickerState>(
      'reset emits initial state values',
      build: () => CustomDatePickerCubit(initialStartDate: now),
      act: (cubit) => cubit.reset(),
      expect: () => [
        isA<CustomDatePickerState>().having(
          (s) => s.startDate,
          'startDate',
          null,
        ),
      ],
    );
  });
}
