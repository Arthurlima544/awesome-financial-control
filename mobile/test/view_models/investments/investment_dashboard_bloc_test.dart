import 'package:afc/models/investment_dashboard_data.dart';
import 'package:afc/repositories/investment_repository.dart';
import 'package:afc/services/cache_service.dart';
import 'package:afc/view_models/investments/investment_dashboard_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInvestmentRepository extends Mock implements InvestmentRepository {}

class MockCacheService extends Mock implements CacheService {}

void main() {
  late InvestmentRepository repository;
  late CacheService cacheService;

  const testData = InvestmentDashboardData(
    totalProfitLoss: 5000.0,
    totalProfitLossPercentage: 10.5,
    currentTotalValue: 55000.0,
    totalInvested: 50000.0,
    allocationByType: {'Ações': 60.0, 'FIIs': 40.0},
    assetPerformance: [
      AssetPerformance(
        name: 'Stock A',
        profitLoss: 1000.0,
        percentage: 5.0,
        ticker: 'STKA3',
      ),
    ],
  );

  setUp(() {
    repository = MockInvestmentRepository();
    cacheService = MockCacheService();
  });

  group('InvestmentDashboardBloc', () {
    test('initial state is correct', () {
      final bloc = InvestmentDashboardBloc(
        repository: repository,
        cacheService: cacheService,
      );
      expect(bloc.state.status, InvestmentDashboardStatus.initial);
      expect(bloc.state.data, isNull);
      bloc.close();
    });

    blocTest<InvestmentDashboardBloc, InvestmentDashboardState>(
      'emits [success] immediately if cache is available, then [success] again when API returns',
      build: () {
        when(() => cacheService.load(any())).thenReturn(testData.toJson());
        when(
          () => repository.getDashboardData(),
        ).thenAnswer((_) async => testData);
        when(() => cacheService.save(any(), any())).thenAnswer((_) async => {});
        return InvestmentDashboardBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadInvestmentDashboard()),
      expect: () => [
        const InvestmentDashboardState(
          status: InvestmentDashboardStatus.success,
          data: testData,
        ),
      ],
    );

    blocTest<InvestmentDashboardBloc, InvestmentDashboardState>(
      'emits [loading, success] when cache is empty and API succeeds',
      build: () {
        when(() => cacheService.load(any())).thenReturn(null);
        when(
          () => repository.getDashboardData(),
        ).thenAnswer((_) async => testData);
        when(() => cacheService.save(any(), any())).thenAnswer((_) async => {});
        return InvestmentDashboardBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadInvestmentDashboard()),
      expect: () => [
        const InvestmentDashboardState(
          status: InvestmentDashboardStatus.loading,
        ),
        const InvestmentDashboardState(
          status: InvestmentDashboardStatus.success,
          data: testData,
        ),
      ],
    );

    blocTest<InvestmentDashboardBloc, InvestmentDashboardState>(
      'emits [loading, failure] when cache is empty and API fails',
      build: () {
        when(() => cacheService.load(any())).thenReturn(null);
        when(
          () => repository.getDashboardData(),
        ).thenThrow(Exception('API Error'));
        return InvestmentDashboardBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadInvestmentDashboard()),
      expect: () => [
        const InvestmentDashboardState(
          status: InvestmentDashboardStatus.loading,
        ),
        const InvestmentDashboardState(
          status: InvestmentDashboardStatus.failure,
          errorMessage: 'Erro ao carregar análise de portfólio',
        ),
      ],
    );
  });
}
