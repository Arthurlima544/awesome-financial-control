import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'dart:async';

part 'transaction_list_event.dart';
part 'transaction_list_state.dart';

class TransactionListBloc
    extends Bloc<TransactionListEvent, TransactionListState> {
  final TransactionListRepository _repository;
  final AppRefreshBloc _refreshBloc;
  late final StreamSubscription _refreshSubscription;

  TransactionListBloc({
    TransactionListRepository? repository,
    AppRefreshBloc? refreshBloc,
  }) : _repository = repository ?? sl<TransactionListRepository>(),
       _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
       super(TransactionListInitial()) {
    on<TransactionListFetchRequested>(_onFetchRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
    on<TransactionUpdateRequested>(_onUpdateRequested);
    on<TransactionListToggleGrouping>(_onToggleGrouping);
    on<TransactionListSearchChanged>(_onSearchChanged);
    on<TransactionListDateRangeChanged>(_onDateRangeChanged);
    on<TransactionListTypeFilterChanged>(_onTypeFilterChanged);
    on<TransactionListClearFilters>(_onClearFilters);

    _refreshSubscription = _refreshBloc.stream.listen(
      (_) => add(const TransactionListFetchRequested()),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

  Future<void> _onFetchRequested(
    TransactionListFetchRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(TransactionListLoading());
    try {
      final transactions = await _repository.getAll();
      emit(
        TransactionListData(
          transactions: transactions,
          filteredTransactions: _applyFilters(transactions, '', null, null),
        ),
      );
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    TransactionDeleteRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    final current = state;
    if (current is! TransactionListData) return;
    try {
      await _repository.delete(event.id);
      final updated = current.transactions
          .where((t) => t.id != event.id)
          .toList();
      emit(
        current.copyWith(
          transactions: updated,
          filteredTransactions: _applyFilters(
            updated,
            current.searchQuery,
            current.dateRange,
            current.selectedType,
          ),
        ),
      );
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    TransactionUpdateRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    final current = state;
    if (current is! TransactionListData) return;
    try {
      final updated = await _repository.update(
        event.id,
        description: event.description,
        amount: event.amount,
        type: event.type.name.toUpperCase(),
        category: event.category,
        occurredAt: event.occurredAt,
        isPassive: event.isPassive,
        investmentId: event.investmentId,
      );
      final updatedList = current.transactions.map((t) {
        return t.id == event.id ? updated : t;
      }).toList();
      emit(
        current.copyWith(
          transactions: updatedList,
          filteredTransactions: _applyFilters(
            updatedList,
            current.searchQuery,
            current.dateRange,
            current.selectedType,
          ),
        ),
      );
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }

  Future<void> _onToggleGrouping(
    TransactionListToggleGrouping event,
    Emitter<TransactionListState> emit,
  ) async {
    final current = state;
    if (current is TransactionListData) {
      emit(current.copyWith(groupByType: !current.groupByType));
    }
  }

  void _onSearchChanged(
    TransactionListSearchChanged event,
    Emitter<TransactionListState> emit,
  ) {
    final current = state;
    if (current is! TransactionListData) return;
    emit(
      current.copyWith(
        searchQuery: event.query,
        filteredTransactions: _applyFilters(
          current.transactions,
          event.query,
          current.dateRange,
          current.selectedType,
        ),
      ),
    );
  }

  void _onDateRangeChanged(
    TransactionListDateRangeChanged event,
    Emitter<TransactionListState> emit,
  ) {
    final current = state;
    if (current is! TransactionListData) return;
    emit(
      current.copyWith(
        dateRange: () => event.range,
        filteredTransactions: _applyFilters(
          current.transactions,
          current.searchQuery,
          event.range,
          current.selectedType,
        ),
      ),
    );
  }

  void _onTypeFilterChanged(
    TransactionListTypeFilterChanged event,
    Emitter<TransactionListState> emit,
  ) {
    final current = state;
    if (current is! TransactionListData) return;
    emit(
      current.copyWith(
        selectedType: () => event.type,
        filteredTransactions: _applyFilters(
          current.transactions,
          current.searchQuery,
          current.dateRange,
          event.type,
        ),
      ),
    );
  }

  void _onClearFilters(
    TransactionListClearFilters event,
    Emitter<TransactionListState> emit,
  ) {
    final current = state;
    if (current is! TransactionListData) return;
    emit(
      current.copyWith(
        searchQuery: '',
        dateRange: () => null,
        selectedType: () => null,
        filteredTransactions: current.transactions,
      ),
    );
  }

  List<TransactionModel> _applyFilters(
    List<TransactionModel> all,
    String query,
    DateTimeRange? range,
    TransactionType? type,
  ) {
    return all.where((t) {
      final matchesSearch =
          query.isEmpty ||
          t.description.toLowerCase().contains(query.toLowerCase());

      final matchesType = type == null || t.type == type;

      bool matchesDate = true;
      if (range != null) {
        final date = DateTime(
          t.occurredAt.year,
          t.occurredAt.month,
          t.occurredAt.day,
        );
        final start = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );
        final end = DateTime(range.end.year, range.end.month, range.end.day);
        matchesDate =
            (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
            (date.isAtSameMomentAs(end) || date.isBefore(end));
      }

      return matchesSearch && matchesType && matchesDate;
    }).toList();
  }
}
