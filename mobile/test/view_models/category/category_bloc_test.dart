import 'package:afc/models/category_model.dart';
import 'package:afc/repositories/category_repository.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockAppRefreshBloc extends MockBloc<AppRefreshEvent, AppRefreshState>
    implements AppRefreshBloc {}

class AppRefreshEventFake extends Fake implements AppRefreshEvent {}

void main() {
  late CategoryRepository repository;
  late AppRefreshBloc refreshBloc;

  setUpAll(() {
    registerFallbackValue(AppRefreshEventFake());
  });

  final List<CategoryModel> testCategories = [
    CategoryModel(id: '1', name: 'Alimentação', createdAt: DateTime(2026)),
    CategoryModel(id: '2', name: 'Transporte', createdAt: DateTime(2026)),
  ];

  setUp(() {
    repository = MockCategoryRepository();
    refreshBloc = MockAppRefreshBloc();

    when(() => refreshBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('CategoryBloc', () {
    test('initial state is CategoryInitial', () {
      final bloc = CategoryBloc(
        repository: repository,
        refreshBloc: refreshBloc,
      );
      expect(bloc.state, isA<CategoryInitial>());
      bloc.close();
    });

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryData] when CategoryFetchRequested succeeds',
      build: () {
        when(() => repository.getAll()).thenAnswer((_) async => testCategories);
        return CategoryBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(const CategoryFetchRequested()),
      expect: () => [isA<CategoryLoading>(), CategoryData(testCategories)],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryData] with new item when CategoryCreateRequested succeeds',
      seed: () => CategoryData(testCategories),
      build: () {
        final newCategory = CategoryModel(
          id: '3',
          name: 'Lazer',
          createdAt: DateTime(2026),
        );
        when(
          () => repository.create(any()),
        ).thenAnswer((_) async => newCategory);
        when(() => refreshBloc.add(any())).thenReturn(null);
        return CategoryBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(const CategoryCreateRequested('Lazer')),
      expect: () => [
        CategoryData([
          ...testCategories,
          CategoryModel(id: '3', name: 'Lazer', createdAt: DateTime(2026)),
        ]),
      ],
      verify: (_) {
        verify(() => refreshBloc.add(any())).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryData] with updated item when CategoryUpdateRequested succeeds',
      seed: () => CategoryData(testCategories),
      build: () {
        final updated = CategoryModel(
          id: '1',
          name: 'Comida',
          createdAt: DateTime(2026),
        );
        when(
          () => repository.update(any(), any()),
        ).thenAnswer((_) async => updated);
        when(() => refreshBloc.add(any())).thenReturn(null);
        return CategoryBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) =>
          bloc.add(const CategoryUpdateRequested(id: '1', name: 'Comida')),
      expect: () => [
        CategoryData([
          CategoryModel(id: '1', name: 'Comida', createdAt: DateTime(2026)),
          CategoryModel(id: '2', name: 'Transporte', createdAt: DateTime(2026)),
        ]),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryData] without item when CategoryDeleteRequested succeeds',
      seed: () => CategoryData(testCategories),
      build: () {
        when(() => repository.delete(any())).thenAnswer((_) async => {});
        when(() => refreshBloc.add(any())).thenReturn(null);
        return CategoryBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(const CategoryDeleteRequested('1')),
      expect: () => [
        CategoryData([
          CategoryModel(id: '2', name: 'Transporte', createdAt: DateTime(2026)),
        ]),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryError] when fetch fails',
      build: () {
        when(() => repository.getAll()).thenThrow(Exception('error'));
        return CategoryBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(const CategoryFetchRequested()),
      expect: () => [
        isA<CategoryLoading>(),
        const CategoryError('Erro ao carregar categorias'),
      ],
    );
  });
}
