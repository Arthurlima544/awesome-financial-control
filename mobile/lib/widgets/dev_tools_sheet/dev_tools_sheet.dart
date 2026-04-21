import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/dev_tools/dev_tools_cubit.dart';

void showDevToolsSheet(BuildContext context, {VoidCallback? onSuccess}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => DevToolsCubit(),
      child: _DevToolsSheetContent(onSuccess: onSuccess),
    ),
  );
}

class _DevToolsSheetContent extends StatelessWidget {
  const _DevToolsSheetContent({this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DevToolsCubit, DevToolsState>(
      listener: (context, state) {
        if (state is DevToolsSuccess) {
          Navigator.of(context).pop();
          onSuccess?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.action == DevToolsAction.seed
                    ? l10n.devSeedSuccess
                    : l10n.devResetSuccess,
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is DevToolsError) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.devToolsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<DevToolsCubit, DevToolsState>(
              builder: (context, state) {
                final isLoading = state is DevToolsLoading;
                final isSeedLoading =
                    isLoading && state.action == DevToolsAction.seed;
                final isResetLoading =
                    isLoading && state.action == DevToolsAction.reset;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context.read<DevToolsCubit>().seed(),
                      icon: isSeedLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Icon(Icons.data_array),
                      label: Text(l10n.devSeedButton),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => context.read<DevToolsCubit>().reset(),
                      icon: isResetLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(
                              Icons.delete_sweep_outlined,
                              color: AppColors.error,
                            ),
                      label: Text(
                        l10n.devResetButton,
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
