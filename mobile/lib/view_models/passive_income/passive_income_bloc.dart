import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/passive_income_repository.dart';
import 'package:afc/models/passive_income_data.dart';
import 'package:afc/services/cache_service.dart';

// Events
abstract class PassiveIncomeEvent extends Equatable {
  const PassiveIncomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadPassiveIncomeDashboard extends PassiveIncomeEvent {}

// State
enum PassiveIncomeStatus { initial, loading, success, failure }

class PassiveIncomeState extends Equatable {
  final PassiveIncomeStatus status;
  final PassiveIncomeData? data;
  final String? errorMessage;

  const PassiveIncomeState({
    this.status = PassiveIncomeStatus.initial,
    this.data,
    this.errorMessage,
  });

  PassiveIncomeState copyWith({
    PassiveIncomeStatus? status,
    PassiveIncomeData? data,
    String? errorMessage,
  }) {
    return PassiveIncomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}

// Bloc
class PassiveIncomeBloc extends Bloc<PassiveIncomeEvent, PassiveIncomeState> {
  final PassiveIncomeRepository _repository;
  final CacheService _cacheService;
  static const _cacheKey = 'passive_income_dashboard';

  PassiveIncomeBloc({
    required PassiveIncomeRepository repository,
    required CacheService cacheService,
  }) : _repository = repository,
       _cacheService = cacheService,
       super(const PassiveIncomeState()) {
    on<LoadPassiveIncomeDashboard>(_onLoadPassiveIncomeDashboard);
  }

  Future<void> _onLoadPassiveIncomeDashboard(
    LoadPassiveIncomeDashboard event,
    Emitter<PassiveIncomeState> emit,
  ) async {
    // 1. Load from cache
    final cachedData = _cacheService.load(_cacheKey);
    if (cachedData != null) {
      try {
        final data = PassiveIncomeData.fromJson(cachedData);
        emit(state.copyWith(status: PassiveIncomeStatus.success, data: data));
      } catch (_) {
        // Cache corrupted, ignore
      }
    }

    // 2. Fetch from API
    if (state.status != PassiveIncomeStatus.success) {
      emit(state.copyWith(status: PassiveIncomeStatus.loading));
    }

    try {
      final data = await _repository.getDashboardData();
      // 3. Update cache
      await _cacheService.save(_cacheKey, data.toJson());
      emit(state.copyWith(status: PassiveIncomeStatus.success, data: data));
    } catch (e) {
      // 4. If failure and no cached data, show error
      if (state.data == null) {
        emit(
          state.copyWith(
            status: PassiveIncomeStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
      // If we have cached data, we stay in success state (silent error or we could show a snackbar)
    }
  }
}
