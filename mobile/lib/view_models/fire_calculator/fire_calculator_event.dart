part of 'fire_calculator_bloc.dart';

abstract class FireCalculatorEvent extends Equatable {
  const FireCalculatorEvent();

  @override
  List<Object?> get props => [];
}

class FireCalculationRequested extends FireCalculatorEvent {
  final double monthlyExpenses;
  final double currentPortfolio;
  final double monthlySavings;
  final double annualReturnRate;
  final double safeWithdrawalRate;

  const FireCalculationRequested({
    required this.monthlyExpenses,
    required this.currentPortfolio,
    required this.monthlySavings,
    required this.annualReturnRate,
    required this.safeWithdrawalRate,
  });

  @override
  List<Object?> get props => [
    monthlyExpenses,
    currentPortfolio,
    monthlySavings,
    annualReturnRate,
    safeWithdrawalRate,
  ];
}
