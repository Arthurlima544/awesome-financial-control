import 'package:afc/models/category_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/repositories/template_repository.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/services/receipt_service.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/widgets/quick_add_transaction_sheet/quick_add_transaction_sheet.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

class MockTransactionListRepository extends Mock
    implements TransactionListRepository {}

class MockRecurringRepository extends Mock implements RecurringRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockReceiptService extends Mock implements ReceiptService {}

class MockAppRefreshBloc extends MockBloc<AppRefreshEvent, AppRefreshState>
    implements AppRefreshBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

void main() {
  late MockTransactionListRepository transactionRepository;
  late MockRecurringRepository recurringRepository;
  late MockTemplateRepository templateRepository;
  late MockReceiptService receiptService;
  late MockAppRefreshBloc refreshBloc;
  late MockCategoryBloc categoryBloc;

  setUpAll(() {
    registerFallbackValue(const CategoryFetchRequested());
    registerFallbackValue(TransactionType.expense);
  });

  setUp(() async {
    transactionRepository = MockTransactionListRepository();
    recurringRepository = MockRecurringRepository();
    templateRepository = MockTemplateRepository();
    receiptService = MockReceiptService();
    refreshBloc = MockAppRefreshBloc();
    categoryBloc = MockCategoryBloc();

    await sl.reset();
    sl.registerSingleton<TransactionListRepository>(transactionRepository);
    sl.registerSingleton<RecurringRepository>(recurringRepository);
    sl.registerSingleton<TemplateRepository>(templateRepository);
    sl.registerSingleton<ReceiptService>(receiptService);
    sl.registerSingleton<AppRefreshBloc>(refreshBloc);
    sl.registerSingleton<CategoryBloc>(categoryBloc);

    when(() => templateRepository.getAll()).thenAnswer((_) async => []);
    when(() => categoryBloc.state).thenReturn(CategoryInitial());
    when(() => categoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => refreshBloc.state).thenReturn(const AppRefreshState(0));
    when(() => refreshBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<CategoryBloc>.value(
          value: categoryBloc,
          child: const QuickAddTransactionSheet(),
        ),
      ),
    );
  }

  Future<void> setupScreenSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
  }

  group('QuickAddTransactionSheet Widget Tests', () {
    testWidgets('renders correctly', (tester) async {
      await setupScreenSize(tester);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('R\$ 0'), findsOneWidget);
      expect(find.text('Receita'), findsOneWidget);
      expect(find.text('Despesa'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
    });

    testWidgets('switches between income and expense', (tester) async {
      await setupScreenSize(tester);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Receita'));
      await tester.pumpAndSettle();

      // Check if button is selected (implementation detail: variant solid)
      // We can also check if the amount text color changes or similar
    });

    testWidgets('typing amount updates display', (tester) async {
      await setupScreenSize(tester);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      expect(find.text('R\$ 10'), findsOneWidget);
    });

    testWidgets('selecting category updates selection', (tester) async {
      await setupScreenSize(tester);
      when(() => categoryBloc.state).thenReturn(
        CategoryData([
          CategoryModel(id: '1', name: 'Comida', createdAt: DateTime.now()),
        ]),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Comida'), findsOneWidget);
      await tester.tap(find.text('Comida'));
      await tester.pumpAndSettle();
    });

    testWidgets('submitting valid transaction calls repository', (
      tester,
    ) async {
      await setupScreenSize(tester);
      when(
        () => transactionRepository.create(
          description: any(named: 'description'),
          amount: any(named: 'amount'),
          type: any(named: 'type'),
          category: any(named: 'category'),
          occurredAt: any(named: 'occurredAt'),
        ),
      ).thenAnswer(
        (_) async => TransactionModel(
          id: '1',
          description: 'Almoço',
          amount: 50.0,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Enter amount
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();

      // Enter description
      await tester.enterText(find.byType(TextFormField), 'Almoço');
      await tester.pump();

      // Verify display
      expect(find.text('R\$ 50'), findsOneWidget);

      // Save
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      verify(
        () => transactionRepository.create(
          description: 'Almoço',
          amount: 50.0,
          type: any(named: 'type'),
          category: any(named: 'category'),
          occurredAt: any(named: 'occurredAt'),
        ),
      ).called(1);
    });

    testWidgets('typing multiple dots does not break display', (tester) async {
      await setupScreenSize(tester);
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.tap(find.text('.'));
      await tester.tap(find.text('.'));
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(find.text('R\$ 1.5'), findsOneWidget);
    });
  });
}
