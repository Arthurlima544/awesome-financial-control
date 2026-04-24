part of 'investment_goal_bloc.dart';

abstract class InvestmentGoalEvent extends Equatable {
  const InvestmentGoalEvent();

  @override
  List<Object?> get props => [];
}

class CalculateInvestmentGoalRequested extends InvestmentGoalEvent {
  final double targetAmount;
  final DateTime targetDate;
  final double annualReturnRate;
  final double initialAmount;

  const CalculateInvestmentGoalRequested({
    required this.targetAmount,
    required this.targetDate,
    required this.annualReturnRate,
    required this.initialAmount,
  });

  @override
  List<Object?> get props => [
    targetAmount,
    targetDate,
    annualReturnRate,
    initialAmount,
  ];
}
