import 'package:afc/shared/components/adaptive_search_bar/adaptive_search_bar.dart';
import 'package:afc/shared/components/adaptive_search_bar/adaptive_search_bar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  late AdaptiveSearchBarCubit cubit;
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    cubit = AdaptiveSearchBarCubit();
    controller = TextEditingController();
    focusNode = FocusNode();
  });

  tearDown(() {
    cubit.close();
    controller.dispose();
    focusNode.dispose();
  });

  Widget buildTestableWidget({
    bool showCancelButton = false,
    bool showMicrophone = false,
    VoidCallback? onCancelTapped,
    VoidCallback? onMicrophoneTapped,
    ValueChanged<String>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: AdaptiveSearchBar(
            controller: controller,
            focusNode: focusNode,
            showCancelButton: showCancelButton,
            showMicrophone: showMicrophone,
            onCancelTapped: onCancelTapped,
            onMicrophoneTapped: onMicrophoneTapped,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  group('AdaptiveSearchBar Widget Tests', () {
    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.byIcon(Icons.mic_none), findsNothing);
      expect(
        find.byIcon(Icons.close),
        findsNothing,
      ); // Close shouldn't be there when empty
    });

    testWidgets('renders microphone and cancel button when enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(showCancelButton: true, showMicrophone: true),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets(
      'typing updates state and reveals clear button while hiding mic',
      (WidgetTester tester) async {
        String changedValue = '';

        await tester.pumpWidget(
          buildTestableWidget(
            showMicrophone: true,
            onChanged: (val) => changedValue = val,
          ),
        );

        await tester.enterText(find.byType(TextField), 'Colorado');
        await tester.pump();

        expect(changedValue, 'Colorado');
        expect(cubit.state.query, 'Colorado');
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(
          find.byIcon(Icons.mic_none),
          findsNothing,
        ); // Mic is replaced by clear icon
      },
    );

    testWidgets('tapping clear button clears text and state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(find.byType(TextField), 'Colorado');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(cubit.state.query, isEmpty);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('renders error state properly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      cubit.setError('Invalid character');
      await tester.pump();

      // Get the container decoration to verify the red error border
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Focus),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.red);
    });

    testWidgets('Golden Test - Default State', (WidgetTester tester) async {
      // Fixed view size to prevent varying golden test sizes
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        buildTestableWidget(showCancelButton: true, showMicrophone: true),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AdaptiveSearchBar),
        matchesGoldenFile('goldens/adaptive_search_bar.png'),
      );

      // Reset test bindings
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
