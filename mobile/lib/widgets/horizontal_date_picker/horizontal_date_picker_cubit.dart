import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HorizontalDatePickerState extends Equatable {
  final DateTime? selectedDate;
  final String? errorMessage;

  const HorizontalDatePickerState({this.selectedDate, this.errorMessage});

  HorizontalDatePickerState copyWith({
    DateTime? selectedDate,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HorizontalDatePickerState(
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [selectedDate, errorMessage];
}

class HorizontalDatePickerCubit extends Cubit<HorizontalDatePickerState> {
  HorizontalDatePickerCubit({DateTime? initialDate})
    : super(HorizontalDatePickerState(selectedDate: initialDate));

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date, clearError: true));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset(DateTime? resetDate) {
    emit(HorizontalDatePickerState(selectedDate: resetDate));
  }
}
