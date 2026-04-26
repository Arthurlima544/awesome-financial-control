import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/calculator_repository.dart';
import 'package:afc/models/fire_calculator_result.dart';

part 'fire_calculator_event.dart';
part 'fire_calculator_state.dart';

class FireCalculatorBloc
    extends Bloc<FireCalculatorEvent, FireCalculatorState> {
  final CalculatorRepository _repository;

  FireCalculatorBloc({required CalculatorRepository repository})
    : _repository = repository,
      super(const FireCalculatorState()) {
    on<FireCalculationRequested>(_onFireCalculationRequested);
  }

  Future<void> _onFireCalculationRequested(
    FireCalculationRequested event,
    Emitter<FireCalculatorState> emit,
  ) async {
    emit(state.copyWith(status: FireCalculatorStatus.loading));
    try {
      final result = await _repository.calculateFire(
        monthlyExpenses: event.monthlyExpenses,
        currentPortfolio: event.currentPortfolio,
        monthlySavings: event.monthlySavings,
        annualReturnRate: event.annualReturnRate,
        safeWithdrawalRate: event.safeWithdrawalRate,
        adjustForInflation: event.adjustForInflation,
      );
      emit(
        state.copyWith(status: FireCalculatorStatus.success, result: result),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FireCalculatorStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
