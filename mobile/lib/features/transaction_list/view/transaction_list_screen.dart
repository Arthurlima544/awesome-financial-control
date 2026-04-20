import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/components/adaptive_popup/adaptive_popup.dart';
import '../../../shared/components/adaptive_popup/adaptive_popup_cubit.dart';
import '../../../shared/components/dismissible_delete_background/dismissible_delete_background.dart';
import '../../../shared/components/empty_state/empty_state.dart';
import '../../../shared/components/error_view/error_view.dart';
import '../../../shared/components/transaction_list_item/transaction_list_item.dart';
import 'package:go_router/go_router.dart';

import '../bloc/transaction_list_bloc.dart';
import '../model/transaction_model.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TransactionListBloc()..add(const TransactionListFetchRequested()),
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
      appBar: AppBar(title: Text(l10n.transactionListTitle)),
      body: BlocBuilder<TransactionListBloc, TransactionListState>(
        builder: (context, state) {
          if (state is TransactionListLoading ||
              state is TransactionListInitial) {
            return const Center(child: CircularProgressIndicator());
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
                  return _DismissibleItem(transaction: t, l10n: l10n);
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
        onTap: () => context.push(
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
