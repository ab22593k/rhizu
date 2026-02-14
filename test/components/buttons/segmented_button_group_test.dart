import 'package:flutter/material.dart' hide SegmentedButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/buttons/segmented_button_group.dart';

void main() {
  group('ExpressiveSegmentedButton', () {
    testWidgets('renders all segments correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('One')),
                ButtonSegment(value: 2, label: Text('Two')),
                ButtonSegment(value: 3, label: Text('Three')),
              ],
              selected: const {1},
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
      expect(
        find.byIcon(Icons.check),
        findsOneWidget,
      ); // Selected item has checkmark
    });

    testWidgets('updates selection on tap', (tester) async {
      var selected = {1};
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            splashFactory: InkRipple.splashFactory,
          ),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('One')),
                    ButtonSegment(value: 2, label: Text('Two')),
                  ],
                  selected: selected,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      selected = newSelection;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap "Two"
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selected, {2});
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('supports multi-selection', (tester) async {
      var selected = {1};
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            splashFactory: InkRipple.splashFactory,
          ),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SegmentedButton<int>(
                  multiSelectionEnabled: true,
                  segments: const [
                    ButtonSegment(value: 1, label: Text('One')),
                    ButtonSegment(value: 2, label: Text('Two')),
                    ButtonSegment(value: 3, label: Text('Three')),
                  ],
                  selected: selected,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      selected = newSelection;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap "Two" to add it
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(selected, {1, 2});

      // Tap "One" to remove it
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      expect(selected, {2});
    });

    testWidgets('respects emptySelectionAllowed', (tester) async {
      var selected = {1};
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            splashFactory: InkRipple.splashFactory,
          ),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('One')),
                  ],
                  selected: selected,
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      selected = newSelection;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap "One" to try removing it
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      expect(selected, {1}); // Should not change
    });

    testWidgets('respects size constraints (XS)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SegmentedButton<int>(
                size: SegmentedButtonSize.xs,
                segments: const [
                  ButtonSegment(value: 1, label: Text('One')),
                ],
                selected: const {1},
                onSelectionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Find the Container that wraps the content inside _Segment
      // It has a BoxConstraints with minHeight: 32.0
      final container = find
          .ancestor(
            of: find.text('One'),
            matching: find.byType(AnimatedContainer),
          )
          .first;

      final widget = tester.widget<AnimatedContainer>(container);
      expect(widget.constraints!.minHeight, 32.0);
    });

    testWidgets('hides checkmark when showSelectedIcon is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 1, label: Text('One')),
              ],
              selected: const {1},
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
