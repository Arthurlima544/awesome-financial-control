import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBubbleState extends Equatable {
  final bool isSelected;
  final String? errorMessage;

  const MessageBubbleState({required this.isSelected, this.errorMessage});

  MessageBubbleState copyWith({
    bool? isSelected,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessageBubbleState(
      isSelected: isSelected ?? this.isSelected,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isSelected, errorMessage];
}

class MessageBubbleCubit extends Cubit<MessageBubbleState> {
  MessageBubbleCubit({bool initialSelected = false})
    : super(MessageBubbleState(isSelected: initialSelected));

  void toggleSelection() {
    emit(state.copyWith(isSelected: !state.isSelected, clearError: true));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void reset() {
    emit(const MessageBubbleState(isSelected: false));
  }
}
