import 'package:afc/features/auth/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(AuthBloc().state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthSignedOut] when AppLaunched',
      build: () => AuthBloc(AuthInitial(), Duration.zero),
      act: (bloc) => bloc.add(const AppLaunched()),
      expect: () => [isA<AuthSignedOut>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthSignedIn] when SignInSubmitted',
      build: () => AuthBloc(AuthSignedOut(), Duration.zero),
      act: (bloc) => bloc.add(
        const SignInSubmitted(email: 'test@test.com', password: '123456'),
      ),
      expect: () => [isA<AuthSignedIn>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthSignedOut] when SignOutRequested',
      build: () => AuthBloc(AuthSignedIn(), Duration.zero),
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [isA<AuthSignedOut>()],
    );

    blocTest<AuthBloc, AuthState>(
      'state is AuthSignedOut after AppLaunched when starting at AuthInitial',
      build: () => AuthBloc(AuthInitial(), Duration.zero),
      act: (bloc) => bloc.add(const AppLaunched()),
      verify: (bloc) => expect(bloc.state, isA<AuthSignedOut>()),
    );
  });
}
