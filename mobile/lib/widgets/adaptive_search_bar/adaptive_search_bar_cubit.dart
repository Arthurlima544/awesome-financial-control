import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveSearchBar.
class AdaptiveSearchBarState extends Equatable {
  final String query;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveSearchBarState({
    this.query = '',
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveSearchBarState copyWith({
    String? query,
    bool? isFocused,
    Object? errorMessage = const Object(),
  }) {
    return AdaptiveSearchBarState(
      query: query ?? this.query,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: identical(errorMessage, const Object())
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [query, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveSearchBar.
class AdaptiveSearchBarCubit extends Cubit<AdaptiveSearchBarState> {
  AdaptiveSearchBarCubit() : super(const AdaptiveSearchBarState());

  /// Updates the current query text state.
  void updateQuery(String query) {
    emit(state.copyWith(query: query, errorMessage: null));
  }

  /// Updates the focus state.
  void setFocus(bool isFocused) {
    emit(state.copyWith(isFocused: isFocused));
  }

  /// Sets a validation error message.
  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  /// Clears the search query and resets the error state.
  void clear() {
    emit(state.copyWith(query: '', errorMessage: null));
  }
}
