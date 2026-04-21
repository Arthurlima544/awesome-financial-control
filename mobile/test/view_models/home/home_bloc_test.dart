import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/models/summary_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/home_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends HomeRepository {
  _FakeRepository({required this.summary, required this.transactions});

  final SummaryModel summary;
  final List<TransactionModel> transactions;

  @override
  Future<SummaryModel> getSummary() async => summary;

  @override
  Future<List<TransactionModel>> getLastTransactions({int limit = 5}) async =>
      transactions;
}

class _FailingRepository extends HomeRepository {
  @override
  Future<SummaryModel> getSummary() => Future.error(Exception('network error'));

  @override
  Future<List<TransactionModel>> getLastTransactions({int limit = 5}) =>
      Future.error(Exception('network error'));
}

void main() {
  final fakeSummary = SummaryModel(
    totalIncome: 5000,
    totalExpenses: 1500,
    balance: 3500,
  );

  final fakeTransactions = [
    TransactionModel(
      id: '1',
      description: 'Salary',
      amount: 5000,
      type: TransactionType.income,
      occurredAt: DateTime.now(),
    ),
  ];

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      final bloc = HomeBloc(
        repository: _FakeRepository(
          summary: fakeSummary,
          transactions: fakeTransactions,
        ),
      );
      expect(bloc.state, isA<HomeInitial>());
      addTearDown(bloc.close);
    });

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when HomeDashboardLoaded succeeds',
      build: () => HomeBloc(
        repository: _FakeRepository(
          summary: fakeSummary,
          transactions: fakeTransactions,
        ),
      ),
      act: (bloc) => bloc.add(const HomeDashboardLoaded()),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
    );

    blocTest<HomeBloc, HomeState>(
      'HomeLoaded contains correct summary values',
      build: () => HomeBloc(
        repository: _FakeRepository(
          summary: fakeSummary,
          transactions: fakeTransactions,
        ),
      ),
      act: (bloc) => bloc.add(const HomeDashboardLoaded()),
      verify: (bloc) {
        final state = bloc.state as HomeLoaded;
        expect(state.summary.totalIncome, 5000);
        expect(state.summary.totalExpenses, 1500);
        expect(state.summary.balance, 3500);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'HomeLoaded contains correct transactions',
      build: () => HomeBloc(
        repository: _FakeRepository(
          summary: fakeSummary,
          transactions: fakeTransactions,
        ),
      ),
      act: (bloc) => bloc.add(const HomeDashboardLoaded()),
      verify: (bloc) {
        final state = bloc.state as HomeLoaded;
        expect(state.transactions.length, 1);
        expect(state.transactions.first.description, 'Salary');
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeError] when repository throws',
      build: () => HomeBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const HomeDashboardLoaded()),
      expect: () => [isA<HomeLoading>(), isA<HomeError>()],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when HomeDashboardLoaded is dispatched again from loaded state',
      build: () => HomeBloc(
        repository: _FakeRepository(
          summary: fakeSummary,
          transactions: fakeTransactions,
        ),
      ),
      seed: () =>
          HomeLoaded(summary: fakeSummary, transactions: fakeTransactions),
      act: (bloc) => bloc.add(const HomeDashboardLoaded()),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] with empty transactions list',
      build: () => HomeBloc(
        repository: _FakeRepository(
          summary: SummaryModel(totalIncome: 0, totalExpenses: 0, balance: 0),
          transactions: [],
        ),
      ),
      act: (bloc) => bloc.add(const HomeDashboardLoaded()),
      verify: (bloc) {
        final state = bloc.state as HomeLoaded;
        expect(state.transactions, isEmpty);
      },
    );
  });
}
