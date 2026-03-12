import 'package:flutter/material.dart';
import 'package:rhizu/src/ui/components/toolbar/items.dart';
import 'package:rhizu/src/ui/components/toolbar/placement.dart';
import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A list-detail layout that shows either single or dual pane based on window size.
///
/// Integrated with [RZToolbar] to handle navigation and contextual actions.
class RZListDetailLayout extends StatefulWidget {
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
  State<RZListDetailLayout> createState() => _RZListDetailLayoutState();
}

class _RZListDetailLayoutState extends State<RZListDetailLayout> {
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

        if (isCompact || widget.detail == null) {
          final showDetail = widget.isDetailVisible && widget.detail != null;
          final content = showDetail ? widget.detail! : widget.list;
          final toolbar = showDetail
              ? widget.detailToolbar
              : widget.listToolbar;

          final effectiveToolbar =
              toolbar != null || widget.destinations != null
              ? RZToolbar(
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

          final Widget body = Stack(
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

          if (!isCompact && widget.detail == null) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: body,
              ),
            );
          }
          
          return body;
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
                  content: widget.detail!,
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
  final RZToolbar? toolbar;
  final WindowSizeClass sizeClass;
  final List<NavigationDestination>? destinations;
  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final effectiveToolbar = toolbar != null || destinations != null
        ? RZToolbar(
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
