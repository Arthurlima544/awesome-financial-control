import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/view_models/auth/auth_bloc.dart';
import 'package:afc/view_models/auth/login_form_cubit.dart';

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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocProvider(
              create: (_) => AdaptiveTextFieldCubit(),
              child: AdaptiveTextField(
                key: const ValueKey('loginEmailField'),
                hintText: l10n.loginEmailLabel,
                leadingIcon: const Icon(Icons.email_outlined),
                focusedBorderColor: AppColors.primary,
                semanticLabel: l10n.loginEmailLabel,
                onChanged: formCubit.emailChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BlocProvider(
              create: (_) => AdaptiveTextFieldCubit(),
              child: BlocBuilder<LoginFormCubit, LoginFormState>(
                buildWhen: (prev, curr) =>
                    prev.isPasswordVisible != curr.isPasswordVisible,
                builder: (context, state) => AdaptiveTextField(
                  key: const ValueKey('loginPasswordField'),
                  hintText: l10n.loginPasswordLabel,
                  leadingIcon: const Icon(Icons.lock_outlined),
                  obscureText: !state.isPasswordVisible,
                  trailingIcon: IconButton(
                    icon: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: formCubit.togglePasswordVisibility,
                  ),
                  focusedBorderColor: AppColors.primary,
                  semanticLabel: l10n.loginPasswordLabel,
                  onChanged: formCubit.passwordChanged,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocProvider(
              create: (_) => AdaptiveButtonCubit(),
              child: AdaptiveButton(
                key: const ValueKey('loginButton'),
                text: l10n.loginButton,
                size: AdaptiveButtonSize.fullWidth,
                primaryColor: AppColors.primary,
                semanticLabel: l10n.loginButton,
                onPressed: () {
                  final form = context.read<LoginFormCubit>().state;
                  context.read<AuthBloc>().add(
                    SignInSubmitted(email: form.email, password: form.password),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
