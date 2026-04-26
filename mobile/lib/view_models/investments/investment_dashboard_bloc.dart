import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/investment_repository.dart';
import 'package:afc/models/investment_dashboard_data.dart';
import 'package:afc/services/cache_service.dart';

// Events
abstract class InvestmentDashboardEvent extends Equatable {
  const InvestmentDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadInvestmentDashboard extends InvestmentDashboardEvent {}

// State
enum InvestmentDashboardStatus { initial, loading, success, failure }

class InvestmentDashboardState extends Equatable {
  final InvestmentDashboardStatus status;
  final InvestmentDashboardData? data;
  final String? errorMessage;

  const InvestmentDashboardState({
    this.status = InvestmentDashboardStatus.initial,
    this.data,
    this.errorMessage,
  });

  InvestmentDashboardState copyWith({
    InvestmentDashboardStatus? status,
    InvestmentDashboardData? data,
    String? errorMessage,
  }) {
    return InvestmentDashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}

// Bloc
class InvestmentDashboardBloc
    extends Bloc<InvestmentDashboardEvent, InvestmentDashboardState> {
  final InvestmentRepository _repository;
  final CacheService _cacheService;
  static const _cacheKey = 'investment_dashboard';

  InvestmentDashboardBloc({
    required InvestmentRepository repository,
    required CacheService cacheService,
  }) : _repository = repository,
       _cacheService = cacheService,
       super(const InvestmentDashboardState()) {
    on<LoadInvestmentDashboard>(_onLoadInvestmentDashboard);
  }

  Future<void> _onLoadInvestmentDashboard(
    LoadInvestmentDashboard event,
    Emitter<InvestmentDashboardState> emit,
  ) async {
    // 1. Load from cache
    final cachedData = _cacheService.load(_cacheKey);
    if (cachedData != null) {
      try {
        final data = InvestmentDashboardData.fromJson(cachedData);
        emit(
          state.copyWith(status: InvestmentDashboardStatus.success, data: data),
        );
      } catch (_) {
        // Cache corrupted, ignore
      }
    }

    // 2. Fetch from API
    if (state.status != InvestmentDashboardStatus.success) {
      emit(state.copyWith(status: InvestmentDashboardStatus.loading));
    }

    try {
      final data = await _repository.getDashboardData();
      // 3. Update cache
      await _cacheService.save(_cacheKey, data.toJson());
      emit(
        state.copyWith(status: InvestmentDashboardStatus.success, data: data),
      );
    } catch (e) {
      // 4. If failure and no cached data, show error
      if (state.data == null) {
        emit(
          state.copyWith(
            status: InvestmentDashboardStatus.failure,
            errorMessage: 'Erro ao carregar análise de portfólio',
          ),
        );
      }
      // If we have cached data, we stay in success state
    }
  }
}
