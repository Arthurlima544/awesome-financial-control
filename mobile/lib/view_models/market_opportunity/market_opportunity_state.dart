part of 'market_opportunity_bloc.dart';

enum MarketFilter { all, stocks, fiis }

enum MarketSort { dyDesc, dyVsCdiDesc, peAsc }

enum MarketOpportunityStatus { initial, loading, success, failure }

class MarketOpportunityState extends Equatable {
  final MarketOpportunityStatus status;
  final List<MarketOpportunity> opportunities;
  final List<MarketOpportunity> filteredOpportunities;
  final MarketBenchmarks? benchmarks;
  final MarketFilter filter;
  final MarketSort sort;
  final String? errorMessage;

  const MarketOpportunityState({
    this.status = MarketOpportunityStatus.initial,
    this.opportunities = const [],
    this.filteredOpportunities = const [],
    this.benchmarks,
    this.filter = MarketFilter.all,
    this.sort = MarketSort.dyDesc,
    this.errorMessage,
  });

  MarketOpportunityState copyWith({
    MarketOpportunityStatus? status,
    List<MarketOpportunity>? opportunities,
    List<MarketOpportunity>? filteredOpportunities,
    MarketBenchmarks? benchmarks,
    MarketFilter? filter,
    MarketSort? sort,
    String? errorMessage,
  }) {
    return MarketOpportunityState(
      status: status ?? this.status,
      opportunities: opportunities ?? this.opportunities,
      filteredOpportunities:
          filteredOpportunities ?? this.filteredOpportunities,
      benchmarks: benchmarks ?? this.benchmarks,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    opportunities,
    filteredOpportunities,
    benchmarks,
    filter,
    sort,
    errorMessage,
  ];
}
