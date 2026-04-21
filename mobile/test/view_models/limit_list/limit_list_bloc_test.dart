import 'package:afc/view_models/limit_list/limit_list_bloc.dart';
import 'package:afc/models/limit_model.dart';
import 'package:afc/repositories/limit_list_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends LimitListRepository {
  _FakeRepository(this._limits);

  final List<LimitModel> _limits;

  @override
  Future<List<LimitModel>> getAll() async => _limits;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<LimitModel> update(String id, double amount) async {
    final l = _limits.firstWhere((l) => l.id == id);
    return LimitModel(
      id: l.id,
      categoryName: l.categoryName,
      amount: amount,
      createdAt: l.createdAt,
    );
  }
}

class _FailingRepository extends LimitListRepository {
  @override
  Future<List<LimitModel>> getAll() => Future.error(Exception('network'));

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));

  @override
  Future<LimitModel> update(String id, double amount) =>
      Future.error(Exception('update failed'));
}

class _FailingDeleteRepository extends LimitListRepository {
  _FailingDeleteRepository(this._limits);

  final List<LimitModel> _limits;

  @override
  Future<List<LimitModel>> getAll() async => _limits;

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));

  @override
  Future<LimitModel> update(String id, double amount) async => _limits.first;
}

class _FailingUpdateRepository extends LimitListRepository {
  _FailingUpdateRepository(this._limits);

  final List<LimitModel> _limits;

  @override
  Future<List<LimitModel>> getAll() async => _limits;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<LimitModel> update(String id, double amount) =>
      Future.error(Exception('update failed'));
}

class _UpdateRepository extends LimitListRepository {
  _UpdateRepository(this._limits, this._updated);

  final List<LimitModel> _limits;
  final LimitModel _updated;

  @override
  Future<List<LimitModel>> getAll() async => _limits;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<LimitModel> update(String id, double amount) async => _updated;
}

void main() {
  final l1 = LimitModel(
    id: 'id-1',
    categoryName: 'Food',
    amount: 500.0,
    createdAt: DateTime(2026, 4, 1),
  );

  final l2 = LimitModel(
    id: 'id-2',
    categoryName: 'Transport',
    amount: 200.0,
    createdAt: DateTime(2026, 4, 2),
  );

  group('LimitListBloc', () {
    test('initial state is LimitListInitial', () {
      final bloc = LimitListBloc(repository: _FakeRepository([]));
      expect(bloc.state, isA<LimitListInitial>());
      addTearDown(bloc.close);
    });

    blocTest<LimitListBloc, LimitListState>(
      'emits [Loading, Data([])] when repository returns empty list',
      build: () => LimitListBloc(repository: _FakeRepository([])),
      act: (bloc) => bloc.add(const LimitListFetchRequested()),
      expect: () => [isA<LimitListLoading>(), isA<LimitListData>()],
      verify: (bloc) {
        expect((bloc.state as LimitListData).limits, isEmpty);
      },
    );

    blocTest<LimitListBloc, LimitListState>(
      'emits [Loading, Data] with correct limits on success',
      build: () => LimitListBloc(repository: _FakeRepository([l1, l2])),
      act: (bloc) => bloc.add(const LimitListFetchRequested()),
      expect: () => [isA<LimitListLoading>(), isA<LimitListData>()],
      verify: (bloc) {
        final state = bloc.state as LimitListData;
        expect(state.limits.length, 2);
        expect(state.limits.first.categoryName, 'Food');
      },
    );

    blocTest<LimitListBloc, LimitListState>(
      'emits [Loading, Error] when repository throws on fetch',
      build: () => LimitListBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const LimitListFetchRequested()),
      expect: () => [isA<LimitListLoading>(), isA<LimitListError>()],
    );

    blocTest<LimitListBloc, LimitListState>(
      'LimitListDeleteRequested removes the item from the loaded list',
      build: () => LimitListBloc(repository: _FakeRepository([l1, l2])),
      seed: () => LimitListData([l1, l2]),
      act: (bloc) => bloc.add(const LimitListDeleteRequested('id-1')),
      expect: () => [isA<LimitListData>()],
      verify: (bloc) {
        final state = bloc.state as LimitListData;
        expect(state.limits.length, 1);
        expect(state.limits.first.id, 'id-2');
      },
    );

    blocTest<LimitListBloc, LimitListState>(
      'LimitListDeleteRequested emits Error when delete fails',
      build: () =>
          LimitListBloc(repository: _FailingDeleteRepository([l1, l2])),
      seed: () => LimitListData([l1, l2]),
      act: (bloc) => bloc.add(const LimitListDeleteRequested('id-1')),
      expect: () => [isA<LimitListError>()],
    );

    blocTest<LimitListBloc, LimitListState>(
      'LimitListUpdateRequested replaces the updated item in the list',
      build: () {
        final updated = LimitModel(
          id: 'id-1',
          categoryName: 'Food',
          amount: 800.0,
          createdAt: l1.createdAt,
        );
        return LimitListBloc(repository: _UpdateRepository([l1, l2], updated));
      },
      seed: () => LimitListData([l1, l2]),
      act: (bloc) =>
          bloc.add(const LimitListUpdateRequested(id: 'id-1', amount: 800.0)),
      expect: () => [isA<LimitListData>()],
      verify: (bloc) {
        final state = bloc.state as LimitListData;
        expect(state.limits.length, 2);
        expect(state.limits.first.amount, 800.0);
        expect(state.limits.last.categoryName, 'Transport');
      },
    );

    blocTest<LimitListBloc, LimitListState>(
      'LimitListUpdateRequested emits Error when update fails',
      build: () =>
          LimitListBloc(repository: _FailingUpdateRepository([l1, l2])),
      seed: () => LimitListData([l1, l2]),
      act: (bloc) =>
          bloc.add(const LimitListUpdateRequested(id: 'id-1', amount: 800.0)),
      expect: () => [isA<LimitListError>()],
    );

    blocTest<LimitListBloc, LimitListState>(
      'LimitListDeleteRequested does nothing when state is not LimitListData',
      build: () => LimitListBloc(repository: _FakeRepository([l1])),
      act: (bloc) => bloc.add(const LimitListDeleteRequested('id-1')),
      expect: () => [],
    );
  });
}
