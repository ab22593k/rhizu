import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('ListDetailLayout', () {
    final listWidget = Container(key: const Key('list'), color: Colors.red);
    final detailWidget = Container(
      key: const Key('detail'),
      color: Colors.blue,
    );

    testWidgets('shows only list on compact screen when no detail selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ListDetailLayout(
            list: listWidget,
            detail: detailWidget,
          ),
        ),
      );

      expect(find.byKey(const Key('list')), findsOneWidget);
      expect(find.byKey(const Key('detail')), findsNothing);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('shows only detail on compact screen when detail visible', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ListDetailLayout(
            list: listWidget,
            detail: detailWidget,
            isDetailVisible: true,
          ),
        ),
      );

      expect(find.byKey(const Key('list')), findsNothing);
      expect(find.byKey(const Key('detail')), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('shows both on expanded screen', (tester) async {
      tester.view.physicalSize = const Size(1000, 800); // Expanded range
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ListDetailLayout(
            list: listWidget,
            detail: detailWidget,
          ),
        ),
      );

      expect(find.byKey(const Key('list')), findsOneWidget);
      expect(find.byKey(const Key('detail')), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
