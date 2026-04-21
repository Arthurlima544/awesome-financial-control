import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The immutable state for the AdaptiveCheckbox.
class AdaptiveCheckboxState extends Equatable {
  final bool isChecked;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveCheckboxState({
    this.isChecked = false,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveCheckboxState copyWith({
    bool? isChecked,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveCheckboxState(
      isChecked: isChecked ?? this.isChecked,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isChecked, isDisabled, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveCheckbox.
class AdaptiveCheckboxCubit extends Cubit<AdaptiveCheckboxState> {
  AdaptiveCheckboxCubit({bool initialChecked = false, bool isDisabled = false})
    : super(
        AdaptiveCheckboxState(
          isChecked: initialChecked,
          isDisabled: isDisabled,
        ),
      );

  /// Toggles the checkbox state if it is not disabled.
  void toggle() {
    if (!state.isDisabled) {
      emit(state.copyWith(isChecked: !state.isChecked, clearError: true));
    }
  }

  /// Sets an explicit value for the checkbox.
  void setValue(bool isChecked) {
    if (!state.isDisabled && state.isChecked != isChecked) {
      emit(state.copyWith(isChecked: isChecked, clearError: true));
    }
  }

  /// Sets the disabled state.
  void setDisabled(bool isDisabled) {
    emit(state.copyWith(isDisabled: isDisabled));
  }

  /// Updates the focus state.
  void setFocus(bool isFocused) {
    emit(state.copyWith(isFocused: isFocused));
  }

  /// Sets a validation error (e.g., if a terms of service checkbox is required).
  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  /// Resets the checkbox to its default state.
  void reset() {
    emit(const AdaptiveCheckboxState());
  }
}
