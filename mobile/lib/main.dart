import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:afc/utils/config/app_theme.dart';
import 'package:afc/utils/config/router.dart';
import 'package:afc/view_models/auth/auth_bloc.dart';
import 'package:afc/view_models/theme/theme_cubit.dart';
import 'package:afc/view_models/onboarding/onboarding_cubit.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/view_models/recurring/recurring_bloc.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/view_models/privacy/privacy_cubit.dart';

import 'package:afc/utils/config/injection.dart' as di;
import 'package:afc/utils/config/injection.dart';

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
  late final OnboardingCubit _onboardingCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _onboardingCubit = sl<OnboardingCubit>()..loadOnboardingStatus();
    _router = createRouter(_authBloc, _onboardingCubit);
    _authBloc.add(const AppLaunched());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _onboardingCubit),
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider(
          create: (_) =>
              sl<CategoryBloc>()..add(const CategoryFetchRequested()),
        ),
        BlocProvider(create: (_) => sl<RecurringBloc>()..add(LoadRecurring())),
        BlocProvider(
          create: (_) => sl<HomeBloc>()..add(const HomeDashboardLoaded()),
        ),
        BlocProvider(
          create: (_) => sl<InvestmentBloc>()..add(LoadInvestments()),
        ),
        BlocProvider.value(value: sl<PrivacyCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'AFC',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: _router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
          );
        },
      ),
    );
  }
}
