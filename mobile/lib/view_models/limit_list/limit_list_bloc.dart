import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/limit_model.dart';
import 'package:afc/repositories/limit_list_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'dart:async';

part 'limit_list_event.dart';
part 'limit_list_state.dart';

class LimitListBloc extends Bloc<LimitListEvent, LimitListState> {
  final LimitListRepository _repository;
  final AppRefreshBloc _refreshBloc;
  late final StreamSubscription _refreshSubscription;

  LimitListBloc({LimitListRepository? repository, AppRefreshBloc? refreshBloc})
    : _repository = repository ?? sl<LimitListRepository>(),
      _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
      super(LimitListInitial()) {
    on<LimitListFetchRequested>(_onFetchRequested);
    on<LimitListDeleteRequested>(_onDeleteRequested);
    on<LimitListUpdateRequested>(_onUpdateRequested);

    _refreshSubscription = _refreshBloc.stream.listen(
      (_) => add(const LimitListFetchRequested()),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

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
      _refreshBloc.add(DataChanged());
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
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(LimitListError(e.toString()));
    }
  }
}
