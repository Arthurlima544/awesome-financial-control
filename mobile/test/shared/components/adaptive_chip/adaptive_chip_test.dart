import 'package:afc/shared/components/adaptive_chip/adaptive_chip.dart';
import 'package:afc/shared/components/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveChipCubit cubit,
    VoidCallback? onPressed,
    VoidCallback? onIconPressed,
    AdaptiveChipSize size = AdaptiveChipSize.wrap,
    AdaptiveChipIconPosition iconPosition = AdaptiveChipIconPosition.trailing,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveChip(
              label: 'Filter',
              icon: Icons.close,
              iconPosition: iconPosition,
              size: size,
              onPressed: onPressed,
              onIconPressed: onIconPressed,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveChip Widget Tests', () {
    late AdaptiveChipCubit cubit;

    setUp(() {
      cubit = AdaptiveChipCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );

      expect(find.byType(AdaptiveChip), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('taps trigger onPressed callback', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () => wasTapped = true),
      );

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('disabled state prevents interaction', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () => wasTapped = true),
      );

      cubit.setDisabled(true);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AdaptiveChip));
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
    });

    testWidgets('renders error state border correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );

      cubit.setError('Error');
      await tester.pumpAndSettle();

      final materialWidget = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AnimatedContainer),
              matching: find.byType(Material),
            )
            .first,
      );

      final shape = materialWidget.shape as RoundedRectangleBorder;
      expect(shape.side.color, Colors.red);
    });
  });
}
