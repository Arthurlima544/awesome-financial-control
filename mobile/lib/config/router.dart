import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/view/login_screen.dart';
import '../features/home/bloc/home_bloc.dart';
import '../features/auth/view/splash_screen.dart';
import '../features/category/bloc/category_bloc.dart';
import '../features/category/view/category_edit_screen.dart';
import '../features/category/view/category_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/limit/view/limit_screen.dart';
import '../features/limit_list/bloc/limit_list_bloc.dart';
import '../features/limit_list/view/limit_edit_screen.dart';
import '../features/limit_list/view/limit_list_screen.dart';
import '../features/shell/view/scaffold_shell.dart';
import '../features/stats/view/stats_screen.dart';
import '../features/transaction_list/bloc/transaction_list_bloc.dart';
import '../features/transaction_list/view/transaction_edit_screen.dart';
import '../features/transaction_list/view/transaction_list_screen.dart';

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
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefreshStream(authBloc.stream),
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
              GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}
