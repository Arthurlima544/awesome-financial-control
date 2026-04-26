import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/view_models/fire_calculator/fire_calculator_bloc.dart';
import 'package:afc/models/fire_calculator_result.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch_cubit.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/action_card/action_card.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/widgets/app_tooltip_icon/app_tooltip_icon.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/services/currency_service.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/currency_formatter.dart';
import 'package:afc/models/currency.dart';
import 'package:afc/widgets/error_state/error_state.dart';

class FireCalculatorScreen extends StatefulWidget {
  const FireCalculatorScreen({super.key});

  @override
  State<FireCalculatorScreen> createState() => _FireCalculatorScreenState();
}

class _FireCalculatorScreenState extends State<FireCalculatorScreen> {
  final _expensesController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _savingsController = TextEditingController();
  final _returnController = TextEditingController(text: '7');
  double _swr = 0.04;
  bool _adjustForInflation = false;

  @override
  void initState() {
    super.initState();
    _prepopulateData();
    // Auto-calculate on entry
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  void _prepopulateData() {
    final investmentState = context.read<InvestmentBloc>().state;
    final homeState = context.read<HomeBloc>().state;

    if (investmentState.investments.isNotEmpty) {
      _portfolioController.text = investmentState.totalCurrentValue
          .toStringAsFixed(0);
    }

    if (homeState is HomeLoaded) {
      _expensesController.text = homeState.summary.totalExpenses
          .abs()
          .toStringAsFixed(0);

      final income = homeState.summary.totalIncome;
      final expenses = homeState.summary.totalExpenses.abs();
      final savings = income - expenses;

      _savingsController.text = savings > 0
          ? savings.toStringAsFixed(0)
          : '1000';
    }

    if (_expensesController.text.isEmpty) _expensesController.text = '3000';
    if (_portfolioController.text.isEmpty) _portfolioController.text = '0';
    if (_savingsController.text.isEmpty) _savingsController.text = '500';
  }

  @override
  void dispose() {
    _expensesController.dispose();
    _portfolioController.dispose();
    _savingsController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _calculate() {
    final expenses = double.tryParse(_expensesController.text) ?? 0;
    final portfolio = double.tryParse(_portfolioController.text) ?? 0;
    final savings = double.tryParse(_savingsController.text) ?? 0;
    final annualReturn = (double.tryParse(_returnController.text) ?? 0) / 100;

    if (expenses > 0 && annualReturn > 0) {
      context.read<FireCalculatorBloc>().add(
        FireCalculationRequested(
          monthlyExpenses: expenses,
          currentPortfolio: portfolio,
          monthlySavings: savings,
          annualReturnRate: annualReturn,
          safeWithdrawalRate: _swr,
          adjustForInflation: _adjustForInflation,
        ),
      );
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
          appBar: AppBar(title: Text(l10n.fireCalcTitle)),
          body: BlocBuilder<FireCalculatorBloc, FireCalculatorState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _buildInputs(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInflationToggle(),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.status == FireCalculatorStatus.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.status == FireCalculatorStatus.success) ...[
                    Text(
                      l10n.calcResultTitle,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildResults(
                      context,
                      state.result!,
                      currency,
                      currencyService,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildAboutFire(),
                  ] else if (state.status == FireCalculatorStatus.failure)
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
          label: l10n.fireCalcExpensesLabel,
          tooltipTitle: l10n.fireCalcExpensesTooltipTitle,
          tooltipDesc: l10n.fireCalcExpensesTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 3000',
              controller: _expensesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: l10n.fireCalcSavingsLabel,
          tooltipTitle: l10n.fireCalcSavingsTooltipTitle,
          tooltipDesc: l10n.fireCalcSavingsTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 1000',
              controller: _savingsController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.trending_up),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: l10n.fireCalcPortfolioLabel,
          tooltipTitle: l10n.fireCalcPortfolioTooltipTitle,
          tooltipDesc: l10n.fireCalcPortfolioTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 10000',
              controller: _portfolioController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: l10n.fireCalcReturnLabel,
          tooltipTitle: l10n.calcRentabilidadeTooltipTitle,
          tooltipDesc: l10n.fireCalcReturnTooltipDesc,
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 7',
              controller: _returnController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.percent),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.fireCalcSwrLabel,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildSwrChip(l10n.fireCalcSwrLeanChip, 0.03),
            _buildSwrChip(l10n.fireCalcSwrStandardChip, 0.04),
            _buildSwrChip(l10n.fireCalcSwrFatChip, 0.05),
          ],
        ),
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
            AppTooltipIcon(
              title: tooltipTitle,
              description: tooltipDesc,
              iconSize: 16,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }

  Widget _buildInflationToggle() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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

  Widget _buildSwrChip(String label, double value) {
    return BlocProvider(
      create: (_) => AdaptiveChipCubit(initialSelected: _swr == value),
      child: AdaptiveChip(
        label: label,
        isSelected: _swr == value,
        onPressed: () => setState(() => _swr = value),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    FireCalculatorResult result,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final fireNumber = result.fireNumber;
    final monthsToFire = result.monthsToFire;
    final retirementDate = result.retirementDate;
    final yearlyTimeline = result.yearlyTimeline;

    final years = monthsToFire ~/ 12;
    final months = monthsToFire % 12;

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
                  l10n.fireCalcFireNumberLabel,
                  CurrencyFormatter.format(
                    currencyService.convert(fireNumber, currency),
                    currency,
                  ),
                  isTeal: true,
                  hasInfo: true,
                  isPrivate: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  l10n.fireCalcTimeToFireLabel,
                  l10n.fireCalcTimeToFireValue(years, months),
                  isBold: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  l10n.fireCalcEstimatedDateLabel,
                  DateFormat('MM/yyyy').format(retirementDate),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  l10n.tooltipFIScoreTitle,
                  '${result.fiScore.toStringAsFixed(1)}%',
                  isBold: true,
                  hasInfo: true,
                  tooltipDesc: l10n.tooltipFIScoreDesc,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.fireCalcChartTitle, style: AppTextStyles.titleMedium),
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
                  child: _buildChart(
                    yearlyTimeline,
                    fireNumber,
                    currency,
                    currencyService,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.fireCalcChartProjectionLabel(retirementDate.year + 20),
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                ),
                Text(
                  l10n.fireCalcChartSwrLabel((_swr * 100).toInt()),
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                ),
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
    bool hasInfo = false,
    bool isPrivate = false,
    String? tooltipDesc,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            if (hasInfo) ...[
              const SizedBox(width: 4),
              AppTooltipIcon(
                title: label,
                description:
                    tooltipDesc ??
                    (label == l10n.fireCalcFireNumberLabel
                        ? l10n.tooltipFIREDesc
                        : ''),
                iconSize: 14,
              ),
            ],
          ],
        ),
        isPrivate
            ? PrivacyText(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: isBold || isTeal
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isTeal ? AppColors.primary : Colors.black87,
                ),
              )
            : Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: isBold || isTeal
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isTeal ? AppColors.primary : Colors.black87,
                ),
              ),
      ],
    );
  }

  Widget _buildChart(
    List<FireTimelinePoint> timeline,
    double fireNumber,
    Currency currency,
    CurrencyService currencyService,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (timeline.isEmpty) return const SizedBox.shrink();
    final spots = timeline.map((e) {
      return FlSpot(e.year, e.portfolioValue);
    }).toList();

    final tealColor = AppColors.primary;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.withValues(alpha: 0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  CurrencyFormatter.format(
                    currencyService.convert(spot.y, currency),
                    currency,
                  ),
                  const TextStyle(color: Colors.white, fontSize: 10),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                final symbol = currency.symbol;
                if (value == 0) {
                  return PrivacyText(
                    '$symbol 0',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                if (value >= 1000000) {
                  return PrivacyText(
                    '$symbol ${(value / 1000000).toStringAsFixed(1)} mi',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return PrivacyText(
                  '$symbol ${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return Text(
                    l10n.calcChartTodayLabel,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                if (value % 10 == 0) {
                  return Text(
                    l10n.calcChartYearLabel(value.toInt()),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: tealColor,
            barWidth: 2,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, fireNumber),
              FlSpot(spots.isNotEmpty ? spots.last.x : 50, fireNumber),
            ],
            dashArray: [5, 5],
            color: tealColor.withValues(alpha: 0.5),
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: 0,
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (line) => l10n.calcChartTodayLabel,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutFire() {
    final l10n = AppLocalizations.of(context)!;
    return ActionCard(
      style: ActionCardStyle.iconHeader,
      title: l10n.fireCalcAboutCardTitle,
      description: l10n.fireCalcAboutCardDesc,
      leadingIcon: Icons.lightbulb_outline,
      buttonText: l10n.fireCalcAboutCardButton,
      onAction: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => _FireExplanationSheet(),
        );
      },
    );
  }
}

class _FireExplanationSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fireCalcSheetTitle, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildInfoItem(
            l10n.fireCalcSheetFireNumberTitle,
            l10n.fireCalcSheetFireNumberDesc,
          ),
          _buildInfoItem(l10n.fireCalcSheetSwrTitle, l10n.fireCalcSheetSwrDesc),
          _buildInfoItem(
            l10n.fireCalcSheetLeanTitle,
            l10n.fireCalcSheetLeanDesc,
          ),
          _buildInfoItem(l10n.fireCalcSheetFatTitle, l10n.fireCalcSheetFatDesc),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.calcButtonEntendi),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
