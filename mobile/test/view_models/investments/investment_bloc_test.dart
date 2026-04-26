import 'package:afc/models/investment_model.dart';
import 'package:afc/repositories/investment_repository.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInvestmentRepository extends Mock implements InvestmentRepository {}

void main() {
  late InvestmentRepository repository;
  late InvestmentBloc bloc;

  setUp(() {
    repository = MockInvestmentRepository();
    bloc = InvestmentBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  final mockInvestments = [
    const InvestmentModel(
      id: '1',
      name: 'Stock 1',
      ticker: 'S1',
      type: InvestmentType.stock,
      quantity: 10,
      avgCost: 100,
      currentPrice: 110,
      totalCost: 1000,
      currentValue: 1100,
      gainLoss: 100,
      gainLossPercentage: 10,
    ),
  ];

  group('InvestmentBloc', () {
    blocTest<InvestmentBloc, InvestmentState>(
      'emits [loading, success] when LoadInvestments is added',
      build: () {
        when(
          () => repository.getAllInvestments(),
        ).thenAnswer((_) async => mockInvestments);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadInvestments()),
      expect: () => [
        const InvestmentState(status: InvestmentStatus.loading),
        InvestmentState(
          status: InvestmentStatus.success,
          investments: mockInvestments,
        ),
      ],
    );

    blocTest<InvestmentBloc, InvestmentState>(
      'emits [loading, failure] when LoadInvestments fails',
      build: () {
        when(
          () => repository.getAllInvestments(),
        ).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadInvestments()),
      expect: () => [
        const InvestmentState(status: InvestmentStatus.loading),
        const InvestmentState(
          status: InvestmentStatus.failure,
          errorMessage: 'Erro ao carregar investimentos',
        ),
      ],
    );

    blocTest<InvestmentBloc, InvestmentState>(
      'emits loading and reloads when CreateInvestment is added',
      build: () {
        when(
          () => repository.createInvestment(any()),
        ).thenAnswer((_) async => mockInvestments.first);
        when(
          () => repository.getAllInvestments(),
        ).thenAnswer((_) async => mockInvestments);
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateInvestment({'name': 'New'})),
      expect: () => [
        const InvestmentState(status: InvestmentStatus.loading),
        InvestmentState(
          status: InvestmentStatus.success,
          investments: mockInvestments,
        ),
      ],
    );
  });
}
