import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/components/adaptive_button/adaptive_button.dart';
import '../../../shared/components/adaptive_button/adaptive_button_cubit.dart';
import '../../../shared/components/adaptive_chip/adaptive_chip.dart';
import '../../../shared/components/adaptive_chip/adaptive_chip_cubit.dart';
import '../cubit/quick_add_transaction_cubit.dart';
import '../cubit/quick_add_transaction_state.dart';
import '../model/transaction_model.dart';

class QuickAddTransactionSheet extends StatelessWidget {
  const QuickAddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuickAddTransactionCubit(),
      child: const _QuickAddTransactionForm(),
    );
  }
}

class _QuickAddTransactionForm extends StatefulWidget {
  const _QuickAddTransactionForm();

  @override
  State<_QuickAddTransactionForm> createState() =>
      _QuickAddTransactionFormState();
}

class _QuickAddTransactionFormState extends State<_QuickAddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    final cubit = context.read<QuickAddTransactionCubit>();
    if (!cubit.state.isValid) {
      _formKey.currentState!.validate();
      return;
    }
    cubit.submit();
  }

  void _onNumpadTap(String value) {
    final cubit = context.read<QuickAddTransactionCubit>();
    final current = cubit.state.amount;
    if (value == '<') {
      if (current.isNotEmpty) {
        cubit.amountChanged(current.substring(0, current.length - 1));
      }
    } else {
      cubit.amountChanged(current + value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocListener<QuickAddTransactionCubit, QuickAddTransactionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == QuickAddTransactionStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == QuickAddTransactionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.transactionListError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Modelos',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildChip('Supermercado'),
                                const SizedBox(width: 8),
                                _buildChip('Uber trabalho'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) => p.amount != c.amount,
                            builder: (context, state) {
                              return Text(
                                'R\$ ${state.amount.isEmpty ? '0' : state.amount}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0D253F),
                                    ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) => p.type != c.type,
                            builder: (context, state) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: BlocProvider(
                                      create: (_) => AdaptiveButtonCubit(),
                                      child: AdaptiveButton(
                                        text: l10n.income,
                                        variant:
                                            state.type == TransactionType.income
                                            ? AdaptiveButtonVariant.solid
                                            : AdaptiveButtonVariant.outlined,
                                        primaryColor: AppColors.primary,
                                        onPressed: () => context
                                            .read<QuickAddTransactionCubit>()
                                            .typeChanged(
                                              TransactionType.income,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: BlocProvider(
                                      create: (_) => AdaptiveButtonCubit(),
                                      child: AdaptiveButton(
                                        text: l10n.expense,
                                        variant:
                                            state.type ==
                                                TransactionType.expense
                                            ? AdaptiveButtonVariant.solid
                                            : AdaptiveButtonVariant.outlined,
                                        primaryColor: AppColors.primary,
                                        onPressed: () => context
                                            .read<QuickAddTransactionCubit>()
                                            .typeChanged(
                                              TransactionType.expense,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Categoria',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) => p.category != c.category,
                            builder: (context, state) {
                              final categories = [
                                'Salário',
                                'Transporte',
                                'Investimentos',
                                'Saúde',
                                'Alimentação',
                                'Moradia',
                                'Lazer',
                                'Educação',
                              ];
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...categories.map(
                                    (c) => _buildCategoryChip(
                                      c,
                                      state.category == c,
                                      context,
                                    ),
                                  ),
                                  _buildNewCategoryChip(),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) => p.description != c.description,
                            builder: (context, state) => TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Título (opcional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (v) => context
                                  .read<QuickAddTransactionCubit>()
                                  .descriptionChanged(v),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: BlocProvider(
                                  create: (_) => AdaptiveButtonCubit(),
                                  child: AdaptiveButton(
                                    text: 'Câmera',
                                    leadingIcon: Icons.camera_alt_outlined,
                                    variant: AdaptiveButtonVariant.outlined,
                                    primaryColor: AppColors.primary,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BlocProvider(
                                  create: (_) => AdaptiveButtonCubit(),
                                  child: AdaptiveButton(
                                    text: 'Galeria',
                                    leadingIcon: Icons.image_outlined,
                                    variant: AdaptiveButtonVariant.outlined,
                                    primaryColor: AppColors.primary,
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildNumpad(),
                          const SizedBox(height: 16),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            builder: (context, state) {
                              return BlocProvider(
                                create: (_) => AdaptiveButtonCubit(),
                                child: AdaptiveButton(
                                  text: l10n.save,
                                  size: AdaptiveButtonSize.fullWidth,
                                  variant: AdaptiveButtonVariant.solid,
                                  primaryColor: state.isValid
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                  onPressed:
                                      state.isValid &&
                                          state.status !=
                                              QuickAddTransactionStatus.loading
                                      ? _submit
                                      : null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return BlocProvider(
      create: (_) => AdaptiveChipCubit(),
      child: AdaptiveChip(
        label: label,
        variant: AdaptiveChipVariant.tonal,
        onPressed: () {},
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    bool isSelected,
    BuildContext context,
  ) {
    return BlocProvider(
      create: (_) => AdaptiveChipCubit(initialSelected: isSelected),
      child: AdaptiveChip(
        label: label,
        variant: AdaptiveChipVariant.tonal,
        onPressed: () {
          context.read<QuickAddTransactionCubit>().categoryChanged(label);
        },
      ),
    );
  }

  Widget _buildNewCategoryChip() {
    return BlocProvider(
      create: (_) => AdaptiveChipCubit(),
      child: AdaptiveChip(
        label: '+ Nova',
        variant: AdaptiveChipVariant.outlined,
        onPressed: () {},
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          children: [
            _buildNumpadKey('7'),
            const SizedBox(width: 8),
            _buildNumpadKey('8'),
            const SizedBox(width: 8),
            _buildNumpadKey('9'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildNumpadKey('4'),
            const SizedBox(width: 8),
            _buildNumpadKey('5'),
            const SizedBox(width: 8),
            _buildNumpadKey('6'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildNumpadKey('1'),
            const SizedBox(width: 8),
            _buildNumpadKey('2'),
            const SizedBox(width: 8),
            _buildNumpadKey('3'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildNumpadKey('.'),
            const SizedBox(width: 8),
            _buildNumpadKey('0'),
            const SizedBox(width: 8),
            _buildNumpadKey('<', icon: Icons.backspace_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadKey(String value, {IconData? icon}) {
    return Expanded(
      child: InkWell(
        onTap: () => _onNumpadTap(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.primary)
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
