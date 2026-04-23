import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsProfileUpdated>(_onProfileUpdated);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsBiometricToggled>(_onBiometricToggled);
    on<SettingsDataCleared>(_onDataCleared);
  }

  void _onProfileUpdated(
    SettingsProfileUpdated event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(userName: event.name, userEmail: event.email));
  }

  void _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  void _onBiometricToggled(
    SettingsBiometricToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(biometricEnabled: event.enabled));
  }

  void _onDataCleared(SettingsDataCleared event, Emitter<SettingsState> emit) {
    // Logic for clearing local data would go here
    // For now, just a placeholder for the state transition
  }
}
