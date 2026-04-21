import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/summary_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({HomeRepository? repository})
    : _repository = repository ?? sl<HomeRepository>(),
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
