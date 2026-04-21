import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'config/app_theme.dart';
import 'config/router.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'l10n/generated/app_localizations.dart';

import 'config/injection.dart' as di;
import 'config/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const AfcApp());
}

class AfcApp extends StatefulWidget {
  const AfcApp({super.key});

  @override
  State<AfcApp> createState() => _AfcAppState();
}

class _AfcAppState extends State<AfcApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _router = createRouter(_authBloc);
    _authBloc.add(const AppLaunched());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'AFC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
      ),
    );
  }
}
