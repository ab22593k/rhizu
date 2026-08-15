import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

// Helper to wrap widgets with theme that avoids InkSparkle shader issues
Widget wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent, // Prevents InkSparkle shader
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ButtonGroup', () {
    group('Rendering', () {
      testWidgets('renders item labels and icons', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(
                  value: 'a',
                  label: 'Alpha',
                  icon: Icons.add,
                ),
                ButtonGroupItem(
                  value: 'b',
                  label: 'Beta',
                  icon: Icons.remove,
                ),
              ],
              selected: const {'a'},
            ),
          ),
        );

        expect(find.text('Alpha'), findsOneWidget);
        expect(find.text('Beta'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
      });

      testWidgets('renders all five sizes with matching heights', (
        tester,
      ) async {
        for (final size in ButtonGroupSize.values) {
          await tester.pumpWidget(
            wrapWithTheme(
              ButtonGroup<String>(
                size: size,
                items: [
                  ButtonGroupItem(value: 'a', label: size.name),
                  const ButtonGroupItem(value: 'b', label: 'b'),
                ],
                selected: const {'a'},
              ),
            ),
          );
          await tester.pump();

          final box = tester.getSize(find.byType(ButtonGroup<String>));
          expect(box.height, size.height);
        }
      });

      testWidgets('renders both variants', (tester) async {
        for (final variant in ButtonGroupVariant.values) {
          await tester.pumpWidget(
            wrapWithTheme(
              ButtonGroup<String>(
                variant: variant,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          );

          expect(find.text('Alpha'), findsOneWidget);
          expect(find.text('Beta'), findsOneWidget);
        }
      });

      testWidgets('renders both shapes', (tester) async {
        for (final shape in ButtonGroupShape.values) {
          await tester.pumpWidget(
            wrapWithTheme(
              ButtonGroup<String>(
                shape: shape,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          );

          expect(find.text('Alpha'), findsOneWidget);
        }
      });

      testWidgets('renders all styles', (tester) async {
        for (final style in ButtonGroupStyle.values) {
          await tester.pumpWidget(
            wrapWithTheme(
              ButtonGroup<String>(
                style: style,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          );

          expect(find.text('Alpha'), findsOneWidget);
        }
      });
    });

    group('Standard variant layout', () {
      testWidgets('uses size-based gaps between buttons', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        // M standard gap is 8dp.
        final gaps = tester
            .widgetList<SizedBox>(
              find.descendant(
                of: find.byType(ButtonGroup<String>),
                matching: find.byType(SizedBox),
              ),
            )
            .where((box) => box.width == 8.0);
        expect(gaps.length, 1);
      });

      testWidgets('standard group hugs content (no expansion)', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ButtonGroup<String>(
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );

        final box = tester.getSize(find.byType(ButtonGroup<String>));
        expect(box.width, lessThan(400));
      });

      testWidgets('standard group grows pressed button by 15% and shrinks '
          'neighbors', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
                ButtonGroupItem(value: 'c', label: 'Gamma'),
              ],
              selected: const {'a'},
            ),
          ),
        );
        await tester.pump(); // let natural widths measure

        final groupFinder = find.byType(ButtonGroup<String>);
        final groupBefore = tester.getSize(groupFinder);

        // Measure the pressed button's material box before pressing.
        final betaFinder = find.ancestor(
          of: find.text('Beta'),
          matching: find.byType(Material),
        );
        final betaBefore = tester.getSize(betaFinder.first);

        // Press the middle button and hold it down mid-animation.
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Beta')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        final betaDuring = tester.getSize(betaFinder.first);
        // The pressed button grew: natural * (1 + 0.15 * progress).
        expect(betaDuring.width, greaterThan(betaBefore.width));

        final groupDuring = tester.getSize(groupFinder);
        // Total width stays stable (pressed grows, neighbors give up width).
        expect(groupDuring.width, closeTo(groupBefore.width, 0.5));

        await gesture.up();
        await tester.pumpAndSettle();
        final groupAfter = tester.getSize(groupFinder);
        expect(groupAfter.width, closeTo(groupBefore.width, 0.5));
      });
    });

    group('Expanded variant layout', () {
      testWidgets('expanded standard group fills available width', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SizedBox(
              width: 400,
              child: ButtonGroup<String>(
                expanded: true,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );

        final box = tester.getSize(find.byType(ButtonGroup<String>));
        expect(box.width, 400);
      });

      testWidgets('expanded group shares width equally at rest', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SizedBox(
              width: 400,
              child: ButtonGroup<String>(
                expanded: true,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                  ButtonGroupItem(value: 'c', label: 'Gamma'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );
        await tester.pump();

        // 400 - 2 * 8dp gap = 384 shared by 3 buttons = 128 each.
        final widths = find
            .descendant(
              of: find.byType(ButtonGroup<String>),
              matching: find.byType(Material),
            )
            .evaluate()
            .map((element) {
              return tester.getSize(find.byWidget(element.widget)).width;
            })
            .toList();
        expect(widths, hasLength(3));
        for (final width in widths) {
          expect(width, closeTo(128, 0.5));
        }
      });

      testWidgets('expanded group keeps total width stable while pressing', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SizedBox(
              width: 400,
              child: ButtonGroup<String>(
                expanded: true,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                  ButtonGroupItem(value: 'c', label: 'Gamma'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );
        await tester.pump();

        final groupFinder = find.byType(ButtonGroup<String>);
        final groupBefore = tester.getSize(groupFinder);
        final betaFinder = find.ancestor(
          of: find.text('Beta'),
          matching: find.byType(Material),
        );
        final betaBefore = tester.getSize(betaFinder.first);

        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Beta')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // The pressed button takes a larger share while held.
        final betaDuring = tester.getSize(betaFinder.first);
        expect(betaDuring.width, greaterThan(betaBefore.width));

        // The group still spans the full available width.
        final groupDuring = tester.getSize(groupFinder);
        expect(groupDuring.width, closeTo(groupBefore.width, 0.5));

        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('expanded vertical group stretches buttons full width', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SizedBox(
              width: 300,
              child: ButtonGroup<String>(
                expanded: true,
                direction: Axis.vertical,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );

        final materials = find.descendant(
          of: find.byType(ButtonGroup<String>),
          matching: find.byType(Material),
        );
        for (final material in materials.evaluate()) {
          expect(
            tester.getSize(find.byWidget(material.widget)).width,
            300,
          );
        }
      });

      testWidgets('connected group ignores expanded flag (always flexible)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SizedBox(
              width: 400,
              child: ButtonGroup<String>(
                variant: ButtonGroupVariant.connected,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );

        final box = tester.getSize(find.byType(ButtonGroup<String>));
        expect(box.width, 400);
      });
    });

    group('Custom color', () {
      testWidgets('color overrides the selected button background', (
        tester,
      ) async {
        const custom = Color(0xFF00696D);
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              color: custom,
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        Material materialOf(String label) => tester.widget<Material>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(Material),
              )
              .first,
        );

        // Selected button uses the custom color.
        expect(materialOf('Alpha').color, custom);
        // Unselected button keeps the tonal style's default container.
        expect(
          materialOf('Beta').color,
          Theme.of(
            tester.element(find.text('Beta')),
          ).colorScheme.surfaceContainerHighest,
        );
      });

      testWidgets('dark custom color derives a light foreground', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              color: const Color(0xFF111111),
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final label = tester.widget<Text>(find.text('Alpha'));
        expect(label.style?.color, Colors.white);
      });

      testWidgets('light custom color derives a dark foreground', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              color: const Color(0xFFEEEEEE),
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final label = tester.widget<Text>(find.text('Alpha'));
        expect(label.style?.color, Colors.black);
      });

      testWidgets('custom color applies across all styles', (tester) async {
        const custom = Color(0xFF00696D);
        for (final style in ButtonGroupStyle.values) {
          await tester.pumpWidget(
            wrapWithTheme(
              ButtonGroup<String>(
                style: style,
                color: custom,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          );

          final material = tester.widget<Material>(
            find
                .ancestor(
                  of: find.text('Alpha'),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(material.color, custom);
        }
      });
    });

    group('Connected variant layout', () {
      testWidgets('uses 2dp gaps between buttons', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              variant: ButtonGroupVariant.connected,
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final gaps = tester
            .widgetList<SizedBox>(
              find.descendant(
                of: find.byType(ButtonGroup<String>),
                matching: find.byType(SizedBox),
              ),
            )
            .where((box) => box.width == 2.0);

        expect(gaps.length, 1);
      });

      testWidgets('connected group expands to fill available width', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            SizedBox(
              width: 400,
              child: ButtonGroup<String>(
                variant: ButtonGroupVariant.connected,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                ],
                selected: const {'a'},
              ),
            ),
          ),
        );

        final box = tester.getSize(find.byType(ButtonGroup<String>));
        expect(box.width, 400);
      });

      testWidgets('connected group does not change width on press', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              variant: ButtonGroupVariant.connected,
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );
        await tester.pump();

        final groupFinder = find.byType(ButtonGroup<String>);
        final before = tester.getSize(groupFinder);
        final betaFinder = find.ancestor(
          of: find.text('Beta'),
          matching: find.byType(Material),
        );
        final betaBefore = tester.getSize(betaFinder.first);

        // Press and hold the second button mid-animation.
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Beta')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        final during = tester.getSize(groupFinder);
        expect(during.width, closeTo(before.width, 0.5));
        // Connected groups never change individual button widths.
        expect(
          tester.getSize(betaFinder.first).width,
          closeTo(betaBefore.width, 0.5),
        );

        await gesture.up();
        await tester.pumpAndSettle();
      });
    });

    group('Selection', () {
      testWidgets('single select: taps select the tapped item', (
        tester,
      ) async {
        Set<String>? result;
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
              onSelectionChanged: (next) => result = next,
            ),
          ),
        );

        await tester.tap(find.text('Beta'));
        await tester.pumpAndSettle();

        expect(result, {'b'});
      });

      testWidgets('single select: only one item can be selected', (
        tester,
      ) async {
        Set<String>? result;
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
                ButtonGroupItem(value: 'c', label: 'Gamma'),
              ],
              selected: const {'a'},
              onSelectionChanged: (next) => result = next,
            ),
          ),
        );

        await tester.tap(find.text('Beta'));
        expect(result, {'b'});
      });

      testWidgets('selection is required by default (cannot deselect last)', (
        tester,
      ) async {
        Set<String>? result;
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
              onSelectionChanged: (next) => result = next,
            ),
          ),
        );

        await tester.tap(find.text('Alpha'));
        await tester.pumpAndSettle();

        // Tapping the already-selected item keeps the selection.
        expect(result, isNull);
      });

      testWidgets('emptySelectionAllowed allows deselecting', (tester) async {
        Set<String>? result;
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
              emptySelectionAllowed: true,
              onSelectionChanged: (next) => result = next,
            ),
          ),
        );

        await tester.tap(find.text('Alpha'));
        await tester.pumpAndSettle();

        expect(result, isEmpty);
      });

      testWidgets('multi-select: taps toggle items', (tester) async {
        Set<String>? result;
        var selected = <String>{'a'};
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => wrapWithTheme(
              ButtonGroup<String>(
                multiSelectionEnabled: true,
                emptySelectionAllowed: true,
                items: const [
                  ButtonGroupItem(value: 'a', label: 'Alpha'),
                  ButtonGroupItem(value: 'b', label: 'Beta'),
                  ButtonGroupItem(value: 'c', label: 'Gamma'),
                ],
                selected: selected,
                onSelectionChanged: (next) {
                  result = next;
                  setState(() => selected = next);
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Beta'));
        await tester.pump();
        expect(result, {'a', 'b'});

        await tester.tap(find.text('Alpha'));
        await tester.pump();
        expect(result, {'b'});
      });

      testWidgets('disabled item cannot be selected', (tester) async {
        Set<String>? result;
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta', enabled: false),
              ],
              selected: const {'a'},
              onSelectionChanged: (next) => result = next,
            ),
          ),
        );

        await tester.tap(find.text('Beta'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(result, isNull);
      });

      testWidgets('read-only when onSelectionChanged is null', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        await tester.tap(find.text('Beta'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('showSelectedIcon displays check on selected items', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              showSelectedIcon: true,
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('selected item exposes selected semantics', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final node = tester.getSemantics(find.text('Alpha'));
        expect(node.flagsCollection.isButton, isTrue);
        expect(
          node.flagsCollection.isSelected,
          equals(Tristate.isTrue),
        );

        final unselected = tester.getSemantics(find.text('Beta'));
        expect(
          unselected.flagsCollection.isSelected,
          equals(Tristate.isFalse),
        );

        semantics.dispose();
      });

      testWidgets('provides tooltips when specified', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(
                  value: 'a',
                  icon: Icons.settings,
                  tooltip: 'Settings',
                ),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final tooltip = tester.widget<Tooltip>(
          find.byWidgetPredicate(
            (widget) => widget is Tooltip && widget.message == 'Settings',
          ),
        );
        expect(tooltip.message, 'Settings');
      });
    });

    group('Orientation', () {
      testWidgets('vertical direction stacks buttons', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              direction: Axis.vertical,
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final groupBox = tester.getSize(find.byType(ButtonGroup<String>));
        // Two buttons stacked (40 + 8 gap + 40 for sm default? no, md default:
        // 56 + 8 + 56).
        expect(groupBox.height, 120);
      });

      testWidgets('horizontal is the default direction', (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            ButtonGroup<String>(
              items: const [
                ButtonGroupItem(value: 'a', label: 'Alpha'),
                ButtonGroupItem(value: 'b', label: 'Beta'),
              ],
              selected: const {'a'},
            ),
          ),
        );

        final groupBox = tester.getSize(find.byType(ButtonGroup<String>));
        expect(groupBox.width, greaterThan(groupBox.height));
      });
    });
  });
}
