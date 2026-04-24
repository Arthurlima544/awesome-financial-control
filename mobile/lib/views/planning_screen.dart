import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/utils/config/app_icons.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/widgets/custom_list_tile/custom_list_tile.dart';
import 'package:afc/widgets/planning_quick_add_sheet/planning_quick_add_sheet.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPlanning)),
      body: ListView(
        children: [
          CustomListTile(
            title: l10n.limitTitle,
            leadingIcon: AppIcons.limits,
            onTap: () => context.push('/limits'),
          ),
          CustomListTile(
            title: l10n.goalsTitle,
            leadingIcon: AppIcons.goals,
            onTap: () => context.push('/goals'),
          ),
          CustomListTile(
            title: l10n.billsTitle,
            leadingIcon: AppIcons.bills,
            onTap: () => context.push('/bills'),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text('Calculadoras', style: AppTextStyles.titleSmall),
          ),
          CustomListTile(
            title: 'Calculadora FIRE',
            leadingIcon: Icons.local_fire_department,
            onTap: () => context.push('/fire-calculadora'),
          ),
          CustomListTile(
            title: 'Juros Compostos',
            leadingIcon: Icons.trending_up,
            onTap: () => context.push('/juros-compostos'),
          ),
          CustomListTile(
            title: 'Análise de Investimentos',
            leadingIcon: Icons.analytics_outlined,
            onTap: () => context.push('/investments/dashboard'),
          ),
          CustomListTile(
            title: 'Renda Passiva',
            leadingIcon: Icons.monetization_on_outlined,
            onTap: () => context.push('/passive-income'),
          ),
          CustomListTile(
            title: 'Evolução do Patrimônio',
            leadingIcon: Icons.show_chart_outlined,
            onTap: () => context.push('/net-worth'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PlanningQuickAddSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
