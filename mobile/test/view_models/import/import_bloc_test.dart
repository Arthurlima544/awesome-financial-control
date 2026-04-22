import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afc/view_models/import/import_bloc.dart';
import 'package:afc/view_models/import/import_event.dart';
import 'package:afc/view_models/import/import_state.dart';
import 'package:afc/services/import_parser_service.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/models/import_candidate_model.dart';
import 'package:afc/models/transaction_model.dart';

class MockImportParserService extends Mock implements ImportParserService {}

class MockTransactionListRepository extends Mock
    implements TransactionListRepository {}

class MockAppRefreshBloc extends MockBloc<AppRefreshEvent, AppRefreshState>
    implements AppRefreshBloc {}

void main() {
  late ImportBloc importBloc;
  late MockImportParserService mockParserService;
  late MockTransactionListRepository mockRepository;
  late MockAppRefreshBloc mockRefreshBloc;

  setUpAll(() {
    registerFallbackValue(ImportBank.generic);
    registerFallbackValue(ImportType.ofx);
    registerFallbackValue(DataChanged());
  });

  setUp(() {
    mockParserService = MockImportParserService();
    mockRepository = MockTransactionListRepository();
    mockRefreshBloc = MockAppRefreshBloc();

    // Stub default state for mock bloc
    when(() => mockRefreshBloc.state).thenReturn(const AppRefreshState(0));

    importBloc = ImportBloc(
      parserService: mockParserService,
      repository: mockRepository,
      refreshBloc: mockRefreshBloc,
    );
  });

  tearDown(() {
    importBloc.close();
  });

  group('ImportBloc', () {
    test('initial state is correct', () {
      expect(importBloc.state, const ImportState());
    });

    blocTest<ImportBloc, ImportState>(
      'emits [bank updated] when ImportBankSelected is added',
      build: () => importBloc,
      act: (bloc) => bloc.add(const ImportBankSelected(ImportBank.nubank)),
      expect: () => [const ImportState(bank: ImportBank.nubank)],
    );

    blocTest<ImportBloc, ImportState>(
      'emits [type updated] when ImportTypeSelected is added',
      build: () => importBloc,
      act: (bloc) => bloc.add(const ImportTypeSelected(ImportType.fatura)),
      expect: () => [const ImportState(type: ImportType.fatura)],
    );

    final candidates = [
      ImportCandidateModel(
        description: 'Test',
        amount: 10.0,
        type: TransactionType.expense,
        occurredAt: DateTime(2026, 1, 1),
      ),
    ];

    blocTest<ImportBloc, ImportState>(
      'emits [parsing, reviewing] when file is selected successfully',
      build: () {
        when(
          () => mockParserService.parse(any(), any(), any()),
        ).thenReturn(candidates);
        when(() => mockRepository.getAll()).thenAnswer((_) async => []);
        return importBloc;
      },
      act: (bloc) => bloc.add(const ImportFileSelected('content')),
      expect: () => [
        const ImportState(status: ImportStatus.parsing),
        ImportState(
          status: ImportStatus.reviewing,
          candidates: candidates
              .map((c) => c.copyWith(isSelected: true, isDuplicate: false))
              .toList(),
        ),
      ],
    );

    blocTest<ImportBloc, ImportState>(
      'marks candidates as duplicate if they exist in repository',
      build: () {
        when(
          () => mockParserService.parse(any(), any(), any()),
        ).thenReturn(candidates);
        when(() => mockRepository.getAll()).thenAnswer(
          (_) async => [
            TransactionModel(
              id: '1',
              description: 'Test',
              amount: 10.0,
              type: TransactionType.expense,
              occurredAt: DateTime(2026, 1, 1),
            ),
          ],
        );
        return importBloc;
      },
      act: (bloc) => bloc.add(const ImportFileSelected('content')),
      expect: () => [
        const ImportState(status: ImportStatus.parsing),
        ImportState(
          status: ImportStatus.reviewing,
          candidates: candidates
              .map((c) => c.copyWith(isSelected: false, isDuplicate: true))
              .toList(),
        ),
      ],
    );

    blocTest<ImportBloc, ImportState>(
      'submits selected candidates successfully',
      build: () {
        when(
          () => mockRepository.createBulk(any()),
        ).thenAnswer((_) async => []);
        return importBloc;
      },
      seed: () => ImportState(
        status: ImportStatus.reviewing,
        candidates: candidates
            .map((c) => c.copyWith(isSelected: true))
            .toList(),
      ),
      act: (bloc) => bloc.add(const ImportSubmitRequested()),
      expect: () => [
        isA<ImportState>().having(
          (s) => s.status,
          'status',
          ImportStatus.submitting,
        ),
        isA<ImportState>().having(
          (s) => s.status,
          'status',
          ImportStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.createBulk(any())).called(1);
        verify(() => mockRefreshBloc.add(any())).called(1);
      },
    );
  });
}
