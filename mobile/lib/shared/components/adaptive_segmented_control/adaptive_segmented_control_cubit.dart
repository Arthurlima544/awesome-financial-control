import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveSegmentedControl.
class AdaptiveSegmentedControlState extends Equatable {
  final int selectedIndex;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveSegmentedControlState({
    this.selectedIndex = 0,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveSegmentedControlState copyWith({
    int? selectedIndex,
    bool? isDisabled,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveSegmentedControlState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    selectedIndex,
    isDisabled,
    isFocused,
    errorMessage,
  ];
}

/// Cubit managing the local UI state of the AdaptiveSegmentedControl.
class AdaptiveSegmentedControlCubit
    extends Cubit<AdaptiveSegmentedControlState> {
  AdaptiveSegmentedControlCubit({int initialIndex = 0, bool isDisabled = false})
    : super(
        AdaptiveSegmentedControlState(
          selectedIndex: initialIndex,
          isDisabled: isDisabled,
        ),
      );

  void setSelectedIndex(int index) {
    if (!state.isDisabled && state.selectedIndex != index) {
      emit(state.copyWith(selectedIndex: index, clearError: true));
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

  void reset({int defaultIndex = 0}) {
    emit(
      AdaptiveSegmentedControlState(
        selectedIndex: defaultIndex,
        isDisabled: state.isDisabled,
      ),
    );
  }
}
