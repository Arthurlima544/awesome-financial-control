import 'package:afc/models/investment_goal.dart';
import 'package:afc/repositories/calculator_repository.dart';
import 'package:afc/view_models/investment_goal/investment_goal_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCalculatorRepository extends Mock implements CalculatorRepository {}

void main() {
  late CalculatorRepository repository;

  setUpAll(() {
    registerFallbackValue(DateTime(2030));
  });

  final testResponse = InvestmentGoalResponse(
    requiredMonthlyContribution: 500.0,
    totalContributed: 10000.0,
    totalInterestEarned: 2000.0,
    timeline: const [],
  );

  setUp(() {
    repository = MockCalculatorRepository();
  });

  group('InvestmentGoalBloc', () {
    test('initial state has correct default values', () {
      final bloc = InvestmentGoalBloc(repository: repository);
      expect(bloc.state.status, InvestmentGoalStatus.initial);
      expect(bloc.state.response, isNull);
      bloc.close();
    });

    blocTest<InvestmentGoalBloc, InvestmentGoalState>(
      'emits [loading, success] when CalculateInvestmentGoalRequested succeeds',
      build: () {
        when(
          () => repository.calculateInvestmentGoal(
            targetAmount: any(named: 'targetAmount'),
            targetDate: any(named: 'targetDate'),
            annualReturnRate: any(named: 'annualReturnRate'),
            initialAmount: any(named: 'initialAmount'),
            adjustForInflation: any(named: 'adjustForInflation'),
          ),
        ).thenAnswer((_) async => testResponse);
        return InvestmentGoalBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        CalculateInvestmentGoalRequested(
          targetAmount: 20000,
          targetDate: DateTime(2030, 1, 1),
          annualReturnRate: 0.1,
          initialAmount: 5000,
          adjustForInflation: false,
        ),
      ),
      expect: () => [
        const InvestmentGoalState(status: InvestmentGoalStatus.loading),
        InvestmentGoalState(
          status: InvestmentGoalStatus.success,
          response: testResponse,
        ),
      ],
    );

    blocTest<InvestmentGoalBloc, InvestmentGoalState>(
      'emits [loading, failure] when CalculateInvestmentGoalRequested fails',
      build: () {
        when(
          () => repository.calculateInvestmentGoal(
            targetAmount: any(named: 'targetAmount'),
            targetDate: any(named: 'targetDate'),
            annualReturnRate: any(named: 'annualReturnRate'),
            initialAmount: any(named: 'initialAmount'),
            adjustForInflation: any(named: 'adjustForInflation'),
          ),
        ).thenThrow(Exception('error'));
        return InvestmentGoalBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        CalculateInvestmentGoalRequested(
          targetAmount: 20000,
          targetDate: DateTime(2030, 1, 1),
          annualReturnRate: 0.1,
          initialAmount: 5000,
          adjustForInflation: false,
        ),
      ),
      expect: () => [
        const InvestmentGoalState(status: InvestmentGoalStatus.loading),
        const InvestmentGoalState(
          status: InvestmentGoalStatus.failure,
          errorMessage: 'Erro ao calcular meta de investimento',
        ),
      ],
    );
  });
}
