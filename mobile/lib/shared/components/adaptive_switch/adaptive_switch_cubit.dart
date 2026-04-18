import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The immutable state for the AdaptiveSwitch.
class AdaptiveSwitchState extends Equatable {
  final bool isOn;
  final bool isDisabled;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveSwitchState({
    this.isOn = false,
    this.isDisabled = false,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveSwitchState copyWith({
    bool? isOn,
    bool? isDisabled,
    bool? isFocused,
    Object? errorMessage = const Object(),
  }) {
    return AdaptiveSwitchState(
      isOn: isOn ?? this.isOn,
      isDisabled: isDisabled ?? this.isDisabled,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: identical(errorMessage, const Object())
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isOn, isDisabled, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveSwitch.
class AdaptiveSwitchCubit extends Cubit<AdaptiveSwitchState> {
  AdaptiveSwitchCubit({bool initialValue = false, bool isDisabled = false})
    : super(AdaptiveSwitchState(isOn: initialValue, isDisabled: isDisabled));

  void toggle() {
    if (!state.isDisabled) {
      emit(state.copyWith(isOn: !state.isOn, errorMessage: null));
    }
  }

  void setValue(bool value) {
    if (!state.isDisabled && state.isOn != value) {
      emit(state.copyWith(isOn: value, errorMessage: null));
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
    emit(const AdaptiveSwitchState());
  }
}
