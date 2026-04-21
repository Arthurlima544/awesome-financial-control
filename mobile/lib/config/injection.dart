import 'package:get_it/get_it.dart';
import '../shared/services/navigation_service.dart';
import '../features/category/bloc/category_bloc.dart';
import '../features/category/repository/category_repository.dart';
import '../features/dev/repository/dev_tools_repository.dart';
import '../features/home/bloc/home_bloc.dart';
import '../features/home/repository/home_repository.dart';
import '../features/limit/bloc/limit_bloc.dart';
import '../features/limit/repository/limit_repository.dart';
import '../features/limit_list/bloc/limit_list_bloc.dart';
import '../features/limit_list/repository/limit_list_repository.dart';
import '../features/stats/bloc/stats_bloc.dart';
import '../features/stats/repository/stats_repository.dart';
import '../features/transaction_list/bloc/transaction_list_bloc.dart';
import '../features/transaction_list/repository/transaction_list_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => NavigationService());

  // Repositories
  sl.registerLazySingleton(() => CategoryRepository());
  sl.registerLazySingleton(() => DevToolsRepository());
  sl.registerLazySingleton(() => HomeRepository());
  sl.registerLazySingleton(() => LimitRepository());
  sl.registerLazySingleton(() => LimitListRepository());
  sl.registerLazySingleton(() => StatsRepository());
  sl.registerLazySingleton(() => TransactionListRepository());

  // Blocs
  sl.registerLazySingleton(() => AuthBloc());
  sl.registerLazySingleton(() => HomeBloc());
  sl.registerFactory(() => CategoryBloc());
  sl.registerFactory(() => LimitBloc());
  sl.registerFactory(() => LimitListBloc());
  sl.registerFactory(() => StatsBloc());
  sl.registerFactory(() => TransactionListBloc());
}
