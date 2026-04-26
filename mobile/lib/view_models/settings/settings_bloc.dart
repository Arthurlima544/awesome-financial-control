import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afc/models/currency.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;
  static const _currencyKey = 'selected_currency';
  static const _nameKey = 'settings_user_name';
  static const _emailKey = 'settings_user_email';
  static const _notificationsKey = 'settings_notifications_enabled';
  static const _biometricKey = 'settings_biometric_enabled';

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
    final name = _prefs.getString(_nameKey);
    final email = _prefs.getString(_emailKey);
    final notifications = _prefs.getBool(_notificationsKey);
    final biometric = _prefs.getBool(_biometricKey);
    emit(
      state.copyWith(
        selectedCurrency: currencyIndex != null
            ? Currency.values[currencyIndex]
            : null,
        userName: name,
        userEmail: email,
        notificationsEnabled: notifications,
        biometricEnabled: biometric,
      ),
    );
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
    _prefs.setString(_nameKey, event.name);
    _prefs.setString(_emailKey, event.email);
    emit(state.copyWith(userName: event.name, userEmail: event.email));
  }

  void _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    _prefs.setBool(_notificationsKey, event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  void _onBiometricToggled(
    SettingsBiometricToggled event,
    Emitter<SettingsState> emit,
  ) {
    _prefs.setBool(_biometricKey, event.enabled);
    emit(state.copyWith(biometricEnabled: event.enabled));
  }

  Future<void> _onDataCleared(
    SettingsDataCleared event,
    Emitter<SettingsState> emit,
  ) async {
    await _prefs.clear();
    emit(const SettingsState());
  }
}
