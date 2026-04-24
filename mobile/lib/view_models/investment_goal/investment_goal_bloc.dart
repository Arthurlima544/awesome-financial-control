import 'package:afc/models/investment_goal.dart';
import 'package:afc/repositories/calculator_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'investment_goal_event.dart';
part 'investment_goal_state.dart';

class InvestmentGoalBloc
    extends Bloc<InvestmentGoalEvent, InvestmentGoalState> {
  final CalculatorRepository _repository;

  InvestmentGoalBloc({required CalculatorRepository repository})
    : _repository = repository,
      super(const InvestmentGoalState()) {
    on<CalculateInvestmentGoalRequested>(_onCalculateRequested);
  }

  Future<void> _onCalculateRequested(
    CalculateInvestmentGoalRequested event,
    Emitter<InvestmentGoalState> emit,
  ) async {
    emit(state.copyWith(status: InvestmentGoalStatus.loading));

    try {
      final data = await _repository.calculateInvestmentGoal(
        targetAmount: event.targetAmount,
        targetDate: event.targetDate,
        annualReturnRate: event.annualReturnRate,
        initialAmount: event.initialAmount,
      );

      final response = InvestmentGoalResponse.fromJson(data);
      emit(
        state.copyWith(
          status: InvestmentGoalStatus.success,
          response: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentGoalStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
