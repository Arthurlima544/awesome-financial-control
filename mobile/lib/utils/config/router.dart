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
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) =>
            _buildSlideTransitionPage(context, state, const CategoryScreen()),
        routes: [
          GoRoute(
            path: ':id/edit',
            pageBuilder: (context, state) => _buildSlideTransitionPage(
              context,
              state,
              BlocProvider.value(
                value: state.extra! as CategoryBloc,
                child: CategoryEditScreen(
                  categoryId: state.pathParameters['id']!,
                ),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/limits/manage',
        pageBuilder: (context, state) =>
            _buildSlideTransitionPage(context, state, const LimitListScreen()),
        routes: [
          GoRoute(
            path: ':id/edit',
            pageBuilder: (context, state) => _buildSlideTransitionPage(
              context,
              state,
              BlocProvider.value(
                value: state.extra! as LimitListBloc,
                child: LimitEditScreen(limitId: state.pathParameters['id']!),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        pageBuilder: (context, state) => _buildSlideTransitionPage(
          context,
          state,
          BlocProvider.value(
            value: state.extra! as TransactionListBloc,
            child: TransactionEditScreen(
              transactionId: state.pathParameters['id']!,
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/investments',
        pageBuilder: (context, state) => _buildSlideTransitionPage(
          context,
          state,
          BlocProvider(
            create: (_) => sl<InvestmentBloc>()..add(LoadInvestments()),
            child: const InvestmentsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/import',
        pageBuilder: (context, state) =>
            _buildSlideTransitionPage(context, state, const ImportScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BlocProvider<HomeBloc>(
          create: (_) => HomeBloc()..add(const HomeDashboardLoaded()),
          child: Builder(
            builder: (innerContext) => ScaffoldShell(
              navigationShell: navigationShell,
              onHomeTabReactivated: () => innerContext.read<HomeBloc>().add(
                const HomeDashboardLoaded(),
              ),
            ),
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TransactionListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/limits',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: LimitScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: StatsScreen()),
                routes: [
                  GoRoute(
                    path: 'report',
                    pageBuilder: (context, state) => _buildSlideTransitionPage(
                      context,
                      state,
                      const ReportScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recurring',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: RecurringListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/goals',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: GoalsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bills',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: BlocProvider(
                    create: (_) => sl<BillBloc>()..add(const LoadBills()),
                    child: const BillsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage _buildSlideTransitionPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
