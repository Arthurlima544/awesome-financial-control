import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../cubit/login_form_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormCubit(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formCubit = context.read<LoginFormCubit>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              key: const ValueKey('loginEmailField'),
              decoration: InputDecoration(labelText: l10n.loginEmailLabel),
              keyboardType: TextInputType.emailAddress,
              onChanged: formCubit.emailChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('loginPasswordField'),
              decoration: InputDecoration(labelText: l10n.loginPasswordLabel),
              obscureText: true,
              onChanged: formCubit.passwordChanged,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const ValueKey('loginButton'),
              onPressed: () {
                final form = context.read<LoginFormCubit>().state;
                context.read<AuthBloc>().add(
                  SignInSubmitted(email: form.email, password: form.password),
                );
              },
              child: Text(l10n.loginButton),
            ),
          ],
        ),
      ),
    );
  }
}
