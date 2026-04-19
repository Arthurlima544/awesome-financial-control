import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorViewState extends Equatable {
  const ErrorViewState({this.isRetrying = false});

  final bool isRetrying;

  ErrorViewState copyWith({bool? isRetrying}) {
    return ErrorViewState(isRetrying: isRetrying ?? this.isRetrying);
  }

  @override
  List<Object?> get props => [isRetrying];
}

class ErrorViewCubit extends Cubit<ErrorViewState> {
  ErrorViewCubit() : super(const ErrorViewState());

  void setRetrying(bool retrying) => emit(state.copyWith(isRetrying: retrying));
}
