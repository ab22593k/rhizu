import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

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
          home: SupportingPaneLayout(
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
          home: SupportingPaneLayout(
            main: mainWidget,
            supporting: supportingWidget,
          ),
        ),
      );

      expect(find.byKey(const Key('main')), findsOneWidget);
      expect(find.byKey(const Key('supporting')), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
