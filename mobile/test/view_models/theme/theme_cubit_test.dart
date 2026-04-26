import 'package:afc/view_models/theme/theme_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeCubit', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state is ThemeMode.system', () {
      expect(ThemeCubit().state, ThemeMode.system);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'emits ThemeMode.dark when toggleTheme is called from light',
      seed: () => ThemeMode.light,
      build: () => ThemeCubit(),
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits ThemeMode.light when toggleTheme is called from dark',
      seed: () => ThemeMode.dark,
      build: () => ThemeCubit(),
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'setTheme persists value',
      build: () => ThemeCubit(),
      act: (cubit) => cubit.setTheme(ThemeMode.dark),
      expect: () => [ThemeMode.dark],
      verify: (_) {
        expect(prefs.getInt('theme_mode'), ThemeMode.dark.index);
      },
    );
  });
}
