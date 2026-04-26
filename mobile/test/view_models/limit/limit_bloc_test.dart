import 'package:afc/models/limit_progress_model.dart';
import 'package:afc/repositories/limit_repository.dart';
import 'package:afc/view_models/limit/limit_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLimitRepository extends Mock implements LimitRepository {}

void main() {
  late LimitRepository repository;

  final List<LimitProgressModel> testProgress = [
    const LimitProgressModel(
      id: '1',
      categoryName: 'Alimentação',
      limitAmount: 1000.0,
      spent: 600.0,
      percentage: 60.0,
    ),
  ];

  setUp(() {
    repository = MockLimitRepository();
  });

  group('LimitBloc', () {
    test('initial state is LimitInitial', () {
      final bloc = LimitBloc(repository: repository);
      expect(bloc.state, isA<LimitInitial>());
      bloc.close();
    });

    blocTest<LimitBloc, LimitState>(
      'emits [LimitLoading, LimitLoaded] when LimitProgressLoaded succeeds',
      build: () {
        when(
          () => repository.getLimitsProgress(),
        ).thenAnswer((_) async => testProgress);
        return LimitBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LimitProgressLoaded()),
      expect: () => [isA<LimitLoading>(), LimitLoaded(testProgress)],
    );

    blocTest<LimitBloc, LimitState>(
      'emits [LimitLoading, LimitError] when fetch fails',
      build: () {
        when(
          () => repository.getLimitsProgress(),
        ).thenThrow(Exception('error'));
        return LimitBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const LimitProgressLoaded()),
      expect: () => [
        isA<LimitLoading>(),
        const LimitError('Erro ao carregar progresso dos limites'),
      ],
    );
  });
}
