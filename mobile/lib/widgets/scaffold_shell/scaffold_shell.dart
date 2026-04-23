import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_icons.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/widgets/quick_add_transaction_sheet/quick_add_transaction_sheet.dart';

class ScaffoldShell extends StatefulWidget {
  const ScaffoldShell({
    super.key,
    required this.navigationShell,
    this.onHomeTabReactivated,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback? onHomeTabReactivated;

  @override
  State<ScaffoldShell> createState() => _ScaffoldShellState();
}

class _ScaffoldShellState extends State<ScaffoldShell> {
  void _onDestinationSelected(int index) {
    final wasOnOtherTab = widget.navigationShell.currentIndex != 0;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    if (index == 0 && wasOnOtherTab) {
      widget.onHomeTabReactivated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: widget.navigationShell.currentIndex <= 1
          ? FloatingActionButton(
              heroTag: 'shell_fab',
              onPressed: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const QuickAddTransactionSheet(),
                );
                if (result == true) {
                  HapticFeedback.lightImpact();
                  if (context.mounted) {
                    context.read<HomeBloc>().add(const HomeDashboardLoaded());
                  }
                }
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              tooltip: l10n.fabAddTransaction,
              child: const Icon(AppIcons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(AppIcons.homeOutlined),
            selectedIcon: const Icon(AppIcons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.transactionsOutlined),
            selectedIcon: const Icon(AppIcons.transactions),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: l10n.navPlanning,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.statsOutlined),
            selectedIcon: const Icon(AppIcons.stats),
            label: l10n.navStats,
          ),
        ],
      ),
    );
  }
}
