import 'package:afc/widgets/custom_tooltip/custom_tooltip_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomTooltipCubit', () {
    late CustomTooltipCubit cubit;

    setUp(() => cubit = CustomTooltipCubit());
    tearDown(() => cubit.close());

    test('initial state is not visible', () {
      expect(cubit.state.isVisible, false);
    });

    blocTest<CustomTooltipCubit, CustomTooltipState>(
      'emits isVisible true when show is called',
      build: () => cubit,
      act: (c) => c.show(),
      expect: () => [const CustomTooltipState(isVisible: true)],
    );

    blocTest<CustomTooltipCubit, CustomTooltipState>(
      'emits isVisible false when hide is called',
      build: () => cubit,
      seed: () => const CustomTooltipState(isVisible: true),
      act: (c) => c.hide(),
      expect: () => [const CustomTooltipState(isVisible: false)],
    );

    blocTest<CustomTooltipCubit, CustomTooltipState>(
      'emits error state when setError is called',
      build: () => cubit,
      act: (c) => c.setError('Error occurred'),
      expect: () => [const CustomTooltipState(errorMessage: 'Error occurred')],
    );

    blocTest<CustomTooltipCubit, CustomTooltipState>(
      'resets to initial state',
      build: () => cubit,
      seed: () =>
          const CustomTooltipState(isVisible: true, errorMessage: 'Fail'),
      act: (c) => c.reset(),
      expect: () => [const CustomTooltipState()],
    );
  });
}
