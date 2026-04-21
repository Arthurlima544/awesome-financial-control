import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveSlider.
class AdaptiveSliderState extends Equatable {
  final double startValue;
  final double endValue;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveSliderState({
    this.startValue = 0.0,
    this.endValue = 0.0,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveSliderState copyWith({
    double? startValue,
    double? endValue,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveSliderState(
      startValue: startValue ?? this.startValue,
      endValue: endValue ?? this.endValue,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    startValue,
    endValue,
    isDisabled,
    isFocused,
    errorMessage,
  ];
}

/// Cubit managing the local UI state of the AdaptiveSlider.
class AdaptiveSliderCubit extends Cubit<AdaptiveSliderState> {
  AdaptiveSliderCubit({
    double initialStart = 0.0,
    double initialEnd = 0.0,
    bool isDisabled = false,
  }) : super(
         AdaptiveSliderState(
           startValue: initialStart,
           endValue: initialEnd,
           isDisabled: isDisabled,
         ),
       );

  void updateSingleValue(double value) {
    if (!state.isDisabled) {
      emit(state.copyWith(endValue: value, clearError: true));
    }
  }

  void updateRangeValues(double start, double end) {
    if (!state.isDisabled && start <= end) {
      emit(state.copyWith(startValue: start, endValue: end, clearError: true));
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

  void reset(double defaultStart, double defaultEnd) {
    emit(
      AdaptiveSliderState(
        startValue: defaultStart,
        endValue: defaultEnd,
        isDisabled: state.isDisabled,
      ),
    );
  }
}
