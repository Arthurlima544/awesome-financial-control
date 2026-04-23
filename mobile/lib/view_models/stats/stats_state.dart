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

  double get totalIncome => stats.fold(0.0, (sum, s) => sum + s.income);
  double get totalExpenses => stats.fold(0.0, (sum, s) => sum + s.expenses);
  double get totalSavings => totalIncome - totalExpenses;

  double get averageIncome => stats.isEmpty ? 0 : totalIncome / stats.length;
  double get averageExpenses =>
      stats.isEmpty ? 0 : totalExpenses / stats.length;

  double get averageSavingsRate {
    if (totalIncome <= 0) return 0;
    return ((totalIncome - totalExpenses) / totalIncome) * 100;
  }

  MonthlyStatModel? get bestMonth {
    if (stats.isEmpty) return null;
    return stats.reduce((a, b) {
      final rateA = a.income <= 0 ? 0 : (a.income - a.expenses) / a.income;
      final rateB = b.income <= 0 ? 0 : (b.income - b.expenses) / b.income;
      return rateA > rateB ? a : b;
    });
  }

  bool get isTrendPositive {
    if (stats.length < 2) return true;
    final last = stats[stats.length - 1];
    final previous = stats[stats.length - 2];

    final lastRate = last.income <= 0
        ? 0
        : (last.income - last.expenses) / last.income;
    final prevRate = previous.income <= 0
        ? 0
        : (previous.income - previous.expenses) / previous.income;

    return lastRate >= prevRate;
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
