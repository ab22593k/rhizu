import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/layout/layout_toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A supporting pane layout that shows supporting content based on window size.
///
/// Integrated with [RZToolbar] to handle navigation and contextual actions.
class RZSupportingPaneLayout extends StatelessWidget {
  const RZSupportingPaneLayout({
    required this.main,
    required this.supporting,
    super.key,
    this.mainFlex = 2,
    this.supportingFlex = 1,
    this.mainToolbar,
    this.supportingToolbar,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  final Widget main;
  final Widget supporting;
  final int mainFlex;
  final int supportingFlex;

  /// Optional [RZToolbar] for the main pane.
  final RZToolbar? mainToolbar;

  /// Optional [RZToolbar] for the supporting pane.
  final RZToolbar? supportingToolbar;

  /// Optional navigation destinations to be integrated into the toolbar.
  final List<NavigationDestination>? destinations;

  /// The index of the currently selected destination.
  final int? selectedIndex;

  /// Called when a navigation destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);

        if (isCompactLayout(sizeClass)) {
          return LayoutToolbarOverlay(
            content: main,
            sizeClass: sizeClass,
            toolbar: buildLayoutToolbar(
              toolbar: mainToolbar,
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
            bottomPadding: 80,
          );
        }

        return Row(
          children: [
            Expanded(
              flex: mainFlex,
              child: LayoutPaneWithToolbar(
                content: main,
                toolbar: mainToolbar,
                sizeClass: sizeClass,
                destinations: destinations,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: supportingFlex,
              child: LayoutPaneWithToolbar(
                content: supporting,
                toolbar: supportingToolbar,
                sizeClass: sizeClass,
              ),
            ),
          ],
        );
      },
    );
  }
}
