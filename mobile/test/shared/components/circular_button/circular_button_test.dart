import 'package:afc/shared/components/circular_button/circular_button.dart';
import 'package:afc/shared/components/circular_button/circular_button_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required CircularButtonCubit cubit,
    VoidCallback? onPressed,
    CircularButtonVariant variant = CircularButtonVariant.solid,
    CircularButtonSize size = CircularButtonSize.medium,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: BlocProvider.value(
            value: cubit,
            child: CircularButton(
              icon: Icons.adjust,
              semanticLabel: 'Test Circular Button',
              onPressed: onPressed,
              variant: variant,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  group('CircularButton Widget Tests', () {
    late CircularButtonCubit cubit;

    setUp(() {
      cubit = CircularButtonCubit();
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

      expect(find.byIcon(Icons.adjust), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('onPressed callback fires correctly when tapped', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () => wasTapped = true),
      );

      await tester.tap(find.byIcon(Icons.adjust));
      await tester.pumpAndSettle();

      expect(wasTapped, isTrue);
    });

    testWidgets('rebuilds and shows loading indicator on state change', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );

      cubit.setLoading(true);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.adjust), findsNothing);
    });

    testWidgets('does not fire onPressed when disabled by state', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () => wasTapped = true),
      );

      cubit.setDisabled(true);
      await tester.pump();

      await tester.tap(find.byType(CircularButton));
      await tester.pumpAndSettle();

      expect(wasTapped, isFalse);
    });

    testWidgets('renders error state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(cubit: cubit, onPressed: () {}),
      );

      cubit.setError('Error');
      await tester.pump();

      final Icon icon = tester.widget(find.byIcon(Icons.adjust));
      expect(icon.color, Colors.red);
    });
  });
}
