import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/toolbar/toolbar.dart';
import 'package:rhizu/src/foundation/layout/feed.dart';

void main() {
  group('FeedLayout', () {
    testWidgets('renders grid view with items', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedLayout(
              itemCount: 10,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('renders toolbar as floating in compact mode', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedLayout(
              itemCount: 10,
              itemBuilder: (context, index) => Text('Item $index'),
              toolbar: const RZToolbar(children: [Icon(Icons.add)]),
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

    testWidgets('renders toolbar as floating in expanded mode', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedLayout(
              itemCount: 10,
              itemBuilder: (context, index) => Text('Item $index'),
              toolbar: const RZToolbar(children: [Icon(Icons.add)]),
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
  });
}
