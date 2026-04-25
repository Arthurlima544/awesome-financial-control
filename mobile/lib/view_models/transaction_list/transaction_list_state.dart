part of 'transaction_list_bloc.dart';

abstract class TransactionListState extends Equatable {
  const TransactionListState();
  @override
  List<Object?> get props => [];
}

class TransactionListInitial extends TransactionListState {}

class TransactionListLoading extends TransactionListState {}

class TransactionListData extends TransactionListState {
  const TransactionListData(this.transactions, {this.groupByType = false});

  final List<TransactionModel> transactions;
  final bool groupByType;

  @override
  List<Object?> get props => [transactions, groupByType];

  TransactionListData copyWith({
    List<TransactionModel>? transactions,
    bool? groupByType,
  }) {
    return TransactionListData(
      transactions ?? this.transactions,
      groupByType: groupByType ?? this.groupByType,
    );
  }
}

class TransactionListError extends TransactionListState {
  const TransactionListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
