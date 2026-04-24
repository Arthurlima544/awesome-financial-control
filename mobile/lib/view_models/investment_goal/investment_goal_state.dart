part of 'investment_goal_bloc.dart';

enum InvestmentGoalStatus { initial, loading, success, failure }

class InvestmentGoalState extends Equatable {
  final InvestmentGoalStatus status;
  final InvestmentGoalResponse? response;
  final String? errorMessage;

  const InvestmentGoalState({
    this.status = InvestmentGoalStatus.initial,
    this.response,
    this.errorMessage,
  });

  InvestmentGoalState copyWith({
    InvestmentGoalStatus? status,
    InvestmentGoalResponse? response,
    String? errorMessage,
  }) {
    return InvestmentGoalState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, response, errorMessage];
}
