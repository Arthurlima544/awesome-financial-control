import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/splash_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/limit/view/limit_screen.dart';
import '../features/shell/view/scaffold_shell.dart';
import '../features/stats/view/stats_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldShell(navigationShell: navigationShell),
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
