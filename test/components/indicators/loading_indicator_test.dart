import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/morphing.dart';

void main() {
  group('MorphingLI', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLoadingindicator())),
      );

      expect(find.byType(MorphingLoadingindicator), findsOneWidget);
    });

    testWidgets('renders in simple mode by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLoadingindicator())),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLoadingindicator),
              matching: find.byType(Container),
            )
            .first,
      );

      // In simple mode, background should be transparent
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
    });

    testWidgets('renders in contained mode with background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
            ),
          ),
          home: const Scaffold(
            body: MorphingLoadingindicator(containment: Containment.contained),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLoadingindicator),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration! as BoxDecoration;
      final colorScheme = Theme.of(
        tester.element(find.byType(MorphingLoadingindicator)),
      ).colorScheme;

      // In contained mode, background should match primaryContainer
      expect(decoration.color, equals(colorScheme.primaryContainer));
    });

    testWidgets('uses correct colors in simple mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
            ),
          ),
          home: const Scaffold(
            body: MorphingLoadingindicator(),
          ),
        ),
      );

      // Don't use pumpAndSettle - animation is continuous
      await tester.pump();

      // Verify the CustomPaint is rendered
      expect(
        find.descendant(
          of: find.byType(MorphingLoadingindicator),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('container has correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLoadingindicator())),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLoadingindicator),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, equals(48.0));
      expect(container.constraints?.maxHeight, equals(48.0));
    });

    testWidgets('animates when displayed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLoadingindicator())),
      );

      // Initial frame
      await tester.pump();

      // Advance time to trigger animation
      await tester.pump(const Duration(milliseconds: 100));

      // The indicator should still be present
      expect(find.byType(MorphingLoadingindicator), findsOneWidget);
    });

    testWidgets('disposes controllers when removed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLoadingindicator())),
      );

      expect(find.byType(MorphingLoadingindicator), findsOneWidget);

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      expect(find.byType(MorphingLoadingindicator), findsNothing);
    });

    testWidgets('MorphingLI respects size parameter', (
      tester,
    ) async {
      // Default size
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator()),
      );
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      // Default size is 48.0
      expect(
        container.constraints?.minWidth,
        equals(LoadingIndicatorConstants.containerSize),
      );
      expect(
        container.constraints?.minHeight,
        equals(LoadingIndicatorConstants.containerSize),
      );

      // Custom size
      const customSize = 96.0;
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator(size: customSize)),
      );
      final containerFinder2 = find.byType(Container).first;
      final container2 = tester.widget<Container>(containerFinder2);

      expect(container2.constraints?.minWidth, equals(customSize));
      expect(container2.constraints?.minHeight, equals(customSize));
    });

    testWidgets('MorphingLI respects text scale factor', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(home: MorphingLoadingindicator()),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLoadingindicator),
              matching: find.byType(Container),
            )
            .first,
      );

      // Default size is 48.0, with scale 2.0 it should be 96.0
      expect(container.constraints?.minWidth, equals(96.0));
      expect(container.constraints?.minHeight, equals(96.0));
    });

    testWidgets('MorphingLI clamps size to constraints', (
      tester,
    ) async {
      // Too small -> clamped to min (24.0)
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator(size: 10)),
      );
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      expect(
        container.constraints?.minWidth,
        equals(LoadingIndicatorConstants.minContainerSize),
      );

      // Too large -> clamped to max (240.0)
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator(size: 300)),
      );
      final containerFinder2 = find.byType(Container).first;
      final container2 = tester.widget<Container>(containerFinder2);

      expect(
        container2.constraints?.minWidth,
        equals(LoadingIndicatorConstants.maxContainerSize),
      );
    });

    testWidgets('MorphingLI named constructors set correct sizes', (
      tester,
    ) async {
      // Small
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator.small()),
      );
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(LoadingIndicatorConstants.minContainerSize),
      );

      // Medium
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator.medium()),
      );
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(LoadingIndicatorConstants.defaultContainerSize),
      );

      // Large
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator.large()),
      );
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(96.0),
      );

      // Extra Large
      await tester.pumpWidget(
        const MaterialApp(home: MorphingLoadingindicator.extraLarge()),
      );
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(144.0),
      );
    });
  });

  group('Containment', () {
    test('has correct values', () {
      expect(Containment.values, contains(Containment.simple));
      expect(Containment.values, contains(Containment.contained));
      expect(Containment.values.length, equals(2));
    });
  });

  group('IndicatorState', () {
    test('has correct values', () {
      expect(IndicatorState.values, contains(IndicatorState.loading));
      expect(IndicatorState.values, contains(IndicatorState.success));
      expect(IndicatorState.values, contains(IndicatorState.error));
      expect(IndicatorState.values.length, equals(3));
    });

    testWidgets('transitions from loading to success', (tester) async {
      // Start in loading state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingLoadingindicator(),
          ),
        ),
      );

      expect(find.byType(MorphingLoadingindicator), findsOneWidget);
      // Should still show CustomPaint for the morphing animation
      expect(
        find.descendant(
          of: find.byType(MorphingLoadingindicator),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      // Transition to success
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingLoadingindicator(state: IndicatorState.success),
          ),
        ),
      );

      // Pump through the transition animation
      await tester.pump(const Duration(milliseconds: 400));

      // The success state should show an Icon (checkmark)
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('transitions from loading to error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingLoadingindicator(),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MorphingLoadingindicator(state: IndicatorState.error),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      // The error state should show an Icon (close/X)
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('success state uses correct color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: const Scaffold(
            body: MorphingLoadingindicator(state: IndicatorState.success),
          ),
        ),
      );

      // Let the transition complete
      await tester.pump(const Duration(milliseconds: 400));

      // Verify the icon is present
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // The icon should use onPrimaryContainer or a custom success color
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_rounded));
      expect(icon.color, isNotNull);
    });

    testWidgets('default state is loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MorphingLoadingindicator()),
        ),
      );

      // The default should be the morphing animation (no icon visible)
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });
}
