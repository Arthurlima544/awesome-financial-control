part of 'app_refresh_bloc.dart';

class AppRefreshState extends Equatable {
  final int version;

  const AppRefreshState(this.version);

  @override
  List<Object?> get props => [version];
}
