import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/src/ui/components/toolbar/items.dart';
import 'package:rhizu/src/ui/components/toolbar/placement.dart';
import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A landing layout that stacks children vertically with a max width constraint.
///
/// Integrated with [RZToolbar] to handle both actions and navigation
/// on mobile and desktop.
class RZLandingLayout extends StatefulWidget {
  const RZLandingLayout({
    required this.children,
    super.key,
    this.maxWidth = 800.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.toolbar,
    this.destinations,
    this.selectedIndex,
    this.onDestinationSelected,
  });

  /// The vertical list of widgets to display.
  final List<Widget> children;

  /// The maximum width of the content.
  final double maxWidth;

  /// The content padding.
  final EdgeInsets padding;

  /// An optional [RZToolbar] to display with the landing layout.
  final RZToolbar? toolbar;

  /// Optional navigation destinations to be integrated into the toolbar.
  final List<NavigationDestination>? destinations;

  /// The index of the currently selected destination.
  final int? selectedIndex;

  /// Called when a navigation destination is selected.
  final ValueChanged<int>? onDestinationSelected;

  @override
  State<RZLandingLayout> createState() => _RZLandingLayoutState();
}

class _RZLandingLayoutState extends State<RZLandingLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sizeClass = WindowSizeClass.fromWidth(width);

        // Calculate bottom padding for toolbar avoidance
        final bottomPadding =
            (widget.toolbar != null || widget.destinations != null)
            ? (sizeClass == WindowSizeClass.compact ? 80.0 : 100.0)
            : 16.0;

        final list = SingleChildScrollView(
          padding: widget.padding.copyWith(
            bottom: widget.padding.bottom + bottomPadding,
          ),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
          ),
        );

        final destinations = widget.destinations;
        final toolbar = widget.toolbar;

        if (toolbar == null && destinations == null) return list;

        final effectiveToolbar = RZToolbar(
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
            list,
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

@Preview(name: 'Landing Layout - With Navigation')
Widget rzLandingLayoutWithNav() {
  return RZLandingLayout(
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ],
    selectedIndex: 0,
    children: [
      ...List.generate(
        5,
        (index) => Container(
          height: 150,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text('Feature $index')),
        ),
      ),
    ],
  );
}
