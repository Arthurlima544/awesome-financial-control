part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsProfileUpdated extends SettingsEvent {
  final String name;
  final String email;

  const SettingsProfileUpdated({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}

class SettingsNotificationsToggled extends SettingsEvent {
  final bool enabled;

  const SettingsNotificationsToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SettingsBiometricToggled extends SettingsEvent {
  final bool enabled;

  const SettingsBiometricToggled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SettingsDataCleared extends SettingsEvent {}

class SettingsCurrencyChanged extends SettingsEvent {
  final Currency currency;

  const SettingsCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SettingsLoaded extends SettingsEvent {}
