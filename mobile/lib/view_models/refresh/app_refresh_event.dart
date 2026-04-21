part of 'app_refresh_bloc.dart';

abstract class AppRefreshEvent extends Equatable {
  const AppRefreshEvent();

  @override
  List<Object?> get props => [];
}

class DataChanged extends AppRefreshEvent {}
