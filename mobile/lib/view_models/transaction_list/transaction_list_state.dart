part of 'transaction_list_bloc.dart';

abstract class TransactionListState extends Equatable {
  const TransactionListState();
  @override
  List<Object?> get props => [];
}

class TransactionListInitial extends TransactionListState {}

class TransactionListLoading extends TransactionListState {}

class TransactionListData extends TransactionListState {
  const TransactionListData(this.transactions);

  final List<TransactionModel> transactions;

  @override
  List<Object?> get props => [transactions];
}

class TransactionListError extends TransactionListState {
  const TransactionListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
