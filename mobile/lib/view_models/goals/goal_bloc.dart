import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/models/goal_model.dart';
import 'package:afc/repositories/goal_repository.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository _repository;

  GoalBloc({required GoalRepository repository})
    : _repository = repository,
      super(const GoalState()) {
    on<LoadGoals>(_onLoadGoals);
    on<CreateGoal>(_onCreateGoal);
    on<ContributeToGoal>(_onContributeToGoal);
    on<DeleteGoal>(_onDeleteGoal);
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    emit(state.copyWith(status: GoalStatus.loading));
    try {
      final goals = await _repository.getGoals();
      emit(state.copyWith(status: GoalStatus.success, goals: goals));
    } catch (e) {
      emit(
        state.copyWith(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao carregar objetivos',
        ),
      );
    }
  }

  Future<void> _onCreateGoal(CreateGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(status: GoalStatus.loading));
    try {
      await _repository.createGoal({
        'name': event.name,
        'targetAmount': event.targetAmount,
        'deadline': event.deadline.toIso8601String(),
        'icon': event.icon,
      });
      add(LoadGoals());
    } catch (e) {
      emit(
        state.copyWith(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao criar objetivo',
        ),
      );
    }
  }

  Future<void> _onContributeToGoal(
    ContributeToGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _repository.addContribution(event.goalId, event.amount);
      add(LoadGoals());
    } catch (e) {
      emit(
        state.copyWith(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao adicionar contribuição',
        ),
      );
    }
  }

  Future<void> _onDeleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    try {
      await _repository.deleteGoal(event.goalId);
      add(LoadGoals());
    } catch (e) {
      emit(
        state.copyWith(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao excluir objetivo',
        ),
      );
    }
  }
}
