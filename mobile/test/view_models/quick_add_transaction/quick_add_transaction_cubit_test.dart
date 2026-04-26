import 'dart:io';
import 'package:afc/view_models/quick_add_transaction/quick_add_transaction_cubit.dart';
import 'package:afc/view_models/quick_add_transaction/quick_add_transaction_state.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/repositories/template_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afc/services/receipt_service.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAppRefreshBloc extends MockBloc<AppRefreshEvent, AppRefreshState>
    implements AppRefreshBloc {}

class _FakeRepository extends TransactionListRepository {
  @override
  Future<TransactionModel> create({
    required String description,
    required double amount,
    required String type,
    String? category,
    required DateTime occurredAt,
    bool isPassive = false,
    String? investmentId,
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
    bool isPassive = false,
    String? investmentId,
  }) {
    return Future.error(Exception('create failed'));
  }
}

class MockRecurringRepository extends Mock implements RecurringRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockReceiptService extends Mock implements ReceiptService {}

class FakeFile extends Fake implements File {}

void main() {
  late AppRefreshBloc refreshBloc;
  late RecurringRepository recurringRepository;
  late TemplateRepository templateRepository;
  late ReceiptService receiptService;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    refreshBloc = MockAppRefreshBloc();
    recurringRepository = MockRecurringRepository();
    templateRepository = MockTemplateRepository();
    receiptService = MockReceiptService();

    when(() => refreshBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => refreshBloc.state).thenReturn(const AppRefreshState(0));
    when(() => templateRepository.getAll()).thenAnswer((_) async => []);
  });

  group('QuickAddTransactionCubit', () {
    test('initial state is correct', () {
      final cubit = QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      );
      expect(cubit.state.status, QuickAddTransactionStatus.initial);
      expect(cubit.state.description, '');
      expect(cubit.state.amount, '');
      expect(cubit.state.type, TransactionType.expense);
      expect(cubit.state.category, '');
      expect(cubit.state.isValid, false);
      addTearDown(cubit.close);
    });

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'processReceipt emits [processingImage, initial] with extracted data',
      build: () {
        when(() => receiptService.extractFromImage(any())).thenAnswer(
          (_) async =>
              ReceiptExtractionResult(amount: 42.5, merchant: 'Gemini'),
        );
        return QuickAddTransactionCubit(
          repository: _FakeRepository(),
          recurringRepository: recurringRepository,
          templateRepository: templateRepository,
          receiptService: receiptService,
          refreshBloc: refreshBloc,
        );
      },
      act: (cubit) => cubit.processReceipt(File('path/to/image.jpg')),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.status,
          'status',
          QuickAddTransactionStatus.processingImage,
        ),
        isA<QuickAddTransactionState>()
            .having(
              (s) => s.status,
              'status',
              QuickAddTransactionStatus.initial,
            )
            .having((s) => s.amount, 'amount', '42.50')
            .having((s) => s.description, 'description', 'Gemini'),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'processReceipt emits [processingImage, failure] on error',
      build: () {
        when(
          () => receiptService.extractFromImage(any()),
        ).thenThrow(Exception('Extraction failed'));
        return QuickAddTransactionCubit(
          repository: _FakeRepository(),
          recurringRepository: recurringRepository,
          templateRepository: templateRepository,
          receiptService: receiptService,
          refreshBloc: refreshBloc,
        );
      },
      act: (cubit) => cubit.processReceipt(File('path/to/image.jpg')),
      expect: () => [
        isA<QuickAddTransactionState>().having(
          (s) => s.status,
          'status',
          QuickAddTransactionStatus.processingImage,
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
              'Erro ao processar comprovante',
            ),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'descriptionChanged updates description',
      build: () => QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
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
      build: () => QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
      seed: () => const QuickAddTransactionState(description: 'Test'),
      act: (cubit) => cubit.amountChanged('50.50'),
      expect: () => [
        isA<QuickAddTransactionState>()
            .having((s) => s.amount, 'amount', '50.50')
            .having((s) => s.isValid, 'isValid', true),
      ],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'typeChanged updates type',
      build: () => QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
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
      build: () => QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
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
      build: () => QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
      act: (cubit) => cubit.submit(),
      expect: () => [],
    );

    blocTest<QuickAddTransactionCubit, QuickAddTransactionState>(
      'submit emits [loading, success] on successful creation',
      build: () => QuickAddTransactionCubit(
        repository: _FakeRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
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
      build: () => QuickAddTransactionCubit(
        repository: _FailingRepository(),
        recurringRepository: recurringRepository,
        templateRepository: templateRepository,
        receiptService: receiptService,
        refreshBloc: refreshBloc,
      ),
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
              'Erro ao salvar transação',
            ),
      ],
    );
  });
}
