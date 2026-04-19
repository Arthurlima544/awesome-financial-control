import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/summary_model.dart';
import '../model/transaction_model.dart';
import '../repository/home_repository.dart';

// Events

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeDashboardLoaded extends HomeEvent {
  const HomeDashboardLoaded();
}

// States

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  const HomeLoaded({required this.summary, required this.transactions});

  final SummaryModel summary;
  final List<TransactionModel> transactions;

  @override
  List<Object?> get props => [summary, transactions];
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({HomeRepository? repository})
    : _repository = repository ?? HomeRepository(),
      super(HomeInitial()) {
    on<HomeDashboardLoaded>(_onDashboardLoaded);
  }

  final HomeRepository _repository;

  Future<void> _onDashboardLoaded(
    HomeDashboardLoaded event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getLastTransactions(),
      ]);
      emit(
        HomeLoaded(
          summary: results[0] as SummaryModel,
          transactions: results[1] as List<TransactionModel>,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
