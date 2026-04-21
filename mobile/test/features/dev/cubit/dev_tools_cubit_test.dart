import 'package:afc/features/dev/cubit/dev_tools_cubit.dart';
import 'package:afc/features/dev/repository/dev_tools_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends DevToolsRepository {
  @override
  Future<void> seed() async {}

  @override
  Future<void> reset() async {}
}

class _FailingRepository extends DevToolsRepository {
  @override
  Future<void> seed() => Future.error(Exception('seed failed'));

  @override
  Future<void> reset() => Future.error(Exception('reset failed'));
}

void main() {
  group('DevToolsCubit', () {
    test('initial state is DevToolsInitial', () {
      final cubit = DevToolsCubit(repository: _FakeRepository());
      expect(cubit.state, isA<DevToolsInitial>());
      addTearDown(cubit.close);
    });

    blocTest<DevToolsCubit, DevToolsState>(
      'seed emits [Loading(seed), Success(seed)] on success',
      build: () => DevToolsCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.seed(),
      expect: () => [
        const DevToolsLoading(DevToolsAction.seed),
        const DevToolsSuccess(DevToolsAction.seed),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'reset emits [Loading(reset), Success(reset)] on success',
      build: () => DevToolsCubit(repository: _FakeRepository()),
      act: (cubit) => cubit.reset(),
      expect: () => [
        const DevToolsLoading(DevToolsAction.reset),
        const DevToolsSuccess(DevToolsAction.reset),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'seed emits [Loading(seed), Error] when repository throws',
      build: () => DevToolsCubit(repository: _FailingRepository()),
      act: (cubit) => cubit.seed(),
      expect: () => [
        const DevToolsLoading(DevToolsAction.seed),
        isA<DevToolsError>(),
      ],
    );

    blocTest<DevToolsCubit, DevToolsState>(
      'reset emits [Loading(reset), Error] when repository throws',
      build: () => DevToolsCubit(repository: _FailingRepository()),
      act: (cubit) => cubit.reset(),
      expect: () => [
        const DevToolsLoading(DevToolsAction.reset),
        isA<DevToolsError>(),
      ],
    );
  });
}
