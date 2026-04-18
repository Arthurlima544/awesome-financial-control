import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The immutable state for the AdaptiveDatePicker.
class AdaptiveDatePickerState extends Equatable {
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveDatePickerState({
    required this.displayedMonth,
    this.selectedDate,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveDatePickerState copyWith({
    DateTime? displayedMonth,
    DateTime? selectedDate,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveDatePickerState(
      displayedMonth: displayedMonth ?? this.displayedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    displayedMonth,
    selectedDate,
    isDisabled,
    isFocused,
    errorMessage,
  ];
}

/// Cubit managing the local UI state of the AdaptiveDatePicker.
class AdaptiveDatePickerCubit extends Cubit<AdaptiveDatePickerState> {
  AdaptiveDatePickerCubit({
    required DateTime initialMonth,
    DateTime? initialSelectedDate,
    bool isDisabled = false,
  }) : super(
         AdaptiveDatePickerState(
           displayedMonth: DateTime(initialMonth.year, initialMonth.month, 1),
           selectedDate: initialSelectedDate != null
               ? DateTime(
                   initialSelectedDate.year,
                   initialSelectedDate.month,
                   initialSelectedDate.day,
                 )
               : null,
           isDisabled: isDisabled,
         ),
       );

  void selectDate(DateTime date) {
    if (!state.isDisabled) {
      // Normalize to midnight to avoid time-based comparison issues
      final normalizedDate = DateTime(date.year, date.month, date.day);
      emit(state.copyWith(selectedDate: normalizedDate, clearError: true));
    }
  }

  void changeMonth(DateTime newMonth) {
    if (!state.isDisabled) {
      final normalizedMonth = DateTime(newMonth.year, newMonth.month, 1);
      emit(state.copyWith(displayedMonth: normalizedMonth));
    }
  }

  void setDisabled(bool isDisabled) {
    emit(state.copyWith(isDisabled: isDisabled));
  }

  void setFocus(bool isFocused) {
    emit(state.copyWith(isFocused: isFocused));
  }

  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  void reset(DateTime defaultMonth) {
    emit(
      AdaptiveDatePickerState(
        displayedMonth: DateTime(defaultMonth.year, defaultMonth.month, 1),
        isDisabled: state.isDisabled,
      ),
    );
  }
}
