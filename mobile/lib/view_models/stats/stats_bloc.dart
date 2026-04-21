import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/monthly_stat_model.dart';
import 'package:afc/repositories/stats_repository.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({StatsRepository? repository})
    : _repository = repository ?? sl<StatsRepository>(),
      super(StatsInitial()) {
    on<StatsLoaded>(_onLoaded);
  }

  final StatsRepository _repository;

  Future<void> _onLoaded(StatsLoaded event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final stats = await _repository.getMonthlyStats();
      emit(StatsData(stats));
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }
}
