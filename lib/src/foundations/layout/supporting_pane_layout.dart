import 'package:flutter/material.dart';
import 'package:rhizu/src/components/toolbars/toolbars.dart';
import 'package:rhizu/src/foundations/layout/adaptive_toolbar.dart';
import 'package:rhizu/src/foundations/layout/layout_nav.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A supporting pane layout that shows supporting content based on window size.
///
/// Integrated with [Toolbar] to handle navigation and contextual actions.
class SupportingPaneLayout extends StatefulWidget {
  const SupportingPaneLayout({
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

  /// Optional [Toolbar] for the main pane.
  final Toolbar? mainToolbar;

  /// Optional [Toolbar] for the supporting pane.
  final Toolbar? supportingToolbar;

  /// Optional navigation destinations to be integrated into the toolbar.
  final List<NavigationDestination>? destinations;

  /// The index of the currently selected destination.
  final int? selectedIndex;

  /// Called when a navigation destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<SupportingPaneLayout> createState() => _SupportingPaneLayoutState();
}

class _SupportingPaneLayoutState extends State<SupportingPaneLayout> {
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
          final effectiveToolbar =
              widget.mainToolbar != null || widget.destinations != null
              ? Toolbar(
                  style: widget.mainToolbar?.style ?? ToolbarStyle.standard,
                  leading: widget.mainToolbar?.leading,
                  trailing: widget.mainToolbar?.trailing,
                  fab: widget.mainToolbar?.fab,
                  centerTitle: widget.mainToolbar?.centerTitle ?? false,
                  scrollable: widget.mainToolbar?.scrollable ?? false,
                  backgroundColor: widget.mainToolbar?.backgroundColor,
                  elevation: widget.mainToolbar?.elevation,
                  padding: widget.mainToolbar?.padding,
                  borderRadius: widget.mainToolbar?.borderRadius,
                  shape: widget.mainToolbar?.shape,
                  children: mergeNavAndActions(
                    widget.destinations,
                    widget.selectedIndex,
                    widget.onDestinationSelected,
                    widget.mainToolbar?.children,
                  ),
                )
              : null;

          final bottomPadding = effectiveToolbar != null ? 80.0 : 0.0;

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: widget.main,
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
                flex: widget.mainFlex,
                child: _PaneWithToolbar(
                  content: widget.main,
                  toolbar: widget.mainToolbar,
                  sizeClass: sizeClass,
                  destinations: widget.destinations,
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: widget.supportingFlex,
                child: _PaneWithToolbar(
                  content: widget.supporting,
                  toolbar: widget.supportingToolbar,
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
