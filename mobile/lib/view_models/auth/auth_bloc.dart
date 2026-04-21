import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc([
    AuthState? initialState,
    Duration checkDelay = const Duration(milliseconds: 300),
  ]) : _checkDelay = checkDelay,
       super(initialState ?? AuthInitial()) {
    on<AppLaunched>(_onAppLaunched);
    on<SignInSubmitted>(_onSignInSubmitted);
    on<SignOutRequested>(_onSignOutRequested);
  }

  final Duration _checkDelay;

  Future<void> _onAppLaunched(
    AppLaunched event,
    Emitter<AuthState> emit,
  ) async {
    await Future.delayed(_checkDelay);
    emit(AuthSignedOut());
  }

  Future<void> _onSignInSubmitted(
    SignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSignedIn());
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSignedOut());
  }
}
