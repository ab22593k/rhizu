import 'package:flutter/material.dart';
import 'package:rhizu/src/components/toolbars/toolbars.dart';
import 'package:rhizu/src/foundations/layout/adaptive_toolbar.dart';
import 'package:rhizu/src/foundations/layout/layout_nav.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A feed layout that adapts column count based on window size.
///
/// Integrated with [Toolbar] to handle both actions and navigation
/// on mobile and desktop.
class FeedLayout extends StatefulWidget {
  const FeedLayout({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.childAspectRatio = 0.8,
    this.toolbar,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double childAspectRatio;

  /// An optional [Toolbar] to display with the feed.
  final Toolbar? toolbar;

  /// Optional navigation destinations to be integrated into the toolbar.
  final List<NavigationDestination>? destinations;

  /// The index of the currently selected destination.
  final int? selectedIndex;

  /// Called when a navigation destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<FeedLayout> createState() => _FeedLayoutState();
}

class _FeedLayoutState extends State<FeedLayout> {
  late int? _cachedCrossAxisCount;
  double? _cachedWidth;

  int _getCrossAxisCount(double width) {
    if (_cachedWidth != null && width == _cachedWidth) {
      return _cachedCrossAxisCount!;
    }

    _cachedWidth = width;
    final sizeClass = WindowSizeClass.fromWidth(width);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        _cachedCrossAxisCount = 1;
      case WindowSizeClass.medium:
        _cachedCrossAxisCount = 1;
      case WindowSizeClass.expanded:
        _cachedCrossAxisCount = 2;
      case WindowSizeClass.large:
        _cachedCrossAxisCount = 3;
      case WindowSizeClass.extraLarge:
        _cachedCrossAxisCount = 4;
    }

    return _cachedCrossAxisCount!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sizeClass = WindowSizeClass.fromWidth(width);
        final crossAxisCount = _getCrossAxisCount(width);

        // Calculate bottom padding for toolbar avoidance
        final bottomPadding =
            (widget.toolbar != null || widget.destinations != null)
            ? (sizeClass == WindowSizeClass.compact ? 80.0 : 100.0)
            : 16.0;

        final grid = GridView.builder(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottomPadding,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: widget.childAspectRatio,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
        );

        final destinations = widget.destinations;
        final toolbar = widget.toolbar;

        if (toolbar == null && destinations == null) return grid;

        final effectiveToolbar = Toolbar(
          style: toolbar?.style ?? ToolbarStyle.standard,
          leading: toolbar?.leading,
          trailing: toolbar?.trailing,
          fab: toolbar?.fab,
          centerTitle: toolbar?.centerTitle ?? false,
          scrollable: toolbar?.scrollable ?? false,
          backgroundColor: toolbar?.backgroundColor,
          elevation: toolbar?.elevation,
          padding: toolbar?.padding,
          borderRadius: toolbar?.borderRadius,
          shape: toolbar?.shape,
          children: mergeNavAndActions(
            destinations,
            widget.selectedIndex,
            widget.onDestinationSelected,
            toolbar?.children,
          ),
        );

        return Stack(
          children: [
            grid,
            AdaptiveToolbarPlacement(
              sizeClass: sizeClass,
              toolbar: effectiveToolbar,
            ),
          ],
        );
      },
    );
  }
}
