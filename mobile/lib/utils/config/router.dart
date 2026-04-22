import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/view_models/auth/auth_bloc.dart';
import 'package:afc/views/login_screen.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/views/splash_screen.dart';
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

GoRouter createRouter(AuthBloc authBloc) {
  final refreshBloc = sl<AppRefreshBloc>();
  return GoRouter(
    navigatorKey: sl<NavigationService>().navigatorKey,
    initialLocation: '/',
    refreshListenable: Listenable.merge([
      _RouterRefreshStream(authBloc.stream),
      _RouterRefreshStream(refreshBloc.stream),
    ]),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      if (authState is AuthInitial) {
        return location == '/' ? null : '/';
      }
      if (authState is AuthSignedOut) {
        return location == '/login' ? null : '/login';
      }
      if (location == '/' || location == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
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
      GoRoute(path: '/import', builder: (_, _) => const ImportScreen()),
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
              GoRoute(path: '/limits', builder: (_, _) => const LimitScreen()),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recurring',
                builder: (_, _) => const RecurringListScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
