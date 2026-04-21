import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomProgressBarState extends Equatable {
  final double progress;
  final String? errorMessage;

  const CustomProgressBarState({required this.progress, this.errorMessage});

  CustomProgressBarState copyWith({
    double? progress,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomProgressBarState(
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [progress, errorMessage];
}

class CustomProgressBarCubit extends Cubit<CustomProgressBarState> {
  CustomProgressBarCubit({double initialProgress = 0.0})
    : super(CustomProgressBarState(progress: initialProgress.clamp(0.0, 1.0)));

  void setProgress(double value) {
    if (value < 0.0 || value > 1.0) {
      emit(
        state.copyWith(errorMessage: 'Progress must be between 0.0 and 1.0'),
      );
    } else {
      emit(state.copyWith(progress: value, clearError: true));
    }
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset({double initialProgress = 0.0}) {
    emit(CustomProgressBarState(progress: initialProgress.clamp(0.0, 1.0)));
  }
}
