import 'package:afc/features/limit/bloc/limit_bloc.dart';
import 'package:afc/features/limit/model/limit_progress_model.dart';
import 'package:afc/features/limit/repository/limit_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository extends LimitRepository {
  _FakeRepository(this._limits);

  final List<LimitProgressModel> _limits;

  @override
  Future<List<LimitProgressModel>> getLimitsProgress() async => _limits;
}

class _FailingRepository extends LimitRepository {
  @override
  Future<List<LimitProgressModel>> getLimitsProgress() =>
      Future.error(Exception('network error'));
}

class _RetryRepository extends LimitRepository {
  _RetryRepository({required this.onCall});

  final List<LimitProgressModel> Function() onCall;

  @override
  Future<List<LimitProgressModel>> getLimitsProgress() async => onCall();
}

void main() {
  final limitUnder = LimitProgressModel(
    id: '1',
    categoryName: 'Alimentação',
    limitAmount: 1000.0,
    spent: 500.0,
    percentage: 50.0,
  );

  final limitOver = LimitProgressModel(
    id: '2',
    categoryName: 'Transporte',
    limitAmount: 300.0,
    spent: 350.0,
    percentage: 116.67,
  );

  group('LimitBloc', () {
    test('initial state is LimitInitial', () {
      final bloc = LimitBloc(repository: _FakeRepository([]));
      expect(bloc.state, isA<LimitInitial>());
      addTearDown(bloc.close);
    });

    blocTest<LimitBloc, LimitState>(
      'emits [LimitLoading, LimitLoaded([])] when repository returns empty list',
      build: () => LimitBloc(repository: _FakeRepository([])),
      act: (bloc) => bloc.add(const LimitProgressLoaded()),
      expect: () => [isA<LimitLoading>(), isA<LimitLoaded>()],
      verify: (bloc) {
        final state = bloc.state as LimitLoaded;
        expect(state.limits, isEmpty);
      },
    );

    blocTest<LimitBloc, LimitState>(
      'emits [LimitLoading, LimitLoaded] with correct limits on success',
      build: () =>
          LimitBloc(repository: _FakeRepository([limitUnder, limitOver])),
      act: (bloc) => bloc.add(const LimitProgressLoaded()),
      expect: () => [isA<LimitLoading>(), isA<LimitLoaded>()],
      verify: (bloc) {
        final state = bloc.state as LimitLoaded;
        expect(state.limits.length, 2);
        expect(state.limits.first.categoryName, 'Alimentação');
      },
    );

    blocTest<LimitBloc, LimitState>(
      'emits [LimitLoading, LimitError] when repository throws',
      build: () => LimitBloc(repository: _FailingRepository()),
      act: (bloc) => bloc.add(const LimitProgressLoaded()),
      expect: () => [isA<LimitLoading>(), isA<LimitError>()],
    );

    blocTest<LimitBloc, LimitState>(
      'emits [LimitLoading, LimitLoaded] on retry after error',
      build: () {
        var calls = 0;
        return LimitBloc(
          repository: _RetryRepository(
            onCall: () {
              calls++;
              if (calls == 1) throw Exception('network error');
              return [limitUnder];
            },
          ),
        );
      },
      act: (bloc) async {
        bloc.add(const LimitProgressLoaded());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const LimitProgressLoaded());
      },
      expect: () => [
        isA<LimitLoading>(),
        isA<LimitError>(),
        isA<LimitLoading>(),
        isA<LimitLoaded>(),
      ],
    );

    blocTest<LimitBloc, LimitState>(
      'LimitLoaded.isOverLimit is false when under limit and true when over',
      build: () =>
          LimitBloc(repository: _FakeRepository([limitUnder, limitOver])),
      act: (bloc) => bloc.add(const LimitProgressLoaded()),
      verify: (bloc) {
        final state = bloc.state as LimitLoaded;
        expect(state.limits[0].isOverLimit, false);
        expect(state.limits[1].isOverLimit, true);
      },
    );
  });
}
