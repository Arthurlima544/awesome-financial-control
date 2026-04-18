import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The immutable state for the AdaptiveNavBar.
class AdaptiveNavBarState extends Equatable {
  final bool isLoading;
  final bool isActionDisabled;
  final String? errorMessage;

  const AdaptiveNavBarState({
    this.isLoading = false,
    this.isActionDisabled = false,
    this.errorMessage,
  });

  AdaptiveNavBarState copyWith({
    bool? isLoading,
    bool? isActionDisabled,
    String? errorMessage,
  }) {
    return AdaptiveNavBarState(
      isLoading: isLoading ?? this.isLoading,
      isActionDisabled: isActionDisabled ?? this.isActionDisabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isActionDisabled, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveNavBar.
class AdaptiveNavBarCubit extends Cubit<AdaptiveNavBarState> {
  AdaptiveNavBarCubit() : super(const AdaptiveNavBarState());

  /// Sets the loading state of the navigation bar's action.
  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  /// Sets whether the action button is disabled.
  void setActionDisabled(bool isDisabled) {
    emit(state.copyWith(isActionDisabled: isDisabled));
  }

  /// Sets an error state to be displayed on the UI.
  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }
  
  /// Resets the state to initial values.
  void reset() {
    emit(const AdaptiveNavBarState());
  }
}