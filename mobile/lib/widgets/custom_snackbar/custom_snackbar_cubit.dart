import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomSnackbarState extends Equatable {
  final bool isVisible;
  final bool isActionLoading;
  final String? errorMessage;

  const CustomSnackbarState({
    this.isVisible = true,
    this.isActionLoading = false,
    this.errorMessage,
  });

  CustomSnackbarState copyWith({
    bool? isVisible,
    bool? isActionLoading,
    String? errorMessage,
  }) {
    return CustomSnackbarState(
      isVisible: isVisible ?? this.isVisible,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isVisible, isActionLoading, errorMessage];
}

class CustomSnackbarCubit extends Cubit<CustomSnackbarState> {
  CustomSnackbarCubit() : super(const CustomSnackbarState());

  void dismiss() {
    emit(state.copyWith(isVisible: false));
  }

  void setActionLoading(bool isLoading) {
    emit(state.copyWith(isActionLoading: isLoading));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error, isActionLoading: false));
  }

  void reset() {
    emit(const CustomSnackbarState());
  }
}
