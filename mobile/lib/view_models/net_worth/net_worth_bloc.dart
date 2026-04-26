import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/models/net_worth_point.dart';
import 'package:afc/repositories/stats_repository.dart';

// Events
abstract class NetWorthEvent {}

class LoadNetWorthEvolution extends NetWorthEvent {}

// States
enum NetWorthStatus { initial, loading, success, failure }

class NetWorthState {
  final NetWorthStatus status;
  final List<NetWorthPoint> data;
  final String? errorMessage;

  NetWorthState({required this.status, required this.data, this.errorMessage});

  factory NetWorthState.initial() =>
      NetWorthState(status: NetWorthStatus.initial, data: []);

  NetWorthState copyWith({
    NetWorthStatus? status,
    List<NetWorthPoint>? data,
    String? errorMessage,
  }) {
    return NetWorthState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Bloc
class NetWorthBloc extends Bloc<NetWorthEvent, NetWorthState> {
  final StatsRepository _repository;

  NetWorthBloc({required StatsRepository repository})
    : _repository = repository,
      super(NetWorthState.initial()) {
    on<LoadNetWorthEvolution>(_onLoadNetWorthEvolution);
  }

  Future<void> _onLoadNetWorthEvolution(
    LoadNetWorthEvolution event,
    Emitter<NetWorthState> emit,
  ) async {
    emit(state.copyWith(status: NetWorthStatus.loading));
    try {
      final data = await _repository.getNetWorthEvolution();
      emit(state.copyWith(status: NetWorthStatus.success, data: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: NetWorthStatus.failure,
          errorMessage: 'Erro ao carregar evolução do patrimônio',
        ),
      );
    }
  }
}
