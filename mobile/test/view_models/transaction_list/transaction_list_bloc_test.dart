import 'package:afc/view_models/transaction_list/transaction_list_bloc.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends TransactionListRepository {
  _FakeRepository(this._transactions);

  final List<TransactionModel> _transactions;

  @override
  Future<List<TransactionModel>> getAll() async => _transactions;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) async {
    final t = _transactions.firstWhere((t) => t.id == id);
    return TransactionModel(
      id: t.id,
      description: description,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      category: category,
      occurredAt: occurredAt,
    );
  }
}

class _FailingRepository extends TransactionListRepository {
  @override
  Future<List<TransactionModel>> getAll() =>
      Future.error(Exception('network error'));

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));

  @override
  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) => Future.error(Exception('update failed'));
}

class _FailingDeleteRepository extends TransactionListRepository {
  _FailingDeleteRepository(this._transactions);

  final List<TransactionModel> _transactions;

  @override
  Future<List<TransactionModel>> getAll() async => _transactions;

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));

  @override
  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) async => _transactions.first;
}

class _FailingUpdateRepository extends TransactionListRepository {
  _FailingUpdateRepository(this._transactions);

  final List<TransactionModel> _transactions;

  @override
  Future<List<TransactionModel>> getAll() async => _transactions;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) => Future.error(Exception('update failed'));
}

class _UpdateRepository extends TransactionListRepository {
  _UpdateRepository(this._transactions, this._updated);

  final List<TransactionModel> _transactions;
  final TransactionModel _updated;

  @override
  Future<List<TransactionModel>> getAll() async => _transactions;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<TransactionModel> update(
    String id, {
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) async => _updated;
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

    blocTest<TransactionListBloc, TransactionListState>(
      'TransactionUpdateRequested replaces the updated item in the list',
      build: () {
        final updated = TransactionModel(
          id: 'id-1',
          description: 'Updated Salary',
          amount: 6000.0,
          type: TransactionType.income,
          occurredAt: DateTime(2026, 4, 1),
        );
        return TransactionListBloc(
          repository: _UpdateRepository([t1, t2], updated),
        );
      },
      seed: () => TransactionListData([t1, t2]),
      act: (bloc) => bloc.add(
        TransactionUpdateRequested(
          id: 'id-1',
          description: 'Updated Salary',
          amount: 6000.0,
          type: 'income',
          occurredAt: DateTime(2026, 4, 1),
        ),
      ),
      expect: () => [isA<TransactionListData>()],
      verify: (bloc) {
        final state = bloc.state as TransactionListData;
        expect(state.transactions.length, 2);
        expect(state.transactions.first.description, 'Updated Salary');
        expect(state.transactions.first.amount, 6000.0);
        expect(state.transactions.last.id, 'id-2');
      },
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'TransactionUpdateRequested emits Error when update fails',
      build: () =>
          TransactionListBloc(repository: _FailingUpdateRepository([t1, t2])),
      seed: () => TransactionListData([t1, t2]),
      act: (bloc) => bloc.add(
        TransactionUpdateRequested(
          id: 'id-1',
          description: 'Updated',
          amount: 100.0,
          type: 'expense',
          occurredAt: DateTime(2026, 4, 1),
        ),
      ),
      expect: () => [isA<TransactionListError>()],
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'TransactionUpdateRequested does nothing when state is not TransactionListData',
      build: () => TransactionListBloc(repository: _FakeRepository([t1])),
      act: (bloc) => bloc.add(
        TransactionUpdateRequested(
          id: 'id-1',
          description: 'Updated',
          amount: 100.0,
          type: 'expense',
          occurredAt: DateTime(2026, 4, 1),
        ),
      ),
      expect: () => [],
    );
  });
}
