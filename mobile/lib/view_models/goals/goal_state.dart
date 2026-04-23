part of 'goal_bloc.dart';

enum GoalStatus { initial, loading, success, failure }

class GoalState extends Equatable {
  final GoalStatus status;
  final List<GoalModel> goals;
  final String? errorMessage;

  const GoalState({
    this.status = GoalStatus.initial,
    this.goals = const [],
    this.errorMessage,
  });

  GoalState copyWith({
    GoalStatus? status,
    List<GoalModel>? goals,
    String? errorMessage,
  }) {
    return GoalState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, goals, errorMessage];
}
