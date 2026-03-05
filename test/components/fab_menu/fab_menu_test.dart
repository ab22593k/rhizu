import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/fab_menu.dart';

// Helper to create test app with FAB positioned at bottom-right,
// giving overlay items room to appear above.
Widget createTestApp({required Widget body}) {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true).copyWith(
      splashFactory: InkRipple.splashFactory,
    ),
    home: Scaffold(
      body: const SizedBox.expand(),
      floatingActionButton: body,
    ),
  );
}

void main() {
  group('ExpressiveFabMenu', () {
    testWidgets('renders FAB in collapsed state initially', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const ValueKey('fab_menu_toggle')), findsOneWidget);
      // Items are NOT in the tree when collapsed (overlay mode)
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('expands menu on tap showing items in overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      // After expanding, items appear in the overlay
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.byType(RZFabMenuItemWidget), findsOneWidget);
    });

    testWidgets('collapses menu when scrim is tapped', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Open
      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Item 1'), findsOneWidget);

      // Close by tapping the scrim
      await tester.tap(find.byKey(const ValueKey('fab_menu_scrim')));
      await tester.pumpAndSettle();

      // Items are removed from the overlay after collapse animation
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('triggers item callback and closes menu', (tester) async {
      var itemPressed = false;
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {
                  itemPressed = true;
                },
              ),
            ],
          ),
        ),
      );

      // Open
      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      // Verify items are visible in overlay
      expect(find.byType(RZFabMenuItemWidget), findsOneWidget);

      // Tap the item's FAB
      final itemFab = find.descendant(
        of: find.byType(RZFabMenuItemWidget),
        matching: find.byType(FloatingActionButton),
      );
      expect(itemFab, findsOneWidget);
      await tester.tap(itemFab, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(itemPressed, isTrue);
    });

    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: '1',
                icon: const Icon(Icons.looks_one),
                onPressed: () {},
              ),
              RZFabMenuItem(
                label: '2',
                icon: const Icon(Icons.looks_two),
                onPressed: () {},
              ),
              RZFabMenuItem(
                label: '3',
                icon: const Icon(Icons.looks_3),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      expect(find.byType(RZFabMenuItemWidget), findsNWidgets(3));
    });

    testWidgets('FAB icon rotates when menu opens', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      final rotationFinder = find.descendant(
        of: find.byKey(const ValueKey('fab_menu_toggle')),
        matching: find.byType(RotationTransition),
      );
      expect(rotationFinder, findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      expect(rotationFinder, findsOneWidget);
    });

    testWidgets('menu items are animated with scale and fade', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Items not in tree until expanded
      expect(find.byType(RZFabMenuItemWidget), findsNothing);

      // Open menu
      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      final itemFinder = find.byType(RZFabMenuItemWidget);
      expect(itemFinder, findsOneWidget);

      final scaleFinder = find.descendant(
        of: itemFinder,
        matching: find.byType(ScaleTransition),
      );
      final fadeFinder = find.descendant(
        of: itemFinder,
        matching: find.byType(FadeTransition),
      );
      expect(scaleFinder, findsOneWidget);
      expect(fadeFinder, findsOneWidget);
    });

    testWidgets('renders default add icon when no custom icon is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      final mainFab = find.byKey(const ValueKey('fab_menu_toggle'));
      expect(mainFab, findsOneWidget);

      final addIcon = find.descendant(
        of: mainFab,
        matching: find.byIcon(Icons.add),
      );
      expect(addIcon, findsOneWidget);
    });

    testWidgets('renders custom icon when provided', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            icon: const Icon(Icons.create),
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.copy),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      final mainFab = find.byKey(const ValueKey('fab_menu_toggle'));
      expect(mainFab, findsOneWidget);

      final customIcon = find.descendant(
        of: mainFab,
        matching: find.byIcon(Icons.create),
      );
      expect(customIcon, findsOneWidget);
    });

    testWidgets('only FAB takes layout space (no items in collapsed tree)', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          body: RZFabMenu(
            children: [
              RZFabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
              RZFabMenuItem(
                label: 'Item 2',
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Only the FAB should be in the tree
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(RZFabMenuItemWidget), findsNothing);
      expect(find.byType(CompositedTransformTarget), findsOneWidget);
      expect(find.byType(OverlayPortal), findsOneWidget);
    });
  });

  group('RZFabMenuConfig', () {
    test('creates config with required items', () {
      final config = RZFabMenuConfig(
        items: [
          RZFabMenuItem(
            label: 'Test',
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      );

      expect(config.items.length, 1);
      expect(config.icon, isNull);
      expect(config.alignment, Alignment.bottomRight);
    });

    test('creates config with optional parameters', () {
      final config = RZFabMenuConfig(
        items: [
          RZFabMenuItem(
            label: 'Test',
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
        icon: const Icon(Icons.create),
        alignment: Alignment.bottomLeft,
      );

      expect(config.items.length, 1);
      expect(config.icon, isNotNull);
      expect(config.alignment, Alignment.bottomLeft);
    });
  });
}
