import 'package:afc/models/category_model.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/widgets/category_form_sheet/category_form_sheet.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

void main() {
  late CategoryBloc categoryBloc;

  setUpAll(() {
    registerFallbackValue(const CategoryFetchRequested());
  });

  setUp(() {
    categoryBloc = MockCategoryBloc();
    when(() => categoryBloc.state).thenReturn(CategoryInitial());
    when(() => categoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => categoryBloc.add(any())).thenReturn(null);
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider.value(value: categoryBloc, child: child),
      ),
    );
  }

  group('CategoryFormSheet Widget Tests', () {
    testWidgets('renders creation form correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CategoryFormSheet()));
      await tester.pumpAndSettle();

      expect(find.text('Categorias'), findsOneWidget); // Default title for new
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
    });

    testWidgets('renders edit form correctly', (tester) async {
      final category = CategoryModel(
        id: '1',
        name: 'Alimentação',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        buildTestableWidget(CategoryFormSheet(category: category)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar categoria'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget);
    });

    testWidgets('submitting valid name adds CategoryCreateRequested', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpWidget(
        buildTestableWidget(
          CategoryFormSheet(onCategoryCreated: (name) => createdName = name),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Saúde');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      verify(
        () => categoryBloc.add(const CategoryCreateRequested('Saúde')),
      ).called(1);
      expect(createdName, 'Saúde');
    });

    testWidgets('submitting empty name does nothing', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CategoryFormSheet()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      verifyNever(() => categoryBloc.add(any()));
    });

    testWidgets('submitting update adds CategoryUpdateRequested', (
      tester,
    ) async {
      final category = CategoryModel(
        id: '1',
        name: 'Alimentação',
        createdAt: DateTime.now(),
      );
      await tester.pumpWidget(
        buildTestableWidget(CategoryFormSheet(category: category)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Comida');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      verify(
        () => categoryBloc.add(
          const CategoryUpdateRequested(id: '1', name: 'Comida'),
        ),
      ).called(1);
    });
  });
}
