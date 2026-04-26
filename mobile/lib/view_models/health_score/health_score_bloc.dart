import 'package:afc/models/health_score_model.dart';
import 'package:afc/repositories/health_score_repository.dart';
import 'package:afc/services/cache_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'health_score_event.dart';
part 'health_score_state.dart';

class HealthScoreBloc extends Bloc<HealthScoreEvent, HealthScoreState> {
  final HealthScoreRepository _repository;
  final CacheService _cacheService;
  static const _cacheKey = 'health_score_dashboard';

  HealthScoreBloc({
    required HealthScoreRepository repository,
    required CacheService cacheService,
  }) : _repository = repository,
       _cacheService = cacheService,
       super(const HealthScoreState()) {
    on<LoadHealthScore>(_onLoadHealthScore);
  }

  Future<void> _onLoadHealthScore(
    LoadHealthScore event,
    Emitter<HealthScoreState> emit,
  ) async {
    // 1. Load from cache
    final cachedData = _cacheService.load(_cacheKey);
    if (cachedData != null) {
      try {
        final data = HealthScoreModel.fromJson(cachedData);
        emit(
          state.copyWith(status: HealthScoreStatus.success, healthScore: data),
        );
      } catch (_) {
        // Cache corrupted, ignore
      }
    }

    // 2. Fetch from API
    if (state.status != HealthScoreStatus.success) {
      emit(state.copyWith(status: HealthScoreStatus.loading));
    }

    try {
      final healthScore = await _repository.getHealthScore();
      // 3. Update cache
      await _cacheService.save(_cacheKey, healthScore.toJson());
      emit(
        state.copyWith(
          status: HealthScoreStatus.success,
          healthScore: healthScore,
        ),
      );
    } catch (e) {
      // 4. If failure and no cached data, show error
      if (state.healthScore == null) {
        emit(
          state.copyWith(
            status: HealthScoreStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
      // If we have cached data, we stay in success state
    }
  }
}
