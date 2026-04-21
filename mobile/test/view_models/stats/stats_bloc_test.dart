import 'package:afc/view_models/stats/stats_bloc.dart';
import 'package:afc/models/monthly_stat_model.dart';
import 'package:afc/repositories/stats_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends StatsRepository {
  _FakeRepository(this._stats);

  final List<MonthlyStatModel> _stats;

  @override
  Future<List<MonthlyStatModel>> getMonthlyStats() async => _stats;
}

class _FailingRepository extends StatsRepository {
  @override
  Future<List<MonthlyStatModel>> getMonthlyStats() =>
      Future.error(Exception('network error'));
}

void main() {
  final sampleStats = [
    const MonthlyStatModel(month: '2025-01', income: 5000.0, expenses: 3000.0),
    const MonthlyStatModel(month: '2025-02', income: 4500.0, expenses: 4800.0),
    const MonthlyStatModel(month: '2025-03', income: 6000.0, expenses: 2500.0),
  ];

  group('StatsBloc', () {
    test('initial state is StatsInitial', () {
      final bloc = StatsBloc(repository: _FakeRepository([]));
      expect(bloc.state, isA<StatsInitial>());
      addTearDown(bloc.close);
    });

    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsData([])] when repository returns empty list',
      build: () => StatsBloc(repository: _FakeRepository([])),
      act: (bloc) => bloc.add(const StatsLoaded()),
      expect: () => [isA<StatsLoading>(), isA<StatsData>()],
      verify: (bloc) {
        final state = bloc.state as StatsData;
        expect(state.stats, isEmpty);
      },
    );

    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsData] with correct stats on success',
      build: () => StatsBloc(repository: _FakeRepository(sampleStats)),
      act: (bloc) => bloc.add(const StatsLoaded()),
      expect: () => [isA<StatsLoading>(), isA<StatsData>()],
      verify: (bloc) {
        final state = bloc.state as StatsData;
        expect(state.stats.length, 3);
        expect(state.stats.first.month, '2025-01');
      },
    );

    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsError] when repository throws',
      build: () => StatsBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const StatsLoaded()),
      expect: () => [isA<StatsLoading>(), isA<StatsError>()],
    );

    test(
      'StatsData.maxValue returns the highest single value across all months',
      () {
        final state = StatsData(sampleStats);
        // income: 5000, 4500, 6000 / expenses: 3000, 4800, 2500 → max = 6000
        expect(state.maxValue, 6000.0);
      },
    );

    test('StatsData.maxValue returns 0 for empty stats', () {
      final state = StatsData(const []);
      expect(state.maxValue, 0.0);
    });

    test('StatsData.yInterval rounds up to nearest 500 step divided by 4', () {
      // maxValue = 6000 → raw = 1500 → (1500/500).ceil()*500 = 3*500 = 1500
      final state = StatsData(sampleStats);
      expect(state.yInterval, 1500.0);

      // maxValue = 0 → fallback 1000
      final emptyState = StatsData(const []);
      expect(emptyState.yInterval, 1000.0);

      // maxValue = 1200 → raw = 300 → (300/500).ceil()*500 = 1*500 = 500
      final smallState = StatsData(const [
        MonthlyStatModel(month: '2025-01', income: 1200.0, expenses: 800.0),
      ]);
      expect(smallState.yInterval, 500.0);
    });
  });
}
