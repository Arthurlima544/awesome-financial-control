import 'package:afc/view_models/quick_add_transaction/quick_add_transaction_cubit.dart';
import 'package:afc/view_models/quick_add_transaction/quick_add_transaction_state.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends TransactionListRepository {
  @override
  Future<TransactionModel> create({
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) async {
    return TransactionModel(
      id: 'new-id',
      description: description,
      amount: amount,
      type: type == 'INCOME' ? TransactionType.income : TransactionType.expense,
      category: category,
      occurredAt: occurredAt,
    );
  }
}

class _FailingRepository extends TransactionListRepository {
  @override
  Future<TransactionModel> create({
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
  }) {
    return Future.error(Exception('create failed'));
  }
}

void main() {
  group('QuickAddTransactionCubit', () {
    test('initial state is correct', () {
      final cubit = QuickAddTransactionCubit(repository: _FakeRepository());
      expect(cubit.state.status, QuickAddTransactionStatus.initial);
      expect(cubit.state.description, '');
      expect(cubit.state.amount, '');
      expect(cubit.state.type, TransactionType.expense);
      expect(cubit.state.category, '');
      expect(cubit.state.isValid, false);
      addTearDown(cubit.close);
    });

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'descriptionChanged updates description',
      build: () => QuickAddTransactionCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.descriptionChanged('Test desc'),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.description,
          'description',
          'Test desc',
        ),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'amountChanged updates amount and validity',
      build: () => QuickAddTransactionCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.amountChanged('50.50'),
      expect: () => [
        isA<QuickAddTransactionState>()
            .having((s) => s.amount, 'amount', '50.50')
            .having((s) => s.isValid, 'isValid', true),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'typeChanged updates type',
      build: () => QuickAddTransactionCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.typeChanged(TransactionType.income),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.type,
          'type',
          TransactionType.income,
        ),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'categoryChanged updates category',
      build: () => QuickAddTransactionCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.categoryChanged('Food'),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.category,
          'category',
          'Food',
        ),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'submit does nothing if state is invalid',
      build: () => QuickAddTransactionCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.submit(),
      expect: () => [],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'submit emits [loading, success] on successful creation',
      build: () => QuickAddTransactionCubit(repository: _FakeRepository()),
      seed: () =>
          const QuickAddTransactionState(amount: '10.0', description: 'Coffee'),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.status,
          'status',
          QuickAddTransactionStatus.loading,
        ),
        isA<QuickAddTransactionState>().having(
          (s) => s.status,
          'status',
          QuickAddTransactionStatus.success,
        ),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'submit emits [loading, failure] on error',
      build: () => QuickAddTransactionCubit(repository: _FailingRepository()),
      seed: () =>
          const QuickAddTransactionState(amount: '10.0', description: 'Coffee'),
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.status,
          'status',
          QuickAddTransactionStatus.loading,
        ),
        isA<QuickAddTransactionState>()
            .having(
              (s) => s.status,
              'status',
              QuickAddTransactionStatus.failure,
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Exception: create failed',
            ),
      ],
    );
  });
}
