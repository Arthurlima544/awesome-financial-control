import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionCardState extends Equatable {
  final bool isActionLoading;
  final String? errorMessage;

  const ActionCardState({this.isActionLoading = false, this.errorMessage});

  ActionCardState copyWith({
    bool? isActionLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActionCardState(
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isActionLoading, errorMessage];
}

class ActionCardCubit extends Cubit<ActionCardState> {
  ActionCardCubit() : super(const ActionCardState());

  void setActionLoading(bool isLoading) {
    emit(state.copyWith(isActionLoading: isLoading, clearError: true));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error, isActionLoading: false));
  }

  void reset() {
    emit(const ActionCardState());
  }
}
