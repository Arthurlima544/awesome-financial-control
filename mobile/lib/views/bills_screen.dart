import 'package:afc/models/bill_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/bills/bill_bloc.dart';
import 'package:afc/widgets/circular_button/circular_button.dart';
import 'package:afc/widgets/circular_button/circular_button_cubit.dart';
import 'package:afc/widgets/bill_form_sheet/bill_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.billsTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(
                left: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
            ),
          ),
          BlocBuilder<BillBloc, BillState>(
            builder: (context, state) {
              if (state.status == BillStatus.loading && state.bills.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.bills.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l10n.billsNoBills,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final bill = state.bills[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _BillCard(
                        bill: bill,
                        currencyFormat: currencyFormat,
                        onTap: () => _showBillForm(context, bill),
                      ),
                    );
                  }, childCount: state.bills.length),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: BlocProvider(
        create: (_) => CircularButtonCubit(),
        child: CircularButton(
          icon: Icons.add,
          onPressed: () => _showBillForm(context),
          semanticLabel: l10n.add,
        ),
      ),
    );
  }

  void _showBillForm(BuildContext context, [BillModel? bill]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BillBloc>(),
        child: BillFormSheet(bill: bill),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final BillModel bill;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const _BillCard({
    required this.bill,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isOverdue = bill.dueDay < today.day;
    final isUpcoming = bill.dueDay >= today.day && bill.dueDay <= today.day + 3;

    Color statusColor;
    if (isOverdue) {
      statusColor = AppColors.error;
    } else if (isUpcoming) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.success;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOverdue ? Icons.priority_high : Icons.calendar_today,
                color: statusColor,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Dia ${bill.dueDay}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(bill.amount),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverdue ? AppColors.error : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
