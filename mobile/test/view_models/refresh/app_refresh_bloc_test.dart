import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRefreshBloc', () {
    test('initial state has version 0', () {
      expect(AppRefreshBloc().state.version, 0);
    });

    blocTest<AppRefreshBloc, AppRefreshState>(
      'emits state with incremented version on DataChanged',
      build: () => AppRefreshBloc(),
      act: (bloc) => bloc.add(DataChanged()),
      expect: () => [const AppRefreshState(1)],
    );

    blocTest<AppRefreshBloc, AppRefreshState>(
      'increments version multiple times',
      build: () => AppRefreshBloc(),
      act: (bloc) {
        bloc.add(DataChanged());
        bloc.add(DataChanged());
      },
      expect: () => [const AppRefreshState(1), const AppRefreshState(2)],
    );
  });
}
