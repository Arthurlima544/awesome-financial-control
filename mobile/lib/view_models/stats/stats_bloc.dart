import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/monthly_stat_model.dart';
import 'package:afc/repositories/stats_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'dart:async';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsRepository _repository;
  final AppRefreshBloc _refreshBloc;
  late final StreamSubscription _refreshSubscription;

  StatsBloc({StatsRepository? repository, AppRefreshBloc? refreshBloc})
    : _repository = repository ?? sl<StatsRepository>(),
      _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
      super(StatsInitial()) {
    on<StatsLoaded>(_onLoaded);
    _refreshSubscription = _refreshBloc.stream.listen(
      (_) => add(const StatsLoaded()),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoaded(StatsLoaded event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final stats = await _repository.getMonthlyStats();
      emit(StatsData(stats));
    } catch (e) {
      emit(const StatsError('Erro ao carregar estatísticas mensais'));
    }
  }
}
