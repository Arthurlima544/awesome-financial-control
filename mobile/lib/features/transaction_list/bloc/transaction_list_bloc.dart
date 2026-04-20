import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/transaction_model.dart';
import '../repository/transaction_list_repository.dart';

// Events

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

// States

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

// Bloc

class TransactionListBloc
    extends Bloc<TransactionListEvent, TransactionListState> {
  TransactionListBloc({TransactionListRepository? repository})
    : _repository = repository ?? TransactionListRepository(),
      super(TransactionListInitial()) {
    on<TransactionListFetchRequested>(_onFetchRequested);
    on<TransactionDeleteRequested>(_onDeleteRequested);
  }

  final TransactionListRepository _repository;

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
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }
}
