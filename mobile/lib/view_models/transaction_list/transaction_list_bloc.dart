import 'package:equatable/equatable.dart';
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
      emit(TransactionListData(transactions));
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
      emit(TransactionListData(updated));
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
        type: event.type,
        category: event.category,
        occurredAt: event.occurredAt,
      );
      final updatedList = current.transactions.map((t) {
        return t.id == event.id ? updated : t;
      }).toList();
      emit(TransactionListData(updatedList));
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }
}
