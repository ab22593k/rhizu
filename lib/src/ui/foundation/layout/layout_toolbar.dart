import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/toolbar/items.dart';
import 'package:rhizu/src/ui/components/toolbar/placement.dart';
import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// Whether [sizeClass] uses the single-pane foundation layout.
///
/// The adaptive foundations collapse to one pane at compact and medium
/// widths and split at expanded and above.
bool isCompactLayout(WindowSizeClass sizeClass) =>
    sizeClass == WindowSizeClass.compact || sizeClass == WindowSizeClass.medium;

/// The bottom inset that keeps scrollable content clear of a floating
/// toolbar in a foundation layout.
///
/// Returns a small content inset when no toolbar is present, and the
/// compact/expanded toolbar clearance otherwise.
double layoutBottomPadding(
  WindowSizeClass sizeClass, {
  required bool hasToolbar,
}) {
  if (!hasToolbar) return 16;
  return sizeClass == WindowSizeClass.compact ? 80 : 100;
}

/// Builds the effective [RZToolbar] for a foundation layout.
///
/// Returns `null` when neither [toolbar] nor [destinations] is provided, so
/// callers can skip the toolbar overlay entirely. Navigation [destinations]
/// are merged into the toolbar's action children, keeping the layout
/// configuration (style, FAB, padding, shape, …) intact.
RZToolbar? buildLayoutToolbar({
  required RZToolbar? toolbar,
  required List<NavigationDestination>? destinations,
  required int? selectedIndex,
  required ValueChanged<int>? onDestinationSelected,
}) {
  if (toolbar == null && destinations == null) return null;

  return (toolbar ?? const RZToolbar(children: [])).copyWith(
    children: mergeNavAndActions(
      destinations,
      selectedIndex,
      onDestinationSelected,
      toolbar?.children,
    ),
  );
}

/// Lays out [content] beneath an optional adaptive [toolbar].
///
/// When [toolbar] is `null` the content is returned unchanged. When
/// [bottomPadding] is non-null the content is inset by that amount so the
/// floating toolbar does not cover interactive content.
class LayoutToolbarOverlay extends StatelessWidget {
  const LayoutToolbarOverlay({
    required this.content,
    required this.sizeClass,
    required this.toolbar,
    super.key,
    this.bottomPadding,
  });

  /// The layout body shown behind (and beneath) the toolbar.
  final Widget content;

  /// The window size class that decides the toolbar's adaptive placement.
  final WindowSizeClass sizeClass;

  /// The toolbar to overlay, or `null` to render [content] unchanged.
  final RZToolbar? toolbar;

  /// Optional reservation below [content].
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveToolbar = toolbar;
    if (effectiveToolbar == null) return content;

    final padding = bottomPadding;
    final body = padding == null
        ? content
        : Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: content,
          );

    return Stack(
      children: [
        body,
        AdaptiveToolbarPlacement(
          sizeClass: sizeClass,
          toolbar: effectiveToolbar,
        ),
      ],
    );
  }
}

/// A split-layout pane with its own optional toolbar.
///
/// Used by the list-detail and supporting-pane foundations for each pane of
/// the expanded layout. Navigation destinations belong to the leading pane,
/// so callers only pass them for that pane.
class LayoutPaneWithToolbar extends StatelessWidget {
  const LayoutPaneWithToolbar({
    required this.content,
    required this.sizeClass,
    required this.toolbar,
    super.key,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  final Widget content;
  final WindowSizeClass sizeClass;
  final RZToolbar? toolbar;
  final List<NavigationDestination>? destinations;
  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutToolbarOverlay(
      content: content,
      sizeClass: sizeClass,
      toolbar: buildLayoutToolbar(
        toolbar: toolbar,
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      bottomPadding: 100,
    );
  }
}
