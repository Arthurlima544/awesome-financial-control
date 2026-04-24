part of 'market_opportunity_bloc.dart';

abstract class MarketOpportunityEvent {}

class FetchMarketOpportunities extends MarketOpportunityEvent {}

class MarketFilterChanged extends MarketOpportunityEvent {
  final MarketFilter filter;
  MarketFilterChanged(this.filter);
}

class MarketSortChanged extends MarketOpportunityEvent {
  final MarketSort sort;
  MarketSortChanged(this.sort);
}
