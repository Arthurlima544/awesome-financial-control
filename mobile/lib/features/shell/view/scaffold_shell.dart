import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/bloc/home_bloc.dart';
import '../../transaction_list/view/quick_add_transaction_sheet.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const QuickAddTransactionSheet(),
          );
          if (result == true) {
            HapticFeedback.lightImpact();
            // We use the same read<HomeBloc>() as in onHomeTabReactivated
            if (context.mounted) {
              context.read<HomeBloc>().add(const HomeDashboardLoaded());
            }
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: l10n.fabAddTransaction,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.price_change_outlined),
            selectedIcon: const Icon(Icons.price_change),
            label: l10n.navLimits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navStats,
          ),
        ],
      ),
    );
  }
}
