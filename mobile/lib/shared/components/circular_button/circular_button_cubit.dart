import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The immutable state for the CircularButton.
class CircularButtonState extends Equatable {
  final bool isLoading;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const CircularButtonState({
    this.isLoading = false,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  CircularButtonState copyWith({
    bool? isLoading,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
  }) {
    return CircularButtonState(
      isLoading: isLoading ?? this.isLoading,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isDisabled, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the CircularButton.
class CircularButtonCubit extends Cubit<CircularButtonState> {
  CircularButtonCubit() : super(const CircularButtonState());

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
    emit(const CircularButtonState());
  }
}
