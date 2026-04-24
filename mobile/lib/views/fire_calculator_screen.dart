import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/view_models/fire_calculator/fire_calculator_bloc.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip.dart';
import 'package:afc/widgets/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/widgets/custom_tooltip/custom_tooltip.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch.dart';
import 'package:afc/widgets/adaptive_switch/adaptive_switch_cubit.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:afc/widgets/action_card/action_card.dart';

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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora FIRE')),
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
                Text('Resultado', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _buildResults(context, state.result!),
                const SizedBox(height: AppSpacing.xl),
                _buildAboutFire(),
              ] else if (state.status == FireCalculatorStatus.failure)
                Text(
                  'Erro: ${state.errorMessage}',
                  style: const TextStyle(color: AppColors.error),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldWithTitle(
          label: 'Gastos mensais (R\$)',
          tooltipTitle: 'Gastos Mensais',
          tooltipDesc:
              'O custo total para manter seu padrão de vida atual. '
              'Quanto mais baixo, menor será seu Número FIRE.',
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
          label: 'Investimento mensal (R\$)',
          tooltipTitle: 'Aporte Mensal',
          tooltipDesc:
              'Quanto você economiza e investe todos os meses. '
              'Este é o motor que acelera sua independência financeira.',
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
          label: 'Patrimônio atual (R\$)',
          tooltipTitle: 'Patrimônio',
          tooltipDesc:
              'A soma de todos os seus investimentos atuais e saldo em conta.',
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
          label: 'Retorno anual esperado (%)',
          tooltipTitle: 'Rentabilidade',
          tooltipDesc:
              'A rentabilidade média estimada dos seus investimentos. '
              'Um valor conservador costuma ser entre 4% e 7% ao ano acima da inflação.',
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
          'Taxa de Retirada (SWR)',
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildSwrChip('Lean FIRE (3%)', 0.03),
            _buildSwrChip('Padrão (4%)', 0.04),
            _buildSwrChip('Fat FIRE (5%)', 0.05),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        BlocProvider(
          create: (_) => AdaptiveButtonCubit(),
          child: AdaptiveButton(text: 'Calcular', onPressed: _calculate),
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

  Widget _buildInflationToggle() {
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
                    'Ajuste de Inflação',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Valores em poder de compra de hoje',
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
                semanticLabel: 'Ajuste de Inflação',
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

  Widget _buildResults(BuildContext context, Map<String, dynamic> result) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final fireNumber = result['fireNumber'] as double;
    final monthsToFire = result['monthsToFire'] as int;
    final retirementDate = DateTime.parse(result['retirementDate'] as String);
    final yearlyTimeline = result['yearlyTimeline'] as List<dynamic>;

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
                  'Número FIRE',
                  currencyFormat.format(fireNumber),
                  isTeal: true,
                  hasInfo: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  'Tempo até FIRE',
                  '$years anos e $months meses',
                  isBold: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  'Data estimada',
                  DateFormat('MM/yyyy').format(retirementDate),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Trajetória do Portfólio', style: AppTextStyles.titleMedium),
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
                  child: _buildChart(yearlyTimeline, fireNumber),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Projeção até ${retirementDate.year + 20}',
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
                ),
                Text(
                  'Taxa de retirada segura: ${(_swr * 100).toInt()}% a.a.',
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
  }) {
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
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
            ],
          ],
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: isBold || isTeal ? FontWeight.bold : FontWeight.normal,
            color: isTeal ? const Color(0xFF00BFA5) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<dynamic> timeline, double fireNumber) {
    if (timeline.isEmpty) return const SizedBox.shrink();
    final spots = timeline.map((e) {
      return FlSpot(
        (e['year'] as num).toDouble(),
        (e['portfolioValue'] as num).toDouble(),
      );
    }).toList();

    const tealColor = Color(0xFF00BFA5);

    return LineChart(
      LineChartData(
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
                if (value == 0)
                  return const Text(
                    'R\$ 0',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  );
                if (value >= 1000000) {
                  return Text(
                    'R\$ ${(value / 1000000).toStringAsFixed(1)} mi',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return Text(
                  'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0)
                  return const Text(
                    'Hoje',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  );
                if (value % 10 == 0)
                  return Text(
                    'A${value.toInt()}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
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
                labelResolver: (line) => 'Hoje',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutFire() {
    return ActionCard(
      style: ActionCardStyle.iconHeader,
      title: 'O que é o Movimento FIRE?',
      description:
          'Financial Independence, Retire Early (Independência Financeira, Aposentadoria Precoce). '
          'O objetivo é acumular patrimônio suficiente para viver apenas dos rendimentos de seus investimentos.',
      leadingIcon: Icons.lightbulb_outline,
      buttonText: 'Saber mais',
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
          Text('Conceitos do FIRE', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildInfoItem(
            'Número FIRE',
            'É o valor total que você precisa ter investido para se aposentar. '
                'Geralmente calculado como 25x seus gastos anuais.',
          ),
          _buildInfoItem(
            'Regra dos 4% (SWR)',
            'Safe Withdrawal Rate (Taxa de Retirada Segura). É a porcentagem do seu patrimônio '
                'que você pode sacar anualmente sem que o dinheiro acabe.',
          ),
          _buildInfoItem(
            'Lean FIRE',
            'Foco em uma vida minimalista e gastos extremamente baixos para se aposentar mais rápido.',
          ),
          _buildInfoItem(
            'Fat FIRE',
            'Foco em manter um padrão de vida alto, exigindo um patrimônio muito maior.',
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
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
