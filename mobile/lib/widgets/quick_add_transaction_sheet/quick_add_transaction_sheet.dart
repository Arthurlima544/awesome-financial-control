import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:afc/view_models/quick_add_transaction/quick_add_transaction_cubit.dart';
import 'package:afc/view_models/quick_add_transaction/quick_add_transaction_state.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/models/template_model.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch_cubit.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control.dart';
import 'package:afc/widgets/adaptive_segmented_control/adaptive_segmented_control_cubit.dart';
import 'package:afc/widgets/category_form_sheet/category_form_sheet.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/widgets/custom_date_picker/custom_date_picker.dart';
import 'package:afc/widgets/custom_date_picker/custom_date_picker_cubit.dart'
    as picker;

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

  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  Future<void> _onPickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      context.read<QuickAddTransactionCubit>().processReceipt(File(image.path));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

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
    } else if (value == '.') {
      if (!current.contains('.') && current.isNotEmpty) {
        cubit.amountChanged(current + value);
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
      listenWhen: (p, c) =>
          p.status != c.status || p.description != c.description,
      listener: (context, state) {
        if (state.status == QuickAddTransactionStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == QuickAddTransactionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.genericError),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (_descriptionController.text != state.description) {
          _descriptionController.text = state.description;
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
                BlocBuilder<QuickAddTransactionCubit, QuickAddTransactionState>(
                  builder: (context, state) {
                    if (state.status ==
                        QuickAddTransactionStatus.processingImage) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(l10n.quickAddAnalyzingReceipt),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) =>
                                p.selectedTemplate != c.selectedTemplate ||
                                p.templates != c.templates,
                            builder: (context, state) {
                              if (state.templates.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.quickAddTemplates,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...state.templates.map((template) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: _buildChip(
                                              template,
                                              state.selectedTemplate ==
                                                  template.description,
                                              context,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              );
                            },
                          ),
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
                            l10n.quickAddCategory,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<CategoryBloc, CategoryState>(
                            builder: (context, categoryState) {
                              List<String> categoryNames = [];
                              if (categoryState is CategoryData) {
                                categoryNames = categoryState.categories
                                    .map((c) => c.name)
                                    .toList();
                              } else {
                                // Fallback to basic categories while loading
                                categoryNames = [
                                  l10n.categorySalary,
                                  l10n.categoryTransport,
                                  l10n.categoryInvestments,
                                  l10n.categoryHealth,
                                  l10n.categoryFood,
                                  l10n.categoryHousing,
                                  l10n.categoryLeisure,
                                  l10n.categoryEducation,
                                ];
                              }

                              return BlocBuilder<
                                QuickAddTransactionCubit,
                                QuickAddTransactionState
                              >(
                                buildWhen: (p, c) => p.category != c.category,
                                builder: (context, state) {
                                  // Ensure the current category is always in the list even if not yet in CategoryBloc data
                                  final displayCategories = List<String>.from(
                                    categoryNames,
                                  );
                                  if (state.category.isNotEmpty &&
                                      !displayCategories.contains(
                                        state.category,
                                      )) {
                                    displayCategories.add(state.category);
                                  }

                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ...displayCategories.map(
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
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.filterDate,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) => p.occurredAt != c.occurredAt,
                            builder: (context, state) {
                              return CustomDatePicker(
                                mode: picker.DatePickerMode.single,
                                initialStartDate: state.occurredAt,
                                placeholder: l10n.filterDate,
                                primaryColor: AppColors.primary,
                                onChanged: (start, end) {
                                  context
                                      .read<QuickAddTransactionCubit>()
                                      .occurredAtChanged(start);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) => p.description != c.description,
                            builder: (context, state) {
                              return TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText: l10n.quickAddTitleHint,
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
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<
                            QuickAddTransactionCubit,
                            QuickAddTransactionState
                          >(
                            buildWhen: (p, c) =>
                                p.isRecurring != c.isRecurring ||
                                p.frequency != c.frequency,
                            builder: (context, state) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.recurringTitle, // Or add a specific "Repeat" key
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      BlocProvider(
                                        create: (_) => AdaptiveSwitchCubit(
                                          initialValue: state.isRecurring,
                                        ),
                                        child: AdaptiveSwitch(
                                          semanticLabel: l10n.recurringTitle,
                                          onChanged: (v) => context
                                              .read<QuickAddTransactionCubit>()
                                              .setRecurring(v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.quickAddSaveTemplate,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      BlocProvider(
                                        create: (_) => AdaptiveSwitchCubit(
                                          initialValue: state.saveAsTemplate,
                                        ),
                                        child: AdaptiveSwitch(
                                          semanticLabel:
                                              l10n.quickAddSaveTemplate,
                                          onChanged: (v) => context
                                              .read<QuickAddTransactionCubit>()
                                              .setSaveAsTemplate(v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (state.isRecurring) ...[
                                    const SizedBox(height: 12),
                                    BlocProvider(
                                      create: (_) =>
                                          AdaptiveSegmentedControlCubit(
                                            initialIndex: state.frequency.index,
                                          ),
                                      child: AdaptiveSegmentedControl(
                                        semanticLabel:
                                            l10n.recurringFormFrequencyLabel,
                                        segments: [
                                          l10n.recurringFrequencyDaily,
                                          l10n.recurringFrequencyWeekly,
                                          l10n.recurringFrequencyMonthly,
                                        ],
                                        onChanged: (index) => context
                                            .read<QuickAddTransactionCubit>()
                                            .frequencyChanged(
                                              RecurrenceFrequency.values[index],
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: BlocProvider(
                                  create: (_) => AdaptiveButtonCubit(),
                                  child: AdaptiveButton(
                                    text: l10n.quickAddCamera,
                                    leadingIcon: Icons.camera_alt_outlined,
                                    variant: AdaptiveButtonVariant.outlined,
                                    primaryColor: AppColors.primary,
                                    onPressed: () =>
                                        _onPickImage(ImageSource.camera),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BlocProvider(
                                  create: (_) => AdaptiveButtonCubit(),
                                  child: AdaptiveButton(
                                    text: l10n.quickAddGallery,
                                    leadingIcon: Icons.image_outlined,
                                    variant: AdaptiveButtonVariant.outlined,
                                    primaryColor: AppColors.primary,
                                    onPressed: () =>
                                        _onPickImage(ImageSource.gallery),
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

  Widget _buildChip(
    TemplateModel template,
    bool isSelected,
    BuildContext context,
  ) {
    return BlocProvider(
      key: ValueKey('template_${template.id}'),
      create: (_) => AdaptiveChipCubit(initialSelected: isSelected),
      child: AdaptiveChip(
        label: template.description,
        isSelected: isSelected,
        variant: AdaptiveChipVariant.tonal,
        onPressed: () {
          context.read<QuickAddTransactionCubit>().applyTemplate(template);
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    bool isSelected,
    BuildContext context,
  ) {
    return BlocProvider(
      key: ValueKey('category_$label'),
      create: (_) => AdaptiveChipCubit(initialSelected: isSelected),
      child: AdaptiveChip(
        label: label,
        isSelected: isSelected,
        variant: AdaptiveChipVariant.tonal,
        onPressed: () {
          context.read<QuickAddTransactionCubit>().categoryChanged(label);
        },
      ),
    );
  }

  Widget _buildNewCategoryChip() {
    return BlocBuilder<QuickAddTransactionCubit, QuickAddTransactionState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        return BlocProvider(
          create: (_) => AdaptiveChipCubit(),
          child: AdaptiveChip(
            label: l10n.quickAddCategoryNew,
            variant: AdaptiveChipVariant.outlined,
            onPressed: () => CategoryFormSheet.show(
              context,
              onCategoryCreated: (name) => context
                  .read<QuickAddTransactionCubit>()
                  .categoryChanged(name),
            ),
          ),
        );
      },
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
                    style: TextStyle(
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
