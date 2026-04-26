import 'package:afc/models/limit_model.dart';
import 'package:afc/repositories/limit_list_repository.dart';
import 'package:afc/view_models/limit_list/limit_list_bloc.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLimitListRepository extends Mock implements LimitListRepository {}

class MockAppRefreshBloc extends MockBloc<AppRefreshEvent, AppRefreshState>
    implements AppRefreshBloc {}

class AppRefreshEventFake extends Fake implements AppRefreshEvent {}

void main() {
  late LimitListRepository repository;
  late AppRefreshBloc refreshBloc;

  setUpAll(() {
    registerFallbackValue(AppRefreshEventFake());
  });

  final List<LimitModel> testLimits = [
    LimitModel(
      id: '1',
      categoryName: 'Alimentação',
      amount: 1000.0,
      createdAt: DateTime(2026),
    ),
    LimitModel(
      id: '2',
      categoryName: 'Transporte',
      amount: 500.0,
      createdAt: DateTime(2026),
    ),
  ];

  setUp(() {
    repository = MockLimitListRepository();
    refreshBloc = MockAppRefreshBloc();

    when(() => refreshBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('LimitListBloc', () {
    test('initial state is LimitListInitial', () {
      final bloc = LimitListBloc(
        repository: repository,
        refreshBloc: refreshBloc,
      );
      expect(bloc.state, isA<LimitListInitial>());
      bloc.close();
    });

    blocTest<LimitListBloc, LimitListState>(
      'emits [LimitListLoading, LimitListData] when LimitListFetchRequested succeeds',
      build: () {
        when(() => repository.getAll()).thenAnswer((_) async => testLimits);
        return LimitListBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(const LimitListFetchRequested()),
      expect: () => [isA<LimitListLoading>(), LimitListData(testLimits)],
    );

    blocTest<LimitListBloc, LimitListState>(
      'emits [LimitListData] with new item when LimitListCreateRequested succeeds',
      seed: () => LimitListData(testLimits),
      build: () {
        final newLimit = LimitModel(
          id: '3',
          categoryName: 'Lazer',
          amount: 300.0,
          createdAt: DateTime(2026),
        );
        when(
          () => repository.create(any(), any()),
        ).thenAnswer((_) async => newLimit);
        when(() => refreshBloc.add(any())).thenReturn(null);
        return LimitListBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(
        const LimitListCreateRequested(categoryId: '3', amount: 300.0),
      ),
      expect: () => [
        LimitListData([
          ...testLimits,
          LimitModel(
            id: '3',
            categoryName: 'Lazer',
            amount: 300.0,
            createdAt: DateTime(2026),
          ),
        ]),
      ],
      verify: (_) {
        verify(() => refreshBloc.add(any())).called(1);
      },
    );

    blocTest<LimitListBloc, LimitListState>(
      'emits [LimitListError] when fetch fails',
      build: () {
        when(() => repository.getAll()).thenThrow(Exception('error'));
        return LimitListBloc(repository: repository, refreshBloc: refreshBloc);
      },
      act: (bloc) => bloc.add(const LimitListFetchRequested()),
      expect: () => [
        isA<LimitListLoading>(),
        const LimitListError('Erro ao carregar limites'),
      ],
    );
  });
}
