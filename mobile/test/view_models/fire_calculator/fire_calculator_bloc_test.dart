import 'package:afc/models/fire_calculator_result.dart';
import 'package:afc/repositories/calculator_repository.dart';
import 'package:afc/view_models/fire_calculator/fire_calculator_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCalculatorRepository extends Mock implements CalculatorRepository {}

void main() {
  late CalculatorRepository repository;

  final testResult = FireCalculatorResult(
    fireNumber: 1000000.0,
    monthsToFire: 120,
    retirementDate: DateTime(2036, 1, 1),
    yearlyTimeline: const [],
    fiScore: 50.0,
  );

  setUp(() {
    repository = MockCalculatorRepository();
  });

  group('FireCalculatorBloc', () {
    test('initial state has correct default values', () {
      final bloc = FireCalculatorBloc(repository: repository);
      expect(bloc.state.status, FireCalculatorStatus.initial);
      expect(bloc.state.result, isNull);
      bloc.close();
    });

    blocTest<FireCalculatorBloc, FireCalculatorState>(
      'emits [loading, success] when FireCalculationRequested succeeds',
      build: () {
        when(
          () => repository.calculateFire(
            monthlyExpenses: any(named: 'monthlyExpenses'),
            currentPortfolio: any(named: 'currentPortfolio'),
            monthlySavings: any(named: 'monthlySavings'),
            annualReturnRate: any(named: 'annualReturnRate'),
            safeWithdrawalRate: any(named: 'safeWithdrawalRate'),
            adjustForInflation: any(named: 'adjustForInflation'),
          ),
        ).thenAnswer((_) async => testResult);
        return FireCalculatorBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        const FireCalculationRequested(
          monthlyExpenses: 3000,
          currentPortfolio: 0,
          monthlySavings: 1000,
          annualReturnRate: 0.07,
          safeWithdrawalRate: 0.04,
          adjustForInflation: false,
        ),
      ),
      expect: () => [
        const FireCalculatorState(status: FireCalculatorStatus.loading),
        FireCalculatorState(
          status: FireCalculatorStatus.success,
          result: testResult,
        ),
      ],
    );

    blocTest<FireCalculatorBloc, FireCalculatorState>(
      'emits [loading, failure] when FireCalculationRequested fails',
      build: () {
        when(
          () => repository.calculateFire(
            monthlyExpenses: any(named: 'monthlyExpenses'),
            currentPortfolio: any(named: 'currentPortfolio'),
            monthlySavings: any(named: 'monthlySavings'),
            annualReturnRate: any(named: 'annualReturnRate'),
            safeWithdrawalRate: any(named: 'safeWithdrawalRate'),
            adjustForInflation: any(named: 'adjustForInflation'),
          ),
        ).thenThrow(Exception('error'));
        return FireCalculatorBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        const FireCalculationRequested(
          monthlyExpenses: 3000,
          currentPortfolio: 0,
          monthlySavings: 1000,
          annualReturnRate: 0.07,
          safeWithdrawalRate: 0.04,
          adjustForInflation: false,
        ),
      ),
      expect: () => [
        const FireCalculatorState(status: FireCalculatorStatus.loading),
        const FireCalculatorState(
          status: FireCalculatorStatus.failure,
          errorMessage: 'Erro ao calcular FIRE',
        ),
      ],
    );
  });
}
