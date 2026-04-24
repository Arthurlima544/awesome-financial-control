import 'package:get_it/get_it.dart';
import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/repositories/category_repository.dart';
import 'package:afc/repositories/dev_tools_repository.dart';
import 'package:afc/view_models/bills/bill_bloc.dart';
import 'package:afc/view_models/health_score/health_score_bloc.dart';
import 'package:afc/view_models/home/home_bloc.dart';
import 'package:afc/repositories/home_repository.dart';
import 'package:afc/view_models/limit/limit_bloc.dart';
import 'package:afc/repositories/limit_repository.dart';
import 'package:afc/view_models/limit_list/limit_list_bloc.dart';
import 'package:afc/repositories/limit_list_repository.dart';
import 'package:afc/view_models/stats/stats_bloc.dart';
import 'package:afc/repositories/stats_repository.dart';
import 'package:afc/view_models/transaction_list/transaction_list_bloc.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/repositories/template_repository.dart';
import 'package:afc/view_models/recurring/recurring_bloc.dart';
import 'package:afc/view_models/auth/auth_bloc.dart';
import 'package:afc/services/import_parser_service.dart';
import 'package:afc/services/receipt_service.dart';
import 'package:afc/view_models/import/import_bloc.dart';
import 'package:afc/repositories/report_repository.dart';
import 'package:afc/view_models/report/report_bloc.dart';
import 'package:afc/repositories/bill_repository.dart';
import 'package:afc/repositories/health_score_repository.dart';
import 'package:afc/repositories/goal_repository.dart';
import 'package:afc/view_models/goals/goal_bloc.dart';
import 'package:afc/repositories/investment_repository.dart';
import 'package:afc/view_models/investments/investment_bloc.dart';
import 'package:afc/view_models/theme/theme_cubit.dart';
import 'package:afc/view_models/onboarding/onboarding_cubit.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:afc/repositories/calculator_repository.dart';
import 'package:afc/view_models/fire_calculator/fire_calculator_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => NavigationService());
  sl.registerLazySingleton(() => ImportParserService());
  sl.registerLazySingleton(() => ReceiptService());
  sl.registerLazySingleton(() => AppRefreshBloc());

  // Repositories
  sl.registerLazySingleton(() => CategoryRepository());
  sl.registerLazySingleton(() => DevToolsRepository());
  sl.registerLazySingleton(() => HomeRepository());
  sl.registerLazySingleton(() => LimitRepository());
  sl.registerLazySingleton(() => LimitListRepository());
  sl.registerLazySingleton(() => StatsRepository());
  sl.registerLazySingleton(() => TransactionListRepository());
  sl.registerLazySingleton(() => RecurringRepository());
  sl.registerLazySingleton(() => TemplateRepository());
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl());
  sl.registerLazySingleton(() => GoalRepository());
  sl.registerLazySingleton(() => InvestmentRepository());
  sl.registerLazySingleton(() => BillRepository());
  sl.registerLazySingleton(() => HealthScoreRepository());
  sl.registerLazySingleton(() => CalculatorRepository());

  // Blocs
  sl.registerLazySingleton(() => AuthBloc());
  sl.registerLazySingleton(() => HomeBloc());
  sl.registerFactory(() => CategoryBloc());
  sl.registerFactory(() => LimitBloc());
  sl.registerFactory(() => LimitListBloc());
  sl.registerFactory(() => StatsBloc());
  sl.registerFactory(() => TransactionListBloc());
  sl.registerFactory(() => RecurringBloc(sl(), sl()));
  sl.registerFactory(
    () => ImportBloc(parserService: sl(), repository: sl(), refreshBloc: sl()),
  );
  sl.registerFactory(() => ReportBloc(repository: sl()));
  sl.registerFactory(() => GoalBloc(repository: sl()));
  sl.registerFactory(() => InvestmentBloc(repository: sl()));
  sl.registerFactory(() => BillBloc(repository: sl()));
  sl.registerFactory(() => HealthScoreBloc(repository: sl()));
  sl.registerFactory(() => SettingsBloc());
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerFactory(() => OnboardingCubit());
  sl.registerFactory(() => FireCalculatorBloc(repository: sl()));
}
