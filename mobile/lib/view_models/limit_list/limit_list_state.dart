part of 'limit_list_bloc.dart';

abstract class LimitListState extends Equatable {
  const LimitListState();
  @override
  List<Object?> get props => [];
}

class LimitListInitial extends LimitListState {}

class LimitListLoading extends LimitListState {}

class LimitListData extends LimitListState {
  const LimitListData(this.limits);

  final List<LimitModel> limits;

  @override
  List<Object?> get props => [limits];
}

class LimitListError extends LimitListState {
  const LimitListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
