import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afc/repositories/market_repository.dart';

part 'market_opportunity_event.dart';
part 'market_opportunity_state.dart';

class MarketOpportunityBloc
    extends Bloc<MarketOpportunityEvent, MarketOpportunityState> {
  final MarketRepository _marketRepository;

  MarketOpportunityBloc({required MarketRepository marketRepository})
    : _marketRepository = marketRepository,
      super(MarketOpportunityState()) {
    on<FetchMarketOpportunities>(_onFetchMarketOpportunities);
    on<RefreshMarketOpportunities>(_onRefreshMarketOpportunities);
    on<MarketFilterChanged>(_onFilterChanged);
    on<MarketSortChanged>(_onSortChanged);
  }

  Future<void> _onRefreshMarketOpportunities(
    RefreshMarketOpportunities event,
    Emitter<MarketOpportunityState> emit,
  ) async {
    try {
      final opportunities = await _marketRepository.getOpportunities();
      final benchmarks = await _marketRepository.getBenchmarks();

      final filtered = _applyFilterAndSort(
        opportunities,
        state.filter,
        state.sort,
      );

      emit(
        state.copyWith(
          status: MarketOpportunityStatus.success,
          opportunities: opportunities,
          filteredOpportunities: filtered,
          benchmarks: benchmarks,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MarketOpportunityStatus.failure,
          errorMessage: 'Erro ao carregar oportunidades de mercado',
        ),
      );
    }
  }

  Future<void> _onFetchMarketOpportunities(
    FetchMarketOpportunities event,
    Emitter<MarketOpportunityState> emit,
  ) async {
    emit(state.copyWith(status: MarketOpportunityStatus.loading));
    try {
      final opportunities = await _marketRepository.getOpportunities();
      final benchmarks = await _marketRepository.getBenchmarks();

      final filtered = _applyFilterAndSort(
        opportunities,
        state.filter,
        state.sort,
      );

      emit(
        state.copyWith(
          status: MarketOpportunityStatus.success,
          opportunities: opportunities,
          filteredOpportunities: filtered,
          benchmarks: benchmarks,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MarketOpportunityStatus.failure,
          errorMessage: 'Erro ao carregar oportunidades de mercado',
        ),
      );
    }
  }

  void _onFilterChanged(
    MarketFilterChanged event,
    Emitter<MarketOpportunityState> emit,
  ) {
    final filtered = _applyFilterAndSort(
      state.opportunities,
      event.filter,
      state.sort,
    );
    emit(state.copyWith(filter: event.filter, filteredOpportunities: filtered));
  }

  void _onSortChanged(
    MarketSortChanged event,
    Emitter<MarketOpportunityState> emit,
  ) {
    final filtered = _applyFilterAndSort(
      state.opportunities,
      state.filter,
      event.sort,
    );
    emit(state.copyWith(sort: event.sort, filteredOpportunities: filtered));
  }

  List<MarketOpportunity> _applyFilterAndSort(
    List<MarketOpportunity> list,
    MarketFilter filter,
    MarketSort sort,
  ) {
    var result = List<MarketOpportunity>.from(list);

    // Apply Filter
    if (filter == MarketFilter.stocks) {
      result = result.where((o) => !o.isFii).toList();
    } else if (filter == MarketFilter.fiis) {
      result = result.where((o) => o.isFii).toList();
    }

    // Apply Sort
    switch (sort) {
      case MarketSort.dyDesc:
        result.sort((a, b) => b.dividendYield.compareTo(a.dividendYield));
        break;
      case MarketSort.dyVsCdiDesc:
        result.sort((a, b) => b.dyVsCdi.compareTo(a.dyVsCdi));
        break;
      case MarketSort.peAsc:
        result.sort((a, b) {
          if (a.priceEarnings == null) return 1;
          if (b.priceEarnings == null) return -1;
          return a.priceEarnings!.compareTo(b.priceEarnings!);
        });
        break;
    }

    return result;
  }
}
