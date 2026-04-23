import 'package:afc/utils/config/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/widgets/scaffold_shell/scaffold_shell.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';

GoRouter _buildRouter({int initialIndex = 0}) {
  final paths = ['/home', '/transactions', '/planning', '/stats'];
  final labels = ['Home', 'Transactions', 'Planning', 'Stats'];

  return GoRouter(
    initialLocation: paths[initialIndex],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldShell(navigationShell: navigationShell),
        branches: List.generate(
          paths.length,
          (i) => StatefulShellBranch(
            routes: [
              GoRoute(
                path: paths[i],
                builder: (_, _) => Scaffold(
                  body: Center(
                    key: ValueKey('screen_$i'),
                    child: Text(labels[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildApp({int initialIndex = 0}) {
  return MaterialApp.router(
    routerConfig: _buildRouter(initialIndex: initialIndex),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  group('ScaffoldShell', () {
    testWidgets('renders NavigationBar with 4 destinations', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('shows all tab labels', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Transações'), findsOneWidget);
      expect(find.text('Planejamento'), findsOneWidget);
      expect(find.text('Gráficos'), findsOneWidget);
    });

    testWidgets('shows FloatingActionButton', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(AppIcons.add), findsOneWidget);
    });

    testWidgets('initial selected index is 0 (Home)', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('screen_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('screen_1')), findsNothing);
    });

    testWidgets('tapping index 1 navigates to Transactions', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transações'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('screen_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('screen_0')), findsNothing);
    });

    testWidgets('tapping index 3 navigates to Stats', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gráficos'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('screen_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('screen_0')), findsNothing);
    });
  });
}
