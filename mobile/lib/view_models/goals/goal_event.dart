part of 'goal_bloc.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();
  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class CreateGoal extends GoalEvent {
  final String name;
  final double targetAmount;
  final DateTime deadline;
  final String? icon;

  const CreateGoal({
    required this.name,
    required this.targetAmount,
    required this.deadline,
    this.icon,
  });

  @override
  List<Object?> get props => [name, targetAmount, deadline, icon];
}

class ContributeToGoal extends GoalEvent {
  final String goalId;
  final double amount;

  const ContributeToGoal({required this.goalId, required this.amount});

  @override
  List<Object?> get props => [goalId, amount];
}

class DeleteGoal extends GoalEvent {
  final String goalId;

  const DeleteGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}
