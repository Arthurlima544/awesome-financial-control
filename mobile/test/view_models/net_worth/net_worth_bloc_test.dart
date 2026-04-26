import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afc/models/net_worth_point.dart';
import 'package:afc/repositories/stats_repository.dart';
import 'package:afc/view_models/net_worth/net_worth_bloc.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late StatsRepository repository;
  late NetWorthBloc bloc;

  setUp(() {
    repository = MockStatsRepository();
    bloc = NetWorthBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is correct', () {
    expect(bloc.state.status, NetWorthStatus.initial);
    expect(bloc.state.data, isEmpty);
  });

  blocTest<NetWorthBloc, NetWorthState>(
    'emits [loading, success] when LoadNetWorthEvolution is successful',
    build: () {
      final data = [
        NetWorthPoint(
          month: '2024-01',
          assets: 1000,
          liabilities: 500,
          total: 500,
        ),
      ];
      when(
        () => repository.getNetWorthEvolution(),
      ).thenAnswer((_) async => data);
      return bloc;
    },
    act: (bloc) => bloc.add(LoadNetWorthEvolution()),
    expect: () => [
      predicate<NetWorthState>(
        (state) => state.status == NetWorthStatus.loading,
      ),
      predicate<NetWorthState>(
        (state) =>
            state.status == NetWorthStatus.success &&
            state.data.length == 1 &&
            state.data.first.month == '2024-01',
      ),
    ],
  );

  blocTest<NetWorthBloc, NetWorthState>(
    'emits [loading, failure] when LoadNetWorthEvolution fails',
    build: () {
      when(
        () => repository.getNetWorthEvolution(),
      ).thenThrow(Exception('error'));
      return bloc;
    },
    act: (bloc) => bloc.add(LoadNetWorthEvolution()),
    expect: () => [
      predicate<NetWorthState>(
        (state) => state.status == NetWorthStatus.loading,
      ),
      predicate<NetWorthState>(
        (state) =>
            state.status == NetWorthStatus.failure &&
            state.errorMessage == 'Erro ao carregar evolução do patrimônio',
      ),
    ],
  );
}
