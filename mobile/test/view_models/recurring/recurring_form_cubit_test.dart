import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/view_models/recurring/recurring_form_cubit.dart';
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

  setUpAll(() {
    registerFallbackValue(RecurringTransactionModelFake());
    registerFallbackValue(AppRefreshEventFake());
  });

  final testInitial = RecurringTransactionModel(
    id: '1',
    description: 'Rent',
    amount: 1000.0,
    type: TransactionType.expense,
    frequency: RecurrenceFrequency.monthly,
    nextDueAt: DateTime(2026, 1, 1),
    active: true,
  );

  setUp(() {
    repository = MockRecurringRepository();
    refreshBloc = MockAppRefreshBloc();
  });

  group('RecurringFormCubit', () {
    test('initial state is empty when no initial model is provided', () {
      final cubit = RecurringFormCubit(
        repository: repository,
        refreshBloc: refreshBloc,
      );
      expect(cubit.state.description, '');
      expect(cubit.state.amount, '');
      expect(cubit.state.active, true);
      cubit.close();
    });

    test('initial state is pre-filled when initial model is provided', () {
      final cubit = RecurringFormCubit(
        initial: testInitial,
        repository: repository,
        refreshBloc: refreshBloc,
      );
      expect(cubit.state.description, 'Rent');
      expect(cubit.state.amount, '1000.0');
      expect(cubit.state.active, true);
      cubit.close();
    });

    blocTest<RecurringFormCubit, RecurringFormState>(
      'emits correct state on field changes',
      build: () =>
          RecurringFormCubit(repository: repository, refreshBloc: refreshBloc),
      act: (cubit) {
        cubit.onDescriptionChanged('New description');
        cubit.onAmountChanged('500');
        cubit.onTypeChanged(TransactionType.income);
        cubit.onActiveChanged(false);
      },
      expect: () => [
        isA<RecurringFormState>().having(
          (s) => s.description,
          'description',
          'New description',
        ),
        isA<RecurringFormState>().having((s) => s.amount, 'amount', '500'),
        isA<RecurringFormState>().having(
          (s) => s.type,
          'type',
          TransactionType.income,
        ),
        isA<RecurringFormState>().having((s) => s.active, 'active', false),
      ],
    );

    blocTest<RecurringFormCubit, RecurringFormState>(
      'submits successfully and triggers refresh',
      build: () {
        when(
          () => repository.create(any()),
        ).thenAnswer((_) async => testInitial);
        return RecurringFormCubit(
          repository: repository,
          refreshBloc: refreshBloc,
        );
      },
      act: (cubit) async {
        cubit.onDescriptionChanged('Rent');
        cubit.onAmountChanged('1000');
        await cubit.submit();
      },
      expect: () => [
        isA<RecurringFormState>().having(
          (s) => s.description,
          'description',
          'Rent',
        ),
        isA<RecurringFormState>().having((s) => s.amount, 'amount', '1000'),
        isA<RecurringFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<RecurringFormState>().having((s) => s.isSuccess, 'isSuccess', true),
        isA<RecurringFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
      verify: (_) {
        verify(() => repository.create(any())).called(1);
        verify(() => refreshBloc.add(any(that: isA<DataChanged>()))).called(1);
      },
    );

    blocTest<RecurringFormCubit, RecurringFormState>(
      'emits error state on submission failure',
      build: () {
        when(() => repository.create(any())).thenThrow(Exception('error'));
        return RecurringFormCubit(
          repository: repository,
          refreshBloc: refreshBloc,
        );
      },
      act: (cubit) async {
        cubit.onDescriptionChanged('Rent');
        cubit.onAmountChanged('1000');
        await cubit.submit();
      },
      expect: () => [
        isA<RecurringFormState>().having(
          (s) => s.description,
          'description',
          'Rent',
        ),
        isA<RecurringFormState>().having((s) => s.amount, 'amount', '1000'),
        isA<RecurringFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<RecurringFormState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Erro ao salvar transação recorrente',
        ),
        isA<RecurringFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          false,
        ),
      ],
    );
  });
}
