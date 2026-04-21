part of 'limit_bloc.dart';

abstract class LimitState extends Equatable {
  const LimitState();
  @override
  List<Object?> get props => [];
}

class LimitInitial extends LimitState {}

class LimitLoading extends LimitState {}

class LimitLoaded extends LimitState {
  const LimitLoaded(this.limits);

  final List<LimitProgressModel> limits;

  @override
  List<Object?> get props => [limits];
}

class LimitError extends LimitState {
  const LimitError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
