import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomStepperState extends Equatable {
  final int currentStep;
  final String? errorMessage;

  const CustomStepperState({required this.currentStep, this.errorMessage});

  CustomStepperState copyWith({
    int? currentStep,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomStepperState(
      currentStep: currentStep ?? this.currentStep,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [currentStep, errorMessage];
}

class CustomStepperCubit extends Cubit<CustomStepperState> {
  final int totalSteps;

  CustomStepperCubit({required int initialStep, required this.totalSteps})
    : super(CustomStepperState(currentStep: initialStep));

  void setStep(int step) {
    if (step < 0 || step >= totalSteps) {
      emit(state.copyWith(errorMessage: 'Invalid step selection.'));
    } else {
      emit(state.copyWith(currentStep: step, clearError: true));
    }
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset(int initialStep) {
    emit(CustomStepperState(currentStep: initialStep));
  }
}
