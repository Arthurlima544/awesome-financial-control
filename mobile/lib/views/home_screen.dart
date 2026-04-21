import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_config.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/dev_tools_sheet/dev_tools_sheet.dart';
import 'package:afc/view_models/limit/limit_bloc.dart';
import 'package:afc/views/month_limit_view.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/widgets/error_view/error_view.dart';
import 'package:afc/widgets/skeleton/card_skeleton.dart';
import 'package:afc/widgets/skeleton/list_item_skeleton.dart';
import 'package:afc/widgets/skeleton/skeleton_view.dart';
import 'package:afc/widgets/transaction_list_item/transaction_list_item.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/models/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LimitBloc>()..add(const LimitProgressLoaded()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _hasShownAlert = false;

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
                final limitBloc = context.read<LimitBloc>();
                showDevToolsSheet(
                  context,
                  onSuccess: () {
                    homeBloc.add(const HomeDashboardLoaded());
                    limitBloc.add(const LimitProgressLoaded());
                  },
                );
              },
            ),
        ],
      ),
      body: BlocListener<LimitBloc, LimitState>(
        listenWhen: (p, c) => p is! LimitLoaded && c is LimitLoaded,
        listener: (context, state) {
          if (state is LimitLoaded && !_hasShownAlert) {
            final overspent = state.limits.where((l) => l.isOverLimit).toList();
            if (overspent.isNotEmpty) {
              _hasShownAlert = true;
              final limitNames = overspent
                  .map((e) => e.categoryName)
                  .join(', ');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Limite excedido: $limitNames')),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeDashboardLoaded());
            context.read<LimitBloc>().add(const LimitProgressLoaded());
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return switch (state) {
                HomeLoading() || HomeInitial() => ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: const [
                    SkeletonView(width: double.infinity, height: 180),
                    SizedBox(height: AppSpacing.lg),
                    SkeletonView(width: 150, height: 24),
                    SizedBox(height: 12),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                    ListItemSkeleton(),
                  ],
                ),
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
                  :final savingsRate,
                ) =>
                  ListView(
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
                        savingsRate: savingsRate,
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
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Limites',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<LimitBloc, LimitState>(
                        builder: (context, limitState) {
                          return switch (limitState) {
                            LimitLoading() || LimitInitial() => const Column(
                              children: [
                                CardSkeleton(),
                                SizedBox(height: AppSpacing.sm),
                                CardSkeleton(),
                              ],
                            ),
                            LimitError() => ErrorView(
                              message: l10n.limitErrorLoading,
                              onRetry: () => context.read<LimitBloc>().add(
                                const LimitProgressLoaded(),
                              ),
                            ),
                            LimitLoaded(:final limits) =>
                              limits.isEmpty
                                  ? EmptyState(
                                      icon: Icons.price_change_outlined,
                                      title: l10n.limitNoLimits,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: limits
                                          .map(
                                            (limit) => MonthLimitView(
                                              key: ValueKey(limit.id),
                                              limit: limit,
                                            ),
                                          )
                                          .toList(),
                                    ),
                            _ => const SizedBox.shrink(),
                          };
                        },
                      ),
                      const SizedBox(height: 80), // Padding for FAB
                    ],
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.savingsRate,
  });

  final String totalIncome;
  final String totalExpenses;
  final int savingsRate;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  '$savingsRate%',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Taxa de\npoupança',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalIncome,
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Receita do mês',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalExpenses,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Gastos do mês',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
