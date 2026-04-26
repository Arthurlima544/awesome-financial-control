import 'package:afc/models/health_score_model.dart';
import 'package:afc/repositories/health_score_repository.dart';
import 'package:afc/services/cache_service.dart';
import 'package:afc/view_models/health_score/health_score_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthScoreRepository extends Mock implements HealthScoreRepository {}

class MockCacheService extends Mock implements CacheService {}

void main() {
  late HealthScoreRepository repository;
  late CacheService cacheService;

  final testScore = HealthScoreModel(
    score: 85,
    savingsScore: 20,
    limitsScore: 22,
    goalsScore: 23,
    varianceScore: 20,
    historicalScores: const [70, 75, 80, 85],
  );

  setUp(() {
    repository = MockHealthScoreRepository();
    cacheService = MockCacheService();
  });

  group('HealthScoreBloc', () {
    test('initial state has correct default values', () {
      final bloc = HealthScoreBloc(
        repository: repository,
        cacheService: cacheService,
      );
      expect(bloc.state.status, HealthScoreStatus.initial);
      expect(bloc.state.healthScore, isNull);
      bloc.close();
    });

    blocTest<HealthScoreBloc, HealthScoreState>(
      'emits [success] immediately if cache is available, then [success] again with updated data from API',
      build: () {
        final updatedScore = HealthScoreModel(
          score: 90,
          savingsScore: 25,
          limitsScore: 22,
          goalsScore: 23,
          varianceScore: 20,
          historicalScores: const [70, 75, 80, 85, 90],
        );
        when(() => cacheService.load(any())).thenReturn(testScore.toJson());
        when(
          () => repository.getHealthScore(),
        ).thenAnswer((_) async => updatedScore);
        when(
          () => cacheService.save(any(), any()),
        ).thenAnswer((_) async => true);
        return HealthScoreBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(const LoadHealthScore()),
      expect: () => [
        HealthScoreState(
          status: HealthScoreStatus.success,
          healthScore: testScore,
        ),
        isA<HealthScoreState>()
            .having((s) => s.status, 'status', HealthScoreStatus.success)
            .having((s) => s.healthScore?.score, 'score', 90),
      ],
      verify: (_) {
        verify(() => cacheService.load(any())).called(1);
        verify(() => repository.getHealthScore()).called(1);
        verify(() => cacheService.save(any(), any())).called(1);
      },
    );

    blocTest<HealthScoreBloc, HealthScoreState>(
      'emits [loading, success] when cache is empty and API succeeds',
      build: () {
        when(() => cacheService.load(any())).thenReturn(null);
        when(
          () => repository.getHealthScore(),
        ).thenAnswer((_) async => testScore);
        when(
          () => cacheService.save(any(), any()),
        ).thenAnswer((_) async => true);
        return HealthScoreBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(const LoadHealthScore()),
      expect: () => [
        const HealthScoreState(status: HealthScoreStatus.loading),
        HealthScoreState(
          status: HealthScoreStatus.success,
          healthScore: testScore,
        ),
      ],
    );

    blocTest<HealthScoreBloc, HealthScoreState>(
      'emits [loading, failure] when cache is empty and API fails',
      build: () {
        when(() => cacheService.load(any())).thenReturn(null);
        when(() => repository.getHealthScore()).thenThrow(Exception('error'));
        return HealthScoreBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(const LoadHealthScore()),
      expect: () => [
        const HealthScoreState(status: HealthScoreStatus.loading),
        const HealthScoreState(
          status: HealthScoreStatus.failure,
          errorMessage: 'Erro ao carregar pontuação de saúde financeira',
        ),
      ],
    );

    blocTest<HealthScoreBloc, HealthScoreState>(
      'stays in [success] with cached data if API fails',
      build: () {
        when(() => cacheService.load(any())).thenReturn(testScore.toJson());
        when(() => repository.getHealthScore()).thenThrow(Exception('error'));
        return HealthScoreBloc(
          repository: repository,
          cacheService: cacheService,
        );
      },
      act: (bloc) => bloc.add(const LoadHealthScore()),
      expect: () => [
        HealthScoreState(
          status: HealthScoreStatus.success,
          healthScore: testScore,
        ),
        // No loading or failure state emitted because we have cached data
      ],
    );
  });
}
