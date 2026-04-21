import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/limit_model.dart';
import 'package:afc/repositories/limit_list_repository.dart';

part 'limit_list_event.dart';
part 'limit_list_state.dart';

class LimitListBloc extends Bloc<LimitListEvent, LimitListState> {
  LimitListBloc({LimitListRepository? repository})
    : _repository = repository ?? sl<LimitListRepository>(),
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
