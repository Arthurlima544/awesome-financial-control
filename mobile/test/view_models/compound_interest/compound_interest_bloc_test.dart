import 'package:afc/models/compound_interest_result.dart';
import 'package:afc/repositories/calculator_repository.dart';
import 'package:afc/view_models/compound_interest/compound_interest_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCalculatorRepository extends Mock implements CalculatorRepository {}

void main() {
  late CalculatorRepository repository;

  const testResult = CompoundInterestResult(
    finalAmount: 1500.0,
    totalInvested: 1000.0,
    totalInterest: 500.0,
    timeline: [],
  );

  setUp(() {
    repository = MockCalculatorRepository();
  });

  group('CompoundInterestBloc', () {
    test('initial state has correct default values', () {
      final bloc = CompoundInterestBloc(repository: repository);
      expect(bloc.state.status, CompoundInterestStatus.initial);
      expect(bloc.state.result, isNull);
      bloc.close();
    });

    blocTest<CompoundInterestBloc, CompoundInterestState>(
      'emits [loading, success] when CalculateCompoundInterestRequested succeeds',
      build: () {
        when(
          () => repository.calculateCompoundInterest(
            initialAmount: any(named: 'initialAmount'),
            monthlyContribution: any(named: 'monthlyContribution'),
            years: any(named: 'years'),
            annualInterestRate: any(named: 'annualInterestRate'),
            adjustForInflation: any(named: 'adjustForInflation'),
          ),
        ).thenAnswer((_) async => testResult);
        return CompoundInterestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        const CalculateCompoundInterestRequested(
          initialAmount: 1000,
          monthlyContribution: 100,
          years: 10,
          annualInterestRate: 0.1,
          adjustForInflation: false,
        ),
      ),
      expect: () => [
        const CompoundInterestState(status: CompoundInterestStatus.loading),
        const CompoundInterestState(
          status: CompoundInterestStatus.success,
          result: testResult,
        ),
      ],
    );

    blocTest<CompoundInterestBloc, CompoundInterestState>(
      'emits [loading, failure] when CalculateCompoundInterestRequested fails',
      build: () {
        when(
          () => repository.calculateCompoundInterest(
            initialAmount: any(named: 'initialAmount'),
            monthlyContribution: any(named: 'monthlyContribution'),
            years: any(named: 'years'),
            annualInterestRate: any(named: 'annualInterestRate'),
            adjustForInflation: any(named: 'adjustForInflation'),
          ),
        ).thenThrow(Exception('error'));
        return CompoundInterestBloc(repository: repository);
      },
      act: (bloc) => bloc.add(
        const CalculateCompoundInterestRequested(
          initialAmount: 1000,
          monthlyContribution: 100,
          years: 10,
          annualInterestRate: 0.1,
          adjustForInflation: false,
        ),
      ),
      expect: () => [
        const CompoundInterestState(status: CompoundInterestStatus.loading),
        const CompoundInterestState(
          status: CompoundInterestStatus.failure,
          errorMessage: 'Erro ao calcular juros compostos',
        ),
      ],
    );
  });
}
