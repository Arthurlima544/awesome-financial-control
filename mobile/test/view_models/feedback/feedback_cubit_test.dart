import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:afc/view_models/feedback/feedback_cubit.dart';
import 'package:afc/repositories/feedback_repository.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  late FeedbackCubit feedbackCubit;
  late MockFeedbackRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedbackRepository();
    feedbackCubit = FeedbackCubit(repository: mockRepository);
  });

  tearDown(() {
    feedbackCubit.close();
  });

  group('FeedbackCubit', () {
    test('initial state is correct', () {
      expect(feedbackCubit.state, const FeedbackState());
    });

    blocTest<FeedbackCubit, FeedbackState>(
      'emits state with updated rating when updateRating is called',
      build: () => feedbackCubit,
      act: (cubit) => cubit.updateRating(4),
      expect: () => [const FeedbackState(rating: 4)],
    );

    blocTest<FeedbackCubit, FeedbackState>(
      'emits state with updated message when updateMessage is called',
      build: () => feedbackCubit,
      act: (cubit) => cubit.updateMessage('Testing'),
      expect: () => [const FeedbackState(message: 'Testing')],
    );

    blocTest<FeedbackCubit, FeedbackState>(
      'submits successfully when rating is set',
      build: () {
        when(
          () => mockRepository.submit(
            userId: any(named: 'userId'),
            rating: any(named: 'rating'),
            message: any(named: 'message'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          ),
        ).thenAnswer((_) async => {});
        return feedbackCubit;
      },
      seed: () => const FeedbackState(rating: 5, message: 'Great!'),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const FeedbackState(
          rating: 5,
          message: 'Great!',
          status: FeedbackStatus.submitting,
        ),
        const FeedbackState(
          rating: 5,
          message: 'Great!',
          status: FeedbackStatus.success,
        ),
      ],
    );

    blocTest<FeedbackCubit, FeedbackState>(
      'emits failure when submission fails',
      build: () {
        when(
          () => mockRepository.submit(
            userId: any(named: 'userId'),
            rating: any(named: 'rating'),
            message: any(named: 'message'),
            appVersion: any(named: 'appVersion'),
            platform: any(named: 'platform'),
          ),
        ).thenThrow(Exception('Error'));
        return feedbackCubit;
      },
      seed: () => const FeedbackState(rating: 3),
      act: (cubit) => cubit.submit(),
      expect: () => [
        const FeedbackState(rating: 3, status: FeedbackStatus.submitting),
        const FeedbackState(
          rating: 3,
          status: FeedbackStatus.failure,
          errorMessage: 'Falha ao enviar feedback. Tente novamente.',
        ),
      ],
    );

    test('reset() returns to initial state', () {
      feedbackCubit.updateRating(5);
      feedbackCubit.reset();
      expect(feedbackCubit.state, const FeedbackState());
    });
  });
}
