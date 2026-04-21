import 'package:afc/widgets/adaptative_nav_bar/adaptive_nav_bar.dart';
import 'package:afc/widgets/adaptative_nav_bar/adaptive_nav_bar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  Widget buildTestableWidget({
    required AdaptiveNavBarCubit cubit,
    VoidCallback? onBackTapped,
    VoidCallback? onSettingsTapped,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: Column(
            children: [
              AdaptiveNavBar(
                title: 'Test Title',
                onBackTapped: onBackTapped,
                onSettingsTapped: onSettingsTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('AdaptiveNavBar Widget Tests', () {
    late AdaptiveNavBarCubit cubit;

    setUp(() {
      cubit = AdaptiveNavBarCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders correctly with default Cubit state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(cubit: cubit));

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('onBackTapped and onSettingsTapped fire correctly', (
      WidgetTester tester,
    ) async {
      bool backTapped = false;
      bool settingsTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          cubit: cubit,
          onBackTapped: () => backTapped = true,
          onSettingsTapped: () => settingsTapped = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(backTapped, isTrue);
      expect(settingsTapped, isTrue);
    });

    testWidgets(
      'rebuilds correctly and shows loading indicator on state change',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(cubit: cubit));

        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

        // Update state
        cubit.setLoading(true);
        await tester.pump(); // Pump to trigger rebuild

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.settings_outlined), findsNothing);
      },
    );

    testWidgets('renders error state color when Cubit emits error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(cubit: cubit));

      cubit.setError('Network Issue');
      await tester.pump();

      final Icon settingsIcon = tester.widget(
        find.byIcon(Icons.settings_outlined),
      );
      expect(settingsIcon.color, Colors.red);
    });
  });
}
