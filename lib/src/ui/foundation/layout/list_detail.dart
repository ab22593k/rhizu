import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/layout/layout_toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A list-detail layout that shows either single or dual pane based on window size.
///
/// Integrated with [RZToolbar] to handle navigation and contextual actions.
class RZListDetailLayout extends StatelessWidget {
  const RZListDetailLayout({
    required this.list,
    this.detail,
    super.key,
    this.isDetailVisible = false,
    this.listFlex = 1,
    this.detailFlex = 1,
    this.listToolbar,
    this.detailToolbar,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  final Widget list;
  final Widget? detail;
  final bool isDetailVisible;
  final int listFlex;
  final int detailFlex;

  /// Optional [RZToolbar] for the list pane.
  final RZToolbar? listToolbar;

  /// Optional [RZToolbar] for the detail pane.
  final RZToolbar? detailToolbar;

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
        final isCompact = isCompactLayout(sizeClass);
        final detail = this.detail;

        if (isCompact || detail == null) {
          return _buildSinglePane(
            context,
            sizeClass: sizeClass,
            isCompact: isCompact,
          );
        }

        return Row(
          children: [
            Expanded(
              flex: listFlex,
              child: LayoutPaneWithToolbar(
                content: list,
                toolbar: listToolbar,
                sizeClass: sizeClass,
                destinations: destinations,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              flex: detailFlex,
              child: LayoutPaneWithToolbar(
                content: detail,
                toolbar: detailToolbar,
                sizeClass: sizeClass,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSinglePane(
    BuildContext context, {
    required WindowSizeClass sizeClass,
    required bool isCompact,
  }) {
    final showDetail = isDetailVisible && detail != null;
    final content = showDetail ? detail! : list;
    final toolbar = showDetail ? detailToolbar : listToolbar;

    final body = LayoutToolbarOverlay(
      content: content,
      sizeClass: sizeClass,
      toolbar: buildLayoutToolbar(
        toolbar: toolbar,
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      bottomPadding: 80,
    );

    // A lone list on a wide window reads better constrained to a comfortable
    // reading width.
    if (!isCompact && detail == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: body,
        ),
      );
    }

    return body;
  }
}
