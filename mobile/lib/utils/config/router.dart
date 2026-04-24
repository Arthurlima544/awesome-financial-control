import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/view_models/auth/auth_bloc.dart';
import 'package:afc/views/login_screen.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/views/splash_screen.dart';
import 'package:afc/view_models/onboarding/onboarding_cubit.dart';
import 'package:afc/views/onboarding_screen.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/views/category_edit_screen.dart';
import 'package:afc/views/category_screen.dart';
import 'package:afc/views/home_screen.dart';
import 'package:afc/views/limit_screen.dart';
import 'package:afc/view_models/limit_list/limit_list_bloc.dart';
import 'package:afc/views/limit_edit_screen.dart';
import 'package:afc/views/limit_list_screen.dart';
import 'package:afc/widgets/scaffold_shell/scaffold_shell.dart';
import 'package:afc/views/stats_screen.dart';
import 'package:afc/view_models/transaction_list/transaction_list_bloc.dart';
import 'package:afc/views/transaction_edit_screen.dart';
import 'package:afc/views/transaction_list_screen.dart';
import 'package:afc/views/recurring_list_screen.dart';
import 'package:afc/views/import_screen.dart';
import 'package:afc/views/report_screen.dart';
import 'package:afc/views/goals_screen.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/views/investments_screen.dart';
import 'package:afc/view_models/bills/bill_bloc.dart';
import 'package:afc/views/bills_screen.dart';
import 'package:afc/views/settings_screen.dart';
import 'package:afc/views/planning_screen.dart';
import 'package:afc/views/fire_calculator_screen.dart';
import 'package:afc/view_models/fire_calculator/fire_calculator_bloc.dart';
import 'package:afc/views/compound_interest_screen.dart';
import 'package:afc/view_models/compound_interest/compound_interest_bloc.dart';

import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/utils/config/injection.dart';

class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc, OnboardingCubit onboardingCubit) {
  final refreshBloc = sl<AppRefreshBloc>();
  return GoRouter(
    navigatorKey: sl<NavigationService>().navigatorKey,
    initialLocation: '/',
    refreshListenable: Listenable.merge([
      _RouterRefreshStream(authBloc.stream),
      _RouterRefreshStream(refreshBloc.stream),
      _RouterRefreshStream(onboardingCubit.stream),
    ]),
    redirect: (context, state) {
      final authState = authBloc.state;
      final onboardingState = onboardingCubit.state;
      final location = state.matchedLocation;

      // 1. Loading / Initializing
      if (authState is AuthInitial || onboardingState.isLoading) {
        return location == '/' ? null : '/';
      }

      // 2. Onboarding Guard
      final isOnboarding = location == '/onboarding';
      if (!onboardingState.isCompleted) {
        return isOnboarding ? null : '/onboarding';
      }

      // 3. Post-Onboarding: If still on onboarding route, move to next destination
      if (isOnboarding) {
        return authState is AuthSignedIn ? '/home' : '/login';
      }

      // 4. Authentication Guard
      if (authState is AuthSignedOut) {
        return location == '/login' ? null : '/login';
      }

      if (authState is AuthSignedIn &&
          (location == '/' || location == '/login')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/categories',
        builder: (_, _) => const CategoryScreen(),
        routes: [
          GoRoute(
            path: ':id/edit',
            builder: (_, state) => BlocProvider.value(
              value: state.extra! as CategoryBloc,
              child: CategoryEditScreen(
                categoryId: state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/limits/manage',
        builder: (_, _) => const LimitListScreen(),
        routes: [
          GoRoute(
            path: ':id/edit',
            builder: (_, state) => BlocProvider.value(
              value: state.extra! as LimitListBloc,
              child: LimitEditScreen(limitId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        builder: (_, state) => BlocProvider.value(
          value: state.extra! as TransactionListBloc,
          child: TransactionEditScreen(
            transactionId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/investments',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<InvestmentBloc>()..add(LoadInvestments()),
          child: const InvestmentsScreen(),
        ),
      ),
      GoRoute(path: '/import', builder: (_, _) => const ImportScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/limits', builder: (_, _) => const LimitScreen()),
      GoRoute(path: '/goals', builder: (_, _) => const GoalsScreen()),
      GoRoute(
        path: '/fire-calculadora',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<FireCalculatorBloc>(),
          child: const FireCalculatorScreen(),
        ),
      ),
      GoRoute(
        path: '/juros-compostos',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<CompoundInterestBloc>(),
          child: const CompoundInterestScreen(),
        ),
      ),
      GoRoute(
        path: '/bills',
        builder: (_, _) => BlocProvider(
          create: (_) => sl<BillBloc>()..add(const LoadBills()),
          child: const BillsScreen(),
        ),
      ),
      GoRoute(
        path: '/recurring',
        builder: (_, _) => const RecurringListScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldShell(
          navigationShell: navigationShell,
          onHomeTabReactivated: () =>
              context.read<HomeBloc>().add(const HomeDashboardLoaded()),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (_, _) => const TransactionListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planning',
                builder: (_, _) => const PlanningScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (_, _) => const StatsScreen(),
                routes: [
                  GoRoute(
                    path: 'report',
                    builder: (_, _) => const ReportScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
