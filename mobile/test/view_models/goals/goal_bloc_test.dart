import 'package:afc/models/goal_model.dart';
import 'package:afc/repositories/goal_repository.dart';
import 'package:afc/view_models/goals/goal_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  late GoalRepository repository;
  late GoalBloc bloc;

  final testGoal = GoalModel(
    id: '1',
    name: 'Travel',
    targetAmount: 1000.0,
    currentAmount: 200.0,
    progressPercentage: 20.0,
    deadline: DateTime(2026, 12, 31),
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockGoalRepository();
    bloc = GoalBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('GoalBloc', () {
    test('initial state is correct', () {
      expect(bloc.state.status, GoalStatus.initial);
      expect(bloc.state.goals, isEmpty);
    });

    blocTest<GoalBloc, GoalState>(
      'emits [loading, success] when LoadGoals succeeds',
      build: () {
        when(() => repository.getGoals()).thenAnswer((_) async => [testGoal]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGoals()),
      expect: () => [
        const GoalState(status: GoalStatus.loading),
        GoalState(status: GoalStatus.success, goals: [testGoal]),
      ],
      verify: (_) {
        verify(() => repository.getGoals()).called(1);
      },
    );

    blocTest<GoalBloc, GoalState>(
      'emits [loading, failure] when LoadGoals fails',
      build: () {
        when(() => repository.getGoals()).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGoals()),
      expect: () => [
        const GoalState(status: GoalStatus.loading),
        const GoalState(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao carregar objetivos',
        ),
      ],
    );

    blocTest<GoalBloc, GoalState>(
      'calls createGoal and reloads on CreateGoal success',
      build: () {
        when(
          () => repository.createGoal(any()),
        ).thenAnswer((_) async => testGoal);
        when(() => repository.getGoals()).thenAnswer((_) async => [testGoal]);
        return bloc;
      },
      act: (bloc) => bloc.add(
        CreateGoal(
          name: 'Travel',
          targetAmount: 1000.0,
          deadline: DateTime(2026, 12, 31),
          icon: 'flight',
        ),
      ),
      expect: () => [
        const GoalState(status: GoalStatus.loading),
        GoalState(status: GoalStatus.success, goals: [testGoal]),
      ],
      verify: (_) {
        verify(() => repository.createGoal(any())).called(1);
        verify(() => repository.getGoals()).called(1);
      },
    );

    blocTest<GoalBloc, GoalState>(
      'emits [loading, failure] when CreateGoal fails',
      build: () {
        when(() => repository.createGoal(any())).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        CreateGoal(
          name: 'Travel',
          targetAmount: 1000.0,
          deadline: DateTime(2026, 12, 31),
        ),
      ),
      expect: () => [
        const GoalState(status: GoalStatus.loading),
        const GoalState(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao criar objetivo',
        ),
      ],
    );

    blocTest<GoalBloc, GoalState>(
      'calls addContribution and reloads on ContributeToGoal success',
      build: () {
        when(
          () => repository.addContribution(any(), any()),
        ).thenAnswer((_) async => testGoal);
        when(() => repository.getGoals()).thenAnswer((_) async => [testGoal]);
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const ContributeToGoal(goalId: '1', amount: 50.0)),
      expect: () => [
        const GoalState(status: GoalStatus.loading),
        GoalState(status: GoalStatus.success, goals: [testGoal]),
      ],
      verify: (_) {
        verify(() => repository.addContribution('1', 50.0)).called(1);
        verify(() => repository.getGoals()).called(1);
      },
    );

    blocTest<GoalBloc, GoalState>(
      'emits [failure] when ContributeToGoal fails',
      build: () {
        when(
          () => repository.addContribution(any(), any()),
        ).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const ContributeToGoal(goalId: '1', amount: 50.0)),
      expect: () => [
        const GoalState(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao adicionar contribuição',
        ),
      ],
    );

    blocTest<GoalBloc, GoalState>(
      'calls deleteGoal and reloads on DeleteGoal success',
      build: () {
        when(() => repository.deleteGoal(any())).thenAnswer((_) async {});
        when(() => repository.getGoals()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteGoal('1')),
      expect: () => [
        const GoalState(status: GoalStatus.loading),
        const GoalState(status: GoalStatus.success, goals: []),
      ],
      verify: (_) {
        verify(() => repository.deleteGoal('1')).called(1);
        verify(() => repository.getGoals()).called(1);
      },
    );

    blocTest<GoalBloc, GoalState>(
      'emits [failure] when DeleteGoal fails',
      build: () {
        when(() => repository.deleteGoal(any())).thenThrow(Exception('error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteGoal('1')),
      expect: () => [
        const GoalState(
          status: GoalStatus.failure,
          errorMessage: 'Erro ao excluir objetivo',
        ),
      ],
    );
    group('GoalState', () {
      test('supports value comparisons', () {
        expect(const GoalState(), const GoalState());
      });
    });
  });
}
