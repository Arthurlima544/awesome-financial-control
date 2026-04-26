import 'package:afc/models/currency.dart';
import 'package:afc/view_models/settings/settings_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsBloc', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state is correct', () {
      final bloc = SettingsBloc(prefs);
      expect(bloc.state.selectedCurrency, Currency.brl);
      expect(bloc.state.userName, 'Arthur Lima');
      bloc.close();
    });

    blocTest<SettingsBloc, SettingsState>(
      'loads settings from SharedPreferences',
      build: () {
        prefs.setInt('selected_currency', Currency.brl.index);
        prefs.setString('settings_user_name', 'Art');
        return SettingsBloc(prefs);
      },
      act: (bloc) => bloc.add(SettingsLoaded()),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.selectedCurrency, 'currency', Currency.brl)
            .having((s) => s.userName, 'userName', 'Art'),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'updates currency and persists it',
      build: () => SettingsBloc(prefs),
      act: (bloc) => bloc.add(const SettingsCurrencyChanged(Currency.usd)),
      expect: () => [
        isA<SettingsState>().having(
          (s) => s.selectedCurrency,
          'currency',
          Currency.usd,
        ),
      ],
      verify: (_) {
        expect(prefs.getInt('selected_currency'), Currency.usd.index);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'updates profile and persists it',
      build: () => SettingsBloc(prefs),
      act: (bloc) => bloc.add(
        const SettingsProfileUpdated(name: 'New Name', email: 'test@test.com'),
      ),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.userName, 'name', 'New Name')
            .having((s) => s.userEmail, 'email', 'test@test.com'),
      ],
      verify: (_) {
        expect(prefs.getString('settings_user_name'), 'New Name');
        expect(prefs.getString('settings_user_email'), 'test@test.com');
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'clears all data',
      seed: () =>
          const SettingsState(userName: 'Art', notificationsEnabled: true),
      build: () => SettingsBloc(prefs),
      act: (bloc) => bloc.add(SettingsDataCleared()),
      expect: () => [const SettingsState()],
      verify: (_) {
        expect(prefs.getKeys(), isEmpty);
      },
    );
  });
}
