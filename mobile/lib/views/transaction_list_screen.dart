import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/adaptive_popup/adaptive_popup.dart';
import 'package:afc/widgets/adaptive_popup/adaptive_popup_cubit.dart';
import 'package:afc/widgets/dismissible_delete_background/dismissible_delete_background.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_view/error_view.dart';
import 'package:afc/widgets/transaction_list_item/transaction_list_item.dart';
import 'package:afc/widgets/animations/fade_in_animation.dart';

import 'package:afc/utils/config/injection.dart';
import 'package:afc/widgets/skeleton/skeleton_list.dart';
import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/transaction_list/transaction_list_bloc.dart';
import 'package:afc/models/transaction_model.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransactionListBloc>()..add(const TransactionListFetchRequested()),
      child: const _TransactionListView(),
    );
  }
}

class _TransactionListView extends StatelessWidget {
  const _TransactionListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: l10n.importTitle,
            onPressed: () {
              context.push('/import');
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionListBloc, TransactionListState>(
        builder: (context, state) {
          if (state is TransactionListLoading ||
              state is TransactionListInitial) {
            return const SkeletonList(itemCount: 8);
          }
          if (state is TransactionListError) {
            return Center(
              child: ErrorView(
                message: l10n.transactionListError,
                onRetry: () => context.read<TransactionListBloc>().add(
                  const TransactionListFetchRequested(),
                ),
              ),
            );
          }
          if (state is TransactionListData) {
            if (state.transactions.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.transactionListEmpty,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<TransactionListBloc>().add(
                const TransactionListFetchRequested(),
              ),
              child: ListView.builder(
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final t = state.transactions[index];
                  return FadeInAnimation(
                    delay: Duration(milliseconds: index * 50),
                    child: _DismissibleItem(transaction: t, l10n: l10n),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DismissibleItem extends StatelessWidget {
  const _DismissibleItem({required this.transaction, required this.l10n});

  final TransactionModel transaction;
  final AppLocalizations l10n;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => AdaptivePopupCubit(),
        child: AdaptivePopup(
          title: l10n.transactionDeleteConfirmTitle,
          description: l10n.transactionDeleteConfirmMessage,
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
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<TransactionListBloc>().add(
        TransactionDeleteRequested(transaction.id),
      ),
      background: const DismissibleDeleteBackground(),
      child: InkWell(
        onTap: () => sl<NavigationService>().push(
          '/transactions/${transaction.id}/edit',
          extra: context.read<TransactionListBloc>(),
        ),
        child: TransactionListItem(
          description: transaction.description,
          amount: transaction.amount,
          type: transaction.type == TransactionType.income
              ? TransactionItemType.income
              : TransactionItemType.expense,
          category: transaction.category,
          occurredAt: transaction.occurredAt,
        ),
      ),
    );
  }
}
