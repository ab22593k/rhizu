import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/buttons/split_button.dart';
import 'package:rhizu/src/components/toolbars/toolbars.dart';

Finder findToolbarMaterial() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Material &&
        widget.key == const ValueKey('expressive_toolbar_material'),
  );
}

void main() {
  group('ExpressiveToolbar', () {
    testWidgets('renders with default floating style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Toolbar), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('renders docked toolbar with no elevation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              type: ToolbarType.docked,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      expect(material.elevation, 0.0);
    });

    testWidgets('renders floating toolbar with default elevation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      expect(material.elevation, 2.0);
    });

    testWidgets('applies vibrant color style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          home: Scaffold(
            body: Toolbar(
              style: ToolbarStyle.vibrant,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final colorScheme = Theme.of(tester.element(finder)).colorScheme;
      expect(material.color, colorScheme.primaryContainer);
    });

    testWidgets('applies standard color style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final colorScheme = Theme.of(tester.element(finder)).colorScheme;
      expect(material.color, colorScheme.surfaceContainer);
    });

    testWidgets('renders with custom background color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              backgroundColor: customColor,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      expect(material.color, customColor);
    });

    testWidgets('renders docked toolbar with no elevation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              type: ToolbarType.docked,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      expect(material.elevation, 0.0);
    });

    testWidgets('renders floating toolbar with default elevation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      expect(material.elevation, 2.0);
    });

    testWidgets('applies vibrant color style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          home: Scaffold(
            body: Toolbar(
              style: ToolbarStyle.vibrant,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final colorScheme = Theme.of(tester.element(finder)).colorScheme;
      expect(material.color, colorScheme.primaryContainer);
    });

    testWidgets('applies standard color style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final colorScheme = Theme.of(tester.element(finder)).colorScheme;
      expect(material.color, colorScheme.surfaceContainer);
    });

    testWidgets('renders with custom background color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              backgroundColor: customColor,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      expect(material.color, customColor);
    });

    testWidgets('renders with leading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              leading: const Icon(Icons.menu),
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders with trailing widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('renders with FAB', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              fab: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders vertical layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              layout: ToolbarLayout.vertical,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.format_bold),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.format_italic),
                ),
              ],
            ),
          ),
        ),
      );

      final toolbarColumn = find.descendant(
        of: find.byType(Toolbar),
        matching: find.byType(Column),
      );
      expect(toolbarColumn, findsOneWidget);
    });

    testWidgets('renders horizontal layout by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.format_bold),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.format_italic),
                ),
              ],
            ),
          ),
        ),
      );

      final toolbarRow = find.descendant(
        of: find.byType(Toolbar),
        matching: find.byType(Row),
      );
      expect(toolbarRow, findsOneWidget);
    });

    testWidgets('integrates with SplitButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                SplitButton<String>(
                  label: 'Action',
                  onPressed: () {},
                  menuBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: '1',
                      child: Text('Option 1'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('renders multiple children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNWidgets(3));
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.all(20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              padding: customPadding,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      // Verify custom padding is applied by checking widget hierarchy
      final materialFinder = findToolbarMaterial();
      expect(materialFinder, findsOneWidget);

      // Find Padding that is a direct child of Material
      final paddingFinder = find.descendant(
        of: materialFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Padding && widget.padding == customPadding,
        ),
      );
      expect(paddingFinder, findsOneWidget);
    });

    testWidgets('applies custom border radius', (tester) async {
      const customRadius = BorderRadius.all(Radius.circular(16));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              borderRadius: customRadius,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, customRadius);
    });

    testWidgets('applies default border radius for floating type', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(
        (shape.borderRadius as BorderRadius).topLeft.x,
        closeTo(28.0, 0.1),
      );
    });

    testWidgets('applies zero border radius for docked type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Toolbar(
              type: ToolbarType.docked,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
          ),
        ),
      );

      final finder = findToolbarMaterial();
      expect(finder, findsOneWidget);

      final material = tester.widget<Material>(finder);
      final shape = material.shape! as RoundedRectangleBorder;
      expect(
        (shape.borderRadius as BorderRadius).topLeft.x,
        closeTo(0.0, 0.1),
      );
    });
  });
}
