import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/progress.dart';

void main() {
  group('Circular PI', () {
    testWidgets('renders without error in indeterminate mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(color: Colors.blue, trackColor: Colors.grey),
          ),
        ),
      );

      expect(find.byType(CircularPI), findsOneWidget);
    });

    testWidgets('renders without error in determinate mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(
              value: 0.5,
              color: Colors.blue,
              trackColor: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(CircularPI), findsOneWidget);
    });

    testWidgets('uses correct default values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(color: Colors.blue, trackColor: Colors.grey),
          ),
        ),
      );

      final widget = tester.widget<CircularPI>(find.byType(CircularPI));

      expect(widget.radius, equals(24.0));
      expect(widget.strokeWidth, equals(4.0));
      expect(widget.waves, equals(12));
      expect(widget.amplitude, equals(2.0));
      expect(widget.trackGap, equals(4.0));
      expect(widget.value, isNull);
    });

    testWidgets('accepts custom values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(
              value: 0.75,
              color: Colors.red,
              trackColor: Colors.black,
              radius: 50,
              strokeWidth: 8,
              waves: 8,
              amplitude: 5,
              trackGap: 10,
            ),
          ),
        ),
      );

      final widget = tester.widget<CircularPI>(find.byType(CircularPI));

      expect(widget.value, equals(0.75));
      expect(widget.color, equals(Colors.red));
      expect(widget.trackColor, equals(Colors.black));
      expect(widget.radius, equals(50.0));
      expect(widget.strokeWidth, equals(8.0));
      expect(widget.waves, equals(8));
      expect(widget.amplitude, equals(5.0));
      expect(widget.trackGap, equals(10.0));
    });

    testWidgets('has correct size based on radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(
              color: Colors.blue,
              trackColor: Colors.grey,
              radius: 30,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(CircularPI),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, equals(60.0)); // radius * 2
      expect(sizedBox.height, equals(60.0));
    });

    testWidgets('renders CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(color: Colors.blue, trackColor: Colors.grey),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CircularPI),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('disposes controller when removed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(color: Colors.blue, trackColor: Colors.grey),
          ),
        ),
      );

      expect(find.byType(CircularPI), findsOneWidget);

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      expect(find.byType(CircularPI), findsNothing);
    });

    testWidgets('switches between determinate and indeterminate modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(
              color: Colors.blue,
              trackColor: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(CircularPI), findsOneWidget);

      // Switch to determinate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(
              value: 0.5, // Determinate
              color: Colors.blue,
              trackColor: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(CircularPI), findsOneWidget);

      // Switch back to indeterminate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(
              color: Colors.blue,
              trackColor: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(CircularPI), findsOneWidget);
    });

    testWidgets('animates in indeterminate mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPI(color: Colors.blue, trackColor: Colors.grey),
          ),
        ),
      );

      // Initial frame
      await tester.pump();

      // Advance time to trigger animation
      await tester.pump(const Duration(milliseconds: 100));

      // The indicator should still be present
      expect(find.byType(CircularPI), findsOneWidget);
    });
  });
}
