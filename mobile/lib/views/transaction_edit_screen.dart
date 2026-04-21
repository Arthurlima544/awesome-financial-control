import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/transaction_list/transaction_list_bloc.dart';
import 'package:afc/view_models/transaction_list/transaction_edit_cubit.dart';
import 'package:afc/models/transaction_model.dart';

class TransactionEditScreen extends StatelessWidget {
  const TransactionEditScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TransactionListBloc,
      TransactionListState,
      TransactionModel?
    >(
      selector: (state) {
        if (state is TransactionListData) {
          return state.transactions
              .where((t) => t.id == transactionId)
              .firstOrNull;
        }
        return null;
      },
      builder: (context, transaction) {
        return BlocProvider(
          create: (_) => TransactionEditCubit(initialTransaction: transaction),
          child: TransactionEditForm(transactionId: transactionId),
        );
      },
    );
  }
}

class TransactionEditForm extends StatefulWidget {
  const TransactionEditForm({super.key, required this.transactionId});

  final String transactionId;

  @override
  State<TransactionEditForm> createState() => _TransactionEditFormState();
}

class _TransactionEditFormState extends State<TransactionEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TransactionEditCubit>();
    _descriptionController = TextEditingController(
      text: cubit.state.description,
    );
    _amountController = TextEditingController(text: cubit.state.amount);
    _categoryController = TextEditingController(text: cubit.state.category);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<TransactionEditCubit>();
    if (!cubit.state.isValid) {
      _formKey.currentState!.validate();
      return;
    }

    context.read<TransactionListBloc>().add(
      TransactionUpdateRequested(
        id: widget.transactionId,
        description: cubit.state.description.trim(),
        amount: cubit.state.parsedAmount!,
        type: cubit.state.type.name,
        category: cubit.state.parsedCategory,
        occurredAt: cubit.state.occurredAt ?? DateTime.now(),
      ),
    );

    cubit.saved();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<TransactionEditCubit, TransactionEditState>(
      listenWhen: (previous, current) =>
          current.status == TransactionEditStatus.success,
      listener: (context, state) {
        sl<NavigationService>().pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.transactionEditTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BlocBuilder<TransactionEditCubit, TransactionEditState>(
                  buildWhen: (p, c) => p.description != c.description,
                  builder: (context, state) => TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.transactionDescriptionLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => context
                        .read<TransactionEditCubit>()
                        .descriptionChanged(v),
                    validator: (_) => state.isDescriptionValid
                        ? null
                        : l10n.transactionDescriptionLabel,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<TransactionEditCubit, TransactionEditState>(
                  buildWhen: (p, c) => p.amount != c.amount,
                  builder: (context, state) => TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: l10n.transactionAmountLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        context.read<TransactionEditCubit>().amountChanged(v),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (_) => state.isAmountValid
                        ? null
                        : l10n.transactionAmountLabel,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<TransactionEditCubit, TransactionEditState>(
                  buildWhen: (p, c) => p.type != c.type,
                  builder: (context, state) {
                    return DropdownButtonFormField<TransactionType>(
                      initialValue: state.type,
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
                      onChanged: (v) =>
                          context.read<TransactionEditCubit>().typeChanged(v!),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: l10n.navLimits,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      context.read<TransactionEditCubit>().categoryChanged(v),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
