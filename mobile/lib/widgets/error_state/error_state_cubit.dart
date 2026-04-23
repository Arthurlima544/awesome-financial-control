import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ErrorStateViewState extends Equatable {
  final bool isRetrying;

  const ErrorStateViewState({this.isRetrying = false});

  ErrorStateViewState copyWith({bool? isRetrying}) {
    return ErrorStateViewState(isRetrying: isRetrying ?? this.isRetrying);
  }

  @override
  List<Object?> get props => [isRetrying];
}

class ErrorStateCubit extends Cubit<ErrorStateViewState> {
  ErrorStateCubit() : super(const ErrorStateViewState());

  void setRetrying(bool value) => emit(state.copyWith(isRetrying: value));
}
