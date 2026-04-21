import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveStepper.
class AdaptiveStepperState extends Equatable {
  final int value;
  final int min;
  final int max;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveStepperState({
    this.value = 0,
    this.min = 0,
    this.max = 100,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveStepperState copyWith({
    int? value,
    int? min,
    int? max,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveStepperState(
      value: value ?? this.value,
      min: min ?? this.min,
      max: max ?? this.max,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    value,
    min,
    max,
    isDisabled,
    isFocused,
    errorMessage,
  ];
}

/// Cubit managing the local UI state of the AdaptiveStepper.
class AdaptiveStepperCubit extends Cubit<AdaptiveStepperState> {
  AdaptiveStepperCubit({
    int initialValue = 0,
    int min = 0,
    int max = 100,
    bool isDisabled = false,
  }) : super(
         AdaptiveStepperState(
           value: initialValue,
           min: min,
           max: max,
           isDisabled: isDisabled,
         ),
       );

  void increment() {
    if (!state.isDisabled && state.value < state.max) {
      emit(state.copyWith(value: state.value + 1, clearError: true));
    }
  }

  void decrement() {
    if (!state.isDisabled && state.value > state.min) {
      emit(state.copyWith(value: state.value - 1, clearError: true));
    }
  }

  void setValue(int newValue) {
    if (!state.isDisabled && newValue >= state.min && newValue <= state.max) {
      emit(state.copyWith(value: newValue, clearError: true));
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

  void reset() {
    emit(AdaptiveStepperState(min: state.min, max: state.max));
  }
}
