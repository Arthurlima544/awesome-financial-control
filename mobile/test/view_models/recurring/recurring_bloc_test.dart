import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/view_models/recurring/recurring_bloc.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}

class MockAppRefreshBloc extends MockBloc<AppRefreshEvent, AppRefreshState>
    implements AppRefreshBloc {}

class RecurringTransactionModelFake extends Fake
    implements RecurringTransactionModel {}

class AppRefreshEventFake extends Fake implements AppRefreshEvent {}

void main() {
  late RecurringRepository repository;
  late AppRefreshBloc refreshBloc;
  late RecurringBloc bloc;

  setUpAll(() {
    registerFallbackValue(RecurringTransactionModelFake());
    registerFallbackValue(AppRefreshEventFake());
  });

  final testRules = [
    RecurringTransactionModel(
      id: '1',
      description: 'Rent',
      amount: 1000.0,
      type: TransactionType.expense,
      frequency: RecurrenceFrequency.monthly,
      nextDueAt: DateTime(2026, 1, 1),
      active: true,
    ),
  ];

  setUp(() {
    repository = MockRecurringRepository();
    refreshBloc = MockAppRefreshBloc();
    when(() => refreshBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => refreshBloc.state).thenReturn(const AppRefreshState(0));
    bloc = RecurringBloc(repository, refreshBloc);
  });

  tearDown(() {
    bloc.close();
  });

  group('RecurringBloc', () {
    test('initial state is RecurringInitial', () {
      expect(bloc.state, isA<RecurringInitial>());
    });

    blocTest<RecurringBloc, RecurringState>(
      'emits [RecurringLoading, RecurringLoaded] when LoadRecurring succeeds',
      build: () {
        when(() => repository.getAll()).thenAnswer((_) async => testRules);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadRecurring()),
      expect: () => [
        isA<RecurringLoading>(),
        isA<RecurringLoaded>().having((s) => s.rules, 'rules', testRules),
      ],
    );

    blocTest<RecurringBloc, RecurringState>(
      'emits [RecurringLoading, RecurringError] when LoadRecurring fails',
      build: () {
        when(() => repository.getAll()).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadRecurring()),
      expect: () => [
        isA<RecurringLoading>(),
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          'Erro ao carregar transações recorrentes',
        ),
      ],
    );

    blocTest<RecurringBloc, RecurringState>(
      'calls update and triggers refresh on ToggleRecurringActive',
      build: () {
        when(
          () => repository.update(any()),
        ).thenAnswer((_) async => testRules.first);
        return bloc;
      },
      act: (bloc) => bloc.add(ToggleRecurringActive(testRules.first)),
      verify: (_) {
        verify(() => repository.update(any())).called(1);
        verify(() => refreshBloc.add(any(that: isA<DataChanged>()))).called(1);
      },
    );

    blocTest<RecurringBloc, RecurringState>(
      'emits RecurringError when ToggleRecurringActive fails',
      build: () {
        when(() => repository.update(any())).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(ToggleRecurringActive(testRules.first)),
      expect: () => [
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          'Erro ao atualizar transação recorrente',
        ),
      ],
    );

    blocTest<RecurringBloc, RecurringState>(
      'calls delete and triggers refresh on DeleteRecurring',
      build: () {
        when(() => repository.delete(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRecurring('1')),
      verify: (_) {
        verify(() => repository.delete('1')).called(1);
        verify(() => refreshBloc.add(any(that: isA<DataChanged>()))).called(1);
      },
    );

    blocTest<RecurringBloc, RecurringState>(
      'emits RecurringError when DeleteRecurring fails',
      build: () {
        when(() => repository.delete(any())).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRecurring('1')),
      expect: () => [
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          'Erro ao excluir transação recorrente',
        ),
      ],
    );
  });
}
