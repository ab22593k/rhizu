import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/layout/layout_toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A landing layout that stacks children vertically with a max width constraint.
///
/// Integrated with [RZToolbar] to handle both actions and navigation
/// on mobile and desktop.
class RZLandingLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);
        final hasToolbar = toolbar != null || destinations != null;

        final list = SingleChildScrollView(
          padding: padding.copyWith(
            bottom:
                padding.bottom +
                layoutBottomPadding(sizeClass, hasToolbar: hasToolbar),
          ),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        );

        return LayoutToolbarOverlay(
          content: list,
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
