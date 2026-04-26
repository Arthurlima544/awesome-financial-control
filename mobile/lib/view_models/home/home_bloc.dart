import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/summary_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/home_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'dart:async';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;
  final AppRefreshBloc _refreshBloc;
  late final StreamSubscription _refreshSubscription;

  HomeBloc({HomeRepository? repository, AppRefreshBloc? refreshBloc})
    : _repository = repository ?? sl<HomeRepository>(),
      _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
      super(HomeInitial()) {
    on<HomeDashboardLoaded>(_onDashboardLoaded);
    _refreshSubscription = _refreshBloc.stream.listen(
      (_) => add(const HomeDashboardLoaded()),
    );
  }

  @override
  Future<void> close() {
    _refreshSubscription.cancel();
    return super.close();
  }

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
      emit(HomeError('Erro ao carregar painel'));
    }
  }
}
