import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

part 'recurring_event.dart';
part 'recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final RecurringRepository _repository;
  final AppRefreshBloc _refreshBloc;
  late final StreamSubscription _refreshSubscription;

  RecurringBloc(this._repository, this._refreshBloc)
    : super(RecurringInitial()) {
    on<LoadRecurring>(_onLoadRecurring);
    on<ToggleRecurringActive>(_onToggleRecurringActive);
    on<DeleteRecurring>(_onDeleteRecurring);

    _refreshSubscription = _refreshBloc.stream.listen(
      (_) => add(LoadRecurring()),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoadRecurring(
    LoadRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    emit(RecurringLoading());
    try {
      final rules = await _repository.getAll();
      emit(RecurringLoaded(rules));
    } catch (e) {
      emit(RecurringError('Erro ao carregar transações recorrentes'));
    }
  }

  Future<void> _onToggleRecurringActive(
    ToggleRecurringActive event,
    Emitter<RecurringState> emit,
  ) async {
    try {
      final updated = event.recurring.copyWith(active: !event.recurring.active);
      await _repository.update(updated);
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(RecurringError('Erro ao atualizar transação recorrente'));
    }
  }

  Future<void> _onDeleteRecurring(
    DeleteRecurring event,
    Emitter<RecurringState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      _refreshBloc.add(DataChanged());
    } catch (e) {
      emit(RecurringError('Erro ao excluir transação recorrente'));
    }
  }
}
