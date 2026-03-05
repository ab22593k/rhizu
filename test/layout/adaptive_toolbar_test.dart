// ignore_for_file: document_ignores, omit_local_variable_types

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/toolbar/placement.dart';
import 'package:rhizu/src/components/toolbar/toolbar.dart';
import 'package:rhizu/src/foundation/window_size_class.dart';

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
                  toolbar: RZToolbar(children: [Text('Action')]),
                ),
              ],
            ),
          ),
        ),
      );

      final toolbarFinder = find.byType(RZToolbar);
      expect(toolbarFinder, findsOneWidget);

      final toolbar = tester.widget<RZToolbar>(toolbarFinder);
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
                    toolbar: RZToolbar(children: [Text('Action')]),
                    isDocked: true,
                  ),
                ],
              ),
            ),
          ),
        );

        final toolbarFinder = find.byType(RZToolbar);
        expect(toolbarFinder, findsOneWidget);

        final toolbar = tester.widget<RZToolbar>(toolbarFinder);
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
                  toolbar: RZToolbar(children: [Text('Action')]),
                  isVertical: true,
                ),
              ],
            ),
          ),
        ),
      );

      final toolbarFinder = find.byType(RZToolbar);
      final toolbar = tester.widget<RZToolbar>(toolbarFinder);
      expect(toolbar.layout, ToolbarLayout.vertical);

      // Verify placement (on the right)
      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.right, 16);
    });
  });
}
