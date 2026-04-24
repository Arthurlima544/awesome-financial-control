import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/calculator_repository.dart';

part 'compound_interest_event.dart';
part 'compound_interest_state.dart';

class CompoundInterestBloc
    extends Bloc<CompoundInterestEvent, CompoundInterestState> {
  final CalculatorRepository _repository;

  CompoundInterestBloc({required CalculatorRepository repository})
    : _repository = repository,
      super(const CompoundInterestState()) {
    on<CalculateCompoundInterestRequested>(
      _onCalculateCompoundInterestRequested,
    );
  }

  Future<void> _onCalculateCompoundInterestRequested(
    CalculateCompoundInterestRequested event,
    Emitter<CompoundInterestState> emit,
  ) async {
    emit(state.copyWith(status: CompoundInterestStatus.loading));
    try {
      final result = await _repository.calculateCompoundInterest(
        initialAmount: event.initialAmount,
        monthlyContribution: event.monthlyContribution,
        years: event.years,
        annualInterestRate: event.annualInterestRate,
        adjustForInflation: event.adjustForInflation,
      );
      emit(
        state.copyWith(status: CompoundInterestStatus.success, result: result),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CompoundInterestStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
