import 'package:afc/view_models/privacy/privacy_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrivacyCubit', () {
    test('initial state is not private', () {
      expect(PrivacyCubit().state.isPrivate, false);
    });

    blocTest<PrivacyCubit, PrivacyState>(
      'toggles privacy state correctly',
      build: () => PrivacyCubit(),
      act: (cubit) => cubit.togglePrivacy(),
      expect: () => [const PrivacyState(isPrivate: true)],
    );

    blocTest<PrivacyCubit, PrivacyState>(
      'toggles privacy back to false',
      seed: () => const PrivacyState(isPrivate: true),
      build: () => PrivacyCubit(),
      act: (cubit) => cubit.togglePrivacy(),
      expect: () => [const PrivacyState(isPrivate: false)],
    );
  });
}
