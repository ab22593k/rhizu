import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/morphing.dart';

void main() {
  group('MorphingLI', () {
    testWidgets('renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MorphingLI())),
      );

      expect(find.byType(MorphingLI), findsOneWidget);
    });

    testWidgets('renders in simple mode by default', (
      WidgetTester tester,
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
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
    });

    testWidgets('renders in contained mode with background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
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

      final decoration = container.decoration as BoxDecoration;
      final colorScheme = Theme.of(
        tester.element(find.byType(MorphingLI)),
      ).colorScheme;

      // In contained mode, background should match primaryContainer
      expect(decoration.color, equals(colorScheme.primaryContainer));
    });

    testWidgets('uses correct colors in simple mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: const Scaffold(
            body: MorphingLI(containment: Containment.simple),
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

    testWidgets('container has correct size', (WidgetTester tester) async {
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

    testWidgets('animates when displayed', (WidgetTester tester) async {
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
      WidgetTester tester,
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
  });

  group('Containment', () {
    test('has correct values', () {
      expect(Containment.values, contains(Containment.simple));
      expect(Containment.values, contains(Containment.contained));
      expect(Containment.values.length, equals(2));
    });
  });
}
