// ignore_for_file: document_ignores, omit_local_variable_types

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/toolbars/toolbars.dart';
import 'package:rhizu/src/foundations/layout/adaptive_toolbar.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

void main() {
  group('AdaptiveToolbarPlacement', () {
    testWidgets('renders floating toolbar by default even in compact mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AdaptiveToolbarPlacement(
                  sizeClass: WindowSizeClass.compact,
                  toolbar: Toolbar(children: [Text('Action')]),
                ),
              ],
            ),
          ),
        ),
      );

      final toolbarFinder = find.byType(Toolbar);
      expect(toolbarFinder, findsOneWidget);

      final toolbar = tester.widget<Toolbar>(toolbarFinder);
      expect(toolbar.type, ToolbarType.floating);
    });

    testWidgets(
      'renders floating toolbar in expanded mode even if isDocked is true',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  AdaptiveToolbarPlacement(
                    sizeClass: WindowSizeClass.expanded,
                    toolbar: Toolbar(children: [Text('Action')]),
                    isDocked: true,
                  ),
                ],
              ),
            ),
          ),
        );

        final toolbarFinder = find.byType(Toolbar);
        expect(toolbarFinder, findsOneWidget);

        final toolbar = tester.widget<Toolbar>(toolbarFinder);
        expect(toolbar.type, ToolbarType.floating);

        // Verify placement (floating at bottom)
        final Positioned positioned = tester.widget(find.byType(Positioned));
        expect(positioned.bottom, 16);
      },
    );

    testWidgets('renders vertical toolbar when isVertical is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AdaptiveToolbarPlacement(
                  sizeClass: WindowSizeClass.expanded,
                  toolbar: Toolbar(children: [Text('Action')]),
                  isVertical: true,
                ),
              ],
            ),
          ),
        ),
      );

      final toolbarFinder = find.byType(Toolbar);
      final toolbar = tester.widget<Toolbar>(toolbarFinder);
      expect(toolbar.layout, ToolbarLayout.vertical);

      // Verify placement (on the right)
      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.right, 16);
    });
  });
}
