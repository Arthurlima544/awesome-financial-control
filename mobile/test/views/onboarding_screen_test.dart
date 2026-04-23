import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afc/view_models/onboarding/onboarding_cubit.dart';
import 'package:afc/views/onboarding_screen.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

class MockOnboardingCubit extends Mock implements OnboardingCubit {}

void main() {
  late MockOnboardingCubit mockCubit;
  late StreamController<OnboardingState> stateController;

  setUp(() {
    mockCubit = MockOnboardingCubit();
    stateController = StreamController<OnboardingState>.broadcast();

    when(
      () => mockCubit.state,
    ).thenReturn(const OnboardingState(isLoading: false));
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(
      () => mockCubit.close(),
    ).thenAnswer((_) async => stateController.close());
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidget() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<OnboardingCubit>.value(
        value: mockCubit,
        child: const OnboardingScreen(),
      ),
    );
  }

  testWidgets('renders all onboarding pages in PageView', (tester) async {
    await tester.pumpWidget(createWidget());
    stateController.add(const OnboardingState(isLoading: false));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao AFC'), findsOneWidget);
  });

  testWidgets('tapping Skip calls completeOnboarding', (tester) async {
    when(() => mockCubit.completeOnboarding()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidget());
    stateController.add(const OnboardingState(isLoading: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.completeOnboarding()).called(1);
  });

  testWidgets('tapping Next/Start button behavior', (tester) async {
    await tester.pumpWidget(createWidget());

    // Page 0
    when(
      () => mockCubit.state,
    ).thenReturn(const OnboardingState(currentPage: 0, isLoading: false));
    stateController.add(
      const OnboardingState(currentPage: 0, isLoading: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Próximo'), findsOneWidget);

    // Change to Page 3
    when(
      () => mockCubit.state,
    ).thenReturn(const OnboardingState(currentPage: 3, isLoading: false));
    stateController.add(
      const OnboardingState(currentPage: 3, isLoading: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Começar'), findsOneWidget);

    when(() => mockCubit.completeOnboarding()).thenAnswer((_) async {});
    await tester.tap(find.text('Começar'));
    verify(() => mockCubit.completeOnboarding()).called(1);
  });
}
