part of 'stats_bloc.dart';

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

  String formatYLabel(double value) {
    if (value >= 1000) {
      return 'R\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$${value.toStringAsFixed(0)}';
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
