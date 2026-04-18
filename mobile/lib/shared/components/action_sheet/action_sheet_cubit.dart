import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionSheetOption extends Equatable {
  final String id;
  final String label;

  const ActionSheetOption({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}

class ActionSheetState extends Equatable {
  final List<ActionSheetOption> options;
  final String? selectedOptionId;
  final String? errorMessage;

  const ActionSheetState({
    required this.options,
    this.selectedOptionId,
    this.errorMessage,
  });

  ActionSheetState copyWith({
    List<ActionSheetOption>? options,
    String? selectedOptionId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActionSheetState(
      options: options ?? this.options,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [options, selectedOptionId, errorMessage];
}

class ActionSheetCubit extends Cubit<ActionSheetState> {
  ActionSheetCubit({required List<ActionSheetOption> options})
    : super(ActionSheetState(options: options));

  void selectOption(String id) {
    emit(state.copyWith(selectedOptionId: id, clearError: true));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset() {
    emit(ActionSheetState(options: state.options));
  }
}
