part of 'investment_bloc.dart';

enum InvestmentStatus { initial, loading, success, failure }

class InvestmentState extends Equatable {
  final InvestmentStatus status;
  final List<InvestmentModel> investments;
  final String? errorMessage;

  const InvestmentState({
    this.status = InvestmentStatus.initial,
    this.investments = const [],
    this.errorMessage,
  });

  double get totalInvested =>
      investments.fold(0, (sum, item) => sum + item.totalCost);

  double get totalCurrentValue =>
      investments.fold(0, (sum, item) => sum + item.currentValue);

  double get totalGainLoss => totalCurrentValue - totalInvested;

  double get totalGainLossPercentage =>
      totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0;

  InvestmentState copyWith({
    InvestmentStatus? status,
    List<InvestmentModel>? investments,
    String? errorMessage,
  }) {
    return InvestmentState(
      status: status ?? this.status,
      investments: investments ?? this.investments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, investments, errorMessage];
}
