import 'package:get_it/get_it.dart';
import 'package:afc/services/navigation_service.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/view_models/category/category_bloc.dart';
import 'package:afc/repositories/category_repository.dart';
import 'package:afc/repositories/dev_tools_repository.dart';
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
import 'package:afc/view_models/recurring/recurring_bloc.dart';
import 'package:afc/view_models/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => NavigationService());
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

  // Blocs
  sl.registerLazySingleton(() => AuthBloc());
  sl.registerLazySingleton(() => HomeBloc());
  sl.registerFactory(() => CategoryBloc());
  sl.registerFactory(() => LimitBloc());
  sl.registerFactory(() => LimitListBloc());
  sl.registerFactory(() => StatsBloc());
  sl.registerFactory(() => TransactionListBloc());
  sl.registerFactory(() => RecurringBloc(sl(), sl()));
}
