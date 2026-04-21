import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_config.dart';
import '../../../config/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../dev/view/dev_tools_sheet.dart';
import '../../../shared/components/empty_state/empty_state.dart';
import '../../../shared/components/error_view/error_view.dart';
import '../../../shared/components/transaction_list_item/transaction_list_item.dart';
import '../bloc/home_bloc.dart';
import '../model/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          if (AppConfig.isLocal)
            IconButton(
              icon: const Icon(Icons.developer_mode),
              tooltip: l10n.devToolsTitle,
              onPressed: () {
                final homeBloc = context.read<HomeBloc>();
                showDevToolsSheet(
                  context,
                  onSuccess: () => homeBloc.add(const HomeDashboardLoaded()),
                );
              },
            ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeLoading() ||
            HomeInitial() => const Center(child: CircularProgressIndicator()),
            HomeError() => ErrorView(
              key: const ValueKey('homeError'),
              message: l10n.homeErrorLoading,
              onRetry: () =>
                  context.read<HomeBloc>().add(const HomeDashboardLoaded()),
            ),
            HomeLoaded(
              :final transactions,
              :final totalIncomeFormatted,
              :final totalExpensesFormatted,
              :final balanceFormatted,
              :final isBalancePositive,
            ) =>
              RefreshIndicator(
                onRefresh: () async =>
                    context.read<HomeBloc>().add(const HomeDashboardLoaded()),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    Text(
                      l10n.homeSummaryTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      key: const ValueKey('summaryCard'),
                      totalIncome: totalIncomeFormatted,
                      totalExpenses: totalExpensesFormatted,
                      balance: balanceFormatted,
                      isBalancePositive: isBalancePositive,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.homeRecentTransactions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      EmptyState(
                        key: const ValueKey('homeEmptyTransactions'),
                        icon: Icons.receipt_long_outlined,
                        title: l10n.homeNoTransactions,
                      )
                    else
                      ...transactions.map(
                        (t) => TransactionListItem(
                          key: ValueKey(t.id),
                          description: t.description,
                          amount: t.amount,
                          type: t.type == TransactionType.income
                              ? TransactionItemType.income
                              : TransactionItemType.expense,
                          category: t.category,
                          occurredAt: t.occurredAt,
                        ),
                      ),
                  ],
                ),
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.isBalancePositive,
  });

  final String totalIncome;
  final String totalExpenses;
  final String balance;
  final bool isBalancePositive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              key: const ValueKey('totalIncome'),
              label: l10n.homeTotalIncome,
              amount: totalIncome,
              color: AppColors.success,
            ),
            _SummaryItem(
              key: const ValueKey('totalExpenses'),
              label: l10n.homeTotalExpenses,
              amount: totalExpenses,
              color: AppColors.error,
            ),
            _SummaryItem(
              key: const ValueKey('balance'),
              label: l10n.homeBalance,
              amount: balance,
              color: isBalancePositive ? AppColors.success : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
