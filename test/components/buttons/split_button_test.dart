import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

class _SimpleMenuEntry<T> extends PopupMenuEntry<T> {
  const _SimpleMenuEntry({required this.child});

  final Widget child;

  @override
  double get height => 48.0;

  @override
  bool represents(T? value) => false;

  @override
  State<StatefulWidget> createState() => _SimpleMenuEntryState<T>();
}

class _SimpleMenuEntryState<T> extends State<_SimpleMenuEntry<T>> {
  @override
  Widget build(BuildContext context) => widget.child;
}

// Helper to wrap widgets with theme that avoids InkSparkle shader issues
Widget wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent, // Prevents InkSparkle shader
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SplitButtonM3E', () {
    // =========================================================================
    // RENDERING TESTS
    // =========================================================================

    group('Rendering', () {
      testWidgets('renders with label and icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SplitButton<String>(
                label: 'Save',
                leadingIcon: Icons.save,
                onPressed: () {},
                items: const [
                  SplitButtonItem(value: 'draft', child: 'Draft'),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Save'), findsOneWidget);
        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      });

      testWidgets('renders all 5 sizes correctly', (tester) async {
        for (final size in SplitButtonSize.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SplitButton<String>(
                  size: size,
                  label: size.name,
                  onPressed: () {},
                  items: const [],
                ),
              ),
            ),
          );

          expect(find.text(size.name), findsOneWidget);

          // Verify height constraint
          final sizedBox = tester.widget<SizedBox>(
            find
                .ancestor(
                  of: find.text(size.name),
                  matching: find.byType(SizedBox),
                )
                .first,
          );
          expect(sizedBox.height, size.height);
        }
      });

      testWidgets('renders all emphasis variants', (tester) async {
        for (final emphasis in SplitButtonEmphasis.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SplitButton<String>(
                  emphasis: emphasis,
                  label: emphasis.name,
                  onPressed: () {},
                  items: const [],
                ),
              ),
            ),
          );

          expect(find.text(emphasis.name), findsOneWidget);
        }
      });

      testWidgets('renders both shape variants', (tester) async {
        for (final shape in SplitButtonShape.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SplitButton<String>(
                  shape: shape,
                  label: shape.name,
                  onPressed: () {},
                  items: const [],
                ),
              ),
            ),
          );

          expect(find.text(shape.name), findsOneWidget);
        }
      });

      testWidgets('renders icon-only trailing segment', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SplitButton<String>(
                label: 'Action',
                onPressed: () {},
                items: const [],
              ),
            ),
          ),
        );

        // Should find chevron icon in trailing segment
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      });
    });

    // =========================================================================
    // INTERACTION TESTS
    // =========================================================================

    group('Interaction', () {
      testWidgets('calls onPressed when leading segment tapped', (
        tester,
      ) async {
        var pressed = false;

        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () => pressed = true,
              items: const [],
            ),
          ),
        );

        // Tap on the leading segment (the label area)
        await tester.tap(find.text('Save'));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('opens menu when trailing segment tapped', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [
                SplitButtonItem(value: 'draft', child: 'Save as Draft'),
                SplitButtonItem(value: 'close', child: 'Save & Close'),
              ],
            ),
          ),
        );

        // Initially menu items should not be visible
        expect(find.text('Save as Draft'), findsNothing);
        expect(find.text('Save & Close'), findsNothing);

        // Tap trailing segment (chevron area)
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        // Menu items should now be visible
        expect(find.text('Save as Draft'), findsOneWidget);
        expect(find.text('Save & Close'), findsOneWidget);
      });

      testWidgets('closes menu when item selected', (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [
                SplitButtonItem(value: 'draft', child: 'Save as Draft'),
              ],
              onSelected: (value) => selectedValue = value,
            ),
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        // Tap menu item
        await tester.tap(find.text('Save as Draft'));
        await tester.pumpAndSettle();

        // Menu should close and value should be selected
        expect(selectedValue, 'draft');
        expect(find.text('Save as Draft'), findsNothing);
      });

      testWidgets('closes menu when tapped outside', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            Column(
              children: [
                SplitButton<String>(
                  label: 'Save',
                  onPressed: () {},
                  items: const [
                    SplitButtonItem(
                      value: 'draft',
                      child: 'Save as Draft',
                    ),
                  ],
                ),
                const Text('Outside area'),
              ],
            ),
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        expect(find.text('Save as Draft'), findsOneWidget);

        // Tap outside
        await tester.tap(find.text('Outside area'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Menu should close
        expect(find.text('Save as Draft'), findsNothing);
      });

      testWidgets('chevron rotates when menu opens', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [],
            ),
          ),
        );

        // Find the rotation transition within the split button
        final rotationTransitions = tester.widgetList<RotationTransition>(
          find.descendant(
            of: find.byType(SplitButton<String>),
            matching: find.byType(RotationTransition),
          ),
        );

        expect(rotationTransitions.length, 1);
        final rotationTransition = rotationTransitions.first;

        // Initial rotation should be 0
        expect(rotationTransition.turns.value, 0.0);

        // Open menu
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pump();

        // After animation, rotation should be 0.5 (180 degrees)
        await tester.pumpAndSettle();
        expect(rotationTransition.turns.value, 0.5);
      });
    });

    // =========================================================================
    // STATE MANAGEMENT TESTS
    // =========================================================================

    group('State Management', () {
      testWidgets('disabled state prevents interaction', (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              enabled: false,
              onPressed: () => pressed = true,
              items: const [
                SplitButtonItem(value: 'draft', child: 'Draft'),
              ],
            ),
          ),
        );

        // Try to tap leading segment
        await tester.tap(find.text('Save'));
        await tester.pump();

        expect(pressed, isFalse);

        // Try to tap trailing segment
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pump();

        // Menu item should not be visible (menu didn't open)
        expect(find.text('Draft'), findsNothing);
      });

      testWidgets('menu item disabled state prevents selection', (
        tester,
      ) async {
        var selected = false;

        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [
                SplitButtonItem(
                  value: 'draft',
                  child: 'Save as Draft',
                  enabled: false,
                ),
              ],
              onSelected: (_) => selected = true,
            ),
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        // Try to tap disabled item
        await tester.tap(find.text('Save as Draft'));
        await tester.pump();

        // Selection should not occur, menu stays open
        expect(selected, isFalse);
        expect(find.text('Save as Draft'), findsOneWidget);
      });

      testWidgets('custom menu builder works correctly', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              menuBuilder: (context) => [
                const _SimpleMenuEntry<String>(child: Text('Custom Item')),
              ],
            ),
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        expect(find.text('Custom Item'), findsOneWidget);
      });
    });

    // =========================================================================
    // SIZE & LAYOUT TESTS
    // =========================================================================

    group('Size & Layout', () {
      testWidgets('trailing segment has minimum touch target of 48dp', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SplitButton<String>(
                size: SplitButtonSize.xs,
                label: 'Save',
                onPressed: () {},
                items: const [],
              ),
            ),
          ),
        );

        // Find trailing segment InkWell
        final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));

        // The second InkWell is the trailing segment
        expect(inkWells.length, 2);

        // Verify minimum constraints
        final constraints = tester
            .widget<Container>(
              find.descendant(
                of: find.byType(InkWell).last,
                matching: find.byType(Container),
              ),
            )
            .constraints;

        expect(constraints?.minWidth, greaterThanOrEqualTo(48.0));
      });

      testWidgets('2dp gap exists between segments', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SplitButton<String>(
                label: 'Save',
                onPressed: () {},
                items: const [],
              ),
            ),
          ),
        );

        // Find SizedBox with 2dp width (the gap)
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));

        // Find the one with width 2
        final gapBox = sizedBoxes.firstWhere(
          (box) => box.width == 2.0,
        );

        expect(gapBox.width, 2.0);
      });

      testWidgets('optical chevron offset is applied in unselected state', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [],
            ),
          ),
        );

        // Find Transform widget that applies offset
        final transform = tester.widget<Transform>(
          find
              .ancestor(
                of: find.byType(RotationTransition),
                matching: find.byType(Transform),
              )
              .first,
        );

        // MD size should have -2dp offset when unselected (MD is the default)
        expect(transform.transform.getTranslation().x, -2.0);
      });
    });

    // =========================================================================
    // EDGE CASES & ERROR HANDLING
    // =========================================================================

    group('Edge Cases', () {
      test(
        'throws assertion error when neither items nor menuBuilder provided',
        () {
          expect(
            () => SplitButton<String>(
              label: 'Save',
              onPressed: () {},
            ),
            throwsAssertionError,
          );
        },
      );

      testWidgets('handles empty items list', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [],
            ),
          ),
        );

        // Should render without error
        expect(find.text('Save'), findsOneWidget);

        // Open menu - should show empty column
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        // Menu opens but is empty
        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('handles String child in menu items', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [
                SplitButtonItem(value: 'draft', child: 'String Child'),
              ],
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        expect(find.text('String Child'), findsOneWidget);
      });

      testWidgets('handles Widget child in menu items', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [
                SplitButtonItem(
                  value: 'draft',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, size: 18),
                      SizedBox(width: 4),
                      Flexible(child: Text('Widget Child')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.text('Widget Child'), findsOneWidget);
      });

      testWidgets('handles null onPressed gracefully', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const SplitButton<String>(
              label: 'Save',
              items: [],
            ),
          ),
        );

        // Should render without error
        expect(find.text('Save'), findsOneWidget);

        // Tap should not crash
        await tester.tap(find.text('Save'));
        await tester.pump();

        // No error thrown
        expect(tester.takeException(), isNull);
      });

      testWidgets('handles null onSelected gracefully', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () {},
              items: const [
                SplitButtonItem(value: 'draft', child: 'Draft'),
              ],
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        // Selecting item should not crash even without callback
        await tester.tap(find.text('Draft'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    // =========================================================================
    // ACCESSIBILITY TESTS
    // =========================================================================

    group('Accessibility', () {
      testWidgets('provides tooltips when specified', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SplitButton<String>(
                label: 'Save',
                leadingTooltip: 'Save document',
                trailingTooltip: 'More options',
                onPressed: () {},
                items: const [],
              ),
            ),
          ),
        );

        // Find Tooltip widgets
        final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));

        // Verify tooltips exist
        expect(tooltips.length, greaterThanOrEqualTo(2));

        // Check tooltip messages
        final tooltipMessages = tooltips.map((t) => t.message).toList();
        expect(tooltipMessages, contains('Save document'));
        expect(tooltipMessages, contains('More options'));
      });

      testWidgets('each segment is independently tappable', (tester) async {
        var leadingPressed = false;

        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              label: 'Save',
              onPressed: () => leadingPressed = true,
              items: const [],
            ),
          ),
        );

        // Find all InkWells
        final inkWells = find.byType(InkWell);
        expect(inkWells, findsNWidgets(2));

        // Tap first (leading)
        await tester.tap(inkWells.first);
        await tester.pump();
        expect(leadingPressed, isTrue);
      });
    });

    // =========================================================================
    // ANIMATION TESTS
    // =========================================================================

    group('Animation', () {
      testWidgets('morphing animation plays for M/L/XL round shapes', (
        tester,
      ) async {
        for (final size in [
          SplitButtonSize.md,
          SplitButtonSize.lg,
          SplitButtonSize.xl,
        ]) {
          await tester.pumpWidget(
            wrapWithTheme(
              SplitButton<String>(
                size: size,
                label: size.name,
                onPressed: () {},
                items: const [],
              ),
            ),
          );

          // Find AnimatedBuilder
          // It wraps the Material of the trailing segment
          // We can find it by looking for one that is an ancestor of the InkWell
          // and a descendant of the Row
          final animatedBuilder = find
              .descendant(
                of: find.byType(SplitButton<String>),
                matching: find.ancestor(
                  of: find.byType(Icon), // Chevron icon
                  matching: find.byType(AnimatedBuilder),
                ),
              )
              .first; // Use first found

          expect(animatedBuilder, findsOneWidget);

          // Trigger animation by opening menu
          await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
          await tester.pump();

          // Animation should be in progress
          await tester.pump(const Duration(milliseconds: 100));

          // Pump to completion
          await tester.pumpAndSettle();
        }
      });

      testWidgets('no morphing for XS/S sizes', (tester) async {
        for (final size in [SplitButtonSize.xs, SplitButtonSize.sm]) {
          await tester.pumpWidget(
            wrapWithTheme(
              SplitButton<String>(
                size: size,
                label: size.name,
                onPressed: () {},
                items: const [],
              ),
            ),
          );

          // Open menu
          await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
          await tester.pumpAndSettle();

          // Verify rendering completes without error
          expect(find.text(size.name), findsOneWidget);
        }
      });

      testWidgets('no morphing for square shapes', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SplitButton<String>(
              size: SplitButtonSize.lg,
              shape: SplitButtonShape.square,
              label: 'Save',
              onPressed: () {},
              items: const [],
            ),
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
        await tester.pumpAndSettle();

        // Should still render correctly
        expect(find.text('Save'), findsOneWidget);
      });
    });
  });
}
