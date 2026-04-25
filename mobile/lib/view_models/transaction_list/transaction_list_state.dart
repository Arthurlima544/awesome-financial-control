part of 'transaction_list_bloc.dart';

abstract class TransactionListState extends Equatable {
  const TransactionListState();
  @override
  List<Object?> get props => [];
}

class TransactionListInitial extends TransactionListState {}

class TransactionListLoading extends TransactionListState {}

class TransactionListData extends TransactionListState {
  const TransactionListData({
    required this.transactions,
    required this.filteredTransactions,
    this.groupByType = false,
    this.searchQuery = '',
    this.dateRange,
    this.selectedType,
  });

  final List<TransactionModel> transactions; // Original list
  final List<TransactionModel> filteredTransactions; // Computed list
  final bool groupByType;
  final String searchQuery;
  final DateTimeRange? dateRange;
  final TransactionType? selectedType;

  bool get hasFilters =>
      searchQuery.isNotEmpty || dateRange != null || selectedType != null;

  @override
  List<Object?> get props => [
    transactions,
    filteredTransactions,
    groupByType,
    searchQuery,
    dateRange,
    selectedType,
  ];

  TransactionListData copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    bool? groupByType,
    String? searchQuery,
    DateTimeRange? Function()? dateRange,
    TransactionType? Function()? selectedType,
  }) {
    return TransactionListData(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      groupByType: groupByType ?? this.groupByType,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange != null ? dateRange() : this.dateRange,
      selectedType: selectedType != null ? selectedType() : this.selectedType,
    );
  }
}

class TransactionListError extends TransactionListState {
  const TransactionListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
