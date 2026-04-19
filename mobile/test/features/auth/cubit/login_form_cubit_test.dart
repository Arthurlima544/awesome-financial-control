import 'package:afc/features/auth/cubit/login_form_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginFormCubit', () {
    test('initial state has empty email and password', () {
      final cubit = LoginFormCubit();
      expect(cubit.state.email, '');
      expect(cubit.state.password, '');
      cubit.close();
    });

    blocTest<LoginFormCubit, LoginFormState>(
      'emits updated email when emailChanged is called',
      build: LoginFormCubit.new,
      act: (cubit) => cubit.emailChanged('user@example.com'),
      expect: () => [
        const LoginFormState(email: 'user@example.com', password: ''),
      ],
    );

    blocTest<LoginFormCubit, LoginFormState>(
      'emits updated password when passwordChanged is called',
      build: LoginFormCubit.new,
      act: (cubit) => cubit.passwordChanged('secret123'),
      expect: () => [const LoginFormState(email: '', password: 'secret123')],
    );

    blocTest<LoginFormCubit, LoginFormState>(
      'preserves email when passwordChanged is called',
      build: LoginFormCubit.new,
      seed: () => const LoginFormState(email: 'user@example.com'),
      act: (cubit) => cubit.passwordChanged('pass'),
      expect: () => [
        const LoginFormState(email: 'user@example.com', password: 'pass'),
      ],
    );

    blocTest<LoginFormCubit, LoginFormState>(
      'preserves password when emailChanged is called',
      build: LoginFormCubit.new,
      seed: () => const LoginFormState(password: 'pass'),
      act: (cubit) => cubit.emailChanged('new@test.com'),
      expect: () => [
        const LoginFormState(email: 'new@test.com', password: 'pass'),
      ],
    );
  });
}
