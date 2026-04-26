import 'package:afc/repositories/market_repository.dart';
import 'package:afc/view_models/market_opportunity/market_opportunity_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late MarketRepository repository;

  final testOpportunities = [
    MarketOpportunity(
      ticker: 'PETR4',
      name: 'Petrobras',
      price: 35.0,
      changePercent: 1.5,
      dividendYield: 15.0,
      isFii: false,
      dyVsCdi: 1.2,
      lastUpdated: DateTime(2026),
    ),
    MarketOpportunity(
      ticker: 'HGLG11',
      name: 'HGLG FII',
      price: 160.0,
      changePercent: -0.5,
      dividendYield: 9.0,
      isFii: true,
      dyVsCdi: 0.8,
      lastUpdated: DateTime(2026),
    ),
  ];

  final testBenchmarks = MarketBenchmarks(cdiRate: 11.25, selicRate: 11.25);

  setUp(() {
    repository = MockMarketRepository();
  });

  group('MarketOpportunityBloc', () {
    test('initial state is correct', () {
      final bloc = MarketOpportunityBloc(marketRepository: repository);
      expect(bloc.state.status, MarketOpportunityStatus.initial);
      expect(bloc.state.filter, MarketFilter.all);
      expect(bloc.state.sort, MarketSort.dyDesc);
      bloc.close();
    });

    blocTest<MarketOpportunityBloc, MarketOpportunityState>(
      'emits [loading, success] when FetchMarketOpportunities succeeds',
      build: () {
        when(
          () => repository.getOpportunities(),
        ).thenAnswer((_) async => testOpportunities);
        when(
          () => repository.getBenchmarks(),
        ).thenAnswer((_) async => testBenchmarks);
        return MarketOpportunityBloc(marketRepository: repository);
      },
      act: (bloc) => bloc.add(FetchMarketOpportunities()),
      expect: () => [
        isA<MarketOpportunityState>().having(
          (s) => s.status,
          'status',
          MarketOpportunityStatus.loading,
        ),
        isA<MarketOpportunityState>()
            .having((s) => s.status, 'status', MarketOpportunityStatus.success)
            .having((s) => s.opportunities, 'opportunities', testOpportunities)
            .having(
              (s) => s.filteredOpportunities,
              'filtered',
              testOpportunities,
            )
            .having((s) => s.benchmarks, 'benchmarks', testBenchmarks),
      ],
    );

    blocTest<MarketOpportunityBloc, MarketOpportunityState>(
      'filters by stocks correctly',
      seed: () => MarketOpportunityState(
        status: MarketOpportunityStatus.success,
        opportunities: testOpportunities,
        filteredOpportunities: testOpportunities,
      ),
      build: () => MarketOpportunityBloc(marketRepository: repository),
      act: (bloc) => bloc.add(const MarketFilterChanged(MarketFilter.stocks)),
      expect: () => [
        isA<MarketOpportunityState>()
            .having((s) => s.filter, 'filter', MarketFilter.stocks)
            .having((s) => s.filteredOpportunities.length, 'length', 1)
            .having(
              (s) => s.filteredOpportunities.first.ticker,
              'ticker',
              'PETR4',
            ),
      ],
    );

    blocTest<MarketOpportunityBloc, MarketOpportunityState>(
      'filters by FIIs correctly',
      seed: () => MarketOpportunityState(
        status: MarketOpportunityStatus.success,
        opportunities: testOpportunities,
        filteredOpportunities: testOpportunities,
      ),
      build: () => MarketOpportunityBloc(marketRepository: repository),
      act: (bloc) => bloc.add(const MarketFilterChanged(MarketFilter.fiis)),
      expect: () => [
        isA<MarketOpportunityState>()
            .having((s) => s.filter, 'filter', MarketFilter.fiis)
            .having((s) => s.filteredOpportunities.length, 'length', 1)
            .having(
              (s) => s.filteredOpportunities.first.ticker,
              'ticker',
              'HGLG11',
            ),
      ],
    );

    blocTest<MarketOpportunityBloc, MarketOpportunityState>(
      'emits [failure] when fetch fails',
      build: () {
        when(() => repository.getOpportunities()).thenThrow(Exception('Error'));
        return MarketOpportunityBloc(marketRepository: repository);
      },
      act: (bloc) => bloc.add(FetchMarketOpportunities()),
      expect: () => [
        isA<MarketOpportunityState>().having(
          (s) => s.status,
          'status',
          MarketOpportunityStatus.loading,
        ),
        isA<MarketOpportunityState>()
            .having((s) => s.status, 'status', MarketOpportunityStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Erro ao carregar oportunidades de mercado',
            ),
      ],
    );
  });
}
