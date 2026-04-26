import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/adaptive_popup/adaptive_popup.dart';
import 'package:afc/widgets/adaptive_popup/adaptive_popup_cubit.dart';
import 'package:afc/widgets/custom_list_tile/custom_list_tile.dart';
import 'package:afc/widgets/dismissible_delete_background/dismissible_delete_background.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:afc/widgets/limit_form_sheet/limit_form_sheet.dart';
import 'package:afc/widgets/skeleton/skeleton_list.dart';
import 'package:afc/view_models/limit_list/limit_list_bloc.dart';
import 'package:afc/models/limit_model.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/utils/currency_formatter.dart';

class LimitListScreen extends StatelessWidget {
  const LimitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LimitListBloc>()..add(const LimitListFetchRequested()),
      child: const _LimitListView(),
    );
  }
}

class _LimitListView extends StatelessWidget {
  const _LimitListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.limitListTitle)),
      body: BlocBuilder<LimitListBloc, LimitListState>(
        builder: (context, state) {
          if (state is LimitListLoading || state is LimitListInitial) {
            return const SkeletonList(itemCount: 6);
          }
          if (state is LimitListError) {
            return Center(
              child: ErrorState(
                message: l10n.limitListError,
                onRetry: () => context.read<LimitListBloc>().add(
                  const LimitListFetchRequested(),
                ),
              ),
            );
          }
          if (state is LimitListData) {
            if (state.limits.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.price_change_outlined,
                  title: l10n.limitListEmpty,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<LimitListBloc>().add(
                const LimitListFetchRequested(),
              ),
              child: ListView.builder(
                itemCount: state.limits.length,
                itemBuilder: (context, index) {
                  final limit = state.limits[index];
                  return _DismissibleItem(limit: limit, l10n: l10n);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLimitForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DismissibleItem extends StatelessWidget {
  const _DismissibleItem({required this.limit, required this.l10n});

  final LimitModel limit;
  final AppLocalizations l10n;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => AdaptivePopupCubit(),
        child: AdaptivePopup(
          title: l10n.limitDeleteConfirmTitle,
          description: l10n.limitDeleteConfirmMessage,
          primaryButtonText: l10n.delete,
          secondaryButtonText: l10n.cancel,
          primaryColor: AppColors.error,
          onPrimaryAction: (_) => Navigator.of(dialogContext).pop(true),
          onSecondaryAction: () => Navigator.of(dialogContext).pop(false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(limit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<LimitListBloc>().add(LimitListDeleteRequested(limit.id)),
      background: const DismissibleDeleteBackground(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final currency = settingsState.selectedCurrency;
          final currencyService = sl<CurrencyService>();

          final amountStr = CurrencyFormatter.format(
            currencyService.convert(limit.amount, currency),
            currency,
          );

          return CustomListTile(
            title: limit.categoryName,
            description: amountStr,
            leadingType: CustomListTileLeading.icon,
            leadingIcon: Icons.price_change_outlined,
            trailingType: CustomListTileTrailing.arrow,
            primaryColor: AppColors.primary,
            onTap: () => _showLimitForm(context, limit),
          );
        },
      ),
    );
  }
}

void _showLimitForm(BuildContext context, [LimitModel? limit]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<LimitListBloc>(),
      child: LimitFormSheet(limit: limit),
    ),
  );
}
