import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../bloc/home_bloc.dart';
import '../model/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeDashboardLoaded()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeLoading() ||
            HomeInitial() => const Center(child: CircularProgressIndicator()),
            HomeError() => _ErrorView(
              message: l10n.homeErrorLoading,
              onRetry: () =>
                  context.read<HomeBloc>().add(const HomeDashboardLoaded()),
            ),
            HomeLoaded(:final summary, :final transactions) => RefreshIndicator(
              onRefresh: () async =>
                  context.read<HomeBloc>().add(const HomeDashboardLoaded()),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.homeSummaryTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    key: const ValueKey('summaryCard'),
                    totalIncome: summary.totalIncome,
                    totalExpenses: summary.totalExpenses,
                    balance: summary.balance,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeRecentTransactions,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(l10n.homeNoTransactions),
                      ),
                    )
                  else
                    ...transactions.map(
                      (t) =>
                          _TransactionTile(key: ValueKey(t.id), transaction: t),
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
  });

  final double totalIncome;
  final double totalExpenses;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              key: const ValueKey('totalIncome'),
              label: l10n.homeTotalIncome,
              amount: totalIncome,
              color: Colors.green,
            ),
            _SummaryItem(
              key: const ValueKey('totalExpenses'),
              label: l10n.homeTotalExpenses,
              amount: totalExpenses,
              color: Colors.red,
            ),
            _SummaryItem(
              key: const ValueKey('balance'),
              label: l10n.homeBalance,
              amount: balance,
              color: balance >= 0 ? Colors.green : Colors.red,
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
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          'R\$ ${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return ListTile(
      leading: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: isIncome ? Colors.green : Colors.red,
      ),
      title: Text(transaction.description),
      subtitle: transaction.category != null
          ? Text(transaction.category!)
          : null,
      trailing: Text(
        '${isIncome ? '+' : '-'} R\$ ${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
