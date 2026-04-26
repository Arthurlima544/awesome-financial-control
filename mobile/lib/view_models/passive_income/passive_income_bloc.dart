import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/passive_income_repository.dart';
import 'package:afc/models/passive_income_data.dart';

// Events
abstract class PassiveIncomeEvent extends Equatable {
  const PassiveIncomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadPassiveIncomeDashboard extends PassiveIncomeEvent {}

// State
enum PassiveIncomeStatus { initial, loading, success, failure }

class PassiveIncomeState extends Equatable {
  final PassiveIncomeStatus status;
  final PassiveIncomeData? data;
  final String? errorMessage;

  const PassiveIncomeState({
    this.status = PassiveIncomeStatus.initial,
    this.data,
    this.errorMessage,
  });

  PassiveIncomeState copyWith({
    PassiveIncomeStatus? status,
    PassiveIncomeData? data,
    String? errorMessage,
  }) {
    return PassiveIncomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}

// Bloc
class PassiveIncomeBloc extends Bloc<PassiveIncomeEvent, PassiveIncomeState> {
  final PassiveIncomeRepository _repository;

  PassiveIncomeBloc({required PassiveIncomeRepository repository})
    : _repository = repository,
      super(const PassiveIncomeState()) {
    on<LoadPassiveIncomeDashboard>(_onLoadPassiveIncomeDashboard);
  }

  Future<void> _onLoadPassiveIncomeDashboard(
    LoadPassiveIncomeDashboard event,
    Emitter<PassiveIncomeState> emit,
  ) async {
    emit(state.copyWith(status: PassiveIncomeStatus.loading));
    try {
      final data = await _repository.getDashboardData();
      emit(state.copyWith(status: PassiveIncomeStatus.success, data: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: PassiveIncomeStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
