import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../bloc/limit_list_bloc.dart';

class LimitEditScreen extends StatefulWidget {
  const LimitEditScreen({super.key, required this.limitId});

  final String limitId;

  @override
  State<LimitEditScreen> createState() => _LimitEditScreenState();
}

class _LimitEditScreenState extends State<LimitEditScreen> {
  late final TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<LimitListBloc>().state;
    final current = state is LimitListData
        ? state.limits.where((l) => l.id == widget.limitId).firstOrNull
        : null;
    _amountController = TextEditingController(
      text: current != null ? current.amount.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(
        _amountController.text.trim().replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) return;
      context.read<LimitListBloc>().add(
        LimitListUpdateRequested(id: widget.limitId, amount: amount),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.limitEditTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.limitAmountLabel,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.limitAmountLabel;
                  }
                  final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return l10n.limitAmountLabel;
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
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
