import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/widgets/profile_edit_sheet/profile_edit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileEditSheet extends StatelessWidget {
  const ProfileEditSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required String initialEmail,
  }) {
    final settingsBloc = context.read<SettingsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: settingsBloc,
        child: BlocProvider(
          create: (_) => ProfileEditCubit(
            initialName: initialName,
            initialEmail: initialEmail,
          ),
          child: const ProfileEditSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.settingsProfile,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _NameField(),
          const SizedBox(height: AppSpacing.md),
          const _EmailField(),
          const SizedBox(height: AppSpacing.xl),
          const _SaveButton(),
        ],
      ),
    );
  }
}

class _NameField extends StatefulWidget {
  const _NameField();

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ProfileEditCubit>().state.name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => AdaptiveTextFieldCubit(),
      child: AdaptiveTextField(
        hintText: l10n.settingsProfileName,
        controller: _controller,
        onChanged: (val) => context.read<ProfileEditCubit>().updateName(val),
      ),
    );
  }
}

class _EmailField extends StatefulWidget {
  const _EmailField();

  @override
  State<_EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<_EmailField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ProfileEditCubit>().state.email,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => AdaptiveTextFieldCubit(),
      child: AdaptiveTextField(
        hintText: l10n.settingsProfileEmail,
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        onChanged: (val) => context.read<ProfileEditCubit>().updateEmail(val),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProfileEditCubit, ProfileEditState>(
      builder: (context, state) {
        return BlocProvider(
          create: (_) => AdaptiveButtonCubit(),
          child: AdaptiveButton(
            text: l10n.save,
            onPressed: state.name.trim().isEmpty
                ? null
                : () {
                    context.read<SettingsBloc>().add(
                      SettingsProfileUpdated(
                        name: state.name.trim(),
                        email: state.email.trim(),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
          ),
        );
      },
    );
  }
}
