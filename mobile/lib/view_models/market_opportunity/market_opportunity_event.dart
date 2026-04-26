part of 'market_opportunity_bloc.dart';

abstract class MarketOpportunityEvent extends Equatable {
  const MarketOpportunityEvent();
  @override
  List<Object?> get props => [];
}

class FetchMarketOpportunities extends MarketOpportunityEvent {
  const FetchMarketOpportunities();
}

class MarketFilterChanged extends MarketOpportunityEvent {
  final MarketFilter filter;
  const MarketFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class MarketSortChanged extends MarketOpportunityEvent {
  final MarketSort sort;
  const MarketSortChanged(this.sort);
  @override
  List<Object?> get props => [sort];
}

class RefreshMarketOpportunities extends MarketOpportunityEvent {
  const RefreshMarketOpportunities();
}
