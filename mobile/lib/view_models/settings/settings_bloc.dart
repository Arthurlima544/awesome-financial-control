import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afc/models/currency.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;
  static const _currencyKey = 'selected_currency';

  SettingsBloc(this._prefs) : super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsProfileUpdated>(_onProfileUpdated);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsBiometricToggled>(_onBiometricToggled);
    on<SettingsDataCleared>(_onDataCleared);
    on<SettingsCurrencyChanged>(_onCurrencyChanged);
  }

  void _onLoaded(SettingsLoaded event, Emitter<SettingsState> emit) {
    final currencyIndex = _prefs.getInt(_currencyKey);
    if (currencyIndex != null) {
      emit(state.copyWith(selectedCurrency: Currency.values[currencyIndex]));
    }
  }

  void _onCurrencyChanged(
    SettingsCurrencyChanged event,
    Emitter<SettingsState> emit,
  ) {
    _prefs.setInt(_currencyKey, event.currency.index);
    emit(state.copyWith(selectedCurrency: event.currency));
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
