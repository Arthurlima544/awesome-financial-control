import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/widgets/custom_tooltip/custom_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/view_models/compound_interest/compound_interest_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _initialController = TextEditingController();
  final _contributionController = TextEditingController();
  final _yearsController = TextEditingController(text: '10');
  final _rateController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _prepopulateData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  void _prepopulateData() {
    final investmentState = context.read<InvestmentBloc>().state;
    final homeState = context.read<HomeBloc>().state;

    if (investmentState.investments.isNotEmpty) {
      _initialController.text = investmentState.totalCurrentValue
          .toStringAsFixed(0);
    } else {
      _initialController.text = '1000';
    }

    if (homeState is HomeLoaded) {
      final income = homeState.summary.totalIncome;
      final expenses = homeState.summary.totalExpenses.abs();
      final savings = income - expenses;
      _contributionController.text = savings > 0
          ? savings.toStringAsFixed(0)
          : '500';
    } else {
      _contributionController.text = '500';
    }
  }

  void _calculate() {
    final initial = double.tryParse(_initialController.text) ?? 0;
    final contribution = double.tryParse(_contributionController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;
    final rate = (double.tryParse(_rateController.text) ?? 0) / 100;

    if (years > 0) {
      context.read<CompoundInterestBloc>().add(
        CalculateCompoundInterestRequested(
          initialAmount: initial,
          monthlyContribution: contribution,
          years: years,
          annualInterestRate: rate,
        ),
      );
    }
  }

  @override
  void dispose() {
    _initialController.dispose();
    _contributionController.dispose();
    _yearsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Juros Compostos')),
      body: BlocBuilder<CompoundInterestBloc, CompoundInterestState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _buildInputs(context),
              const SizedBox(height: AppSpacing.xl),
              if (state.status == CompoundInterestStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (state.status == CompoundInterestStatus.success) ...[
                Text('Resultado', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _buildResults(context, state.result!),
              ] else if (state.status == CompoundInterestStatus.failure)
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
          label: 'Investimento Inicial (R\$)',
          tooltipTitle: 'Capital Inicial',
          tooltipDesc: 'O valor que você já tem hoje para começar a investir.',
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 1000',
              controller: _initialController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.account_balance_wallet_outlined),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldWithTitle(
          label: 'Aporte Mensal (R\$)',
          tooltipTitle: 'Investimento Mensal',
          tooltipDesc: 'Quanto você planeja investir todos os meses.',
          child: BlocProvider(
            create: (_) => AdaptiveTextFieldCubit(),
            child: AdaptiveTextField(
              hintText: 'Ex: 500',
              controller: _contributionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              leadingIcon: const Icon(Icons.add_circle_outline),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _buildFieldWithTitle(
                label: 'Período (Anos)',
                tooltipTitle: 'Tempo',
                tooltipDesc:
                    'Por quanto tempo você pretende manter o investimento.',
                child: BlocProvider(
                  create: (_) => AdaptiveTextFieldCubit(),
                  child: AdaptiveTextField(
                    hintText: 'Ex: 10',
                    controller: _yearsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildFieldWithTitle(
                label: 'Taxa Anual (%)',
                tooltipTitle: 'Rentabilidade',
                tooltipDesc: 'A taxa de juros anual estimada.',
                child: BlocProvider(
                  create: (_) => AdaptiveTextFieldCubit(),
                  child: AdaptiveTextField(
                    hintText: 'Ex: 10',
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        BlocProvider(
          create: (_) => AdaptiveButtonCubit(),
          child: AdaptiveButton(text: 'Simular', onPressed: _calculate),
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

  Widget _buildResults(BuildContext context, Map<String, dynamic> result) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final finalAmount = result['finalAmount'] as double;
    final totalInvested = result['totalInvested'] as double;
    final totalInterest = result['totalInterest'] as double;
    final timeline = result['timeline'] as List<dynamic>;

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
                  'Valor Final',
                  currencyFormat.format(finalAmount),
                  isTeal: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  'Total Investido',
                  currencyFormat.format(totalInvested),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildResultRow(
                  'Total em Juros',
                  currencyFormat.format(totalInterest),
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Evolução do Patrimônio', style: AppTextStyles.titleMedium),
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
                SizedBox(height: 250, child: _buildChart(timeline)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _buildLegendItem(const Color(0xFF00BFA5), 'Acumulado'),
                    const SizedBox(width: AppSpacing.md),
                    _buildLegendItem(Colors.grey.shade400, 'Investido'),
                  ],
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: Colors.grey.shade700),
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildChart(List<dynamic> timeline) {
    if (timeline.isEmpty) return const SizedBox.shrink();

    final accumulatedSpots = timeline.map((e) {
      return FlSpot(
        (e['year'] as num).toDouble(),
        (e['accumulated'] as num).toDouble(),
      );
    }).toList();

    final investedSpots = timeline.map((e) {
      return FlSpot(
        (e['year'] as num).toDouble(),
        (e['invested'] as num).toDouble(),
      );
    }).toList();

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
                return Text(
                  'A${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: accumulatedSpots,
            isCurved: true,
            color: const Color(0xFF00BFA5),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
            ),
          ),
          LineChartBarData(
            spots: investedSpots,
            isCurved: true,
            color: Colors.grey.shade400,
            barWidth: 2,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
