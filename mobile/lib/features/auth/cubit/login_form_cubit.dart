import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginFormState extends Equatable {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [email, password, isPasswordVisible];
}

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit() : super(const LoginFormState());

  void emailChanged(String value) => emit(state.copyWith(email: value));

  void passwordChanged(String value) => emit(state.copyWith(password: value));

  void togglePasswordVisibility() =>
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
}
