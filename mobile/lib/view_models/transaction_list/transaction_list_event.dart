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
  final TransactionType type;
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

class TransactionListSearchChanged extends TransactionListEvent {
  const TransactionListSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class TransactionListDateRangeChanged extends TransactionListEvent {
  const TransactionListDateRangeChanged(this.range);
  final DateTimeRange? range;

  @override
  List<Object?> get props => [range];
}

class TransactionListTypeFilterChanged extends TransactionListEvent {
  const TransactionListTypeFilterChanged(this.type);
  final TransactionType? type;

  @override
  List<Object?> get props => [type];
}

class TransactionListClearFilters extends TransactionListEvent {
  const TransactionListClearFilters();
}
