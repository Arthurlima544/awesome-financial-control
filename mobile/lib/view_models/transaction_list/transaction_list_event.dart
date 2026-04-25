part of 'transaction_list_bloc.dart';

abstract class TransactionListEvent extends Equatable {
  const TransactionListEvent();
  @override
  List<Object?> get props => [];
}

class TransactionListFetchRequested extends TransactionListEvent {
  const TransactionListFetchRequested();
}

class TransactionDeleteRequested extends TransactionListEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TransactionUpdateRequested extends TransactionListEvent {
  const TransactionUpdateRequested({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    required this.occurredAt,
    this.isPassive = false,
    this.investmentId,
  });

  final String id;
  final String description;
  final double amount;
  final String type;
  final String? category;
  final DateTime occurredAt;
  final bool isPassive;
  final String? investmentId;

  @override
  List<Object?> get props => [
    id,
    description,
    amount,
    type,
    category,
    occurredAt,
    isPassive,
    investmentId,
  ];
}

class TransactionListToggleGrouping extends TransactionListEvent {
  const TransactionListToggleGrouping();
}
