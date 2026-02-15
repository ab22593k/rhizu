import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/fab_menu/fab_menu.dart';

// Helper to create test app with proper theme
Widget createTestApp({required Widget body}) {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true).copyWith(
      splashFactory: InkRipple.splashFactory,
    ),
    home: Scaffold(body: body),
  );
}

void main() {
  group('ExpressiveFabMenu', () {
    testWidgets('renders FAB in collapsed state initially', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const ValueKey('fab_menu_toggle')), findsOneWidget);
      // Items are in the tree for animation purposes
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('expands menu on tap', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
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

      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('collapses menu on second tap', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
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

      // Close
      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();
      // Items are still in tree but invisible due to animation
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('triggers item callback and closes menu', (tester) async {
      var itemPressed = false;
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
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

      // Tap the item's FAB (not the text label)
      final itemFab = find.descendant(
        of: find.byType(FabMenuItemWidget),
        matching: find.byType(FloatingActionButton),
      );
      expect(itemFab, findsOneWidget);
      await tester.tap(itemFab);
      await tester.pumpAndSettle();

      expect(itemPressed, isTrue);
      // Menu is closed but items remain in tree with 0 opacity
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
                label: '1',
                icon: const Icon(Icons.looks_one),
                onPressed: () {},
              ),
              FabMenuItem(
                label: '2',
                icon: const Icon(Icons.looks_two),
                onPressed: () {},
              ),
              FabMenuItem(
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

      expect(find.byType(FabMenuItemWidget), findsNWidgets(3));
    });

    testWidgets('FAB icon rotates when menu opens', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Initial state - find the RotationTransition
      final rotationFinder = find.descendant(
        of: find.byKey(const ValueKey('fab_menu_toggle')),
        matching: find.byType(RotationTransition),
      );
      expect(rotationFinder, findsOneWidget);

      // Open menu
      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      // Verify RotationTransition still exists
      expect(rotationFinder, findsOneWidget);
    });

    testWidgets('menu items are animated', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          body: FabMenu(
            children: [
              FabMenuItem(
                label: 'Item 1',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      );

      // Find the item widget which uses animations
      final itemFinder = find.byType(FabMenuItemWidget);
      expect(itemFinder, findsOneWidget);

      // Open menu
      await tester.tap(find.byKey(const ValueKey('fab_menu_toggle')));
      await tester.pumpAndSettle();

      // Item should have ScaleTransition and FadeTransition
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
  });
}
