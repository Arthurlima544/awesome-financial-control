import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/app_spacing.dart';
import '../../../config/injection.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/navigation_service.dart';
import '../bloc/limit_list_bloc.dart';
import '../cubit/limit_edit_cubit.dart';
import '../model/limit_model.dart';

class LimitEditScreen extends StatelessWidget {
  const LimitEditScreen({super.key, required this.limitId});

  final String limitId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LimitListBloc, LimitListState, LimitModel?>(
      selector: (state) {
        if (state is LimitListData) {
          return state.limits.where((l) => l.id == limitId).firstOrNull;
        }
        return null;
      },
      builder: (context, limit) {
        return BlocProvider(
          create: (_) => LimitEditCubit(initialLimit: limit),
          child: LimitEditForm(limitId: limitId),
        );
      },
    );
  }
}

class LimitEditForm extends StatefulWidget {
  const LimitEditForm({super.key, required this.limitId});

  final String limitId;

  @override
  State<LimitEditForm> createState() => _LimitEditFormState();
}

class _LimitEditFormState extends State<LimitEditForm> {
  late final TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LimitEditCubit>();
    _amountController = TextEditingController(text: cubit.state.amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<LimitEditCubit>();
    if (!cubit.state.isValid) {
      _formKey.currentState!.validate();
      return;
    }

    context.read<LimitListBloc>().add(
      LimitListUpdateRequested(
        id: widget.limitId,
        amount: cubit.state.parsedAmount!,
      ),
    );

    cubit.saved();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<LimitEditCubit, LimitEditState>(
      listenWhen: (previous, current) =>
          current.status == LimitEditStatus.success,
      listener: (context, state) {
        sl<NavigationService>().pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.limitEditTitle)),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BlocBuilder<LimitEditCubit, LimitEditState>(
                  buildWhen: (p, c) => p.amount != c.amount,
                  builder: (context, state) => TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: l10n.limitAmountLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        context.read<LimitEditCubit>().amountChanged(v),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (_) =>
                        state.isAmountValid ? null : l10n.limitAmountLabel,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
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
