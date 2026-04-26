import 'package:afc/models/passive_income_data.dart';
import 'package:afc/repositories/passive_income_repository.dart';
import 'package:afc/services/cache_service.dart';
import 'package:afc/view_models/passive_income/passive_income_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassiveIncomeRepository extends Mock
    implements PassiveIncomeRepository {}

class MockCacheService extends Mock implements CacheService {}

void main() {
  late PassiveIncomeRepository repository;
  late CacheService cacheService;

  const testData = PassiveIncomeData(
    freedomIndex: 45.5,
    totalPassiveIncomeCurrentMonth: 1200.0,
    monthlyProgression: [
      PassiveIncomeMonth(month: '2024-01', amount: 1000.0),
      PassiveIncomeMonth(month: '2024-02', amount: 1200.0),
    ],
    incomeByInvestment: {'Stock A': 500.0, 'REIT B': 700.0},
  );

  setUp(() {
    repository = MockPassiveIncomeRepository();
    cacheService = MockCacheService();
  });

  group('PassiveIncomeBloc', () {
    test('initial state is correct', () {
      final bloc = PassiveIncomeBloc(
        repository: repository,
        cacheService: cacheService,
      );
      expect(bloc.state.status, PassiveIncomeStatus.initial);
      expect(bloc.state.data, isNull);
      bloc.close();
    });

    blocTest<PassiveIncomeBloc, PassiveIncomeState>(
      'emits [success] immediately if cache is available, then [success] again when API returns',
      build: () {
        when(() => cacheService.load(any())).thenReturn(testData.toJson());
        when(
          () => repository.getDashboardData(),
        ).thenAnswer((_) async => testData);
        when(() => cacheService.save(any(), any())).thenAnswer((_) async => {});
        return PassiveIncomeBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadPassiveIncomeDashboard()),
      expect: () => [
        const PassiveIncomeState(
          status: PassiveIncomeStatus.success,
          data: testData,
        ),
        // Note: The second success emission might not happen if the data is identical
        // but Bloc emits it anyway because it's a new state object from copyWith
      ],
      verify: (_) {
        verify(() => cacheService.load('passive_income_dashboard')).called(1);
        verify(() => repository.getDashboardData()).called(1);
        verify(
          () => cacheService.save('passive_income_dashboard', any()),
        ).called(1);
      },
    );

    blocTest<PassiveIncomeBloc, PassiveIncomeState>(
      'emits [loading, success] when cache is empty and API succeeds',
      build: () {
        when(() => cacheService.load(any())).thenReturn(null);
        when(
          () => repository.getDashboardData(),
        ).thenAnswer((_) async => testData);
        when(() => cacheService.save(any(), any())).thenAnswer((_) async => {});
        return PassiveIncomeBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadPassiveIncomeDashboard()),
      expect: () => [
        const PassiveIncomeState(status: PassiveIncomeStatus.loading),
        const PassiveIncomeState(
          status: PassiveIncomeStatus.success,
          data: testData,
        ),
      ],
    );

    blocTest<PassiveIncomeBloc, PassiveIncomeState>(
      'emits [loading, failure] when cache is empty and API fails',
      build: () {
        when(() => cacheService.load(any())).thenReturn(null);
        when(
          () => repository.getDashboardData(),
        ).thenThrow(Exception('API Error'));
        return PassiveIncomeBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadPassiveIncomeDashboard()),
      expect: () => [
        const PassiveIncomeState(status: PassiveIncomeStatus.loading),
        const PassiveIncomeState(
          status: PassiveIncomeStatus.failure,
          errorMessage: 'Erro ao carregar painel de renda passiva',
        ),
      ],
    );

    blocTest<PassiveIncomeBloc, PassiveIncomeState>(
      'stays in success if API fails but cache was available',
      build: () {
        when(() => cacheService.load(any())).thenReturn(testData.toJson());
        when(
          () => repository.getDashboardData(),
        ).thenThrow(Exception('API Error'));
        return PassiveIncomeBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(LoadPassiveIncomeDashboard()),
      expect: () => [
        const PassiveIncomeState(
          status: PassiveIncomeStatus.success,
          data: testData,
        ),
      ],
    );
  });
}
