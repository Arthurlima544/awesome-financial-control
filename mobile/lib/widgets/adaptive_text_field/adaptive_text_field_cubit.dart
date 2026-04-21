import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveTextField.
class AdaptiveTextFieldState extends Equatable {
  final String text;
  final bool isFocused;
  final bool isDisabled;
  final String? errorMessage;

  const AdaptiveTextFieldState({
    this.text = '',
    this.isFocused = false,
    this.isDisabled = false,
    this.errorMessage,
  });

  AdaptiveTextFieldState copyWith({
    String? text,
    bool? isFocused,
    bool? isDisabled,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveTextFieldState(
      text: text ?? this.text,
      isFocused: isFocused ?? this.isFocused,
      isDisabled: isDisabled ?? this.isDisabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [text, isFocused, isDisabled, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveTextField.
class AdaptiveTextFieldCubit extends Cubit<AdaptiveTextFieldState> {
  AdaptiveTextFieldCubit({bool isDisabled = false})
    : super(AdaptiveTextFieldState(isDisabled: isDisabled));

  void textChanged(String value) {
    emit(state.copyWith(text: value, clearError: true));
  }

  void focusChanged(bool isFocused) {
    emit(state.copyWith(isFocused: isFocused));
  }

  void setDisabled(bool isDisabled) {
    emit(state.copyWith(isDisabled: isDisabled));
  }

  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  /// Runs a validation function and updates the error state accordingly.
  void validate(String? Function(String) validator) {
    final error = validator(state.text);
    emit(state.copyWith(errorMessage: error, clearError: error == null));
  }

  void reset() {
    emit(AdaptiveTextFieldState(isDisabled: state.isDisabled));
  }
}
