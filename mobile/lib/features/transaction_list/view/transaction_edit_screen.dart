import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../bloc/transaction_list_bloc.dart';
import '../model/transaction_model.dart';

class TransactionEditScreen extends StatefulWidget {
  const TransactionEditScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late TransactionType _type;
  late DateTime _occurredAt;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<TransactionListBloc>().state;
    final current = state is TransactionListData
        ? state.transactions
              .where((t) => t.id == widget.transactionId)
              .firstOrNull
        : null;
    _descriptionController = TextEditingController(
      text: current?.description ?? '',
    );
    _amountController = TextEditingController(
      text: current != null ? current.amount.toStringAsFixed(2) : '',
    );
    _categoryController = TextEditingController(text: current?.category ?? '');
    _type = current?.type ?? TransactionType.expense;
    _occurredAt = current?.occurredAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(
        _amountController.text.trim().replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) return;
      context.read<TransactionListBloc>().add(
        TransactionUpdateRequested(
          id: widget.transactionId,
          description: _descriptionController.text.trim(),
          amount: amount,
          type: _type.name,
          category: _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
          occurredAt: _occurredAt,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionEditTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.transactionDescriptionLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.transactionDescriptionLabel
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.transactionAmountLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.transactionAmountLabel;
                  }
                  final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return l10n.transactionAmountLabel;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.income,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text(l10n.income),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text(l10n.expense),
                  ),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: l10n.navLimits,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _submit, child: Text(l10n.save)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
