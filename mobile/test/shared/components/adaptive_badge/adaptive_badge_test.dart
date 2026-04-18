import 'package:afc/shared/components/adaptive_badge/adaptive_badge.dart';
import 'package:afc/shared/components/adaptive_badge/adaptive_badge_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveBadgeCubit cubit,
    required AdaptiveBadgeType type,
    VoidCallback? onTap,
    Color? baseColor,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: AdaptiveBadge(
              type: type,
              semanticLabel: 'Test Badge',
              onTap: onTap,
              baseColor: baseColor,
            ),
          ),
        ),
      ),
    );
  }

  group('AdaptiveBadge Widget Tests', () {
    late AdaptiveBadgeCubit cubit;

    setUp(() {
      cubit = AdaptiveBadgeCubit(initialLabel: 'Success', initialCount: 7);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders status badge correctly with label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, type: AdaptiveBadgeType.status),
      );

      expect(find.byType(AdaptiveBadge), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('renders count badge correctly with number', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, type: AdaptiveBadgeType.count),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets('renders dot badge without text', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, type: AdaptiveBadgeType.dot),
      );

      expect(find.byType(AdaptiveBadge), findsOneWidget);
      expect(find.text('7'), findsNothing);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets('taps trigger onTap callback', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          type: AdaptiveBadgeType.status,
          onTap: () => wasTapped = true,
        ),
      );

      await tester.tap(find.byType(AdaptiveBadge));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('badge disappears when isVisible is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, type: AdaptiveBadgeType.status),
      );

      expect(find.text('Success'), findsOneWidget);

      cubit.setVisibility(false);
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsNothing);
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('renders error state border', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, type: AdaptiveBadgeType.status),
      );

      cubit.setError('Network Error');
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
    });
  });
}
