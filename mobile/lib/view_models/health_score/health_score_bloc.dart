import 'package:afc/models/health_score_model.dart';
import 'package:afc/repositories/health_score_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'health_score_event.dart';
part 'health_score_state.dart';

class HealthScoreBloc extends Bloc<HealthScoreEvent, HealthScoreState> {
  final HealthScoreRepository _repository;

  HealthScoreBloc({required HealthScoreRepository repository})
    : _repository = repository,
      super(const HealthScoreState()) {
    on<LoadHealthScore>(_onLoadHealthScore);
  }

  Future<void> _onLoadHealthScore(
    LoadHealthScore event,
    Emitter<HealthScoreState> emit,
  ) async {
    emit(state.copyWith(status: HealthScoreStatus.loading));
    try {
      final healthScore = await _repository.getHealthScore();
      emit(
        state.copyWith(
          status: HealthScoreStatus.success,
          healthScore: healthScore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HealthScoreStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
