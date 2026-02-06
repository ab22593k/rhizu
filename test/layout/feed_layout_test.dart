import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('FeedLayout', () {
    testWidgets('renders grid view with items', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: FeedLayout(
            itemCount: 10,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
