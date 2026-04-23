import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/auth/auth_bloc.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/view_models/theme/theme_cubit.dart';
import 'package:afc/widgets/custom_list_tile/custom_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsBloc>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeCubit = context.watch<ThemeCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.settingsTitle), elevation: 0),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              _SectionHeader(title: l10n.settingsProfile),
              CustomListTile(
                title: state.userName,
                description: state.userEmail,
                leadingType: CustomListTileLeading.avatar,
                trailingType: CustomListTileTrailing.arrow,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onTap: () {
                  // TODO: Profile edit
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: l10n.settingsAppearance),
              CustomListTile(
                title: l10n.settingsAppearanceTheme,
                description: _getThemeName(context, themeCubit.state),
                leadingIcon: Icons.palette_outlined,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onTap: () => _showThemePicker(context, themeCubit),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: l10n.settingsNotifications),
              CustomListTile(
                title: l10n.settingsNotificationsEnabled,
                leadingIcon: Icons.notifications_outlined,
                trailingType: CustomListTileTrailing.toggleSwitch,
                initialValue: state.notificationsEnabled,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onChanged: (val) {
                  context.read<SettingsBloc>().add(
                    SettingsNotificationsToggled(val),
                  );
                },
              ),
              CustomListTile(
                title: l10n.settingsNotificationsBiometric,
                leadingIcon: Icons.fingerprint,
                trailingType: CustomListTileTrailing.toggleSwitch,
                initialValue: state.biometricEnabled,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onChanged: (val) {
                  context.read<SettingsBloc>().add(
                    SettingsBiometricToggled(val),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: l10n.settingsData),
              CustomListTile(
                title: l10n.settingsDataExport,
                leadingIcon: Icons.file_download_outlined,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onTap: () {
                  // TODO: Export data
                },
              ),
              CustomListTile(
                title: l10n.settingsDataClear,
                leadingIcon: Icons.delete_outline,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onTap: () {
                  context.read<SettingsBloc>().add(SettingsDataCleared());
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: l10n.settingsAbout),
              CustomListTile(
                title: l10n.settingsAboutVersion,
                description: state.appVersion,
                leadingIcon: Icons.info_outline,
                trailingType: CustomListTileTrailing.none,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
              ),
              CustomListTile(
                title: l10n.settingsAboutTerms,
                leadingIcon: Icons.description_outlined,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onTap: () {},
              ),
              CustomListTile(
                title: l10n.settingsAboutPrivacy,
                leadingIcon: Icons.privacy_tip_outlined,
                backgroundColor: AppColors.surface,
                titleColor: AppColors.onSurface,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    l10n.settingsLogout,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.system:
        return l10n.settingsAppearanceSystem;
      case ThemeMode.light:
        return l10n.settingsAppearanceLight;
      case ThemeMode.dark:
        return l10n.settingsAppearanceDark;
    }
  }

  void _showThemePicker(BuildContext context, ThemeCubit themeCubit) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.settingsAppearanceTheme,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: Text(l10n.settingsAppearanceSystem),
              onTap: () {
                themeCubit.setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
              trailing: themeCubit.state == ThemeMode.system
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: Text(l10n.settingsAppearanceLight),
              onTap: () {
                themeCubit.setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
              trailing: themeCubit.state == ThemeMode.light
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: Text(l10n.settingsAppearanceDark),
              onTap: () {
                themeCubit.setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
              trailing: themeCubit.state == ThemeMode.dark
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLogout),
        content: Text(l10n.settingsLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.neutral500,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
