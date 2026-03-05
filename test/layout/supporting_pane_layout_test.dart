import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/toolbar/toolbar.dart';
import 'package:rhizu/src/foundation/layout/supporting_pane.dart';

void main() {
  group('SupportingPaneLayout', () {
    final mainWidget = Container(key: const Key('main'), color: Colors.red);
    final supportingWidget = Container(
      key: const Key('supporting'),
      color: Colors.blue,
    );

    testWidgets('shows only main content on compact screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: RZSupportingPaneLayout(
            main: mainWidget,
            supporting: supportingWidget,
          ),
        ),
      );

      expect(find.byKey(const Key('main')), findsOneWidget);
      expect(find.byKey(const Key('supporting')), findsNothing);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('shows both on expanded screen', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: RZSupportingPaneLayout(
            main: mainWidget,
            supporting: supportingWidget,
          ),
        ),
      );

      expect(find.byKey(const Key('main')), findsOneWidget);
      expect(find.byKey(const Key('supporting')), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('renders main toolbar in compact mode', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RZSupportingPaneLayout(
              main: mainWidget,
              supporting: supportingWidget,
              mainToolbar: const RZToolbar(children: [Icon(Icons.menu)]),
            ),
          ),
        ),
      );

      final toolbarFinder = find.byType(RZToolbar);
      expect(toolbarFinder, findsOneWidget);

      final toolbar = tester.widget<RZToolbar>(toolbarFinder);
      expect(toolbar.type, ToolbarType.floating);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('renders both toolbars in expanded mode', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RZSupportingPaneLayout(
              main: mainWidget,
              supporting: supportingWidget,
              mainToolbar: const RZToolbar(children: [Icon(Icons.menu)]),
              supportingToolbar: const RZToolbar(
                children: [Icon(Icons.settings)],
              ),
            ),
          ),
        ),
      );

      final toolbarFinder = find.byType(RZToolbar);
      expect(toolbarFinder, findsNWidgets(2));

      final toolbars = tester.widgetList<RZToolbar>(toolbarFinder);
      for (final toolbar in toolbars) {
        expect(toolbar.type, ToolbarType.floating);
      }

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
