import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/repositories/investment_repository.dart';

// Events
abstract class InvestmentDashboardEvent extends Equatable {
  const InvestmentDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadInvestmentDashboard extends InvestmentDashboardEvent {}

// State
enum InvestmentDashboardStatus { initial, loading, success, failure }

class InvestmentDashboardState extends Equatable {
  final InvestmentDashboardStatus status;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const InvestmentDashboardState({
    this.status = InvestmentDashboardStatus.initial,
    this.data,
    this.errorMessage,
  });

  InvestmentDashboardState copyWith({
    InvestmentDashboardStatus? status,
    Map<String, dynamic>? data,
    String? errorMessage,
  }) {
    return InvestmentDashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}

// Bloc
class InvestmentDashboardBloc
    extends Bloc<InvestmentDashboardEvent, InvestmentDashboardState> {
  final InvestmentRepository _repository;

  InvestmentDashboardBloc({required InvestmentRepository repository})
    : _repository = repository,
      super(const InvestmentDashboardState()) {
    on<LoadInvestmentDashboard>(_onLoadInvestmentDashboard);
  }

  Future<void> _onLoadInvestmentDashboard(
    LoadInvestmentDashboard event,
    Emitter<InvestmentDashboardState> emit,
  ) async {
    emit(state.copyWith(status: InvestmentDashboardStatus.loading));
    try {
      final data = await _repository.getDashboardData();
      emit(
        state.copyWith(status: InvestmentDashboardStatus.success, data: data),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InvestmentDashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
