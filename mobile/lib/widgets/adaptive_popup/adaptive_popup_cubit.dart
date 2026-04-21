import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptivePopup.
class AdaptivePopupState extends Equatable {
  final String inputValue;
  final bool isLoading;
  final String? errorMessage;

  const AdaptivePopupState({
    this.inputValue = '',
    this.isLoading = false,
    this.errorMessage,
  });

  AdaptivePopupState copyWith({
    String? inputValue,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptivePopupState(
      inputValue: inputValue ?? this.inputValue,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [inputValue, isLoading, errorMessage];
}

/// Cubit managing the local UI state of the AdaptivePopup.
class AdaptivePopupCubit extends Cubit<AdaptivePopupState> {
  AdaptivePopupCubit() : super(const AdaptivePopupState());

  void onInputChanged(String value) {
    emit(state.copyWith(inputValue: value, clearError: true));
  }

  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  /// Validates the input and returns true if valid.
  /// Emits an error state if validation fails.
  bool validateInput({required String errorMessage}) {
    if (state.inputValue.trim().isEmpty) {
      emit(state.copyWith(errorMessage: errorMessage));
      return false;
    }
    return true;
  }

  void reset() {
    emit(const AdaptivePopupState());
  }
}
