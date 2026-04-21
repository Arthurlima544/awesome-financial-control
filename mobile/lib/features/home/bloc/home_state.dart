part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  const HomeLoaded({required this.summary, required this.transactions});

  final SummaryModel summary;
  final List<TransactionModel> transactions;

  String get totalIncomeFormatted =>
      CurrencyFormatter.format(summary.totalIncome);
  String get totalExpensesFormatted =>
      CurrencyFormatter.format(summary.totalExpenses);
  String get balanceFormatted => CurrencyFormatter.format(summary.balance);

  bool get isBalancePositive => summary.balance >= 0;

  @override
  List<Object?> get props => [summary, transactions];
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
