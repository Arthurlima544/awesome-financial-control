import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/models/investment_model.dart';
import 'package:afc/repositories/investment_repository.dart';

part 'investment_event.dart';
part 'investment_state.dart';

class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final InvestmentRepository _repository;

  InvestmentBloc({required InvestmentRepository repository})
    : _repository = repository,
      super(const InvestmentState()) {
    on<LoadInvestments>(_onLoadInvestments);
    on<CreateInvestment>(_onCreateInvestment);
    on<UpdateInvestment>(_onUpdateInvestment);
    on<DeleteInvestment>(_onDeleteInvestment);
    on<UpdateInvestmentPrice>(_onUpdateInvestmentPrice);
  }

  Future<void> _onLoadInvestments(
    LoadInvestments event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(state.copyWith(status: InvestmentStatus.loading));
    try {
      final investments = await _repository.getAllInvestments();
      emit(
        state.copyWith(
          status: InvestmentStatus.success,
          investments: investments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateInvestment(
    CreateInvestment event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(state.copyWith(status: InvestmentStatus.loading));
    try {
      await _repository.createInvestment(event.data);
      add(LoadInvestments());
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateInvestment(
    UpdateInvestment event,
    Emitter<InvestmentState> emit,
  ) async {
    emit(state.copyWith(status: InvestmentStatus.loading));
    try {
      await _repository.updateInvestment(event.id, event.data);
      add(LoadInvestments());
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteInvestment(
    DeleteInvestment event,
    Emitter<InvestmentState> emit,
  ) async {
    try {
      await _repository.deleteInvestment(event.id);
      add(LoadInvestments());
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateInvestmentPrice(
    UpdateInvestmentPrice event,
    Emitter<InvestmentState> emit,
  ) async {
    try {
      await _repository.updatePrice(event.id, event.price);
      add(LoadInvestments());
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
