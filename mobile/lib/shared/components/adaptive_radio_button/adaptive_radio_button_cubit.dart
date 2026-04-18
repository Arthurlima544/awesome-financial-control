import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveRadioButton.
class AdaptiveRadioButtonState extends Equatable {
  final bool isSelected;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveRadioButtonState({
    this.isSelected = false,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveRadioButtonState copyWith({
    bool? isSelected,
    bool? isDisabled,
    bool? isFocused,
    Object? errorMessage = const Object(),
  }) {
    return AdaptiveRadioButtonState(
      isSelected: isSelected ?? this.isSelected,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: identical(errorMessage, const Object())
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isSelected, isDisabled, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveRadioButton.
class AdaptiveRadioButtonCubit extends Cubit<AdaptiveRadioButtonState> {
  AdaptiveRadioButtonCubit({
    bool initialSelected = false,
    bool isDisabled = false,
  }) : super(
         AdaptiveRadioButtonState(
           isSelected: initialSelected,
           isDisabled: isDisabled,
         ),
       );

  /// Selects the radio button. Radio buttons typically don't unselect themselves on tap.
  void select() {
    if (!state.isDisabled && !state.isSelected) {
      emit(state.copyWith(isSelected: true, errorMessage: null));
    }
  }

  /// Externally updates the selection state (useful for radio groups).
  void setSelection(bool isSelected) {
    emit(state.copyWith(isSelected: isSelected, errorMessage: null));
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
    emit(const AdaptiveRadioButtonState());
  }
}
