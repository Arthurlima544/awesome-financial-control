import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/models/category_model.dart';
import 'package:afc/repositories/category_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends CategoryRepository {
  _FakeRepository(this._categories);

  final List<CategoryModel> _categories;

  @override
  Future<List<CategoryModel>> getAll() async => _categories;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<CategoryModel> update(String id, String name) async {
    final c = _categories.firstWhere((c) => c.id == id);
    return CategoryModel(id: c.id, name: name, createdAt: c.createdAt);
  }
}

class _FailingRepository extends CategoryRepository {
  @override
  Future<List<CategoryModel>> getAll() => Future.error(Exception('network'));

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));

  @override
  Future<CategoryModel> update(String id, String name) =>
      Future.error(Exception('update failed'));
}

class _FailingDeleteRepository extends CategoryRepository {
  _FailingDeleteRepository(this._categories);

  final List<CategoryModel> _categories;

  @override
  Future<List<CategoryModel>> getAll() async => _categories;

  @override
  Future<void> delete(String id) => Future.error(Exception('delete failed'));

  @override
  Future<CategoryModel> update(String id, String name) async =>
      _categories.first;
}

class _FailingUpdateRepository extends CategoryRepository {
  _FailingUpdateRepository(this._categories);

  final List<CategoryModel> _categories;

  @override
  Future<List<CategoryModel>> getAll() async => _categories;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<CategoryModel> update(String id, String name) =>
      Future.error(Exception('update failed'));
}

class _UpdateRepository extends CategoryRepository {
  _UpdateRepository(this._categories, this._updated);

  final List<CategoryModel> _categories;
  final CategoryModel _updated;

  @override
  Future<List<CategoryModel>> getAll() async => _categories;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<CategoryModel> update(String id, String name) async => _updated;
}

void main() {
  final c1 = CategoryModel(
    id: 'id-1',
    name: 'Food',
    createdAt: DateTime(2026, 4, 1),
  );

  final c2 = CategoryModel(
    id: 'id-2',
    name: 'Transport',
    createdAt: DateTime(2026, 4, 2),
  );

  group('CategoryBloc', () {
    test('initial state is CategoryInitial', () {
      final bloc = CategoryBloc(repository: _FakeRepository([]));
      expect(bloc.state, isA<CategoryInitial>());
      addTearDown(bloc.close);
    });

    blocTest<CategoryBloc, CategoryState>(
      'emits [Loading, Data([])] when repository returns empty list',
      build: () => CategoryBloc(repository: _FakeRepository([])),
      act: (bloc) => bloc.add(const CategoryFetchRequested()),
      expect: () => [isA<CategoryLoading>(), isA<CategoryData>()],
      verify: (bloc) {
        expect((bloc.state as CategoryData).categories, isEmpty);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [Loading, Data] with correct categories on success',
      build: () => CategoryBloc(repository: _FakeRepository([c1, c2])),
      act: (bloc) => bloc.add(const CategoryFetchRequested()),
      expect: () => [isA<CategoryLoading>(), isA<CategoryData>()],
      verify: (bloc) {
        final state = bloc.state as CategoryData;
        expect(state.categories.length, 2);
        expect(state.categories.first.name, 'Food');
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [Loading, Error] when repository throws on fetch',
      build: () => CategoryBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const CategoryFetchRequested()),
      expect: () => [isA<CategoryLoading>(), isA<CategoryError>()],
    );

    blocTest<CategoryBloc, CategoryState>(
      'CategoryDeleteRequested removes the item from the loaded list',
      build: () => CategoryBloc(repository: _FakeRepository([c1, c2])),
      seed: () => CategoryData([c1, c2]),
      act: (bloc) => bloc.add(const CategoryDeleteRequested('id-1')),
      expect: () => [isA<CategoryData>()],
      verify: (bloc) {
        final state = bloc.state as CategoryData;
        expect(state.categories.length, 1);
        expect(state.categories.first.id, 'id-2');
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'CategoryDeleteRequested emits Error when delete fails',
      build: () => CategoryBloc(repository: _FailingDeleteRepository([c1, c2])),
      seed: () => CategoryData([c1, c2]),
      act: (bloc) => bloc.add(const CategoryDeleteRequested('id-1')),
      expect: () => [isA<CategoryError>()],
    );

    blocTest<CategoryBloc, CategoryState>(
      'CategoryUpdateRequested replaces the updated item in the list',
      build: () {
        final updated = CategoryModel(
          id: 'id-1',
          name: 'Groceries',
          createdAt: c1.createdAt,
        );
        return CategoryBloc(repository: _UpdateRepository([c1, c2], updated));
      },
      seed: () => CategoryData([c1, c2]),
      act: (bloc) => bloc.add(
        const CategoryUpdateRequested(id: 'id-1', name: 'Groceries'),
      ),
      expect: () => [isA<CategoryData>()],
      verify: (bloc) {
        final state = bloc.state as CategoryData;
        expect(state.categories.length, 2);
        expect(state.categories.first.name, 'Groceries');
        expect(state.categories.last.name, 'Transport');
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'CategoryUpdateRequested emits Error when update fails',
      build: () => CategoryBloc(repository: _FailingUpdateRepository([c1, c2])),
      seed: () => CategoryData([c1, c2]),
      act: (bloc) => bloc.add(
        const CategoryUpdateRequested(id: 'id-1', name: 'Groceries'),
      ),
      expect: () => [isA<CategoryError>()],
    );

    blocTest<CategoryBloc, CategoryState>(
      'CategoryDeleteRequested does nothing when state is not CategoryData',
      build: () => CategoryBloc(repository: _FakeRepository([c1])),
      act: (bloc) => bloc.add(const CategoryDeleteRequested('id-1')),
      expect: () => [],
    );
  });
}
