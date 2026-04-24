part of 'compound_interest_bloc.dart';

abstract class CompoundInterestEvent extends Equatable {
  const CompoundInterestEvent();

  @override
  List<Object?> get props => [];
}

class CalculateCompoundInterestRequested extends CompoundInterestEvent {
  final double initialAmount;
  final double monthlyContribution;
  final int years;
  final double annualInterestRate;
  final bool adjustForInflation;

  const CalculateCompoundInterestRequested({
    required this.initialAmount,
    required this.monthlyContribution,
    required this.years,
    required this.annualInterestRate,
    this.adjustForInflation = false,
  });

  @override
  List<Object?> get props => [
    initialAmount,
    monthlyContribution,
    years,
    annualInterestRate,
    adjustForInflation,
  ];
}
