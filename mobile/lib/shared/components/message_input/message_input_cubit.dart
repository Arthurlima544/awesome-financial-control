import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageInputState extends Equatable {
  final String text;
  final bool isFocused;
  final String? errorMessage;

  const MessageInputState({
    this.text = '',
    this.isFocused = false,
    this.errorMessage,
  });

  MessageInputState copyWith({
    String? text,
    bool? isFocused,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessageInputState(
      text: text ?? this.text,
      isFocused: isFocused ?? this.isFocused,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [text, isFocused, errorMessage];
}

class MessageInputCubit extends Cubit<MessageInputState> {
  MessageInputCubit({String initialText = ''})
    : super(MessageInputState(text: initialText));

  void textChanged(String text) {
    emit(state.copyWith(text: text, clearError: true));
  }

  void focusChanged(bool isFocused) {
    emit(state.copyWith(isFocused: isFocused));
  }

  void setError(String error) {
    emit(state.copyWith(errorMessage: error));
  }

  void clear() {
    emit(const MessageInputState());
  }
}
