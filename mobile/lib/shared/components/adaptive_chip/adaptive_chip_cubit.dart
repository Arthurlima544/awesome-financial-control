import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveChip.
class AdaptiveChipState extends Equatable {
  final bool isSelected;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveChipState({
    this.isSelected = false,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveChipState copyWith({
    bool? isSelected,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveChipState(
      isSelected: isSelected ?? this.isSelected,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isSelected, isDisabled, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveChip.
class AdaptiveChipCubit extends Cubit<AdaptiveChipState> {
  AdaptiveChipCubit({bool initialSelected = false, bool isDisabled = false})
    : super(
        AdaptiveChipState(isSelected: initialSelected, isDisabled: isDisabled),
      );

  void toggleSelection() {
    if (!state.isDisabled) {
      emit(state.copyWith(isSelected: !state.isSelected, clearError: true));
    }
  }

  void setSelected(bool isSelected) {
    if (!state.isDisabled && state.isSelected != isSelected) {
      emit(state.copyWith(isSelected: isSelected, clearError: true));
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
    emit(const AdaptiveChipState());
  }
}
