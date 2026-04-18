import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Immutable state for the AdaptiveBadge.
class AdaptiveBadgeState extends Equatable {
  final String? label;
  final int? count;
  final bool isVisible;
  final bool isFocused;
  final String? errorMessage;

  const AdaptiveBadgeState({
    this.label,
    this.count,
    this.isVisible = true,
    this.isFocused = false,
    this.errorMessage,
  });

  AdaptiveBadgeState copyWith({
    String? label,
    int? count,
    bool? isVisible,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdaptiveBadgeState(
      label: label ?? this.label,
      count: count ?? this.count,
      isVisible: isVisible ?? this.isVisible,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [label, count, isVisible, isFocused, errorMessage];
}

/// Cubit managing the local UI state of the AdaptiveBadge.
class AdaptiveBadgeCubit extends Cubit<AdaptiveBadgeState> {
  AdaptiveBadgeCubit({
    String? initialLabel,
    int? initialCount,
    bool isVisible = true,
  }) : super(
         AdaptiveBadgeState(
           label: initialLabel,
           count: initialCount,
           isVisible: isVisible,
         ),
       );

  void updateLabel(String newLabel) {
    emit(state.copyWith(label: newLabel, clearError: true));
  }

  void updateCount(int newCount) {
    emit(state.copyWith(count: newCount, clearError: true));
  }

  void setVisibility(bool isVisible) {
    emit(state.copyWith(isVisible: isVisible));
  }

  void setFocus(bool isFocused) {
    emit(state.copyWith(isFocused: isFocused));
  }

  void setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  void reset({String? defaultLabel, int? defaultCount}) {
    emit(AdaptiveBadgeState(label: defaultLabel, count: defaultCount));
  }
}
