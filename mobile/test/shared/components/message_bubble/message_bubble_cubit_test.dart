import 'package:afc/shared/components/message_bubble/message_bubble_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageBubbleCubit', () {
    late MessageBubbleCubit cubit;

    setUp(() {
      cubit = MessageBubbleCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const MessageBubbleState(isSelected: false, errorMessage: null),
      );
    });

    blocTest<MessageBubbleCubit, MessageBubbleState>(
      'emits state with isSelected toggled when toggleSelection is called',
      build: () => cubit,
      act: (cubit) => cubit.toggleSelection(),
      expect: () => [
        const MessageBubbleState(isSelected: true, errorMessage: null),
      ],
    );

    blocTest<MessageBubbleCubit, MessageBubbleState>(
      'emits state with error message when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Failed to send'),
      expect: () => [
        const MessageBubbleState(
          isSelected: false,
          errorMessage: 'Failed to send',
        ),
      ],
    );

    blocTest<MessageBubbleCubit, MessageBubbleState>(
      'clears error message when selection is toggled',
      build: () => cubit,
      seed: () =>
          const MessageBubbleState(isSelected: false, errorMessage: 'Error'),
      act: (cubit) => cubit.toggleSelection(),
      expect: () => [
        const MessageBubbleState(isSelected: true, errorMessage: null),
      ],
    );

    blocTest<MessageBubbleCubit, MessageBubbleState>(
      'emits initial state when reset is called',
      build: () => cubit,
      seed: () =>
          const MessageBubbleState(isSelected: true, errorMessage: 'Error'),
      act: (cubit) => cubit.reset(),
      expect: () => [
        const MessageBubbleState(isSelected: false, errorMessage: null),
      ],
    );
  });
}
