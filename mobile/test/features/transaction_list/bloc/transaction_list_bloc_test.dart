import 'package:afc/features/transaction_list/bloc/transaction_list_bloc.dart';
import 'package:afc/features/transaction_list/model/transaction_model.dart';
import 'package:afc/features/transaction_list/repository/transaction_list_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends TransactionListRepository {
  _FakeRepository(this._transactions);

  final List<TransactionModel> _transactions;

  @override
  Future<List<TransactionModel>> getAll() async => _transactions;

  @override
  Future<void> delete(String id) async {}
}

class _FailingRepository extends TransactionListRepository {
  @override
  Future<List<TransactionModel>> getAll() =>
      Future.error(Exception('network error'));

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));
}

class _FailingDeleteRepository extends TransactionListRepository {
  _FailingDeleteRepository(this._transactions);

  final List<TransactionModel> _transactions;

  @override
  Future<List<TransactionModel>> getAll() async => _transactions;

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));
}

void main() {
  final t1 = TransactionModel(
    id: 'id-1',
    description: 'Salary',
    amount: 5000.0,
    type: TransactionType.income,
    occurredAt: DateTime(2026, 4, 1),
  );

  final t2 = TransactionModel(
    id: 'id-2',
    description: 'Rent',
    amount: 1500.0,
    type: TransactionType.expense,
    occurredAt: DateTime(2026, 4, 2),
  );

  group('TransactionListBloc', () {
    test('initial state is TransactionListInitial', () {
      final bloc = TransactionListBloc(repository: _FakeRepository([]));
      expect(bloc.state, isA<TransactionListInitial>());
      addTearDown(bloc.close);
    });

    blocTest<TransactionListBloc, TransactionListState>(
      'emits [Loading, Loaded([])] when repository returns empty list',
      build: () => TransactionListBloc(repository: _FakeRepository([])),
      act: (bloc) => bloc.add(const TransactionListFetchRequested()),
      expect: () => [isA<TransactionListLoading>(), isA<TransactionListData>()],
      verify: (bloc) {
        expect((bloc.state as TransactionListData).transactions, isEmpty);
      },
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'emits [Loading, Loaded] with correct transactions on success',
      build: () => TransactionListBloc(repository: _FakeRepository([t1, t2])),
      act: (bloc) => bloc.add(const TransactionListFetchRequested()),
      expect: () => [isA<TransactionListLoading>(), isA<TransactionListData>()],
      verify: (bloc) {
        final state = bloc.state as TransactionListData;
        expect(state.transactions.length, 2);
        expect(state.transactions.first.description, 'Salary');
      },
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'emits [Loading, Error] when repository throws on load',
      build: () => TransactionListBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const TransactionListFetchRequested()),
      expect: () => [
        isA<TransactionListLoading>(),
        isA<TransactionListError>(),
      ],
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'TransactionDeleteRequested removes the item from the loaded list',
      build: () => TransactionListBloc(repository: _FakeRepository([t1, t2])),
      seed: () => TransactionListData([t1, t2]),
      act: (bloc) => bloc.add(const TransactionDeleteRequested('id-1')),
      expect: () => [isA<TransactionListData>()],
      verify: (bloc) {
        final state = bloc.state as TransactionListData;
        expect(state.transactions.length, 1);
        expect(state.transactions.first.id, 'id-2');
      },
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'TransactionDeleteRequested emits Error when delete fails',
      build: () =>
          TransactionListBloc(repository: _FailingDeleteRepository([t1, t2])),
      seed: () => TransactionListData([t1, t2]),
      act: (bloc) => bloc.add(const TransactionDeleteRequested('id-1')),
      expect: () => [isA<TransactionListError>()],
    );
  });
}
