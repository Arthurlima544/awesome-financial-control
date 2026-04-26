import 'package:afc/models/currency.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SettingsBloc', () {
    test('initial state has default values', () {
      final bloc = SettingsBloc(prefs);
      expect(bloc.state, const SettingsState());
      addTearDown(bloc.close);
    });

    group('SettingsLoaded', () {
      blocTest<SettingsBloc, SettingsState>(
        'emits default state when prefs are empty',
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(SettingsLoaded()),
        expect: () => [const SettingsState()],
      );

      blocTest<SettingsBloc, SettingsState>(
        'loads persisted name, email, notifications, biometric and currency',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            'settings_user_name': 'Maria Silva',
            'settings_user_email': 'maria@example.com',
            'settings_notifications_enabled': false,
            'settings_biometric_enabled': true,
            'selected_currency': Currency.usd.index,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(SettingsLoaded()),
        expect: () => [
          const SettingsState(
            userName: 'Maria Silva',
            userEmail: 'maria@example.com',
            notificationsEnabled: false,
            biometricEnabled: true,
            selectedCurrency: Currency.usd,
          ),
        ],
      );
    });

    group('SettingsProfileUpdated', () {
      blocTest<SettingsBloc, SettingsState>(
        'emits state with new name and email',
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(
          const SettingsProfileUpdated(
            name: 'João Costa',
            email: 'joao@example.com',
          ),
        ),
        expect: () => [
          const SettingsState(
            userName: 'João Costa',
            userEmail: 'joao@example.com',
          ),
        ],
      );

      blocTest<SettingsBloc, SettingsState>(
        'persists name and email to SharedPreferences',
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(
          const SettingsProfileUpdated(
            name: 'João Costa',
            email: 'joao@example.com',
          ),
        ),
        verify: (_) {
          expect(prefs.getString('settings_user_name'), 'João Costa');
          expect(prefs.getString('settings_user_email'), 'joao@example.com');
        },
      );
    });

    group('SettingsNotificationsToggled', () {
      blocTest<SettingsBloc, SettingsState>(
        'emits state with notifications disabled',
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(SettingsNotificationsToggled(false)),
        expect: () => [const SettingsState(notificationsEnabled: false)],
      );

      blocTest<SettingsBloc, SettingsState>(
        'emits state with notifications enabled when toggled back on',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            'settings_notifications_enabled': false,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(SettingsNotificationsToggled(true)),
        expect: () => [const SettingsState(notificationsEnabled: true)],
      );

      blocTest<SettingsBloc, SettingsState>(
        'persists notification preference to SharedPreferences',
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(SettingsNotificationsToggled(false)),
        verify: (_) {
          expect(prefs.getBool('settings_notifications_enabled'), false);
        },
      );
    });

    group('SettingsDataCleared', () {
      blocTest<SettingsBloc, SettingsState>(
        'clears all prefs and emits default state',
        setUp: () async {
          SharedPreferences.setMockInitialValues({
            'settings_user_name': 'Teste',
            'settings_user_email': 'teste@example.com',
            'settings_notifications_enabled': false,
            'settings_biometric_enabled': true,
            'selected_currency': Currency.usd.index,
          });
          prefs = await SharedPreferences.getInstance();
        },
        build: () => SettingsBloc(prefs),
        act: (bloc) => bloc.add(SettingsDataCleared()),
        expect: () => [const SettingsState()],
        verify: (_) {
          expect(prefs.getKeys(), isEmpty);
        },
      );
    });
  });
}
