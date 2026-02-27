import 'package:flutter/material.dart';
import 'package:rhizu/src/components/toolbars/toolbars.dart';
import 'package:rhizu/src/foundations/layout/adaptive_toolbar.dart';
import 'package:rhizu/src/foundations/layout/layout_nav.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A list-detail layout that shows either single or dual pane based on window size.
///
/// Integrated with [Toolbar] to handle navigation and contextual actions.
class ListDetailLayout extends StatefulWidget {
  const ListDetailLayout({
    required this.list,
    required this.detail,
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
  final Widget detail;
  final bool isDetailVisible;
  final int listFlex;
  final int detailFlex;

  /// Optional [Toolbar] for the list pane.
  final Toolbar? listToolbar;

  /// Optional [Toolbar] for the detail pane.
  final Toolbar? detailToolbar;

  /// Optional navigation destinations to be integrated into the toolbar.
  final List<NavigationDestination>? destinations;

  /// The index of the currently selected destination.
  final int? selectedIndex;

  /// Called when a navigation destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  late bool? _cachedIsCompact;
  double? _cachedWidth;

  /// Determines if layout should show single pane with caching.
  bool _isCompact(double width) {
    if (_cachedWidth != null && width == _cachedWidth) {
      return _cachedIsCompact!;
    }

    _cachedWidth = width;
    final sizeClass = WindowSizeClass.fromWidth(width);
    _cachedIsCompact =
        sizeClass == WindowSizeClass.compact ||
        sizeClass == WindowSizeClass.medium;

    return _cachedIsCompact!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sizeClass = WindowSizeClass.fromWidth(width);
        final isCompact = _isCompact(width);

        if (isCompact) {
          final content = widget.isDetailVisible ? widget.detail : widget.list;
          final toolbar = widget.isDetailVisible
              ? widget.detailToolbar
              : widget.listToolbar;

          final effectiveToolbar =
              toolbar != null || widget.destinations != null
              ? Toolbar(
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
                    widget.destinations,
                    widget.selectedIndex,
                    widget.onDestinationSelected,
                    toolbar?.children,
                  ),
                )
              : null;

          final bottomPadding = effectiveToolbar != null ? 80.0 : 0.0;

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: content,
              ),
              if (effectiveToolbar != null)
                AdaptiveToolbarPlacement(
                  sizeClass: sizeClass,
                  toolbar: effectiveToolbar,
                ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: widget.listFlex,
                child: _PaneWithToolbar(
                  content: widget.list,
                  toolbar: widget.listToolbar,
                  sizeClass: sizeClass,
                  destinations: widget.destinations,
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: widget.detailFlex,
                child: _PaneWithToolbar(
                  content: widget.detail,
                  toolbar: widget.detailToolbar,
                  sizeClass: sizeClass,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class _PaneWithToolbar extends StatelessWidget {
  const _PaneWithToolbar({
    required this.content,
    required this.toolbar,
    required this.sizeClass,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  final Widget content;
  final Toolbar? toolbar;
  final WindowSizeClass sizeClass;
  final List<NavigationDestination>? destinations;
  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final effectiveToolbar = toolbar != null || destinations != null
        ? Toolbar(
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
              selectedIndex,
              onDestinationSelected,
              toolbar?.children,
            ),
          )
        : null;

    if (effectiveToolbar == null) return content;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: content,
        ),
        AdaptiveToolbarPlacement(
          sizeClass: sizeClass,
          toolbar: effectiveToolbar,
        ),
      ],
    );
  }
}
