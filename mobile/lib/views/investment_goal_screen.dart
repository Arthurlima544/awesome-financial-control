import 'package:afc/models/investment_goal.dart';
import 'package:afc/utils/app_formatters.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/view_models/investment_goal/investment_goal_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/widgets/custom_tooltip/custom_tooltip.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/currency.dart';
import 'package:afc/widgets/error_state/error_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/action_card/action_card.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';

import 'package:afc/widgets/finance_line_chart/finance_line_chart.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch_cubit.dart';

class InvestmentGoalScreen extends StatefulWidget {
  const InvestmentGoalScreen({super.key});

  @override
  State<InvestmentGoalScreen> createState() => _InvestmentGoalScreenState();
}

class _InvestmentGoalScreenState extends State<InvestmentGoalScreen> {
  final _targetAmountController = TextEditingController(text: '1000000');
  final _initialAmountController = TextEditingController(text: '0');
  final _returnController = TextEditingController(text: '10');
  DateTime _targetDate = DateTime.now().plusYears(20);
  bool _adjustForInflation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  @override
  void dispose() {
    _targetAmountController.dispose();
    _initialAmountController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _calculate() {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final initialAmount = double.tryParse(_initialAmountController.text) ?? 0;
    final annualReturn = (double.tryParse(_returnController.text) ?? 0) / 100;

    if (targetAmount > 0) {
      context.read<InvestmentGoalBloc>().add(
        CalculateInvestmentGoalRequested(
          targetAmount: targetAmount,
          targetDate: _targetDate,
          annualReturnRate: annualReturn,
          initialAmount: initialAmount,
          adjustForInflation: _adjustForInflation,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
      _calculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final currency = settingsState.selectedCurrency;
        final currencyService = sl<CurrencyService>();

        return Scaffold(
          appBar: AppBar(title: Text(l10n.investmentGoalCalcTitle)),
          body: BlocBuilder<InvestmentGoalBloc, InvestmentGoalState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _buildInputs(context),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.status == InvestmentGoalStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.status == InvestmentGoalStatus.success) ...[
                    Text(
                      l10n.calcResultTitle,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildResults(
                      context,
                      state.response!,
                      currency,
                      currencyService,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildGoalInfo(),
                  ] else if (state.status == InvestmentGoalStatus.failure)
                    ErrorState(
                      message: l10n.calcErrorMessage(state.errorMessage ?? ''),
                      onRetry: _calculate,
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInputs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldWithTitle(
          label: l10n.investmentGoalCalcTargetLabel,
          tooltipTitle: l10n.investmentGoalCalcTargetTooltipTitle,
          tooltipDesc: l10n.investmentGoalCalcTargetTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 1000000',
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.stars),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: l10n.investmentGoalCalcDateLabel,
          tooltipTitle: l10n.investmentGoalCalcDateTooltipTitle,
          tooltipDesc: l10n.investmentGoalCalcDateTooltipDesc,
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    AppFormatters.monthYearFull.format(_targetDate),
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: l10n.investmentGoalCalcInitialLabel,
          tooltipTitle: l10n.calcCapitalInicialTooltipTitle,
          tooltipDesc: l10n.investmentGoalCalcInitialTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 0',
              controller: _initialAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: l10n.investmentGoalCalcReturnLabel,
          tooltipTitle: l10n.calcRentabilidadeTooltipTitle,
          tooltipDesc: l10n.investmentGoalCalcReturnTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 10',
              controller: _returnController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.percent),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildInflationToggle(),
        const SizedBox(height: AppSpacing.xl),
        BlocProvider(
          create: (_) => AdaptiveButtonCubit(),
          child: AdaptiveButton(
            text: l10n.calcButtonCalcular,
            onPressed: _calculate,
          ),
        ),
      ],
    );
  }

  Widget _buildInflationToggle() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.calcInflationToggleLabel,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.calcInflationToggleSubtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            BlocProvider(
              create: (_) =>
                  AdaptiveSwitchCubit(initialValue: _adjustForInflation),
              child: AdaptiveSwitch(
                semanticLabel: l10n.calcInflationToggleLabel,
                onChanged: (value) {
                  setState(() => _adjustForInflation = value);
                  _calculate();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWithTitle({
    required String label,
    required String tooltipTitle,
    required String tooltipDesc,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            CustomTooltip(
              title: tooltipTitle,
              description: tooltipDesc,
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }

  Widget _buildResults(
    BuildContext context,
    InvestmentGoalResponse response,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildResultRow(
                  l10n.investmentGoalCalcMonthlyContributionLabel,
                  CurrencyFormatter.format(
                    currencyService.convert(
                      response.requiredMonthlyContribution,
                      currency,
                    ),
                    currency,
                  ),
                  isTeal: true,
                  isBold: true,
                ),
                const Divider(height: AppSpacing.xl),
                _buildResultRow(
                  l10n.investmentGoalCalcTotalContributedLabel,
                  CurrencyFormatter.format(
                    currencyService.convert(
                      response.totalContributed,
                      currency,
                    ),
                    currency,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  l10n.investmentGoalCalcTotalInterestLabel,
                  CurrencyFormatter.format(
                    currencyService.convert(
                      response.totalInterestEarned,
                      currency,
                    ),
                    currency,
                  ),
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.calcPatrimonioEvolutionTitle,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 250,
                  child: FinanceLineChart(
                    lineBarsData: [
                      LineChartBarData(
                        spots: response.timeline.map((e) {
                          return FlSpot(
                            e.years,
                            currencyService.convert(e.accumulated, currency),
                          );
                        }).toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    currency: currency,
                    bottomTitleWidget: (value, meta) {
                      if (value == 0) {
                        return Text(
                          l10n.calcChartTodayLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      }
                      if (value % 5 == 0) {
                        return Text(
                          l10n.calcChartYearLabel(value.toInt()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildCompositionBar(response),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isTeal = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: Colors.grey.shade700),
        ),
        PrivacyText(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: isBold || isTeal ? FontWeight.bold : FontWeight.normal,
            color: isTeal ? AppColors.primary : (valueColor ?? Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildCompositionBar(InvestmentGoalResponse response) {
    final l10n = AppLocalizations.of(context)!;
    final total = response.totalContributed + response.totalInterestEarned;
    final investedPercent = response.totalContributed / total;
    final interestPercent = response.totalInterestEarned / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.investmentGoalCalcCompositionBarTitle,
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.shade200,
          ),
          child: Row(
            children: [
              Flexible(
                flex: (investedPercent * 100).toInt(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: (interestPercent * 100).toInt(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(
              l10n.investmentGoalCalcLegendContributions,
              Colors.grey,
            ),
            _buildLegendItem(
              l10n.investmentGoalCalcLegendInterest,
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGoalInfo() {
    final l10n = AppLocalizations.of(context)!;
    return ActionCard(
      style: ActionCardStyle.iconHeader,
      title: l10n.investmentGoalCalcInfoCardTitle,
      description: l10n.investmentGoalCalcInfoCardDesc,
      leadingIcon: Icons.insights,
      buttonText: l10n.calcButtonEntendi,
      primaryColor: AppColors.primary,
      onAction: () {},
    );
  }
}

extension DateTimeExtensions on DateTime {
  DateTime plusYears(int years) => DateTime(year + years, month, day);
}
