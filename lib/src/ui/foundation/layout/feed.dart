import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/layout/layout_toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A feed layout that adapts column count based on window size.
///
/// Integrated with [RZToolbar] to handle both actions and navigation
/// on mobile and desktop.
class FeedLayout extends StatelessWidget {
  const FeedLayout({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.childAspectRatio = 0.8,
    this.toolbar,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
    this.header,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double childAspectRatio;

  /// An optional [RZToolbar] to display with the feed.
  final RZToolbar? toolbar;

  /// Optional navigation destinations to be integrated into the toolbar.
  final List<NavigationDestination>? destinations;

  /// The index of the currently selected destination.
  final int? selectedIndex;

  /// Called when a navigation destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  /// An optional header widget displayed above the grid.
  final Widget? header;

  /// The number of grid columns for [sizeClass].
  static int crossAxisCountFor(WindowSizeClass sizeClass) {
    return switch (sizeClass) {
      WindowSizeClass.compact || WindowSizeClass.medium => 1,
      WindowSizeClass.expanded => 2,
      WindowSizeClass.large => 3,
      WindowSizeClass.extraLarge => 4,
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);
        final hasToolbar = toolbar != null || destinations != null;

        final grid = GridView.builder(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: layoutBottomPadding(
              sizeClass,
              hasToolbar: hasToolbar,
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCountFor(sizeClass),
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );

        final header = this.header;
        final content = header == null
            ? grid
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  Expanded(child: grid),
                ],
              );

        return LayoutToolbarOverlay(
          content: content,
          sizeClass: sizeClass,
          toolbar: buildLayoutToolbar(
            toolbar: toolbar,
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
          ),
        );
      },
    );
  }
}
