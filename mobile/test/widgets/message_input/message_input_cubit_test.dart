import 'package:afc/widgets/message_input/message_input_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageInputCubit', () {
    late MessageInputCubit cubit;

    setUp(() {
      cubit = MessageInputCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(
        cubit.state,
        const MessageInputState(text: '', isFocused: false, errorMessage: null),
      );
    });

    blocTest<MessageInputCubit, MessageInputState>(
      'emits correct state when textChanged is called',
      build: () => cubit,
      act: (cubit) => cubit.textChanged('Hello World'),
      expect: () => [
        const MessageInputState(
          text: 'Hello World',
          isFocused: false,
          errorMessage: null,
        ),
      ],
    );

    blocTest<MessageInputCubit, MessageInputState>(
      'emits correct state when focusChanged is called',
      build: () => cubit,
      act: (cubit) => cubit.focusChanged(true),
      expect: () => [
        const MessageInputState(text: '', isFocused: true, errorMessage: null),
      ],
    );

    blocTest<MessageInputCubit, MessageInputState>(
      'emits state with error message when setError is called',
      build: () => cubit,
      act: (cubit) => cubit.setError('Network error'),
      expect: () => [
        const MessageInputState(
          text: '',
          isFocused: false,
          errorMessage: 'Network error',
        ),
      ],
    );

    blocTest<MessageInputCubit, MessageInputState>(
      'clears error message when text is changed',
      build: () => cubit,
      seed: () => const MessageInputState(text: '', errorMessage: 'Error'),
      act: (cubit) => cubit.textChanged('A'),
      expect: () => [
        const MessageInputState(
          text: 'A',
          isFocused: false,
          errorMessage: null,
        ),
      ],
    );

    blocTest<MessageInputCubit, MessageInputState>(
      'emits initial state when clear is called',
      build: () => cubit,
      seed: () => const MessageInputState(
        text: 'Some text',
        isFocused: true,
        errorMessage: 'Error',
      ),
      act: (cubit) => cubit.clear(),
      expect: () => [const MessageInputState()],
    );
  });
}
