import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/recurring/recurring_bloc.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:afc/widgets/recurring_form_sheet/recurring_form_sheet.dart';
import 'package:afc/widgets/empty_state/empty_state.dart';
import 'package:afc/models/transaction_model.dart';

class RecurringListScreen extends StatelessWidget {
  const RecurringListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      body: BlocBuilder<RecurringBloc, RecurringState>(
        builder: (context, state) {
          if (state is RecurringLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RecurringError) {
            return ErrorState(
              message: l10n.recurringErrorLoading,
              onRetry: () => context.read<RecurringBloc>().add(LoadRecurring()),
            );
          }
          if (state is RecurringLoaded) {
            if (state.rules.isEmpty) {
              return Center(
                child: EmptyState(
                  icon: Icons.repeat,
                  title: l10n.recurringEmpty,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RecurringBloc>().add(LoadRecurring());
              },
              child: ListView.builder(
                itemCount: state.rules.length,
                itemBuilder: (context, index) {
                  final rule = state.rules[index];
                  return _RecurringItem(rule: rule);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recurring_fab',
        onPressed: () => RecurringFormSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecurringItem extends StatelessWidget {
  final RecurringTransactionModel rule;

  const _RecurringItem({required this.rule});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat.yMd('pt_BR');

    String frequencyLabel = switch (rule.frequency) {
      RecurrenceFrequency.daily => l10n.recurringFrequencyDaily,
      RecurrenceFrequency.weekly => l10n.recurringFrequencyWeekly,
      RecurrenceFrequency.monthly => l10n.recurringFrequencyMonthly,
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: rule.active
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        child: Icon(
          rule.type == TransactionType.income
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: rule.active
              ? (rule.type == TransactionType.income
                    ? Colors.green
                    : Colors.red)
              : Colors.grey,
        ),
      ),
      title: Text(rule.description),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$frequencyLabel • ${currencyFormat.format(rule.amount)}'),
          Text(
            l10n.recurringNextDue(dateFormat.format(rule.nextDueAt)),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (rule.isPaidThisMonth)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Pago',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: rule.active,
            onChanged: (value) =>
                context.read<RecurringBloc>().add(ToggleRecurringActive(rule)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, rule),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RecurringTransactionModel rule) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.recurringDeleteConfirmTitle),
        content: Text(l10n.recurringDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<RecurringBloc>().add(DeleteRecurring(rule.id));
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
