import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/monthly_stat_model.dart';
import '../repository/stats_repository.dart';

// Events

abstract class StatsEvent extends Equatable {
  const StatsEvent();
  @override
  List<Object?> get props => [];
}

class StatsLoaded extends StatsEvent {
  const StatsLoaded();
}

// States

abstract class StatsState extends Equatable {
  const StatsState();
  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsData extends StatsState {
  const StatsData(this.stats);

  final List<MonthlyStatModel> stats;

  double get maxValue => stats.fold(0.0, (max, s) {
    final m = s.income > s.expenses ? s.income : s.expenses;
    return m > max ? m : max;
  });

  double get yInterval {
    if (maxValue == 0) return 1000;
    final raw = maxValue / 4;
    return ((raw / 500).ceil() * 500).toDouble();
  }

  @override
  List<Object?> get props => [stats];
}

class StatsError extends StatsState {
  const StatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({StatsRepository? repository})
    : _repository = repository ?? StatsRepository(),
      super(StatsInitial()) {
    on<StatsLoaded>(_onLoaded);
  }

  final StatsRepository _repository;

  Future<void> _onLoaded(StatsLoaded event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final stats = await _repository.getMonthlyStats();
      emit(StatsData(stats));
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }
}
