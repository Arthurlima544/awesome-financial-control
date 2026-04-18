import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The immutable state for the AdaptiveButton.
class AdaptiveButtonState extends Equatable {
  final bool isLoading;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveButtonState({
    this.isLoading = false,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveButtonState copyWith({
    bool? isLoading,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
  }) {
    return AdaptiveButtonState(
      isLoading: isLoading ?? this.isLoading,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isDisabled, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveButton.
class AdaptiveButtonCubit extends Cubit<AdaptiveButtonState> {
  AdaptiveButtonCubit() : super(const AdaptiveButtonState());

  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
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
    emit(const AdaptiveButtonState());
  }
}
