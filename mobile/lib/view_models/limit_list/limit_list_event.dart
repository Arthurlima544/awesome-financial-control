part of 'limit_list_bloc.dart';

abstract class LimitListEvent extends Equatable {
  const LimitListEvent();
  @override
  List<Object?> get props => [];
}

class LimitListFetchRequested extends LimitListEvent {
  const LimitListFetchRequested();
}

class LimitListDeleteRequested extends LimitListEvent {
  const LimitListDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class LimitListUpdateRequested extends LimitListEvent {
  const LimitListUpdateRequested({required this.id, required this.amount});

  final String id;
  final double amount;

  @override
  List<Object?> get props => [id, amount];
}

class LimitListCreateRequested extends LimitListEvent {
  const LimitListCreateRequested({
    required this.categoryId,
    required this.amount,
  });

  final String categoryId;
  final double amount;

  @override
  List<Object?> get props => [categoryId, amount];
}
