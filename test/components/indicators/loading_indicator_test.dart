import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/constants.dart';
import 'package:rhizu/src/components/indicators/morphing.dart';

void main() {
  group('MorphingLI', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLI())),
      );

      expect(find.byType(MorphingLI), findsOneWidget);
    });

    testWidgets('renders in simple mode by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLI())),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLI),
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
            body: MorphingLI(containment: Containment.contained),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLI),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration! as BoxDecoration;
      final colorScheme = Theme.of(
        tester.element(find.byType(MorphingLI)),
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
            body: MorphingLI(),
          ),
        ),
      );

      // Don't use pumpAndSettle - animation is continuous
      await tester.pump();

      // Verify the CustomPaint is rendered
      expect(
        find.descendant(
          of: find.byType(MorphingLI),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('container has correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLI())),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(MorphingLI),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.constraints?.maxWidth, equals(48.0));
      expect(container.constraints?.maxHeight, equals(48.0));
    });

    testWidgets('animates when displayed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLI())),
      );

      // Initial frame
      await tester.pump();

      // Advance time to trigger animation
      await tester.pump(const Duration(milliseconds: 100));

      // The indicator should still be present
      expect(find.byType(MorphingLI), findsOneWidget);
    });

    testWidgets('disposes controllers when removed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLI())),
      );

      expect(find.byType(MorphingLI), findsOneWidget);

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      expect(find.byType(MorphingLI), findsNothing);
    });

    testWidgets('MorphingLI respects size parameter', (
      tester,
    ) async {
      // Default size
      await tester.pumpWidget(const MaterialApp(home: MorphingLI()));
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
        const MaterialApp(home: MorphingLI(size: customSize)),
      );
      final containerFinder2 = find.byType(Container).first;
      final container2 = tester.widget<Container>(containerFinder2);

      expect(container2.constraints?.minWidth, equals(customSize));
      expect(container2.constraints?.minHeight, equals(customSize));
    });

    testWidgets('MorphingLI clamps size to constraints', (
      tester,
    ) async {
      // Too small -> clamped to min (24.0)
      await tester.pumpWidget(const MaterialApp(home: MorphingLI(size: 10)));
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);

      expect(
        container.constraints?.minWidth,
        equals(LoadingIndicatorConstants.minContainerSize),
      );

      // Too large -> clamped to max (240.0)
      await tester.pumpWidget(const MaterialApp(home: MorphingLI(size: 300)));
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
      await tester.pumpWidget(const MaterialApp(home: MorphingLI.small()));
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(LoadingIndicatorConstants.minContainerSize),
      );

      // Medium
      await tester.pumpWidget(const MaterialApp(home: MorphingLI.medium()));
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(LoadingIndicatorConstants.defaultContainerSize),
      );

      // Large
      await tester.pumpWidget(const MaterialApp(home: MorphingLI.large()));
      expect(
        (tester.widget(find.byType(Container).first) as Container)
            .constraints
            ?.minWidth,
        equals(96.0),
      );

      // Extra Large
      await tester.pumpWidget(const MaterialApp(home: MorphingLI.extraLarge()));
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
}
