import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/utils/config/app_icons.dart';
import 'package:afc/widgets/custom_list_tile/custom_list_tile.dart';

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
        ],
      ),
    );
  }
}
