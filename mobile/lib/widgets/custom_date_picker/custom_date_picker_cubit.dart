import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DatePickerMode { single, range }

class CustomDatePickerState extends Equatable {
  final DateTime viewingMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final DatePickerMode mode;
  final bool isConfirmed;

  const CustomDatePickerState({
    required this.viewingMonth,
    this.startDate,
    this.endDate,
    this.mode = DatePickerMode.single,
    this.isConfirmed = false,
  });

  CustomDatePickerState copyWith({
    DateTime? viewingMonth,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
    DatePickerMode? mode,
    bool? isConfirmed,
  }) {
    return CustomDatePickerState(
      viewingMonth: viewingMonth ?? this.viewingMonth,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      mode: mode ?? this.mode,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  List<Object?> get props => [
    viewingMonth,
    startDate,
    endDate,
    mode,
    isConfirmed,
  ];
}

class CustomDatePickerCubit extends Cubit<CustomDatePickerState> {
  CustomDatePickerCubit({
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DatePickerMode mode = DatePickerMode.range,
  }) : super(
         CustomDatePickerState(
           viewingMonth: DateTime(
             (initialStartDate ?? DateTime.now()).year,
             (initialStartDate ?? DateTime.now()).month,
           ),
           startDate: initialStartDate,
           endDate: initialEndDate,
           mode: mode,
         ),
       );

  void selectDate(DateTime date) {
    if (state.mode == DatePickerMode.single) {
      emit(state.copyWith(startDate: date, endDate: null, isConfirmed: false));
    } else {
      if (state.startDate == null ||
          (state.startDate != null && state.endDate != null)) {
        emit(
          state.copyWith(
            startDate: date,
            clearEndDate: true,
            isConfirmed: false,
          ),
        );
      } else if (date.isBefore(state.startDate!)) {
        emit(
          state.copyWith(
            startDate: date,
            clearEndDate: true,
            isConfirmed: false,
          ),
        );
      } else {
        emit(state.copyWith(endDate: date, isConfirmed: false));
      }
    }
  }

  void changeMonth(int year, int month) {
    emit(state.copyWith(viewingMonth: DateTime(year, month)));
  }

  void reset() {
    emit(
      state.copyWith(
        clearStartDate: true,
        clearEndDate: true,
        viewingMonth: DateTime(DateTime.now().year, DateTime.now().month),
      ),
    );
  }

  void confirm() {
    emit(state.copyWith(isConfirmed: true));
  }
}
