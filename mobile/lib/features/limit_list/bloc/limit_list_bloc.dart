import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/limit_model.dart';
import '../repository/limit_list_repository.dart';

// Events

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

// States

abstract class LimitListState extends Equatable {
  const LimitListState();
  @override
  List<Object?> get props => [];
}

class LimitListInitial extends LimitListState {}

class LimitListLoading extends LimitListState {}

class LimitListData extends LimitListState {
  const LimitListData(this.limits);

  final List<LimitModel> limits;

  @override
  List<Object?> get props => [limits];
}

class LimitListError extends LimitListState {
  const LimitListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc

class LimitListBloc extends Bloc<LimitListEvent, LimitListState> {
  LimitListBloc({LimitListRepository? repository})
    : _repository = repository ?? LimitListRepository(),
      super(LimitListInitial()) {
    on<LimitListFetchRequested>(_onFetchRequested);
    on<LimitListDeleteRequested>(_onDeleteRequested);
    on<LimitListUpdateRequested>(_onUpdateRequested);
  }

  final LimitListRepository _repository;

  Future<void> _onFetchRequested(
    LimitListFetchRequested event,
    Emitter<LimitListState> emit,
  ) async {
    emit(LimitListLoading());
    try {
      final limits = await _repository.getAll();
      emit(LimitListData(limits));
    } catch (e) {
      emit(LimitListError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    LimitListDeleteRequested event,
    Emitter<LimitListState> emit,
  ) async {
    final current = state;
    if (current is! LimitListData) return;
    try {
      await _repository.delete(event.id);
      final updated = current.limits.where((l) => l.id != event.id).toList();
      emit(LimitListData(updated));
    } catch (e) {
      emit(LimitListError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    LimitListUpdateRequested event,
    Emitter<LimitListState> emit,
  ) async {
    final current = state;
    if (current is! LimitListData) return;
    try {
      final updated = await _repository.update(event.id, event.amount);
      final updatedList = current.limits.map((l) {
        return l.id == event.id ? updated : l;
      }).toList();
      emit(LimitListData(updatedList));
    } catch (e) {
      emit(LimitListError(e.toString()));
    }
  }
}
